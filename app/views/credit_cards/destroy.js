$("<%= escape_javascript("div[data-card-id='#{@credit_card.id}'".html_safe) %>").effect('highlight', {}, 400, function(){
    $(this).fadeOut('fast', function(){
        $(this).remove();
    });
});

toastr.info("The credit card was deleted successfully!");