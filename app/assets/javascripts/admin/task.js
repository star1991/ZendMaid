$(document).on('change', "#tasks .task input[type='checkbox']", function(e) {
  $(e.currentTarget).closest('form').submit();
});

$(document).on('change', "#pageslide .task input[type='checkbox']", function(e) {
  $(e.currentTarget).closest('form').submit();
});

$(document).on('change', "#tasks select#task_filter", function(e) {
  $(e.currentTarget).closest('form').trigger( "submit" ) ;
});

$("#tasks").on('click', 'form .btn.cancel', function() {
  $("#tasks .new-task").html('');
  return false;
})

$(document).on('click', ".new-task .show-set-to-repeat, .task .show-set-to-repeat", function (e) {
	$(this).hide();
	$(this).siblings('.set-to-repeat').show();
	$(this).siblings('.set-to-repeat-field').val('true');
	return false;
});

$(document).on('click', ".new-task .cancel-set-to-repeat, .task .cancel-set-to-repeat", function (e) {
	$(this).closest('.set-to-repeat').hide();
	$(this).closest('.set-to-repeat').siblings('.show-set-to-repeat').show();
	$(this).closest('.set-to-repeat').siblings('.set-to-repeat-field').val('false');
	return false;
});

