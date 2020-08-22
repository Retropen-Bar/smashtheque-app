(function($) {

  var DATA_KEY = 'data-global-search';

  var initInput = function(input) {
    console.log('[global search] initInput', input);
    var $input = $(input);
    var options = JSON.parse($input.attr(DATA_KEY));

    $input.removeAttr(DATA_KEY);

    window.GlobalSearch.configureInput(input, $.extend({
      url: '/api/v1/search'
    }, options));
  };

  var init = function() {
    console.log('[global search] init');
    $('['+DATA_KEY+']').each(function() {
      initInput(this);
    });
  };

  $(document).ready(init);

})(jQuery);
