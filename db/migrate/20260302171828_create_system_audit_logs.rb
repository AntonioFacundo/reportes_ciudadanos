# frozen_string_literal: true

class CreateSystemAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :system_audit_logs do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :target_type
      t.bigint :target_id
      t.jsonb :metadata, default: {}
      t.string :ip_address
      t.timestamps
    end

    add_index :system_audit_logs, [:target_type, :target_id]
    add_index :system_audit_logs, :action
    add_index :system_audit_logs, :created_at
  end
end
