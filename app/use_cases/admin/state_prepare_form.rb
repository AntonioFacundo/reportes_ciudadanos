# frozen_string_literal: true

module Admin
  class StatePrepareForm < RageArch::UseCase::Base
    use_case_symbol :admin_state_prepare_form
    deps :state_repo

    def call(params = {})
      state = if params[:id].present?
        state_repo.find(params[:id])
      else
        state_repo.build
      end

      return failure(base: I18n.t("errors.not_found")) if params[:id].present? && state.nil?

      success(state: state)
    end
  end
end
