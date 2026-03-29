# frozen_string_literal: true

class SystemAuditLog < ApplicationRecord
  ACTIONS = %w[
    force_state_transition
    impersonate_user
    update_boundary
    deactivate_user
    create_user
    update_user
    create_alcaldia
    update_alcaldia
    destroy_alcaldia
  ].freeze

  belongs_to :actor, class_name: "User"

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc) }

  def self.record!(actor:, action:, target: nil, metadata: {}, ip_address: nil)
    create!(
      actor: actor,
      action: action,
      target_type: target&.class&.name,
      target_id: target&.id,
      metadata: metadata,
      ip_address: ip_address
    )
  end
end
