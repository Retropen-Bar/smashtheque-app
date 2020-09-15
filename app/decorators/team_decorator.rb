class TeamDecorator < BaseDecorator

  def full_name
    "#{name} (#{short_name})"
  end

  def full_name_with_logo(options)
    [
      if model.logo_url.blank?
        default_logo_image_tag(options)
      else
        logo_image_tag(options)
      end,
      full_name
    ].join('&nbsp;').html_safe
  end

  def short_name_with_logo(options)
    [
      if model.logo_url.blank?
        default_logo_image_tag(options)
      else
        logo_image_tag(options)
      end,
      short_name
    ].join('&nbsp;').html_safe
  end

  def autocomplete_name
    full_name
  end

  def listing_name
   full_name
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

  def default_logo_image_tag(options)
    h.image_tag_with_max_size 'default-team-logo.png', options.merge(class: 'avatar')
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'character' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
