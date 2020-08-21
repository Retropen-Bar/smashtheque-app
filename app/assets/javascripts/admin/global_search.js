(function($) {

  var generateInput = function() {
    return $('<select id="global_search_input">');
  };

  var formatResult = function(result) {
    var $a = $('<div class="search-result search-result-'+(result.type || '').toLowerCase()+'">');

    $a.append('<i class="search-result-icon fas fa-'+result.icon+' fa-fw">');
    $a.append(result.html);

    return $a;
  }

  var configure = function($input) {
    $input.select2({
      width: '400px',
      placeholder: 'Recherche globale',
      ajax: {
        url: '/admin/search',
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

  var init = function() {
    // generate the DOM element
    var $input = generateInput();

    // append it to the DOM
    $('#header ul#utility_nav').prepend(
      $('<li class="menu_item" id="global_search"></li>').append(
        $input
      )
    );

    // configure search
    configure($input);
  };

  $(document).ready(init);

})(jQuery);
