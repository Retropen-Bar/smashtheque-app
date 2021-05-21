const DATA_KEY = 'data-toggle';
const DATA_KEY_INVERSE = 'data-untoggle';

let onCheckboxClick = function(input) {
  // console.log('[Toggle] onCheckboxClick', input);
  let $input = $(input);
  let isChecked = $input.is(':checked');
  $($input.attr(DATA_KEY)).toggle(isChecked);
  $($input.attr(DATA_KEY_INVERSE)).toggle(!isChecked);
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
