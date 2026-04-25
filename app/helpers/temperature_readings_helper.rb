module TemperatureReadingsHelper
  DISPLAY_TIME_ZONE = "America/Sao_Paulo".freeze

  HOT_TEMPERATURE_C = 30.0
  COLD_TEMPERATURE_C = 15.0

  HOT_BADGE_CLASSES = "text-red-600 bg-red-50".freeze
  HOT_BADGE_BORDER_CLASSES = "text-red-600 bg-red-50 border-red-200".freeze
  COLD_BADGE_CLASSES = "text-sky-700 bg-sky-50".freeze
  COLD_BADGE_BORDER_CLASSES = "text-sky-700 bg-sky-50 border-sky-200".freeze
  NORMAL_BADGE_CLASSES = "text-emerald-700 bg-emerald-50".freeze
  NORMAL_BADGE_BORDER_CLASSES = "text-emerald-700 bg-emerald-50 border-emerald-200".freeze

  def temperature_badge_classes(temperature, with_border: false)
    value = temperature.to_f

    if value >= HOT_TEMPERATURE_C
      return with_border ? HOT_BADGE_BORDER_CLASSES : HOT_BADGE_CLASSES
    end

    if value <= COLD_TEMPERATURE_C
      return with_border ? COLD_BADGE_BORDER_CLASSES : COLD_BADGE_CLASSES
    end

    with_border ? NORMAL_BADGE_BORDER_CLASSES : NORMAL_BADGE_CLASSES
  end

  def format_temperature_recorded_at(recorded_at)
    return "-" if recorded_at.blank?

    I18n.l(
      recorded_at.in_time_zone(DISPLAY_TIME_ZONE),
      format: :temperature_reading,
      locale: :"pt-BR"
    )
  end
end