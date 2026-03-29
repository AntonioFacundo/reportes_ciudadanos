class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: I18n.t("sessions.rate_limit") }

  def new
  end

  def create
    run :users_login, params.permit(:name, :password).to_h.symbolize_keys,
        success: ->(result) {
          start_new_session_for result.value[:user]
          redirect_to after_authentication_url
        },
        failure: ->(result) {
          redirect_to new_session_path, alert: error_messages_from(result)
        }
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
