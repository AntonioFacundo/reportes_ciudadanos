# frozen_string_literal: true

module Whatsapp
  class ConversationRepo
    def find_or_create_by_phone(phone)
      WhatsappConversation.find_or_create_by!(phone_number: phone)
    end

    def update(conversation, attrs)
      conversation.update!(attrs)
      conversation
    end
  end
end
