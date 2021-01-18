(function($) {

  var DATA_KEY = 'data-select2';

  var getSortableUl = function($select) {
    return $select.next('.select2-container').find('ul.select2-selection__rendered');
  };

  var moveElementToEndOfParent = function($element) {
    // console.log('moveElementToEndOfParent', $element[0]);
    var $parent = $element.parent();
    $element.detach();
    $parent.append($element);
  };

  var findOptionFromLabel = function($select, label) {
    return $select.children('option:contains("'+label+'")').filter(function(){
      return $(this).text() === label;
    });
  };

  var orderSortedPassageValues = function($select) {
    // console.log('orderSortedPassageValues');
    var $ul = getSortableUl($select);
    $ul.children("li[title]").each(function(i, obj){
      var $element = findOptionFromLabel($select, obj.title);
      moveElementToEndOfParent($element);
    });
  };

  var initSortableUl = function($select) {
    var $ul = getSortableUl($select);
    // TODO: prevent text field to move
    $ul.sortable({
      containment: 'parent',
      update: function() {
        orderSortedPassageValues($select);
      }
    });

    $select.on("select2:select", function (evt) {
      // console.log('on select2:select');
      var id = evt.params.data.id;
      var element = $(this).children("option[value="+id+"]");
      moveElementToEndOfParent(element);
      $(this).trigger("change");
    });
  };

  var initSelect2Sortable = function($select, options) {
    console.log('initSelect2Sortable', $select[0], options);

    if(options.sortedValues) {
      sortSelect2Sortable($select, options.sortedValues);
    }
    $select.select2(options);
    initSortableUl($select);
  };

  var sortSelect2Sortable = function($select, values) {
    $.each(values, function(i, value) {
      var $element = $select.children('option[value="'+value+'"]');
      moveElementToEndOfParent($element);
    });
  };

  var initSelect = function(input) {
    // console.log('initSelect', input);
    var $input = $(input);
    var options = JSON.parse($input.attr(DATA_KEY));

    $input.removeAttr(DATA_KEY);

    if( options.sortable ) {
      if(!$input.prop('multiple')) {
        return;
      }
      initSelect2Sortable($input, options);
    } else {
      $input.select2(options);
    }
  };

  var init = function() {
    $('['+DATA_KEY+']').each(function() {
      initSelect(this);
    });
  };

  $(document).ready(init);

})(jQuery);
