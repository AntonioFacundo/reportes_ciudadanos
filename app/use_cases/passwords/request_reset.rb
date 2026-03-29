# frozen_string_literal: true

module Passwords
  class RequestReset < RageArch::UseCase::Base
    use_case_symbol :passwords_request_reset

    def call(params = {})
      if (user = User.find_by(email_address: params[:email_address]))
        PasswordsMailer.reset(user).deliver_later
      end
      success(sent: true)
    end
  end
end
