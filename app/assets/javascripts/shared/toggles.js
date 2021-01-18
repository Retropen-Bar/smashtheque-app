(function($) {

  var DATA_KEY = 'data-toggle';

  var onCheckboxClick = function(input) {
    // console.log('[Toggle] onCheckboxClick', input);
    var $input = $(input);
    var targetSelector = $input.attr(DATA_KEY);
    $(targetSelector).toggle($input.is(':checked'));
  };

  var init = function() {
    var checkboxSelector = 'input[type=checkbox][' + DATA_KEY + ']';
    $(checkboxSelector).each(function() {
      onCheckboxClick(this);
    });
    $(document).on('click', checkboxSelector, function(e) {
      window.setTimeout(function() {
        onCheckboxClick(e.target);
      }, 0);
      return true;
    });
  };

  $(document).ready(init);

})(jQuery);
