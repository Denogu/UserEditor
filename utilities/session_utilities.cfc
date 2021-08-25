<cfcomponent>

  <!--- Match session with key we stored in the database. --->
  <cffunction name="is_session_current" access="public" returntype="boolean" output="false">
    <cfif StructKeyExists(session, 'user')>
      <cfif isdefined("session.user.id") and isdefined("session.user.key")>
        <cfquery name="local.checksession" datasource="#application.dsn#" maxrows="1">
          SELECT TOP 1 current_session_id 
          FROM iwrs_users
          WHERE id = <cfqueryparam value="#session.user.id#">
        </cfquery>

        <cfreturn local.checksession.current_session_id EQ session.user.key 
          AND local.checksession.current_session_id NEQ ''>
      </cfif>
    </cfif>
    <cfreturn false>
  </cffunction>  

</cfcomponent>
