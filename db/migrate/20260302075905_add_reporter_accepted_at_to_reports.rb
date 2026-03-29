class AddReporterAcceptedAtToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :reporter_accepted_at, :datetime
  end
end
