# frozen_string_literal: true

module Whatsapp
  class SignatureValidator
    def self.valid?(request_body, signature_header)
      return false if signature_header.blank?

      app_secret = Rails.application.credentials.dig(:whatsapp, :app_secret)
      return false if app_secret.blank?

      expected = "sha256=#{OpenSSL::HMAC.hexdigest("SHA256", app_secret, request_body)}"
      ActiveSupport::SecurityUtils.secure_compare(expected, signature_header)
    end
  end
end
