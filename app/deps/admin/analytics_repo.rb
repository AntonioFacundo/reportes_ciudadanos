# frozen_string_literal: true

module Admin
  class AnalyticsRepo
    def scoped_reports(alcaldia_id: nil, base_ids: [], date_from: nil, date_to: nil)
      scope = Report.all
      scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id
      scope = scope.where(alcaldia_id: base_ids) if !alcaldia_id && base_ids.any?
      scope = scope.where("reports.created_at >= ?", parse_date(date_from).beginning_of_day) if date_from.present?
      scope = scope.where("reports.created_at <= ?", parse_date(date_to).end_of_day) if date_to.present?
      scope
    end

    def resolution_rate(reports, date_from: nil, date_to: nil)
      start_date, end_date, months = date_range_months(date_from, date_to)

      created_by_month = reports
        .where("reports.created_at >= ?", start_date)
        .where("reports.created_at <= ?", end_date)
        .group(Arel.sql("DATE_TRUNC('month', reports.created_at)"))
        .count

      resolved_by_month = reports
        .where(status: "resolved")
        .where("reports.resolved_at >= ?", start_date)
        .where("reports.resolved_at <= ?", end_date)
        .where.not(resolved_at: nil)
        .group(Arel.sql("DATE_TRUNC('month', reports.resolved_at)"))
        .count

      months.map do |m|
        key = m.beginning_of_month.in_time_zone
        created = created_by_month[key].to_i
        resolved = resolved_by_month[key].to_i
        rate = created > 0 ? (resolved.to_f / created * 100).round(1) : 0
        { month: I18n.l(m, format: "%b %Y"), created: created, resolved: resolved, rate: rate }
      end
    end

    def stage_times(reports, date_from: nil, date_to: nil)
      reports = reports
      reports = reports.where("reports.created_at >= ?", parse_date(date_from).beginning_of_day) if date_from.present?
      reports = reports.where("reports.created_at <= ?", parse_date(date_to).end_of_day) if date_to.present?
      row = reports.where(status: "resolved").where.not(resolved_at: nil).pick(
        Arel.sql("AVG(CASE WHEN read_at IS NOT NULL THEN EXTRACT(EPOCH FROM (read_at - created_at)) / 3600 END)"),
        Arel.sql("AVG(CASE WHEN assigned_at IS NOT NULL THEN EXTRACT(EPOCH FROM (assigned_at - COALESCE(read_at, created_at))) / 3600 END)"),
        Arel.sql("AVG(CASE WHEN assigned_at IS NOT NULL THEN EXTRACT(EPOCH FROM (resolved_at - assigned_at)) / 3600 END)"),
        Arel.sql("AVG(EXTRACT(EPOCH FROM (resolved_at - created_at)) / 3600)")
      )
      {
        avg_to_read: row[0]&.to_f&.round(1),
        avg_to_assign: row[1]&.to_f&.round(1),
        avg_to_resolve: row[2]&.to_f&.round(1),
        avg_total: row[3]&.to_f&.round(1)
      }
    end

    def official_load(alcaldia_id: nil)
      scope = User.where(role: "official", active: true)
      scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id.present?
      scope
        .joins("LEFT JOIN reports ON reports.assignee_id = users.id AND reports.status IN ('assigned','read','pending')")
        .select("users.id, users.name, COUNT(reports.id) AS open_count")
        .group("users.id, users.name")
        .order("open_count DESC")
        .limit(15)
    end

    def official_reopens(alcaldia_id: nil)
      scope = User.where(role: "official", active: true)
      scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id.present?
      scope
        .joins("INNER JOIN reports ON reports.assignee_id = users.id AND reports.reopened = true")
        .select("users.id, users.name, COUNT(reports.id) AS reopen_count")
        .group("users.id, users.name")
        .having("COUNT(reports.id) > 0")
        .order("reopen_count DESC")
        .limit(15)
    end

    def time_distributions(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      rows = reports
        .select(
          "EXTRACT(DOW FROM created_at)::int AS dow",
          "EXTRACT(HOUR FROM created_at)::int AS hr",
          "COUNT(*) AS cnt"
        )
        .group("dow, hr")
        .to_a

      dow_counts = Array.new(7, 0)
      hour_counts = Array.new(24, 0)
      rows.each do |r|
        dow_counts[r.dow] += r.cnt
        hour_counts[r.hr] += r.cnt
      end

      {
        by_dow: dow_counts.each_with_index.map { |cnt, i| { dow: i, count: cnt } },
        by_hour: hour_counts.each_with_index.map { |cnt, i| { hour: i, count: cnt } }
      }
    end

    def monthly_comparison(reports, date_from: nil, date_to: nil)
      start_date, end_date, months = date_range_months(date_from, date_to)

      raw = reports
        .joins(:category)
        .where("reports.created_at >= ?", start_date)
        .where("reports.created_at <= ?", end_date)
        .group(Arel.sql("DATE_TRUNC('month', reports.created_at)"), :category_id)
        .pluck(Arel.sql("DATE_TRUNC('month', reports.created_at)"), :category_id, Arel.sql("COUNT(*)"))

      counts = {}
      cat_ids = Set.new
      raw.each do |month_ts, cat_id, cnt|
        key = month_ts.to_date
        counts[[key, cat_id]] = cnt
        cat_ids << cat_id
      end

      categories = Category.where(id: cat_ids.to_a).order(:name).pluck(:name, :id)

      months.map do |m|
        by_cat = categories.map do |name, id|
          { name: name, count: counts[[m, id]] || 0 }
        end
        { month: I18n.l(m, format: "%b %Y"), total: by_cat.sum { |c| c[:count] }, categories: by_cat }
      end
    end

    def problem_categories(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      reports
        .joins(:category)
        .where.not(status: "resolved")
        .select(
          "categories.name AS cat_name",
          "COUNT(*) AS open_count",
          "SUM(CASE WHEN reports.reopened THEN 1 ELSE 0 END) AS reopen_count",
          "categories.sla_hours"
        )
        .group("categories.name, categories.sla_hours")
        .order("open_count DESC")
    end

    def top_locations(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      reports
        .where.not(location_description: [nil, ""])
        .select("location_description, COUNT(*) AS cnt")
        .group("location_description")
        .order("cnt DESC")
        .limit(10)
    end

    # Reporte por colonia/zona: ubicaciones agrupadas con categorías para planeación territorial
    def report_by_zone(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      reports
        .joins(:category)
        .where.not(location_description: [nil, ""])
        .select(
          "location_description AS zona",
          "categories.name AS categoria",
          "COUNT(*) AS total",
          "SUM(CASE WHEN reports.status = 'resolved' THEN 1 ELSE 0 END) AS resueltos"
        )
        .group("location_description", "categories.name")
        .order("total DESC")
        .limit(50)
    end

    def sla_by_category(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      reports
        .joins(:category)
        .where("categories.sla_hours IS NOT NULL")
        .select(
          "categories.name AS cat_name",
          "categories.sla_hours",
          "COUNT(*) AS total",
          "SUM(CASE WHEN reports.status = 'resolved' AND EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at))/3600 <= categories.sla_hours THEN 1 WHEN reports.status != 'resolved' AND EXTRACT(EPOCH FROM (NOW() - reports.created_at))/3600 <= categories.sla_hours THEN 1 ELSE 0 END) AS within_sla"
        )
        .group("categories.name, categories.sla_hours")
        .order("categories.name")
    end

    def sla_by_official(alcaldia_id: nil)
      scope = User.where(role: "official", active: true)
      scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id.present?
      scope
        .joins("INNER JOIN reports ON reports.assignee_id = users.id")
        .joins("INNER JOIN categories ON categories.id = reports.category_id AND categories.sla_hours IS NOT NULL")
        .select(
          "users.id, users.name",
          "COUNT(reports.id) AS total",
          "SUM(CASE WHEN reports.status = 'resolved' AND EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at))/3600 <= categories.sla_hours THEN 1 WHEN reports.status != 'resolved' AND EXTRACT(EPOCH FROM (NOW() - reports.created_at))/3600 <= categories.sla_hours THEN 1 ELSE 0 END) AS within_sla"
        )
        .group("users.id, users.name")
        .order(Arel.sql("(SUM(CASE WHEN reports.status = 'resolved' AND EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at))/3600 <= categories.sla_hours THEN 1 WHEN reports.status != 'resolved' AND EXTRACT(EPOCH FROM (NOW() - reports.created_at))/3600 <= categories.sla_hours THEN 1 ELSE 0 END)::float / NULLIF(COUNT(reports.id), 0)) ASC NULLS LAST"))
        .limit(20)
    end

    def sla_trend(reports, date_from: nil, date_to: nil)
      start_date, end_date, months = date_range_months(date_from, date_to)
      reports = apply_date_filter(reports, date_from, date_to)
      rows = reports
        .joins(:category)
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at >= ?", start_date)
        .select(
          "DATE_TRUNC('month', reports.created_at) AS month_start",
          "COUNT(*) AS total",
          "SUM(CASE WHEN reports.status = 'resolved' AND EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at))/3600 <= categories.sla_hours THEN 1 WHEN reports.status != 'resolved' AND EXTRACT(EPOCH FROM (NOW() - reports.created_at))/3600 <= categories.sla_hours THEN 1 ELSE 0 END) AS within_sla"
        )
        .group("month_start")
        .order("month_start")

      by_month = rows.index_by { |r| r.month_start.to_date }
      months.map do |m|
        row = by_month[m]
        total = row&.total.to_i
        within = row&.within_sla.to_i
        { month: I18n.l(m, format: "%b %Y"), total: total, within: within, pct: total > 0 ? (within.to_f / total * 100).round(1) : 0 }
      end
    end

    def red_flags(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      reports
        .joins(:category)
        .where.not(status: "resolved")
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at < NOW() - (categories.sla_hours || ' hours')::interval")
        .preload(:assignee, :alcaldia)
        .select("reports.*, categories.name AS cat_name, categories.sla_hours AS cat_sla_hours")
        .order(created_at: :asc)
        .limit(15)
    end

    def satisfaction(reports, date_from: nil, date_to: nil)
      reports = apply_date_filter(reports, date_from, date_to)
      resolved = reports.where(status: "resolved")
      counts = resolved.pick(
        Arel.sql("COUNT(*)"),
        Arel.sql("COUNT(*) FILTER (WHERE reporter_accepted_at IS NOT NULL)"),
        Arel.sql("COUNT(*) FILTER (WHERE reopened = true)")
      )
      total_resolved = counts[0].to_i
      accepted_count = counts[1].to_i
      rejected_count = counts[2].to_i
      no_response_count = total_resolved - accepted_count - rejected_count

      acceptance_by_category = resolved
        .joins(:category)
        .select(
          "categories.name AS cat_name",
          "COUNT(*) AS total",
          "SUM(CASE WHEN reporter_accepted_at IS NOT NULL THEN 1 ELSE 0 END) AS accepted",
          "SUM(CASE WHEN reopened = true THEN 1 ELSE 0 END) AS rejected"
        )
        .group("categories.name")
        .order("categories.name")

      inactive_reports = reports
        .where(status: %w[pending read])
        .where("reports.created_at < ?", 7.days.ago)
        .includes(:category, :alcaldia, :reporter)
        .order(created_at: :asc)
        .limit(15)

      {
        total_resolved: total_resolved,
        accepted_count: accepted_count,
        rejected_count: rejected_count,
        no_response_count: no_response_count,
        acceptance_by_category: acceptance_by_category,
        inactive_reports: inactive_reports
      }
    end

    # Comparativa año contra año: datos del año actual vs año anterior
    def year_over_year(reports, date_from: nil, date_to: nil)
      start_date, end_date, _ = date_range_months(date_from, date_to)
      this_year = reports.where("reports.created_at >= ?", start_date).where("reports.created_at <= ?", end_date)
      prev_start = start_date - 1.year
      prev_end = end_date - 1.year
      prev_year = reports.where("reports.created_at >= ?", prev_start).where("reports.created_at <= ?", prev_end)

      created_this = this_year.count
      resolved_this = this_year.where(status: "resolved").where.not(resolved_at: nil).count
      created_prev = prev_year.count
      resolved_prev = prev_year.where(status: "resolved").where.not(resolved_at: nil).count

      {
        this_year: { created: created_this, resolved: resolved_this, rate: created_this > 0 ? (resolved_this.to_f / created_this * 100).round(1) : 0 },
        prev_year: { created: created_prev, resolved: resolved_prev, rate: created_prev > 0 ? (resolved_prev.to_f / created_prev * 100).round(1) : 0 },
        period_label: "#{start_date.year} vs #{prev_start.year}"
      }
    end

    private

    def date_range_months(date_from, date_to)
      if date_from.present? && date_to.present?
        from = parse_date(date_from).to_date
        to = parse_date(date_to).to_date
        start_date = from.beginning_of_month
        end_date = to.end_of_month
        months = []
        cursor = start_date
        while cursor <= end_date
          months << cursor
          cursor = cursor + 1.month
        end
        [start_date, end_date, months]
      else
        start_date = 5.months.ago.beginning_of_month
        end_date = Time.current.end_of_month
        months = 6.times.map { |i| i.months.ago.beginning_of_month.to_date }.reverse
        [start_date, end_date, months]
      end
    end

    def parse_date(val)
      val.is_a?(Date) || val.is_a?(Time) ? val : Date.parse(val.to_s)
    rescue Date::Error
      Date.current
    end

    def apply_date_filter(scope, date_from, date_to)
      scope = scope.where("reports.created_at >= ?", parse_date(date_from).beginning_of_day) if date_from.present?
      scope = scope.where("reports.created_at <= ?", parse_date(date_to).end_of_day) if date_to.present?
      scope
    end
  end
end
