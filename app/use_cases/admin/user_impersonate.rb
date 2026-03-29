# frozen_string_literal: true

module Admin
  class UserImpersonate < RageArch::UseCase::Base
    use_case_symbol :admin_user_impersonate
    deps :user_repo, :session_repo

    def call(params = {})
      actor = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless actor&.system_admin?

      target = user_repo.find(params[:target_user_id])
      return failure(base: I18n.t("errors.not_found")) unless target

      return failure(base: I18n.t("admin.users.impersonate.cannot_self")) if target.id == actor.id

      current_session_id = params[:current_session_id]
      return failure(base: I18n.t("admin.users.impersonate.no_session")) unless current_session_id.present?

      new_session = session_repo.create_for_user(
        target,
        user_agent: params[:user_agent].to_s,
        ip_address: params[:ip_address].to_s
      )

      success(
        session: new_session,
        impersonator_session_id: current_session_id,
        target_user: target
      )
    end
  end
end
