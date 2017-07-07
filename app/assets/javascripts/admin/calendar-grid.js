var GridInformation = function () {
	var self = this;

	self.events = {};
	self.employee_calendars = {}
	self.date = null;
	self.active = false;
	self.source = $('#source');
	
	self.init = function () {
		self.active = true;
		self.date = new Date();
		self.initialize_all_calendars();

		$('#date-prev').click(function () {
			self.date.setDate(self.date.getDate() - 1);
			self.refreshDateInfo();
		});
	
		$('#date-next').click(function () {
			self.date.setDate(self.date.getDate() + 1);
			self.refreshDateInfo();
		});	
		
		$("#datepicker-focus").datepicker({
			onSelect: function () {
				self.date = new Date($(this).val());
				self.refreshDateInfo();			
			}
		});
		
		$('#date-wrapper').click( function () {
			$('#datepicker-focus').datepicker('show');
		});
		
		$('#selected-date').html($.datepicker.formatDate("DD, MM d, yy", self.date));
		
		$('#refresh-calendar-button').click(function () {
			self.refreshDateInfo();
		});
		
		self.source.change(function () {
			self.refreshDateInfo();
		});
		
		self.fetchEvents();
	
	}
	
	self.initialize_all_calendars = function () {
		$('.calendar-item').each( function () {
			self.employee_calendars[$(this).data("id")] = $(this).fullCalendar({
				header: false,
				defaultView: "agendaDay",
				height: 1400,
				allDaySlot: false,
				eventClick: eventPopoverPanel.show,
			});
		});
	}
	
	self.reinitialize_employee_calendars = function () {
		$('#grid-content').find('.calendar-item').each( function () {
			self.employee_calendars[$(this).data("id")] = $(this).fullCalendar({
				header: false,
				defaultView: "agendaDay",
				height: 1400,
				allDaySlot: false,
				eventClick: eventPopoverPanel.show,
			});
		});
	}
	
	self.redraw_employee_calendars = function () {
		var grid_headers = $('#grid-content').find('#grid-headers');
		var grid_calendars = $('#grid-content').find('#grid-calendars');
		
		grid_headers.empty();
		grid_calendars.empty();
		
		for (id in self.events) {
			if (id != 0) {
				grid_headers.append('<div class="header-item">' + filterObject.names_by_id[self.source.val()][id] + '</div>');
				grid_calendars.append('<div class="calendar-item" data-id="' +  id + '"></div>');
			}
		}
		
		set_calendar_grid_dimensions();
	}
	
	self.refreshDateInfo = function() {
		if (!self.active) {
			return false;
		}
		
		$('#selected-date').html($.datepicker.formatDate("DD, MM d, yy", self.date));
		$('#new-appointment-button').data("date", $.datepicker.formatDate("mm/dd/yy", self.date))

		for (id in self.employee_calendars) {
			self.employee_calendars[id].fullCalendar('removeEventSource', self.events[id]);
		}

		self.fetchEvents();
		
	}
	
	
	self.fetchEvents = function () {
		var start_and_end = self.get_beginning_and_end_of_day(self.date);	
		$.ajax({
			type: "POST",
			url: '/get_appts_grid.json',
			data: {
				source: self.source.val(),
				start: start_and_end[0],
				end: start_and_end[1],
				filter_show: JSON.stringify(filterObject.filter_show)
			},
			success: function(data) {
				self.events = data;
				
				self.redraw_employee_calendars();
				self.reinitialize_employee_calendars();
				
				for (id in self.employee_calendars) {
					self.employee_calendars[id].fullCalendar('addEventSource', self.events[id]);
					self.employee_calendars[id].fullCalendar('gotoDate', self.date);
				}
			}
			
		})		
	}
	
	self.get_beginning_and_end_of_day = function (date) {
		var date = new Date(date);
		date.setHours(0,0,0,0)
		var start = date/1000;
		
		date = new Date(date);
		date.setHours(23,59,59,999);
		var end = date/1000;
		
		return [start, end];
	}

}

var gridObject = new GridInformation();

var set_calendar_grid_dimensions = function () {

    var wwidth = 0;
    var lleft = 0;

    $('#grid-content').find('.header-item').each(function() {

        wwidth += $(this).outerWidth(true);
        lleft = $(this).offset().left;

    });

    $('#grid-content').find('#grid-headers,#grid-calendars').width(wwidth);

    $('#grid-content,#unassigned-panel').find('#grid-calendars').css('top', $('#grid-content').find('#grid-headers').outerHeight());
    
    $('#grid-content').trigger('scroll');

}


$(document).ready(function() {

	set_calendar_grid_dimensions();

    $('#grid-content').scroll(function() {
		
		var top_offset = $('#grid-content').scrollTop();
        $('#grid-content,#unassigned-panel').find('#grid-headers').css('top', top_offset);
        $('#unassigned-panel').scrollTop(top_offset);

    });

	$('#grid-content,#unassigned-panel').scrollTop(250);
	
	// This is going to be confusing
  	filterObject.init();  

	//Only fetch events if on calendar grid page
	if ($('.calendar-item').length > 0) {
		gridObject.init();
	}
	
});