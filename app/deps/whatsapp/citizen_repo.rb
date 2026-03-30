# frozen_string_literal: true

module Whatsapp
  class CitizenRepo
    def find_or_create_by_phone(phone, name: nil)
      user = User.find_by(whatsapp_phone: phone)
      return user if user

      display_name = name.presence || "WhatsApp #{phone[-4..]}"
      # Ensure unique name
      base_name = display_name
      counter = 0
      while User.exists?(name: display_name)
        counter += 1
        display_name = "#{base_name} #{counter}"
      end

      pwd = SecureRandom.hex(16)
      User.create!(
        name: display_name,
        whatsapp_phone: phone,
        role: "citizen",
        password: pwd,
        password_confirmation: pwd
      )
    end
  end
end
