require "test_helper"

class TemperatureReadingsControllerTest < ActionDispatch::IntegrationTest
  test "index shows the average temperature from the last 24 hours and renders timestamps in Sao Paulo time" do
    travel_to Time.utc(2026, 4, 4, 12, 0, 0) do
      recent_reading = temperature_readings(:recent)
      expected_timestamp = I18n.l(
        recent_reading.recorded_at.in_time_zone("America/Sao_Paulo"),
        format: :temperature_reading,
        locale: :"pt-BR"
      )

      get temperature_readings_url

      assert_response :success
      assert_includes response.body, "Total exibido"
      assert_includes response.body, "Média 24h"
      assert_includes response.body, "20.50 °C"
      assert_select "#temperature-readings-chart canvas", count: 1
      assert_includes response.body, expected_timestamp
    end
  end

  test "index renders chart series grouped by source" do
    travel_to Time.utc(2026, 4, 4, 12, 0, 0) do
      TemperatureReading.create!(
        temperature_c: 21.4,
        recorded_at: Time.utc(2026, 4, 4, 10, 30, 0),
        source: TemperatureReading::SOURCE_OPEN_METEO,
        raw_payload: "{\"current\":{\"temperature_2m\":21.4}}"
      )

      get temperature_readings_url

      assert_response :success
      assert_includes response.body, "data-chart-series-value"
      assert_includes response.body, "Arduino"
      assert_includes response.body, "Open-Meteo"
    end
  end
end