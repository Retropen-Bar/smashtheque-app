const DATA_KEY = 'data-autoclick';

const autoclick = function() {
  $('['+DATA_KEY+']').click();
}

$(document).ready(autoclick);
