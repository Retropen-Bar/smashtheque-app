class RecurringTournamentDecorator < BaseDecorator

  LEVEL_COLORS = {
    l1_playground: :green,
    l2_anything: :blue,
    l3_glory: :red,
    l4_experts: :black
  }

  def self.level_color(level)
    LEVEL_COLORS[level.to_sym]
  end

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
    start = date_on_week(week_start)
    classes = [
      "level-#{model.level}"
    ]
    duration = 3.hours # TODO: improve this
    {
      title: model.name,
      start: start,
      end: start + duration,
      description: description,
      classNames: classes
    }
  end

end
