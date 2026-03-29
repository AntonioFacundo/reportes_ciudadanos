# frozen_string_literal: true

module Admin
  class AlcaldiasByState < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldias_by_state
    deps :alcaldia_repo

    def call(params = {})
      alcaldias = alcaldia_repo.list_by_state(params[:state_id])
      success(alcaldias: alcaldias.map { |a| { id: a.id, name: a.name } })
    end
  end
end
