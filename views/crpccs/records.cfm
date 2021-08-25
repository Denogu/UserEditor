<div style="color: #6a8dac;" class="row">
  <div class="col-sm-12">
    <h3 >Assignment Treatments</h3>
    <span class="help-block">(Click on a row to edit)</span> 
  </div>
</div>

<div class="table-responsive">
  <table  id="atm_table" class="table table-hover" report_name="Assignment Treatment Mappings">
    <thead>
      <tr>
        <th>ID</th>
        <th>Assignment type</th>
        <th>Package definition</th>
        <th>Cutoff to expiration</th>
        <th>Medication</th>
        <th>Treatment arm</th>
      </tr>
    </thead>
    <tbody>
      <cfoutput query="view_data.atm_records">
        <tr>
          <td>#id#</td>
          <td>#assignment_type_id#</td>
          <td>#package_definition_id#</td>
          <td>#cutoff_prior_to_expiration#</td>
          <td>#medication#</td>
          <td>#treatment_arm#</td>
        </tr>
      </cfoutput>
    </tbody>
  </table>
</div>

<div id="atm_edit_form_modal" class="modal custom fade" role="dialog"><div class="modal-dialog"></div></div>