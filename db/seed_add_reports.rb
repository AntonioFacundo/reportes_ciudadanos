# frozen_string_literal: true

# Adds more reports to existing data. Run: rails runner db/seed_add_reports.rb
# Fast - only creates reports, uses existing users/categories.

require "securerandom"

puts "=== Agregando reportes ==="

STATE_COORDS = {
  "AGS" => [21.88, -102.29], "BC" => [32.51, -117.04], "BCS" => [24.14, -110.31],
  "CAM" => [19.84, -90.53], "COAH" => [27.29, -103.69], "COL" => [19.24, -103.72],
  "CDMX" => [19.43, -99.13], "CHIS" => [16.75, -93.11], "CHIH" => [28.63, -106.08],
  "DGO" => [24.03, -104.67], "GTO" => [21.02, -101.26], "GRO" => [17.44, -99.55],
  "HGO" => [20.10, -98.73], "JAL" => [20.67, -103.35], "MEX" => [19.36, -99.59],
  "MICH" => [19.71, -101.19], "MOR" => [18.68, -99.10], "NAY" => [21.51, -104.89],
  "NL" => [25.67, -100.31], "OAX" => [17.07, -96.72], "PUE" => [19.04, -98.19],
  "QRO" => [20.59, -100.39], "QROO" => [21.16, -86.83], "SLP" => [22.15, -100.97],
  "SIN" => [25.80, -108.99], "SON" => [29.07, -110.95], "TAB" => [18.00, -92.94],
  "TAM" => [25.87, -97.50], "TLAX" => [19.31, -98.24], "VER" => [19.17, -96.13],
  "YUC" => [20.98, -89.62], "ZAC" => [22.77, -102.58]
}.freeze

DESC = [
  "Bache en la calle principal", "Lámpara fundida", "Basura acumulada",
  "Fuga de drenaje", "Bache peligroso", "Alcantarilla tapada"
].freeze
LOC = ["Calle Principal", "Avenida Central", "Colonia Centro", "Zona centro"].freeze

citizens = User.where(role: "citizen").to_a
if citizens.empty?
  puts "No hay ciudadanos. Ejecuta seed_reports_nacional primero."
  exit 1
end

alcaldias = Alcaldia.includes(:state).joins(:categories).distinct.to_a
if alcaldias.empty?
  puts "No hay alcaldías con categorías."
  exit 1
end

start_date = 6.months.ago
total = 0

alcaldias.sample([alcaldias.size, 400].min).each do |alc|
  cats = Category.where(alcaldia_id: alc.id).to_a
  offs = User.where(role: "official", alcaldia_id: alc.id).to_a
  base = STATE_COORDS[alc.state&.code] || [25.67, -100.31]

  rand(15..45).times do
    created = rand(start_date..Time.current)
    r = Report.new(
      description: DESC.sample,
      category_id: cats.sample.id,
      alcaldia_id: alc.id,
      reporter_id: citizens.sample.id,
      latitude: base[0] + rand(-0.1..0.1),
      longitude: base[1] + rand(-0.1..0.1),
      location_description: LOC.sample,
      status: "pending",
      created_at: created,
      updated_at: created
    )
    r.save!(validate: false)

    rn = rand(100)
    status = rn < 60 ? "resolved" : rn < 80 ? "assigned" : rn < 92 ? "read" : "pending"
    read_at = created + rand(1..48).hours

    if status != "pending"
      r.update_columns(status: "read", read_at: read_at, updated_at: read_at)
    end
    if %w[assigned resolved].include?(status) && offs.any?
      assigned_at = read_at + rand(1..24).hours
      r.update_columns(status: "assigned", assignee_id: offs.sample.id, assigned_at: assigned_at, updated_at: assigned_at)
    end
    if status == "resolved" && offs.any?
      resolved_at = (r.assigned_at || read_at) + rand(2..72).hours
      r.update_columns(status: "resolved", resolved_at: resolved_at, resolution_note: "Atendido.", updated_at: resolved_at)
    elsif status == "resolved" && offs.empty?
      r.update_columns(status: "read", updated_at: read_at)
    end
    total += 1
  end
  print "\r   +#{total} reportes"
end

ReportSnapshot.capture!(date: Date.current)
puts "\n   Total agregados: #{total}"
puts "   Reportes totales: #{Report.count}"
puts "=== Listo ==="
