(function($) {

  var formatResult = function(result) {
    var $a = $('<div class="search-result search-result-'+(result.type || '').toLowerCase()+'">');

    $a.append('<i class="search-result-icon fas fa-'+result.icon+' fa-fw">');
    $a.append(result.html);

    return $a;
  }

  // options:
  // - url
  // - (placeholder)
  var configureInput = function(input, options) {
    console.log('[GlobalSearch] configureInput', input, options);

    var $input = $(input);
    $input.select2({
      width: '400px',
      placeholder: options.placeholder || 'Recherche globale',
      ajax: {
        url: options.url,
        dataType: 'json',
        delay: 250
      },
      templateResult: formatResult,
      minimumInputLength: 3
    });

    $input.on('select2:select', function (e) {
      var result = e.params.data;
      var win = window.open(result.url, '_blank');
      win.focus();
    });
  };

  window.GlobalSearch = {
    configureInput: configureInput
  };

})(jQuery);
