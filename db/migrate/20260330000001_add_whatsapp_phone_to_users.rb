# frozen_string_literal: true

class AddWhatsappPhoneToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :whatsapp_phone, :string
    add_index :users, :whatsapp_phone, unique: true, where: "whatsapp_phone IS NOT NULL"
  end
end
