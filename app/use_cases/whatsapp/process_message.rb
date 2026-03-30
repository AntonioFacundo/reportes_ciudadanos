# frozen_string_literal: true

module Whatsapp
  class ProcessMessage < RageArch::UseCase::Base
    use_case_symbol :whatsapp_process_message
    deps :conversation_repo, :whatsapp_citizen_repo, :report_repo

    def call(params = {})
      message = params[:message]
      return success unless message

      conversation = conversation_repo.find_or_create_by_phone(message.phone)

      # Ensure citizen user exists and is linked
      unless conversation.user_id
        user = whatsapp_citizen_repo.find_or_create_by_phone(message.phone, name: message.name)
        conversation_repo.update(conversation, user_id: user.id)
      end

      result = ConversationStateMachine.process(conversation, message)

      # Apply state and field updates
      updates = result.updates.merge(state: result.new_state)
      conversation_repo.update(conversation, updates)
      conversation.touch_expiry!

      # Create report if confirmed
      if result.create_report
        report = create_report(conversation, message)
        if report
          conversation.reset!
          send_responses(message.phone, [
            "✅ *¡Reporte ##{report.id} creado!*\n\n" \
            "Te avisaremos por aquí cuando haya avances.\n" \
            "Consulta el estado escribiendo: *ESTADO #{report.id}*"
          ])
        else
          send_responses(message.phone, ["❌ Hubo un error al crear tu reporte. Intenta de nuevo."])
        end
      else
        send_responses(message.phone, result.responses)
      end

      success
    end

    private

    def create_report(conversation, message)
      report = Report.new(
        reporter_id: conversation.user_id,
        category_id: conversation.pending_category_id,
        alcaldia_id: conversation.pending_alcaldia_id,
        description: conversation.pending_description,
        latitude: conversation.pending_latitude,
        longitude: conversation.pending_longitude,
        location_description: conversation.pending_location_description,
        source: "whatsapp"
      )

      # Attach photo if present
      if conversation.pending_photo_media_id.present?
        begin
          media = ApiClient.new.download_media(conversation.pending_photo_media_id)
          ext = media[:content_type]&.include?("png") ? "png" : "jpg"
          report.photos.attach(
            io: StringIO.new(media[:binary]),
            filename: "whatsapp_#{SecureRandom.hex(4)}.#{ext}",
            content_type: media[:content_type]
          )
        rescue => e
          Rails.logger.error "[WhatsApp] Failed to download photo: #{e.message}"
        end
      end

      report_repo.save(report) ? report : nil
    end

    def send_responses(phone, messages)
      client = ApiClient.new
      messages.each { |text| client.send_text(phone, text) }
    end
  end
end
