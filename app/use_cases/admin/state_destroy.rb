# frozen_string_literal: true

module Admin
  class StateDestroy < RageArch::UseCase::Base
    use_case_symbol :admin_state_destroy
    deps :state_repo

    def call(params = {})
      state = state_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless state

      if state_repo.has_dependencies?(state)
        return failure(base: I18n.t("admin.states.destroy.has_alcaldias"))
      end

      if state_repo.destroy(state)
        success(state: state)
      else
        failure(base: I18n.t("admin.states.destroy.failed"))
      end
    end
  end
end
