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

  def short_level_text
    RecurringTournament.human_attribute_name("level.#{model.level}").first
  end

  def self.size_name(size)
    size && (size > 128 ? '128+' : size)
  end

  def size_or_real_size
    tournament_events_count > 4 ? (real_size || size) : size
  end

  def real_size
    counts = tournament_events.order(date: :desc).limit(5).pluck(:participants_count).compact
    return nil if counts.empty?

    "~ #{(counts.sum / counts.size.to_f).round(0)}"
  end

  def recurring_type_text
    RecurringTournament.human_attribute_name("recurring_type.#{model.recurring_type}")
  end

  def wday_text
    I18n.t('date.day_names')[model.wday].titlecase
  end

  def has_starts_at?
    model.is_recurring? && !(model.starts_at_hour || 0).zero?
  end

  def starts_at(timezone: RecurringTournament::STARTS_AT_TIMEZONE)
    "#{starts_at_hour_in_time_zone(timezone)}h#{(starts_at_min || '').to_s.rjust(2, '0')}"
  end

  def full_date
    if model.is_recurring?
      "#{wday_text} à #{starts_at} (FR)"
    else
      model.date_description
    end
  end

  def date_on_week(monday)
    # in the future, we might need to allow different timezones
    d = monday.beginning_of_week + ((model.wday + 6) % 7)
    DateTime.new(
      d.year, d.month, d.day,
      starts_at_hour, starts_at_min
    ) - d.in_time_zone(RecurringTournament::STARTS_AT_TIMEZONE.name).utc_offset.seconds
  end

  def duration
    1.hour
  end

  def as_event(week_start:)
    start = date_on_week(week_start)
    classes = [
      "level--#{model.level}"
    ]
    {
      id: model.id,
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
    start = date_on_week(Date.today)
    start += 1.week if start < Date.today

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

  def duo_tournament_events_count
    model.duo_tournament_events.count
  end

  def all_events_count
    tournament_events_count + duo_tournament_events_count
  end

  def icon_class
    'chess'
  end

  def as_autocomplete_result
    h.tag.div class: 'recurring-tournament' do
      h.tag.div class: :name do
        name
      end
    end
  end

  def link(options = {})
    super({ label: name_with_logo(max_width: 64, max_height: 64) }.merge(options))
  end

  def tournament_events_path
    h.tournament_events_path(by_recurring_tournament_id: model.id)
  end

  def duo_tournament_events_path
    h.duo_tournament_events_path(by_recurring_tournament_id: model.id)
  end

  def any_image_url
    logo_url.presence || discord_guild_icon_image_url || default_logo_image_url
  end

  def any_image_tag(options = {})
    classes = ['avatar', options.delete(:class)]
    h.image_tag_with_max_size any_image_url, options.merge(class: classes.join(' '))
  end

  def logo_image_tag(options = {})
    return nil unless model.logo.attached?

    h.image_tag_with_max_size logo_url, options.merge(class: 'avatar')
  end

  def discord_guild_icon_image_url(size = nil)
    return nil if model.discord_guild.nil?

    model.discord_guild.decorate.icon_image_url(size)
  end

  def discord_guild_icon_image_tag(size = nil, options = {})
    url = discord_guild_icon_image_url
    return nil if url.blank?

    h.image_tag_with_max_size url,
                              {
                                max_width: size,
                                max_height: size,
                                class: 'avatar'
                              }.merge(options)
  end

  def default_logo_image_url
    @@default_logo_image_url ||= h.image_url('smash.svg')
  end

  def name_with_logo(options = {})
    [
      any_image_tag(options),
      name
    ].join('&nbsp;').html_safe
  end

  def full_address
    [
      address_name,
      address
    ].reject(&:blank?).join('<br/>')
  end

  def badges
    (
      '' + (
        if is_online?
          h.tag.span 'Online', class: 'badge badge-info'
        else
          h.tag.span 'Offline', class: 'badge badge-success'
        end
      ) + ' ' + (
        h.tag.span  level_text,
                    class: 'badge',
                    style: "background-color: #{self.class.level_color(model.level)}; color: white"
      )
    ).html_safe
  end

  def archived_badge
    h.tag.span(class: 'badge badge-with-icon badge-warning') do
      [
        h.svg_icon_tag(:warning, class: 'mr-0 mr-sm-1'),
        '<span class="d-none d-sm-inline">En pause</span>'
      ].join(' ').html_safe
    end
  end

  def badges_v2(with_level: false, with_online: true)
    [
      with_online && !is_online? && h.tag.span(class: 'badge badge-with-icon badge-primary') do
        [
          h.svg_icon_tag(:offline, class: 'mr-0 mr-sm-1'),
          '<span class="d-none d-sm-inline">Offline</span>'
        ].join(' ').html_safe
      end,
      with_online && is_online? && h.tag.span(class: 'badge badge-with-icon badge-primary') do
        [
          h.svg_icon_tag(:online, class: 'mr-0 mr-sm-1'),
          '<span class="d-none d-sm-inline">Online</span>'
        ].join(' ').html_safe
      end,
      with_level && h.tag.span(class: "badge level--#{model.level}") do
        RecurringTournament.human_attribute_name("level.#{model.level}")
      end
    ].reject(&:blank?).join(' ').html_safe
  end

  def level
    h.tag.span(class: "level level--#{model.level}") do
      h.tag.span(class: 'sr-only') do
        RecurringTournament.human_attribute_name("level.#{model.level}")
      end
    end
  end

  def formatted_registration
    registration&.to_s
  end

  def formatted_misc
    misc.to_s
  end

  def formatted_lagtest
    lagtest.to_s
  end

  def formatted_ruleset
    ruleset.to_s
  end

  def country_flag(options = {})
    return nil if countrycode.blank?

    h.flag_icon_tag(countrycode, options)
  end
end
