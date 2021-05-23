class TournamentEventBaseDecorator < BaseDecorator
  def name_with_logo(size = nil, options = {})
    [
      recurring_tournament&.decorate&.discord_guild_icon_image_tag(size, options),
      name
    ].compact.join('&nbsp;').html_safe
  end

  def full_name
    [
      recurring_tournament&.name,
      name
    ].reject(&:blank?).join(' : ')
  end

  def link(options = {})
    super({ label: name_with_logo(64) }.merge(options))
  end

  def recurring_tournament_link
    recurring_tournament&.decorate&.link
  end

  def bracket_link
    return nil if bracket_url.blank?

    h.link_to bracket_url, bracket_url, target: '_blank', rel: :noopener
  end

  def bracket_icon
    return h.image_tag('https://smash.gg/images/gg-app-icon.png', height: 32) if is_on_smashgg?
    return h.image_tag('https://braacket.com/favicon.ico', height: 32) if is_on_braacket?

    if is_on_challonge?
      return h.image_tag(
        'https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg',
        height: 32
      )
    end

    '🔗'
  end

  def bracket_icon_link(options = {})
    return nil if bracket_url.blank?

    h.link_to bracket_icon, bracket_url, { target: '_blank' }.merge(options)
  end

  def graph_image_tag(options = {})
    return nil unless model.graph.attached?

    url = model.graph.service_url
    h.image_tag_with_max_size url, options
  end

  def icon_class
    'chess-knight'
  end

  def as_ical_event
    event = Icalendar::Event.new
    event.dtstart = Icalendar::Values::Date.new(date)
    event.summary = name
    event.description = full_name
    event
  end

  def first_event_link(options = {})
    event = first_event
    if event
      event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def previous_event_link(options = {})
    event = previous_event
    if event
      event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def next_event_link(options = {})
    event = next_event
    if event
      event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def last_event_link(options = {})
    event = last_event
    if event
      event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end
end
