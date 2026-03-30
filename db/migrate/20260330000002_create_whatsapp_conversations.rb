# frozen_string_literal: true

class CreateWhatsappConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_conversations do |t|
      t.string :phone_number, null: false
      t.references :user, foreign_key: true
      t.string :state, null: false, default: "idle"
      t.bigint :pending_alcaldia_id
      t.bigint :pending_category_id
      t.text :pending_description
      t.string :pending_photo_media_id
      t.decimal :pending_latitude, precision: 10, scale: 7
      t.decimal :pending_longitude, precision: 10, scale: 7
      t.string :pending_location_description
      t.bigint :last_alcaldia_id
      t.datetime :expires_at
      t.timestamps
    end

    add_index :whatsapp_conversations, :phone_number, unique: true
    add_index :whatsapp_conversations, :state
  end
end
