# frozen_string_literal: true

module Reports
  class ForceTransition < RageArch::UseCase::Base
    use_case_symbol :reports_force_transition
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user&.system_admin?

      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report

      new_status = params[:status]
      unless Report::STATUSES.include?(new_status)
        return failure(base: I18n.t("admin.reports.force_transition.invalid_status"))
      end

      old_status = report.status
      attrs = { status: new_status }

      case new_status
      when "read"
        attrs[:read_at] = Time.current unless report.read_at
      when "assigned"
        attrs[:assigned_at] = Time.current unless report.assigned_at
      when "resolved"
        attrs[:resolved_at] = Time.current unless report.resolved_at
      end

      if report.update(attrs)
        success(report: report, old_status: old_status, new_status: new_status)
      else
        failure(base: I18n.t("admin.reports.force_transition.failed"))
      end
    end
  end
end
