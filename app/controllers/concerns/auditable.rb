# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  private

  def audit!(action, target = nil, **extra_metadata)
    return unless Current.user&.system_admin?

    SystemAuditLog.record!(
      actor: Current.user,
      action: action.to_s,
      target: target,
      metadata: extra_metadata,
      ip_address: request.remote_ip
    )
  end
end
