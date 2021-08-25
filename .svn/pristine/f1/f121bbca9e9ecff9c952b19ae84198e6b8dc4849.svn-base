

 <!--- Maintenance message (if applicable). ---> 
  <cfif DateCompare(Now(), application.maintenance_message_start) EQ 1
    AND DateCompare(application.maintenance_message_end, Now()) EQ 1
    AND structKeyExists(application, "maintenance_message")
    AND Trim(application.maintenance_message) NEQ "">
    <div class="row">
      <div class="col-sm-12 alert alert-danger">
        <p><cfoutput>#application.maintenance_message#</cfoutput></p>
      </div>
    </div>
  </cfif>

<div class="row">
<div class="col-sm-6">
<form name="login_form" action="login" method="post" >
  <h2>Login</h2>
  <p>You must be authorized to access this site.  If you need access, please register <b><a href="registration_form" title="Click me to register for this site.">here</a>.</b></p>



  <div class="form-group has-feedback">
      <label for="user_name" class="control-label">Username</label>
      <div class="input-group">
        <span class="input-group-addon glyphicon glyphicon-user" style="top: 0px;"></span>
        <input type="text" class="form-control" name="user_name" id="user_name" placeholder="Username"  message="You must provide a username." required autofocus>
      </div>


   </div>


   <div class="form-group has-feedback">
       <label for="password" class="control-label">Password</label>
   		<div class="input-group">
        <span class="input-group-addon glyphicon glyphicon-lock" style="top: 0px;"></span>

        <input type="password" class="form-control" name="password" id="password" placeholder="Password" message="Password is required." required>
        </div>

   </div>

    <input type="hidden" name="utc_offset" id="utc_offset" value="" 
      required="true" message="The system was unable to retrieve your computer's timezone offset"/>

    <input type="submit" name="submit_button" class="btn btn-default btn-primary btn-lg" value="Login">
    <a class="btn-link" href="reset_password_form">
      Reset password
    </a>
  </form>
</div>

<div class="col-sm-4"></div>
</div>

