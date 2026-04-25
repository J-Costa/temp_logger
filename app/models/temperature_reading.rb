class TemperatureReading < ApplicationRecord
  SOURCE_ARDUINO = "arduino".freeze
  SOURCE_OPEN_METEO = "open_meteo".freeze
  SOURCES = [SOURCE_ARDUINO, SOURCE_OPEN_METEO].freeze

  validates :temperature_c, presence: true
  validates :recorded_at, presence: true
  validates :source, inclusion: { in: SOURCES }

  scope :by_source, ->(source) { where(source: source) }
end
