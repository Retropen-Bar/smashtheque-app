class PlayerDecorator < BaseDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
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

  def name_with_avatar(size: nil, with_teams: false)
    txt = [name]
    if with_teams
      txt = teams.map(&:short_name) + txt
    end
    [
      avatar_tag(size),
      txt.join('&nbsp;|&nbsp;')
    ].join('&nbsp;').html_safe
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.jpg', width: size, class: :avatar
  end

  def map_popup
    h.content_tag :div, class: 'map-popup-player' do
      h.link_to model, class: 'player' do
        [
          name_with_avatar(size: 64),
          (
            h.content_tag :div, class: 'player-characters' do
              model.characters.map do |character|
                character.decorate.emoji_image_tag(max_height: 32)
              end.join('&nbsp;').html_safe
            end
          )
        ].join('<br/>').html_safe
      end
    end
    # <h5 class="card-title">
    #   <% player.teams.each do |team| %>
    #     <div class="player-team">
    #       <%= link_to team.decorate.short_name_with_logo(max_width: 32, max_height: 32), team, class: 'text-muted' %>
    #     </div>
    #   <% end %>
    #   <%= link_to player.decorate.name_with_avatar(size: 64), player %>
    # </h5>
    # <% player.locations.each do |location| %>
    #   <div class="player-location">
    #     <i class="fas fa-map-marker-alt"></i>
    #     <%= link_to location.name.titleize, location_path(location) %>
    #   </div>
    # <% end %>
    # <% player.characters.each do |character| %>
    #   <%= link_to character.decorate.emoji_image_tag(max_height: '32px'), character %>
    # <% end %>
  end

  def ban_status
    if model.is_banned?
      h.content_tag :span,
                    'oui',
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

  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS}.png",
        options
      ),
      h.number_with_delimiter(points)
    ].join('&nbsp;').html_safe
  end

  def link(options = {})
    avatar_size = options.delete(:avatar_size) || 32
    if model.is_legit?
      super({label: name_with_avatar(size: avatar_size)}.merge(options))
    else
      [
        default_avatar(avatar_size),
        '-'
      ].join('&nbsp;').html_safe
    end
  end

  def name_and_old_names
    result = name
    if old_names.any?
      result += " (aka #{old_names.reverse.join(', ')})"
    end
    result
  end

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name_and_old_names
      end
    end
  end

  def best_rewards_badges(options = {})
    best_rewards.map do |reward|
      reward.decorate.badge(options.clone)
    end
  end

  def unique_rewards_badges(options = {})
    unique_rewards.ordered_by_level.decorate.map do |reward|
      reward.badge(options.clone)
    end
  end

  def discord_badge(options = {})
    discord_user&.decorate&.discord_badge(options)
  end

end
