class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :reports, %i[alcaldia_id status], name: "idx_reports_alcaldia_status"
    add_index :reports, [:created_at], name: "idx_reports_created_at"
    add_index :reports, %i[status resolved_at], name: "idx_reports_status_resolved_at"
    add_index :users, %i[role active], name: "idx_users_role_active"
  end
end
