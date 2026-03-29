# frozen_string_literal: true

module Admin
  class StatesIndex < RageArch::UseCase::Base
    use_case_symbol :admin_states_index
    deps :state_repo

    def call(params = {})
      states = state_repo.list_with_counts
      success(states: states)
    end
  end
end
