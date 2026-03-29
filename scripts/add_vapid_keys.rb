#!/usr/bin/env ruby
# Adds VAPID keys to Rails credentials. Run as: EDITOR="ruby scripts/add_vapid_keys.rb" bin/rails credentials:edit

file_path = ARGV.last
exit 1 unless file_path && File.exist?(file_path)

require_relative "../config/environment"
keys = WebPush.generate_key

content = File.read(file_path)
data = content.empty? ? {} : YAML.load(content) || {}
data = data.with_indifferent_access
data["vapid"] = { "public_key" => keys.public_key, "private_key" => keys.private_key }
File.write(file_path, data.to_yaml)
