module Arduino
  class SerialReader
    DEFAULT_BAUD_RATE = 9_600
    DEFAULT_READ_TIMEOUT_MS = 2_000

    def initialize(port:, baud_rate: DEFAULT_BAUD_RATE, io_factory: SerialPort)
      @port = port
      @baud_rate = baud_rate
      @io_factory = io_factory
    end

    def run_forever
      with_serial do |serial|
        Rails.logger.info("[Arduino::SerialReader] Listening on #{@port} at #{@baud_rate} baud")

        loop do
          read_and_persist(serial)
        end
      end
    end

    def run_once(samples: 1)
      persisted = 0

      with_serial do |serial|
        samples.times do
          persisted += 1 if read_and_persist(serial)
        end
      end

      persisted
    end

    private

    def with_serial
      serial = @io_factory.new(@port, @baud_rate, 8, 1, SerialPort::NONE)
      serial.read_timeout = DEFAULT_READ_TIMEOUT_MS
      yield serial
    ensure
      serial&.close
    end

    def read_and_persist(serial)
      raw_line = serial.gets
      return false if raw_line.nil?

      payload = raw_line.strip
      return false if payload.empty?

      temperature = parse_temperature(payload)
      return false if temperature.nil?

      TemperatureReading.create!(
        temperature_c: temperature,
        recorded_at: Time.current,
        source: "arduino",
        serial_port: @port,
        raw_payload: payload
      )

      Rails.logger.info("[Arduino::SerialReader] Saved #{temperature.round(2)} C")
      true
    rescue StandardError => e
      Rails.logger.error("[Arduino::SerialReader] Error while reading serial: #{e.class} - #{e.message}")
      false
    end

    def parse_temperature(payload)
      Float(payload)
    rescue ArgumentError, TypeError
      Rails.logger.warn("[Arduino::SerialReader] Ignoring invalid payload: #{payload.inspect}")
      nil
    end
  end
end
