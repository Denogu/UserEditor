<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator" >
<!--- nvd, how set up unit test data in db? --->
  <cfset item_service = ''>
  <cfset SITE_NUMBER = '888'/>
  <cfset SUBJECT_NUMBER = '9999' />
  <cfset ALPHA_CODE = 'WXYZ' />
  <cfset USER_NAME = 'mx_unit_assignment_test' />
  <cfset UTC_OFFSET = 360>
  <cfset PACKAGE_DEFINITION_ID = 272>
  <cfset CUTOFF_PRIOR_TO_EXPIRATION = 90>


  <cffunction name="setup" access="public">
    <cfset variables.item_service = createObject('component', 'utilities.item_services').init()>
  </cffunction>


  <cffunction name="insert_user_record" access="private">
    <cfquery name="local.record" datasource="#application.dsn#">
          INSERT [iwrs_users] ([user_name], [first_name], [last_name], [email], [site_number], [is_locked],
          [authorized_at], [authorized_by], [role_id], [all_site_access], [can_manage_users], [can_unblind], [is_crpcc],
          [current_session_id], [created_at], [updated_at], [updated_by])
          VALUES (N'" & USER_NAME & "', N'na', N'van', N'nathan.vandelinder@va.gov', N'301',
          0, CAST(N'2017-05-22T00:00:00.000' AS DateTime), N'me', 2, 1, 1, 1, 1, NULL, CAST(N'2017-05-22T20:48:52.463' AS DateTime),
          CAST(N'2017-05-22T20:48:52.463' AS DateTime), N'nvd')
    </cfquery>
  </cffunction>


  <cffunction name="insert_item_and_user_record" access="private">
    <cfset PACKAGE_DEFINITION_ID = 272>
    <cfset LOT_ID = 23650>
    <cfset BOTTLE_NUMBER = 8956>
    <cfset BOTTLE_NUMBER_2 = 8564>
    <cfset ASSIGNMENT_TYPE_ID = 1>
    <cfset JUSTIFICATION = 'assignment test'>

    <cfset insert_user_record() />

    <cfset item = createObject('component', 'models.item').create(attributes = {site_id=SITE_NUMBER, 
      package_definition_id=PACKAGE_DEFINITION_ID, lot_id=LOT_ID, number=BOTTLE_NUMBER,
      user_name = USER_NAME}, is_do_not_validate = true) />

   <cfset var item = createObject('component', 'models.item').create(attributes = {site_id=SITE_NUMBER, 
      package_definition_id=PACKAGE_DEFINITION_ID, lot_id=LOT_ID, number=BOTTLE_NUMBER,
      user_name = USER_NAME}, is_do_not_validate = true) />

    <cfset var item_status = createObject('component', 'models.item_status').create(attributes = { 
      item_id = item.id, status_id = 1, reason = 'unit test', from_external_source = 0,
      user_name = USER_NAME}, is_do_not_validate = true) />
      
    <cfset item = createObject('component', 'models.assignment_type_treatment_mapping')
      .create(attributes = {id = 787, assignment_type_id = ASSIGNMENT_TYPE_ID,
        package_definition_id = PACKAGE_DEFINITION_ID, cutoff_prior_to_expiration = CUTOFF_PRIOR_TO_EXPIRATION, 
        medication = 'mxunit med', treatment_arm = 1, user_name = USER_NAME}, is_do_not_validate = true) />

  </cffunction>


  <cffunction name="get_next_available_none_available">
    <cftry>
      <cfset insert_item_and_user_record()>
      <cfset variables.item_service.get_next_available(
        package_definition_id = PACKAGE_DEFINITION_ID,
        days_prior_to_expiration = CUTOFF_PRIOR_TO_EXPIRATION,
        site_number = SITE_NUMBER,
        drug_quantity = 1)>
      <cfcatch type="custom">
        <cfset assertEquals(item_service.ERROR_MESSAGE_INVENTORY, cfcatch.message)>
      </cfcatch>
    </cftry>
  </cffunction>




</cfcomponent>