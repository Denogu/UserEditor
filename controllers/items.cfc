<cfcomponent extends="iwrs_controller">

  <cffunction name="is_authorized" access="Public">
    <cfreturn createObject('component', 'utilities.session_utilities').is_session_current()>
  </cffunction>


  <cffunction name="update_fit_result" access="Public">
    <cfset local.success = 0>
    <cfset local.message = "">

    <cfif isDefined('this.params.in_cprs')>
      <cfset local.in_cprs = "1">
    <cfelse>
      <cfset local.in_cprs = "0">
    </cfif>

    <cftry>
      <cfset createObject("models.item").update_cprs_notification_field(this.params.id, local.in_cprs)>
      <cfset local.success = 1>
      <cfset local.message = "You have successfully updated the FIT result record.">
    <cfcatch>
      <cfset local.message = cfcatch.message>
    </cfcatch>
    </cftry>

    <cfset local.view_data.in_cprs = local.in_cprs>
    <cfset local.view_data.success = local.success>
    <cfset local.view_data.message = local.message>

    <cfreturn render_partial(view_data=local.view_data)>
    
  </cffunction>


  <cffunction name="fit_results" access="Public">

    <cfif isDefined("url.site")>
      <cfset session.user.site_number = url.site>
    </cfif>

    <cfset local.view_data.sites_to_access = valueArray(session.user.user_site_access, "site_id")>
    <cfif session.user.all_site_access EQ 1>
      <cfset local.view_data.fit_results = createObject("component", "models.item").all() />
      <cfreturn render(view_data=local.view_data)>
    <cfelse>
      <cfif arrayContains(local.view_data.sites_to_access, session.user.site_number)>
        <cfset local.view_data.fit_results = createObject("component", "models.item").all() />
        <cfreturn render(view_data=local.view_data)>
      <cfelse>
        <cfset local.view_data.fit_results = 0>
        <cfreturn render(view_data=local.view_data)>
      </cfif>
    </cfif>
  </cffunction>

  <cffunction name="_dataTable_fit_results" access="Public">

    <cfif isDefined("url.site")>
      <cfset session.user.site_number = url.site>
    </cfif>

    <cfset local.view_data.sites_to_access = valueArray(session.user.user_site_access, "site_id")>
    <cfif session.user.all_site_access EQ 1>
      <cfset local.view_data.fit_results = createObject("component", "models.item").all() />
      <cfreturn render(view_data=local.view_data)>
    <cfelse>
      <cfif arrayContains(local.view_data.sites_to_access, session.user.site_number)>
        <cfset local.view_data.fit_results = createObject("component", "models.item").all() />
        <cfreturn render(view_data=local.view_data)>
      <cfelse>
        <cfset local.view_data.fit_results = 0>
        <cfreturn render(view_data=local.view_data)>
      </cfif>
    </cfif>
  </cffunction>



  <cffunction name="cprs_form" access="Public">
    <cfset local.fit_result_record = createObject("component", "models.item").details(this.params.id) />
    <cfset local.view_data.id = this.params.id>
    <cfset local.view_data.kit_number = local.fit_result_record.kit_number>
    <cfset local.view_data.subject_number = local.fit_result_record.subject_number>
    <cfset local.view_data.first_name = local.fit_result_record.first_name>
    <cfset local.view_data.last_name = local.fit_result_record.last_name>
    <cfset local.view_data.ssn = local.fit_result_record.ssn>
    <cfset local.view_data.tested_on = local.fit_result_record.tested_on>
    <cfset local.view_data.is_positive = local.fit_result_record.is_positive>
    <cfset local.view_data.item_id = local.fit_result_record.actions>
    <cfset local.view_data.in_cprs = local.fit_result_record.in_cprs>

    <cfreturn render_partial(view_data=local.view_data)>
  </cffunction>

</cfcomponent>
