class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true, where: "email_address IS NOT NULL"
  end
end
