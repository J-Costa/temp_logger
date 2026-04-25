require "test_helper"

class TemperatureReadingTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    reading = TemperatureReading.new(
      temperature_c: 24.7,
      recorded_at: Time.current
    )

    assert reading.valid?
  end

  test "is invalid without temperature" do
    reading = TemperatureReading.new(recorded_at: Time.current)

    assert_not reading.valid?
    assert_includes reading.errors[:temperature_c], "can't be blank"
  end

  test "is invalid without recorded_at" do
    reading = TemperatureReading.new(temperature_c: 24.7)

    assert_not reading.valid?
    assert_includes reading.errors[:recorded_at], "can't be blank"
  end

  test "is valid with open meteo source" do
    reading = TemperatureReading.new(
      temperature_c: 22.1,
      recorded_at: Time.current,
      source: TemperatureReading::SOURCE_OPEN_METEO
    )

    assert reading.valid?
  end

  test "is invalid with unsupported source" do
    reading = TemperatureReading.new(
      temperature_c: 22.1,
      recorded_at: Time.current,
      source: "unsupported_source"
    )

    assert_not reading.valid?
    assert_includes reading.errors[:source], "is not included in the list"
  end

  test "filters readings by source" do
    open_meteo = temperature_readings(:open_meteo_recent)

    filtered = TemperatureReading.by_source(TemperatureReading::SOURCE_OPEN_METEO)

    assert_includes filtered, open_meteo
    assert_not_includes filtered, temperature_readings(:recent)
  end
end
