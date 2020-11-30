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

end
