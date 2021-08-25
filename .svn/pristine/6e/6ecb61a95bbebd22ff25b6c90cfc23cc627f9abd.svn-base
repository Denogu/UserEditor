<cfcomponent>
  <cfset this.name = "2002_mxunit">
  <cfset this.SessionManagement = true>
  <cfset this.mappings[ "/mxunit" ] = "E:\inetpub\wwwroot\csp\ctsc\2002\tests\mxunit">
  <cfset this.mappings[ "/core" ] = "E:\inetpub\wwwroot\csp\ctsc\2002\core">
  <cfset this.mappings[ "/models" ] = "E:\inetpub\wwwroot\csp\ctsc\2002\models">
  <cfset this.mappings['/controllers'] = "E:\inetpub\wwwroot\csp\ctsc\2002\controllers">
  <cfset this.mappings['/utilities'] = "E:\inetpub\wwwroot\csp\ctsc\2002\utilities">


  <cffunction name="OnApplicationStart" access="public" returntype="boolean">
    <cfset application.dsn="2002">
    <cfset application.root = "csp/ctsc/2002">
    <cfset application.url_root="http://vhaabqcspwebdev/#application.root#">

    <cfset application.notify = "zachary.taylor2@va.gov">
    <cfset application.study='2002'>
    <cfset application.single_unit_test_url_root='2002/tests'>
    
    <!--- Get settings configured in database table. --->
    <cfquery name = "local.records" datasource = "#application.dsn#" >
      SELECT name, value
      FROM iwrs_application_settings
    </cfquery>

    <cfloop query = "local.records">
      <cfset application[#local.records.name#] = #local.records.value#>
    </cfloop>

    
    <cfreturn true>
  </cffunction>


  <cffunction name="OnRequest" access="public" returntype="boolean" output="true">
    <cfargument name="TargetPage" type="string" required="true">
    
    <cfif structKeyExists( url, "reset" )>
      <cfset ApplicationStop() />
      <cfabort>
  	</cfif>

    <cfinclude template="#ARGUMENTS.TargetPage#">

    <cfreturn true>
  </cffunction>

</cfcomponent>
