const handleAddClick = function(link, e) {
  // console.log('click add new fields', link, e);

  // Stop the function from executing if a link or event were not passed into the function.
  if (!link || !e) return
  // Prevent the browser from following the URL.
  e.preventDefault();
  // Save a unique timestamp to ensure the key of the associated array is unique.
  let time = new Date().getTime()
  // Save the data id attribute into a variable. This corresponds to `new_object.object_id`.
  let linkId = link.dataset.id
  // Create a new regular expression needed to find any instance of the `new_object.object_id` used in the fields data attribute if there's a value in `linkId`.
  let regexp = linkId ? new RegExp(linkId, 'g') : null
  // Replace all instances of the `new_object.object_id` with `time`, and save markup into a variable if there's a value in `regexp`.
  let newFields = regexp ? link.dataset.fields.replace(regexp, time) : null
  // Add the new markup to the form if there are fields to add.
  newFields ? link.insertAdjacentHTML('beforebegin', newFields) : null
};

const handleRemoveClick = function(link, e) {
  // console.log('click rm fields', link, e);

  // Stop the function from executing if a link or event were not passed into the function.
  if (!link || !e) return
  // Prevent the browser from following the URL.
  e.preventDefault()
  // Find the parent wrapper for the set of nested fields.
  let $fieldParent = $(link).closest('.nested-fields')
  // If there is a parent wrapper, find the hidden delete field.
  let $deleteField = $fieldParent.find('input[type="hidden"]');
  // If there is a delete field, update the value to `1` and hide the corresponding nested fields.
  $deleteField.val(1);
  $fieldParent.hide();
};

$(document).on('click', '.add-nested-fields', function(e) {
  handleAddClick(this, e);
});
$(document).on('click', '.rm-nested-fields', function(e) {
  handleRemoveClick(this, e);
});
