class TemperatureReading < ApplicationRecord
  validates :temperature_c, presence: true
  validates :recorded_at, presence: true
end
