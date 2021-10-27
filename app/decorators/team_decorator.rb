class TeamDecorator < BaseDecorator
  include HasTrackRecordsDecorator

  def full_name
    "#{name} (#{short_name})"
  end

  def full_name_with_logo(options = {})
    [
      logo_image_tag(options),
      full_name
    ].join('&nbsp;').html_safe
  end

  def short_name_with_logo(options = {})
    [
      logo_image_tag(options),
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
                  "background-image: url(\"#{any_non_default_image_url}\"), url(\"#{default_logo_image_url}\")",
                  'background-size: cover',
                  "width: #{size}px",
                  "height: #{size}px"
                ].join(';')
  end

  def logo_image_tag(options = {})
    return nil unless model.logo.attached?

    h.image_tag_with_max_size logo_url, options.merge(class: 'avatar')
  end

  def first_discord_guild_icon_image_url(size = nil)
    return nil if model.first_discord_guild.nil?

    model.first_discord_guild.decorate.icon_image_url(size)
  end

  def default_logo_image_url
    @@default_logo_image_url ||= h.image_url('default-team-logo.png')
  end

  def roster_image_tag(options = {})
    return nil unless model.roster.attached?

    url = model.roster.service_url
    h.image_tag_with_max_size url, options
  end

  def discord_url
    model.first_discord_guild&.invitation_url
  end

  def as_autocomplete_result
    h.tag.div class: 'team' do
      h.tag.div class: :name do
        full_name
      end
    end
  end

  def link(options = {})
    super({ label: short_name_with_logo(max_width: 32, max_height: 32) }.merge(options))
  end

  def badges
    [
      is_offline? && h.tag.span(class: 'badge badge-with-icon badge-primary') do
        [
          h.svg_icon_tag(:offline, class: 'mr-0 mr-sm-1'),
          '<span class="d-none d-sm-inline">Offline</span>'
        ].join(' ').html_safe
      end,
      is_online? && h.tag.span(class: 'badge badge-with-icon badge-primary') do
        [
          h.svg_icon_tag(:online, class: 'mr-0 mr-sm-1'),
          '<span class="d-none d-sm-inline">Online</span>'
        ].join(' ').html_safe
      end,
      is_sponsor? && h.tag.span(class: 'badge badge-with-icon badge-primary') do
        [
          h.svg_icon_tag(:sponsor, class: 'mr-0 mr-sm-1'),
          '<span class="d-none d-sm-inline">Sponsor</span>'
        ].join(' ').html_safe
      end
    ].reject(&:blank?).join(' ').html_safe
  end

  def website_link
    h.link_to website_url, website_url, target: '_blank', rel: :noopener
  end

  def formatted_recruiting_details
    recruiting_details.to_s
  end

  def formatted_description
    description.to_s
  end
end
