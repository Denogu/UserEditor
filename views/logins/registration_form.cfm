<cfoutput>
<div class="row">
<div class="col-sm-8">

<!--- Maintenance message (if applicable). ---> 
<cfif DateCompare(Now(), application.maintenance_message_start) IS 1
  AND DateCompare(application.maintenance_message_end, Now()) IS 1
  AND isDefined("application.maintenance_message")
  AND Trim(application.maintenance_message) NEQ "">
  <div class="row">
    <div class="col-sm-12 alert alert-danger">
      <p><cfoutput>#application.maintenance_message#</cfoutput></p>
    </div>
  </div>
</cfif>

<form name="registration_form" id="user_registration_form" data-toggle="validator" action="register" method="post">
  <h2>User Registration</h2>
  <p>Before you can access the #application.study# IWRS, you must submit a registration form.  Once you have
  successfully submitted the registration form, the manager of this site will be notified.  You will receive an e-mail notification after your information has been reviewed and you have been granted access.</p>

  <cfif application.intranet_site>
  	<cfinclude template = "user_inputs.cfm">
  <cfelse>  
  	<cfinclude template = "user_password_inputs.cfm">
  </cfif>  

  <hr/>
  
  
    <div class="form-group has-feedback">
      <label for="first_name" class="control-label">First name</label>
      <input class="form-control" type="text" name="first_name" data-minlength="2" maxlength="50" data-error="You must provide your first name." required>
      <span class="glyphicon form-control-feedback"></span>
      <div class="help-block with-errors"></div>
    </div>
    
    
    
    <div class="form-group has-feedback">
      <label for="last_name" class="control-label">Last name</label>
      <input class="form-control" type="text" name="last_name" data-minlength="2" maxlength="50" data-error="You must provide your last name." required>
      <span class="glyphicon form-control-feedback"></span>
      <div class="help-block with-errors"></div>
    </div>




  <label for="email" class="control-label">E-mail</label>
  <div class="form-inline row">
    <div class="form-group has-feedback col-sm-6">
      <input type="email" class="form-control" name="email" id="email" placeholder="E-mail" data-error="You must provide a valid e-mail address." required style="width: 100%;">
      <span class="glyphicon form-control-feedback" style="padding-right: 30px;"></span>
      <div class="help-block with-errors"></div>
    </div>
    <div class="form-group has-feedback col-sm-6">
      <input type="text" class="form-control" name="email_verification" data-match="##email" data-match-error="Must match e-mail." placeholder="Confirm e-mail" required style="width: 100%;">
      <span class="glyphicon form-control-feedback" style="padding-right: 30px;"></span>
      <div class="help-block with-errors"></div>
    </div>
  </div>


  
  
  <div class="form-group has-feedback">
      <label for="user_role" class="control-label">Role</label>      
      <select id="user_role" name="user_role" class="form-control">
        <cfloop query="view_data.roles">
          <option value="#view_data.roles.id#">#view_data.roles.name# &nbsp;&nbsp; (#view_data.roles.description#)</option>
        </cfloop>
      </select> 
  </div>




  <div class="form-group has-feedback" id="study_site_div">
      <label for="study_site_number" class="control-label">Site</label>          
      <input class="form-control" type="text" name="study_site_number" data-minlength="2" maxlength="3" data-error="You must provide your site number." required>
      <span class="glyphicon form-control-feedback"></span>
      <div class="help-block with-errors"></div>
  </div>

  <hr/>
  
  
  
  <div id="captcha_div">
    <cfinclude template="captcha.cfm">
  </div>
  
  
  
  
  <label for="captcha_string">
    Please enter the text displayed in the above image.
  </label>




  <input class="form-control" type="text" name="captcha_string" value="" required="true">



  <hr style="clear:both;"/>
  <input type="submit" name="submit_user_registration_form" class="btn btn-default btn-primary btn-lg" value="Register">
</form>
</div>
</div>
</cfoutput>
