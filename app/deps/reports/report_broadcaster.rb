# frozen_string_literal: true

module Reports
  class ReportBroadcaster
    def broadcast_and_notify(report, event:)
      Broadcaster.broadcast_and_notify(report, event: event)
    end

    def broadcast_report_updated(report)
      Broadcaster.broadcast_report_updated(report)
    end
  end
end
