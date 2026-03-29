# frozen_string_literal: true

class AddBoundaryToAlcaldias < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      ALTER TABLE alcaldias
      ADD COLUMN boundary geometry(Polygon, 4326);
    SQL
    add_index :alcaldias, :boundary, using: :gist
  end

  def down
    remove_index :alcaldias, :boundary
    remove_column :alcaldias, :boundary
  end
end
