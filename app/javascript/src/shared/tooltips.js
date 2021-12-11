const DATA_KEY = 'data-tooltip';

let initElement = function(element) {
  // console.log('[Tooltips] initElement', element);
  let $element = $(element);
  let options = JSON.parse($element.attr(DATA_KEY));
  $element.removeAttr(DATA_KEY);
  $element.tooltip($.extend({ html: true }, options));
};

let initContainer = function(container) {
  $(container).find('['+DATA_KEY+']').each(function() {
    initElement(this);
  });
};

let init = function() {
  initContainer('body');
};

$(document).ready(init);
window.initTooltips = initContainer;
