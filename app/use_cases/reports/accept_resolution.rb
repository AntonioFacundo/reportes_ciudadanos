# frozen_string_literal: true

module Reports
  class AcceptResolution < RageArch::UseCase::Base
    use_case_symbol :reports_accept_resolution
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report
      return failure(base: I18n.t("errors.unauthorized")) unless user&.id == report.reporter_id
      return failure(base: I18n.t("reports.accept_resolution.not_resolved")) unless report.resolved?
      return failure(base: I18n.t("reports.accept_resolution.already_accepted")) if report.reporter_accepted_at.present?

      if report_repo.update(report, { reporter_accepted_at: Time.current })
        report.update_column(:reopened, false)
        success(report: report)
      else
        failure(report.errors.to_hash)
      end
    end
  end
end
