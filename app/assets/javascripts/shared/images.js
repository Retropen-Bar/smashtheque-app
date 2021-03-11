(function($) {

  var DATA_KEY = 'data-previewpanel';

  var initFileField = function(input) {
    // console.log('[Images] initFileField', input);

    var $input = $(input);
    var targetId = $input.attr(DATA_KEY);
    $input.removeAttr(DATA_KEY);
    var $target = $('.panel#' + targetId + ' .panel_contents');

    $input.change(function() {
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
          var $img = $('<img/>');
          $img.attr('src', e.target.result);
          $target.html($img);
        }
        reader.readAsDataURL(input.files[0]); // convert to base64 string
      }
    });
  };

  var init = function() {
    $('input[type="file"]['+DATA_KEY+']').each(function() {
      initFileField(this);
    });
  };

  $(document).ready(init);

})(jQuery);
