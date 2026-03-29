class AddReporterRejectionNoteToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :reporter_rejection_note, :text
  end
end
