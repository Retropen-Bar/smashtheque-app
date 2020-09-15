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
    console.log('toggleMapLayerElement', element);
    var $element = $(element),
        map_id = $element.attr('data-map'),
        layer_id = $element.attr('data-layer');
    toggleMapLayer(element, map_id, layer_id);
  };

  $(document).on('click', '.layer[data-map][data-layer]', function(e) {
    toggleMapLayerElement(e.currentTarget);
    return false;
  });

  window.maps = {};

})(jQuery);
