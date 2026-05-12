class TemperatureReading < ApplicationRecord
  SOURCE_ARDUINO = "arduino".freeze
  SOURCE_OPEN_METEO = "open_meteo".freeze
  SOURCE_SEED_DATA = "seed_data".freeze
  SOURCES = [SOURCE_ARDUINO, SOURCE_OPEN_METEO, SOURCE_SEED_DATA].freeze

  validates :temperature_c, presence: true
  validates :recorded_at, presence: true
  validates :source, inclusion: { in: SOURCES }

  scope :by_source, ->(source) { where(source: source) }
end
