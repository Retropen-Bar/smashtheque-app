class LocationDecorator < BaseDecorator

  def pretty_name
    model.name.titleize
  end

  def full_name(separator = '&nbsp;')
    [model.icon, pretty_name].reject(&:blank?).join(separator).html_safe
  end

  def autocomplete_name
    full_name
  end

  def players_count
    model.players.count
  end

  def icon_class
    'map-marker-alt'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'location' do
      h.content_tag :div, class: :name do
        pretty_name
      end
    end
  end

end
