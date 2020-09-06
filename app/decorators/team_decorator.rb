class TeamDecorator < BaseDecorator

  def full_name
    "#{name} (#{short_name})"
  end

  def full_name_with_logo(options)
    [
      logo_image_tag(options),
      full_name
    ].join('&nbsp;').html_safe
  end

  def players_count
    model.players.count
  end

  def icon_class
    :users
  end

  def logo_image_tag(options)
    return nil if model.logo_url.blank?
    h.image_tag_with_max_size model.logo_url, options.merge(class: 'avatar')
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'character' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
