class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.references :assignee, null: true, foreign_key: { to_table: :users }
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.text :location_description
      t.text :description, null: false
      t.text :resolution_note
      t.boolean :reopened, default: false, null: false
      t.datetime :read_at
      t.datetime :assigned_at
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :reports, :status
    add_index :reports, %i[reporter_id status]
    add_index :reports, %i[assignee_id status]
  end
end
