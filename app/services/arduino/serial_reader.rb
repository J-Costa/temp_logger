module Arduino
  class SerialReader
    DEFAULT_BAUD_RATE = 9_600
    DEFAULT_READ_TIMEOUT_MS = 2_000
    DEFAULT_POLL_INTERVAL_SECONDS = 60
    REQUEST_COMMAND = "READ\n"

    def initialize(port:, baud_rate: DEFAULT_BAUD_RATE, io_factory: SerialPort)
      @port = port
      @baud_rate = baud_rate
      @io_factory = io_factory
    end

    def run_forever(poll_interval_seconds: DEFAULT_POLL_INTERVAL_SECONDS)
      with_serial do |serial|
        Rails.logger.info(
          "[Arduino::SerialReader] Listening on #{@port} at #{@baud_rate} baud (interval=#{poll_interval_seconds}s)"
        )

        loop do
          started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          read_and_persist(serial)

          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
          sleep_seconds = poll_interval_seconds - elapsed
          sleep(sleep_seconds) if sleep_seconds.positive?
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
      serial.write(REQUEST_COMMAND)
      raw_line = serial.gets
      return false if raw_line.nil?

      payload = raw_line.strip
      return false if payload.empty?
      return false if payload == "ERR"

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
