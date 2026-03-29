class AddStateToAlcaldias < ActiveRecord::Migration[8.1]
  def up
    add_reference :alcaldias, :state, foreign_key: true

    state = execute("INSERT INTO states (name, code, created_at, updated_at) VALUES ('Nuevo León', 'NL', NOW(), NOW()) RETURNING id").first
    execute("UPDATE alcaldias SET state_id = #{state['id']} WHERE state_id IS NULL")

    change_column_null :alcaldias, :state_id, false
    remove_index :alcaldias, :name, if_exists: true
    add_index :alcaldias, [:name, :state_id], unique: true
  end

  def down
    remove_index :alcaldias, [:name, :state_id], if_exists: true
    remove_reference :alcaldias, :state
    add_index :alcaldias, :name, unique: true
  end
end
