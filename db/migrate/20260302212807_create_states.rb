class CreateStates < ActiveRecord::Migration[8.1]
  def change
    create_table :states do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :states, :code, unique: true
    add_index :states, :name, unique: true
  end
end
