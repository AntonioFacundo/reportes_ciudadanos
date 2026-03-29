# frozen_string_literal: true

module Admin
  class CitizenRepo
    def find(id)
      User.where(role: "citizen").find_by(id: id)
    end

    def list(q: nil, status: nil)
      scope = User.where(role: "citizen")
      scope = scope.where("users.name ILIKE ?", "%#{q}%") if q.present?

      case status.to_s
      when "active"   then scope = scope.active
      when "inactive" then scope = scope.where(active: false)
      end

      scope.order(created_at: :desc)
    end

    def update(record, attrs)
      record.assign_attributes(attrs)
      record.save
    end

    def report_counts_for(user_ids)
      Report.where(reporter_id: user_ids).group(:reporter_id).count
    end

    def reports_for_citizen(citizen)
      citizen.reports_as_reporter.includes(:category, :alcaldia).order(created_at: :desc)
    end

    def citizen_stats(citizen)
      citizen.reports_as_reporter.pick(
        Arel.sql("COUNT(*)"),
        Arel.sql("COUNT(*) FILTER (WHERE status IN ('pending','read','assigned'))"),
        Arel.sql("COUNT(*) FILTER (WHERE status = 'resolved')")
      ).map(&:to_i)
    end
  end
end
