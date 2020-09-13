module MapsHelper

  def players_map(players, map_options: {})
    markers = []
    players.each do |player|
      player.locations.geocoded.each do |location|
        marker = {
          latlng: [
            location.latitude,
            location.longitude
          ],
          popup: link_to(player.name, player)
        }
        markers << marker
      end
    end

    france_map markers, map_options || {}
  end

  def locations_map(locations, map_options: {})
    markers = []
    locations.geocoded.each do |location|
      marker = {
        latlng: [
          location.latitude,
          location.longitude
        ],
        popup: link_to(location.name, [:admin, location])
      }
      markers << marker
    end

    france_map markers, map_options || {}
  end

  private

  def france_map(markers, options = {})
    args = {
      center: {
        latlng: [46.71109, 1.7191036],
        zoom: 6
      },
      markers: markers
    }.deep_merge(options)
    map args
  end

end
