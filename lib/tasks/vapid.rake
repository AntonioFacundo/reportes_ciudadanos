# frozen_string_literal: true

namespace :vapid do
  desc "Generate VAPID keys for Web Push and show how to add to credentials"
  task generate: :environment do
    keys = WebPush.generate_key
    puts "Add these to your credentials (rails credentials:edit):"
    puts ""
    puts "vapid:"
    puts "  public_key: #{keys.public_key}"
    puts "  private_key: #{keys.private_key}"
    puts ""
    puts "Or run: EDITOR='code --wait' bin/rails credentials:edit"
  end
end
