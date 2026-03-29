# frozen_string_literal: true

module Reports
  class Show < RageArch::UseCase::Base
    use_case_symbol :reports_show
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report

      return failure(base: I18n.t("errors.unauthorized")) unless authorized?(user, report)

      assignable = user&.government? ? report_repo.list_assignable_officials(user) : []
      success(report: report, assignable: assignable)
    end

    private

    def authorized?(user, report)
      return false unless user
      return true if report.reporter_id == user.id
      return true if user.system_admin?
      return false unless user.government?
      return report.alcaldia_id == user.alcaldia_id if user.mayor?
      user_alcaldia = user.alcaldia_id || user.manager&.alcaldia_id
      return false unless report.alcaldia_id == user_alcaldia
      return true if report.assignee_id == user.id
      user.subordinates.exists?(id: report.assignee_id)
    end
  end
end
