# frozen_string_literal: true

module Passwords
  class Reset < RageArch::UseCase::Base
    use_case_symbol :passwords_reset

    def call(params = {})
      user = params[:user]
      return failure(base: I18n.t("errors.not_found")) unless user

      if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
        user.sessions.destroy_all
        success(user: user)
      else
        failure(base: I18n.t("passwords.update.mismatch"))
      end
    end
  end
end
