# frozen_string_literal: true

class WhatsappConversation < ApplicationRecord
  STATES = %w[idle awaiting_location awaiting_category awaiting_description awaiting_photo awaiting_confirm].freeze
  TIMEOUT = 30.minutes

  belongs_to :user, optional: true

  validates :phone_number, presence: true, uniqueness: true
  validates :state, inclusion: { in: STATES }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def reset!
    update!(
      state: "idle",
      pending_alcaldia_id: nil,
      pending_category_id: nil,
      pending_description: nil,
      pending_photo_media_id: nil,
      pending_latitude: nil,
      pending_longitude: nil,
      pending_location_description: nil,
      expires_at: nil
    )
  end

  def touch_expiry!
    update_column(:expires_at, TIMEOUT.from_now)
  end
end
