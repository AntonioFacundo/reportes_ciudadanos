# frozen_string_literal: true

# Seeds fake reports across Mexico to simulate nationwide activity.
# Run: rails runner db/seed_reports_nacional.rb
#
# Prerequisites: seed_states.rb, seed_municipios.rb, db:seed (base data)

require "securerandom"

puts "=== Simulación de reportes a nivel nacional (México) ==="
puts "Inicio: #{Time.current}"

FIRST_NAMES = %w[Carlos María José Ana Luis Laura Pedro Rosa Juan Elena Miguel Carmen
  Fernando Patricia Ricardo Sofía Alejandro Gabriela Jorge Claudia Roberto Lucía
  Daniel Verónica Arturo Mónica Raúl Teresa Héctor Adriana Sergio Leticia
  Francisco Margarita Eduardo Silvia Óscar Beatriz Javier Norma
  Víctor Paola Alberto Irene Armando Lorena Germán Alicia].freeze

LAST_NAMES = %w[García Hernández López Martínez González Rodríguez Pérez Sánchez Ramírez
  Torres Flores Rivera Gómez Díaz Cruz Morales Reyes Gutiérrez Ortiz Ruiz
  Mendoza Aguilar Medina Castillo Vargas Rojas Jiménez Chávez Delgado Salazar
  Castro Romero Herrera Luna Jiménez Soto Sandoval Guzmán Núñez].freeze

CATEGORY_NAMES = %w[Baches Alumbrado Limpieza Seguridad Drenaje Parques Transporte Otros].freeze

# Population weight by state code (more = more reports per alcaldía)
STATE_WEIGHT = {
  "CDMX" => 4, "JAL" => 3, "MEX" => 3, "VER" => 2, "PUE" => 2,
  "GTO" => 2, "NL" => 2, "CHIH" => 2, "TAM" => 2, "QROO" => 2,
  "BC" => 2, "SON" => 2, "SIN" => 2, "COAH" => 2, "YUC" => 2,
  "QRO" => 1.5, "HGO" => 1.5, "MOR" => 1.5, "SLP" => 1.5,
  "MICH" => 1.5, "OAX" => 1.5, "TAB" => 1.5, "BCS" => 1.5,
  "AGS" => 1, "COL" => 1, "CHIS" => 1, "DGO" => 1, "GRO" => 1,
  "NAY" => 1, "CAM" => 1, "TLAX" => 1, "ZAC" => 1
}.freeze

DESCRIPTIONS = [
  "Bache grande en la calle principal, peligroso para vehículos",
  "Lámpara fundida, muy oscuro por las noches",
  "Acumulación de basura en el terreno baldío",
  "Robos frecuentes en la colonia, necesitamos más patrullaje",
  "Fuga de aguas negras en la calle",
  "Problema general que requiere atención municipal",
  "Hoyo profundo en el pavimento que daña llantas",
  "Poste de luz caído, riesgo para peatones",
  "Contenedor de basura desbordado desde hace días",
  "Punto de venta de drogas en la esquina",
  "Alcantarilla tapada, se inunda cuando llueve",
  "Juegos infantiles rotos en el parque",
  "Parada de camión sin techo ni protección",
  "Cable de electricidad colgando peligrosamente",
  "Bache en la esquina que se llena de agua",
  "Luminaria parpadeante, genera molestia",
  "No han pasado a recoger la basura en varios días",
  "Vandalismo constante en el parque",
  "Olor insoportable por drenaje roto",
  "Árboles que necesitan poda urgente",
  "Camiones no respetan horarios ni rutas",
  "Terreno baldío usado como basurero",
  "Toda la cuadra sin alumbrado",
  "Escombros abandonados en la banqueta",
  "Autos a exceso de velocidad en zona escolar",
  "Registro de drenaje sin tapa",
  "Bancas del parque destruidas",
  "Falta señalización de parada",
  "Perros callejeros agresivos",
  "Aguas negras saliendo por la coladera"
].freeze

LOCATIONS = [
  "Calle Principal esquina con Juárez", "Avenida Central #100",
  "Colonia Centro", "Zona centro", "Calle Hidalgo",
  "Calle Juárez esquina con Morelos", "Avenida Constitución",
  "Boulevard Díaz Ordaz", "Calle Zaragoza frente al mercado",
  "Avenida Universidad", "Calle Madero y Guerrero",
  "Fraccionamiento Las Palmas", "Colonia Industrial",
  "Calle Reforma", "Boulevard principal", "Avenida Lincoln",
  "Calle Matamoros esquina Bravo", "Colonia Moderna",
  "Avenida Ruiz Cortines", "Calle Pino Suárez",
  "Colonia Del Valle", "Avenida Lázaro Cárdenas",
  "Frente al parque municipal", "Plaza principal",
  "Cerca de la escuela primaria", "Mercado municipal",
  "Cruce de avenidas principales", "Entrada a la colonia"
].freeze

RESOLUTION_NOTES = [
  "Se atendió el reporte. Trabajo completado.",
  "Reparación realizada satisfactoriamente.",
  "Se coordinó con el área responsable para la solución.",
  "Problema solucionado por el equipo de trabajo.",
  "Atendido. Gracias por su reporte."
].freeze

REJECTION_NOTES = [
  "No se resolvió correctamente, el problema persiste.",
  "La reparación fue superficial, volvió a fallar.",
  "No estoy conforme, el problema sigue igual."
].freeze

def gen_name(used)
  50.times do
    n = "#{FIRST_NAMES.sample} #{LAST_NAMES.sample}"
    return n unless used.include?(n.downcase)
  end
  "#{FIRST_NAMES.sample} #{LAST_NAMES.sample} #{SecureRandom.hex(2)}"
end

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

# 1. Ensure categories for all alcaldias
puts "\n📋 Verificando categorías..."
added = 0
Alcaldia.find_each do |alc|
  CATEGORY_NAMES.each do |name|
    unless Category.exists?(name: name, alcaldia_id: alc.id)
      Category.create!(name: name, alcaldia_id: alc.id, sla_hours: [48, 72, 96].sample)
      added += 1
    end
  end
end
puts "   +#{added} categorías creadas"

# 2. Select MORE alcaldias (10 per state = ~320, nationwide coverage)
puts "\n🏛️ Seleccionando alcaldías para reportes..."
alcaldias_for_reports = []
State.ordered.find_each do |state|
  alc_list = Alcaldia.where(state_id: state.id).order("RANDOM()").limit(10)
  alcaldias_for_reports.concat(alc_list.to_a)
end
puts "   #{alcaldias_for_reports.size} alcaldías seleccionadas"

# 3. Create mayor + officials for each alcaldia
puts "\n👥 Creando alcaldes y funcionarios..."
used_names = Set.new(User.pluck(:name).map(&:downcase))
mayors = {}
officials_hash = {}
created_gov = 0

alcaldias_for_reports.each do |alc|
  next if User.exists?(role: "mayor", alcaldia_id: alc.id)

  name = gen_name(used_names)
  used_names.add(name.downcase)
  mayor = User.create!(
    name: name, role: "mayor", alcaldia_id: alc.id,
    password: "password123", password_confirmation: "password123"
  )
  mayors[alc.id] = mayor
  officials_hash[alc.id] = []

  official_count = STATE_WEIGHT[alc.state&.code].to_i >= 2 ? rand(4..6) : rand(2..4)
  official_count.times do
    name = gen_name(used_names)
    used_names.add(name.downcase)
    officials_hash[alc.id] << User.create!(
      name: name, role: "official", manager_id: mayor.id, alcaldia_id: alc.id,
      password: "password123", password_confirmation: "password123"
    )
  end
  created_gov += (1 + official_count)
end
puts "   +#{created_gov} usuarios gobierno creados"

# 4. Ensure enough citizens (3500 for nationwide feel)
puts "\n🧑 Creando ciudadanos..."
existing_citizens = User.where(role: "citizen").to_a
target = 3500
to_create = (target - existing_citizens.size).clamp(0, 3200)
to_create.times do
  name = gen_name(used_names)
  used_names.add(name.downcase)
  existing_citizens << User.create!(
    name: name, role: "citizen",
    password: "password123", password_confirmation: "password123"
  )
  print "\r   #{existing_citizens.size}/#{target} ciudadanos" if (existing_citizens.size % 200).zero?
end
puts "\n   #{existing_citizens.size} ciudadanos disponibles"

# 5. Generate reports (12 months, population-weighted)
puts "\n📝 Generando reportes..."
start_date = 12.months.ago.beginning_of_day
end_date = Time.current
total_created = 0

alcaldias_for_reports.each do |alc|
  state = alc.state
  weight = (STATE_WEIGHT[state&.code] || 1).to_f
  base = STATE_COORDS[state&.code] || [25.67, -100.31]
  lat = base[0] + rand(-0.5..0.5)
  lng = base[1] + rand(-0.5..0.5)

  categories = Category.where(alcaldia_id: alc.id).to_a
  alc_officials = (officials_hash[alc.id] || User.where(role: "official", alcaldia_id: alc.id)).to_a

  # More reports for populous states (scaled for reasonable runtime ~3-5 min)
  min_reports = (18 * weight).to_i.clamp(18, 50)
  max_reports = (45 * weight).to_i.clamp(45, 100)
  reports_count = rand(min_reports..max_reports)

  reports_count.times do
    cat = categories.sample
    created = rand(start_date..end_date)
    reporter = existing_citizens.sample

    age_hours = (Time.current - created) / 3600.0
    r = rand(100)
    status = age_hours < 4 ? "pending" : r < 6 ? "pending" : r < 14 ? "read" : r < 32 ? "assigned" : "resolved"

    report = Report.new(
      description: DESCRIPTIONS.sample,
      category_id: cat.id,
      alcaldia_id: alc.id,
      reporter_id: reporter.id,
      latitude: lat + rand(-0.02..0.02),
      longitude: lng + rand(-0.02..0.02),
      location_description: LOCATIONS.sample,
      status: "pending",
      created_at: created,
      updated_at: created
    )
    report.save!(validate: false)

    if %w[read assigned resolved].include?(status)
      read_at = created + rand(0.5..48).hours
      report.update_columns(status: "read", read_at: read_at, updated_at: read_at)
    end

    if %w[assigned resolved].include?(status) && alc_officials.any?
      assignee = alc_officials.sample
      assigned_at = (report.read_at || created) + rand(1..72).hours
      report.update_columns(status: "assigned", assignee_id: assignee.id, assigned_at: assigned_at, updated_at: assigned_at)
    end

    if status == "resolved"
      resolved_at = (report.assigned_at || created) + rand(2..168).hours
      resolved_at = [resolved_at, Time.current].min
      report.update_columns(
        status: "resolved",
        resolved_at: resolved_at,
        resolution_note: RESOLUTION_NOTES.sample,
        updated_at: resolved_at
      )
      report.update_columns(reporter_accepted_at: resolved_at + rand(1..24).hours) if rand(100) < 35

      # 8% chance of reopen
      if rand(100) < 8
        report.update_columns(
          reopened: true,
          status: "assigned",
          reporter_rejection_note: REJECTION_NOTES.sample
        )
      end
    end

    total_created += 1
  end
  print "\r   #{alc.name.ljust(30)} #{reports_count} reportes"
end

puts "\n   Total: #{total_created} reportes creados"

# 6. Historical snapshots (last 90 days, weekly)
puts "\n📊 Generando snapshots históricos..."
snapshot_date = 90.days.ago.to_date
snap_count = 0

while snapshot_date <= Date.current
  next snapshot_date += 1.day unless snapshot_date.sunday? || snapshot_date == Date.current

  alcaldias_for_reports.each do |alc|
    reports = Report.where(alcaldia_id: alc.id).where("reports.created_at <= ?", snapshot_date.end_of_day)

    resolved = reports.where(status: "resolved").where.not(resolved_at: nil)
    avg_resolution = resolved
      .where("reports.resolved_at <= ?", snapshot_date.end_of_day)
      .average("EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at)) / 3600")
      &.to_f

    read_reports = reports.where.not(read_at: nil).where("reports.read_at <= ?", snapshot_date.end_of_day)
    avg_response = read_reports.average("EXTRACT(EPOCH FROM (reports.read_at - reports.created_at)) / 3600")&.to_f

    overdue = reports
      .joins(:category)
      .where.not(status: "resolved")
      .where("categories.sla_hours IS NOT NULL")
      .where("reports.created_at + (categories.sla_hours * INTERVAL '1 hour') < ?", snapshot_date.end_of_day)
      .count

    by_cat = reports.joins(:category).group("categories.name").count

    ReportSnapshot.upsert(
      {
        alcaldia_id: alc.id,
        snapshot_date: snapshot_date,
        total_reports: reports.count,
        pending_count: reports.where(status: "pending").count,
        read_count: reports.where(status: "read").count,
        assigned_count: reports.where(status: "assigned").count,
        resolved_count: reports.where(status: "resolved").count,
        overdue_count: overdue,
        reopened_count: reports.where(reopened: true).count,
        avg_resolution_hours: avg_resolution,
        avg_response_hours: avg_response,
        by_category: by_cat,
        created_at: snapshot_date.to_time,
        updated_at: snapshot_date.to_time
      },
      unique_by: [:alcaldia_id, :snapshot_date]
    )
    snap_count += 1
  end
  snapshot_date += 1.day
end

puts "   #{snap_count} snapshots creados"

# 7. Final snapshot for today
ReportSnapshot.capture!(date: Date.current)
puts "   Snapshot actual capturado"

puts "\n=== Resumen ==="
puts "Alcaldías:     #{Alcaldia.count}"
puts "Con reportes:  #{alcaldias_for_reports.size}"
puts "Estados:       #{State.count}"
puts "Categorías:    #{Category.count}"
puts "Usuarios:      #{User.count}"
puts "  Gobierno:    #{User.where(role: %w[mayor official]).count}"
puts "  Ciudadanos:  #{User.where(role: 'citizen').count}"
puts "Reportes:      #{Report.count}"
puts "  Pendientes:  #{Report.where(status: 'pending').count}"
puts "  Leídos:      #{Report.where(status: 'read').count}"
puts "  Asignados:   #{Report.where(status: 'assigned').count}"
puts "  Resueltos:   #{Report.where(status: 'resolved').count}"
puts "  Reabiertos:  #{Report.where(reopened: true).count}"
puts "Snapshots:     #{ReportSnapshot.count}"
puts "\nFin: #{Time.current}"
