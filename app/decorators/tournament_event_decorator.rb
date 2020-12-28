class TournamentEventDecorator < BaseDecorator

  def name_with_logo(size = nil, options = {})
    [
      recurring_tournament.decorate.discord_guild_icon_image_tag(size, options),
      name
    ].join('&nbsp;').html_safe
  end

  def link(options = {})
    super({label: name_with_logo(64)}.merge(options))
  end

  def recurring_tournament_link
    recurring_tournament.decorate.link
  end

  def bracket_link
    return nil if bracket_url.blank?
    h.link_to bracket_url, bracket_url, target: '_blank'
  end

  def bracket_icon
    if bracket_url.starts_with?('https://smash.gg/')
      return h.image_tag('https://smash.gg/images/gg-app-icon.png', height: 32)
    end
    if bracket_url.starts_with?('https://braacket.com/')
      return h.image_tag('https://braacket.com/favicon.ico', height: 32)
    end
    if bracket_url.starts_with?('https://challonge.com/')
      return h.image_tag('https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg', height: 32)
    end
    '🔗'
  end

  def bracket_icon_link
    return nil if bracket_url.blank?
    h.link_to bracket_icon, bracket_url, target: '_blank', class: 'text-decoration-none'
  end

  def graph_image_tag(options = {})
    return nil unless model.graph.attached?
    url = model.graph.service_url
    h.image_tag_with_max_size url, options
  end

  def player_rank(player_id)
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      return player_name if send("#{player_name}_id") == player_id
    end
    nil
  end

  def player_rank_name(player_id)
    player_name = player_rank(player_id)
    if player_name
      TournamentEvent.human_attribute_name("rank.#{player_name}")
    else
      nil
    end
  end

  def icon_class
    'chess-knight'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'tournament-event' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

  def previous_tournament_event_link(options = {})
    tournament_event = previous_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def next_tournament_event_link(options = {})
    tournament_event = next_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

end
