# frozen_string_literal: true

module Push
  class SubscriptionRepo
    def find_or_build(user, endpoint:, p256dh:, auth:)
      user.push_subscriptions.find_or_initialize_by(endpoint: endpoint).tap do |s|
        s.p256dh_key = p256dh
        s.auth_key = auth
      end
    end

    def find_by_endpoint(user, endpoint)
      user.push_subscriptions.find_by(endpoint: endpoint)
    end

    def save(record)
      record.save
    end

    def destroy(record)
      record&.destroy
    end
  end
end
