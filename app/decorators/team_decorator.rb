class TeamDecorator < BaseDecorator

  def full_name
    "#{name} (#{short_name})"
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
