class ApplicationController < ActionController::Base
  include RageArch::Controller
  include Authentication
  include Auditable
  include Pagy::Method
  allow_browser versions: :modern
  stale_when_importmap_changes
  after_action :prevent_user_cache

  private

  def prevent_user_cache
    return unless authenticated?
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def error_messages_from(result)
    errs = result.errors
    return "" unless errs.present?
    h = errs.is_a?(Hash) ? errs : (errs.respond_to?(:to_h) ? errs.to_h : {})
    skip_keys = %i[invalid_report categories _record report assignable]
    messages = h.except(*skip_keys).values
    Array(messages).flatten.reject { |m| m.is_a?(ActiveRecord::Base) || m.is_a?(ApplicationRecord) }.join(", ")
  end
end
