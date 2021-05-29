class CommunityDecorator < BaseDecorator

  def autocomplete_name
    name
  end

  def listing_name
   name
  end

  def players_count
    model.players.count
  end

  def icon_class
    'map-marker-alt'
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'community' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

  def path
    community_path(model)
  end

  def any_image_url
    logo_url.presence || first_discord_guild_icon_image_url || default_logo_image_url
  end

  def any_image_tag(options = {})
    h.image_tag_with_max_size any_image_url, options.merge(class: 'avatar')
  end

  def logo_image_tag(options = {})
    return nil unless model.logo.attached?
    url = model.logo.service_url
    h.image_tag_with_max_size url, options.merge(class: 'avatar')
  end

  def first_discord_guild_icon_image_url(size = nil)
    return nil if model.first_discord_guild.nil?
    model.first_discord_guild.decorate.icon_image_url(size)
  end

  def default_logo_image_url
    'default-community-logo.png'
  end

  def name_with_logo(options = {})
    [
      any_image_tag(options),
      name
    ].join('&nbsp;').html_safe
  end

end
