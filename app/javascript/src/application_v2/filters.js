let init = function() {
  const $form = $('#index-filters form');
  $form.on('change', 'input, select', function() {
    $form[0].submit();
  });
};

$(document).ready(init);
