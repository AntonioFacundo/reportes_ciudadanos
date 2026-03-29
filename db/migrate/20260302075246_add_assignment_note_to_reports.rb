class AddAssignmentNoteToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :assignment_note, :text
  end
end
