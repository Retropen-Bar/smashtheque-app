(function($) {

  var DATA_KEY = 'data-maps-autocomplete';

  var onPlaceChanged = function(input, target, place) {
    // console.log('[Maps Autocomplete] onPlaceChanged', input, target, place);

    $(input).val(place.name);
    $(target.latitude).val(place.geometry.location.lat());
    $(target.longitude).val(place.geometry.location.lng());
  };

  var initInput = function(input) {
    // console.log('[Maps Autocomplete] initInput', input);
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
    // console.log('[Maps Autocomplete] init');
    $('['+DATA_KEY+']').each(function() {
      initInput(this);
    });
  };

  $(document).ready(init);

})(jQuery);
