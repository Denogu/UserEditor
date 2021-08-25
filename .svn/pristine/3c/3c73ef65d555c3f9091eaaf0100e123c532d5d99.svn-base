<cfoutput>

  <div class="row" id="form_div">
    <div class="col-sm-8">
      <form name="update_password_form" action="update_password" data-toggle="validator">
        <h2>Update Password</h2>

        <!--- Send token along to validate it with user name and passwords on submit. --->
        <input type="hidden" name="password_reset_token" value="#view_data.token#" />

        <cfinclude template = "_user_and_password_inputs.cfm">

        <div id="error_message_div"></div>

        <input type="submit" name="submit_button" class="btn btn-default btn-primary btn-lg" value="Submit">
        <a class="btn-link" href="welcome">Cancel</a>
      </form>
    </div>
  </div>

</cfoutput>