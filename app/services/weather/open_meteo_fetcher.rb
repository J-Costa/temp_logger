require "json"
require "net/http"
require "time"

module Weather
  class OpenMeteoFetcher
    API_ENDPOINT = "https://api.open-meteo.com/v1/forecast".freeze
    DEFAULT_LATITUDE = -23.5505
    DEFAULT_LONGITUDE = -46.6333
    DEFAULT_TIME_ZONE = "America/Sao_Paulo".freeze

    def initialize(
      latitude: DEFAULT_LATITUDE,
      longitude: DEFAULT_LONGITUDE,
      timezone: DEFAULT_TIME_ZONE,
      http_client: Net::HTTP,
      logger: Rails.logger
    )
      @latitude = latitude
      @longitude = longitude
      @timezone = timezone
      @http_client = http_client
      @logger = logger
    end

    def fetch_and_persist
      payload = fetch_payload(current: "temperature_2m")
      current = payload["current"] || {}

      temperature = current["temperature_2m"]
      recorded_at = parse_recorded_at(current["time"])

      if temperature.nil? || recorded_at.nil?
        @logger.warn("[Weather::OpenMeteoFetcher] Missing fields in payload")
        return nil
      end

      reading = TemperatureReading.find_or_initialize_by(
        source: TemperatureReading::SOURCE_OPEN_METEO,
        recorded_at: recorded_at
      )
      reading.temperature_c = temperature.to_f
      reading.raw_payload = payload.to_json
      reading.save!

      @logger.info(
        "[Weather::OpenMeteoFetcher] Saved #{reading.temperature_c.round(2)} C for #{recorded_at.iso8601}"
      )

      reading
    rescue StandardError => e
      @logger.error("[Weather::OpenMeteoFetcher] Error while fetching external reading: #{e.class} - #{e.message}")
      nil
    end

    def fetch_last_7_days_hourly_and_persist
      payload = fetch_payload(hourly: "temperature_2m", past_days: 7, forecast_days: 1)
      hourly_times = Array(payload.dig("hourly", "time"))
      hourly_temperatures = Array(payload.dig("hourly", "temperature_2m"))

      result = {
        inserted: 0,
        updated: 0,
        skipped: 0
      }
      window_start = 7.days.ago
      now = Time.current

      hourly_times.zip(hourly_temperatures).each do |time_value, temperature|
        recorded_at = parse_recorded_at(time_value)

        if recorded_at.nil? || temperature.nil? || recorded_at < window_start || recorded_at > now
          result[:skipped] += 1
          next
        end

        reading = TemperatureReading.find_or_initialize_by(
          source: TemperatureReading::SOURCE_OPEN_METEO,
          recorded_at: recorded_at
        )
        was_new_record = reading.new_record?

        reading.temperature_c = temperature.to_f
        reading.raw_payload = {
          provider: "open_meteo",
          time: time_value,
          temperature_2m: temperature
        }.to_json
        reading.save!

        if was_new_record
          result[:inserted] += 1
        else
          result[:updated] += 1
        end
      end

      @logger.info(
        "[Weather::OpenMeteoFetcher] Hourly history sync inserted=#{result[:inserted]} updated=#{result[:updated]} skipped=#{result[:skipped]}"
      )
      result
    rescue StandardError => e
      @logger.error("[Weather::OpenMeteoFetcher] Error while syncing hourly history: #{e.class} - #{e.message}")
      {
        inserted: 0,
        updated: 0,
        skipped: 0,
        error: e.message
      }
    end

    private

    def fetch_payload(request_params)
      uri = URI(API_ENDPOINT)
      uri.query = URI.encode_www_form(
        latitude: @latitude,
        longitude: @longitude,
        timezone: @timezone,
        **request_params
      )

      response = @http_client.get_response(uri)
      status_code = response.code.to_i
      raise "Open-Meteo request failed with status #{status_code}" unless status_code.between?(200, 299)

      JSON.parse(response.body)
    end

    def parse_recorded_at(value)
      return nil if value.blank?

      timezone = ActiveSupport::TimeZone[@timezone] || Time.zone
      timezone.parse(value)&.utc
    rescue ArgumentError
      nil
    end
  end
end