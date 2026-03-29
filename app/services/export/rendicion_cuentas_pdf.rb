# frozen_string_literal: true

require "prawn"
require "prawn/table"

module Export
  class RendicionCuentasPdf
    def initialize(data:, date_from: nil, date_to: nil, alcaldia_name: nil)
      @data = data
      @date_from = date_from
      @date_to = date_to
      @alcaldia_name = alcaldia_name
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 50) do |pdf|
        pdf.font "Helvetica"

        # Encabezado formal
        pdf.text "RENDICIÓN DE CUENTAS", size: 16, style: :bold, align: :center
        pdf.move_down 4
        pdf.text "Sistema de Reportes Ciudadanos", size: 12, align: :center
        pdf.move_down 4
        pdf.text @alcaldia_name || "Municipio", size: 11, align: :center, color: "333333"
        pdf.move_down 2
        pdf.text "Período: #{@date_from || '—'} al #{@date_to || '—'}", size: 10, align: :center, color: "555555"
        pdf.move_down 20

        # Sección 1: Atención ciudadana
        pdf.text "1. INDICADORES DE ATENCIÓN CIUDADANA", size: 12, style: :bold
        pdf.move_down 10

        rate = @data[:resolution_rate]
        created = rate&.sum { |r| r[:created] } || 0
        resolved = rate&.sum { |r| r[:resolved] } || 0
        res_pct = created > 0 ? (resolved.to_f / created * 100).round(1) : 0

        table1 = [
          ["Indicador", "Valor"],
          ["Reportes recibidos en el período", created.to_s],
          ["Reportes atendidos y resueltos", resolved.to_s],
          ["Tasa de resolución (%)", "#{res_pct}%"],
          ["Tiempo promedio de atención (horas)", (@data[:stage_times]&.dig(:avg_total) || "—").to_s]
        ]
        pdf.table(table1, header: true, row_colors: %w[ffffff f8fafc], width: pdf.bounds.width) do |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = "e2e8f0"
        end
        pdf.move_down 20

        # Sección 2: Satisfacción
        pdf.text "2. INDICADORES DE SATISFACCIÓN", size: 12, style: :bold
        pdf.move_down 10

        total_r = @data[:total_resolved].to_i
        acc = @data[:accepted_count].to_i
        rej = @data[:rejected_count].to_i
        no_r = @data[:no_response_count].to_i
        acc_pct = total_r > 0 ? (acc.to_f / total_r * 100).round(1) : 0

        table2 = [
          ["Indicador", "Valor"],
          ["Reportes resueltos con respuesta del ciudadano", total_r.to_s],
          ["Respuestas aceptadas (ciudadano satisfecho)", "#{acc} (#{acc_pct}%)"],
          ["Respuestas rechazadas (reabiertos)", rej.to_s],
          ["Sin respuesta del ciudadano", no_r.to_s]
        ]
        pdf.table(table2, header: true, row_colors: %w[ffffff f8fafc], width: pdf.bounds.width) do |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = "e2e8f0"
        end
        pdf.move_down 20

        # Sección 3: Cumplimiento de compromisos (SLA)
        pdf.text "3. CUMPLIMIENTO DE TIEMPOS DE RESPUESTA (SLA)", size: 12, style: :bold
        pdf.move_down 10

        sla_cat = @data[:sla_by_category]
        if sla_cat&.any?
          total_sla = sla_cat.sum { |r| r.total.to_i }
          within_sla = sla_cat.sum { |r| r.within_sla.to_i }
          sla_pct = total_sla > 0 ? (within_sla.to_f / total_sla * 100).round(1) : 0
          table3 = [
            ["Indicador", "Valor"],
            ["Reportes con SLA definido", total_sla.to_s],
            ["Dentro del tiempo comprometido", "#{within_sla} (#{sla_pct}%)"],
            ["Fuera del tiempo comprometido", (total_sla - within_sla).to_s]
          ]
          pdf.table(table3, header: true, row_colors: %w[ffffff f8fafc], width: pdf.bounds.width) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = "e2e8f0"
          end
        else
          pdf.text "No hay categorías con SLA configurado en el período.", size: 10, color: "666666"
        end
        pdf.move_down 24

        # Pie formal
        pdf.stroke_horizontal_rule
        pdf.move_down 12
        pdf.text "Documento generado con fines de transparencia y rendición de cuentas.", size: 9, color: "666666"
        pdf.text "Fecha de emisión: #{Time.current.strftime("%d/%m/%Y %H:%M")}", size: 9, color: "666666"
      end.render
    end
  end
end
