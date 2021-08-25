//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {
	
  var users_table = $('#atm_table').DataTable({	  				  					  
					  rowCallback: function(row, data) {
						$(row).on('click', function() {
						  $('#atm_edit_form_modal .modal-dialog').load('../crpccs/edit_assignment_treatment?id=' + data[0]);
						  $('#atm_edit_form_modal').modal({backdrop: "static"});
						}); 
					  }
					});			
					
					
	//Check for justification text.
  $('#atm_edit_form_modal').on('submit', '#edit_atm_form', function(e) {
		var justification = $('#justification').val();
		var just_trimmed = $.trim(justification);

    if(just_trimmed.length == 0) {
      $('#justification_error').addClass('alert alert-danger').html("Please provide a justification.");
			//Prevent form submission.
			e.preventDefault();
		}
	});

});