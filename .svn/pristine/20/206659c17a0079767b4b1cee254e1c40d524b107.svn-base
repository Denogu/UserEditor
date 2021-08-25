<cfcomponent>


  <cffunction name="item_id_to_return">
  	<cfreturn 5678>	
  </cffunction>
  
  
  <cffunction name="get_next_available" output="No" access="public" returnType="query">
    <cfargument name="package_definition_id" required="true" type="Numeric">
    <cfargument name="days_prior_to_expiration" required="true" type="string">
    <cfargument name="site_number" required="true" type="string">
    <cfargument name="drug_quantity" required="true" type="numeric">

  	<cfset local.table = queryNew("id", "integer")>
  	<cfset local.newRow = QueryAddRow(local.table, 1)>
  	<cfset querySetCell(local.table, "id", item_id_to_return())>
  	
  	<cfreturn local.table>
  </cffunction>

  
</cfcomponent>