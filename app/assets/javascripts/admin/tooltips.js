(function($) {

  var DATA_KEY = 'data-tooltip';

  var initElement = function(element) {
    console.log('[Tooltips] initElement', element);
    var $element = $(element);
    var options = JSON.parse($element.attr(DATA_KEY));
    $element.removeAttr(DATA_KEY);
    window.tippy(element, options);
  };

  var init = function() {
    $('['+DATA_KEY+']').each(function() {
      initElement(this);
    });
  };

  $(document).ready(init);

})(jQuery);
