# frozen_string_literal: true

# Development: log when Action Cable broadcasts happen (helps debug events not reaching client)
if Rails.env.development?
  ActiveSupport::Notifications.subscribe("broadcast.action_cable") do |_name, _start, _finish, _id, payload|
    Rails.logger.info "[ActionCable] Broadcast to #{payload[:broadcasting].inspect} (#{payload[:message].to_s.truncate(80)})"
  end
end
