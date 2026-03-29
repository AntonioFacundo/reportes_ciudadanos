# frozen_string_literal: true

module Admin
  class ExportsController < BaseController

    def reportes_pdf
      run :admin_export_reportes, export_params,
          success: ->(r) {
            pdf = Export::ReportesPdf.new(
              reports: r.value[:reports],
              alcaldia_name: r.value[:alcaldia_name],
              date_from: r.value[:date_from],
              date_to: r.value[:date_to]
            ).call
            send_data pdf, filename: "reportes_#{Date.current.iso8601}.pdf", type: "application/pdf", disposition: "attachment"
          },
          failure: ->(res) { redirect_to inbox_path, alert: error_messages_from(res) }
    rescue StandardError => e
      Rails.logger.error("Export PDF error: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      redirect_to inbox_path, alert: "Error al generar el PDF: #{e.message}"
    end

    def reportes_xlsx
      run :admin_export_reportes, export_params,
          success: ->(r) {
            xlsx = Export::ReportesXlsx.new(
              reports: r.value[:reports],
              alcaldia_name: r.value[:alcaldia_name],
              date_from: r.value[:date_from],
              date_to: r.value[:date_to]
            ).call
            send_data xlsx, filename: "reportes_#{Date.current.iso8601}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: "attachment"
          },
          failure: ->(res) { redirect_to inbox_path, alert: error_messages_from(res) }
    end

    def analytics_pdf
      run :admin_analytics_export_data, analytics_export_params,
          success: ->(r) {
            pdf = Export::AnalyticsPdf.new(
              data: r.value[:data],
              date_from: r.value[:date_from],
              date_to: r.value[:date_to],
              alcaldia_name: r.value[:alcaldia_name]
            ).call
            send_data pdf, filename: "analiticas_#{Date.current.iso8601}.pdf", type: "application/pdf", disposition: "attachment"
          },
          failure: ->(res) { redirect_to admin_analytics_path, alert: error_messages_from(res) }
    rescue StandardError => e
      Rails.logger.error("Export analytics PDF error: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      redirect_to admin_analytics_path, alert: "Error al generar el PDF: #{e.message}"
    end

    def ejecutivo_pdf
      run :admin_analytics_export_data, analytics_export_params,
          success: ->(r) {
            pdf = Export::EjecutivoPdf.new(
              data: r.value[:data],
              date_from: r.value[:date_from],
              date_to: r.value[:date_to],
              alcaldia_name: r.value[:alcaldia_name]
            ).call
            send_data pdf, filename: "reporte_ejecutivo_#{Date.current.iso8601}.pdf", type: "application/pdf", disposition: "attachment"
          },
          failure: ->(res) { redirect_to admin_analytics_path, alert: error_messages_from(res) }
    rescue StandardError => e
      Rails.logger.error("Export ejecutivo PDF error: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      redirect_to admin_analytics_path, alert: "Error al generar el PDF: #{e.message}"
    end

    def rendicion_cuentas_pdf
      run :admin_analytics_export_data, analytics_export_params,
          success: ->(r) {
            pdf = Export::RendicionCuentasPdf.new(
              data: r.value[:data],
              date_from: r.value[:date_from],
              date_to: r.value[:date_to],
              alcaldia_name: r.value[:alcaldia_name]
            ).call
            send_data pdf, filename: "rendicion_cuentas_#{Date.current.iso8601}.pdf", type: "application/pdf", disposition: "attachment"
          },
          failure: ->(res) { redirect_to admin_analytics_path, alert: error_messages_from(res) }
    rescue StandardError => e
      Rails.logger.error("Export rendicion PDF error: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      redirect_to admin_analytics_path, alert: "Error al generar el PDF: #{e.message}"
    end

    private

    def export_params
      {
        current_user: Current.user,
        q: params[:q],
        category_id: params[:category_id],
        status: params[:status],
        date_from: params[:date_from],
        date_to: params[:date_to],
        alcaldia_id: params[:alcaldia_id]
      }
    end

    def analytics_params
      {
        current_user: Current.user,
        alcaldia_id: params[:alcaldia_id],
        state_id: params[:state_id],
        tab: "team",
        date_from: params[:date_from],
        date_to: params[:date_to]
      }
    end

    def analytics_export_params
      {
        current_user: Current.user,
        alcaldia_id: params[:alcaldia_id],
        state_id: params[:state_id],
        date_from: params[:date_from],
        date_to: params[:date_to]
      }
    end
  end
end
