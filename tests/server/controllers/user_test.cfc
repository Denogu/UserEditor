<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator" >

  <cfset USER_NAME = "test_user" />
  <cfset EMAIL = "krishna.poddar@va.gov" />
   


  <cffunction name="setup" access="public">
     <cfset user = CreateObject("component", "models.user") />
     <cfset makePublic(user, "create", "create") />
     <cfset user.create(user_name = USER_NAME, first_name = "test_first_name", 
          last_name = "test_last_name", site_number = "999", 
          email = EMAIL, role_id = 1) />
  </cffunction>
  
  
  <cffunction name="beforeTests" access="public">
  </cffunction>
  
  <cffunction name="tearDown" access="public">
  </cffunction>
  
  <cffunction name="init_from_user_name_user_does_not_exists" access="public">
  		<cfset user_does_not_exists = 'test_user' />
  		<cfquery datasource="#application.dsn#">
        	DELETE FROM iwrs_users where user_name = '#user_does_not_exists#'
        </cfquery>
        <cfset user = CreateObject("component", "models.user").init_from_user_name(user_does_not_exists) />
  </cffunction>

 </cfcomponent>
  

  


 


  


  

 


  

