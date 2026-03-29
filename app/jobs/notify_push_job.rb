# frozen_string_literal: true

class NotifyPushJob < ApplicationJob
  queue_as :default

  def perform(user_id, title:, body:, path: "/")
    user = User.find_by(id: user_id)
    return unless user
    return unless Notifications::PushService.vapid_configured?

    Notifications::PushService.send_to_user(user, title: title, body: body, path: path)
  end
end
