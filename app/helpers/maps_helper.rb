module MapsHelper
  def players_map(players, with_seconds, map_options: {}, &block)
    icons = {}
    markers = {}
    layers = {}
    players.with_address.each do |player|
      player.user.addresses.each do |address|
        player.characters.each_with_index do |character, idx|
          next if idx > 0 && !with_seconds

          icons[character.id.to_s] ||= {
            icon_url: character.decorate.emoji_image_url,
            icon_size: 32,
            icon_anchor: [16, 16]
          }
          layers[character.id.to_s] ||= {
            name: character.decorate.emoji_and_name(
              max_width: 32,
              max_height: 32
            ),
            position: character.name.downcase
          }
          markers[character.id.to_s] ||= []
          markers[character.id.to_s] << {
            icon: character.id.to_s,
            latlng: [
              address[:latitude],
              address[:longitude]
            ],
            modal_url: modal_player_path(player)
          }
        end
      end
    end

    france_map  markers: markers,
                layers: layers,
                icons: icons,
                options: map_options || {},
                &block
  end

  def communities_map(communities, map_options: {})
    markers = { all: [] }
    icons = {}
    communities.geocoded.each do |community|
      icons[community.id.to_s] ||= {
        icon_url: community.decorate.any_image_url,
        icon_size: 32,
        icon_anchor: [16, 16],
        class_name: 'avatar-icon'
      }
      marker = {
        icon: community.id.to_s,
        latlng: [
          community.latitude,
          community.longitude
        ],
        popup: link_to(community.name, community)
      }
      markers[:all] << marker
    end

    france_map  markers: markers,
                icons: icons,
                options: {
                  cluster_markers: false
                }.merge(map_options || {})
  end

  def recurring_tournaments_map(recurring_tournaments, map_options: {}, &block)
    markers = { all: [] }
    icons = {}
    recurring_tournaments.geocoded.each do |recurring_tournament|
      icons[recurring_tournament.id.to_s] ||= {
        icon_url: recurring_tournament.decorate.any_image_url,
        icon_size: 32,
        icon_anchor: [16, 16],
        class_name: 'avatar-icon'
      }
      marker = {
        icon: recurring_tournament.id.to_s,
        latlng: [
          recurring_tournament.latitude,
          recurring_tournament.longitude
        ],
        modal_url: modal_recurring_tournament_path(recurring_tournament)
      }
      markers[:all] << marker
    end

    france_map  markers: markers,
                icons: icons,
                options: map_options || {},
                &block
  end

  def user_addresses_map(user, map_options: {})
    markers = {
      all: user.addresses.map do |address|
        {
          latlng: [
            address[:latitude],
            address[:longitude]
          ],
          popup: address[:name]
        }
      end
    }

    france_map  markers: markers,
                options: map_options || {}
  end

  def single_address_map(address, map_options: {})
    markers = {
      all: [
        {
          latlng: [
            address[:latitude],
            address[:longitude]
          ],
          popup: address[:name]
        }
      ]
    }

    france_map  markers: markers,
                options: map_options || {}
  end

  private

  def france_map(markers:, layers: {}, icons: {}, options: {}, &block)
    options = {
      # attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      center: {
        latlng: [46.71109, 1.7191036],
        zoom: 6
      },
      container_id: 'map',
      max_zoom: 18,
      tile_layer: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    }.deep_merge(options)

    tile_layer = options.delete(:tile_layer)
    # attribution = options.delete(:attribution)
    max_zoom = options.delete(:max_zoom)
    container_id = options.delete(:container_id)
    center = options.delete(:center)
    cluster_markers = options.delete(:cluster_markers)

    html_content = block_given? && capture(&block)

    render_map  markers: markers,
                layers: layers,
                icons: prep_icons_settings(icons),
                options: options,
                tile_layer: tile_layer,
                attribution: nil,#attribution,
                max_zoom: max_zoom,
                container_id: container_id,
                center: center,
                cluster_markers: cluster_markers,
                html_content: html_content
  end

  def prep_icon_settings(settings)
    settings[:name] = 'icon' if settings[:name].nil? || settings[:name].blank?
    settings[:shadow_url] = '' if settings[:shadow_url].nil?
    settings[:icon_size] = [] if settings[:icon_size].nil?
    settings[:shadow_size] = [] if settings[:shadow_size].nil?
    settings[:icon_anchor] = [0, 0] if settings[:icon_anchor].nil?
    settings[:shadow_anchor] = [0, 0] if settings[:shadow_anchor].nil?
    settings[:popup_anchor] = [0, 0] if settings[:popup_anchor].nil?
    settings
  end

  def prep_icons_settings(icons)
    icons.map do |id, settings|
      [id, prep_icon_settings(settings)]
    end.to_h
  end
end
