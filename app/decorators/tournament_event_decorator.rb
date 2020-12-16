class TournamentEventDecorator < BaseDecorator

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

end
