class CityDecorator < BaseDecorator

  def admin_link(options = {})
    super(options.merge(label: full_name))
  end

  def pretty_name
    model.name.titleize
  end

  def full_name(separator = '&nbsp;')
    [model.icon, pretty_name].join(separator).html_safe
  end

  def players_path
    admin_players_path(q: {city_id_in: [model.id]})
  end

  def players_link
    h.link_to players_count, players_path
  end

  def players_count
    model.players.count
  end

  def icon_class
    'map-marker-alt'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'city' do
      (
        h.content_tag :div, class: :icon do
          icon
        end
      ) + (
        h.content_tag :div, class: :name do
          pretty_name
        end
      )
    end
  end

end
