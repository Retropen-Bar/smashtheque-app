(function($) {

  var DATA_KEY = 'data-maps-autocomplete';

  var onPlaceChanged = function(input, target, place) {
    // console.log('onPlaceChanged', input, target, place);

    $(target.latitude).val(place.geometry.location.lat());
    $(target.longitude).val(place.geometry.location.lng());
  };

  var initInput = function(input) {
    // console.log('[Maps] initInput', input);
    var $input = $(input);
    var options = JSON.parse($input.attr(DATA_KEY));
    $input.removeAttr(DATA_KEY);

    var target = options['target'];
    delete options['target'];

    var autocomplete = new google.maps.places.Autocomplete(
      input,
      $.extend({
        types: ['geocode']
      }, options)
    );
    google.maps.event.addListener(
      autocomplete,
      'place_changed',
      function(){
        console.log('place changed', this);
        onPlaceChanged(input, target, this.getPlace());
      }
    );
  };

  var init = function() {
    // console.log('[Maps] init');
    $('['+DATA_KEY+']').each(function() {
      initInput(this);
    });
  };

  $(document).ready(function(){
    google.maps.event.addDomListener(window, 'load', function() {
      init();
    });
  });

})(jQuery);
