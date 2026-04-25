namespace :weather do
  desc "Fetch external temperature from Open-Meteo and persist reading"
  task fetch: :environment do
    latitude = ENV.fetch("WEATHER_LATITUDE", Weather::OpenMeteoFetcher::DEFAULT_LATITUDE.to_s).to_f
    longitude = ENV.fetch("WEATHER_LONGITUDE", Weather::OpenMeteoFetcher::DEFAULT_LONGITUDE.to_s).to_f
    timezone = ENV.fetch("WEATHER_TIMEZONE", Weather::OpenMeteoFetcher::DEFAULT_TIME_ZONE)

    fetcher = Weather::OpenMeteoFetcher.new(
      latitude: latitude,
      longitude: longitude,
      timezone: timezone
    )
    reading = fetcher.fetch_and_persist

    if reading.present?
      puts "Persisted external reading #{reading.temperature_c.round(2)} C at #{reading.recorded_at.iso8601}"
    else
      puts "No external reading was persisted"
    end
  end
end