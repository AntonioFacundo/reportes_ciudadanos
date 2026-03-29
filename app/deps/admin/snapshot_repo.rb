# frozen_string_literal: true

module Admin
  class SnapshotRepo
    def list_scoped(alcaldia_id: nil, base_ids: [])
      scope = ReportSnapshot.includes(:alcaldia).recent_first

      if alcaldia_id
        scope = scope.for_alcaldia(alcaldia_id)
      elsif base_ids.any?
        scope = scope.where(alcaldia_id: base_ids)
      end

      scope
    end

    def chart_data(alcaldia_id: nil, base_ids: [])
      scope = ReportSnapshot.chronological
      scope = scope.for_alcaldia(alcaldia_id) if alcaldia_id
      scope = scope.where(alcaldia_id: base_ids) if !alcaldia_id && base_ids.any?

      rows = scope
        .select(
          "snapshot_date",
          "SUM(total_reports) AS total",
          "SUM(pending_count) AS pending",
          "SUM(assigned_count) AS assigned",
          "SUM(resolved_count) AS resolved",
          "SUM(overdue_count) AS overdue",
          "AVG(avg_resolution_hours) AS avg_resolution"
        )
        .group(:snapshot_date)
        .order(:snapshot_date)
        .last(60)

      {
        labels: rows.map { |r| r.snapshot_date.strftime("%d/%m") },
        total: rows.map { |r| r.total.to_i },
        pending: rows.map { |r| r.pending.to_i },
        assigned: rows.map { |r| r.assigned.to_i },
        resolved: rows.map { |r| r.resolved.to_i },
        overdue: rows.map { |r| r.overdue.to_i },
        avg_resolution: rows.map { |r| r.avg_resolution&.round(1) }
      }
    end

    def capture!
      ReportSnapshot.capture!(date: Date.current)
    end
  end
end
