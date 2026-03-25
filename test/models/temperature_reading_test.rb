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
end
