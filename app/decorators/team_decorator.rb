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
    h.link_to players_count, players_path
  end

  def players_count
    model.players.count
  end

  def icon_class
    :users
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'character' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
