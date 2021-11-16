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
    h.tag.div class: 'community' do
      h.tag.div class: :name do
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

  def any_non_default_image_url
    logo_url.presence || first_discord_guild_icon_image_url
  end

  def avatar_tag(size = nil)
    h.image_tag 's.gif',
                class: 'avatar',
                style: [
                  "background-image: url(\"#{any_image_url}\")",
                  'background-size: cover',
                  "width: #{size}px",
                  "height: #{size}px"
                ].join(';')
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
    @@default_logo_image_url ||= h.image_url('default-community-logo.png')
  end

  def name_with_logo(options = {})
    [
      avatar_tag(options[:max_height]),
      name
    ].join('&nbsp;').html_safe
  end
end
