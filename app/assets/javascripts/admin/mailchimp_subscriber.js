$(document).on('change', '#sync_list_name', function(){
  if($(this).val() == 'new_list')
  {
    $(".sync_new_list").show();
  }
  else
  {
    $(".sync_new_list").hide();
  }
});

$(document).ready(function(){


  $('#fetch-mailchimp-sync-contacts-modal').click( function () {
    $('#mailchimp-sync-contacts-modal').find('.modal-body').html($('#loading').html());
    $('#mailchimp-sync-contacts-modal').modal('show');

    $.ajax( {
      type: 'post',
      contentType: 'application/json',
      url: '/customers/mailchimp_lists',
    });
  });

});