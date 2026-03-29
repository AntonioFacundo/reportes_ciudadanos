class AddAlcaldiaToCategories < ActiveRecord::Migration[8.1]
  def up
    add_reference :categories, :alcaldia, null: true, foreign_key: true
    remove_index :categories, :name, if_exists: true

    first_alcaldia = execute("SELECT id FROM alcaldias ORDER BY id LIMIT 1").first
    default_alcaldia_id = first_alcaldia&.fetch("id", nil)

    if default_alcaldia_id
      execute("UPDATE categories SET alcaldia_id = #{default_alcaldia_id} WHERE alcaldia_id IS NULL")

      other_alcaldias = execute("SELECT id FROM alcaldias WHERE id != #{default_alcaldia_id}")
      originals = execute("SELECT name, sla_hours FROM categories WHERE alcaldia_id = #{default_alcaldia_id}")

      other_alcaldias.each do |alc|
        originals.each do |cat|
          sla = cat["sla_hours"] ? cat["sla_hours"].to_i : "NULL"
          name = cat["name"].gsub("'", "''")
          execute("INSERT INTO categories (name, sla_hours, alcaldia_id, created_at, updated_at) VALUES ('#{name}', #{sla}, #{alc['id']}, NOW(), NOW())")
        end
      end
    end

    change_column_null :categories, :alcaldia_id, false
    add_index :categories, %i[alcaldia_id name], unique: true
  end

  def down
    remove_index :categories, %i[alcaldia_id name], if_exists: true

    first_alcaldia = execute("SELECT id FROM alcaldias ORDER BY id LIMIT 1").first
    default_alcaldia_id = first_alcaldia&.fetch("id", nil)

    if default_alcaldia_id
      execute("UPDATE reports SET category_id = (SELECT c2.id FROM categories c2 WHERE c2.name = (SELECT name FROM categories WHERE id = reports.category_id) AND c2.alcaldia_id = #{default_alcaldia_id} LIMIT 1) WHERE category_id NOT IN (SELECT id FROM categories WHERE alcaldia_id = #{default_alcaldia_id})")
      execute("DELETE FROM categories WHERE alcaldia_id != #{default_alcaldia_id}")
      execute("UPDATE categories SET alcaldia_id = NULL")
    end

    change_column_null :categories, :alcaldia_id, true
    remove_reference :categories, :alcaldia
    add_index :categories, :name, unique: true
  end
end
