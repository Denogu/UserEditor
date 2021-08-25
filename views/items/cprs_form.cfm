<cfoutput>  
<div class="modal-dialog">
  <div class="modal-content">
    <div class="modal-header">        
      <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true" >&times;</span><span class="sr-only">Close</span></button>
      <h4 class="modal-title">FIT Result Details for Subject #view_data.subject_number#</h4>
    </div>
    
    <div class="modal-body" id="cprs_form_modal_body">
      <dl>
        <div class="rec_detail">
          <dt>Name:&nbsp;</dt>
          <dd>#view_data.first_name#&nbsp;#view_data.last_name#</dd>
        </div>
        <div class="rec_detail">
          <dt>SSN:&nbsp;</dt>
          <dd>#view_data.ssn#</dd>
        </div>
        <div class="rec_detail">
          <dt>Test Date:&nbsp;</dt>
          <dd>#view_data.tested_on#</dd>
        </div>
        <div class="rec_detail">
          <dt>Result 1 of 1 (Qualitative):&nbsp;</dt>
          <dd>#view_data.is_positive#</dd>
        </div>

        <dt>
          <form action="update_fit_result" class="update_fit_result_form" data-id="#view_data.id#" method="post">
            <input type="hidden" name="id" value="#view_data.id#"/>
            <div class="rec_detail">        
              <div class="formField">
              <cfif ucase(view_data.in_cprs) EQ 'YES'>
                <input type="checkbox" id="in_cprs_checkbox" checked="checked" name="in_cprs" value="1" />
              <cfelse>
                <input type="checkbox" id="in_cprs_checkbox" name="in_cprs" value="0" />
              </cfif> Result has been entered in CPRS.
              </div>
              <hr/>
              <input type="submit" class="btn btn-primary" id="update_button" value="Done" >
            </div>
          </form>
        </dt>

      </dl>

        
    </div>    
    
  </div>
</div>
</cfoutput>
