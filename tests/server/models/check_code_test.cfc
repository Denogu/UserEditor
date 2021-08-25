<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator" >
  <cfset USER_NAME = "MXUnitTestUser" />
  <cfset EMAIL = "zachary.taylor2@va.gov" />
  <cfset SITE_NUMBER = "501" />
  <cfset PASSWORD = "myPassword1!" />


  <cffunction name="setup" access="public">
    <cfset myComp = CreateObject("component", "models.check_code") />
    <cfset session.user.site_number = SITE_NUMBER>
  </cffunction>
  

  
  <cffunction name="beforeTests" access="public">
  </cffunction>
  


  <cffunction name="tearDown" access="public">    
  </cffunction>

<!---TEST #confirm_eligibility function. ---> 
  <cffunction name="test_confim_eligibility_requires_subject_number" access="public">
    <cfset expectException('Application')>
    <cfset myComp.confirm_eligibility(check_code = 'abcd')>
  </cffunction>

  
  <cffunction name="test_confim_eligibility_requires_check_code" access="public">
    <cfset expectException('Application')>
    <cfset myComp.confirm_eligibility(subject_number = '5010001')>
  </cffunction>


  <cffunction name="test_confirm_eligibility_throws_error_if_subject_number_does_not_match_session_site_number" access="public">
    <cfset expectException('IWRS.CheckCode.InvalidSubjectNumber')>
    <cfset local.subject_number = "#SITE_NUMBER + 1#0001">
    <cfset myComp.confirm_eligibility(subject_number = local.subject_number, check_code = 'abcd')>
  </cffunction>


  <cffunction name="test_confirm_eligibility_returns_false_if_no_record_exists" access="public">
    <cfset local.is_eligible = myComp.confirm_eligibility(subject_number = "#SITE_NUMBER#9999", check_code = 'zzzz')>
    <cfset assertFalse(local.is_eligible, "Confirm eligibility should return false if no record exists.")>
  </cffunction>


  <cffunction name="test_confirm_eligibility_returns_true_if_record_exists" access="public">
    <cfset local.check_code_rec = get_first_check_code_rec()>
    <cfset local.is_eligible = myComp.confirm_eligibility(subject_number = local.check_code_rec.subject_number, check_code = local.check_code_rec.check_code)>
    <cfset assertTrue(local.is_eligible, "Confirm eligibility should return true if record exists.")>
  </cffunction>

<!--- PRIVATE METHODS --->

<cffunction name="get_first_check_code_rec" access="private" returntype="Query">
  <cfquery name="local.check_code_rec" datasource="#application.dsn#" maxrows="1">
    SELECT top 1 * 
    FROM iwrs_check_codes
    WHERE left(subject_number, 3) = <cfqueryparam value="#SITE_NUMBER#">
  </cfquery>

  <cfreturn local.check_code_rec>
</cffunction>

</cfcomponent>
