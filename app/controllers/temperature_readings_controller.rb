class TemperatureReadingsController < ApplicationController
  PER_PAGE = 25
  DEFAULT_TIME_RANGE = "24h"
  DEFAULT_TEMP_RANGE = "all"

  def index
    @time_range = params[:time_range] || DEFAULT_TIME_RANGE
    @temp_range = params[:temp_range] || DEFAULT_TEMP_RANGE

    readings = TemperatureReading.order(recorded_at: :desc)
    readings = filter_by_time_range(readings, @time_range)
    readings = filter_by_temperature_range(readings, @temp_range)

    @average_temperature_filtered = readings.average(:temperature_c) || 0
    @temperature_readings = readings.limit(PER_PAGE).to_a
    @chart_points = @temperature_readings.reverse.map do |reading|
      {
        label: helpers.format_temperature_recorded_at(reading.recorded_at),
        value: reading.temperature_c.to_f
      }
    end
    @average_temperature = TemperatureReading.where(recorded_at: 24.hours.ago..).average(:temperature_c) || 0

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json do
        render json: @temperature_readings.as_json(
          only: [:id, :temperature_c, :recorded_at, :source, :serial_port, :created_at]
        )
      end
    end
  end

  private

  def filter_by_time_range(relation, time_range)
    case time_range
    when "1h"
      relation.where(recorded_at: 1.hour.ago..)
    when "7d"
      relation.where(recorded_at: 7.days.ago..)
    when "all"
      relation
    else 
      relation.where(recorded_at: 24.hours.ago..)
    end
  end

  def filter_by_temperature_range(relation, temp_range)
    case temp_range
    when "cold"
      relation.where("temperature_c <= ?", TemperatureReadingsHelper::COLD_TEMPERATURE_C)
    when "hot"
      relation.where("temperature_c >= ?", TemperatureReadingsHelper::HOT_TEMPERATURE_C)
    when "normal"
      relation.where(
        "temperature_c > ? AND temperature_c < ?",
        TemperatureReadingsHelper::COLD_TEMPERATURE_C,
        TemperatureReadingsHelper::HOT_TEMPERATURE_C
      )
    else 
      relation
    end
  end
end
