# frozen_string_literal: true

module Notifications
  class NotificationRepo
    def list_for_user(user, page:, per_page: 20)
      all = user.notifications.recent.offset((page - 1) * per_page).limit(per_page + 1).to_a
      has_more = all.size > per_page
      { notifications: all.first(per_page), has_more: has_more }
    end

    def unread_count(user)
      user.notifications.unread.count
    end

    def find_for_user(user, id)
      user.notifications.find(id)
    end

    def mark_read!(notification)
      notification.mark_as_read!
    end
  end
end
