# frozen_string_literal: true

module Admin
  class AlcaldiaCreate < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldia_create
    deps :alcaldia_repo, :state_repo

    def call(params = {})
      alcaldia = alcaldia_repo.build(params[:attrs])
      if alcaldia_repo.save(alcaldia)
        success(alcaldia: alcaldia)
      else
        states = state_repo.list_ordered
        failure(alcaldia.errors.to_hash.merge(_record: alcaldia, states: states))
      end
    end
  end
end
