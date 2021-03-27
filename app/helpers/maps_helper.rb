module MapsHelper

  def players_map(players, with_seconds, map_options: {}, &block)
    icons = {}
    markers = {}
    layers = {}
    players.each do |player|
      # player.locations already exists, so don't use the .geocoded scope
      player.locations.each do |location|
        next unless location.is_geocoded?
        player.characters.each_with_index do |character, idx|
          next if idx > 0 && !with_seconds
          icons[character.id.to_s] ||= {
            icon_url: character.decorate.emoji_image_url,
            icon_size: 32,
            icon_anchor: [16, 16]
          }
          layers[character.id.to_s] ||= {
            name: character.decorate.full_name(
              max_width: 32,
              max_height: 32
            ),
            position: character.name.downcase
          }
          markers[character.id.to_s] ||= []
          markers[character.id.to_s] << {
            icon: character.id.to_s,
            latlng: [
              location.latitude,
              location.longitude
            ],
            popup: player.decorate.map_popup
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

  def locations_map(locations, map_options: {})
    markers = {all: []}
    locations.geocoded.each do |location|
      marker = {
        latlng: [
          location.latitude,
          location.longitude
        ],
        popup: link_to(location.decorate.pretty_name, [:admin, location])
      }
      markers[:all] << marker
    end

    france_map  markers: markers,
                options: map_options || {}
  end

  def user_locations_map(user, map_options: {})
    markers = {all: []}
    if user.main_address
      markers[:all] << {
        latlng: [
          user.main_latitude,
          user.main_longitude
        ],
        popup: user.main_address
      }
    end
    if user.secondary_address
      markers[:all] << {
        latlng: [
          user.secondary_latitude,
          user.secondary_longitude
        ],
        popup: user.secondary_address
      }
    end

    france_map  markers: markers,
                options: map_options || {}
  end

  private

  def france_map(markers:, layers: {}, icons: {}, options: {}, &block)
    options = {
      attribution: Leaflet.attribution,
      center: {
        latlng: [46.71109, 1.7191036],
        zoom: 6
      },
      container_id: 'map',
      max_zoom: Leaflet.max_zoom,
      tile_layer: Leaflet.tile_layer
    }.deep_merge(options)

    tile_layer = options.delete(:tile_layer) || Leaflet.tile_layer
    attribution = options.delete(:attribution) || Leaflet.attribution
    max_zoom = options.delete(:max_zoom) || Leaflet.max_zoom
    container_id = options.delete(:container_id) || 'map'
    center = options.delete(:center)

    html_content = block_given? && capture(&block)

    render_map  markers: markers,
                layers: layers,
                icons: icons,
                options: options,
                tile_layer: tile_layer,
                attribution: nil,#attribution,
                max_zoom: max_zoom,
                container_id: container_id,
                center: center,
                html_content: html_content
  end

  def prep_icon_settings(settings)
    settings[:name] = 'icon' if settings[:name].nil? or settings[:name].blank?
    settings[:shadow_url] = '' if settings[:shadow_url].nil?
    settings[:icon_size] = [] if settings[:icon_size].nil?
    settings[:shadow_size] = [] if settings[:shadow_size].nil?
    settings[:icon_anchor] = [0, 0] if settings[:icon_anchor].nil?
    settings[:shadow_anchor] = [0, 0] if settings[:shadow_anchor].nil?
    settings[:popup_anchor] = [0, 0] if settings[:popup_anchor].nil?
    return settings
  end

end
