let generateInput = function() {
  return $('<select id="global_search_input" style="width: 400px">');
};

let init = function() {
  // generate the DOM element
  let $input = generateInput();

  // append it to the DOM
  $('#header ul#utility_nav').prepend(
    $('<li class="menu_item" id="global_search"></li>').append(
      $input
    )
  );

  // configure search
  window.GlobalSearch.configureInput($input[0], {
    url: '/admin/search'
  });
};

$(document).ready(init);
