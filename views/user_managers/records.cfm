
<div class="row">
  <div class="col-sm-12">
    <h3 style="color: #6a8dac;">IWRS Users (Double-Click to Edit)</h3>
  </div>
</div>

<div class="row">
  <div class="col-sm-12">
    <div class="table-responsive">
      <table id="user_table" class="table table-bordered">
        <thead>
          <th style="width:5em;">Authorized</th>
          <th style="width:4em;">ID</th>
          <th style="width:15em;">Username</th>
          <th style="width:10em;">First name</th>
          <th style="width:10em;">Last name</th>
          <th style="width:20em;">E-mail</th>
          <th style="width:5em;">Site</th>
          <th style="width:6em;">Role</th>
        </thead>
        <tbody>
          <cfloop query="view_data.users">
            <cfif Trim(view_data.users.authorized_at) is "">
                <cfset image_to_display = 'revoke_user_access.gif'>
                  <cfset row_class = 'danger'>
              <cfelse>
                <cfset image_to_display = 'authorize_user.gif'>
                  <cfset row_class = ''>
              </cfif>
            <cfoutput>
              <tr class="#row_class#" id="user_#id#">
                <td id="user_authorization_#id#" class="user_authorization">              
                  <img src='../../images/#image_to_display#'/>              
                </td>
                <td id="user_id_#id#" class="user_id">#id#</td>
                <td class="user_username">#HTMLEditFormat(user_name)#</td>
                <td class="user_first_name">#HTMLEditFormat(first_name)#</td>
                <td class="user_last_name">#HTMLEditFormat(last_name)#</td>
                <td class="user_email">#HTMLEditFormat(email)#</td>
                <td class="user_site_number">#HTMLEditFormat(site_number)#</td>
                <td class="user_role_name">#HTMLEditFormat(role)#</td>
              </tr>
            </cfoutput>
          </cfloop>
        </tbody>
      </table>
    </div>
  </div>
</div>
  
<div id="user_edit_form_modal" class="modal custom fade" role="dialog">
  <div class="modal-dialog">
    <div class="modal-content">
    	<div class="modal-header">        
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true" >&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title">Edit User</h4>
      </div>
        
      <div class="modal-body" id="user_edit_form_modal_body">
      </div>    
      
      <div class="modal-footer" style="display:none;">    
        <button type="button" class="btn btn-danger pull-right" id="cancel_button" data-dismiss="modal">Close</button>    
      </div>       
    </div>
  </div>
</div>
