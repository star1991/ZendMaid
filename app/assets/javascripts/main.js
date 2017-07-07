
/* Alternate format is hidden (ruby-compatible)
 * Client-side format is displayed (dateFormat) */
$(function() {


  function skipDay(date) {
  	if (typeof gon !== "undefined" && gon !== null && gon.skip_days !== undefined) {
  		if (gon.skip_days.indexOf(date.getDay()) != -1) {
  			return [false, '']
  		}
  	}

  	return [true, '']
  }

  $("input.date_picker").each( function(i){

    $(this).datepicker({
      altFormat: "dd/mm/yy",
      dateFormat: "mm/dd/yy",
      altField: $(this).next(), 
      beforeShowDay: skipDay	
	});
  })
});

if (typeof gon !== "undefined" && gon !== null && gon.teams !== undefined) {
		self.teams = gon.teams;
		self.employee_map = gon.employee_map;
	}


/* To handle datepicker fields which have no virtual attributes to fall back on */
// I wonder if this code will break in other contries which use the dd/mm/yy format by default
$(function () {
  $("input.input-calendar").each( function() {
  	if ($(this).val() != "" )
  		$(this).next().val( $.datepicker.formatDate("dd/mm/yy", new Date($(this).val())) );
  })
});

/* Appointment Instruction Management Code */

$(function () {
	var instruction_select = $('#service-item-select');
	
	$('#service-items-fields')
	.bind('cocoon:before-insert', function(e, task_to_be_added) {

		task_to_be_added.find('.instruction-id').val(instruction_select.val());
		task_to_be_added.find('.field-name').val(instruction_select.children("option").filter(":selected").text());
		task_to_be_added.find('.field-name-visible').html(instruction_select.children("option").filter(":selected").text());
		$('#no-instructions-notification').remove();
	})
	
	
});

/* Employee Assignment Management Code */

$(function() {
	
	employee_select = $('#employee-select');
	nested_fields = $(".nested-fields", "#assignment-fields");
	$.each(nested_fields, function (key, value) {
		employee_select.find("option[value=" + $(this).find('.employee-id').val() + "]").remove();
	});
	
	if (employee_select.find("option").length == 0) {
		employee_select.parents('.links').hide();
	}
	
	if ($.uniform != undefined) {
		$.uniform.update('#employee-select');
	};
	
	$('#assignment-fields')
	.bind('cocoon:before-insert', function(e, task_to_be_added) {
		task_to_be_added.find('.employee-id').val(employee_select.val());

		task_to_be_added.find('.employee-name').html(employee_select.children("option").filter(":selected").text());
		task_to_be_added.fadeIn('slow');
		
		employee_select.find("option[value=" + employee_select.val() + "]").remove();

		if (employee_select.find("option").length == 0) {
			employee_select.parents('.links').hide();
		 }
		
		$.uniform.update('#employee-select');		
		$('#no-assignments-notification').remove();
	})
	.bind('cocoon:before-remove', function(e, task) {
		
		employee_select.append("<option value=" + task.find('.employee-id').val() + ">" + task.find('.employee-name').html() + "</option>");
        // allow some time for the animation to complete
        $(this).data('remove-timeout', 1000);
        task.fadeOut('slow');
        $.uniform.update('#employee-select');
        employee_select.parents('.links').fadeIn('slow');
     });
	
	
	$('#status-fields')
	.bind('cocoon:after-insert', function(e, task) {
		$(task).find('.colorpicker').colorPicker();
	});
	
	$('#teams-fields')
	.bind('cocoon:after-insert', function(e, task) {
		$(task).find('.colorpicker').colorPicker();
		$(task).find(":checkbox").uniform();
	});
	
	$('#phone-numbers-fields')
	.bind('cocoon:after-insert', function(e, task) {
		$(task).find(":checkbox").uniform();		
	});

	$('#emails-fields')
	.bind('cocoon:after-insert', function(e, task) {
		$(task).find(":checkbox").uniform();		
	});
	
});

/* Instant Booking Price Calculation */

if (typeof gon !== "undefined" && gon !== null && gon.service_type_base_prices !== undefined) {

quantities_for_estimation = {}


function recordValues(quantities) {
	$.each(quantities, function() {
    	recordValue($(this));
    });
}

function recordValue(quantity) {
	if (quantity.closest('.service-item-fields').children(".destroy-field").val() == "1") {
		return false;
	}
	
	if (quantity.attr('type') == "checkbox") {
		quantities_for_estimation[parseInt(quantity.attr('data-id'))] = (+quantity.is(':checked'));
	}
	else if (quantity.attr('type') == 'radio') {
		if(quantity.is(":checked")) {
			quantities_for_estimation[parseInt(quantity.attr('data-id'))] = gon.appointment_fields_map[parseInt(quantity.attr('data-id'))][quantity.val()];
		}
	}
	else {
		quantities_for_estimation[parseInt(quantity.attr('data-id'))] = gon.appointment_fields_map[parseInt(quantity.attr('data-id'))][quantity.val()];
	}
}


//This code is messy, perhaps clean up at a future date
function getTotal(quantities) {
	if ($('#service-type').val()) {
    	var total = parseFloat(gon.service_type_base_prices[$('#service-type').val()]);
    } 
    else {
   		var total = 0;	
    }
	recordValues(quantities);
	
	//Calculate price from quantity values
	$.each(quantities, function() {
		quantity = $(this);
		
		//Only calculate price on radio attribute if it is checked to avoid overcounting
		if (quantity.attr('type') != 'radio' || quantity.is(':checked')) {
			qty = parseFloat(quantity.attr('data-price')) * quantities_for_estimation[parseInt(quantity.attr('data-id'))];
			if (qty) { total += qty; }
		}
	});
	
	//Calculate price from pricing tables
	for (var i=0;i<gon.pricing_tables.length;i++) {
		pricing_table_entry = gon.pricing_tables[i]
		var subTable = pricing_table_entry["pricing_table"];
		
		//Search table for correct value
		for (var j=0;j<pricing_table_entry["custom_field_ids"].length;j++) {
			var quantity_val = quantities_for_estimation[pricing_table_entry["custom_field_ids"][j]];
			if (subTable && quantity_val != undefined) {
				subTable = subTable[quantity_val.toString()];
			}
		}
		
		qty = parseFloat(subTable);
		if (qty) { total += qty }
	}
	
	$('#estimated-price-tag').val(total);
    $("#total-price").html("$" + total);
}


function hideAllServiceItemFields(quantities) {
	$(".destroy-field").val("1");
	$(".service-items").hide();
	$(".service-item-fields").hide();
	quantities_for_estimation = {};
	getTotal(quantities);
}

function showServiceItemFields(quantities, service_type_id) {

	for (var i=0;i<gon.service_type_map[service_type_id].length;i++) {
		var service_fields = $(".service-item-fields[data-id='" + gon.service_type_map[service_type_id][i] + "']");

		service_fields.show();
		service_fields.children(".destroy-field").val("0");
	}
	
	getTotal(quantities);
	$(".service-items").show("blind", 300);
}

function changeServiceItemFieldsForServiceType(quantities) {
	var service_type_id = $('#service-type').val();
	hideAllServiceItemFields(quantities);
	
	showServiceItemFields(quantities, service_type_id);
	
}

$(function() {
    var quantity = $('.quantity-to-estimate');
    quantity.change(function() {
        getTotal(quantity);
    });
    getTotal(quantity);

	$('#service-type').change(function() {
		changeServiceItemFieldsForServiceType(quantity);
	});

	//Initialization behavior
	$(".service-items").hide();
	if ($('#service-type').val()) {
		changeServiceItemFieldsForServiceType(quantity);
	}
});

}


function toggle_repeat_fields(e) {

	if ($(e.target).val() == 'true') {
		$('#no-repeat-fields').hide();
		$('#repeat-fields').show();
	} else {
		$('#no-repeat-fields').show();
		$('#repeat-fields').hide();
	}
	
}

function set_frequency_and_interval() {
	var recurrence_select = $('#recurrence-select').val();
	var hidden_recurrence_fields = $('#hidden-recurrence-fields');
	var frequency = hidden_recurrence_fields.find('#subscription_frequency');
	var interval = hidden_recurrence_fields.find('#subscription_interval');
	
	switch(recurrence_select) {
		case "weekly":
			frequency.val("2");
			interval.val("1");
			break;
		case "every 2 weeks":
			frequency.val("2");
			interval.val("2");
			break;
		case "every 3 weeks":
			frequency.val("2");
			interval.val("3");
			break;
		case "every 4 weeks":
			frequency.val("2");
			interval.val("4");
			break;
		case "every 5 weeks":
			frequency.val("2");
			interval.val("5");
			break;
		case "every 6 weeks":
			frequency.val("2");
			interval.val("6");
			break;
		case "every 7 weeks":
			frequency.val("2");
			interval.val("7");
			break;
		case "every 8 weeks":
			frequency.val("2");
			interval.val("8");
			break;		
		case "monthly":
			frequency.val("3");
			interval.val("1");
			break;
		case "every 2 months":
			frequency.val("3");
			interval.val("2");
			break;			
		case "quarterly":
			frequency.val("3");
			interval.val("3");
			break;		
		case "semi-yearly":
			frequency.val("3");
			interval.val("6");		
			break;
	}
}

var manage_select_toggles = function(e) {
	/* Make sure fields for start_date on subscription and start_date_date on appointment are equal */	
	$('.mirrored-start').change( function (e) {
		$('.mirrored-start').datepicker("setDate", $(this).val()).blur();
	});
	
	var repeat_toggle = $('.repeat-toggle');
	repeat_toggle.click(function (e) { toggle_repeat_fields(e); });
	
	var recurrence_toggle = $('#recurrence-toggle');
	if (recurrence_toggle.length > 0) {
		if (!recurrence_toggle.find('#subscription_repeat_true').parent().hasClass('checked')) {
			$('#repeat-fields').hide();
		}
	 
		if (!recurrence_toggle.find('#subscription_repeat_false').parent().hasClass('checked')){
			$('#no-repeat-fields').hide();
		}
	
	}
	
	set_frequency_and_interval();
	$('#recurrence-select').change( set_frequency_and_interval );	
}


$(function () {
	manage_select_toggles();
})


//Disable all buttons on submit
$(function() {
	$(document).on('submit', 'form', function(){

    // On submit disable its submit button
    	$('button[type=submit]', this).attr('disabled', 'disabled');
    	$('input[type=submit]', this).attr('disabled', 'disabled');
	});
	
	//work-around to submit commit parameter for multibutton submit
	$('.new-customer').mouseover( function () {
		$('#commit').val($(this).attr('name'));
	})	
});



$(function() {
	$('#custom-stripe-button').click(function(){
      	var token = function(res){
        	var $input = $('<input type=hidden name=stripeToken />').val(res.id);
        	$('form').append($input).submit();
      	};

      	StripeCheckout.open({
        	key:         'pk_live_YEK0WoXSv8Qej7KEHmXbgLDI',
        	currency:    'usd',
        	name:        'Almost there...',
        	description: 'Please enter your credit card information',
        	panelLabel:  'Subscribe!',
        	token:       token
      	});

      	return false;
	});
});

$( function(jQuery) {
	$('tr[data-toggle=tooltip]').tooltip();
});

$(document).on('change', "#customer_marketing_source", function(){
if($(this).val() == "Add New")
  {
    $(".new-merketing-source-container").show('slow');
  }
  else
  {
    $("#customer_new_marketing_source").val('');
    $(".new-merketing-source-container").hide('slow');	
  }
});

$(function() {
  if($(".new-merketing-source-container").length > 0)
  {
    $(".new-merketing-source-container").hide();
  }
});
