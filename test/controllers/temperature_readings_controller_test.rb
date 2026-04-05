require "test_helper"

class TemperatureReadingsControllerTest < ActionDispatch::IntegrationTest
  test "index shows the average temperature from the last 24 hours and renders timestamps in Sao Paulo time" do
    travel_to Time.utc(2026, 4, 4, 12, 0, 0) do
      recent_reading = temperature_readings(:recent)

      get temperature_readings_url

      assert_response :success
      assert_select "p", text: /Total exibido: 2 - Média das últimas 24 horas: 20\.50 °C/
      assert_includes response.body, recent_reading.recorded_at.in_time_zone("America/Sao_Paulo").strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end