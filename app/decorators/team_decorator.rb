class TeamDecorator < BaseDecorator

  def full_name
    "#{name} (#{short_name})"
  end

  def full_name_with_logo(options)
    [
      any_image_tag(options),
      full_name
    ].join('&nbsp;').html_safe
  end

  def short_name_with_logo(options)
    [
      any_image_tag(options),
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

  def logo_url
    return nil unless model.logo.attached?
    model.logo.service_url
  end

  def any_image_url
    logo_url.presence || first_discord_guild_icon_image_url || default_logo_image_url
  end

  def any_image_tag(options)
    h.image_tag_with_max_size any_image_url, options.merge(class: 'avatar')
  end

  def logo_image_tag(options)
    return nil unless model.logo.attached?
    url = model.logo.service_url
    h.image_tag_with_max_size url, options.merge(class: 'avatar')
  end

  def first_discord_guild_icon_image_url(size = nil)
    return nil if model.first_discord_guild.nil?
    model.first_discord_guild.decorate.icon_image_url(size)
  end

  def default_logo_image_url
    'default-team-logo.png'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'character' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
