//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {
	
  var users_table = $('#user_table').DataTable({	
						lengthMenu: [[10, 25, 50, -1],[10, 25, 50, "All"]] ,  
						pageLength: 25,										  					  
					  rowCallback: function(row, data) {
						$(row).on('dblclick', function() {
						  $('#user_edit_form_modal .modal-dialog .modal-content .modal-body').load('edit?id=' + data[1]);
						  $('#user_edit_form_modal').modal({backdrop: "static"});
						}); 
					  }
					});			

  $('#tab_form').click(function (e) {
	e.preventDefault();
	$(this).tab('show');
  });

  $("body").on('keyup', "#edit_justification_form", function(){
	
	var value = document.getElementById('edit_justification_form').value;
	var submit_button = document.getElementById("edit_submit_button");
	var update_text = document.getElementById("update_error");
	var update_group = document.getElementById("update_form_group");

	if (value.length > 4) {
		submit_button.disabled = false;
		submit_button.classList.remove('disabled');
		update_text.hidden = true;
		update_group.classList.remove('has-error');
	}
	
	else
	{
		submit_button.disabled = true;
		submit_button.classList.add('disabled');
		update_text.hidden = false;
		update_group.classList.add('has-error');
	}
	
  });

  $('#user_edit_form_modal').on('hidden.bs.modal', function () {
	window.location.reload(); 
  });

  $('#user_edit_form_modal').on('change', '#role_id', function() {
    $('#study_site_div').toggle();
  });


	$('#user_edit_form_modal_body').on('submit', 'form[name="edit_user_form"]', function(event){
		event.preventDefault();
		var any_checked = $('input[name="site_access"]:checked').length > 0;
		if (any_checked) {
			}
		else {
			$('#user_edit_form_modal_body')
			.html('<div class="alert alert-danger">User must have access to at least one site. If they should not, their account must be deactivated by an administator.</div>');
			return;
		}
		var target = $(this).attr('action');
		var values = $(this).serialize();
		var response = ajaxRequest(target, values);
		var div_class = (response.IS_SUCCESS == true)? 'alert alert-success' : 'alert alert-danger';
		$('#user_edit_form_modal_body').html('<div class="'+ div_class +'">' + response.MESSAGE + '</div>');
		$('.modal-footer').css('display', 'block');
	});

});