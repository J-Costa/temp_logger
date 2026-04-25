# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "[seeds] Iniciando seed de temperaturas..."

source_name = "seed_data"
readings_count = 48
window_hours = 8
start_time = window_hours.hours.ago

deleted = TemperatureReading.where(source: source_name).delete_all
puts "[seeds] Removidos #{deleted} registros antigos de '#{source_name}'."

puts "[seeds] Gerando #{readings_count} leituras realistas nas ultimas #{window_hours} horas..."

readings_count.times do |i|
  progress = i + 1
  recorded_at = start_time + ((window_hours.hours.to_f / readings_count) * i)

  # Simula ciclo diario simples: madrugada mais fria, tarde mais quente.
  hour = recorded_at.in_time_zone("America/Sao_Paulo").hour
  base_temperature = 23.0 + Math.sin((hour - 6) * Math::PI / 12.0) * 4.5
  noise = rand(-0.8..0.8)
  temperature = (base_temperature + noise).clamp(17.0, 34.0).round(2)

  TemperatureReading.create!(
    temperature_c: temperature,
    recorded_at: recorded_at,
    source: source_name,
    serial_port: "/dev/ttyUSB#{i % 4}",
    raw_payload: "temperature:#{temperature};timestamp:#{recorded_at.to_i}"
  )

  puts "[seeds] #{progress}/#{readings_count} leituras criadas" if (progress % 12).zero? || progress == readings_count
end

puts "[seeds] Seed finalizado com sucesso."