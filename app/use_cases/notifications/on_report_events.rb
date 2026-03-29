# frozen_string_literal: true

module Notifications
  class OnReportEvents < RageArch::UseCase::Base
    use_case_symbol :notifications_on_report_events
    deps :report_broadcaster
    skip_auto_publish
    subscribe :reports_create, :reports_mark_as_read, :reports_assign,
              :reports_resolve, :reports_reject_resolution,
              :reports_accept_resolution, :reports_force_transition

    EVENT_MAP = {
      reports_create: :created,
      reports_mark_as_read: :read,
      reports_assign: :assigned,
      reports_resolve: :resolved,
      reports_reject_resolution: :rejected
    }.freeze

    def call(payload = {})
      Rails.logger.info "[OnReportEvents] received payload success=#{payload[:success]} use_case=#{payload[:use_case]}"
      return success unless payload[:success]

      report = payload.dig(:value, :report)
      Rails.logger.info "[OnReportEvents] report=#{report&.id} event_type=#{EVENT_MAP[payload[:use_case]]}"
      return success unless report

      event_name = payload[:use_case] || payload[:event]
      event_type = EVENT_MAP[event_name]

      if event_type
        report_broadcaster.broadcast_and_notify(report, event: event_type)
      else
        # reports_accept_resolution, reports_force_transition: broadcast only
        report_broadcaster.broadcast_report_updated(report)
      end

      success
    end
  end
end
