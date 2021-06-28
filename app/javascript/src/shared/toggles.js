const DATA_KEY = 'data-toggle';
const DATA_KEY_INVERSE = 'data-untoggle';

let onCheckboxClick = function(input) {
  // console.log('[Toggle] onCheckboxClick', input);
  let $input = $(input);
  let isChecked = $input.is(':checked');
  $($input.attr(DATA_KEY)).toggle(isChecked);
  $($input.attr(DATA_KEY_INVERSE)).toggle(!isChecked);
};

let onSelectChange = function(select) {
  // console.log('[Toggle] onSelectChange', select);
  let $select = $(select);
  let hasValue = ('' + $select.val()).length > 0;
  $($select.attr(DATA_KEY)).toggle(hasValue);
  $($select.attr(DATA_KEY_INVERSE)).toggle(!hasValue);
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

  let selectSelector = 'select[' + DATA_KEY + ']';
  $(selectSelector).each(function() {
    onSelectChange(this);
  });
  $(document).on('change', selectSelector, function(e) {
    window.setTimeout(function() {
      onSelectChange(e.target);
    }, 0);
    return true;
  });
};

$(document).ready(init);
