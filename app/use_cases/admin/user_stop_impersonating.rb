# frozen_string_literal: true

module Admin
  class UserStopImpersonating < RageArch::UseCase::Base
    use_case_symbol :admin_user_stop_impersonating
    deps :session_repo

    def call(params = {})
      impersonator_session_id = params[:impersonator_session_id]
      return failure(base: I18n.t("admin.users.impersonate.not_impersonating")) unless impersonator_session_id.present?

      impersonator_session = session_repo.find(impersonator_session_id)
      unless impersonator_session
        return failure(
          base: I18n.t("admin.users.impersonate.session_not_found"),
          clear_impersonator_cookie: true
        )
      end

      success(session: impersonator_session)
    end
  end
end
