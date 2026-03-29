# frozen_string_literal: true

module Export
  class ReportesXlsx
    def initialize(reports:, alcaldia_name: nil, date_from: nil, date_to: nil)
      @reports = reports
      @alcaldia_name = alcaldia_name
      @date_from = date_from
      @date_to = date_to
    end

    def call
      p = Axlsx::Package.new
      wb = p.workbook
      wb.add_worksheet(name: "Reportes") do |sheet|
        header_style = sheet.workbook.styles.add_style(b: true, bg_color: "E2E8F0")
        sheet.add_row ["Reportes Ciudadanos - #{@alcaldia_name || 'Todas'}"]
        sheet.add_row ["Período: #{@date_from || '—'} a #{@date_to || '—'}"]
        sheet.add_row []
        headers = ["ID", "Fecha", "Categoría", "Estado", "Descripción", "Ubicación", "Alcaldía", "Resuelto"]
        sheet.add_row headers, style: [header_style] * headers.size
        @reports.limit(5000).each do |r|
          cat = r.respond_to?(:category) ? r.category&.name : r.try(:category_name)
          alc = r.respond_to?(:alcaldia) ? r.alcaldia&.name : r.try(:alcaldia_name)
          sheet.add_row [
            r.id,
            r.created_at&.strftime("%d/%m/%Y %H:%M"),
            cat,
            r.status,
            r.description,
            r.location_description,
            alc,
            r.resolved_at&.strftime("%d/%m/%Y")
          ]
        end
      end
      p.to_stream.read
    end
  end
end
