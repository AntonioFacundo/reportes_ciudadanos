# frozen_string_literal: true

class CreateReportSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :report_snapshots do |t|
      t.references :alcaldia, null: false, foreign_key: true
      t.date :snapshot_date, null: false
      t.integer :total_reports, default: 0, null: false
      t.integer :pending_count, default: 0, null: false
      t.integer :read_count, default: 0, null: false
      t.integer :assigned_count, default: 0, null: false
      t.integer :resolved_count, default: 0, null: false
      t.integer :overdue_count, default: 0, null: false
      t.integer :reopened_count, default: 0, null: false
      t.float :avg_resolution_hours
      t.float :avg_response_hours
      t.jsonb :by_category, default: {}, null: false
      t.timestamps
    end

    add_index :report_snapshots, [:alcaldia_id, :snapshot_date], unique: true
    add_index :report_snapshots, :snapshot_date
  end
end
