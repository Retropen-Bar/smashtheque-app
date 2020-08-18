class CharacterDecorator < BaseDecorator

  def admin_link(options = {})
    super(options.merge(label: full_name))
  end

  def full_name
    [model.icon, model.name].join
  end

  def players_path
    admin_players_path(q: {characters_players_character_id_in: [model.id]})
  end

  def players_link
    h.link_to players_count, players_path
  end

  def players_count
    model.players.count
  end

  def head_icon_tag(max_width: nil, max_height: nil)
    return nil if model.head_icon_url.blank?
    h.image_tag_with_max_size model.head_icon_url,
                              max_width: max_width,
                              max_height: max_height
  end

  def emoji_code
    return nil if model.emoji.blank?
    ":#{model.emoji}:"
  end


end
