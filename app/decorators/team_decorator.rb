class TeamDecorator < BaseDecorator

  def admin_link(options = {})
    super(options.merge(label: full_name))
  end

  def full_name
    "#{name} (#{short_name})"
  end

  def players_path
    admin_players_path(q: {team_id_in: [model.id]})
  end

  def players_link
    h.link_to (players_count || 0), players_path
  end

end
