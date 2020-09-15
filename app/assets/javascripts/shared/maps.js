(function($) {

  var toggleMapLayer = function(element, map_id, layer_id) {
    console.log('toggleMapLayer', element, map_id, layer_id);
    var map = window.maps[map_id].map,
        layer = window.maps[map_id].layers[layer_id];
    if(map.hasLayer(layer)) {
      layer.remove();
      $(element).removeClass('layer-visible').addClass('layer-hidden');
    } else {
      layer.addTo(map);
      $(element).removeClass('layer-hidden').addClass('layer-visible');
    }
  };

  var toggleMapLayerElement = function(element) {
    // console.log('toggleMapLayerElement', element);
    var $element = $(element),
        map_id = $element.attr('data-map'),
        layer_id = $element.attr('data-layer');
    toggleMapLayer(element, map_id, layer_id);
  };

  var toggleAllMapLayers = function(element, map_id, show) {
    // console.log('toggleAllMapLayers', element, map_id, show);
    var map = window.maps[map_id].map,
        layers = window.maps[map_id].layers;
    for(layer_id in layers) {
      var layer = layers[layer_id],
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

  var toggleAllMapLayersElements = function(element, show) {
    // console.log('toggleAllMapLayersElements', element);
    var $element = $(element),
        map_id = $element.attr('data-map');
    toggleAllMapLayers(element, map_id, show);
  };

  var toggleLayersMenu = function(element) {
    var $element = $(element);
    $element.closest('.layers').toggleClass('expanded');
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

})(jQuery);
