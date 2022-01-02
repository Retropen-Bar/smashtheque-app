class ImportLatestSmashggEventsJob < ApplicationJob
  queue_as :smashgg

  DEFAULT_NAME = nil
  DEFAULT_PERIODS = 10
  DEFAULT_PERIOD_DAYS = 7
  DEFAULT_COUNTRY = 'FR'.freeze
  SLEEP = 1

  def perform(
    name: DEFAULT_NAME,
    periods: DEFAULT_PERIODS,
    period_days: DEFAULT_PERIOD_DAYS,
    country: DEFAULT_COUNTRY,
    to: Time.zone.today - 2
  )
    ((to - (periods * period_days))...to).step(period_days) do |from|
      sleep SLEEP
      SmashggEvent.import_all(
        name: name,
        from: from,
        to: from + period_days,
        country: country
      )
    end
  end
end
