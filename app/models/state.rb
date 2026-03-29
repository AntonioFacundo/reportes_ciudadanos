# frozen_string_literal: true

class State < ApplicationRecord
  has_many :alcaldias, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
end
