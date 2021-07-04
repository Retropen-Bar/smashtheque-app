import L from "leaflet"
import "leaflet.markercluster"
import "leaflet.featuregroup.subgroup"

// fix marker images
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});

// ----------------------------------------------------------------------------
// HELPERS
// ----------------------------------------------------------------------------

let toggleMapLayer = function(element, map_id, layer_id) {
  console.log('toggleMapLayer', element, map_id, layer_id);
  let map = window.maps[map_id].map,
      layer = window.maps[map_id].layers[layer_id];
  if(map.hasLayer(layer)) {
    layer.remove();
    $(element).removeClass('layer-visible').addClass('layer-hidden');
  } else {
    layer.addTo(map);
    $(element).removeClass('layer-hidden').addClass('layer-visible');
  }
};

let toggleMapLayerElement = function(element) {
  // console.log('toggleMapLayerElement', element);
  let $element = $(element),
      map_id = $element.attr('data-map'),
      layer_id = $element.attr('data-layer');
  toggleMapLayer(element, map_id, layer_id);
};

let toggleAllMapLayers = function(element, map_id, show) {
  // console.log('toggleAllMapLayers', element, map_id, show);
  let map = window.maps[map_id].map,
      layers = window.maps[map_id].layers;
  for(layer_id in layers) {
    let layer = layers[layer_id],
        $layerElement = $('.layer[data-map="' + map_id + '"][data-layer="' + layer_id + '"]').first();
    if(show && !map.hasLayer(layer)) {
      layer.addTo(map);
      $layerElement.removeClass('layer-hidden').addClass('layer-visible');
    }
    if(!show && map.hasLayer(layer)) {
      layer.remove();
      $layerElement.removeClass('layer-visible').addClass('layer-hidden');
    }
  }
};

let toggleAllMapLayersElements = function(element, show) {
  // console.log('toggleAllMapLayersElements', element);
  let $element = $(element),
      map_id = $element.attr('data-map');
  toggleAllMapLayers(element, map_id, show);
};

let toggleLayersMenu = function(element) {
  let $element = $(element);
  $element.closest('.layers').toggleClass('expanded');
};

let openMapModal = function(url) {
  $.get(url, function(html) {
    $('#map-modal').html(html).modal();
  });
};

$(document).on('click', '.layer[data-map][data-layer]', function(e) {
  toggleMapLayerElement(e.currentTarget);
  return false;
});

$(document).on('click', '.layer-show-all[data-map]', function(e) {
  toggleAllMapLayersElements(e.currentTarget, true);
  return false;
});

$(document).on('click', '.layer-hide-all[data-map]', function(e) {
  toggleAllMapLayersElements(e.currentTarget, false);
  return false;
});

$(document).on('click', '.layers .layers-title', function(e) {
  toggleLayersMenu(e.currentTarget);
  return false;
});

window.maps = {};
window.openMapModal = openMapModal;






var createMap = function(options) {
  // console.log('createMap', options);
  var container_id = options.container_id,
      map_options = options.map_options,
      center = options.center,
      map_icons = options.icons,
      layers_markers = options.layers_markers,
      tile_layer = options.tile_layer,
      attribution = options.attribution,
      max_zoom = options.max_zoom,
      tile_options = options.tile_options;

  var map = L.map(container_id, map_options);
  window.maps[container_id] = { map: map };
  map.setView(center.latlng, center.zoom);

  var icons = {};
  Object.keys(map_icons).forEach(function(icon_id) {
    var map_icon = map_icons[icon_id];
    icons[icon_id] = L.icon({
      iconUrl: map_icon.icon_url,
      iconSize: map_icon.icon_size,
      iconAnchor: map_icon.icon_anchor,
      className: map_icon.class_name
    });
  });

  var markers = L.markerClusterGroup({
    showCoverageOnHover: false,
    zoomToBoundsOnClick: true,
    removeOutsideVisibleBounds: true
  });
  var layers = {};
  var marker;

  Object.keys(layers_markers).forEach(function(layer_id) {
    var layer_markers = layers_markers[layer_id];
    layers[layer_id] = L.featureGroup.subGroup(markers, []).addTo(map);

    Object.keys(layer_markers).forEach(function(idx) {
      var layer_marker = layer_markers[idx];
      if(layer_marker.icon) {
        marker = L.marker(layer_marker.latlng, { icon: icons[layer_marker.icon] });
      } else {
        marker = L.marker(layer_marker.latlng);
      }
      marker.addTo(layers[layer_id]);

      if(layer_marker.popup) {
        marker.bindPopup(layer_marker.popup);
      } else {
        if(layer_marker.modal_url) {
          marker.on('click', function(ev) {
            openMapModal(layer_marker.modal_url);
          });
        }
      }
    });
  });
  window.maps[container_id].layers = layers;

  L.tileLayer(tile_layer, $.extend({
    attribution: attribution,
    maxZoom: max_zoom
  }, tile_options)).addTo(map);

  markers.addTo(map);
};

const DATA_KEY = 'data-url';

var init = function() {
  $('.map-container[' + DATA_KEY + ']').each(function() {
    var url = $(this).attr(DATA_KEY);
    $.getJSON(url, function(data) {
      createMap(data);
    });
  });
};

$(document).ready(init);
