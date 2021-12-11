class UserDecorator < BaseDecorator
  def avatar_tag(size)
    if discord_user&.avatar&.present?
      discord_user.decorate.avatar_tag(size)
    else
      default_avatar(size)
    end
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.svg', width: size, class: :avatar
  end

  def avatar_and_name(size: nil)
    [
      avatar_tag(size),
      name
    ].join('&nbsp;').html_safe
  end

  def name_and_tag
    name_and_tag_string = h.content_tag(:span, name)
    name_and_tag_string += "&nbsp;|&nbsp;#{h.content_tag(:span, player.team_names.first)}".html_safe if player&.team_names&.first&.present?

    name_and_tag_string
  end

  def country_flag(options = {})
    countrycode = addresses&.first&.fetch(:countrycode)
    return nil if countrycode.blank?

    h.flag_icon_tag(countrycode, options)
  end

  def player_link(options = {})
    model.player.decorate.link(options)
  end

  def link(options = {})
    h.tag.span avatar_and_name(size: 32), **options
  end

  def created_players_count
    created_players.count
  end

  def coaching_link(options = {})
    return nil unless is_coach? || coaching_url.blank?

    h.link_to (options[:label] || 'Voir la page'),
              coaching_url,
              {
                target: '_blank',
                rel: :noopener
              }.merge(options)
  end

  def discord_badge(options = {})
    discord_user&.decorate&.discord_badge(options)
  end

  def main_address_with_coordinates
    return nil if main_address.blank?

    "#{main_address} (#{main_latitude}, #{main_longitude})"
  end

  def secondary_address_with_coordinates
    return nil if secondary_address.blank?

    "#{secondary_address} (#{secondary_latitude}, #{secondary_longitude})"
  end

  def main_country_name
    return nil if main_countrycode.blank?

    ISO3166::Country.new(main_countrycode)&.translation('fr')
  end

  def secondary_country_name
    return nil if secondary_countrycode.blank?

    ISO3166::Country.new(secondary_countrycode)&.translation('fr')
  end
end
