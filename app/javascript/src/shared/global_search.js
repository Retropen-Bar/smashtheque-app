let formatResult = function (result) {
  // console.log('[GlobalSearch] formatResult', result)

  // if group
  if ((result.children || []).length > 0) {
    let $g = $("<span>").html(result.text);
    $g.click(function () {
      $g.closest(".select2-results__group").toggleClass("unfold");
    });
    return $g;
  }

  let $a = $(
    '<div class="search-result search-result-' +
      (result.type || "").toLowerCase() +
      '">'
  );

  $a.append('<i class="search-result-icon fas fa-' + result.icon + ' fa-fw">');
  $a.append(result.html);

  return $a;
};

// options:
// - url
// - (placeholder)
let configureInput = function (input, options) {
  // console.log('[GlobalSearch] configureInput', input, options);

  let $input = $(input);
  $input.select2({
    placeholder: options.placeholder || "Rechercher un joueur, une équipe, …",
    ajax: {
      url: options.url,
      dataType: "json",
      delay: 250,
    },
    templateResult: formatResult,
    minimumInputLength: 2,
  });

  $input.on("select2:select", function (e) {
    let result = e.params.data;
    if (options.openOnBlank) {
      let win = window.open(result.url, "_blank");
      win.focus();
    } else {
      window.location.href = result.url;
    }
  });
};

window.GlobalSearch = {
  configureInput: configureInput,
};
