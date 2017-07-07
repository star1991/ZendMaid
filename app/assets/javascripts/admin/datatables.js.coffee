$ ->

  getURLParameter = (sParam) ->
    sPageURL = window.location.search.substring(1)
    sURLVariables = sPageURL.split('&')
    for elem in sURLVariables
        sParameterName = elem.split('=')
        if sParameterName[0] == sParam
            return sParameterName[1];




#initialize the data tables
  $("#appointments-datatable").dataTable(
    bJQueryUI: false
    bAutoWidth: false
    sPaginationType: "bootstrap"
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    oLanguage: {
      sEmptyTable: "No cleanings scheduled"
    }
  )

  $('#appointments-datatable_wrapper').find('.table-header').append($('#customer-new-appointment-link'))

  $("#subscriptions-datatable").dataTable(
    bJQueryUI: false
    bAutoWidth: false
    bSort: false
    sPaginationType: "bootstrap"
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    oLanguage: {
      sEmptyTable: "No cleanings scheduled"
    }
  )   

  $(".users-datatable").dataTable(
    bJQueryUI: false
    bAutoWidth: true
    sPaginationType: "bootstrap"
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
  ) 
  
  $("#payrolls-datatable").dataTable(
    bJQueryUI: false
    bAutoWidth: false
    aaSorting: []
    sPaginationType: "bootstrap"
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    oLanguage: {
      sEmptyTable: "Run your first payroll by clicking the 'Run Payroll' button in the upper right corner of this panel"
    }
  )
  
  
  $('#customers-datatable_wrapper').find('.table-header').append('
    <div class="pull-left" style="line-height: 61px;">
      <label>
      <a href="/customers/new" class="btn btn-danger">
          <i class="icon-plus-sign"></i> New Customer
      </a>
      
    </div>');

  $("#employees-datatable").dataTable(
    bJQueryUI: false
    bAutoWidth: true
    sPaginationType: "bootstrap"
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
  )
  
  $('#instant-booking-table').dataTable(
    bJQueryUI: false
    bAutoWidth: true
    sPaginationType: "bootstrap"
    aaSorting: []
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
  )
  
  top_spans = $('#instant-booking-table_wrapper').find('.span6')
  $(top_spans[0]).append('
    <div class="pull-right">
      <span style="margin-right:5px">Filter </span>
      <select class="width100" id="instant-bookings-filter" name="instant-bookings-filter">
        <option value="all">All</option>
        <option value="pending" selected="selected">Pending</option></select>
      </div> 
  ');
  urlParam = getURLParameter("filter")
  if urlParam != undefined
    $('#instant-bookings-filter').val(urlParam);
  else
    $('#instant-bookings-filter').val("pending");
  
