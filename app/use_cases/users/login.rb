# frozen_string_literal: true

module Users
  class Login < RageArch::UseCase::Base
    use_case_symbol :users_login
    deps :user_repo

    def call(params = {})
      return failure(name: I18n.t("errors.required")) if params[:name].blank?
      return failure(password: I18n.t("errors.required")) if params[:password].blank?

      user = user_repo.find_by_name(params[:name])
      return failure(name: I18n.t("sessions.create.failure")) if user.nil?
      return failure(name: I18n.t("sessions.create.failure")) unless user.authenticate(params[:password])
      return failure(name: I18n.t("errors.inactive")) unless user.active?

      success(user: user)
    end
  end
end
