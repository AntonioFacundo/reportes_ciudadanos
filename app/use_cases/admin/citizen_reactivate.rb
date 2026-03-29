# frozen_string_literal: true

module Admin
  class CitizenReactivate < RageArch::UseCase::Base
    use_case_symbol :admin_citizen_reactivate
    deps :citizen_repo

    def call(params = {})
      citizen = citizen_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless citizen

      if citizen_repo.update(citizen, { active: true })
        success(citizen: citizen)
      else
        failure(base: I18n.t("admin.citizens.reactivate.failed"))
      end
    end
  end
end
