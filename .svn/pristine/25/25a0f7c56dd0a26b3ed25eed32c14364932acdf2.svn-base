<cfcomponent>
  
  <!--- Get next available item(s) at a particular site. --->
  <cffunction name="get_next_available" output="No" access="public" returnType="query">
    <cfargument name="package_definition_id" required="true" type="Numeric">
    <cfargument name="days_prior_to_expiration" required="true" type="string">
    <cfargument name="site_number" required="true" type="string">
    <cfargument name="drug_quantity" required="true" type="numeric">

    <cfquery name='local.items' datasource="#application.dsn#">
      SELECT TOP #arguments.drug_quantity# *
      FROM iwrs_items_available_for_dispensing
      WHERE site_number = <cfqueryparam value='#arguments.site_number#'>
        AND package_definition_id = <cfqueryparam value='#arguments.package_definition_id#'>
        AND expires_on > DateAdd("d", #arguments.days_prior_to_expiration#, GetDate())
      ORDER BY Convert(numeric, [number])
    </cfquery>

    <cfreturn local.items>
  </cffunction>
  
</cfcomponent>