# frozen_string_literal: true

class WhatsappStatusUpdateJob < ApplicationJob
  queue_as :default

  def perform(report_id, event)
    report = Report.find_by(id: report_id)
    return unless report

    user = User.find_by(id: report.reporter_id)
    return unless user&.whatsapp_phone.present?

    status_text = I18n.t("status.#{report.status}", default: report.status)

    messages = {
      "read" => "👁️ Tu reporte *##{report.id}* fue revisado por un funcionario.",
      "assigned" => "👤 Tu reporte *##{report.id}* fue asignado a un funcionario para su atención.",
      "resolved" => "✅ Tu reporte *##{report.id}* fue marcado como *resuelto*.\n\nSi no estás conforme, ingresa a la app para dar seguimiento."
    }

    text = messages[event] || "📋 Tu reporte *##{report.id}* cambió a estado: *#{status_text}*."

    Whatsapp::ApiClient.new.send_text(user.whatsapp_phone, text)
  end
end
