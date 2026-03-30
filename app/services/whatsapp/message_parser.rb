# frozen_string_literal: true

module Whatsapp
  class MessageParser
    ParsedMessage = Data.define(:phone, :name, :type, :text, :media_id, :latitude, :longitude, :list_reply_id)

    def self.parse(payload)
      entry = payload.dig("entry", 0, "changes", 0, "value")
      return nil unless entry

      message = entry.dig("messages", 0)
      return nil unless message

      contact = entry.dig("contacts", 0)
      phone = message["from"]
      name = contact&.dig("profile", "name")
      msg_type = message["type"]

      case msg_type
      when "text"
        new_message(phone:, name:, type: :text, text: message.dig("text", "body"))
      when "image"
        new_message(phone:, name:, type: :image, media_id: message.dig("image", "id"))
      when "location"
        loc = message["location"]
        new_message(phone:, name:, type: :location, latitude: loc["latitude"], longitude: loc["longitude"])
      when "interactive"
        interactive = message["interactive"]
        if interactive["type"] == "list_reply"
          new_message(phone:, name:, type: :list_reply, list_reply_id: interactive.dig("list_reply", "id"))
        else
          new_message(phone:, name:, type: :text, text: interactive.dig("button_reply", "id"))
        end
      else
        new_message(phone:, name:, type: :text, text: "")
      end
    end

    def self.new_message(phone:, name: nil, type:, text: nil, media_id: nil, latitude: nil, longitude: nil, list_reply_id: nil)
      ParsedMessage.new(phone:, name:, type:, text:, media_id:, latitude:, longitude:, list_reply_id:)
    end
  end
end
