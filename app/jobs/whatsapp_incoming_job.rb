# frozen_string_literal: true

class WhatsappIncomingJob < ApplicationJob
  queue_as :default

  def perform(payload)
    message = Whatsapp::MessageParser.parse(payload)
    return unless message

    use_case = Whatsapp::ProcessMessage.new
    use_case.call(message: message)
  end
end
