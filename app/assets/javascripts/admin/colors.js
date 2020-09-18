(function($) {

  var DATA_KEY = 'data-colorpicker';

  var initElement = function(element) {
    console.log('[Colors] initElement', element);
    var $element = $(element);
    var options = JSON.parse($element.attr(DATA_KEY));
    $element.removeAttr(DATA_KEY);
    $element.minicolors(options);
  };

  var init = function() {
    $('['+DATA_KEY+']').each(function() {
      initElement(this);
    });
  };

  $(document).ready(init);

})(jQuery);
