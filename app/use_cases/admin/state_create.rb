# frozen_string_literal: true

module Admin
  class StateCreate < RageArch::UseCase::Base
    use_case_symbol :admin_state_create
    deps :state_repo

    def call(params = {})
      state = state_repo.build(params[:attrs])
      if state_repo.save(state)
        success(state: state)
      else
        failure(state.errors.to_hash.merge(_record: state))
      end
    end
  end
end
