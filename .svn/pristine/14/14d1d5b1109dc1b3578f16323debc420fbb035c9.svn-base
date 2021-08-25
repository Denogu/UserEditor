<!--- Methods that can be used with injectMethod to ensure specific behavior. --->



<cffunction name="zero_records" access="private">
  <cfquery name="local.no_recs" datasource="#application.dsn#">
    SELECT *
    FROM access_log
    WHERE 1 = 0
  </cfquery>

  <cfreturn local.no_recs>
</cffunction>



<cffunction name="multiple_records" access="private">
  <cfquery name="local.multiple_recs" datasource="#application.dsn#">
    SELECT 'Rec 1'
    UNION ALL
    SELECT 'Rec 2' 
  </cfquery>

  <cfreturn local.multiple_recs>
</cffunction>



<cffunction name="empty_array" access="private">
  <cfreturn ArrayNew(1)>
</cffunction>



<cffunction name="new" access="private">
  <cfreturn 'NEW'>
</cffunction>



<cffunction name="cancelled" access="private">
  <cfreturn 'CANCELLED'>
</cffunction>



<cffunction name="generated" access="private">
  <cfreturn 'GENERATED'>
</cffunction>



<cffunction name="on_hold" access="private">
  <cfreturn 'ON HOLD'>
</cffunction>



<cffunction name="needs_review" access="private">
  <cfreturn 'NEEDS REVIEW'>
</cffunction>



<cffunction name="returns_false" access="private">
  <cfreturn false>
</cffunction>



<cffunction name="returns_true" access="private">
  <cfreturn true>
</cffunction>



<cffunction name="throws_error" access="private">
  <cfthrow message="Error">
</cffunction>


