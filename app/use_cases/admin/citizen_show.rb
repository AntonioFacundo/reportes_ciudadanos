# frozen_string_literal: true

module Admin
  class CitizenShow < RageArch::UseCase::Base
    use_case_symbol :admin_citizen_show
    deps :citizen_repo

    def call(params = {})
      citizen = citizen_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless citizen

      reports = citizen_repo.reports_for_citizen(citizen)
      report_counts = citizen_repo.citizen_stats(citizen)
      success(citizen: citizen, reports: reports, report_counts: report_counts)
    end
  end
end
