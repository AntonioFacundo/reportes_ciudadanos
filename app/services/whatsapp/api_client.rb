# frozen_string_literal: true

module Whatsapp
  class ApiClient
    BASE_URL = "https://graph.facebook.com/v21.0"

    def initialize
      @access_token = Rails.application.credentials.dig(:whatsapp, :access_token)
      @phone_number_id = Rails.application.credentials.dig(:whatsapp, :phone_number_id)
    end

    def send_text(phone, text)
      post_message(phone, { type: "text", text: { body: text } })
    end

    def send_list(phone, body_text, button_text, sections)
      post_message(phone, {
        type: "interactive",
        interactive: {
          type: "list",
          body: { text: body_text },
          action: {
            button: button_text,
            sections: sections
          }
        }
      })
    end

    def download_media(media_id)
      uri = URI("#{BASE_URL}/#{media_id}")
      response = http_get(uri)
      meta = JSON.parse(response.body)

      media_uri = URI(meta["url"])
      media_response = http_get(media_uri)
      {
        binary: media_response.body,
        content_type: media_response["content-type"] || "image/jpeg"
      }
    end

    private

    def post_message(phone, message_data)
      uri = URI("#{BASE_URL}/#{@phone_number_id}/messages")
      body = { messaging_product: "whatsapp", to: phone }.merge(message_data)

      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@access_token}"
      req["Content-Type"] = "application/json"
      req.body = body.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(req)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "[WhatsApp API] Error #{response.code}: #{response.body}"
      end

      response
    end

    def http_get(uri)
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@access_token}"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(req)
    end
  end
end
