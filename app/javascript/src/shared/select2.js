import "select2"
import "select2/dist/js/i18n/fr"

/*
 * Hacky fix for a bug in select2 with jQuery 3.6.0's new nested-focus "protection"
 * see: https://github.com/select2/select2/issues/5993
 * see: https://github.com/jquery/jquery/issues/4382
 *
 * TODO: Recheck with the select2 GH issue and remove once this is fixed on their side
 */

$(document).on('select2:open', (e) => {
  if(!e.target.multiple) {
    $('.select2-search__field').last()[0].focus();
  }
});

// GO

const DATA_KEY = 'data-select2';

let getSortableUl = function($select) {
  return $select.next('.select2-container').find('ul.select2-selection__rendered');
};

let moveElementToEndOfParent = function($element) {
  // console.log('moveElementToEndOfParent', $element[0]);
  let $parent = $element.parent();
  $element.detach();
  $parent.append($element);
};

let findOptionFromLabel = function($select, label) {
  return $select.children('option:contains("'+label+'")').filter(function(){
    return $(this).text() === label;
  });
};

let orderSortedPassageValues = function($select) {
  // console.log('orderSortedPassageValues');
  let $ul = getSortableUl($select);
  $ul.children("li[title]").each(function(i, obj){
    let $element = findOptionFromLabel($select, obj.title);
    moveElementToEndOfParent($element);
  });
};

let initSortableUl = function($select) {
  let $ul = getSortableUl($select);
  // TODO: prevent text field to move
  $ul.sortable({
    containment: 'parent',
    update: function() {
      orderSortedPassageValues($select);
    }
  });

  $select.on("select2:select", function (evt) {
    // console.log('on select2:select');
    let id = evt.params.data.id;
    let element = $(this).children("option[value="+id+"]");
    moveElementToEndOfParent(element);
    $(this).trigger("change");
  });
};

let initSelect2Sortable = function($select, options) {
  // console.log('initSelect2Sortable', $select[0], options);

  if(options.sortedValues) {
    sortSelect2Sortable($select, options.sortedValues);
  }
  $select.select2(options);
  initSortableUl($select);
};

let sortSelect2Sortable = function($select, values) {
  $.each(values, function(i, value) {
    let $element = $select.children('option[value="'+value+'"]');
    moveElementToEndOfParent($element);
  });
};

let initSelect = function(input) {
  // console.log('initSelect', input);
  let $input = $(input);
  let options = JSON.parse($input.attr(DATA_KEY));

  $input.removeAttr(DATA_KEY);

  // add default options
  if( options.formatResults ) {
    options.templateResult = formatResult;
  }

  if( options.sortable ) {
    if(!$input.prop('multiple')) {
      return;
    }
    initSelect2Sortable($input, options);
  } else {
    $input.select2(options);
  }
};

let formatResult = function(result) {
  // console.log('[SELECT2] formatResult', result)

  let $a = $('<div class="search-result search-result-'+(result.type || '').toLowerCase()+'">');

  if( result.avatar ) {
    $a.append(
      $('<div class="search-result-avatar">').append(
        result.avatar
      )
    );
  } else {
    $a.append('<i class="search-result-icon fas fa-'+result.icon+' fa-fw">');
  }
  $a.append(result.html);

  return $a;
}

let init = function() {
  $('['+DATA_KEY+']').each(function() {
    initSelect(this);
  });
};

$(document).ready(init);
