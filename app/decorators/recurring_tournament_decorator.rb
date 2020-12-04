class RecurringTournamentDecorator < BaseDecorator

  def level_text
    RecurringTournament.human_attribute_name("level.#{model.level}")
  end

  def recurring_type_text
    RecurringTournament.human_attribute_name("recurring_type.#{model.recurring_type}")
  end

  def wday_text
    I18n.t('date.day_names')[model.wday].titlecase
  end

  def starts_at
    I18n.l(model.starts_at, format: '%Hh%M')
  end

  def date_on_week(monday)
    d = monday.beginning_of_week + model.wday
    t = model.starts_at
    DateTime.new(d.year, d.month, d.day, t.hour, t.min)
  end

  def description
    model.name
  end

  def as_event(week_start:)
    {
      title: model.name,
      start: date_on_week(week_start),
      description: description
    }
  end

end
