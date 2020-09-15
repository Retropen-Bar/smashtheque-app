module MapsHelper

  def players_map(players, map_options: {})
    icons = {}
    markers = {}
    layers = {}
    players.each do |player|
      # player.locations already exists, so don't use the .geocoded scope
      player.locations.each do |location|
        next unless location.is_geocoded?
        main_character = player.characters.first
        next if main_character.nil?
        icons[main_character.id.to_s] ||= {
          icon_url: main_character.decorate.emoji_image_url,
          icon_size: 32,
          icon_anchor: [16, 16]
        }
        layers[main_character.id.to_s] ||= {
          name: main_character.decorate.full_name(
            max_width: 32,
            max_height: 32
          )
        }
        markers[main_character.id.to_s] ||= []
        markers[main_character.id.to_s] << {
          icon: main_character.id.to_s,
          latlng: [
            location.latitude,
            location.longitude
          ],
          popup: link_to(player.name, player)
        }
      end
    end

    france_map  markers: markers,
                layers: layers,
                icons: icons,
                options: map_options || {}
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

  private

  def france_map(markers:, layers: {}, icons: {}, options: {})
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

    output = []

    output << "<div class='map-container'>"
    output << "  <div class='map' id='#{container_id}'></div>"

    if layers.any?
      output << "  <div class='layers'>"
        layers.each do |layer_id, layer|
          output << "    <div class='layer layer-visible noselect' data-map='#{container_id}' data-layer='#{layer_id}'>"
          output << "      <span class='name'>#{layer[:name]}</span>"
          output << "    </div>"
        end
      output << "  </div>"
    end

    output << "</div>"

    output << "<script>"
    output << "var map = L.map('#{container_id}', {#{options.map{|k,v| "#{k}: #{v}"}.join(', ')}});"
    output << "window.maps['#{container_id}'] = {map: map};"
    output << "map.setView([#{center[:latlng][0]}, #{center[:latlng][1]}], #{center[:zoom]});"

    output << "var icons = {};"
    icons.each do |key, icon|
      icon_settings = prep_icon_settings(icon)
      output << "icons['#{key}'] = L.icon({iconUrl: '#{icon_settings[:icon_url]}', iconSize: #{icon_settings[:icon_size]}, iconAnchor: #{icon_settings[:icon_anchor]}});"
    end

    output << "var layers = {};"
    output << "var marker;"
    markers.each do |layer_id, layer_markers|
      output << "layers['#{layer_id}'] = L.layerGroup([]).addTo(map);"
      layer_markers.each_with_index do |marker, index|
        icon_param = marker[:icon].blank? ? '' : ", {icon: icons['#{marker[:icon]}']}"
        output << "marker = L.marker([#{marker[:latlng][0]}, #{marker[:latlng][1]}]#{icon_param}).addTo(layers['#{layer_id}']);"
        if marker[:popup]
          output << "marker.bindPopup('#{escape_javascript marker[:popup]}');"
        end
      end
    end
    output << "window.maps['#{container_id}'].layers = layers;"

    output << "L.tileLayer('#{tile_layer}', {
          attribution: '#{attribution}',
          maxZoom: #{max_zoom},"
    options.each do |key, value|
      output << "#{key.to_s.camelize(:lower)}: '#{value}',"
    end
    output << "}).addTo(map);"

    output << "</script>"
    output.join("\n").html_safe
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
