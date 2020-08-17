(function($) {

  var DATA_KEY = 'data-select2';

  var initSelect = function(input) {
    var $input = $(input);
    var options = JSON.parse($input.attr(DATA_KEY));
    $input.removeAttr(DATA_KEY).select2(options);
  };

  var init = function() {
    $('['+DATA_KEY+']').each(function() {
      initSelect(this);
    });
  };

  $(document).ready(init);

})(jQuery);
