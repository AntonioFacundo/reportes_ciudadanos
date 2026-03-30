# frozen_string_literal: true

module Api
  class WhatsappController < ActionController::API
    before_action :verify_signature, only: :receive

    # GET /api/whatsapp/verify — Meta webhook verification
    def verify
      mode = params["hub.mode"]
      token = params["hub.verify_token"]
      challenge = params["hub.challenge"]

      verify_token = Rails.application.credentials.dig(:whatsapp, :verify_token)

      if mode == "subscribe" && token == verify_token
        render plain: challenge, status: :ok
      else
        head :forbidden
      end
    end

    # POST /api/whatsapp/receive — incoming messages
    def receive
      payload = JSON.parse(request.body.read)

      # Enqueue processing asynchronously (Meta requires fast 200 response)
      WhatsappIncomingJob.perform_later(payload)

      head :ok
    end

    private

    def verify_signature
      request.body.rewind
      body = request.body.read
      request.body.rewind

      signature = request.headers["X-Hub-Signature-256"]
      unless Whatsapp::SignatureValidator.valid?(body, signature)
        head :unauthorized
      end
    end
  end
end
