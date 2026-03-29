# frozen_string_literal: true

# Ensure URL helpers have a host when called from jobs, services, or mailers
# (outside request context). Fixes "Missing host to link to" errors.
Rails.application.config.after_initialize do
  opts = Rails.application.config.action_controller.default_url_options
  opts ||= Rails.application.config.action_mailer.default_url_options
  opts ||= { host: "localhost", port: 3000 }
  Rails.application.routes.default_url_options = opts
end
