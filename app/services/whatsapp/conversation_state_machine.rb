# frozen_string_literal: true

module Whatsapp
  class ConversationStateMachine
    Result = Data.define(:new_state, :updates, :responses, :create_report)

    CATEGORY_NAMES_EXTRA = %w[Drenaje Parques Transporte].freeze

    def self.process(conversation, message)
      new(conversation, message).process
    end

    def initialize(conversation, message)
      @conv = conversation
      @msg = message
      @state = conversation.state
    end

    def process
      # Reset expired conversations
      if @conv.expired? && @state != "idle"
        return result("idle", {}, ["Tu sesión expiró. Escribe *REPORTAR* para iniciar un nuevo reporte."])
      end

      text = @msg.text&.strip&.upcase || ""

      # Global commands
      return handle_cancel if text == "CANCELAR" && @state != "idle"
      return handle_status(text) if text.start_with?("ESTADO ")

      send(:"handle_#{@state}", text)
    end

    private

    def handle_idle(text)
      if text.include?("REPORTAR") || text.include?("REPORTE") || text.include?("HOLA") || text.include?("INICIO")
        responses = []
        responses << "👋 ¡Hola! Soy el asistente de *Reportes Ciudadanos*."

        if @conv.last_alcaldia_id.present?
          alc = Alcaldia.find_by(id: @conv.last_alcaldia_id)
          if alc
            responses << "📍 Tu último municipio fue *#{alc.name}*.\n\nEnvía tu *ubicación* para detectar tu municipio automáticamente, o escribe *ANTERIOR* para usar #{alc.name}."
          else
            responses << "📍 Envía tu *ubicación* (📎 → Ubicación) para detectar tu municipio automáticamente."
          end
        else
          responses << "📍 Envía tu *ubicación* (📎 → Ubicación) para detectar tu municipio automáticamente."
        end

        result("awaiting_location", {}, responses)
      else
        result("idle", {}, [
          "👋 ¡Bienvenido a *Reportes Ciudadanos*!\n\nEscribe *REPORTAR* para crear un nuevo reporte.\nEscribe *ESTADO <número>* para consultar un reporte."
        ])
      end
    end

    def handle_awaiting_location(text)
      if text == "ANTERIOR" && @conv.last_alcaldia_id.present?
        alc = Alcaldia.find_by(id: @conv.last_alcaldia_id)
        return handle_idle("") unless alc
        return transition_to_category(alc)
      end

      if @msg.type == :location
        alc = detect_alcaldia(@msg.latitude, @msg.longitude)
        if alc
          updates = {
            pending_latitude: @msg.latitude,
            pending_longitude: @msg.longitude,
            last_alcaldia_id: alc.id
          }
          return transition_to_category(alc, updates)
        else
          return result("awaiting_location", {}, [
            "❌ No pudimos detectar tu municipio con esa ubicación.\n\nIntenta enviar tu ubicación de nuevo."
          ])
        end
      end

      result("awaiting_location", {}, [
        "📍 Necesito tu ubicación. Usa el botón de 📎 → *Ubicación* en WhatsApp para enviarla.\n\nO escribe *CANCELAR* para salir."
      ])
    end

    def handle_awaiting_category(text)
      alc = Alcaldia.find_by(id: @conv.pending_alcaldia_id)
      return handle_idle("") unless alc

      categories = Category.where(alcaldia_id: alc.id).order(:name)
      selection = @msg.list_reply_id || text

      # Match by number or list_reply_id (cat_<id>)
      category = if selection.start_with?("CAT_")
        categories.find_by(id: selection.delete_prefix("CAT_"))
      else
        idx = selection.to_i
        idx > 0 ? categories.offset(idx - 1).first : nil
      end

      if category
        result("awaiting_description", { pending_category_id: category.id }, [
          "📝 Seleccionaste *#{category.name}*.\n\nDescribe el problema con detalle:"
        ])
      else
        send_category_list(alc, categories, "Selección inválida. Elige una categoría:")
      end
    end

    def handle_awaiting_description(text)
      if @msg.type == :text && @msg.text.present? && @msg.text.strip.length >= 5
        result("awaiting_photo", { pending_description: @msg.text.strip }, [
          "📷 ¿Tienes una foto del problema?\n\nEnvía una *imagen* o escribe *OMITIR* para continuar sin foto."
        ])
      else
        result("awaiting_description", {}, [
          "📝 Escribe una descripción del problema (mínimo 5 caracteres):"
        ])
      end
    end

    def handle_awaiting_photo(text)
      if @msg.type == :image && @msg.media_id.present?
        result("awaiting_confirm", { pending_photo_media_id: @msg.media_id }, [build_summary])
      elsif text == "OMITIR" || text == "SALTAR"
        result("awaiting_confirm", {}, [build_summary])
      else
        result("awaiting_photo", {}, [
          "📷 Envía una *imagen* del problema o escribe *OMITIR* para continuar sin foto."
        ])
      end
    end

    def handle_awaiting_confirm(text)
      if text == "SI" || text == "SÍ" || text == "CONFIRMAR" || text == "OK"
        result("idle", {}, [], true)
      elsif text == "NO" || text == "CANCELAR"
        return handle_cancel
      else
        result("awaiting_confirm", {}, [
          "#{build_summary}\n\n¿Confirmas? Escribe *SI* o *CANCELAR*."
        ])
      end
    end

    def handle_cancel
      result("idle", {
        pending_alcaldia_id: nil, pending_category_id: nil,
        pending_description: nil, pending_photo_media_id: nil,
        pending_latitude: nil, pending_longitude: nil,
        pending_location_description: nil
      }, ["❌ Reporte cancelado.\n\nEscribe *REPORTAR* cuando quieras iniciar uno nuevo."])
    end

    def handle_status(text)
      folio = text.delete_prefix("ESTADO ").strip.to_i
      return result(@state, {}, ["Escribe *ESTADO* seguido del número de reporte. Ej: ESTADO 123"]) if folio <= 0

      report = Report.find_by(id: folio)
      if report && @conv.user_id && report.reporter_id == @conv.user_id
        status_text = I18n.t("status.#{report.status}", default: report.status)
        result(@state, {}, [
          "📋 *Reporte ##{report.id}*\n📌 Estado: *#{status_text}*\n📁 #{report.category&.name}\n📝 #{report.description&.truncate(100)}"
        ])
      elsif report
        result(@state, {}, ["No encontramos un reporte tuyo con ese número."])
      else
        result(@state, {}, ["No existe un reporte con el número #{folio}."])
      end
    end

    def transition_to_category(alc, extra_updates = {})
      categories = Category.where(alcaldia_id: alc.id).order(:name)
      updates = { pending_alcaldia_id: alc.id }.merge(extra_updates)

      send_category_list(alc, categories, "✅ Municipio: *#{alc.name}*\n\n¿Qué tipo de problema quieres reportar?", updates)
    end

    def send_category_list(alc, categories, header, updates = {})
      if categories.any?
        list = categories.each_with_index.map { |c, i| "#{i + 1}. #{c.name}" }.join("\n")
        result("awaiting_category", updates, [
          "#{header}\n\n#{list}\n\nResponde con el *número* de la categoría:"
        ])
      else
        result("idle", {}, ["❌ No hay categorías configuradas para #{alc.name}. Contacta a tu municipio."])
      end
    end

    def build_summary
      alc = Alcaldia.find_by(id: @conv.pending_alcaldia_id)
      cat = Category.find_by(id: @conv.pending_category_id)
      desc = @conv.pending_description || "(sin descripción)"
      photo = @conv.pending_photo_media_id.present? ? "✅ Sí" : "❌ No"

      "📋 *Resumen de tu reporte:*\n\n" \
        "🏛️ Municipio: *#{alc&.name}*\n" \
        "📁 Categoría: *#{cat&.name}*\n" \
        "📝 Descripción: #{desc}\n" \
        "📷 Foto: #{photo}\n\n" \
        "¿Confirmas? Escribe *SI* para enviar o *CANCELAR* para descartar."
    end

    def detect_alcaldia(lat, lng)
      id = Alcaldia.connection.select_value(
        ActiveRecord::Base.sanitize_sql_array([
          "SELECT id FROM alcaldias WHERE boundary IS NOT NULL AND ST_Contains(boundary, ST_SetSRID(ST_MakePoint(?, ?), 4326)) LIMIT 1",
          lng.to_f, lat.to_f
        ])
      )
      Alcaldia.find_by(id: id) if id
    end

    def result(new_state, updates, responses, create_report = false)
      Result.new(new_state:, updates:, responses:, create_report:)
    end
  end
end
