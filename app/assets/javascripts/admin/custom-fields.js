//Reorders nested fields based on order of display in UI
var reorderNestedFields = function(parentDiv) {
	var nestedFields = $(parentDiv).find('.nested-fields');

	nestedFields.each(function(index, element) {
		$(element).find('.order-field').val(index + 1);
	});
}

var toggle_input_specific_fields = function () {
	$modal = $('#custom-field-modal');

	$modal.find('.field-type').hide();
	$modal.find('#' + $('#input-type-select').val()).show();
};

$(function () {
	$('.custom-fields').sortable({
		cancel: ".links, select, input",
		items: ".nested-fields",
		stop: function(event, ui) {
				reorderNestedFields(event.target);
			}
		});
	
	$('.custom-fields').bind('cocoon:after-insert', function(e, task_to_be_added) {
		task_to_be_added.find("input[type='checkbox']").uniform();	
		reorderNestedFields(task_to_be_added.parent());
	});

	$('body').on('change', '#input-type-select', toggle_input_specific_fields);
});