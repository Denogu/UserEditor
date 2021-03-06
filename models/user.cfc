<cfcomponent output="false">
	
	<!--- Database Meta Data (DBMD) --->
	<cfset variables.table_name = 'iwrs_users'>

	<cfset variables.field_names = [
                                  'id',
                                  'site_number',
                                  'user_name',
                                  'first_name',
                                  'last_name',
                                  'is_locked',
                                  'is_crpcc',
                                  'authorized_at',
                                  'authorized_by',
                                  'can_manage_users',
                                  'can_unblind',
                                  'email',
                                  'password',
                                  'salt',
                                  'expires_on',
                                  'created_at',
                                  'updated_at',
                                  'role_id',
                                  'all_site_access',
                                  'password_reset_token',
                                  'password_reset_token_expires_at',
                                  'failed_login_attempts'
                                ]/>
	

	<!--- Finds the record in the database by the record's id.  Builds an object with member variables defined from the table's
	      field names and values. --->
	<cffunction name="init" output="false" access="Public">
		<cfargument name="id" required="true" type="numeric">
		
    	<cfset var rec = find_record_by_id(arguments.id)>
      <cfset this.id = arguments.id>
      <cfset build_orm_object(rec)>

		<cfreturn this>
	</cffunction>


<!--- Create User object using the user's login --->
  <cffunction name="init_from_user_name" output="false" access="Public">
    <cfargument name="user_name" type="string" required="true">

    <cfquery name="local.user_record" datasource="#application.dsn#" >
      SELECT TOP 1 id FROM #variables.table_name# 
      WHERE
      user_name = <cfqueryparam value="#arguments.user_name#" cfsqltype="CF_SQL_varchar" maxlength="50" null="No"> 
    </cfquery>

    <cfif local.user_record.recordCount NEQ 1>
      <cfthrow type="IWRS.User.MissingRecord" message="User record not found.">
    </cfif>

    <cfreturn init(local.user_record.id)>
  </cffunction>


<!--- Get all records. --->
  <cffunction name="all_readable" output="false" access="public" returntype="Query">
    <cfquery name="local.user_recs" datasource="#application.dsn#">
      SELECT [#variables.table_name#].id, site_number, [#variables.table_name#].user_name, first_name, last_name, is_locked, is_crpcc, authorized_at, authorized_by, can_manage_users, can_unblind, email, password, salt, expires_on, [#variables.table_name#].created_at, [#variables.table_name#].updated_at, role_id, all_site_access, password_reset_token, password_reset_token_expires_at, failed_login_attempts, [iwrs_roles].name as role 
      FROM [#variables.table_name#] 
      INNER JOIN [iwrs_roles] 
      ON role_id = [iwrs_roles].id
      ORDER BY id DESC
    </cfquery>

    <cfreturn local.user_recs>
  </cffunction>


<!--- Also applies to reauthorization --->
  <cffunction name="authorize_new_user" output="false" access="public" returntype="Struct">
    <cfargument name="authorized_by" required="true" type="string">
    
    <cfif Trim(this.authorized_at) NEQ "">      
      <cfreturn {is_success=false, message="This user has already been authorized."} />
    </cfif>
    
	  <cfset authorize(authorized_by = arguments.authorized_by) />
    <cfset send_notification(to=this.email, subject="You have been granted access to the #application.study# IWRS.", message="You may access the account using the following link #application.login_url#") /> 
    <cfreturn {is_success=true, message="User authorization successful."} />
  </cffunction>


<!--- Deauthorize user  --->
  <cffunction name="revoke_user_access" output="false" access="Public" returntype="Struct">
    <cfargument name="revoked_by_user_name" required="true" type="string">
    
    <cfif Trim(this.authorized_at) EQ "">        
      <cfreturn {is_success=false, message="This user is not currently authorized to access the site."} />
    </cfif>

    <cfset revoke_access(revoked_by = arguments.revoked_by_user_name)>
    <cfreturn {is_success=true, message="User access revoked successfully."} />
  </cffunction>
  

  <cffunction name="update_user_details" access="public" returntype="struct">
    <cfargument name="user_form" type="struct" required="yes">

    <cfset local.result = {is_success = false, message = 'User record update failed.' } />

    <cftransaction>  
      <!--- Authorization is handled in a special manner. --->
      <cfif arguments.user_form['is_authorized'] EQ 1 and Trim(this.authorized_at) EQ "">
          <cfset local.user_authorized = this.authorize_new_user(authorized_by = session.user.name) />
          <cfif not local.user_authorized.is_success>
              <cfset local.result.message = local.user_authorized.message />
              <cfreturn local.result />
          </cfif>

      <cfelseif arguments.user_form['is_authorized'] EQ 0 and Trim(this.authorized_at) NEQ "">
          <cfset local.user_access_revoked = this.revoke_user_access(revoked_by_user_name = session.user.name) />
          <cfif not local.user_access_revoked.is_success>
              <cfset local.result.message = local.user_access_revoked.message />
              <cfreturn local.result />
          </cfif>
      </cfif>
            
      <cfset structDelete(arguments.user_form,'is_authorized') />
       
      <cfquery name="update_record" datasource="#application.dsn#" result="local.update_result">
        UPDATE [#variables.table_name#]
        SET
          <cfloop collection=#arguments.user_form# item='key'>              
            <cfset local.field_type = (uCase(key) EQ 'ROLE_ID') ? "CF_SQL_INTEGER" : "CF_SQL_VARCHAR" />
            #key# = <cfqueryparam value="#trim(arguments.user_form[key])#" cfsqltype="#local.field_type#">,
          </cfloop>
          updated_by = <cfqueryparam value="#session.user.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="no">,
          updated_at = GETUTCDATE()
        WHERE 
          id = <cfqueryparam value="#this.id#" cfsqltype="CF_SQL_INTEGER" null="no">
      </cfquery>
      <cfset local.result = {is_success = true, message = 'User record updated successfully.'} />
    </cftransaction>
    <cfreturn local.result />
  </cffunction>

  



  <cffunction name="validate_login_form" access="public" output="false">
  	<cfargument name="user_record" type="query" required="true">
    <cfargument name="login_values" type="struct" required="true">

    <cfset local.validation_errors = ArrayNew(1) />

	  <cfif arguments.user_record.recordCount NEQ 1>
        <cfset message = (application.intranet_site) ? "Please contact the 577 study team at the Albuquerque Pharmacy Coordinating Center."  : "The username or password is incorrect." />
        <cfset ArrayAppend(local.validation_errors, message) />
        <cfreturn local.validation_errors />
    </cfif>
    

    <cfif arguments.user_record.is_locked >
        <cfset ArrayAppend(local.validation_errors, "This user account is currently locked. Please contact the site administrator to unlock the account.") />
        <cfreturn local.validation_errors />
    </cfif>


    <cfif NOT application.intranet_site>
        <cfset local.hashed_form_password = createobject("component","utilities.password").secure(arguments.login_values.password, arguments.user_record.salt) />
        <cfif arguments.user_record.password is not local.hashed_form_password>
          <cfset update_failed_login_attempts(arguments.user_record.id, arguments.user_record.failed_login_attempts + 1) />
          <cfset ArrayAppend(local.validation_errors, "The username and/or password you entered are incorrect. Only #application.failed_logins_allowed# login attempts are allowed, after that your account gets locked. Login attempts remaining #application.failed_logins_allowed - (arguments.user_record.failed_login_attempts +  1)#.") />
          <cfreturn local.validation_errors />
        </cfif>
    </cfif>
      
  
    <cfif Trim(arguments.user_record.authorized_at) is ''>
        <cfset ArrayAppend(local.validation_errors, "This user account is not currently authorized to access the site.  Please contact the site administrator if you believe the account should be authorized.") />
        <cfreturn local.validation_errors />
    </cfif>
  

    <cfif NOT application.intranet_site>
        <cfif arguments.user_record.expires_on lte DateConvert("local2UTC",NOW())>
            <cfset ArrayAppend(local.validation_errors, "Your password has expired and must be changed. <b><a href='reset_password_form'>Reset password</a></b>") />
            <cfreturn local.validation_errors />
        </cfif>
    </cfif>      
      
    <cfreturn local.validation_errors />
  </cffunction>
 
 
 
 
 
 <!--- Function to match username and pa$sword and set session key. --->
  <cffunction name="login" access="public" returntype="struct" output="false">
    <cfargument name="login_form" type="struct" required="true">

    <cfset local.result.message = 'Unable to access 577 FIT Results.' />      
    <cfset local.result.is_success = false />
    <cfset local.result.validation_errors = ArrayNew(1) />
    
    <cfset local.user = get_record_by_username(arguments.login_form.user_name) />


		<cfset local.result.validation_errors = validate_login_form(user_record=local.user, login_values=arguments.login_form ) />
          
    <cfif local.user.all_site_access EQ 1>
      <cfset local.user_sites = get_admin_site_access()>
    <cfelseif isNumeric(local.user.id)>
      <cfset local.user_sites = get_user_site_access(local.user.id) />
    <cfelse>
      <cfset local.result.message = 'User record not found. If you need access to this website, you must fill out and submit a registration form.' />
    </cfif>

    <cfif ArrayLen(local.result.validation_errors)>
      <cfreturn local.result />  
    </cfif>   
  
    <cfif local.user.RecordCount EQ 1 and Trim(local.user.authorized_at) NEQ ''>
    <!--- Create a 28-character string generated by Secure Hash Algorithm --->
        <cfset rand_num = createObject("java","java.security.SecureRandom").getInstance('SHA1PRNG').nextInt() />
        <cfset local.session_id = lcase(hash(rand_num,"SHA")) />
  
        <cflock scope="Session" timeout="10" type="Exclusive">
          <cfif isDefined("session.user")>
            <cfset structDelete(session, "user")>
          </cfif>  
          
          <cfparam name=session.user default=#StructNew()#>
  
          <cfparam name=session.user.id default=#local.user.id#>
          <cfparam name=session.user.site_number default=#local.user.site_number#>
          <cfparam name=session.user.first_name default=#local.user.first_name#>
          <cfparam name=session.user.last_name default=#local.user.last_name#>
          <cfparam name=session.user.name default=#local.user.user_name#>
          <cfparam name=session.user.email default=#local.user.email#> 
          <cfparam name=session.user.key default=#local.session_id#>
          <cfparam name=session.user.all_site_access default=#local.user.all_site_access#> 
          <cfparam name=session.user.is_crpcc default=#local.user.is_crpcc#>
          <cfparam name=session.user.can_manage_users default=#local.user.can_manage_users#>
          <cfparam name=session.user.can_unblind default=#local.user.can_unblind#>
          <cfparam name=session.user.role_id default=#local.user.role_id#>
          <cfparam name=session.user.user_site_access default=#local.user_sites#>
        </cflock>
        <cftransaction>
          <cfset update_session_key(user_id='#local.user.id#', session_key='#local.session_id#', datasource="#application.dsn#") />
          <cfset update_failed_login_attempts(user_id='#local.user.id#', failed_attempts=0) />
        </cftransaction>                  
        <cfset local.result.is_success = true />
        <cfset local.result.message = "Sign in successful." />
    </cfif>

    <cfreturn local.result>
  </cffunction>


  <!--- If logout form sent to request clean up key, cookies, and session. --->
  <cffunction name="logout" access="public" output="false">
    <cfargument name="user_id" type="numeric" required="true">
    <cfargument name="session_scope" required="true">
    <cfargument name="application_scope" required="true">

    <!--- Clear session key from database --->
    <cfset update_session_key(user_id = '#arguments.user_id#', session_key = 'NULL', datasource="#arguments.application_scope.dsn#") />
   
    <!--- Expire session cookies now and delete the session user information. --->
    <cfcookie name="CFID" value="#arguments.session_scope.CFID#" expires="NOW">
    <cfcookie name="CFTOKEN" value="#arguments.session_scope.CFTOKEN#" expires="NOW">  
    <cfset structdelete(arguments.session_scope, "user")>
  </cffunction> 


  <cffunction name="is_registered" output="false" access="public" returntype="boolean">
    <cfargument name="user_name" required="true" type="string">
 
    <cfset local.user = get_record_by_username(user_name = '#arguments.user_name#') />
        
    <cfif local.user.recordCount EQ 0>
      <cfreturn false>
    </cfif>

    <cfreturn true>
  </cffunction>  
  
   
  <cffunction name = "get_registration_validation_errors" returnType = "array" access = "public" description = "I validate registration forms.">
    <cfargument name="registration_form_answers" type="struct" required="true">

    <cfset local.registration_errors = Arraynew(1) />

    <cfif arguments.registration_form_answers.captcha_string NEQ session.captcha>
      <cfset ArrayAppend(local.registration_errors, "You must correctly enter the text from the captcha image.") />
      <cfreturn local.registration_errors /> 
    </cfif>

    <cfif NOT isValid("regex", arguments.registration_form_answers.user_name, '^[A-Za-z0-9\\]{3,50}$') >
      <cfset ArrayAppend(local.registration_errors, "Please enter a valid Username.") />
    </cfif>

    <cfset local.user_is_registered = is_registered(arguments.registration_form_answers.user_name) />
	      
    <cfif local.user_is_registered>
      <cfset ArrayAppend(local.registration_errors, "The username you specified is already registered in the system.") /> 
      <cfreturn local.registration_errors />    
    </cfif>

    <cfif not application.intranet_site>
      <cfif Compare(arguments.registration_form_answers.password, arguments.registration_form_answers.password_verification) NEQ 0>
          <cfset ArrayAppend(local.registration_errors, "Please make sure the password you entered in the password verification field matches what you entered for your password.") />
      </cfif>
        
      <cfset local.password_utility = createObject("component", "utilities.password")>

      <cfset local.is_password_strong = local.password_utility.is_strong(arguments.registration_form_answers.password)>
      <cfif not local.is_password_strong>
          <cfset ArrayAppend(local.registration_errors, "The password entered does not meet the specified criteria.") />
      </cfif>
    </cfif>
            
    <cfif NOT isValid("regex", arguments.registration_form_answers.first_name, '^[A-Za-z0-9]{2,50}$') >
      <cfset ArrayAppend(local.registration_errors, "Please enter a valid first name.") />
    </cfif>
    
    <cfif NOT isValid("regex", arguments.registration_form_answers.last_name, '^[A-Za-z0-9\s\-]{2,50}$') >
      <cfset ArrayAppend(local.registration_errors, "Please enter a valid last name.") />
    </cfif>
    
    <cfif NOT isValid("email", arguments.registration_form_answers.email) OR len(arguments.registration_form_answers.email) GT 50>
      <cfset ArrayAppend(local.registration_errors, "Please enter a valid email address.") />
    </cfif>

    <cfif Compare(arguments.registration_form_answers.email, arguments.registration_form_answers.email_verification) NEQ 0>
      <cfset ArrayAppend(local.registration_errors, "You must verify your email address before you can register.  Please make sure what you entered in the email confirmation box matches what you entered for your email.") />
    </cfif>  

    <cfset roles = createObject("component", "models.role").all_readable() />
    <cfset user_roles = createObject("component", "utilities.query_utilities").queryColumnToArray(Query=roles, columnName="id") />
    <cfif NOT arrayContains(user_roles, arguments.registration_form_answers.user_role) >
      <cfset ArrayAppend(local.registration_errors, "Please select a valid Role.") />      
    </cfif>

    <cfreturn local.registration_errors>
  </cffunction>



  <!--- Main method to register new users --->
  <!--- For a user to successfully register they must meet the following:
          -He/she should not already be registered
   --->
  <cffunction name="register" output="false" access="public" returntype="struct">
    <cfargument name="registration_form" type="struct" required="true">
    
    <cfset local.result.message = 'Thank you for registering. You will receive an email when your account is authorized to use the system.' />
    <cfset local.result.is_success = true>
    <cfset local.result.validation_errors = ArrayNew(1) />

    <cfset local.result.validation_errors = get_registration_validation_errors(arguments.registration_form) />   
    <cfif ArrayLen(local.result.validation_errors)>
      <cfset local.result.message = 'User Registration Error' />
      <cfset local.result.is_success = false />      
      <cfreturn local.result />
    </cfif> 

    <cfif application.intranet_site > 
      <!--- Validate passwords only when its not intranet site.--->
      
    	<cfset register_for_intranet(
                                  user_name = Trim(arguments.registration_form.user_name),
                                  first_name = Trim(Ucase(arguments.registration_form.first_name)),
                                  last_name = Trim(Ucase(arguments.registration_form.last_name)),
                                  site_number = arguments.registration_form.study_site_number,
                                  email = Trim(Lcase(arguments.registration_form.email)),
                                  role_id = arguments.registration_form.user_role
                                ) />
                                 
    <cfelse>     
            
    	<cfset register_for_internet(
                                      user_name = Trim(arguments.registration_form.user_name),
                                      first_name = Trim(Ucase(arguments.registration_form.first_name)),
                                      last_name = Trim(Ucase(arguments.registration_form.last_name)),
                                      site_number = arguments.registration_form.study_site_number,
                                      email = Trim(Lcase(arguments.registration_form.email)),
                                      role_id = arguments.registration_form.user_role,
                                      password = arguments.registration_form.password
                                    ) />                               
    </cfif>

    <cfset send_registration_notification() />

    <cfreturn local.result />
  </cffunction>
  
  
  
  

  <cffunction name="reset_password" access="public" returnType="struct">
    <cfargument name="email" required="true">
    <cfargument name="hours_until_token_expires" required="false" default="#application.password_reset_token_expiration_hours#">

    <!---Note: User can still login with his old password even after requesting a reset password, if he has not set his new password. --->
    <cfset local.result = {is_success = true, message="Password reset link has been sent to the e-mail address #HTMLEditFormat(arguments.email)#."} />

    <cfif this.email NEQ arguments.email>
      <cfset local.result = {is_success = false, message="#application.error_message_reset_password#"} /> 
    
    <cfelse>
      <cfset local.temp_password = createObject("component", "utilities.password").generate_random_password()>
      <cfset local.temp_password_hashed = createObject("component", "utilities.password").secure(local.temp_password, this.salt) />

      <cfquery datasource="#application.dsn#">
        UPDATE [#variables.table_name#]
        SET 
          password_reset_token = <cfqueryparam value="#local.temp_password_hashed#">,
          password_reset_token_expires_at = DATEADD("hh", #arguments.hours_until_token_expires#, GETUTCDATE())
        WHERE 
          user_name = <cfqueryparam value="#this.user_name#" CFSQLTYPE="CF_SQL_VARCHAR" null="no">
          AND email = <cfqueryparam value="#arguments.email#" CFSQLTYPE="CF_SQL_VARCHAR" null="no">
      </cfquery>

      <cfset send_reset_password_notification(reset_token="#local.temp_password_hashed#") />
    </cfif>

    <cfreturn local.result>
  </cffunction>






  <cffunction name="send_reset_password_notification" access="public">    
    <cfargument name="reset_token">

    <cfset local.reset_url = "#application.url_root#/index.cfm/logins/update_password_form?token=#arguments.reset_token#" />
    <cfset local.message_body = "To reset your password, please <b><a href='#local.reset_url#'>click here</a></b>. This link expires after #application.password_reset_token_expiration_hours# hours." />
    <cfset local.message_body &= "<br>If you have not made this request please reply and let us know." />
    <cfset local.subject = "#application.study# IWRS - Password Reset" />
    <cfset send_notification(to=this.email, subject=local.subject, message=local.message_body) />    
  </cffunction>






  <cffunction name="update_password_details" access="public" returntype="array">
    <cfargument name="update_password_form">

    <cfset local.errors = is_ok_to_update_password(arguments.update_password_form) />
    
    <cfif ArrayLen(local.errors)>
      <cfreturn local.errors />
    </cfif>
    
    <cfset local.salt = createObject("component", "utilities.password").get_salt() />
    <cfset local.hashed_password = createObject("component", "utilities.password").secure(arguments.update_password_form.password, local.salt) />
    <cftransaction>
      <cfif create_password_history_record( user_id = this.id, plain_text_password = arguments.update_password_form.password, salt = local.salt)>
        <cfset update_password(salt=local.salt, hashed_password=local.hashed_password, password_expiration_days=application.password_expiration_days) />        
        <cfset send_notification(to=this.email, subject="#application.study# IWRS password updated", message="Your password for #application.study# IWRS has been updated.") />
      <cfelse>
        <cfset ArrayAppend(local.errors, "Password may not be same as #application.password_history_enforced_count# previous passwords.") />        
      </cfif>  
    </cftransaction>     

    <cfreturn local.errors />
  </cffunction>






   <!--- Static method. --->
 

  <cffunction name="role" access="public" output="false">
    <cfreturn CreateObject("component", "models.role").init(this.role_id)>
  </cffunction>




  <!--- Determine if password reset token exists and has not expired. --->
  <cffunction name="is_password_reset_token_viable" access="public" returntype="Boolean">
    <cfargument name="password_reset_token">
    
    <cfif Len(Trim(arguments.password_reset_token)) >    
      <cfset local.records = get_records_for_valid_password_reset_token(password_reset_token) />
      <cfreturn local.records.recordCount EQ 1 />
    </cfif>

    <cfreturn false />
  </cffunction>






 <!--- Private Methods --->

  
  <!--- Get password reset token record which exists and has not expired--->
  <cffunction name="get_records_for_valid_password_reset_token" access="private" returntype="Query">
    <cfargument name="password_reset_token">

    <cfquery datasource="#application.dsn#" name="local.records">
      SELECT id
      FROM [#variables.table_name#]
      WHERE password_reset_token = <cfqueryparam value="#arguments.password_reset_token#" CFSQLTYPE="CF_SQL_VARCHAR" null="no">
        AND password_reset_token_expires_at > GETUTCDATE()
    </cfquery>

    <cfreturn local.records>
  </cffunction>

 



  
  <!--- Determine if password reset token exists, has not expired, and is for the user. --->
  <cffunction name="is_password_reset_token_valid" access="private" returntype="Boolean">
    <cfargument name="password_reset_token">
    
    <cfset records = get_records_for_valid_password_reset_token(password_reset_token) />

    <cfquery dbtype="query" result="local.result">
      SELECT id
      FROM records
      WHERE id = #this.id#
    </cfquery>

    <cfreturn local.result.recordCount IS 1>
  </cffunction>






  <cffunction name="is_ok_to_update_password" access="private" returntype="array">
    <cfargument name="update_password_form" type="struct" required="true">
    
    <cfset local.errors = ArrayNew(1) />

    <cfif arguments.update_password_form.password_reset_token NEQ this.password_reset_token>
      <cfset ArrayAppend(local.errors, "Password reset has not been requested for this user.") />
      <cfreturn local.errors />
    </cfif>

    <cfif not is_password_reset_token_valid(arguments.update_password_form.password_reset_token)>
        <cfset ArrayAppend(local.errors, "Password reset token has expired.")>
        <cfreturn local.errors />
    </cfif>

    <cfset local.is_password_strong = createObject("component", "utilities.password").is_strong(arguments.update_password_form.password) />
    
    <cfif not local.is_password_strong>
      <cfset ArrayAppend(local.errors, "Password does not meet security requirements.")>
    </cfif>

    <cfif arguments.update_password_form.password NEQ arguments.update_password_form.password_confirmation>
      <cfset ArrayAppend(local.errors, "Password and Verify Password fields do not match.")>
    </cfif>

    <cfreturn local.errors>
  </cffunction>






  <cffunction name="update_password" access="private" returntype="void">
    <cfargument name="salt" type="string" required="true" >
    <cfargument name="hashed_password" type="string" required="true">
    <cfargument name="password_expiration_days" type="numeric" required="true">

    <!--- Set expiration date of token to 50 years in the past. --->
      <cfquery datasource="#application.dsn#">
          UPDATE [#variables.table_name#]
          SET password = <cfqueryparam value="#arguments.hashed_password#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="No">,
            salt = <cfqueryparam value="#arguments.salt#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="No">, 
            password_reset_token_expires_at = DATEADD("yy", -50, GETUTCDATE()),
            expires_on = DATEADD(day, #arguments.password_expiration_days#, GETUTCDATE())
          WHERE id = #this.id#
      </cfquery> 
  </cffunction>





  
   <cffunction name="update_failed_login_attempts" access="private" output="false" returntype="void" hint="I update failed login attempts. I also set is_locked flag to true when failed login attempt equals or exceeds allowed attempts.">
    <cfargument name="user_id" type='string' required='true'>
    <cfargument name="failed_attempts" type='numeric' required='true'>

    <cfquery datasource="#application.dsn#">
      Update [#variables.table_name#] 
      SET [failed_login_attempts] = <cfqueryparam value="#arguments.failed_attempts#" cfsqltype="CF_SQL_INTEGER" null="no">
      <cfif arguments.failed_attempts GTE application.failed_logins_allowed>
        ,[is_locked] = 1 
      </cfif>
      WHERE id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_INTEGER" null="no">
    </cfquery>
  </cffunction>






  <cffunction name="update_session_key" access="private" output="false" returntype="void">
  	<cfargument name="user_id" type="string" required="true">
    <cfargument name="session_key" type="string" required="true">
    <cfargument name="datasource" type="string" required="true"> <!---We are specifying the datasource here. When this method is called after the sessionEnds, at that time application.dsn may not be accessible. --->
    
    <cfquery name="update_current_session_id" datasource="#arguments.datasource#">
    	UPDATE [#variables.table_name#]
        SET current_session_id = <cfqueryparam value="#arguments.session_key#" cfsqltype="CF_SQL_VARCHAR">          
        WHERE id = <cfqueryparam value="#arguments.user_id#" CFSQLTYPE="CF_SQL_INTEGER">
    </cfquery>
  </cffunction>
 
  
  
  
  
  
  <cffunction name="register_for_intranet" output="false" access="private">
    <cfargument name="user_name" type="string" required="true">
    <cfargument name="first_name" type="string" required="true">
    <cfargument name="last_name" type="string" required="true">
    <cfargument name="site_number" type="string" required="true">
    <cfargument name="email" type="string" required="true">
    <cfargument name="role_id" type="string" required="true">
     
    <cfset local.new_user_id = '' />    
    <cfset local.new_user_id = insert_record(
                                              user_name = arguments.user_name,
                                              first_name = arguments.first_name,
                                              last_name = arguments.last_name,
                                              site_number = arguments.site_number,
                                              email = arguments.email,
                                              role_id = arguments.role_id
                                            ) /> 
    <cfreturn local.new_user_id />
  </cffunction>
  
  
  
  

  
  <cffunction name="register_for_internet" output="false" access="private">
    <cfargument name="user_name" type="string" required="true">
    <cfargument name="first_name" type="string" required="true">
    <cfargument name="last_name" type="string" required="true">
    <cfargument name="site_number" type="string" required="true">
    <cfargument name="email" type="string" required="true">
    <cfargument name="role_id" type="string" required="true">
    <cfargument name="password" type="string" required="true">
	 
    <cfset local.new_user_id = '' />
    
    <cftransaction>      
      <cfset local.salt = createObject("component", "utilities.password").get_salt() />
      <cfset local.hashed_password = createObject("component", "utilities.password").secure(arguments.password, local.salt)>
      <cfset local.new_user_id = insert_record(
                                                user_name = arguments.user_name,
                                                first_name = arguments.first_name,
                                                last_name = arguments.last_name,
                                                site_number = arguments.site_number,
                                                email = arguments.email,
                                                role_id = arguments.role_id,
                                                salt = local.salt,
                                                hashed_password = local.hashed_password,
                                                password_expiration_days = application.password_expiration_days
                                              )/> 
      <cfset give_default_site_access(
                                      iwrs_user_id = local.new_user_id,
                                      site_id = arguments.site_number
                                      ) />
      
                                  
      <!--- Create record for password history as well. --->
      <cfset create_password_history_record(
                      user_id = local.new_user_id,
						          plain_text_password = arguments.password,
						          salt = local.salt
                    ) />    
    </cftransaction>

	<cfreturn local.new_user_id />
   
  </cffunction>






  <cffunction name="create_password_history_record" access="private" returntype="boolean">
    <cfargument name="user_id" type="string" required="true">
    <cfargument name="plain_text_password" type="string" required="true">
    <cfargument name="salt" type="string" required="true">

    <cfreturn createObject("component", "models.user_password_history").create(user_id = arguments.user_id, plain_text_password = arguments.plain_text_password, salt = arguments.salt, password_history_enforced_count = application.password_history_enforced_count)  />

  </cffunction>


  



 
  <cffunction name="insert_record" access="private">
    <cfargument name="user_name" type="string" required="true">
    <cfargument name="first_name" type="string" required="true">
    <cfargument name="last_name" type="string" required="true">
    <cfargument name="site_number" type="string" required="true">
    <cfargument name="email" type="string" required="true">
    <cfargument name="role_id" type="string" required="true">
    <cfargument name="salt" type="string" required="false" default="">
    <cfargument name="hashed_password" type="string" required="false" default="">
    <cfargument name="password_expiration_days" type="string" required="false" default="">
      
    <cfquery name="new_user_rec" datasource="#application.dsn#" result="local.new_user">
      INSERT into [#variables.table_name#](user_name, first_name, last_name, site_number, 
        email, role_id, salt, password, updated_by, expires_on)
      VALUES(
        <cfqueryparam value="#arguments.user_name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
        <cfqueryparam value="#arguments.first_name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
        <cfqueryparam value="#arguments.last_name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
        <cfqueryparam value="#arguments.site_number#" cfsqltype="CF_SQL_VARCHAR" maxlength="20" null="No">,
        <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
        <cfqueryparam value="#arguments.role_id#" cfsqltype="CF_SQL_INTEGER" null="No">,           
        <cfqueryparam value="#arguments.salt#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="#NOT len(Trim(arguments.salt))#" >,            
        <cfqueryparam value="#arguments.hashed_password#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="#NOT len(Trim(arguments.hashed_password))#" >,         
        <cfqueryparam value="#arguments.user_name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="no">,
        <cfif isDefined("arguments.password_expiration_days") and len(Trim(arguments.password_expiration_days))>
          DATEADD(day, #arguments.password_expiration_days#, GETUTCDATE())
        <cfelse>
          NULL
        </cfif>   
      )
    </cfquery>

    <cfreturn local.new_user.GeneratedKey>
  </cffunction> 

  <cffunction name="give_default_site_access" access="private">
    <cfargument name="iwrs_user_id" type="string" required="true">
    <cfargument name="site_id" type="string" required="true">

    <cfquery name="default_site_access" datasource="#application.dsn#" result="local.def_site_id">
      INSERT into iwrs_user_sites(iwrs_user_id, site_id)
      VALUES(
        <cfqueryparam value="#arguments.iwrs_user_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
        <cfqueryparam value="#arguments.site_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">,
      )
    </cfquery>
    <cfreturn local.def_site_id>
  </cffunction>





  <!--- Should be called by authorize_new_user which validates stuff--->
  <cffunction name="authorize" output="false" access="private">
    <cfargument name="authorized_by" type="string" required="true">

    <cfquery datasource="#application.dsn#">
      UPDATE [#variables.table_name#]
        SET authorized_at = GETUTCDATE(),
            authorized_by = <cfqueryparam value="#arguments.authorized_by#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="no">,
            is_locked = 0,
            updated_at = GETUTCDATE(),
            updated_by = <cfqueryparam value="#arguments.authorized_by#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="no">
      WHERE id = <cfqueryparam value="#this.id#" cfsqltype="CF_SQL_INTEGER" null="no">
    </cfquery>
  </cffunction>
<!------>





  <!--- Should be called by revoke_user_access which validates stuff--->
  <cffunction name="revoke_access" output="false" access="private">
    <cfargument name="revoked_by" type="string" required="true">

    <cfquery datasource="#application.dsn#">
      UPDATE [#variables.table_name#]
        SET authorized_at = NULL,
            authorized_by = NULL,
            updated_at = GETUTCDATE(),
            updated_by = <cfqueryparam value="#arguments.revoked_by#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="no">
      WHERE id = <cfqueryparam value="#this.id#" cfsqltype="CF_SQL_INTEGER" null="no">
    </cfquery>
  </cffunction>
<!------>
	




  <!--- Get all users whose role includes the 'can_manage_users' permission --->
  <cffunction name="user_managers" access="private" output="false" returntype="Query">
    <cfquery name="local.manager_records" datasource="#application.dsn#">
      SELECT email 
      FROM [#variables.table_name#] 
      WHERE can_manage_users = 1
    </cfquery>

    <cfreturn local.manager_records>
  </cffunction>
  
  
  
  
  
  
  <cffunction name="send_notification" output="false" access="private">
    <cfargument name="to" required="true" type="string">
    <cfargument name="subject" required="true" type="string">
    <cfargument name="message" required="true" type="string">

    <cfmail to="#arguments.to#" from="#application.notify#" subject="#arguments.subject#" type="html">
      <cfoutput>#message#</cfoutput>
    </cfmail>
  </cffunction>
  
  
  
  


  <cffunction name="send_registration_notification" output="false" access="private">
    
    <cfset local.subject = "A new user has registered in the CSP #application.study# IWRS.">
    <cfset local.message = "Please review the user's request using the following link #application.login_url#.  The user will not have access to the system until an administrator authorizes the user's account.">  
    
    <cfset local.administrator_users = user_managers()>
    
    <cfif local.administrator_users.recordCount NEQ 0>
    	<cfset local.emails = Arraynew(1)>
        <cfloop query="local.administrator_users">
          <cfset ArrayAppend(local.emails, email)>
        </cfloop>
        
      	<cfset send_notification(ArraytoList(local.emails, ', '), local.subject, local.message)>
    </cfif>
  </cffunction>






  <cffunction name="get_record_by_username" access="private" output="false" returntype="query">
  	<cfargument name="user_name" type="string" required="true">

    <!--- Lets see if this user has registered, and if so, is he/she authorized --->
    <cfquery name="local.user_record" datasource="#application.dsn#" >
      SELECT TOP 1 *
      FROM [#variables.table_name#]
      WHERE user_name = <cfqueryparam value="#arguments.user_name#" CFSQLTYPE="CF_SQL_VARCHAR" maxlength="20">
    </cfquery>
    
    <cfreturn local.user_record />
  </cffunction>
  
  
  
  
  
  
  
  <cffunction name="get_user_site_access" access="private" output="false" returntype="query">
    <cfargument name="user_id" required="true" type="numeric">

        <cfquery name="user_sites" datasource="#application.dsn#">
            SELECT iwrs_user_sites.id, iwrs_user_sites.iwrs_user_id, iwrs_user_sites.site_id, sites.site_name
            FROM iwrs_user_sites, sites
            WHERE iwrs_user_id = <cfqueryparam value="#user_id#" cfsqltype="CF_CQL_INT" null="No"> 
            AND sites.id = iwrs_user_sites.site_id
            ORDER BY site_id
        </cfquery>

        <cfreturn user_sites>
  </cffunction>


  <cffunction name="get_admin_site_access" access="private" output="false" returntype="query">

        <cfquery name="user_sites" datasource="#application.dsn#">
            SELECT id AS site_id, site_name from sites
        </cfquery>

        <cfreturn user_sites>
  </cffunction>





<!--- Get the record, define member variables from record field names and values.--->
	<cffunction name="build_orm_object" output="false" access="private" returntype="void">
		<cfargument name="rec" required="true" type="Query">

		<cfloop array=#variables.field_names# index="field_name">
			<cfset this[#field_name#]= rec[#field_name#]>
		</cfloop>
	</cffunction>
    
    
	
    
    
    
	<!--- Look for a record with the specified id, throw an error if it is not found. --->
	<cffunction name="find_record_by_id" output="false" access="private" returntype="Query">
		<cfargument name="record_id" required="true" type="numeric">
		
		<cfquery name="record" datasource="#application.dsn#">
			SELECT TOP 1 * FROM [#variables.table_name#]
				WHERE id = <cfqueryparam value="#arguments.record_id#" cfsqltype="cf_sql_integer" null="false">
		</cfquery>
		
		<cfif record.recordCount EQ 0>
			<cfthrow type="custom" message="No record found.">
		</cfif>
		
		<cfreturn record>
	</cffunction>

</cfcomponent>
