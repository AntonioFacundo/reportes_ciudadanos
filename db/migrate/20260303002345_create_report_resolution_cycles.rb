class CreateReportResolutionCycles < ActiveRecord::Migration[8.1]
  def change
    create_table :report_resolution_cycles do |t|
      t.references :report, null: false, foreign_key: true
      t.datetime :assigned_at
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.text :assignment_note
      t.text :resolution_note
      t.datetime :resolved_at
      t.text :reporter_rejection_note

      t.timestamps
    end
  end
end
