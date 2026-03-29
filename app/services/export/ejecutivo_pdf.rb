# frozen_string_literal: true

require "prawn"
require "prawn/table"

module Export
  class EjecutivoPdf
    def initialize(data:, date_from: nil, date_to: nil, alcaldia_name: nil)
      @data = data
      @date_from = date_from
      @date_to = date_to
      @alcaldia_name = alcaldia_name
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 50) do |pdf|
        pdf.font "Helvetica"

        # Portada / Título
        pdf.move_down 80
        pdf.text "Reporte Ejecutivo", size: 24, style: :bold, align: :center
        pdf.move_down 8
        pdf.text "Reportes Ciudadanos", size: 16, align: :center
        pdf.move_down 4
        pdf.text [@alcaldia_name, "Período: #{@date_from || '—'} a #{@date_to || '—'}"].compact.join(" | "), size: 12, align: :center, color: "555555"
        pdf.move_down 40

        # Resumen en 1–2 páginas
        pdf.text "Resumen de indicadores", size: 14, style: :bold
        pdf.move_down 12

        rate = @data[:resolution_rate]
        stage = @data[:stage_times]
        sat_total = @data[:total_resolved]
        acc = @data[:accepted_count].to_i
        sat_pct = sat_total.to_i > 0 ? (acc.to_f / sat_total * 100).round(1) : 0

        items = []
        items << "• Total de reportes creados en el período: #{rate&.sum { |r| r[:created] } || 0}"
        items << "• Total de reportes resueltos: #{rate&.sum { |r| r[:resolved] } || 0}"
        items << "• Tasa de resolución promedio: #{rate&.any? ? (rate.sum { |r| r[:rate] } / rate.size).round(1) : 0}%"
        items << "• Tiempo promedio total de atención: #{stage&.dig(:avg_total) || '—'} horas"
        items << "• Satisfacción ciudadana (aceptados): #{sat_pct}% de #{sat_total || 0} resueltos"

        sla_cat = @data[:sla_by_category]
        if sla_cat&.any?
          total_sla = sla_cat.sum { |r| r.total.to_i }
          within_sla = sla_cat.sum { |r| r.within_sla.to_i }
          sla_pct = total_sla > 0 ? (within_sla.to_f / total_sla * 100).round(1) : 0
          items << "• Cumplimiento de SLA: #{sla_pct}% (#{within_sla} de #{total_sla})"
        end

        items.each { |i| pdf.text i, size: 11; pdf.move_down 6 }

        pdf.move_down 20
        pdf.text "Conclusiones", size: 12, style: :bold
        pdf.move_down 6
        pdf.text "Este reporte presenta un resumen ejecutivo de la operación del sistema de reportes ciudadanos. Los indicadores permiten evaluar el desempeño en atención, tiempos de respuesta y satisfacción de la ciudadanía.", size: 10
        pdf.move_down 20

        pdf.text "Documento generado el #{I18n.l(Time.current, format: :long)}.", size: 9, color: "666666"
      end.render
    end
  end
end
