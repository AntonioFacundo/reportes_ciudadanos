# frozen_string_literal: true

require "prawn"
require "prawn/table"

module Export
  class ReportesPdf
    def initialize(reports:, alcaldia_name: nil, date_from: nil, date_to: nil)
      @reports = reports
      @alcaldia_name = alcaldia_name
      @date_from = date_from
      @date_to = date_to
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        pdf.font "Helvetica"
        pdf.text "Reportes Ciudadanos", size: 18, style: :bold
        pdf.move_down 4
        pdf.text safe_str(["Período: ", (@date_from.presence || "-"), " a ", (@date_to.presence || "-")].join), size: 10, color: "555555"
        pdf.text "Alcaldía: #{@alcaldia_name || 'Todas'}", size: 10, color: "555555"
        pdf.move_down 16

        headers = ["#", "Fecha", "Categoría", "Estado", "Descripción", "Alcaldía"]
        rows = @reports.limit(500).map.with_index(1) do |r, i|
          [
            i.to_s,
            safe_str(r.created_at&.strftime("%d/%m/%Y") || "—"),
            safe_str((r.respond_to?(:category) ? r.category&.name : r.try(:category_name)).to_s.truncate(25)),
            safe_str((r.status || "—").to_s),
            safe_str((r.description || "").to_s.truncate(50)),
            safe_str((r.respond_to?(:alcaldia) ? r.alcaldia&.name : r.try(:alcaldia_name)).to_s.truncate(20))
          ]
        end

        if rows.any?
          pdf.table([headers] + rows, header: true, row_colors: %w[ffffff f8fafc],
                    width: pdf.bounds.width) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = "e2e8f0"
          end
        else
          pdf.text "No hay reportes en el período seleccionado.", size: 12
        end

        pdf.move_down 20
        pdf.text safe_str("Generado: #{Time.current.strftime("%d/%m/%Y %H:%M")}"), size: 8, color: "888888"
      end.render
    end

    private

    def safe_str(s)
      s.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
        .gsub("\u2014", "-")  # em dash not in WinAnsi
    end
  end
end
