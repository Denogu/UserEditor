<cfcomponent extends="iwrs_controller">

  <cffunction name="is_authorized" access="Public">
    <cfreturn createObject('component', 'utilities.session_utilities').is_session_current()>
  </cffunction>


  <cffunction name="welcome" access="Public">
    <cfreturn render()>
  </cffunction>


  <cffunction name="keep_session_alive" access="Public">
    <cfreturn render_partial()>
  </cffunction>


  <cffunction name="logout" access="Public">
    
    <cftry>  
      <cfinvoke component="models.user" method="logout">
        <cfinvokeargument name="user_id" value="#session.user.id#">
        <cfinvokeargument name="session_scope" value="#session#">
        <cfinvokeargument name="application_scope" value="#application#">
      </cfinvoke>
      
      <cfcatch>
        <cfrethrow>
      </cfcatch>
    </cftry>

    <cfreturn redirect('/logins/logout')>
    
  </cffunction>

</cfcomponent>
