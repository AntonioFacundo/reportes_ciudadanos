# frozen_string_literal: true

require "prawn"
require "prawn/table"

module Export
  class AnalyticsPdf
    def initialize(data:, date_from: nil, date_to: nil, alcaldia_name: nil)
      @data = data
      @date_from = date_from
      @date_to = date_to
      @alcaldia_name = alcaldia_name
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        pdf.font "Helvetica"
        pdf.text "Analíticas de Reportes Ciudadanos", size: 18, style: :bold
        pdf.text safe_str("Alcaldía: #{@alcaldia_name || 'Todas'} | Período: #{@date_from || '-'} a #{@date_to || '-'}"), size: 10, color: "555555"
        pdf.move_down 20

        # Tasa de resolución
        if (rate = @data[:resolution_rate])&.any?
          pdf.text "Tasa de resolución mensual", size: 12, style: :bold
          pdf.move_down 8
          headers = ["Mes", "Creados", "Resueltos", "Tasa %"]
          rows = rate.map { |r| [safe_str(r[:month].to_s), r[:created].to_s, r[:resolved].to_s, "#{r[:rate]}%"] }
          pdf.table([headers] + rows, header: true, row_colors: %w[ffffff f8fafc], width: pdf.bounds.width) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = "e2e8f0"
          end
          pdf.move_down 16
        end

        # Tiempos por etapa
        if (stage = @data[:stage_times])
          pdf.text "Tiempo promedio por etapa (horas)", size: 12, style: :bold
          pdf.move_down 4
          pdf.text safe_str("Creado->Leído: #{stage[:avg_to_read] || '-'}h | Leído->Asignado: #{stage[:avg_to_assign] || '-'}h | Asignado->Resuelto: #{stage[:avg_to_resolve] || '-'}h | Total: #{stage[:avg_total] || '-'}h")
          pdf.move_down 16
        end

        # SLA por categoría
        if (sla = @data[:sla_by_category])&.any?
          pdf.text "Cumplimiento SLA por categoría", size: 12, style: :bold
          pdf.move_down 8
          headers = ["Categoría", "SLA(h)", "Total", "Dentro SLA", "%"]
          rows = sla.map do |r|
            pct = r.total.to_i > 0 ? (r.within_sla.to_i.to_f / r.total.to_i * 100).round(1) : 0
            [safe_str(r.cat_name.to_s), (r.sla_hours || "-").to_s, r.total.to_s, r.within_sla.to_s, "#{pct}%"]
          end
          pdf.table([headers] + rows, header: true, row_colors: %w[ffffff f8fafc], width: pdf.bounds.width) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = "e2e8f0"
          end
          pdf.move_down 16
        end

        # Satisfacción
        if (sat = @data[:total_resolved])
          pdf.text "Satisfacción ciudadana", size: 12, style: :bold
          pdf.move_down 4
          total = sat
          acc = @data[:accepted_count].to_i
          rej = @data[:rejected_count].to_i
          no_resp = @data[:no_response_count].to_i
          pct = total > 0 ? (acc.to_f / total * 100).round(1) : 0
          pdf.text safe_str("Resueltos: #{total} | Aceptados: #{acc} | Rechazados: #{rej} | Sin respuesta: #{no_resp} | % Aceptación: #{pct}%")
          pdf.move_down 16
        end

        # Zonas más reportadas
        if (locs = @data[:top_locations])&.any?
          pdf.text "Zonas con más reportes", size: 12, style: :bold
          pdf.move_down 8
          locs.first(10).each_with_index do |loc, i|
            pdf.text safe_str("#{i + 1}. #{loc.respond_to?(:location_description) ? loc.location_description : loc[:location_description]} - #{loc.respond_to?(:cnt) ? loc.cnt : loc[:cnt]} reportes")
            pdf.move_down 2
          end
          pdf.move_down 16
        end

        pdf.text safe_str("Generado: #{Time.current.strftime("%d/%m/%Y %H:%M")}"), size: 8, color: "888888"
      end.render
    end

    private

    def safe_str(s)
      s.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
        .gsub(/\u2014/, "-").gsub(/\u2192/, "->")  # em dash, arrow
    end
  end
end
