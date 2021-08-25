<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator" >
  <cfset USER_NAME = "MXUnitTestUser" />
  <cfset EMAIL = "zachary.taylor2@va.gov" />
  <cfset SITE_NUMBER = "501" />
  <cfset PASSWORD = "myPassword1!" />


  <cffunction name="setup" access="public">
    <cfinvoke component="utilities.captcha" method="random_captcha_string" returnvariable="captcha_string"></cfinvoke>
    <cfset session.captcha = captcha_string>
    <cfset session.user.name = 'test_script'>
    <cfset user = CreateObject("component", "models.user") />
    <cfset array_utilities = CreateObject("component", "utilities.array_utilities") />
    <cfset query_utilities = CreateObject("component", "utilities.query_utilities") />
    <cfset makePublic(user, "insert_record", "insert_record") />
    <cfset registration_form_answers = { captcha_string='#session.captcha#', 
                                         user_name='#USER_NAME#', 
                                         password='#PASSWORD#', 
                                         password_verification='#PASSWORD#', 
                                         first_name='test', 
                                         last_name='user', 
                                         email='#EMAIL#', 
                                         email_verification='#EMAIL#', 
                                         user_role='1', 
                                         study_site_number='#SITE_NUMBER#'
                                       } />
    <cfset switch_to_intranet_site() />
    <cfset deleteUserRecord(user_name="#USER_NAME#") />
  </cffunction>
  

  
  <cffunction name="beforeTests" access="public">
  </cffunction>
  


  <cffunction name="tearDown" access="public">    
  </cffunction>
  


  <cffunction name="switch_to_internet_site" access="private">    
    <cfset application.intranet_site = 0 />
  </cffunction>



  <cffunction name="switch_to_intranet_site" access="private">
    <cfset application.intranet_site = 1 />
  </cffunction>



  <cffunction name="deleteUserRecord" access="private">
    <cfargument name="user_name" type="string" required="true">

    <cfquery name = "local.user_record" datasource = "#application.dsn#">
      DECLARE @user_id int 
      SELECT TOP 1 @user_id=id from iwrs_users where user_name = <cfqueryparam value = "#arguments.user_name#" CFSQLType = "CF_SQL_VARCHAR">

      DELETE from iwrs_users where id = @user_id
    </cfquery>
  </cffunction>



  <cffunction name="test_register_intranet" access="public">
    <cfset makePublic(user, "register_for_intranet", "register_for_intranet") />
    <cfset local.user_id = user.register_for_intranet(user_name='#USER_NAME#', first_name='Joseph', last_name='TesterGuy', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1') />
    <cfset debug('register user for intranet.') />
    <cfset debug(user.init(local.user_id)) />
    <cfset assertTrue(local.user_id GT 0, "Test failed for registering user for intranet. ") />   
  </cffunction>
    



  <cffunction name="test_register_intranet_duplicateUsername" access="public">
    <cfset makePublic(user, "register_for_intranet", "register_for_intranet") />
    <cfset local.user_id_1 = user.register_for_intranet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1') />	
    <cfset debug('register user for intranet for duplicate username.') />  
    <cftry> 
      <cfset local.user_id_2 = user.register_for_intranet(user_name='#USER_NAME#', first_name='krishna_2', last_name='test_2', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1') /> 
      <cfset fail("It should not reach here. Function throws an error when there's duplicate username") />
      <cfcatch type="mxunit.exception.AssertionFailedError"  >
        <cfrethrow>
      </cfcatch>
      <cfcatch type="any">
        <!--- <cfset assertTrue(1 GT 2, "#cfcatch.message#") />--->
      </cfcatch>
    </cftry> 
    <cfset assertTrue(true) />   
  </cffunction>
  
  

  <cffunction name="test_is_registered_userNotExists" access="public">
    <cfset expected_response = 'false' />
    <cfset user_name = '#USER_NAME#' />
    <cfset actual_response = user.is_registered('#user_name#') />
    <cfset debug(actual_response)/>
    <cfset assertTrue(expected_response EQ actual_response, "Test failed for checking if user is registered when user record for #user_name# does not exists.") />
  </cffunction>



  <cffunction name="test_is_registered_userExists" access="public">
    <cfset expected_response = 'true' />
    <cfset user_name = '#USER_NAME#' />
    <cfset makePublic(user, "register_for_intranet", "register_for_intranet") />
    <cfset local.user_id = user.register_for_intranet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1') /> 
    <cfset actual_response = user.is_registered('#user_name#') />
    <cfset debug(actual_response)/>
    <cfset assertTrue(expected_response EQ actual_response, "Test failed for checking if user is registered when user record for #user_name# exists.") />
  </cffunction>



  <cffunction name="test_registration_validation_errors_badUsername" access="public">
    <cfset expected_response = ["Please enter a valid Username."] />    
    <cfset bad_user_name = ['', 'AB', 'ABCD@'] />
    
    <cfloop array="#bad_user_name#" index="idx">
      <cfset registration_form_answers['user_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <cfset debug("bad_user_name = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad username #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodUsername" access="public">
    <cfset expected_response = ["Please enter a valid Username."] />    
    <cfset good_user_name = ['ABC', 'ABCD1234', '1234', 'VHA18\vhaabqpoddak0'] />    

    <cfloop array="#good_user_name#" index="idx">      
      <cfset registration_form_answers['user_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <cfset debug("good_user_name = " & idx) /> 
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good username #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_UserIsRegistered">
    <cfset expected_response = ["The username you specified is already registered in the system."] />
    <cfset makePublic(user, "register_for_intranet", "register_for_intranet") />
    
    <!---Add a user --->
    <cfset local.user_id_1 = user.register_for_intranet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1') /> 
    <cfset debug("user_name_1 = " & USER_NAME) />

    <!---Try to add the same user --->
    <cfset registration_form_answers['user_name'] = USER_NAME />      
    <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
    <cfset debug("user_name_2 = " & registration_form_answers['user_name']) /> 
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when the user is already registered.") />
  </cffunction>



  <cffunction name="test_registration_validation_errors_badFirstName" access="public">
    <cfset expected_response = ["Please enter a valid first name."] />    
    <cfset bad_first_name = ['', 'A', 'ABCD@'] />
      
    <cfloop array="#bad_first_name#" index="idx">
      <cfset registration_form_answers['first_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
       <!--- <cfset debug(validation_errors) /> --->
      <cfset debug("bad_first_name = " & idx) />       
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad firstname #idx# was submitted.") />
    </cfloop>    
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodFirstName" access="public">
    <cfset expected_response = ["Please enter a valid first name."] />    
    <cfset good_first_name = ['AB', 'A1', 'abcd1'] />
      
    <cfloop array="#good_first_name#" index="idx">
      <cfset registration_form_answers['first_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!--- <cfset debug(validation_errors) /> --->
      <cfset debug("good_first_name = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good firstname #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodLastName" access="public">
    <cfset expected_response = ["Please enter a valid last name."] />    
    <cfset good_last_name = ['AB', 'A1', 'abcd1'] />
      
    <cfloop array="#good_last_name#" index="idx">
      <cfset registration_form_answers['last_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("good_last_name = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good lastname #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_badLastName" access="public">
    <cfset expected_response = ["Please enter a valid last name."] />    
    <cfset bad_last_name = ['', 'A', 'ABCD@'] />
      
    <cfloop array="#bad_last_name#" index="idx">
      <cfset registration_form_answers['last_name'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("bad_last_name = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad lastname #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_badEmail" access="public">
    <cfset expected_response = ["Please enter a valid email address."] />    
    <cfset bad_email = ['', '@', '@ABCD.ben', 'abcd@abc.', 'abcd.@.com'] />
    
    <cfloop array="#bad_email#" index="idx">
      <cfset registration_form_answers['email'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("bad_email = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad email #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodEmail" access="public">
    <cfset expected_response = ["Please enter a valid email address."] />    
    <cfset good_email = ['ABC@va.gov', 'ABCD.XVZ@va.gov'] />
    
    <cfloop array="#good_email#" index="idx">
      <cfset registration_form_answers['email'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("good_email = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good email #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodEmailConfirmation" access="public">
    <cfset expected_response = ["You must verify your email address before you can register.  Please make sure what you entered in the email confirmation box matches what you entered for your email."] />    
    <cfset good_email_confirmation = ['#registration_form_answers['email']#'] />
    
    <cfloop array="#good_email_confirmation#" index="idx">
      <cfset registration_form_answers['email_verification'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("email = #registration_form_answers['email']#") />
      <cfset debug("email_confirmation = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with matching email confirmation #idx# was submitted.") />
    </cfloop>   
  </cffunction>



  <cffunction name="test_registration_validation_errors_badEmailConfirmation" access="public">
    <cfset expected_response = ["You must verify your email address before you can register.  Please make sure what you entered in the email confirmation box matches what you entered for your email."] /> 
    <cfset bad_email_confirmation = ['ab#registration_form_answers['email']#'] />
    
    <cfloop array="#bad_email_confirmation#" index="idx">
      <cfset registration_form_answers['email_verification'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("email = #registration_form_answers['email']#") />
      <cfset debug("email_confirmation = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with non-matching email confirmation #idx# was submitted.") />
    </cfloop>     
  </cffunction>



  <cffunction name="test_registration_validation_errors_badRole" access="public">
    <cfset expected_response = ["Please select a valid Role."] />    
    <cfset bad_role = ['', '0', '3', 'site_team'] />
    
    <cfloop array="#bad_role#" index="idx">
      <cfset registration_form_answers['user_role'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("bad_role_id = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad role #idx# was submitted.") />
    </cfloop>      
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodRole" access="public">
    <cfset expected_response = ["Please select a valid Role."] />    
    <cfset roles = createObject("component", "models.role").all_readable() />
    <cfset good_role = query_utilities.queryColumnToArray(Query=roles, columnName="id") />
    
    <cfloop array="#good_role#" index="idx">
      <cfset registration_form_answers['user_role'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("good_role_id = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good role #idx# was submitted.") />
    </cfloop>    
  </cffunction>



  <cffunction name="test_registration_validation_errors_goodSite" access="public">
    <cfset expected_response = ["Please select a valid Site."] />  
    <cfset sites = createObject("component", "models.site").all_readable() />  
    <cfset good_site = query_utilities.queryColumnToArray(Query=sites, columnName="number") />
    
    <cfloop array="#good_site#" index="idx">
      <cfset registration_form_answers['study_site_number'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("good_site = " & idx) />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good site #idx# was submitted.") />
    </cfloop>        
  </cffunction>



  <cffunction name="test_registration_validation_errors_badSite" access="public">
    <cfset expected_response = ["Please select a valid Site."] />  
    <cfset bad_site = ['', 'abc', '1001'] />
    
    <cfloop array="#bad_site#" index="idx">
      <cfset registration_form_answers['study_site_number'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("bad_site = " & idx) />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad site #idx# was submitted.") />
    </cfloop>    
  </cffunction>



  <cffunction name="test_registration_validation_errors_badCaptcha" access="public">
    <cfset expected_response = ["You must correctly enter the text from the captcha image."] />  
    <cfset bad_captcha = [' ', '#session.captcha#ab'] />
    
    <cfloop array="#bad_captcha#" index="idx">
      <cfset registration_form_answers['captcha_string'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("bad_captcha = " & idx) />
      <cfset debug("actual captcha = #session.captcha#") />       
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad captcha #idx# was submitted.") />
    </cfloop>  
  </cffunction>



  <cffunction name="test_registration_validation_errors_matchingCaptcha" access="public">
    <cfset expected_response = ["You must correctly enter the text from the captcha image."] />  
    <cfset input_captcha = ['#session.captcha#'] />
    
    <cfloop array="#input_captcha#" index="idx">
      <cfset registration_form_answers['captcha_string'] = idx />      
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
      <!---  <cfset debug(validation_errors) /> --->
      <cfset debug("input_captcha = " & idx) />
      <cfset debug("actual captcha = #session.captcha#") />       
      <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with captcha #idx# was submitted.") />
    </cfloop>  
  </cffunction>



  <cffunction name="test_register_intranetUserSuccess" access="public">
    <cfset expected_response = {message = 'Thank you for registering. You will receive an email when your account is authorized to use the system.', is_success = 'true', validation_errors = []} />
    <cfset actual_response = user.register(registration_form_answers) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.Equals(expected_response), "Test failed for registering when in intranet.") /> 
  </cffunction>



  <cffunction name="test_register_intranetUserFailure" access="public">
    <cfset expected_response = {message = 'User Registration Error', is_success = 'false', validation_errors = ["Please enter a valid first name."]} />
    <cfset registration_form_answers['first_name'] = "A-" />
    <cfset actual_response = user.register(registration_form_answers) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.Equals(expected_response), "Test failed for registering when a form with bad first name submitted.") /> 
  </cffunction>



  <cffunction name="test_get_record_by_username_userNotExists">
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />
    <cfset actual_response = user.get_record_by_username(user_name='#USER_NAME#') />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.recordCount EQ 0, "test failed for get_record_by_username when user does not exists.") />
  </cffunction>



  <cffunction name="test_get_record_by_username_userExists">
    <cfset user.register(registration_form_answers) />
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />
    <cfset actual_response = user.get_record_by_username(user_name='#USER_NAME#') />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.recordCount EQ 1, "test failed for get_record_by_username when user exists.") />
  </cffunction>



  <cffunction name="test_validate_login_form_userNotExistsIntranet" access="public">
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["User record not found. If you need access to this website, you must fill out and submit a registration form."]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for intranet user when username does not exists.") />
  </cffunction>



  <cffunction name="test_validate_login_form_accountLocked" access="public">
    <cfset user.register(registration_form_answers) />  
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["This user account is currently locked. Please contact the site administrator to unlock the account."]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for when user account is locked.") />
  </cffunction>



  <cffunction name="test_validate_login_form_userNotAuthorized" access="public">
    <cfset user.register(registration_form_answers) />  

    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = NULL, authorized_by = NULL
      where user_name = '#USER_NAME#'
    </cfquery>

    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["This user account is not currently authorized to access the site.  Please contact the site administrator if you believe the account should be authorized."]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for when user account is locked.") />
  </cffunction>



  <cffunction name="test_validate_login_form_intranetSuccess">
    <cfset user.register(registration_form_answers) />  

    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by = 'test_script'
      where user_name = '#USER_NAME#'
    </cfquery>

    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(ArrayIsEmpty(actual_response) , "Test failed for validate_login_form for intranet.") />    
  </cffunction>


<!--- Internet only
 

  <cffunction name="test_register_internet" access="public">
    
      <cfset makePublic(user, "register_for_internet", "register_for_internet") />  
      <cfset local.user_id = user.register_for_internet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1', password='uvwxvz') />
      <cfset debug('register user for internet facing site.') />
      <cfset debug(user.init(local.user_id)) />
      <cfset assertTrue(local.user_id GT 0, "Test failed for registering user for internet.") />
  </cffunction>
  

  <cffunction name="test_register_internet_duplicateUsername" access="public">
    
      <cfset makePublic(user, "register_for_internet", "register_for_internet") />  
      <cfset local.user_id = user.register_for_internet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1', password='uvwxvz') /> 
      
      <cfset debug('register user for internet facing site for duplicate username.') />
      <cftry>    
        <cfset local.user_id = user.register_for_internet(user_name='#USER_NAME#', first_name='krishna', last_name='test', site_number='#SITE_NUMBER#', email='#EMAIL#', role_id='1', password='uvwxvz') />
        <cfset fail("It should not reach here. Function throws an error when there's duplicate username") />
      <cfcatch type="mxunit.exception.AssertionFailedError"  >
        <cfrethrow>
      </cfcatch>
      <cfcatch type="any">
      </cfcatch>
      </cftry> 
      <cfset assertTrue(true) />
  </cffunction>

  <cffunction name="test_validate_login_form_userNotExistsInternet" access="public">
    <cfset switch_to_internet_site()/>
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["The username or password is incorrect."]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for internet user when username does not exists.") /> 
  </cffunction>


  <cffunction name="test_validate_login_form_incorrectPassword" access="public">
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    
    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by='test_script'
      where user_name = '#USER_NAME#'
    </cfquery>

    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["The username and/or password you entered are incorrect. Only #application.failed_logins_allowed# login attempts are allowed, after that your account gets locked. Login attempts remaining #application.failed_logins_allowed - (local.user_record.failed_login_attempts +  1)#."]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="wrong_#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for when user account is locked.") />
  </cffunction>


  <cffunction name="test_validate_login_form_PasswordExpired" access="public">
    <cfset switch_to_internet_site()/>
    <cfset user.register(registration_form_answers) />  

    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by = 'test_script', expires_on = DATEADD("D", -1, GETUTCDATE())
      where user_name = '#USER_NAME#'
    </cfquery>

    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset expected_response = ["Your password has expired and must be changed. <b><a href='reset_password_form'>Reset password</a></b>"]      />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, actual_response), "Test failed for validate_login_form for when user account is locked.") />   
  </cffunction>


  <cffunction name="test_validate_login_form_internetSuccess">
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />  

    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by = 'test_script'
      where user_name = '#USER_NAME#'
    </cfquery>

    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset actual_response = user.validate_login_form(user_record=local.user_record, login_values={user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(ArrayIsEmpty(actual_response) , "Test failed for validate_login_form for internet.") />
  </cffunction>


  <cffunction name="test_register_internetUserSuccess" access="public">
    <cfset switch_to_internet_site() />
    <cfset expected_response = {message = 'Thank you for registering. You will receive an email when your account is authorized to use the system.', is_success = 'true', validation_errors = []} />
    <cfset actual_response = user.register(registration_form_answers) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.Equals(expected_response), "Test failed for registering when in internet facing site.") /> 
  </cffunction>


  <cffunction name="test_register_internetUserFailure" access="public">
    <cfset switch_to_internet_site() />
    <cfset expected_response = {message = 'User Registration Error', is_success = 'false', validation_errors = ["Please enter a valid first name."]} />
    <cfset registration_form_answers['first_name'] = "A-" />
    <cfset actual_response = user.register(registration_form_answers) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.Equals(expected_response), "Test failed for registering when a form with bad first name submitted.") /> 
  </cffunction>


  <cffunction name="test_registration_validation_errors_blankForm" access="public">
      <cfset switch_to_internet_site()/>
      <cfset expected_response = ["Please enter a valid Username.", "The password entered does not meet the specified criteria.", "Please enter a valid last name.", "Please enter a valid first name.", "Please enter a valid email address.", "Please select a valid Role.", "Please select a valid Site."] />    

      <cfset registration_form_answers = {captcha_string='#session.captcha#', user_name='', password='', password_verification='', first_name='', last_name='', email='', email_verification='', user_role='', study_site_number=''} />
      <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />      
      <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a blank form was submitted.") />
  </cffunction>


  <cffunction name="test_registration_validation_errors_badPassword" access="public">
      <cfset switch_to_internet_site() />
      <cfset expected_response = ["The password entered does not meet the specified criteria."] />    
      <cfset bad_password = ['ABCDEFGH', 'abcdefgh', '12345678', 'Abcdefg1', 'A1234567', 'ABc@123', 'Abcdefg1'] />     
      
      <cfloop array="#bad_password#" index="idx">      
        <cfset registration_form_answers['password'] = idx />  
        <cfset registration_form_answers['password_verification'] = idx />
        <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />
        <cfset debug("bad_password = " & idx) /> 
        <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with bad password #idx# was submitted.") />
      </cfloop>  
  </cffunction>

  
  <cffunction name="test_registration_validation_errors_goodPassword" access="public">
      <cfset switch_to_internet_site() />
      <cfset expected_response = ["The password entered does not meet the specified criteria."] />    
      <cfset good_password = ['Abcdef@1', '1234@Abc'] />     

      <cfloop array="#good_password#" index="idx">      
        <cfset registration_form_answers['password'] = idx />  
        <cfset registration_form_answers['password_verification'] = idx />
        <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) />      
        <cfset debug("good_password = " & idx) />       
        <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with good password #idx# was submitted.") />
      </cfloop>  
  </cffunction>


  <cffunction name="test_registration_validation_errors_goodPasswordConfirmation" access="public">
      <cfset switch_to_internet_site() />
      <cfset expected_response = ["Please make sure the password you entered in the password verification field matches what you entered for your password."] />    
      <cfset good_password_confirmation = ["#registration_form_answers['password']#"] />     

      <cfloop array="#good_password_confirmation#" index="idx">            
        <cfset registration_form_answers['password_verification'] = idx />
        <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) /> <cfset debug("password = " & registration_form_answers['password']) />    
        <cfset debug("good_password_confirmation = " & idx) />       
        <cfset assertTrue(not array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with matching password confirmation #idx# was submitted.") />
      </cfloop>  
      
  </cffunction>





  <cffunction name="test_registration_validation_errors_badPasswordConfirmation" access="public">
      <cfset switch_to_internet_site() />
      <cfset expected_response = ["Please make sure the password you entered in the password verification field matches what you entered for your password."] />    
      <cfset bad_password_confirmation = [" ", "ab#registration_form_answers['password']#"] />     

      <cfloop array="#bad_password_confirmation#" index="idx">            
        <cfset registration_form_answers['password_verification'] = idx />
        <cfset validation_errors = user.get_registration_validation_errors(registration_form_answers) /> <cfset debug("password = " & registration_form_answers['password']) />    
        <cfset debug("bad_password_confirmation = " & idx) />       
        <cfset assertTrue(array_utilities.arrayIsContainedIn(expected_response, validation_errors), "Test failed for registration validation when a form with non-matching password confirmation #idx# was submitted.") />
      </cfloop>  
  </cffunction>


  <cffunction name="test_update_failed_login_attempts_lessThanAllowedLimit">
    <cfset application.failed_logins_allowed = 3 />
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />
    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0
      where user_name = '#USER_NAME#'
    </cfquery>
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset makePublic(user, 'update_failed_login_attempts', 'update_failed_login_attempts') />
    <cfset user.update_failed_login_attempts(user_id=local.user_record.id, failed_attempts=1) />
    <cfset user_record_after_update = user.get_record_by_username(USER_NAME) />
    <cfset debug(user_record_after_update) />
    <cfset assertTrue( user_record_after_update.failed_login_attempts EQ 1 and user_record_after_update.is_locked EQ 0, "Test failed for update_failed_login_attempts when attempts below limit.") />
  </cffunction>


  <cffunction name="test_update_failed_login_attempts_GreaterThanEqualAllowedLimit" access="public"> 
    <cfset application.failed_logins_allowed = 3/>
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />
    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0
      where user_name = '#USER_NAME#'
    </cfquery>
    <cfset makePublic(user, 'get_record_by_username', 'get_record_by_username') />   
    <cfset local.user_record = user.get_record_by_username(USER_NAME) />
    <cfset makePublic(user, 'update_failed_login_attempts', 'update_failed_login_attempts') />
    <cfset user.update_failed_login_attempts(user_id=local.user_record.id, failed_attempts=3) />
    <cfset user_record_after_update = user.get_record_by_username(USER_NAME) />
    <cfset debug(user_record_after_update) />
    <cfset assertTrue( user_record_after_update.failed_login_attempts EQ 3 and user_record_after_update.is_locked EQ 1, "Test failed for update_failed_login_attempts when attempts below limit.") />
  </cffunction>


  <cffunction name="test_login_internet_AccessNotGranted" access="public">
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />    
    <cfset expected_response = {is_success = false, message = "Sign in failed.", validation_errors=["This user account is currently locked. Please contact the site administrator to unlock the account."]} />
    <cfset actual_response = user.login(login_form = {user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.equals(expected_response), "Test failed for internet login when user was locked.") />
  </cffunction>


  <cffunction name="test_login_internet_AccessWasGranted" access="public">
    <cfset switch_to_internet_site() />
    <cfset user.register(registration_form_answers) />
    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by = 'test_script'
      where user_name = '#USER_NAME#'
    </cfquery>
    <cfset expected_response = {is_success = true, message = "Sign in successful.", validation_errors=[]} />
    <cfset actual_response = user.login(login_form = {user_name="#USER_NAME#", password="#PASSWORD#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.equals(expected_response), "Test failed for internet login when user was not locked.") />
  </cffunction>

--->



  <cffunction name="test_login_intranet_AccessNotGranted" access="public">
    <cfset user.register(registration_form_answers) />    
    <cfset expected_response = {is_success = false, message = "Sign in failed.", validation_errors=["This user account is currently locked. Please contact the site administrator to unlock the account."]} />
    <cfset actual_response = user.login(login_form = {user_name="#USER_NAME#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.equals(expected_response), "Test failed for intranet login when user was locked.") />
  </cffunction>






  <cffunction name="test_login_intranet_AccessWasGranted" access="public">
    <cfset user.register(registration_form_answers) />
    <cfquery datasource="#application.dsn#"  >
      UPDATE iwrs_users 
      SET is_locked = 0, authorized_at = GETUTCDATE(), authorized_by = 'test_script'
      where user_name = '#USER_NAME#'
    </cfquery>
    <cfset expected_response = {is_success = true, message = "Sign in successful.", validation_errors=[]} />
    <cfset actual_response = user.login(login_form = {user_name="#USER_NAME#", utc_offset="360"}) />
    <cfset debug(actual_response) />
    <cfset assertTrue(actual_response.equals(expected_response), "Test failed for intranet login when user was not locked.") />
  </cffunction>











  <cffunction name="test_init_from_user_name_userRecordExists" access="public">
    <cfset user.register(registration_form_answers) />
    <cfset user_record = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset assertTrue(user_record.first_name EQ registration_form_answers.first_name and user_record.last_name EQ registration_form_answers.last_name and user_record.email EQ registration_form_answers.email and user_record.user_name EQ registration_form_answers.user_name, "Test failed for initializing by user_name when record exists.")/>

  </cffunction>






  <cffunction name="test_init_from_user_name_userRecordNotExists" access="public">
    
    <cftry>
      <cfset user_record = user.init_from_user_name(user_name="#USER_NAME#") />
      <cfset fail("It should not reach here. Function throws an error when there's username does not exists or more than 1 record found..") />
    <cfcatch type="mxunit.exception.AssertionFailedError"  >
      <cfrethrow>
    </cfcatch>
    <cfcatch type="any">
      <!---<cfset assertTrue(1 GT 2, "#cfcatch.message#") />--->
    </cfcatch>
    </cftry> 
    <cfset assertTrue(true)/>

  </cffunction>






  <cffunction name="test_authorize_new_user_success" access="public">
    <cfset user.register(registration_form_answers) />
    <cfset new_user = user.init_from_user_name(user_name="#USER_NAME#") />    
    <cfset actual_response = new_user.authorize_new_user(authorized_by='test_script') />
    <cfset authorized_user = CreateObject("component", "models.user").init_from_user_name(user_name = "#USER_NAME#") />
    <cfset assertTrue(authorized_user.user_name EQ new_user.user_name and authorized_user.authorized_by EQ 'test_script' and authorized_user.is_locked EQ 0 and IsValid('date', authorized_user.authorized_at), "Test failed for authorize new user.") />
  
  </cffunction>






  <cffunction name="test_authorize_new_user_failure" access="public">
    <cfset user.register(registration_form_answers) />
    
    <cfquery name="update_record" datasource="#application.dsn#">
      UPDATE [iwrs_users]
        SET authorized_at = GETUTCDATE(),
            authorized_by = 'test_script',
            is_locked = 0,
            updated_at = GETUTCDATE(),
            updated_by = 'test_script'
      WHERE user_name = '#USER_NAME#'
    </cfquery>
    <cfset new_user = user.init_from_user_name(user_name="#USER_NAME#") />
    
    <cfset expected_response = {is_success=false, message="This user has already been authorized."} />
    <cfset actual_response = new_user.authorize_new_user(authorized_by='test_script') />

    <cfset assertTrue(actual_response.equals(expected_response), 'Test failed for authorize new user.') />
  </cffunction>






  <cffunction name="test_revoke_user_access_success" access="public">
    <cfset user.register(registration_form_answers) />    
    <cfset new_user = CreateObject("component", "models.user").init_from_user_name(user_name="#USER_NAME#") />     
    <cfset new_user.authorize_new_user(authorized_by='test_script') />  
    <cfset authorized_user =  CreateObject("component", "models.user").init(new_user.ID)  />
    <cfset actual_response = authorized_user.revoke_user_access(revoked_by_user_name='test_script') />
    <cfset deauthorized_user = CreateObject("component", "models.user").init(authorized_user.ID)  />
    <cfset assertTrue(deauthorized_user.user_name EQ new_user.user_name and deauthorized_user.authorized_by EQ '' and deauthorized_user.is_locked EQ 0 and NOT IsValid('date', deauthorized_user.authorized_at), "Test failed for revoking access for user.") />
  
  </cffunction>





  <cffunction name="test_revoke_user_access_failure" access="public">
    <cfset user.register(registration_form_answers) />    
    <cfset new_user = CreateObject("component", "models.user").init_from_user_name(user_name="#USER_NAME#") />         
    <cfset expected_response = {is_success=false, message="This user is not currently authorized to access the site."} />
    <cfset actual_response = new_user.revoke_user_access(revoked_by_user_name='test_script') />
    <cfset assertTrue(actual_response.equals(expected_response), "Test failed for revoking access for user.") />
  
  </cffunction>





  <cffunction name="test_update_user_details_updateFirstName" access="public">
    <cfset user_form = {first_name='test1', last_name=registration_form_answers['last_name'], email=registration_form_answers['EMAIL'], role_id=registration_form_answers['user_role'], site_number=registration_form_answers['study_site_number'], is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset assertTrue(updated_user.first_name EQ user_form.first_name, "Test failed for updating user first name.") />
  </cffunction>






  <cffunction name="test_update_user_details_updateLastName" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name='user_1', email=registration_form_answers['EMAIL'], role_id=registration_form_answers['user_role'], site_number=registration_form_answers['study_site_number'], is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset assertTrue(updated_user.last_name EQ user_form.last_name, "Test failed for updating user last name.") />
  </cffunction>






  <cffunction name="test_update_user_details_updateEmail" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name=registration_form_answers['last_name'], email='test_user@va.gov', role_id=registration_form_answers['user_role'], site_number=registration_form_answers['study_site_number'], is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset assertTrue(updated_user.email EQ user_form.email, "Test failed for updating user email.") />
  </cffunction>






  <cffunction name="test_update_user_details_updateRole" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name=registration_form_answers['last_name'], email=registration_form_answers['EMAIL'], role_id=2, site_number=registration_form_answers['study_site_number'], is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset assertTrue(updated_user.role_id EQ user_form.role_id, "Test failed for updating user role.") />
  </cffunction>

 



  <cffunction name="test_update_user_details_updateSite" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name=registration_form_answers['last_name'], email=registration_form_answers['EMAIL'], role_id=registration_form_answers['user_role'], site_number='000', is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset assertTrue(updated_user.site_number EQ user_form.site_number, "Test failed for updating user site.") />
  </cffunction>






  <cffunction name="test_update_user_details_authorizeUser" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name=registration_form_answers['last_name'], email=registration_form_answers['EMAIL'], role_id=registration_form_answers['user_role'], site_number=registration_form_answers['study_site_number'], is_authorized=1} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.update_user_details(user_form) />
    <cfset updated_user = user.init(registered_user.ID) />
    <cfset debug(updated_user) />
    <cfset assertTrue(updated_user.authorized_by EQ 'test_script' and updated_user.is_locked EQ 0 and IsValid('date', updated_user.authorized_at), "Test failed for authorizing user access.") />
  </cffunction>






  <cffunction name="test_update_user_details_revokeAccess" access="public">
    <cfset user_form = {first_name=registration_form_answers['first_name'], last_name=registration_form_answers['last_name'], email=registration_form_answers['EMAIL'], role_id=registration_form_answers['user_role'], site_number=registration_form_answers['study_site_number'], is_authorized=0} />
    <cfset user.register(registration_form_answers) />
    <cfset registered_user = user.init_from_user_name(user_name="#USER_NAME#") />
    <cfset registered_user.authorize_new_user(authorized_by='test_script') />
    <cfset authorized_user = user.init(registered_user.ID) />

    <cfset authorized_user.update_user_details(user_form) />
    <cfset updated_user = user.init(authorized_user.ID) />
    <cfset debug(updated_user) />
    <cfset assertTrue(updated_user.authorized_by EQ '' and updated_user.is_locked EQ 0 and NOT IsValid('date', updated_user.authorized_at), "Test failed for revoking user access.") />
  </cffunction>





  <!---function update_password_success() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password = "Dude123!";
    var password_confirm = "Dude123!";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.update_password(user.password_reset_token, password, password_confirm);

    // Check that token has expired.
    assertFalse(createObject("component", "models.user")
        .is_password_reset_token_viable(user.password_reset_token), "Token should be invalid (expired).");

    // Check that user can log in with new password.
    makePublic(user, "authorize", "authorize");
    user.authorize("update_password_success_test_authorizer");
    assertTrue(createObject("component", "models.user").login(USER_NAME, password));         
  } --->


  

</cfcomponent>

  


  

 


  




<!---component extends="mxunit.framework.TestCase" {
  
  USER_NAME = "test_user";
  EMAIL = "nathan.vandelinder@yahoo.com";
  HOURS_UNTIL_EXPIRE = 1;

  function setup() {
      var user = createObject("component", "models.user");
      makePublic(user, "create", "create");
      user.create(user_name = USER_NAME, first_name = "test_first_name", 
          last_name = "test_last_name", site_number = "999", 
          email = EMAIL, password="test_password", role_id = 1);   
  }


  function teardown() {
    var deleteStmt = new query(datasource = application.dsn);
    deleteStmt.addParam(name = "user_name", value = USER_NAME & '%');
    deleteStmt.execute(sql = "
        DELETE FROM iwrs_users
        WHERE user_name LIKE :user_name");
  }


  


  function update_password_success_cannot_update_again() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password = "Dude123!";
    var password_confirm = "Dude123!";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.update_password(user.password_reset_token, password, password_confirm);

    // Check that token has expired.
    assertFalse(createObject("component", "models.user")
        .is_password_reset_token_viable(user.password_reset_token), "Token should be invalid (expired).");

    // Check that user can log in with new password.
    makePublic(user, "authorize", "authorize");
    user.authorize("update_password_success_test_authorizer");
    assertTrue(createObject("component", "models.user").login(USER_NAME, password));  

    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assert(user.update_password(user.password_reset_token, password, password_confirm)[1]
      IS "Password reset token has expired.");
  }


  function update_password_bad_token() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password_reset_token = "bad";
    var password = "Dude123!";
    var password_confirm = "Dude123!";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assert(user.update_password(password_reset_token, password, password_confirm)[1] 
      IS "Password reset has not been requested for this user.");
  }


  function update_password_bad_password() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password = "Dude";
    var password_confirm = "Dude";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assert(user.update_password(user.password_reset_token, password, password_confirm)[1]
    IS "Password does not meet security requirements.");
  }


  function update_password_passwords_not_match() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password_reset_token = token;
    var password = "Dude1234$";
    var password_confirm = "Dude123!";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    debug(user.update_password(password_reset_token, password, password_confirm)[1]);
  }


  function update_password_many_problems() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    var password = "Dud";
    var password_confirm = "Dude123!";
    
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assert(user.update_password(user.password_reset_token, password, password_confirm)[1]
      IS "Password does not meet security requirements.");
    assert(user.update_password(user.password_reset_token, password, password_confirm)[2]
      IS "Passwords do not match.");      
  }


  function is_reset_token_viable_yes() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);

    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var is_valid = createObject("component", "models.user")
        .is_password_reset_token_viable(user.password_reset_token);

    assertTrue(is_valid);    
  }


  function is_reset_token_viable_bad_token() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);

    var is_valid = createObject("component", "models.user")
        .is_password_reset_token_viable('bad_token');

    assertFalse(is_valid);    
  }


  function is_reset_token_viable_expired() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(email = EMAIL, hours_until_token_expires = -1);

    var is_valid = createObject("component", "models.user")
        .is_password_reset_token_viable(token);

    assertFalse(is_valid);    
  }


  function is_reset_token_viable_null_expired_date() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(email = EMAIL, hours_until_token_expires = -1);

    var is_valid = createObject("component", "models.user")
        .is_password_reset_token_viable(token);

    assertFalse(is_valid);  
  }


  function is_reset_token_valid_expired() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(email = EMAIL, hours_until_token_expires = -1);
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);

    makePublic(user, "is_password_reset_token_valid", "is_password_reset_token_valid");
    assertFalse(user.is_password_reset_token_valid(token));
  }


  function is_reset_token_valid_bad_token() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE);
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    
    makePublic(user, "is_password_reset_token_valid", "is_password_reset_token_valid");
    assertFalse(user.is_password_reset_token_valid("bad_token"));  
  }


  function is_reset_token_valid_different_token() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    var token = user.reset_password(email = EMAIL, hours_until_token_expires = HOURS_UNTIL_EXPIRE);

    var user2 = createObject("component", "models.user");
    makePublic(user2, "create", "create");

    var user_name_2 = USER_NAME & '2';
    user2.create(user_name = user_name_2, first_name = "test_first_name", 
        last_name = "test_last_name", site_number = "999", 
        email = EMAIL & '2', password="test_password_2", role_id = 1);   

    var user2 = createObject("component", "models.user").init_from_user_name(user_name_2);    
    var token2 = user2.reset_password(email = EMAIL & '2', hours_until_token_expires = HOURS_UNTIL_EXPIRE);

    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    makePublic(user, "is_password_reset_token_valid", "is_password_reset_token_valid");
    assertFalse(user.is_password_reset_token_valid(token2));
  }


  function is_reset_token_valid_yes() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assertTrue(user.reset_password(email = EMAIL, hours_until_token_expires = HOURS_UNTIL_EXPIRE));

    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    makePublic(user, "is_password_reset_token_valid", "is_password_reset_token_valid");
    assertTrue(user.is_password_reset_token_valid(user.password_reset_token));
  }


  function reset_password_not_found() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assertFalse(user.reset_password("bademail@bad.bad", HOURS_UNTIL_EXPIRE));
  } 


  function reset_password_token_success() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assertTrue(user.reset_password(EMAIL, HOURS_UNTIL_EXPIRE));

    user = createObject("component", "models.user").init_from_user_name(USER_NAME);

    assert(len(user.password_reset_token) > 10, "Password reset token unsatisfactory."); 
    assert(len(user.password_reset_token_expires_at) neq '', "Password reset token expiration date unsatisfactory."); 
  } 

  function find_by_username_found() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    
    assertEquals(USER_NAME, user.user_name);
    assertEquals(EMAIL, user.email);
  }


  function find_by_username_not_found() {
    expectException("model");
    createObject("component", "models.user").init_from_user_name("~bad_user_name~");
  }


 
  function register_success() {
    teardown();

    createObject("component", "models.user").register(
      user_name = USER_NAME,
      first_name = "Test",
      last_name = "er",
      site_number = "310",
      email = EMAIL,
      password = "Dude123!",
      role_id = 1);
    
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);

    var deleteStmt = new query(datasource = application.dsn);
    deleteStmt.addParam(name = "user_id", value = user.id);
    deleteStmt.execute(sql = "
        DELETE FROM iwrs_user_password_history
        WHERE user_id = :user_id");        
  }
 

   function get_role_for_user() {
    var user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    assertEquals("Site team", user.role().name);
  }


}--->
