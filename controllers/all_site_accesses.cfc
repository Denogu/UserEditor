<cfcomponent extends="iwrs_controller">
  <cffunction name="is_authorized" access="Public">
    <cfreturn createObject('component', 'utilities.session_utilities').is_session_current()>
  </cffunction>


  <cffunction name="switch_site_form" output="true" access="Public">
    <cfset local.view_data.current_site = this.params.current_site>
    <cfreturn render_partial(view_data=local.view_data)>
  </cffunction>


  <cffunction name="switch_site" output="true" access="Public">
    <cfset session.user.site_number = this.params.new_site_number>
    <cfreturn redirect('/items/fit_results')>
  </cffunction>


  <cffunction name="switch_site_dropdown" output="true" access="Public">
    <cfset session.user.site_number = url.site>
    <cfreturn redirect('/items/fit_results')>
  </cffunction>


  <cffunction name="site_dropdown" output="true" access="Public">
    <cfset local.view_data.user_site_access = session.user.user_site_access />
    <cfreturn render_partial(view_data=local.view_data)>
  </cffunction>

</cfcomponent>