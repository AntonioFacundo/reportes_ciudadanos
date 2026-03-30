class User < ApplicationRecord
  ROLES = %w[system_admin mayor official citizen].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reports_as_reporter, class_name: "Report", foreign_key: :reporter_id, dependent: :restrict_with_error
  has_many :reports_as_assignee, class_name: "Report", foreign_key: :assignee_id, dependent: :nullify
  has_many :push_subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  belongs_to :manager, class_name: "User", optional: true
  has_many :subordinates, class_name: "User", foreign_key: :manager_id, dependent: :restrict_with_error
  belongs_to :alcaldia, optional: true

  normalizes :email_address, with: ->(e) { e.present? ? e.strip.downcase : nil }
  normalizes :name, with: ->(n) { n.present? ? n.strip : nil }
  normalizes :whatsapp_phone, with: ->(p) { p.present? ? p.strip.gsub(/\D/, "") : nil }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }
  validate :official_must_have_manager
  validate :government_must_have_alcaldia

  scope :active, -> { where(active: true) }

  def system_admin?
    role == "system_admin"
  end

  def mayor?
    role == "mayor"
  end

  def official?
    role == "official"
  end

  def citizen?
    role == "citizen"
  end

  def government?
    system_admin? || mayor? || official?
  end

  def alcaldia_ids_for_admin
    return Alcaldia.pluck(:id) if system_admin?
    return [alcaldia_id].compact if mayor?
    return [manager&.alcaldia_id].compact if official?
    []
  end

  private

  def official_must_have_manager
    return unless official?
    return if manager_id.present?
    errors.add(:manager_id, I18n.t("activerecord.errors.models.user.official_requires_manager"))
  end

  def government_must_have_alcaldia
    return unless mayor? || official?
    return if alcaldia_id.present?
    return if official? && manager&.alcaldia_id.present?
    errors.add(:alcaldia_id, I18n.t("activerecord.errors.models.user.government_requires_alcaldia"))
  end
end
