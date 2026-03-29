# frozen_string_literal: true

class SnapshotReportsJob < ApplicationJob
  queue_as :default

  def perform(date: Date.current)
    ReportSnapshot.capture!(date: date)
  end
end
