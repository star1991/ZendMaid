$('#manage-credit-card-modal').modal("hide");

toastr.success("Cha-ching! The credit card has been successfully processed!");

<% if params[:appointment_id].present? %>
    $.ajax( {
	  url: "<%= escape_javascript("/appointments/preview_panel/#{params[:appointment_id]}.js").html_safe %>",
	  type: 'get',
	  contentType: 'application/json'
	});
<% elsif @credit_card_new %>

	<% if @customer.credit_cards.count == 1 %>
		$('#credit-cards-container').empty();
	<% end %>

	$('#credit-cards-container').append("<%= escape_javascript(render('credit_card_with_delete', :credit_card => @credit_card).html_safe) %>");

<% else %>

<% end %>