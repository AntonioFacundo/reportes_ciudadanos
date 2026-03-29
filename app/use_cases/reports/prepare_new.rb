# frozen_string_literal: true

module Reports
  class PrepareNew < RageArch::UseCase::Base
    use_case_symbol :reports_prepare_new
    deps :report_repo

    def call(params = {})
      alcaldias = report_repo.list_alcaldias
      report = report_repo.build
      success(categories: [], alcaldias: alcaldias, report: report)
    end
  end
end
