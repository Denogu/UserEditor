//$(document).ready is where you add event handlers to elements.
$(document).ready(function() {
//Date columns in dataTable using this format will sort using date sorting rather than string sorting
  $.fn.dataTable.moment( 'MM/DD/YYYY' );	

  var fit_results_table = $('#fit_results_table').DataTable({	
    "lengthMenu": [[25,50,100],[25,50,100]],
		"order": [[6, "desc"]],
		"processing": true,
		"serverSide": true,
		"ajax": "./_dataTable_fit_results.cfm"										  					  
					});			

  /* $('#fit_results_table').on('click', 'a.cprsEntryBtn', function() {
    var target = $(this).attr('href');
    $('div#cprs_modal').load(target, function() {
      $(this).modal('toggle');
    });
    return false;
  });
 */

  $('#cprs_modal').on('submit', 'form.update_fit_result_form', function() {
    var rec_id = $(this).data('id');
    var target = $(this).attr('action');
    var form_data = $(this).serialize();
    $.post(target, form_data, function( response ) {
      var parsed_response = JSON.parse(response);
      $('div#cprs_form_modal_body').html( parsed_response.MESSAGE );
      $('td#cprs_field_' + rec_id).html(parsed_response.CPRS_FIELD_VALUE);
    });
    return false;
  });

});
