let handleClick = function(trigger) {
  const $trigger = $(trigger),
        $target = $($trigger.attr('data-target')),
        source = $trigger.attr('data-source');
  $.get(source, function(html) {
    $target.html(html).modal();
    window.initTooltips($target[0]);
  });
};

let init = function() {
  $(document).on('click', '[data-toggle="modal-remote"]', function() {
    handleClick(this);
  });
};

init();
