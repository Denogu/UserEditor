<cfoutput>
<cfif isNumeric(local.view_data.fit_results)>
            <div class="alert alert-danger">
              You do not have access to this site.
            </div>
          
          <cfelse>
<h2>Subject FIT Kit Test Results</h2>
<div class="row">
  <div class="col-sm-12">
    <div class="table-responsive">
      <table id="fit_results_table" class="table table-bordered table-striped">
        <thead>
          <th>Subject Number</th>
          <th>First name</th>
          <th>Last name</th>
          <th>SSN</th>
          <th>Result 1 of 1 (Qualitative)</th>
          <th>Collection Date</th>
          <th>Test Date</th>
          <th>In CPRS</th>
          <th></th>
        </thead>
        <tbody>
        <tr style="height: 70px;"><td colspan="100%"></td></tr>
          <!--- <cfoutput>
            <cfloop query="local.view_data.fit_results">
              <tr>
                <td id="subject_number">#HTMLEditFormat(subject_number)#</td>
                <td>#HTMLEditFormat(first_name)#</td>
                <td>#HTMLEditFormat(last_name)#</td>
                <td>#HTMLEditFormat(ssn)#</td>
                <td>#HTMLEditFormat(is_positive)#</td>
                <td>#HTMLEditFormat(collected_on)#</td>
                <td>#HTMLEditFormat(tested_on)#</td>
                <td id="cprs_field_#actions#">#HTMLEditFormat(in_cprs)#</td>
                <td><a class="cprsEntryBtn btn btn-primary" data-id="#actions#" href="cprs_form/#HTMLEditFormat(actions)#">Open</a></td>
              </tr>
            </cfloop>
          </cfoutput> --->
          </cfif>
        </tbody>
      </table>
    </div>
  </div>
</div>
</cfoutput>

<div id="cprs_modal" class="modal fade"></div>
