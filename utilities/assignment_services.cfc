<cfcomponent>
  
  <!--- nvd, leave?? ---><!---
  <cffunction name="all_runnin_assignments" access="public" returntype="query">
  	<cfargument name="site_number" type="string" required="false">
    <cfquery name="local.all_recs" datasource="#application.dsn#">
      SELECT     
        iwrs_assignments.id, 
        iwrs_assignments.site_number, 
        iwrs_assignments.subject_number, 
        UPPER(iwrs_assignments.alpha_code) AS alpha_code,
        iwrs_assignments.assignment_type_id, 
        iwrs_assignments.justification, 
        iwrs_assignments.user_name AS assigned_by, 
        FORMAT(DATEADD(n, (-1 * iwrs_assignments.utc_offset), iwrs_assignments.created_at), 'MMMM dd, yyyy hh:mm tt') AS created_at_formatted, 
        iwrs_assignments.utc_offset,
        iwrs_assignment_types.name AS assignment_type, 
      	iwrs_items.number AS bottle_number,
        iwrs_sites.name AS site_name,
        UPPER(iwrs_enrollment_forms.gender) AS gender
	  FROM         
      	iwrs_assignments INNER JOIN
        iwrs_assignment_types ON iwrs_assignments.assignment_type_id = iwrs_assignment_types.id INNER JOIN
        iwrs_items ON iwrs_assignments.id = iwrs_items.assignment_id INNER JOIN
        iwrs_sites ON iwrs_assignments.site_number = iwrs_sites.number INNER JOIN
        iwrs_enrollment_forms ON iwrs_assignments.subject_number = iwrs_enrollment_forms.subject_number AND 
          iwrs_assignments.alpha_code = iwrs_enrollment_forms.alpha_code 
      WHERE
    	  assignment_type_id = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
        <cfif structKeyExists(arguments, 'site_number')>
        	and iwrs_assignments.site_number = <cfqueryparam value="#arguments.site_number#" cfsqltype="cf_sql_varchar">
        </cfif>
      ORDER BY [id] DESC
    </cfquery>

    <cfreturn local.all_recs>
  </cffunction>
  --->
  
  <cffunction name="all_randomization_assignments" access="public" returntype="query">
  	<cfargument name="site_number" type="string" required="false">
    <cfquery name="local.all_recs" datasource="#application.dsn#">
      SELECT     
      	iwrs_assignments.id, 
        iwrs_assignments.site_number, 
        iwrs_assignments.subject_number, 
        UPPER(iwrs_participants.gender) AS gender,
        UPPER(iwrs_assignments.alpha_code) AS alpha_code,
        iwrs_assignments.utc_offset, 
        FORMAT(DATEADD(n, (-1 * iwrs_assignments.utc_offset), iwrs_assignments.created_at), 'MMMM dd, yyyy hh:mm tt') AS created_at_formatted, 
        iwrs_assignments.updated_at,
        iwrs_assignments.user_name AS assigned_by,  
        iwrs_assignment_types.name AS assignment_type, 
        iwrs_sites.name AS site_name
	   FROM
       	 iwrs_assignments 
         INNER JOIN
         iwrs_participants ON iwrs_assignments.subject_number = iwrs_participants.subject_number AND 
         iwrs_assignments.alpha_code = iwrs_participants.alpha_code 
         INNER JOIN
         iwrs_assignment_types ON iwrs_assignments.assignment_type_id = iwrs_assignment_types.id 
         INNER JOIN
         iwrs_sites ON iwrs_assignments.site_number = iwrs_sites.number
      WHERE
      	assignment_type_id = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
        <cfif structKeyExists(arguments, 'site_number')>
        	and iwrs_assignments.site_number = <cfqueryparam value="#arguments.site_number#" cfsqltype="cf_sql_varchar">
        </cfif>
      ORDER BY [site_number] ASC, [id] DESC
    </cfquery>

    <cfreturn local.all_recs>
  </cffunction>
</cfcomponent>