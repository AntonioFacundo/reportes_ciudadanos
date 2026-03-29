# frozen_string_literal: true

module Admin
  class CitizenPrepareForm < RageArch::UseCase::Base
    use_case_symbol :admin_citizen_prepare_form
    deps :citizen_repo

    def call(params = {})
      citizen = citizen_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless citizen

      success(citizen: citizen)
    end
  end
end
