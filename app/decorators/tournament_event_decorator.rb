class TournamentEventDecorator < BaseDecorator

  def name_with_logo(size = nil, options = {})
    [
      recurring_tournament.decorate.discord_guild_icon_image_tag(size, options),
      name
    ].join('&nbsp;').html_safe
  end

  def link
    h.link_to name_with_logo(64), model
  end

  def recurring_tournament_link
    recurring_tournament.decorate.link
  end

  def bracket_link
    return nil if bracket_url.blank?
    h.link_to bracket_url, bracket_url, target: '_blank'
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

end
