class PlayerDecorator < BaseDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
  end

  def avatar_tag(size)
    if model.discord_user && !model.discord_user.avatar.blank?
      model.discord_user.decorate.avatar_tag(size)
    else
      default_avatar(size)
    end
  end

  def name_with_avatar(size: nil)
    [
      avatar_tag(size),
      name
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

  def points_count
    [
      h.image_tag('https://cdn.discordapp.com/emojis/790632367487188993.png', height: 32),
      points
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

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
