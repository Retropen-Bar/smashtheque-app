class PlayerDecorator < BaseDecorator
  include HasTrackRecordsDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
  end

  def name_with_teams
    (teams.map(&:short_name) + [name]).join('&nbsp;|&nbsp;')
  end

  def avatar_tag(size)
    # option 1: DiscordUser
    if user && user.discord_user && !user.discord_user.avatar.blank?
      return user.discord_user.decorate.avatar_tag(size)
    end
    # option 2: SmashggUser
    smashgg_users.each do |smashgg_user|
      unless smashgg_user.avatar_url.blank?
        return smashgg_user.decorate.any_image_tag(size: size)
      end
    end
    # default
    default_avatar(size)
  end

  def any_image_url
    # option 1: DiscordUser
    if user && user.discord_user && !user.discord_user.avatar.blank?
      return user.discord_user.decorate.avatar_url
    end
    # option 2: SmashggUser
    smashgg_users.each do |smashgg_user|
      next if smashgg_user.avatar_url.blank?

      return smashgg_user.decorate.any_image_url
    end
    # default
    h.image_url 'default-avatar.svg'
  end

  def name_with_avatar(size: nil, with_teams: false, with_old_names: false)
    txt = [with_old_names ? name_and_old_names : name]
    txt = teams.map(&:short_name) + txt if with_teams
    [
      avatar_tag(size),
      txt.join('&nbsp;|&nbsp;')
    ].join('&nbsp;').html_safe
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.svg', width: size, class: :avatar
  end

  def countrycode
    user&.decorate&.countrycode
  end

  def country_flag(options = {})
    user&.decorate&.country_flag(options)
  end

  def ban_status
    if model.is_banned?
      h.tag.span  'oui',
                  class: 'status_tag yes',
                  title: model.ban_details,
                  data: { tooltip: {} }
    else
      arbre do
        status_tag :no
      end
    end
  end

  def icon_class
    :user
  end

  def link(options = {})
    avatar_size = options.delete(:avatar_size) || 32
    if model.is_legit?
      super({ label: name_with_avatar(size: avatar_size) }.merge(options))
    else
      [
        default_avatar(avatar_size),
        '-'
      ].join('&nbsp;').html_safe
    end
  end

  def name_and_old_names(with_teams: false)
    result = with_teams ? name_with_teams : name
    result += " (aka #{old_names.reverse.join(', ')})" if old_names.any?
    result
  end

  def name_and_old_names_and_main(with_teams: false)
    result = name_and_old_names(with_teams: with_teams)
    characters.first(5).each do |character|
      result += " #{character.decorate.emoji_image_tag(max_height: 20)}"
    end
    result.html_safe
  end

  def as_autocomplete_result
    h.tag.div class: :player do
      h.tag.div class: :name do
        name_and_old_names_and_main(with_teams: true)
      end
    end
  end

  def discord_badge(options = {})
    discord_user&.decorate&.discord_badge(options)
  end
end
