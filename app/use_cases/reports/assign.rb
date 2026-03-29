# frozen_string_literal: true

module Reports
  class Assign < RageArch::UseCase::Base
    use_case_symbol :reports_assign
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      assignee = User.active.find_by(id: params[:assignee_id])
      return failure(base: I18n.t("errors.not_found")) unless report
      return failure(base: I18n.t("errors.unauthorized")) unless government_with_access?(user, report)
      return failure(assignee_id: I18n.t("reports.assign.invalid_assignee")) unless assignee&.government?

      report.assignee_id = assignee.id
      report.status = "assigned"
      report.assigned_at = Time.current
      report.read_at ||= Time.current
      report.assignment_note = params[:assignment_note].to_s.strip.presence
      attrs = { assignee_id: assignee.id, status: "assigned", assigned_at: report.assigned_at, read_at: report.read_at }
      attrs[:assignment_note] = report.assignment_note
      if report_repo.update(report, attrs)
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
      user.id == report.assignee_id || subordinate_ids(user).include?(report.assignee_id) || report.pending? || report.read?
    end

    def subordinate_ids(user)
      User.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "WITH RECURSIVE tree AS (
            SELECT id FROM users WHERE manager_id = ? AND active = true
            UNION ALL
            SELECT u.id FROM users u INNER JOIN tree t ON u.manager_id = t.id AND u.active = true
          ) SELECT id FROM tree",
          user.id
        ])
      )
    end
  end
end
