namespace :arduino do
  desc "Read Arduino serial continuously and persist temperature readings"
  task read_serial: :environment do
    require "serialport"

    port = ENV.fetch("SERIAL_PORT", "/dev/ttyACM0")
    baud_rate = ENV.fetch("SERIAL_BAUD", "9600").to_i

    reader = Arduino::SerialReader.new(port: port, baud_rate: baud_rate)
    reader.run_forever
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
