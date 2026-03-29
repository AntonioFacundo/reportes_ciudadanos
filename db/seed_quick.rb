# frozen_string_literal: true

# Quick seed: creates reports using existing users/categories
# Run: rails runner db/seed_quick.rb

puts "=== Quick seed ==="

citizens = User.where(role: "citizen").pluck(:id)
if citizens.empty?
  puts "No citizens found, creating 50..."
  50.times do |i|
    citizens << User.create!(
      name: "Ciudadano #{SecureRandom.hex(4)}",
      role: "citizen",
      password: "password123",
      password_confirmation: "password123"
    ).id
  end
end

descs = [
  "Bache grande en la calle principal",
  "Lámpara fundida, muy oscuro por las noches",
  "Acumulación de basura en terreno baldío",
  "Necesitamos más patrullaje en la zona",
  "Fuga de aguas negras",
  "Hoyo profundo en el pavimento",
  "Poste de luz caído",
  "Alcantarilla tapada, se inunda cuando llueve",
  "Juegos infantiles rotos en el parque",
  "Cable de electricidad colgando"
]

locs = [
  "Calle Principal esquina con Juárez",
  "Avenida Central #100",
  "Colonia Centro",
  "Calle Hidalgo",
  "Avenida Constitución",
  "Boulevard principal",
  "Frente al parque municipal",
  "Plaza principal",
  "Cerca de la escuela primaria",
  "Mercado municipal"
]

notes = [
  "Se atendió el reporte. Trabajo completado.",
  "Reparación realizada satisfactoriamente.",
  "Problema solucionado por el equipo de trabajo."
]

# Pick 100 random alcaldias that have categories
alc_ids = Category.distinct.pluck(:alcaldia_id).sample(100)
total = 0

alc_ids.each do |alc_id|
  cats = Category.where(alcaldia_id: alc_id).pluck(:id)
  officials = User.where(role: "official", alcaldia_id: alc_id).pluck(:id)

  30.times do
    created = rand(12.months.ago..Time.current)
    status = %w[pending read assigned resolved].sample

    r = Report.new(
      description: descs.sample,
      category_id: cats.sample,
      alcaldia_id: alc_id,
      reporter_id: citizens.sample,
      latitude: 19.4 + rand(-5.0..5.0),
      longitude: -99.1 + rand(-5.0..5.0),
      location_description: locs.sample,
      status: "pending",
      created_at: created,
      updated_at: created
    )
    r.save!(validate: false)

    if %w[read assigned resolved].include?(status)
      r.update_columns(status: "read", read_at: created + rand(1..48).hours)
    end

    if %w[assigned resolved].include?(status) && officials.any?
      r.update_columns(status: "assigned", assignee_id: officials.sample, assigned_at: (r.read_at || created) + rand(1..72).hours)
    end

    if status == "resolved"
      resolved_at = (r.assigned_at || r.read_at || created) + rand(2..168).hours
      resolved_at = [resolved_at, Time.current].min
      r.update_columns(status: "resolved", resolved_at: resolved_at, resolution_note: notes.sample)
    end

    total += 1
  end
end

puts "#{total} reportes creados"
puts "Total en BD: #{Report.count}"
puts "=== Done ==="
