# frozen_string_literal: true

module Admin
  class CitizenDeactivate < RageArch::UseCase::Base
    use_case_symbol :admin_citizen_deactivate
    deps :citizen_repo

    def call(params = {})
      citizen = citizen_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless citizen

      if citizen_repo.update(citizen, { active: false })
        success(citizen: citizen)
      else
        failure(base: I18n.t("admin.citizens.deactivate.failed"))
      end
    end
  end
end
