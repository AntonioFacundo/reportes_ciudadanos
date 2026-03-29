class AddResolvedByToReports < ActiveRecord::Migration[8.1]
  def change
    add_reference :reports, :resolved_by, null: true, foreign_key: { to_table: :users }
  end
end
