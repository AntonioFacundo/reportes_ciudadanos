class AddRoleAndNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :active, :boolean, null: false, default: true
    add_column :users, :role, :string, null: false, default: "citizen"
    add_reference :users, :manager, null: true, foreign_key: { to_table: :users }
    add_index :users, :name, unique: true
  end
end
