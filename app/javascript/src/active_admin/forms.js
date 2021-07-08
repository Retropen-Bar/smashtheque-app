(function($) {

  var evalCallback = function(callback, form) {
    if(callback) {
      (function() {
        eval(callback);
      }).call(form);
    }
  };

  var onAjaxSuccess = function(form) {
    toastr.success('OK');
    evalCallback($(form).attr('data-success'), form);
  };

  var onAjaxFailure = function(form) {
    toastr.error('Un erreur est survenue');
    evalCallback($(form).attr('data-failure'), form);
  };

  var initForm = function(form) {
    $(form).on('ajax:success', function(event) {
      onAjaxSuccess(form);
    }).on('ajax:error', function(event) {
      onAjaxFailure(form);
    });
  };

  var init = function() {
    $('form[data-remote="true"]').each(function() {
      initForm(this);
    });
  };

  $(document).ready(init);

})(jQuery);

