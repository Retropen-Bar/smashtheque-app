(function($) {

  var DATA_KEY = 'data-toggle';

  var onCheckboxClick = function(input) {
    console.log('[Toggle] onCheckboxClick', input);
    var $input = $(input);
    var targetSelector = $input.attr(DATA_KEY);
    console.log('targetSelector: ', targetSelector);
    console.log('target: ', $(targetSelector)[0]);
    console.log('is checked: ', $input.is(':checked'));
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
