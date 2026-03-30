# frozen_string_literal: true

module Whatsapp
  class OnReportStatusChange < RageArch::UseCase::Base
    use_case_symbol :whatsapp_on_report_status_change
    skip_auto_publish
    subscribe :reports_mark_as_read, :reports_assign, :reports_resolve

    EVENT_MAP = {
      reports_mark_as_read: "read",
      reports_assign: "assigned",
      reports_resolve: "resolved"
    }.freeze

    def call(payload = {})
      return success unless payload[:success]

      report = payload.dig(:value, :report)
      return success unless report

      user = User.find_by(id: report.reporter_id)
      return success unless user&.whatsapp_phone.present?

      event = EVENT_MAP[payload[:use_case]]
      return success unless event

      WhatsappStatusUpdateJob.perform_later(report.id, event)
      success
    end
  end
end
