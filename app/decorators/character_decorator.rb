class CharacterDecorator < BaseDecorator

  def full_name
    [model.icon, model.name].join
  end

  def players_path
    admin_players_path(q: {character_id_in: [model.id]})
  end

  def players_link
    h.link_to (players_count || 0), players_path
  end

end
