const DATA_KEY = 'data-maps-autocomplete';

let onPlaceChanged = function(input, target, place) {
  // console.log('[Maps Autocomplete] onPlaceChanged', input, target, place);

  $(input).val(place.formatted_address);

  if(target.formatted) {
    $(target.formatted).val(place.formatted_address);
  }
  if(target.name) {
    $(target.name).val(place.name);
  }
  if(target.latitude) {
    $(target.latitude).val(place.geometry.location.lat());
  }
  if(target.longitude) {
    $(target.longitude).val(place.geometry.location.lng());
  }
  for (const component of place.address_components) {
    const componentType = component.types[0];
    switch (componentType) {
      case "locality":
        if(target.locality) {
          $(target.locality).val(component.long_name);
        }
      case "country":
        if(target.country) {
          $(target.country).val(component.long_name);
        }
    }
  }
};

let onPlaceRemoved = function(input, target) {
  // console.log('[Maps Autocomplete] onPlaceRemoved', input, target);

  $(target.latitude).val('');
  $(target.longitude).val('');
}

let initInput = function(input) {
  // console.log('[Maps Autocomplete] initInput', input);
  let $input = $(input);
  let options = JSON.parse($input.attr(DATA_KEY));
  $input.removeAttr(DATA_KEY);

  let target = options['target'];
  delete options['target'];

  let autocomplete = new google.maps.places.Autocomplete(
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
  $input.on('change', function() {
    if($input.val() == '') {
      onPlaceRemoved(input, target);
    }
  });
};

let init = function() {
  // console.log('[Maps Autocomplete] init');
  $('['+DATA_KEY+']').each(function() {
    initInput(this);
  });
};

$(document).ready(init);
