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

end
