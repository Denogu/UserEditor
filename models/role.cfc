<cfcomponent output="false">
	
	<!--- Database Meta Data (DBMD) --->
	<cfset variables.table_name = 'iwrs_roles'>
	<cfset variables.field_names = ['id', 
                                  'name', 
								  'role_name',
								  'description',
                                  'created_at', 
                                  'updated_at',
                                  'user_name']>
	

	<!--- Finds the record in the database by the record's id.  Builds an object with member variables defined from the table's
	      field names and values. --->
	<cffunction name="init" output="false" access="Public">
		<cfargument name="id" required="true" type="string">
		
    	<cfset var rec = find_one_by_id(arguments.id)>
		<cfset this.id = arguments.id>
		<cfset build_orm_object(rec)>
		
		<cfreturn this>
	</cffunction>


<!--- Get all of the records from the 'readable' view. --->
  <cffunction name="all_readable" output="false" returntype="Query">
    <cfquery name="local.all_recs" datasource="#application.dsn#">
      SELECT *
      FROM [#variables.table_name#]
    </cfquery>

    <cfreturn local.all_recs>
  </cffunction>


	<!--- Look for a record with the specified id, throw an error if it is not found. --->
	<cffunction name="find_one_by_id" output="false" access="public" returntype="Query">
		<cfargument name="record_id" required="true" type="numeric">
		
		<cfquery name="record" datasource="#application.dsn#">
			SELECT TOP 1 * 
			FROM [#variables.table_name#]
			WHERE id = <cfqueryparam value="#arguments.record_id#">
		</cfquery>
		
		<cfif record.recordCount EQ 0>
			<cfthrow type="custom" message="No record found.">
		</cfif>
		
		<cfreturn record>
	</cffunction>


	<cffunction name="is_study_team" access="public">
		<cfreturn this.role_name IS 'study'>
	</cffunction>
    
    <cffunction name="is_site_team" access="public">
		<cfreturn this.role_name IS 'site'>
	</cffunction>


<!--- Private Methods --->

	<!--- Get the record, define member variables from record field names and values.--->
	<cffunction name="build_orm_object" output="false" access="private" returntype="void">
		<cfargument name="rec" required="true" type="Query">
		
		<cfloop array=#variables.field_names# index="field_name">
			<cfset this[#field_name#]= rec[#field_name#]>
		</cfloop>
	</cffunction>
	
  	
</cfcomponent>