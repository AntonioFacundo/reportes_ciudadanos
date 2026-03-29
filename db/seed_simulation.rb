# frozen_string_literal: true

# Run with: bin/rails runner db/seed_simulation.rb
# Simulates 1 year of operation across all 51 municipalities of Nuevo León.

require "securerandom"

puts "=== Simulación de 1 año de Reportes Ciudadanos ==="
puts "Inicio: #{Time.current}"

# ─── 1. Municipios de Nuevo León ─────────────────────────────
MUNICIPIOS = [
  "Abasolo", "Agualeguas", "Los Aldamas", "Allende", "Anáhuac",
  "Apodaca", "Aramberri", "Bustamante", "Cadereyta Jiménez", "El Carmen",
  "Cerralvo", "Ciénega de Flores", "China", "Doctor Arroyo", "Doctor Coss",
  "Doctor González", "Galeana", "García", "San Pedro Garza García",
  "General Bravo", "General Escobedo", "General Terán", "General Treviño",
  "General Zaragoza", "General Zuazua", "Guadalupe", "Los Herreras",
  "Higueras", "Hualahuises", "Iturbide", "Juárez", "Lampazos de Naranjo",
  "Linares", "Marín", "Melchor Ocampo", "Mier y Noriega", "Mina",
  "Montemorelos", "Monterrey", "Parás", "Pesquería", "Los Ramones",
  "Rayones", "Sabinas Hidalgo", "Salinas Victoria", "San Nicolás de los Garza",
  "Hidalgo", "Santa Catarina", "Santiago", "Vallecillo", "Villaldama"
].freeze

# Approximate center coordinates per municipality for realistic heatmap data
COORDS = {
  "Monterrey" => [25.6866, -100.3161], "Guadalupe" => [25.6773, -100.2567],
  "San Nicolás de los Garza" => [25.7441, -100.2889], "Apodaca" => [25.7817, -100.1883],
  "Santa Catarina" => [25.6732, -100.4580], "General Escobedo" => [25.7978, -100.3371],
  "Juárez" => [25.6472, -100.0953], "García" => [25.8117, -100.5920],
  "San Pedro Garza García" => [25.6600, -100.4029], "Cadereyta Jiménez" => [25.5933, -99.9833],
  "Santiago" => [25.4236, -100.1542], "Allende" => [25.2833, -100.0167],
  "Montemorelos" => [25.1875, -99.8267], "Linares" => [24.8597, -99.5672],
  "Sabinas Hidalgo" => [26.5083, -100.1833], "Salinas Victoria" => [25.9667, -100.3000],
  "Ciénega de Flores" => [25.9500, -100.1667], "General Zuazua" => [25.9333, -100.1000],
  "Pesquería" => [25.7833, -100.0500], "El Carmen" => [25.7167, -100.0500],
  "Marín" => [25.8833, -100.0333], "Doctor González" => [25.8667, -99.9333],
  "Hidalgo" => [25.9833, -99.8667], "Abasolo" => [25.9500, -100.4167],
  "Bustamante" => [26.5333, -100.5167], "Villaldama" => [26.5000, -100.4167],
  "Lampazos de Naranjo" => [27.0333, -100.5167], "Anáhuac" => [27.2333, -100.1333],
  "General Terán" => [25.2667, -99.6833], "China" => [25.7000, -99.2333],
  "General Bravo" => [25.8000, -99.1667], "Los Herreras" => [25.9167, -99.4167],
  "Cerralvo" => [26.0833, -99.6167], "Agualeguas" => [26.3167, -99.5500],
  "Los Aldamas" => [26.0667, -99.3000], "Doctor Coss" => [25.9500, -99.1667],
  "General Treviño" => [26.2333, -99.3833], "Los Ramones" => [25.7000, -99.6333],
  "Higueras" => [25.9500, -100.0167], "Mina" => [26.0000, -100.5833],
  "Galeana" => [24.8333, -100.0667], "Doctor Arroyo" => [23.6833, -100.1833],
  "Aramberri" => [24.1000, -99.8167], "General Zaragoza" => [23.9833, -99.7667],
  "Iturbide" => [24.7333, -99.9000], "Rayones" => [25.0167, -100.0833],
  "Hualahuises" => [24.8833, -99.6667], "Mier y Noriega" => [23.5833, -100.0833],
  "Melchor Ocampo" => [26.7667, -99.8333], "Parás" => [26.6167, -99.7667],
  "Vallecillo" => [26.6667, -100.2667]
}.freeze

# Population weight for report volume (metro = more reports)
WEIGHT = Hash.new(1).merge(
  "Monterrey" => 30, "Guadalupe" => 18, "San Nicolás de los Garza" => 12,
  "Apodaca" => 15, "Santa Catarina" => 10, "General Escobedo" => 12,
  "Juárez" => 12, "García" => 10, "San Pedro Garza García" => 5,
  "Cadereyta Jiménez" => 4, "Pesquería" => 4, "Ciénega de Flores" => 3,
  "General Zuazua" => 3, "Salinas Victoria" => 3, "El Carmen" => 3,
  "Santiago" => 2, "Linares" => 3, "Montemorelos" => 2, "Sabinas Hidalgo" => 2,
  "Allende" => 2
).freeze

CATEGORIES_DATA = {
  "Baches" => 48, "Alumbrado" => 72, "Limpieza" => 96,
  "Seguridad" => 24, "Drenaje" => 72, "Parques y jardines" => 120,
  "Transporte público" => 48, "Ruido" => 96, "Basura" => 48,
  "Agua potable" => 24, "Señalización vial" => 72, "Otros" => 120
}.freeze

FIRST_NAMES = %w[Carlos María José Ana Luis Laura Pedro Rosa Juan Elena Miguel Carmen
  Fernando Patricia Ricardo Sofía Alejandro Gabriela Jorge Claudia Roberto Lucía
  Daniel Verónica Arturo Mónica Raúl Teresa Héctor Adriana Sergio Leticia
  Francisco Margarita Eduardo Silvia Óscar Beatriz Javier Norma].freeze

LAST_NAMES = %w[García Hernández López Martínez González Rodríguez Pérez Sánchez Ramírez
  Torres Flores Rivera Gómez Díaz Cruz Morales Reyes Gutiérrez Ortiz Ruiz
  Mendoza Aguilar Medina Castillo Vargas Rojas Jiménez Chávez Delgado Salazar].freeze

DESCRIPTIONS = {
  "Baches" => [
    "Bache grande en la calle principal, peligroso para vehículos",
    "Hoyo en el pavimento frente a la escuela primaria",
    "Bache profundo en la avenida, ya causó un accidente",
    "Calle completamente destruida, necesita repavimentación urgente",
    "Bache en la esquina que se llena de agua cuando llueve"
  ],
  "Alumbrado" => [
    "Lámpara fundida en la calle, muy oscuro por las noches",
    "Poste de luz inclinado, riesgo de caer",
    "Toda la cuadra sin alumbrado desde hace una semana",
    "Luminaria parpadeante, genera molestia a los vecinos",
    "Falta de iluminación en el parque, inseguro por las noches"
  ],
  "Limpieza" => [
    "Acumulación de basura en el terreno baldío",
    "No han pasado a recoger la basura en 3 días",
    "Escombros abandonados en la banqueta",
    "Grafiti en las paredes del edificio público",
    "Necesitan limpiar el arroyo, está lleno de desechos"
  ],
  "Seguridad" => [
    "Robos frecuentes en la colonia, necesitamos más patrullaje",
    "Punto de venta de drogas en la esquina",
    "Vandalismo constante en el parque por las noches",
    "Autos a exceso de velocidad en zona escolar",
    "Necesitamos cámaras de vigilancia en la plaza"
  ],
  "Drenaje" => [
    "Fuga de aguas negras en la calle",
    "Alcantarilla tapada, se inunda cuando llueve",
    "Olor insoportable por drenaje roto",
    "Registro de drenaje sin tapa, peligro para peatones",
    "Aguas negras saliendo por la coladera"
  ],
  "Parques y jardines" => [
    "Juegos infantiles rotos en el parque",
    "Árboles que necesitan poda urgente",
    "Bancas del parque destruidas",
    "Pasto muy crecido en el camellón",
    "Riego automático descompuesto, plantas secándose"
  ],
  "Transporte público" => [
    "Parada de camión sin techo ni banca",
    "Camiones no respetan la ruta ni los horarios",
    "Unidad de transporte en muy mal estado",
    "Falta señalización de parada de autobús",
    "Choferes manejan a exceso de velocidad"
  ],
  "Ruido" => [
    "Taller mecánico genera ruido excesivo todo el día",
    "Fiestas con música a alto volumen hasta la madrugada",
    "Construcción sin permiso genera ruido desde las 6am",
    "Bar con música en exceso, no respeta horarios",
    "Perros ladrando toda la noche sin control"
  ],
  "Basura" => [
    "Contenedor de basura desbordado desde hace días",
    "Personas tirando basura en el río",
    "Necesitamos más contenedores en la colonia",
    "Camión de basura no pasa por nuestra calle",
    "Tiradero clandestino en terreno baldío"
  ],
  "Agua potable" => [
    "Llevamos 3 días sin agua en la colonia",
    "Fuga de agua potable en la calle, desperdicio enorme",
    "Presión de agua muy baja, no sube al tinaco",
    "Agua sale con color café, no es potable",
    "Tubería rota inundando la calle"
  ],
  "Señalización vial" => [
    "Falta señal de alto en cruce peligroso",
    "Semáforo descompuesto en avenida principal",
    "Señales de tránsito vandalizadas, no se leen",
    "Necesitamos topes en zona escolar",
    "Líneas de cruce peatonal borradas"
  ],
  "Otros" => [
    "Perros callejeros agresivos en la colonia",
    "Cable de electricidad colgando peligrosamente",
    "Terreno baldío usado como basurero",
    "Plaga de mosquitos por agua estancada",
    "Puente peatonal en mal estado"
  ]
}.freeze

LOCATIONS = [
  "Calle Juárez esquina con Morelos", "Avenida Constitución #450",
  "Calle Hidalgo entre 5 de Mayo y Allende", "Boulevard Díaz Ordaz km 3",
  "Calle Zaragoza frente al mercado", "Avenida Universidad #1200",
  "Calle Madero y Guerrero", "Colonia Centro, calle principal",
  "Fraccionamiento Las Palmas, calle 4", "Colonia Industrial, av. del Trabajo",
  "Calle Reforma #89", "Boulevard Rogelio Cantú", "Avenida Lincoln #500",
  "Calle Matamoros esquina Bravo", "Colonia Moderna, calle 12",
  "Avenida Ruiz Cortines #300", "Calle Pino Suárez #67",
  "Colonia Del Valle, calle Río Amazonas", "Avenida Lázaro Cárdenas #1500",
  "Calle Venustiano Carranza frente a la iglesia"
].freeze

# ─── 2. Create categories ────────────────────────────────────
puts "\n📋 Creando categorías..."
categories = CATEGORIES_DATA.map do |name, sla|
  Category.find_or_create_by!(name: name) { |c| c.sla_hours = sla }
end
puts "   #{categories.size} categorías"

# ─── 3. Create alcaldías ─────────────────────────────────────
puts "\n🏛️  Creando alcaldías..."
alcaldias = MUNICIPIOS.map do |name|
  Alcaldia.find_or_create_by!(name: name)
end
puts "   #{alcaldias.size} alcaldías"

# ─── 4. Create users ─────────────────────────────────────────
puts "\n👥 Creando usuarios..."
admin = User.find_or_create_by!(name: "blind rage") do |u|
  u.role = "system_admin"
  u.password = "cuidado1"
  u.password_confirmation = "cuidado1"
end

used_names = Set.new(User.pluck(:name).map(&:downcase))

def gen_name(first_names, last_names, used)
  50.times do
    n = "#{first_names.sample} #{last_names.sample}"
    unless used.include?(n.downcase)
      used.add(n.downcase)
      return n
    end
  end
  n = "#{first_names.sample} #{last_names.sample} #{SecureRandom.hex(2)}"
  used.add(n.downcase)
  n
end

mayors = {}
officials = {}
citizens = []

alcaldias.each do |alc|
  # Mayor
  existing_mayor = User.find_by(role: "mayor", alcaldia_id: alc.id)
  if existing_mayor
    mayors[alc.id] = existing_mayor
  else
    name = gen_name(FIRST_NAMES, LAST_NAMES, used_names)
    mayors[alc.id] = User.create!(
      name: name, role: "mayor", alcaldia_id: alc.id,
      password: "password123", password_confirmation: "password123"
    )
  end

  # 3-8 officials per alcaldía (more for big cities)
  count = WEIGHT[alc.name] >= 10 ? rand(5..8) : WEIGHT[alc.name] >= 3 ? rand(3..5) : rand(2..3)
  officials[alc.id] = []

  existing_officials = User.where(role: "official", alcaldia_id: alc.id).to_a
  existing_officials.each { |o| officials[alc.id] << o }

  (count - existing_officials.size).times do
    name = gen_name(FIRST_NAMES, LAST_NAMES, used_names)
    officials[alc.id] << User.create!(
      name: name, role: "official", manager_id: mayors[alc.id].id,
      alcaldia_id: alc.id, password: "password123", password_confirmation: "password123"
    )
  end
end

# 200 citizens
existing_citizens = User.where(role: "citizen").to_a
citizens = existing_citizens.dup
(200 - existing_citizens.size).clamp(0, 200).times do
  name = gen_name(FIRST_NAMES, LAST_NAMES, used_names)
  citizens << User.create!(
    name: name, role: "citizen",
    password: "password123", password_confirmation: "password123"
  )
end

total_officials = officials.values.flatten.size
puts "   1 admin, #{mayors.size} alcaldes, #{total_officials} funcionarios, #{citizens.size} ciudadanos"

# ─── 5. Generate reports for 1 year ──────────────────────────
puts "\n📝 Generando reportes (1 año de simulación)..."

start_date = 1.year.ago.beginning_of_day
end_date = Time.current
total_created = 0

alcaldias.each do |alc|
  weight = WEIGHT[alc.name]
  base_coords = COORDS[alc.name] || [25.67 + rand(-1.0..1.0), -100.0 + rand(-1.0..0.5)]
  alc_officials = officials[alc.id] || []
  reports_count = weight * rand(15..25)

  reports_count.times do
    cat = categories.sample
    created = rand(start_date..end_date)
    reporter = citizens.sample
    desc_pool = DESCRIPTIONS[cat.name] || DESCRIPTIONS["Otros"]
    description = desc_pool.sample

    lat = base_coords[0] + rand(-0.03..0.03)
    lng = base_coords[1] + rand(-0.03..0.03)
    location = LOCATIONS.sample

    # Determine final state based on age and randomness
    age_hours = (Time.current - created) / 3600.0
    r = rand(100)

    status = if age_hours < 4
      "pending"
    elsif r < 5
      "pending"
    elsif r < 12
      "read"
    elsif r < 25
      "assigned"
    else
      "resolved"
    end

    attrs = {
      description: description,
      category_id: cat.id,
      alcaldia_id: alc.id,
      reporter_id: reporter.id,
      latitude: lat,
      longitude: lng,
      location_description: location,
      status: "pending",
      created_at: created,
      updated_at: created
    }

    report = Report.new(attrs)
    report.save!(validate: false)

    # Simulate state transitions with realistic timestamps
    if %w[read assigned resolved].include?(status)
      read_delay = rand(0.5..48.0).hours
      read_at = created + read_delay
      report.update_columns(status: "read", read_at: read_at, updated_at: read_at)
    end

    if %w[assigned resolved].include?(status) && alc_officials.any?
      assign_delay = rand(1.0..72.0).hours
      assigned_at = (report.read_at || created) + assign_delay
      assignee = alc_officials.sample
      report.update_columns(
        status: "assigned", assignee_id: assignee.id,
        assigned_at: assigned_at, updated_at: assigned_at
      )
    end

    if status == "resolved"
      resolve_delay = rand(2.0..168.0).hours
      resolved_at = (report.assigned_at || created) + resolve_delay
      resolved_at = [resolved_at, Time.current].min

      resolution_note = "Se atendió el reporte. #{['Trabajo completado satisfactoriamente.', 'Se realizó la reparación correspondiente.', 'Problema solucionado por el equipo de trabajo.', 'Se coordinó con el área responsable para la solución.'].sample}"
      report.update_columns(
        status: "resolved", resolved_at: resolved_at,
        resolution_note: resolution_note, updated_at: resolved_at
      )

      # 30% chance citizen accepted
      if rand(100) < 30
        accepted_at = resolved_at + rand(1..48).hours
        accepted_at = [accepted_at, Time.current].min
        report.update_columns(reporter_accepted_at: accepted_at)
      end

      # 8% chance of reopen
      if rand(100) < 8
        report.update_columns(
          reopened: true, status: "assigned",
          reporter_rejection_note: ["No se resolvió correctamente, el problema persiste.", "La reparación fue superficial, volvió a fallar.", "No estoy conforme, el problema sigue igual."].sample
        )
      end
    end

    total_created += 1
  end

  print "\r   #{alc.name.ljust(30)} #{reports_count} reportes"
end

puts "\n   Total: #{total_created} reportes creados"

# ─── 6. Generate historical snapshots ────────────────────────
puts "\n📊 Generando snapshots históricos..."

snapshot_date = start_date.to_date
dates_created = 0

while snapshot_date <= Date.current
  # Only snapshot every 7 days to keep it manageable
  if snapshot_date.wday == 0 || snapshot_date == Date.current
    alcaldias.each do |alc|
      reports = Report.where(alcaldia_id: alc.id).where("reports.created_at <= ?", snapshot_date.end_of_day)

      resolved = reports.where(status: "resolved").where.not(resolved_at: nil)
      avg_resolution = resolved
        .where("reports.resolved_at <= ?", snapshot_date.end_of_day)
        .average("EXTRACT(EPOCH FROM (reports.resolved_at - reports.created_at)) / 3600")
        &.to_f

      read_reports = reports.where.not(read_at: nil).where("reports.read_at <= ?", snapshot_date.end_of_day)
      avg_response = read_reports
        .average("EXTRACT(EPOCH FROM (reports.read_at - reports.created_at)) / 3600")
        &.to_f

      overdue = reports
        .joins(:category)
        .where.not(status: "resolved")
        .where("categories.sla_hours IS NOT NULL")
        .where("reports.created_at + (categories.sla_hours * INTERVAL '1 hour') < ?", snapshot_date.end_of_day)
        .count

      by_category = reports
        .joins(:category)
        .group("categories.name")
        .count

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
          by_category: by_category,
          created_at: snapshot_date.to_time,
          updated_at: snapshot_date.to_time
        },
        unique_by: [:alcaldia_id, :snapshot_date]
      )
    end
    dates_created += 1
    print "\r   Snapshot #{snapshot_date} (#{dates_created} fechas)"
  end

  snapshot_date += 1.day
end

puts "\n   #{dates_created} fechas de snapshot generadas (#{dates_created * alcaldias.size} registros)"

# ─── Summary ─────────────────────────────────────────────────
puts "\n=== Resumen ==="
puts "Alcaldías:     #{Alcaldia.count}"
puts "Categorías:    #{Category.count}"
puts "Usuarios:      #{User.count} (#{User.where(role: 'system_admin').count} admin, #{User.where(role: 'mayor').count} alcaldes, #{User.where(role: 'official').count} funcionarios, #{User.where(role: 'citizen').count} ciudadanos)"
puts "Reportes:      #{Report.count}"
puts "  Pendientes:  #{Report.where(status: 'pending').count}"
puts "  Leídos:      #{Report.where(status: 'read').count}"
puts "  Asignados:   #{Report.where(status: 'assigned').count}"
puts "  Resueltos:   #{Report.where(status: 'resolved').count}"
puts "  Reabiertos:  #{Report.where(reopened: true).count}"
puts "Snapshots:     #{ReportSnapshot.count}"
puts "\nFin: #{Time.current}"
