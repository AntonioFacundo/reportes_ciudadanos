# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

state_default = State.find_or_create_by!(name: "Nuevo León")
alcaldia_default = Alcaldia.find_or_create_by!(name: "Sabinas Hidalgo", state: state_default)

sabinas_boundary = '{"type":"Polygon","coordinates":[[[-100.22,26.56],[-100.22,26.44],[-100.12,26.44],[-100.12,26.56],[-100.22,26.56]]]}'
unless alcaldia_default.has_boundary?
  alcaldia_default.boundary_from_geojson(sabinas_boundary)
end

User.find_or_create_by!(name: "blind rage") do |u|
  u.role = "system_admin"
  u.password = "cuidado1"
  u.password_confirmation = "cuidado1"
end

User.find_or_create_by!(name: "ciudadano prueba") do |u|
  u.role = "citizen"
  u.password = "prueba123"
  u.password_confirmation = "prueba123"
end

mayor = User.find_or_initialize_by(name: "alcalde")
mayor.assign_attributes(role: "mayor", alcaldia_id: alcaldia_default.id, password: "alcalde123", password_confirmation: "alcalde123")
mayor.save!

director = User.find_or_initialize_by(name: "director obras")
director.assign_attributes(role: "official", manager_id: mayor.id, alcaldia_id: alcaldia_default.id, password: "obras123", password_confirmation: "obras123")
director.save!

Report.where(alcaldia_id: nil).update_all(alcaldia_id: alcaldia_default.id) if Report.exists?

Alcaldia.find_each do |alcaldia|
  %w[Baches Alumbrado Limpieza Seguridad Otros].each do |name|
    Category.find_or_create_by!(name: name, alcaldia_id: alcaldia.id) { |c| c.sla_hours = 72 }
  end
end
