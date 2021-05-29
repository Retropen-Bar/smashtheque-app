let init = function() {
  const $form = $('form#index-filters');
  $form.on('change', 'input, select', function() {
    $form[0].submit();
  });
};

$(document).ready(init);
