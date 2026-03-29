class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: I18n.t("passwords.rate_limit") }

  def new
  end

  def create
    run :passwords_request_reset, { email_address: params[:email_address] },
        success: ->(_) { redirect_to new_session_path, notice: I18n.t("passwords.create.success") },
        failure: ->(_) { redirect_to new_session_path, notice: I18n.t("passwords.create.success") }
  end

  def edit
  end

  def update
    run :passwords_reset, { user: @user, password: params[:password], password_confirmation: params[:password_confirmation] },
        success: ->(_) { redirect_to new_session_path, notice: I18n.t("passwords.update.success") },
        failure: ->(_) { redirect_to edit_password_path(params[:token]), alert: I18n.t("passwords.update.mismatch") }
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: I18n.t("passwords.token_invalid")
  end
end
