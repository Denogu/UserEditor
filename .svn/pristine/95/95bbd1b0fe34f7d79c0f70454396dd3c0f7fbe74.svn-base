//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {
  
  $("form[name='reset_password_form']").on('submit', function(event){
      event.preventDefault();
      var target = $(this).attr('action');
      var values = $(this).serialize();
      var response = ajaxRequest(target, values);
      if(response.IS_SUCCESS) {
      $('div#form_div').addClass('alert alert-success').html(response.MESSAGE);
      }
      else {
        show_error_message_div(response.MESSAGE);
      }
  });

  $("input").focus(function() {
    hide_error_message_div();
  });
});