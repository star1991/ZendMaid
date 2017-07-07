var $credit_card_modal = $('#manage-credit-card-modal');
$credit_card_modal.find('.modal-body').html("<%= escape_javascript(render('customers/manage_credit_card_modal_content').html_safe) %>");

$credit_card_modal.find(":checkbox").uniform();

$credit_card_modal.find('#expiry-date').datepicker({
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

toggle_new_card_fields();