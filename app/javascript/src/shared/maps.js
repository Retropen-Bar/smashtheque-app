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
