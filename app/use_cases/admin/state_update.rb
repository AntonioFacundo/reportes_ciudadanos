# frozen_string_literal: true

module Admin
  class StateUpdate < RageArch::UseCase::Base
    use_case_symbol :admin_state_update
    deps :state_repo

    def call(params = {})
      state = state_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless state

      if state_repo.update(state, params[:attrs])
        success(state: state)
      else
        failure(state.errors.to_hash.merge(_record: state))
      end
    end
  end
end
