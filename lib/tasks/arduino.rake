namespace :arduino do
  desc "Read Arduino temperature by request-response loop and persist readings"
  task read_serial: :environment do
    require "serialport"

    port = ENV.fetch("SERIAL_PORT", "/dev/ttyACM0")
    baud_rate = ENV.fetch("SERIAL_BAUD", "9600").to_i
    poll_interval_seconds = ENV.fetch("SERIAL_POLL_INTERVAL_SECONDS", "60").to_i
    poll_interval_seconds = 1 if poll_interval_seconds < 1

    reader = Arduino::SerialReader.new(port: port, baud_rate: baud_rate)
    reader.run_forever(poll_interval_seconds: poll_interval_seconds)
  end

  desc "Read a fixed number of Arduino samples (default: 1)"
  task :read_once, [:samples] => :environment do |_task, args|
    require "serialport"

    port = ENV.fetch("SERIAL_PORT", "/dev/ttyACM0")
    baud_rate = ENV.fetch("SERIAL_BAUD", "9600").to_i
    samples = (args[:samples] || ENV.fetch("SERIAL_SAMPLES", "1")).to_i

    reader = Arduino::SerialReader.new(port: port, baud_rate: baud_rate)
    persisted = reader.run_once(samples: samples)

    puts "Persisted #{persisted} reading(s)"
  end
end
