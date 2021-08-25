//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {
	
	  
  //username field is readonly. backspace on this would field would navigate to previous page. this ia a hack to prevent this behaviour.
  $('input#user_name').on('keydown', function(event) {
	 event.preventDefault(); 
	 return false;
  });
		
  $('#user_registration_form').on('click','a#new_captcha_link', function() {
    $('#captcha_div').load('captcha?_=' + new Date().getTime());
    return false;
  });
  
  
  $('#user_role').on('change',function() {
    $('#study_site_div').toggle();
  });
   
});