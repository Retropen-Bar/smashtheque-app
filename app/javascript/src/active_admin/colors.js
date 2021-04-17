const DATA_KEY = 'data-colorpicker';

let initElement = function(element) {
  console.log('[Colors] initElement', element);
  let $element = $(element);
  let options = JSON.parse($element.attr(DATA_KEY));
  $element.removeAttr(DATA_KEY);
  $element.minicolors(options);
};

let init = function() {
  $('['+DATA_KEY+']').each(function() {
    initElement(this);
  });
};

$(document).ready(init);
