# frozen_string_literal: true

module Notifications
  class PushService
    def self.send_to_user(user, title:, body:, path: "/")
      return unless vapid_configured?

      user.push_subscriptions.find_each do |subscription|
        send_to_subscription(subscription, title: title, body: body, path: path)
      end
    end

    def self.send_to_subscription(subscription, title:, body:, path: "/")
      return unless vapid_configured?

      payload = {
        title: title,
        body: body,
        data: { path: path }
      }

      WebPush.payload_send(
        message: JSON.generate(payload),
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh_key,
        auth: subscription.auth_key,
        vapid: vapid_options
      )
    rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
      subscription.destroy
    rescue WebPush::ResponseError => e
      subscription.destroy if e.respond_to?(:response) && e.response&.code.to_s.in?(%w[404 410])
    end

    def self.vapid_configured?
      Rails.application.credentials.dig(:vapid, :public_key).present? &&
        Rails.application.credentials.dig(:vapid, :private_key).present?
    end

    def self.vapid_options
      {
        public_key: Rails.application.credentials.dig(:vapid, :public_key),
        private_key: Rails.application.credentials.dig(:vapid, :private_key)
      }
    end
  end
end
