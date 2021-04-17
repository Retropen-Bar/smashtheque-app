const DATA_KEY = 'data-previewpanel';

let initFileField = function(input) {
  // console.log('[Images] initFileField', input);

  let $input = $(input);
  let targetId = $input.attr(DATA_KEY);
  $input.removeAttr(DATA_KEY);
  let $target = $('.panel#' + targetId + ' .panel_contents');

  $input.change(function() {
    if (input.files && input.files[0]) {
      let reader = new FileReader();
      reader.onload = function(e) {
        let $img = $('<img/>');
        $img.attr('src', e.target.result);
        $target.html($img);
      }
      reader.readAsDataURL(input.files[0]); // convert to base64 string
    }
  });
};

let init = function() {
  $('input[type="file"]['+DATA_KEY+']').each(function() {
    initFileField(this);
  });
};

$(document).ready(init);
