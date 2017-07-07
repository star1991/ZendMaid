$(document).ready(function() {

	/* Appointment list view Javascript */
	$('#appointments-list').find('.appointment-entry').click(function () {
		eventPopoverPanel.show({id: $(this).data('appointment')});
	})
	
	$('#appointment-query-submit').click(function () {
		//When searching, ignore currently selected date range
		location.search = $.param({'query': $('#appointment-search-query').val()});
	})

	$('#appointment-search-query').keypress(function(event){
  		if(event.keyCode == 13){
    		$('#appointment-query-submit').click();
  		}
	});
	
	$('#appointment-select-all').on('click', function () {
		if (this.checked)
			$('#appointments-list').find('.appointment-select').not(':checked').trigger('click');
		else
			$('#appointments-list').find('.appointment-select:checked').trigger('click');
	})
	
	$('.set-appointment-status').click(function () {
		var params = {};
		
		params.status_id = $(this).data('id');
		params.ids = get_selected_appointment_ids();
		
		$.ajax({
			async: false,
			url: '/appointments/set_status',
			type: 'POST',
			data: params
		});
	});
	
	$('.set-paid').click(function () {
		var params = {};
		
		params.paid = $(this).data('paid');
		params.ids = get_selected_appointment_ids();
		
		$.ajax({
			async: false,
			url: '/appointments/set_paid',
			type: 'POST',
			data: params
		});
	});	
	
	$('#delete-selected-appointments').click(function () {
		if (window.confirm("Are you sure you wish to PERMANENTLY delete the selected appointments and all associated data?")) {
			var params = {ids: get_selected_appointment_ids() };
		
			$.ajax({
				async: false,
				url: '/appointments/delete_all',
				type: 'POST',
				data: params
			});
		}
	});
});