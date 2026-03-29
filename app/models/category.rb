class Category < ApplicationRecord
  belongs_to :alcaldia
  has_many :reports, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :alcaldia_id }
  validates :sla_hours, numericality: { greater_than: 0 }, allow_nil: true

  scope :for_alcaldia, ->(alcaldia_id) { where(alcaldia_id: alcaldia_id) }
end
