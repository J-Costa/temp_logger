require "test_helper"

module Weather
  class OpenMeteoFetcherTest < ActiveSupport::TestCase
    test "fetches and persists an open meteo reading" do
      response_payload = {
        current: {
          temperature_2m: 23.4,
          time: "2026-04-04T10:00"
        }
      }
      http_client = build_http_client(code: "200", body: response_payload.to_json)

      fetcher = OpenMeteoFetcher.new(http_client: http_client)
      reading = fetcher.fetch_and_persist

      assert reading.present?
      assert_equal TemperatureReading::SOURCE_OPEN_METEO, reading.source
      assert_in_delta 23.4, reading.temperature_c, 0.001
      assert_includes reading.raw_payload, "temperature_2m"
    end

    test "updates existing reading for same source and timestamp" do
      existing = TemperatureReading.create!(
        temperature_c: 18.5,
        source: TemperatureReading::SOURCE_OPEN_METEO,
        recorded_at: Time.utc(2026, 4, 4, 13, 0, 0),
        raw_payload: "{}"
      )

      response_payload = {
        current: {
          temperature_2m: 21.1,
          time: "2026-04-04T10:00"
        }
      }
      http_client = build_http_client(code: "200", body: response_payload.to_json)

      fetcher = OpenMeteoFetcher.new(http_client: http_client)
      reading = fetcher.fetch_and_persist

      assert_equal existing.id, reading.id
      assert_in_delta 21.1, reading.temperature_c, 0.001
      assert_equal 1, TemperatureReading.where(source: TemperatureReading::SOURCE_OPEN_METEO, recorded_at: existing.recorded_at).count
    end

    test "returns nil when request fails" do
      http_client = build_http_client(code: "500", body: "{}")
      fetcher = OpenMeteoFetcher.new(http_client: http_client)

      reading = fetcher.fetch_and_persist

      assert_nil reading
    end

    private

    def build_http_client(code:, body:)
      response_class = Struct.new(:code, :body)

      Class.new do
        define_singleton_method(:get_response) do |_uri|
          response_class.new(code, body)
        end
      end
    end
  end
end