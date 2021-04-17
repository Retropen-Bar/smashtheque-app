const DATA_KEY = 'data-toggle';

let onCheckboxClick = function(input) {
  // console.log('[Toggle] onCheckboxClick', input);
  let $input = $(input);
  let targetSelector = $input.attr(DATA_KEY);
  $(targetSelector).toggle($input.is(':checked'));
};

let init = function() {
  let checkboxSelector = 'input[type=checkbox][' + DATA_KEY + ']';
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
