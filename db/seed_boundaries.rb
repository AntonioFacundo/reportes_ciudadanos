# frozen_string_literal: true

# Run with: bin/rails runner db/seed_boundaries.rb
# Downloads municipal boundaries from OpenStreetMap/Nominatim and loads them into PostGIS.
# Respects Nominatim rate limit (1 req/s).

require "net/http"
require "json"
require "uri"

NOMINATIM_BASE = "https://nominatim.openstreetmap.org"
USER_AGENT = "RageReportsApp/1.0 (municipal boundary loader)"

SEARCH_QUERIES = ->(name) {
  [
    "#{name}, Nuevo León, Mexico",
    "municipio de #{name}, Nuevo Leon, Mexico",
    "#{name}, Nuevo Leon"
  ]
}

def nominatim_search(municipality_name)
  SEARCH_QUERIES.call(municipality_name).each do |query|
    uri = URI("#{NOMINATIM_BASE}/search?#{URI.encode_www_form(q: query, format: "json", polygon_geojson: 0, limit: 3)}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = USER_AGENT

    response = http.request(req)
    next unless response.is_a?(Net::HTTPSuccess)

    results = JSON.parse(response.body)
    match = results.find { |r| r["osm_type"] == "relation" && r["class"] == "boundary" }
    return match if match

    sleep 1.1
  end
  nil
end

def nominatim_details(osm_id)
  uri = URI("#{NOMINATIM_BASE}/details?#{URI.encode_www_form(osmtype: "R", osmid: osm_id, format: "json", polygon_geojson: 1)}")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri)
  req["User-Agent"] = USER_AGENT

  response = http.request(req)
  return nil unless response.is_a?(Net::HTTPSuccess)

  data = JSON.parse(response.body)
  geom = data["geometry"]
  return nil unless geom && %w[Polygon MultiPolygon].include?(geom["type"])

  geom
end

# Some municipalities have different names in OSM
SEARCH_OVERRIDES = {
  "San Pedro Garza García" => "San Pedro Garza García",
  "San Nicolás de los Garza" => "San Nicolás de los Garza",
  "Cadereyta Jiménez" => "Cadereyta Jiménez",
  "Ciénega de Flores" => "Ciénega de Flores",
  "Lampazos de Naranjo" => "Lampazos de Naranjo",
  "Mier y Noriega" => "Mier y Noriega",
  "Los Aldamas" => "Los Aldamas",
  "Los Herreras" => "Los Herreras",
  "Los Ramones" => "Los Ramones",
  "El Carmen" => "El Carmen",
  "Doctor Arroyo" => "Doctor Arroyo",
  "Doctor Coss" => "Doctor Coss",
  "Doctor González" => "Doctor González"
}.freeze

puts "=== Cargando boundaries municipales de Nuevo León ==="
puts "Fuente: OpenStreetMap / Nominatim"
puts ""

alcaldias = Alcaldia.order(:name).to_a
loaded = 0
skipped = 0
failed = 0

alcaldias.each_with_index do |alc, idx|
  if alc.has_boundary?
    puts "  [#{idx + 1}/#{alcaldias.size}] #{alc.name.ljust(30)} YA TIENE boundary - saltando"
    skipped += 1
    next
  end

  search_name = SEARCH_OVERRIDES[alc.name] || alc.name
  print "  [#{idx + 1}/#{alcaldias.size}] #{alc.name.ljust(30)} buscando..."

  result = nominatim_search(search_name)
  sleep 1.1

  unless result
    puts " NO ENCONTRADO en Nominatim"
    failed += 1
    next
  end

  osm_id = result["osm_id"]
  print " osm_id=#{osm_id}, descargando polígono..."

  geometry = nominatim_details(osm_id)
  sleep 1.1

  unless geometry
    puts " SIN POLÍGONO"
    failed += 1
    next
  end

  geojson = geometry.to_json
  alc.boundary_from_geojson(geojson)

  if alc.has_boundary?
    puts " OK (#{geometry['type']})"
    loaded += 1
  else
    puts " ERROR al guardar"
    failed += 1
  end
end

puts ""
puts "=== Resumen ==="
puts "  Cargados:  #{loaded}"
puts "  Ya tenían: #{skipped}"
puts "  Fallidos:  #{failed}"
puts "  Total:     #{alcaldias.size}"
puts ""
puts "Verificación:"
Alcaldia.order(:name).each do |a|
  status = a.has_boundary? ? "OK" : "SIN BOUNDARY"
  puts "  #{a.name.ljust(30)} #{status}"
end
