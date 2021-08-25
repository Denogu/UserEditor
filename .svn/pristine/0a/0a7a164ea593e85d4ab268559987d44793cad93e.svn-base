<cfcomponent extends="iwrs_controller">

  <cffunction name="requires_current_session" access="Public">
    <cfreturn false>
  </cffunction>




  <cffunction name="welcome" access="Public">
    <cfreturn render()>
  </cffunction>





  <cffunction name="error" access="Public">
    <cfreturn render()>
  </cffunction>





  <cffunction name="session_expired" access="Public">
    <cftry>  
      <cfif isdefined("arguments.SessionScope.user") and isStruct(arguments.SessionScope.user)>
        <cfinvoke component="models.user" method="logout">
          <cfinvokeargument name="user_id" value="#arguments.SessionScope.user.id#">
          <cfinvokeargument name="session_scope" value="#arguments.SessionScope#">
          <cfinvokeargument name="application_scope" value="#arguments.ApplicationScope#">
        </cfinvoke>
      </cfif>
      
      <cfcatch>
        <cfrethrow>
      </cfcatch>
    </cftry>
    <cfreturn render()>
  </cffunction>





  <cffunction name="captcha" access="Public">
    <cfreturn render_partial()>
  </cffunction>





  <cffunction name="registration_form" access="Public">
    <cfset local.view_data.roles = createObject("component", "models.role").all_readable() />
    <cfreturn render(view_data=local.view_data)>
  </cffunction>





  <cffunction name="register" access="Public">
    <cfinvoke component="models.user" method="register" returnvariable="local.result">
        <cfinvokeargument name="registration_form" value="#this.params#" >        
    </cfinvoke>
    
    <cfif local.result.is_success>
      <cfreturn render_success(local.result.message) />
    <cfelse>
      <cfset local.result.message = "<h4>#local.result.message#</h4><ul class='list-group'>" />
      <cfloop array="#local.result.validation_errors#" index="error">
        <cfset local.result.message &= "<li class='list-group-item list-group-item-danger'>#error#</li>" /> 
      </cfloop>
      <cfset local.result.message &= '</ul>' />
      <cfreturn render_error(local.result.message) />
    </cfif>
    
  </cffunction>





  <cffunction name="logout" access="Public">
    <cfreturn render()>
  </cffunction>





  <cffunction name="login_form" access="Public">
  	<cfif application.intranet_site >
    	<cfset local.view_data.login_form_template = 'intranet_site_login_form' />
    <cfelse>
    	<cfset local.view_data.login_form_template = 'internet_site_login_form' />
    </cfif>
    <cfreturn render(view_data=local.view_data)>
  </cffunction>





  <cffunction name="login" access="Public">
    <cfset local.login_form = StructNew() />
    <cfset local.login_form['user_name'] = '#CGI.AUTH_USER#' />
    
    <cfloop collection="#this.params#" item="key">
      <cfif ArrayContains(['user_name', 'password'], lcase(key))>
          <cfset local.login_form[lcase(key)] = this.params[key] />
      </cfif>
    
    </cfloop>

    
    <cfinvoke component="models.user" method="login" returnvariable="local.result">
      <cfinvokeargument name="login_form" value="#local.login_form#">
    </cfinvoke>
      

    <cfif local.result.is_success >
      
      <cfif isDefined("url.site")>
        <cfset session.user.site_number = url.site>
      </cfif>

      <cfreturn redirect('/items/fit_results')>
    <cfelse>
      <cfset local.result.message = "<h4>#local.result.message#</h4><ul class='list-group'>" />
      <cfloop array="#local.result.validation_errors#" index="error">
        <cfset local.result.message &= "<li class='list-group-item list-group-item-danger'>#error#</li>" /> 
      </cfloop>
      <cfset local.result.message &= '</ul>' />
      <cfreturn render_error(local.result.message)>
    </cfif>      
    <cfset session.user.site_number = url.site>
    <cfreturn redirect('/items/fit_results')>
  </cffunction>





  <cffunction name="unauthorized" access="Public">
    <cfreturn render()>
  </cffunction>


   
   
   
  <cffunction name="reset_password_form" access="public">
    <cfif application.intranet_site >
      <cfreturn render_error("Requested resource is only available for internet facing IWRS.") />
    </cfif>  
    <cfreturn render()>
  </cffunction>





  <cffunction name="reset_password" access="public">
    <cfif application.intranet_site>
      <cfreturn render_error("Requested resource is only available for internet facing IWRS.") />
    </cfif>

    <cfset local.result = {is_success = false, message="Password reset operation failed."} />
    <cftry>
      <cfset local.user = createObject("component", "models.user").init_from_user_name(params.user_name) />
      <cfset local.reset_result = local.user.reset_password(email='#this.params.email#') />
      <cfset local.result = {is_success = local.reset_result.is_success, message = local.reset_result.message} />
      
    <cfcatch type="custom">
      <cfset local.result = {is_success=false, message=cfcatch.message} />        
    </cfcatch>
    </cftry>

    <cfreturn render_json(local.result) />
  </cffunction>






  <cffunction name="update_password_form" access="Public">
    <cfargument name="params" type='struct'>

    <cfif application.intranet_site>
      <cfreturn render_error("Requested resource is only available for internet facing IWRS.") />
    </cfif>

    <cfset local.view_data = {}>
    <cfset local.view_data.token = arguments.params.token>

    <cfif createObject("component", "models.user").is_password_reset_token_viable(local.view_data.token)>
      <cfreturn render(local.view_data)>
    <cfelse>
      <cfreturn render_error(message="Password reset token has expired. "
        & '<b><a class="btn-link" href="reset_password_form">Reset password</a></b>')>
    </cfif>
  </cffunction>






  <cffunction name="update_password" access="Public">
    <cfif application.intranet_site>
      <cfreturn render_error("Requested resource is only available for internet facing IWRS.") />
    </cfif>

    <cfset local.update_password_form = {password=this.params.password, password_confirmation=this.params.password_verification, password_reset_token=this.params.password_reset_token} />
    
    <cftry>      
      <cfset local.user = createObject("component", "models.user").init_from_user_name(this.params.user_name) />
      <cfset local.errors = local.user.update_password_details(local.update_password_form) />
      
      <cfif ArrayLen(local.errors) IS 0>
        <cfreturn render_json_success("Password successfully updated.")>
      <cfelse>           
        <cfreturn render_json_error(ArrayToList(local.errors, "<br /> "))> 
      </cfif>
      
    <cfcatch type="custom">
      <cfreturn render_json_error(cfcatch.message)>
    </cfcatch>
    </cftry>
  </cffunction>  


 

</cfcomponent>
