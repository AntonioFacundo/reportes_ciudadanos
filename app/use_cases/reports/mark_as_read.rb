# frozen_string_literal: true

module Reports
  class MarkAsRead < RageArch::UseCase::Base
    use_case_symbol :reports_mark_as_read
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report
      return failure(base: I18n.t("errors.unauthorized")) unless government_with_access?(user, report)
      return success(report: report) if report.read? || report.assigned? || report.resolved?

      report.status = "read"
      report.read_at = Time.current
      if report_repo.update(report, { status: "read", read_at: report.read_at })
        Rails.logger.info "[MarkAsRead] success report=#{report.id} -> will publish"
        success(report: report)
      else
        failure(report.errors.to_hash)
      end
    end

    private

    def government_with_access?(user, report)
      return false unless user&.government?
      return true if user.system_admin?
      user_alcaldia = user.alcaldia_id || user.manager&.alcaldia_id
      return false unless report.alcaldia_id == user_alcaldia
      return true if user.mayor?
      user.id == report.assignee_id || subordinate_ids(user).include?(report.assignee_id) || report.pending?
    end

    def subordinate_ids(user)
      ids = User.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "WITH RECURSIVE tree AS (
            SELECT id FROM users WHERE manager_id = ? AND active = true
            UNION ALL
            SELECT u.id FROM users u INNER JOIN tree t ON u.manager_id = t.id AND u.active = true
          ) SELECT id FROM tree",
          user.id
        ])
      )
      ids
    end
  end
end
