const DATA_KEY = "data-global-search";

let initInput = function (input) {
  // console.log('[global search] initInput', input);

  let $input = $(input);
  let options = JSON.parse($input.attr(DATA_KEY));

  $input.removeAttr(DATA_KEY);

  window.GlobalSearch.configureInput(
    input,
    $.extend(
      {
        url: "/api/v1/search",
      },
      options
    )
  );
};

let init = function () {
  // console.log('[global search] init');

  $("[" + DATA_KEY + "]").each(function () {
    initInput(this);
  });

  $(document).on("shown.bs.modal", "#global-search", function () {
    $("#search").val(null).trigger("change");
    $("#search").select2("open");
  });
};

$(document).ready(init);
