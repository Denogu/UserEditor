<div class="modal-content">
	<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
    <h4 class="modal-title">Assignment Treatment</h4>    
  </div> 

  <div class="modal-body">
    <cfoutput>
      <form id="edit_atm_form" name="edit_atm_form" action="update_assignment_treatment" method="post">
        <input type="hidden" class="form-control" name="id" value="#view_data.id#" readonly>

        <div class="form-group">
          <label>Treatment arm</label>
          <input type="text" class="form-control" name="treatment_arm" value="#view_data.treatment_arm#" readonly>
        </div>
        
        <div class="form-group">
          <label>Medication</label>
          <input type="text" class="form-control" name="medication" value="#view_data.medication#" readonly>
        </div>
        
        <hr/>

        <div class="form-group">
          <label>Cutoff to expiration (days)</label>
          <input type="number" min="0" max="1000" class="form-control" name="cutoff_prior_to_expiration" value="#view_data.cutoff_prior_to_expiration#" required>
        </div>

        <div class="form-group">
          <label>Justification</label>
          <textarea class="form-control" id="justification" name="justification" maxlength="1000" required></textarea>
        </div>

        <div id="justification_error">
        </div>

        <hr/>

        <input type="submit" class="btn btn-primary" name="edit_atm_form_submit" value="Update"/>
        <button type="button" class="btn btn-danger pull-right" id="cancel_button" data-dismiss="modal">Cancel</button>
      </form>
    </cfoutput>
  </div>
</div>    