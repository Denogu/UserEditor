var client_offset = function (){
  var d = new Date();
  return d.getTimezoneOffset();
};


function stopPropagation(evt) {
  if(evt.stopPropagation !== undefined) {
    evt.stopPropagation();
	} else {
	  evt.cancelBubble = true;
	}
}


function get_report_file_name() {
  return '2002 ' + $('table[id$=_report]').attr('report_name');
}


//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {	 
	$('#utc_offset').val(client_offset);
  
  $('input.ssn').on('', function() {
    var ssn = $(this).val();
  });

  $('a#switch_site_link_admin').on('click', function(){
	  var href = $(this).attr('href');
	  $('#switch_site_form_modal_admin .modal-dialog').load(href); 	 
  });
  
  $('a#switch_site_link_user').on('click', function(){
	  var href = $(this).attr('href');
	  $('#switch_site_form_modal_user .modal-dialog').load(href)  	
  });

  addTimeoutDialog();
 

	if($('table[id$=_report]').length) {
		var reports_table = $('table[id$=_report]').DataTable({	
				order: [],	
				pageLength: 25,
				dom: "<'row'<'col-sm-6'B><'col-sm-6'f>>" +
					"<'row'<'col-sm-12'tr>>" +
					"<'row'<'col-sm-5'i><'col-sm-7'p>>", 				  
				buttons: [
					{extend :'excel', className: 'btn btn-info', title: get_report_file_name(), titleAttr: 'Save as Excel file'},
					{extend :'csv', className: 'btn btn-info', title: get_report_file_name(), titleAttr: 'Save as CSV file'},
					{ extend :'pdf', 
						className: 'btn btn-info', 
						title: get_report_file_name(), 
						titleAttr: 'Save as PDF', 
						orientation: 'landscape',
						customize: function(doc) {
								
								doc.styles.tableHeader = {
									bold: true,
									color: 'white',
									fontSize: 14,
									fillColor: '#000000',
									alignment: 'center',
									width: '100%',
								};
								
								doc.styles.tableBodyOdd = {
									fontSize: 11,
									fillColor: '',
									alignment: 'center',
								};
								doc.styles.tableBodyEven = {
									fontSize: 11,
									fillColor: '',
									alignment: 'center',
								};				
								doc.content.layout = 'noBorders';	
								doc.content.pageMargins = [0,0,0,0]	;	
								console.log(doc);		 
						}
					}],
				orderCellsTop: true				  
			});		
			
			// Adds placeholder in filter inputs.
			$('table[id$=_report] thead tr#filterrow th').each(function() {
				var title = $('table[id$=_report] thead th').eq( $(this).index() ).text();
				$(this).html('<input type="text" style="width: 100%; font-size: 0.8em;" class="form-control col_filter" onclick="stopPropagation(event);" placeholder="Search ' + title + '" />');
			}); 					

		// Adds filtering to each column
		$('table[id$=_report] thead input').on('keyup change mouseup', function() {	  
				reports_table
					.column($(this).parent().index()+':visible')
					.search(this.value)
					.draw();
		});
	}

});



function addTimeoutDialog() {
	if($('div#timeout_div').length) { 
	 	var timeout = $('#timeout_value').html().trim();
		var logout_redirect_url = $('#logout_redirect_url_value').html().trim();
		var logout_url = $('#logout_url_value').html().trim();
		var keep_alive_url = $('#keep_alive_url_value').html().trim();
		
    $.timeoutDialog({
			timeout: timeout,
			logout_redirect_url: logout_redirect_url,
			logout_url: logout_url,
			keep_alive_url: keep_alive_url,
			title: 'Session expiring',
			keep_alive_button_text: 'Yes, stay signed in',
			sign_out_button_text: 'No, sign out'
		});		
	}
}




function verify_input_field(value, pattern, error_container_id) {
  var regex_pattern = new RegExp(pattern);
	
  if (value.search(regex_pattern) == -1) {
	  $('#' + error_container_id).removeClass('hidden');
		return false;
	} else {
	  $('#' +error_container_id).addClass('hidden');
		return true;
	}	  
}


function ajaxRequest(target, values) {	
	var response = '';
	var request = $.ajax({							
							    method: "POST",
							    async: false,
							    cache: false,
							    url: target,
							    data: values
						    });
	request.fail(function(jqXHR, textStatus) {
	  show_error_message("Request failed: " + textStatus, 'Error');
	});
	
	request.done(function(msg) {
		addTimeoutDialog();
		try {
		  response = JSON.parse(msg);
		}
		catch(err) {
		  show_error_message(msg, 'Error');	
		}
	});		
	
	return response;
}


function handle_ajax_request(action_method) {
  $('form').submit(function(e) {
    //Prevent form submission.
    e.preventDefault();

    var serialized_form_data = $(this).serialize();
    var response = ajaxRequest(action_method, serialized_form_data);
    
    //Use captialized property names as ColdFusion serializes variable names into capital letters.
    if(response.IS_SUCCESS) {
      $('#form_div').addClass('alert alert-success').html(response.MESSAGE);
    } else {
      show_error_message_div(response.MESSAGE);
    }
  });
}


function show_error_message(message, title) {
  if (message !== '') {
    $('#error_modal_body').html('<div class="alert alert-danger">' + message + '</div>');
  }
  
  $('#error_modal_title').html(title);  
  $('#errorModal').modal({backdrop: 'static', keyboard: false});
  
  return false;
}


function is_error(msg) {
  if ( msg.indexOf("Error: ") == -1)  {
    return false;
  }
  return true;
}


function show_error_message_div(message) {
  $('#error_message_div').addClass('alert alert-danger').html(message);
}


function hide_error_message_div() {
  $('#error_message_div').removeClass('alert alert-danger').html('');
}


function form_errors(el) {
  var errors = new Array();
  var form = $(el);

  form.children('.validated_field').each(function () {
    var field_errors = new Array();
    alert($(this).attr('pattern'));
  });

  return errors;
}


function validation_errors_as_html_list(errors) {
  var html_list = "<ul>";
  for(i=0; i < errors.length; i++) {
    html_list = html_list + "<li>" + errors[i] + "</li>";
  }

  html_list = html_list + "</ul>";
  return html_list;
}

    
Date.prototype.mmddyyyy = function() {
  var date_obj = this;
  var month = new String(date_obj.getMonth()+1).lpad("0",2);
  var day = new String(date_obj.getDate()).lpad("0",2);

  return month + "/" + day + "/" + date_obj.getFullYear();
}


String.prototype.lpad = function(padString, length) {
  var str = this;
  
  while (str.length < length)
    str = padString + str;
  return str;
}
