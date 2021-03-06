<cfcomponent extends="core.controller">  

  <cffunction name="enforce_access_restraints" access="private" returntype="struct">
    <cfset local.redirect_params = StructNew()>
    <cfset local.has_current_session = createObject('component', 'utilities.session_utilities')
      .is_session_current()>

    <cfif this.requires_current_session() AND NOT local.has_current_session >
      <cfset local.redirect_params = redirect('/logins/login')>  
    <cfelseif NOT this.is_authorized()>
      <cfset local.redirect_params = redirect('/logins/unauthorized')>  
    </cfif>

    <cfreturn local.redirect_params>
  </cffunction>

</cfcomponent>
