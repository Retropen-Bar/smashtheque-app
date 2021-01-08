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

  def self.size_name(size)
    size && (size > 128 ? '128+' : size)
  end

  def recurring_type_text
    RecurringTournament.human_attribute_name("recurring_type.#{model.recurring_type}")
  end

  def wday_text
    I18n.t('date.day_names')[model.wday].titlecase
  end

  def full_date
    if model.is_recurring?
      "#{wday_text} à #{starts_at}"
    else
      model.date_description
    end
  end

  def starts_at
    I18n.l(model.starts_at, format: '%Hh%M')
  end

  def date_on_week(monday)
    d = monday.beginning_of_week + ((model.wday + 6) % 7)
    t = model.starts_at
    DateTime.new(d.year, d.month, d.day, t.utc.hour, t.min)
  end

  def duration
    # TODO: improve this
    3.hours
  end

  def as_event(week_start:)
    start = date_on_week(week_start)
    classes = [
      "level-#{model.level}"
    ]
    {
      title: model.name + " (#{model.size})",
      start: start,
      end: start + duration,
      classNames: classes,
      modal_url: modal_recurring_tournament_path(model)
    }
  end

  def text_details
    [
      "Récurrence : #{recurring_type_text}",
      "Difficulté : #{level_text}",
      "Taille : #{size}",
      "Localisation : #{is_online? ? 'online' : 'offline'}",
      "Comment s'inscrire :",
      registration
    ].join("\n")
  end

  def as_ical_event
    start = if wday < Date.today.wday
      date_on_week(Date.today + 1.week)
    else
      date_on_week(Date.today)
    end
    event = Icalendar::Event.new
    event.dtstart = start
    event.dtend = start + duration
    event.summary = name + " (#{model.size})"
    event.description = text_details
    event
  end

  def tournament_events_count
    model.tournament_events.count
  end

  def icon_class
    'chess'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'recurring-tournament' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

  def link(options = {})
    super({label: name_with_logo(64)}.merge(options))
  end

  def discord_guild_icon_image_url(size = nil)
    return nil if model.discord_guild.nil?
    model.discord_guild.decorate.icon_image_url(size)
  end

  def discord_guild_icon_image_tag(size = nil, options = {})
    url = discord_guild_icon_image_url(size)
    return nil if url.blank?
    h.image_tag_with_max_size url, options.merge(class: 'avatar')
  end

  def name_with_logo(size = nil, options = {})
    [
      discord_guild_icon_image_tag(size, options),
      name
    ].join('&nbsp;').html_safe
  end

end
