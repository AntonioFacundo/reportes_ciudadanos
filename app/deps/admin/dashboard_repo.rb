# frozen_string_literal: true

module Admin
  class DashboardRepo
    def counts(alcaldia_ids: [])
      filter_by_alcaldia = alcaldia_ids.any?

      categories_count = filter_by_alcaldia ? Category.where(alcaldia_id: alcaldia_ids).count : Category.count
      users_count = filter_by_alcaldia ? User.where(role: %w[mayor official], alcaldia_id: alcaldia_ids).count : User.where(role: %w[mayor official]).count

      citizens_count = if filter_by_alcaldia
        User.where(role: "citizen").where(id: Report.where(alcaldia_id: alcaldia_ids).select(:reporter_id)).distinct.count
      else
        User.where(role: "citizen").count
      end

      reports_scope = Report.where(status: %w[pending read])
      reports_scope = reports_scope.where(alcaldia_id: alcaldia_ids) if filter_by_alcaldia
      reports_pending = reports_scope.count

      states_count = if filter_by_alcaldia
        State.joins(:alcaldias).where(alcaldias: { id: alcaldia_ids }).distinct.count
      else
        State.count
      end

      {
        states_count: states_count,
        categories_count: categories_count,
        users_count: users_count,
        citizens_count: citizens_count,
        reports_pending: reports_pending
      }
    end

    def admin_dashboard(user)
      reports = scoped_reports_for(user)

      counts = reports
        .pick(
          Arel.sql("COUNT(*)"),
          Arel.sql("COUNT(*) FILTER (WHERE status = 'pending')"),
          Arel.sql("COUNT(*) FILTER (WHERE status = 'assigned')"),
          Arel.sql("COUNT(*) FILTER (WHERE status = 'resolved')"),
          Arel.sql("COUNT(*) FILTER (WHERE reopened = true)")
        )
      total_reports, pending_count, assigned_count, resolved_count, reopened_count = counts.map(&:to_i)

      overdue_count = reports
        .joins(:category)
        .where.not(status: "resolved")
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at < NOW() - (categories.sla_hours || ' hours')::interval")
        .count

      leaderboard = User
        .where(role: "official", active: true)
        .then { |q| user.mayor? ? q.where(alcaldia_id: user.alcaldia_id) : q }
        .joins("INNER JOIN reports ON reports.assignee_id = users.id AND reports.status = 'resolved'")
        .select("users.id, users.name, COUNT(reports.id) AS resolved_count")
        .group("users.id, users.name")
        .order("resolved_count DESC")
        .limit(10)

      avg_resolution_by_category = reports
        .where(status: "resolved")
        .where.not(resolved_at: nil)
        .joins(:category)
        .select(
          "categories.name AS category_name",
          "categories.sla_hours",
          "AVG(EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at)) / 3600) AS avg_hours",
          "COUNT(reports.id) AS report_count"
        )
        .group("categories.name, categories.sla_hours")
        .order("avg_hours DESC")

      reports_by_category = reports
        .joins(:category)
        .select("categories.name AS category_name, COUNT(reports.id) AS report_count")
        .group("categories.name")
        .order("report_count DESC")

      recent_reports = reports.order(created_at: :desc).limit(5).includes(:category, :reporter, :alcaldia)

      heatmap_points = reports
        .where.not(latitude: nil, longitude: nil)
        .pluck(:latitude, :longitude)

      {
        total_reports: total_reports,
        pending_count: pending_count,
        assigned_count: assigned_count,
        resolved_count: resolved_count,
        reopened_count: reopened_count,
        overdue_count: overdue_count,
        leaderboard: leaderboard,
        avg_resolution_by_category: avg_resolution_by_category,
        reports_by_category: reports_by_category,
        recent_reports: recent_reports,
        heatmap_points: heatmap_points
      }
    end

    def official_dashboard(user)
      my_reports = Report.where(assignee_id: user.id)

      my_assigned_count  = my_reports.where(status: "assigned").count
      my_resolved_count  = my_reports.where(status: "resolved").count
      my_pending_count   = my_reports.where(status: %w[pending read]).count
      my_total_count     = my_reports.count

      subordinate_ids = user.subordinates.active.pluck(:id)
      team_workload = if subordinate_ids.any?
        User
          .where(id: subordinate_ids)
          .joins("LEFT JOIN reports ON reports.assignee_id = users.id AND reports.status = 'assigned'")
          .select("users.id, users.name, COUNT(reports.id) AS assigned_count")
          .group("users.id, users.name")
          .order("assigned_count DESC")
      else
        []
      end

      stale_reports = my_reports
        .where(status: "assigned")
        .joins(:category)
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at < NOW() - (categories.sla_hours || ' hours')::interval")
        .includes(:category, :reporter)
        .order(created_at: :asc)
        .limit(10)

      {
        my_assigned_count: my_assigned_count,
        my_resolved_count: my_resolved_count,
        my_pending_count: my_pending_count,
        my_total_count: my_total_count,
        team_workload: team_workload,
        stale_reports: stale_reports
      }
    end

    private

    def scoped_reports_for(user)
      if user.system_admin?
        Report.all
      elsif user.mayor?
        Report.where(alcaldia_id: user.alcaldia_id)
      else
        Report.none
      end
    end
  end
end
