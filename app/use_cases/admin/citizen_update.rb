# frozen_string_literal: true

module Admin
  class CitizenUpdate < RageArch::UseCase::Base
    use_case_symbol :admin_citizen_update
    deps :citizen_repo

    def call(params = {})
      citizen = citizen_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless citizen

      if citizen_repo.update(citizen, params[:attrs])
        success(citizen: citizen)
      else
        failure(citizen.errors.to_hash.merge(_record: citizen))
      end
    end
  end
end
