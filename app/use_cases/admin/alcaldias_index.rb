# frozen_string_literal: true

module Admin
  class AlcaldiasIndex < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldias_index
    deps :alcaldia_repo, :state_repo

    def call(params = {})
      states = state_repo.list_ordered
      alcaldias = alcaldia_repo.list_with_counts(state_id: params[:state_id])
      success(alcaldias: alcaldias, states: states)
    end
  end
end
