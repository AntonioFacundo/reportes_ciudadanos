class ReportResolutionCycle < ApplicationRecord
  belongs_to :report
  belongs_to :assignee, class_name: "User"
  belongs_to :resolver, class_name: "User", optional: true

  has_many_attached :photos

  default_scope -> { order(resolved_at: :asc) }
end
