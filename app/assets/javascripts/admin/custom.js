


$(document).on("click", "input[type='text']", function () {
   $(this).select();
});

$('.filters-wrapper').find('h6').click(function (e) {
	var filter_content = $(this).next();
	
	if (filter_content.is(':visible'))
	{
     	$(this).find('i').removeClass('icon-minus');
      	$(this).find('i').addClass('icon-plus');
	}
	else
	{
     	$(this).find('i').removeClass('icon-plus');
      	$(this).find('i').addClass('icon-minus');		
	}
	filter_content.toggle(300);
})

/* Calendar */

var hideAllPanels = function () {
	$('#filter-panel').hide();
	$('#calendar-info').hide();
	$('#eventPreviewPanel').remove();
}


var CalendarInformation = function () {
	var self = this;
	
	self.filter_colors = {};
	self.filter_show = {};
	self.names_by_id = {}
	
	self.filters_on = false;
	self.hidden_filter_panel = $('#filter-panel');
	self.filter_button = $('#filter-button');
	self.filter_panel = $('#filter-panel');
	self.coloring = $('#color');
	
	self.event_source_appts = {
		url: '/get_appts/',
		type: 'POST'
	} ;

  self.event_source_tasks = {
    url: '/get_tasks/',
    type: 'POST'
  }
	
	self.init = function() {
		$('.filters').each( function () {
			
			var color_object = {}
			var show_object = {}
			var name_object = {}
			self.filter_show[$(this).attr('id')] = show_object;
			self.filter_colors[$(this).attr('id')] = color_object;
			self.names_by_id[$(this).attr('id')] = name_object;
			
			$(this).find('.filter-wrapper').each (function () {
				var name = $(this).find('.name').html();
			
				color_object[name] = hexc($(this).find('.color-preview').css('background-color'));
				show_object[name] = true;
				$(this).click(self.toggle);
				
				name_object[$(this).data("id")] = name;
				
				if ($(this).data("show") == false)
					$(this).trigger("click");		
				
			});
		});
		
		
		$('#refresh-calendar-button').click(self.refresh_calendar);
  		self.coloring.change(self.refresh_calendar);


  		self.filter_button.click( function () {
			$.pageslide({ href: '#filter-panel', modal: true, iframe: true, direction: 'left' } );
			self.filter_panel = $('#pageslide').find('#filter-panel');
			window.calendar.fullCalendar('windowResize');
  		});
  		
  		self.check_if_filters_on();
  		self.refresh_event_source();
	};

	self.refresh_calendar = function () {
		self.check_if_filters_on();
		console.log('refreshing');
  		window.calendar.fullCalendar('removeEventSource', self.event_source_appts);
      window.calendar.fullCalendar('removeEventSource', self.event_source_tasks);
  		self.refresh_event_source();
  		window.calendar.fullCalendar('addEventSource', self.event_source_appts);
      window.calendar.fullCalendar('addEventSource', self.event_source_tasks);
      window.calendar.fullCalendar('windowResize');
	}
	
	self.refresh_event_source = function() {
		self.event_source_appts["data"] = {
			filter_show: JSON.stringify(self.filter_show),
			event_color: self.coloring.val()
		}
	}
	
	self.toggle = function () {
		var name = $(this).find('.name').html();
		var filter_type = $(this).closest('.filters').attr("id");
		var show_obj = self.filter_show[filter_type][name];
		
		if(show_obj) {
			$(this).find('.color-preview').css('background-color', '#fff');
			
			self.hidden_filter_panel.find('#' + filter_type).find('.filter-wrapper').filter(function () {
				return $(this).find('.name').html() == name;
			}).find('.color-preview').css('background-color', '#fff');
		} else {
			$(this).find('.color-preview').css('background-color', self.filter_colors[filter_type][name]);
			
			self.hidden_filter_panel.find('#' + filter_type).find('.filter-wrapper').filter(function () {
				return $(this).find('.name').html() == name;
			}).find('.color-preview').css('background-color', self.filter_colors[filter_type][name]);
		}
		
		self.filter_show[filter_type][name] = !show_obj;
		
	};
	
	self.check_if_filters_on = function () {
		self.filters_on = false;
		
		for (var filter_type in self.filter_show) {
			var local_filters_on = false;
			for (var name in self.filter_show[filter_type]) {
			
				if (!self.filter_show[filter_type][name]) {
					local_filters_on = true;
					self.filters_on = true;
					break;
				}
			}
			
			if (local_filters_on) {
				self.hidden_filter_panel.find('#' + filter_type).prev().find('.filter-notification').html("(Filters ON)");
				self.filter_panel.find('#' + filter_type).prev().find('.filter-notification').html("(Filters ON)");
			} else {
				self.hidden_filter_panel.find('#' + filter_type).prev().find('.filter-notification').html("");
				self.filter_panel.find('#' + filter_type).prev().find('.filter-notification').html("");
			}
			
		}
		
		if (self.filters_on) {
			self.filter_button.html('Filters<strong class="blue">ON</strong>');
		} else {
			self.filter_button.html('Filters<strong class="black">OFF</strong>');
		}
	};
}

var filterObject = new CalendarInformation();

$(document).ready(function() {

  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();
 
  // Calendar that displays assigned appointments
  window.employee_calendar = $('#employee-calendar').fullCalendar({
    header: {
      left: 'prev',
      center: 'title',
      right: 'month,agendaWeek,agendaDay,next'
    },
    editable: true,
    allDaySlot: false,
	height: 800,
    unselectCancel: '.popover, .modal, #ui-datepicker-div',
	eventClick: function(event, jsEvent, view) {
		$.ajax( {
			url: '/appointments/preview_panel/' + event.id + '.js?employee_calendar=true',
			type: 'get',
			contentType: 'application/json',
			success: function () {						
				$('#employee-calendar').fullCalendar('windowResize');
			}
		});	
		
		return false;
	},
	
    eventSources: [
      {
        url: '/get_assigned_appts/',
        backgroundColor: 'green',
        borderColor: 'black',
        textColor: 'white',
        editable: false
      },

    ],

    defaultView:'agendaWeek',
    firstHour: 7,  // first hour is 7am
    loading: calendar_loading,

  });
  

  window.calendar = $('#calendar').fullCalendar({
    header: {
      left: 'prev',
      center: 'title',
      right: 'month,agendaWeek,agendaDay,next'
    },
    editable: true,
    allDaySlot: true,
    allDayText: "<strong class='blue'>Tasks</strong>",
    snapMinutes: 15,
    height: 800,
    selectable: true,
    selectHelper: true,
    unselectCancel: '#pageslide',
    eventSources:[filterObject.event_source_tasks, filterObject.event_source_appts ],
     	
    eventClick: eventPopoverPanel.show,
    defaultView:'agendaWeek',
    loading: calendar_loading,
    firstHour: 7,  // first hour is 7am
    eventDrop: function(event,dayDelta,minuteDelta,allDay,revertFunc) {
      if (event['task']) {
        if (!allDay) {
          revertFunc() ;
        } else {
          calendar_loading(true);
          $.ajax({
            type: "PUT",
            url: '/update_task_from_calendar/'+ event.id,
            data: { delta_day: dayDelta },
            success: function(responseJSON) {
              calendar_loading(false);
              if (responseJSON.success) {
                // refresh calandar is not good for user experience, but prevent bugs
                filterObject.refresh_calendar();
              } else {
                revertFunc() ;
              }
            }
          })
        }

      } else {
        changeEvent(event, revertFunc);
      }
    },
    eventResize: function(event,dayDelta,minuteDelta,revertFunc) {
        changeEvent(event, revertFunc);
    },
    select: function(start, end, allDay, jsEvent, view) {
        console.log("selecting:", jsEvent);
        // the dom element representing the "ghost" event
        var ghostElement = jsEvent.target;

        if (allDay) {
          eventPopoverPanel.create(start);
        } else {
          createPanel.show(start, end, ghostElement);
        }
        return;
    },
    eventRender: function(event, element) {
      // strike through completed tasks
      if (event['task']) {
        element.find("span").css('margin-left',3);
        if (event['completed'] ) {
          element.find("span").prepend("<i class='icon-ok'></i> ");
          element.css('text-decoration','line-through');
          element.css('font-style','italic');
        } else if (event['recurring']) {
          element.find("span").prepend("<i class='icon-refresh'></i> ");
        }
      }
    }

  });
  
});


var calendar_loading = function(bool){
	if (bool) {
   		$('#calendar-loading').show();
    } else {
        $('#calendar-loading').hide();
    }
}

var ShowEventPopover = function() {
	var self = this;
	self.el = $("#eventPreviewPanel");
	self.showTarget = $('.calender-info-panel');
	self.assignedPanel = null;
	
	self.reattach_events = function () {
		
		var $pageslide = $('#pageslide');
		$pageslide.find('.fetch-customer-recent-activity').click(fetch_customer_activity);
		$pageslide.find('#edit_time_in_time_out').click(edit_time_in_time_out);
		
		$pageslide.find('.dropdown-toggle').dropdown();
		
		$pageslide.find('.close-pageslide').click( function (e) {
			e.preventDefault();
			$.pageslide.close();
			window.calendar.fullCalendar('windowResize');
		});
		
		$pageslide.click( function () {
			$pageslide.find('[data-toggle="dropdown"]').parent().removeClass('open');
		})
		
		$pageslide.find('form').submit(function() {
    		$('button[type=submit]', this).attr('disabled', 'disabled');
    		$('input[type=submit]', this).attr('disabled', 'disabled');
		});
		$pageslide.find(":radio").uniform();
  		$pageslide.find(":checkbox").uniform();
		
		self.assignedPanel = new AssignedCleanersPanel();
  		$pageslide.find('#edit-assigned-appointments').click(function () {
  			$('#assignments-modal').appendTo("body").modal('show');	
  		});
		
		$('#status-panel').find('a').click( function () {
			
			data = { 
				id: self.id,
				appointment: { status_id: $(this).data("id") } 
			}
				
			var status_name  = $(this).html();
			if ($('#current-status').html() != status_name) {
				$.ajax({
					url: '/update_from_calendar/' + self.id + '.js',
					type: 'put',
        			data: JSON.stringify(data),
        			contentType: 'application/json',
        			success: function() {
						$('#current-status').html(status_name);
    		  		}
				})
			}
		});
		
		//Toggle customer fields
		$pageslide.find(".toggle-control").click( function() {
			console.log("toggling!");
			var toggleable = $(this).next();	
			if (toggleable.is(':visible'))
			{
     			$(this).find('i').removeClass('icon-minus');
      			$(this).find('i').addClass('icon-plus');
			}
			else
			{
     			$(this).find('i').removeClass('icon-plus');
      			$(this).find('i').addClass('icon-minus');		
			}
			toggleable.toggle(300);
		});
		
		$('#generate-template-button').prev().data("appointment", self.id);
		$pageslide.find('#select-template-link').click(function (e) {
			e.preventDefault();
			$('#select-template-modal').modal('show');
		});
		
		$('#generate-text-template-button').prev().data("appointment", self.id);
		$pageslide.find('#select-text-template-link').click(function (e) {
			e.preventDefault();
			$('#select-text-template-modal').modal('show');
		});

		$pageslide.find('#manage-credit-card').click(manage_credit_cards);
		
		$pageslide.find('.close-pageslide').click( function (e) {
			e.preventDefault();
			$.pageslide.close();
			window.calendar.fullCalendar('windowResize');
		});
		
		window.calendar.fullCalendar('windowResize');
							
	}
	
	self.create = function(day) {
	    hideAllPanels();
	    $.ajax( {
	      url: '/tasks/create_task_panel/' + day.toDateString() + '.js',
	      type: 'get',
	      contentType: 'application/json'
	    });
	    return false;
	}
	
	self.show = function(event, jsEvent, view) {
		hideAllPanels();
		self.id = event.id;
	    var event_type = (event['task']) ? 'tasks' : 'appointments'

	    $.ajax( {
	      url: '/'+ event_type + '/preview_panel/' + event.id + '.js',
	      type: 'get',
	      contentType: 'application/json'
	    });
		return false;
	}
	
}

eventPopoverPanel = new ShowEventPopover();


function saveEvent(event, revertFunc, apply_to_subscription) {
	recurring_modal = $('#reschedule-appointment-modal');
    
    var data = {
        id: event.id,
        apply_to_subscription: apply_to_subscription,
        appointment: {
        	start_time_date: recurring_modal.find('#reschedule_date').next().val(),
            start_time_time: recurring_modal.find('#reschedule_from').val(),
            end_time_time: recurring_modal.find('#reschedule_to').val()
        }
    };
    
    console.log("data:", JSON.stringify(data));
    var url = "/update_from_calendar/" + event.id + ".js"
    calendar_loading(true);
    $.ajax({
        type: 'put',
        data: JSON.stringify(data),
        contentType: 'application/json',
        url: url,
        success: function() {
            calendar_loading(false);
   		},	
        error: function() {
        	revertFunc();
			calendar_loading(false);
        }
    });
}


function changeEvent(event, revertFunc){
		
	recurring_modal = $('#reschedule-appointment-modal');
	eventUpdateNotifier.revertFunc = revertFunc;
	
	if (event.recurring) {
		recurring_modal.find('#reschedule_toggle-recurring').show();
	} else {
		recurring_modal.find('#reschedule_toggle-recurring').hide();
	}
	
	$.uniform.update(recurring_modal.find("#only-this").prop("checked", true));
	$.uniform.update(recurring_modal.find("#all-future").prop("checked", false));
	
	recurring_modal.find('#reschedule_date').val(event.start.formatDate());
	recurring_modal.find('#reschedule_date').next().val(event.start.formatDateInternational());
	
	recurring_modal.find('#reschedule_from').val(event.start.formatTime());
	recurring_modal.find('#reschedule_to').val(event.end.formatTime());
	
	
	recurring_modal.find('#reschedule-save').unbind('click').click( function () {
		recurring_modal.modal("hide");	
		saveEvent(event, revertFunc, $('input[name=apply_to_subscription]:checked', '#reschedule-appointment-modal').val());		
	});
	
	recurring_modal.find('#reschedule-cancel').unbind('click').click(function () {
		recurring_modal.modal("hide");
		revertFunc();		
	});

	recurring_modal.modal({
		backdrop: 'static',
		keyboard: false
	});

}

function EventUpdateNotifier() {
    var self = this;
    self.el = $("<div>").addClass("notification");
    self.el.css('opacity', 0);
    // self.el.appendTo(document.body);
    
    $('#update-notifier').append(self.el);

    self.timeout = 0;
    self.show = function() {
        clearTimeout(self.timeout);
        self.el.css('opacity', 1);
        self.timeout = setTimeout(self.hide, 8000);
    }

    self.hide = function() {
        self.el.css('opacity', 0);
    }

    self.undoCallback = function() {};

    self.undo = function() {
        self.undoCallback();

        clearTimeout(self.timeout);

        // remvoe the undo btn & callback
        self.el.html("Event updated cancelled");
        self.undoCallback = function() {};


        self.timeout = setTimeout(self.hide, 2000);
    }

    self.update = function(undoCallback, revertFunc) {
        self.undoCallback = undoCallback;
        self.revertFunc = revertFunc

        self.el.html("Event updated. ");
        var link = $("<a class='ptr'>");
        link.html("Undo");
        link.on('click', self.undo);
        link.appendTo(self.el);
    }

}

var eventUpdateNotifier = new EventUpdateNotifier();

/* popover for creating a new event quickly */

function hexc(colorval) {
    var parts = colorval.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
    delete(parts[0]);
    for (var i = 1; i <= 3; ++i) {
        parts[i] = parseInt(parts[i]).toString(16);
        if (parts[i].length == 1) parts[i] = '0' + parts[i];
    }
    return '#' + parts.join('');
}

var CreateEventPanelEmp = function() {
  var self = this;
  self.el = $("#createEventPanelEmp");

  self.show = function(start, end, ghostEventElement) {
    var humanTime = function(date) {
      return $.fullCalendar.formatDate(date, 'ddd h:mmtt');
    }
    self.el.find('.time-range').html(humanTime(start) + " - " + humanTime(end));
    self.el.find('#start-time-input').val(localDateString(start));
    self.el.find('#end-time-input').val(localDateString(end));

    self.el.modal();
  }


  self.hide = function() {
    self.el.modal('hide');
    self.el.find('#employee-obligation-form')[0].reset();
    toggle_repeat_fields($('#repeat-toggle'));
  }

  self.cancel = function() {
    employee_calendar.fullCalendar('unselect');
  }

  self.el.find('.btn.cancel').on('click', self.cancel);
}

var createPanelEmp = new CreateEventPanelEmp();

$('#createEventPanel').popover({
  html: true,
  title: function() {
    return $("#popover-title").html();
  },
  content: function() {
    return $("#popover-content").html();
  }
});

var CreateEventPanel = function() {
    var self = this;
	self.el = $('#create-event-panel');
    // maps name to id
    self.customers = {};
    self.start = 0;
    self.end = 0;

    self.show = function(start, end, ghostEventElement) {
    	
        var humanTime = function(date) {
            return $.fullCalendar.formatDate(date, 'h:mmtt');
        }
       	$.pageslide({ href: '#create-event-panel', modal: true, iframe: true, direction: 'left' } );
 
       	self.el = $('#pageslide').find('#create-event-panel');
       	self.el.find("#customers").chosen();
        self.el.find('#customers').focus(); 

        self.el.find('.time-range').html($.fullCalendar.formatDate(start, 'ddd, MMM d') + ' ' + humanTime(start) + " - " + humanTime(end));
        self.start = start;
        self.end = end;

          
       	window.calendar.fullCalendar('windowResize');  
        
    }
	
	self.reattach_events =  function () {
        		
        $pageslide = $('#pageslide');
        
        //For some reason, ON doesn't work in this case
        $pageslide.find('.fetch-customer-recent-activity').click(fetch_customer_activity);       			
        $pageslide.find(":radio").uniform();
  		$pageslide.find(":checkbox").uniform();
  		$pageslide.find("input.date_picker").each( function(i){
    		$(this).datepicker({
      			altFormat: "dd/mm/yy",
      			dateFormat: "mm/dd/yy",
      			altField: $(this).next(), 
    		})
  		})
  					
  		assignedPanel = new AssignedCleanersPanel();
  		$pageslide.find('#edit-assigned-appointments').click(function () {
  			$('#assignments-modal').appendTo("body").modal('show');	
  		});
  					
  		$pageslide.find('form').submit(function() {
    		$('button[type=submit]', this).attr('disabled', 'disabled');
    		$('input[type=submit]', this).attr('disabled', 'disabled');
		});
  					
  		manage_address_fields();
  		manage_select_toggles();
  		
  		$pageslide.find('.close-pageslide').click( function (e) {
 			e.preventDefault();
			$.pageslide.close();
			window.calendar.fullCalendar('windowResize');
		});
  		
		window.calendar.fullCalendar('windowResize');
    }    		
	
    self.hide = function() {
        self.el.hide();
    }

    self.cancel = function() {
        calendar.fullCalendar('unselect');
    }

    self.create = function(customer_id, start_time, end_time, instant_booking_id) {
    	
    	if (typeof customer_id == "undefined") {
        	var id = self.el.find('#customers').val();
      	} else {
      		var id = customer_id;
      	}
        var params = {
            customer_id: id,
            start_time: start_time || localDateString(self.start),
            end_time: end_time || localDateString(self.end),
            to_appointment: true,
            instant_booking_id: instant_booking_id
        }
        
        if (id == "") {
        	location.href = "/customers/new?" + $.param(params)
        } else {
        	
        	$.pageslide({ href: '#for-pageslide', modal: true, iframe: true, direction: 'left' } );
        	//location.href = "/appointments/new?" + $.param(params);
        	$.ajax({
       			type: 'get',
        		contentType: 'application/json',
        		url: '/appointments/new.js?' + $.param(params),

        	})
        }
    }

    self.el.find('.btn.create').on('click', function () {
    	self.create();
    });



}

var createPanel = new CreateEventPanel();

/* Page Head Appointment Create Modal */

$('#new-appointment-create-modal').on('show', function () {
	/* Only do ajax call if customer list hasn't been loaded */
	if  ($.trim($(this).find('.modal-body').html())) {
		return true;
	}
		
	$(this).find('.modal-body').html($('#loading').html());
	$.ajax( {
		url: '/customer_names_and_ids.json',
		type: 'get',
		contentType: 'application/json',
		success: function(data, status, xhr) {
			var create_modal = $('#new-appointment-create-modal');
			create_modal.find('.modal-body').html('<div class="input-append"><select class="select optional" id="customer-list"></select><button type="button" id="create-appointment-button" class="btn btn-info">Create Appointment</button></div>');
			
			var customer_list = create_modal.find('#customer-list');
			for (var i = 0; i < data.length; i++) {
				console.log(data[i])
				customer_list.append("<option value=" + data[i]["id"] + ">" + data[i]["name"] + "</option>");
			}
			create_modal.find("#create-appointment-button").click( function () {
				var customer_id = $(this).prev().val();
				console.log(customer_id);
				if (customer_id != "null")
					window.location = '/appointments/new?' + $.param({customer_id: customer_id});
				else
					window.location = '/customers/new?to_appointment=true'
			})
		}
		
	})
	
	
});

var fetch_customer_activity = function (e) {

	e.preventDefault();

	var customer_activity_modal = $('#customer-recent-activity-modal');
	customer_activity_modal.modal('show');
	
	//Do not do ajax call if customer activity has already been loaded
	if (customer_activity_modal.data("id") == $(this).data("id")) {
		return true;
	} else {
		customer_activity_modal.find('.modal-body').html($('#loading').html());
		$.ajax( {
			url: '/customers/' + $(this).data("id") + '/recent_activity.js',
			type: 'get'			
		})
	}

}

var edit_time_in_time_out = function(e) {
	e.preventDefault();
	
	var time_modal = $('#time_in_time_out_modal');
	time_modal.modal('show');
	
	time_modal.find('.modal-body').html($('#loading').html());
	$.ajax( {
		url: '/appointments/' + $(this).data("id") + '/edit_time_in_time_out.js'
	})

}

$(document).on("click", 'a.fetch-customer-recent-activity', fetch_customer_activity)

var AssignedCleanersPanel = function () {
	
	var self = this;
	self.el = $('#assignments-modal');
	
	self.el.on('hidden', function () {
    	self.el.appendTo('#assigned-employees-preview');
	})
	
	self.employee_selector_map = {}
	
	if (typeof gon !== "undefined" && gon !== null && gon.teams !== undefined) {
		self.teams = gon.teams;
		self.employee_map = gon.employee_map;
	}
	
	self.el.find('#teams-employees-fields').find('.control-group').each( function () {
		self.employee_selector_map[parseInt($(this).next().val())] = $(this).find(':checkbox');
	});
	
	self.uncheckAll = function () {
		$.each(self.employee_selector_map, function(key, value) {
			value.prop("checked", false);
		})
		
	}
	
	console.log(self.employee_selector_map);
	self.el.find('#team-field').change( function () {
		self.uncheckAll();
	
		var team = self.teams[$(this).val()];
		if (team !== undefined ) {
			$.each(team, function (idx, value) {
				var check_box = self.employee_selector_map[value];
				check_box.prop("checked", true);
			});
		}
		
		$.uniform.update();
	})
	
	self.updateEmployeesList = function(omitSavePrompt) {
		if (typeof omitSavePrompt === "undefined") { omitSavePrompt = false; }

		var team_name = $('#team-field option:selected').text();
		var assigned_preview_string = '<div><strong>' + team_name + '</strong></div>'
		
		var at_least_one = false;
		$.each(self.employee_selector_map, function (key, value) {
			if (value.prop("checked") == true) {
				at_least_one = true;
				assigned_preview_string += self.employee_map[key] + "<br>"
			}
		});
		
		if (!at_least_one) {
			assigned_preview_string += '<span class="blue">No Cleaners Assigned</span><br>'
		}
		
		if (!omitSavePrompt) {
			assigned_preview_string += '<div class="red" style="margin-top:10px">Changes (if any) have NOT yet been saved!</div>'
		}
		
		$('#assigned-employees-preview').html(assigned_preview_string);
		self.el.modal('hide');
		
	}
	
	self.el.find('#assign-cleaners-button').click( function (e) {
		self.updateEmployeesList();
		e.preventDefault();
	})
	
}


// Code to manage attached notes

$('body').on("submit", '.attached-notes-form', function () {
	if ($(this).find('#attached_note_body').val().length < 1) {
		setTimeout(function() { $('.attached-notes-form').find('input[type=submit]').removeAttr('disabled') }, 50);
		return false;
	}
})

$('body').on("click", '#attached-notes .will-paginate a', function () {
	$.getScript(this.href);
	return false;
})


var manage_address_fields = function () {
	if (typeof gon !== "undefined" && gon !== null && gon.service_addresses !== undefined) {
		$("#address-select").change(function () {
			var parent_div = $(this).closest("#addresses-wrapper");
			console.log(parent_div);
			var address = gon.service_addresses[$(this).val()];
			if (address !== undefined) {
				parent_div.find('.street').val(address["street"]);
				parent_div.find('.city').val(address["city"]);
				parent_div.find('.state').val(address["state"]);
				parent_div.find('.zip').val(address["zip"]);
			} else {
				parent_div.find('.street').val("");
				parent_div.find('.city').val("");
				parent_div.find('.state').val("");
				parent_div.find('.zip').val("");
			}
		})

	}
}


// Code to manage pay rate form fields

var set_pay_rate_label = function () {
	switch($('#pay-type-input').val())
	{
		case 'Hourly':
			$('#pay-rate').find('label').html('Hourly Rate');
			break;
		case 'Revenue Share':
			$('#pay-rate').find('label').html('Share Percentage');
			break;
		case 'Fixed Flat Rate':
			$('#pay-rate').find('label').html('Amount Per Cleaning');
			break;
	}
}

var decide_if_show_pay_rate = function () {
	switch($('#pay-type-input').val())
	{
		case 'Hourly':
			$('#pay-rate').show();
			break;
		case 'Revenue Share':
			$('#pay-rate').show();
			break;
		case 'Fixed Flat Rate':
			$('#pay-rate').show();
			break;
		default:
			$('#pay-rate').hide();		
	}
}

// Batch select methods

var get_selected_appointment_ids = function () {
	ids = new Array;
	
	$('#appointments-list').find('.appointment-select:checked').each( function () {
		ids.push($(this).attr('id'));
	});
	
	return ids;
}

$(document).ready(function() {

	$('body').on('focus', ".timepicker", function () {
		$(this).timepicker({
			template: false
		});
	})

	//customer index page functionality
	$('#customer-filter-dropdown li a').click(function() {
	  $('#customers-filter').val($(this).attr('value'));
	  build_filter();
	  return false;
	});

	$('#sort-by-filter-dropdown li a').click(function() {
	  $('#sort-by').val($(this).attr('value'));
	  build_filter();
	  return false;
	});

	function build_filter() {
	  var params = {
	    filter: $('#customers-filter').val(),
	    sort_by: $('#sort-by').val(),
	    letter: $('.letter-btn.selected').text()
	    };
	    window.location = '/customers?' + $.param(params);
	};

	$('.letter-btn').click(function() {
	  $('.letter-btn').removeClass('selected');
	  $(this).addClass('selected');
	  build_filter();
	  return false;
	});

  $('#export_btn').click(function() {
    $('#customer-export-modal').modal('hide');
  });

	$('#customers-query-submit').click(function () {
	  //When searching, ignore currently selected date range
	  location.search = $.param({'query': $('#customers-search-query').val()});
	});

	$('#customers-search-query').keypress(function(event){
  		if(event.keyCode == 13){
    		$('#customers-query-submit').click();
  		}
	});

	$('#employees-filter').change(function (){
		var params = {
			filter: $(this).val()
  	 	};
    	window.location = '/employees?' + $.param(params);
	});
	
	$('#instant-bookings-filter').change(function (){
		var params = {
			filter: $(this).val()
  	 	};
    	window.location = '/instant_bookings?' + $.param(params);
	});
	
	$('.colorpicker').colorPicker();
	
	$('.draggable').draggable({
		zIndex: 10000000
	});

	$('#show-password-fields').click(function () {
		$(this).hide();
		$('#password-fields').show();
		
	});
	
	$('#pay-type-input').change(function () {
		$('#pay-rate-input').val('');
		set_pay_rate_label();
		decide_if_show_pay_rate();
	})
	set_pay_rate_label();
	decide_if_show_pay_rate();	
	
	//For employee edit page
	$('#allow-employee-sign-in').click(function () {
		console.log($(this).is(':checked'));
		if ($(this).is(':checked') == '1') {
			$('#password-fields-wrapper').show();
			$('#show-password-fields').click();
		} else {
			$('#password-fields-wrapper').hide();
		}
	});
	
	
	
	$('#generate-template-button').click(function () {
		var template_select = $(this).prev();
		window.location = '/email_templates/' + template_select.val() + '/generate?' + $.param({appointment_id: template_select.data('appointment')});
	});
	
	$('#generate-customer-template-button').click(function () {
		var template_select = $(this).prev();
		window.location = '/email_templates/' + template_select.val() + '/generate?' + $.param({customer_id: $(this).data('customer')});
	});

	$('#generate-text-template-button').click(function () {
		var template_select = $(this).prev();
		window.location = '/text_templates/' + template_select.val() + '/generate?' + $.param({appointment_id: template_select.data('appointment')});
	});
	
	var assigned_cleaners_panel = new AssignedCleanersPanel();
	
	$(document).on("click", "a.set-billing-link", function (e) {
		e.preventDefault();
		
		var parent_div = $(this).closest("div");
		var billing_div = $("#billing-address-fields");
		
		billing_div.find('.street').val( parent_div.find('.street').val() );
		billing_div.find('.city').val( parent_div.find('.city').val() );
		billing_div.find('.state').val( parent_div.find('.state').val() );
		billing_div.find('.zip').val( parent_div.find('.zip').val() );
	})
	
	manage_address_fields();
	
	if (typeof gon !== "undefined" && gon.customer_id !== undefined) {
    	createPanel.create(gon.customer_id, gon.start_time, gon.end_time, gon.instant_booking_id);
    }	
    
    if (typeof gon !== "undefined" && gon.appointment_id !== undefined) {
   		$.ajax({
       		type: 'get',
        	contentType: 'application/json',
        	url: '/email_templates/confirmation_email/' + gon.appointment_id + '.js'
        })
    }
    
    $('#new-appointment-button').click(function () {
    	if ($(this).data("date") != null && $(this).data("date") != "")
    		d = new Date($(this).data("date"));
    	else
    		d = new Date();
    		
    	d.setHours(0,0,0,0)
    	createPanel.show(d, d);
    });
    
    $("[data-toggle='tooltip']").tooltip();
    
	$('.close-pageslide').click( function (e) {
		e.preventDefault();
		$.pageslide.close();
		window.calendar.fullCalendar('windowResize');
	});
	
	// Logic for print route sheet and print work order modal
	$('.work-order-select').change(function () {
		if($(this).val() == "Employees"){
			$(this).closest('form').find('.teams-list').hide('blind');
			$(this).closest('form').find('.employees-list').show('blind');
		} else {
			$(this).closest('form').find('.employees-list').hide('blind');
			$(this).closest('form').find('.teams-list').show('blind');			
		}
	});
	
	$('.simple-schedule').click(function () {
		if ($(this).is(':checked')) {
			$(this).closest('form').find('.teams-employees-lists-wrapper').hide('blind');
		} else {
			$(this).closest('form').find('.teams-employees-lists-wrapper').show('blind');
		}
	});
	
	$('#email-or-print').find('[type=radio]').click(function () {
		if ($(this).val() == "email") {
			$('#print-work-order').hide();
			$('#email-work-order').show();
		} else {
			$('#email-work-order').hide();
			$('#print-work-order').show();			
		}
	});


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
	
	$('.best_in_place').best_in_place();
	$('.deductions,.bonus').bind('ajax:success', function () {
		var new_total_pay = Number($('#total-wages').html().replace(/[^0-9\.]+/g,""));
		new_total_pay -= parseFloat(Number($('.deductions').html().replace(/[^0-9\.]+/g,"")));
		new_total_pay += parseFloat(Number($('.bonus').html().replace(/[^0-9\.]+/g,"")));

		$('#total-pay-field').html('$' + new_total_pay.formatMoney(2));
	});
	
	$('.add-pay-rate').click(function (e) {
		e.preventDefault();
		
		$.ajax({
			url: '/employees/' + $(this).data('id') + '/pay_rate',
			data: {
				entry_id: $(this).data('entry'),
				source: $(this).data('source')
			}
		});
	})
	
	
	//Logic to control modal which changes job wage
	$('.open-edit-fixed-rate-modal').click(function (e) {
		e.preventDefault();
		
		$job_modal = $('#job-wage-modal');
		$job_modal.modal('show');
		$job_modal.find('.modal-body').html($('#loading').html());
		
		$.ajax({
			url: '/assignments/' + $(this).data('id') + '/edit_fixed_rate',
			success: function () {
				$job_modal.find('#job-wage,#job-extras').change(function () {
					var total_pay = 0;
					total_pay += parseFloat(Number($job_modal.find('#job-wage').val().replace(/[^0-9\.\-]+/g,"")));
					total_pay += parseFloat(Number($job_modal.find('#job-extras').val().replace(/[^0-9\.\-]+/g,"")));
			
					$job_modal.find('#total-job-pay').html('$' + total_pay.formatMoney(2));
				});		
			}
		});
		
	});

	//Logic to control modal which changes job wage
	$('.open-edit-hourly-modal').click(function (e) {
		e.preventDefault();
		
		$job_modal = $('#job-wage-modal');
		$job_modal.modal('show');
		$job_modal.find('.modal-body').html($('#loading').html());
		
		$.ajax({
			url: '/assignments/' + $(this).data('id') + '/edit_hourly',
			success: function () {
				$job_modal.find('#job-wage,#job-extras').change(function () {
					var total_pay = 0;
					total_pay += parseFloat(Number($job_modal.find('#job-wage').val().replace(/[^0-9\.\-]+/g,"")));
					total_pay += parseFloat(Number($job_modal.find('#job-extras').val().replace(/[^0-9\.\-]+/g,"")));
			
					$job_modal.find('#total-job-pay').html('$' + total_pay.formatMoney(2));
				});		
			}
		});
		
	});

	//Logic to control modal which changes job wage
	$('.open-edit-revenue-share-modal').click(function (e) {
		e.preventDefault();
		
		$job_modal = $('#job-wage-modal');
		$job_modal.modal('show');
		$job_modal.find('.modal-body').html($('#loading').html());
		
		$.ajax({
			url: '/assignments/' + $(this).data('id') + '/edit_revenue_share',
			success: function () {
				$job_modal.find('#job-wage,#job-extras').change(function () {
					var total_pay = 0;
					total_pay += parseFloat(Number($job_modal.find('#job-wage').val().replace(/[^0-9\.\-]+/g,"")));
					total_pay += parseFloat(Number($job_modal.find('#job-extras').val().replace(/[^0-9\.\-]+/g,"")));
			
					$job_modal.find('#total-job-pay').html('$' + total_pay.formatMoney(2));
				});		
			}
		});
		
	});

	// Only works if there is just ONE template on the page and it is 
	$('.preview-email-template').click( function () {
		$('#preview-email-template-modal').find('.modal-body').html($('#loading').html());
		$('#preview-email-template-modal').modal('show');
		
		//Send currently edited template if available
		var parent_widget = $(this).closest('.content-box');
		var body_template = null;
		var subject_template = null;
		
		if (CKEDITOR.instances["email_template_body"]) {
			subject_template = parent_widget.find('#email_template_title').val();
			body_template = CKEDITOR.instances["email_template_body"].getData();
		}
		
		$.ajax( {
			url: '/email_templates/' + $(this).data('id') + '/preview.js',
			type: 'post',
			contentType: 'application/json',
			data: JSON.stringify({
				subject_template: subject_template,
				body_template: body_template,
				appointment_id: $(this).data('appointment-id')
			}),
			error: function(xhr, status, error) {
				$('#preview-email-template-modal').find('.modal-body').html(
					'<span class="red">Sorry! An error occured while parsing the email template. Please save the template and try again</span>'
				);
			}
		});
		
	});

	$('.preview-text-template').click( function () {
		$('#preview-text-template-modal').find('.modal-body').html($('#loading').html());
		$('#preview-text-template-modal').modal('show');
		
		var body_template = null;
		
		$.ajax( {
			url: '/text_templates/' + $(this).data('id') + '/preview.js',
			type: 'post',
			contentType: 'application/json',
			data: JSON.stringify({
				body_template: body_template,
				appointment_id: $(this).data('appointment-id')
			})
		});
		
	});

	$('.show-user-admin').click(function (e) {
		e.preventDefault();
		
		$('#admin-user-summary-modal').modal('show');
		
		var user_id = $(this).data('user-id');
		$.ajax({
			url: '/admins/user_summary/' + user_id,
		})
	});

	$('body').tooltip({
	    selector: '[rel=tooltip]'
	});
	
	/* LAUNCH */
	$('#sign-up-modal, .sign-up-form').find('#expiry-date').datepicker({
    changeMonth: true,
    changeYear: true,
    showButtonPanel: true,
    dateFormat: 'mm/yy',
    onClose: function(dateText, inst) { 
        var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
        var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
        $(this).datepicker('setDate', new Date(year, month, 1));
    	}
	});

	setTimeout(function(){ $('#sales-cart-button').show("fade") }, $('#sales-cart-button').data("seconds")*1000);


});
