<!---<cfset user = createObject("component", "models.user").init(id)>--->

<cfoutput>
  <div class="well">
      <ul class="nav nav-tabs" id="tab_form">
        <li class="active"><a data-toggle="tab" href="##user">User</a></li>
        <li><a data-toggle="tab" href="##sites">Sites</a></li>
      </ul>
    <form id="edit_user_form" name="edit_user_form" action="update" method="post">
        <!---<input type="hidden" name="id" value="#view_data.user.id#"/> --->
        <div class="tab-content">
          <div id="user" class="tab-pane fade in active">
            <div class="form-group">
              <label>Username</label>
              <input type="text" class="form-control" name="user_name" value="#HTMLEditFormat(view_data.user.user_name)#" onKeyDown="event.preventDefault();" readonly />
            </div>
            <hr/>
      
            <div class="form-group">
              <label>First name</label>
              <input type="text" class="form-control" name="first_name" required pattern="^[a-zA-Z]{2,50}$" value="#HTMLEditFormat(view_data.user.first_name)#">
            </div>
            
            <div class="form-group">    
              <label>Last name</label>
              <input type="text" class="form-control" name="last_name" required pattern="^[a-zA-Z]{2,50}$" value="#HTMLEditFormat(view_data.user.last_name)#">
            </div>
            
            <div class="form-group">
              <label>E-mail</label>
              <input type="email" class="form-control" name="email" value="#HTMLEditFormat(view_data.user.email)#">
            </div>

            <div class="form-group">
              <label>Role</label>
              
              <select id="role_id" name="role_id" class="form-control">
                <cfloop query="view_data.roles">
                  <option value="#view_data.roles.id#" <cfif view_data.roles.id IS view_data.user.role().id>selected</cfif>>
                    #view_data.roles.name# (#view_data.roles.description#)
                  </option>
                </cfloop>
              </select>  
            </div>

            <cfif view_data.user.role().id IS 1>
              <cfset site_display = "">
            <cfelse>
              <cfset site_display = "style='display: none;'">
            </cfif>
              
            <div class="form-group" #site_display#>    
              <label>Default Site Number</label>
              <input type="text" class="form-control" name="site_number" required pattern="^[0-9]{2,3}$" value="#HTMLEditFormat(view_data.user.site_number)#">
            </div>
            
            <div class="checkbox">         
              <label for="is_authorized">
                <input type="checkbox" id="is_authorized" name="is_authorized" value="1" <cfif Trim(view_data.user.authorized_at) NEQ ''>checked="checked"</cfif>/> 
                Authorized for access
              </label>
            </div>
            <hr/>
          </div>
      
          <div id="sites" class="tab-pane fade in">
            <cfinclude  template="_sites_to_access.cfm">
          </div>

          <div class="form-group" id="update_form_group">
            <label class="" id="update_error" hidden>Justification is required.</label>
            <input type="text" name="justification" id="edit_justification_form" value="" class="form-control" placeholder="Reason">
          </div>
            <input id="edit_submit_button" type="submit" class="btn btn-primary disabled" name="edit_user_form_submit" value="Update" disabled="disabled"/>
              <button type="button" class="btn btn-danger pull-right" id="cancel_button" data-dismiss="modal">Cancel</button>
        </div>
    </form>
      </ul>
  </div>
</cfoutput>
  
