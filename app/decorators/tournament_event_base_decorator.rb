class TournamentEventBaseDecorator < BaseDecorator
  def default_logo_image_url
    @@default_logo_image_url ||= h.image_url('smash.svg')
  end

  def any_image_url
    recurring_tournament&.decorate&.any_image_url || default_logo_image_url
  end

  def any_image_tag(options = {})
    classes = ['avatar', options.delete(:class)]
    h.image_tag_with_max_size any_image_url, options.merge(class: classes.join(' '))
  end

  def name_with_logo(options = {})
    [
      any_image_tag(options),
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
    super({ label: name_with_logo(max_width: 64, max_height: 64) }.merge(options))
  end

  def recurring_tournament_link(options = {})
    recurring_tournament&.decorate&.link(options)
  end

  def bracket_link
    return nil if bracket_url.blank?

    h.link_to bracket_url, bracket_url, target: '_blank', rel: :noopener
  end

  def bracket_icon(options = {})
    puts '====='
    puts options.inspect
    puts '====='
    height = 32 || options.delete(:height)
    options&.merge(height: height)
    return h.image_tag('https://smash.gg/images/gg-app-icon.png', options) if is_on_smashgg?
    return h.image_tag('https://braacket.com/favicon.ico', options) if is_on_braacket?

    if is_on_challonge?
      return h.image_tag(
        'https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg',
        options
      )
    end

    return h.svg_icon_tag(:bracket, options)
  end

  def bracket_icon_link(options = {})
    return nil if bracket_url.blank?

    link_content = bracket_icon(options.delete(:backet_icon_options) || {})
    link_text = options.delete(:text) || ''

    link_content = [
      link_content,
      link_text
    ].join('&nbsp;').html_safe unless link_text.blank?

    h.link_to link_content, bracket_url, { target: '_blank', rel: :noopener }.merge(options)
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
    event_link first_event, options
  end

  def previous_event_link(options = {})
    event_link previous_event, options
  end

  def next_event_link(options = {})
    event_link next_event, options
  end

  def last_event_link(options = {})
    event_link last_event, options
  end

  private

  def event_link(event, options = {})
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
