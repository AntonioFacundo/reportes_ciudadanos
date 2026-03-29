# frozen_string_literal: true

class ReportSnapshot < ApplicationRecord
  belongs_to :alcaldia

  validates :snapshot_date, presence: true
  validates :alcaldia_id, uniqueness: { scope: :snapshot_date }

  scope :for_alcaldia, ->(alcaldia_id) { where(alcaldia_id: alcaldia_id) }
  scope :chronological, -> { order(snapshot_date: :asc) }
  scope :recent_first, -> { order(snapshot_date: :desc) }

  def self.capture!(date: Date.current)
    Alcaldia.find_each do |alcaldia|
      reports = Report.where(alcaldia_id: alcaldia.id)

      resolved = reports.where(status: "resolved").where.not(resolved_at: nil)
      avg_resolution = resolved
        .average("EXTRACT(EPOCH FROM (resolved_at - created_at)) / 3600")
        &.to_f

      read_reports = reports.where.not(read_at: nil)
      avg_response = read_reports
        .average("EXTRACT(EPOCH FROM (read_at - created_at)) / 3600")
        &.to_f

      overdue = reports
        .joins(:category)
        .where.not(status: "resolved")
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at < NOW() - (categories.sla_hours || ' hours')::interval")
        .count

      by_category = reports
        .joins(:category)
        .group("categories.name")
        .count
        .transform_values(&:to_i)

      upsert(
        {
          alcaldia_id: alcaldia.id,
          snapshot_date: date,
          total_reports: reports.count,
          pending_count: reports.where(status: "pending").count,
          read_count: reports.where(status: "read").count,
          assigned_count: reports.where(status: "assigned").count,
          resolved_count: reports.where(status: "resolved").count,
          overdue_count: overdue,
          reopened_count: reports.where(reopened: true).count,
          avg_resolution_hours: avg_resolution,
          avg_response_hours: avg_response,
          by_category: by_category
        },
        unique_by: [:alcaldia_id, :snapshot_date]
      )
    end
  end
end
