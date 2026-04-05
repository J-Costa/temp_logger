class TemperatureReadingsController < ApplicationController
  def index
    @temperature_readings = TemperatureReading.order(recorded_at: :desc).limit(100)
    @average_temperature = TemperatureReading.where(recorded_at: 24.hours.ago..).average(:temperature_c)

    respond_to do |format|
      format.html
      format.json do
        render json: @temperature_readings.as_json(
          only: [:id, :temperature_c, :recorded_at, :source, :serial_port, :created_at]
        )
      end
    end
  end
end
