var manage_payment_gateway_fields = function () {
    if ($('#allow-cc-hidden').val() == 't') {
        $('#payment-gateway-fields').show('blind');
    } else {
        $('#payment-gateway-fields').hide();
    }
}


var manage_credit_cards = function (e) {
    e.preventDefault();

    var credit_card_modal = $('#manage-credit-card-modal');

    credit_card_modal.modal('show');

    credit_card_modal.find('.modal-body').html($('#loading').html());
    $.ajax( {
        url: '/customers/' + $(this).data("id") + '/manage_credit_cards.js?' + $.param({appointment_id: $(this).data("appointment-id")}),
        success: toggle_new_card_fields
    });

}

var toggle_new_card_fields = function (e) {
    $token = $('#manage-credit-card-modal').find("#card-token").val();
    if ($token == "") {
        $('#manage-credit-card-modal').find("#new-card-form-fields").show('blind');
    } else {
        $('#manage-credit-card-modal').find("#new-card-form-fields").hide('blind');
    }

}

$(function() {

    $('#toggle-cc').toggles({type:'select', text: {on: "YES", off: "NO"}});

    if ($('#allow-cc-hidden').val() == 't') {
        $('#toggle-cc').data('toggles').toggle();
    }
    
    $('#toggle-cc').click( function () {
        var toggle_state = $(this).data('toggle-active');
        if (toggle_state) {
            $('#allow-cc-hidden').val('t');
        } else {
            $('#allow-cc-hidden').val('f');
        }
        manage_payment_gateway_fields()

    });

    //Set initial state of payment gateway fields correctly
    manage_payment_gateway_fields();

    $('#manage-credit-card').click(manage_credit_cards);

    $('#manage-credit-card-modal').on('change', '#card-token', toggle_new_card_fields);
});



// Note: may need to add this to css temporarily before datepicker is shown
//.ui-datepicker-calendar {
//    display: none;
//    }
