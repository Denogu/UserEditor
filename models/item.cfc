<cfcomponent output="false" extends="core.model">
	<cffunction name="table_name" returntype="string">
    <cfreturn 'items'>
  </cffunction>

  <cffunction name="all" access="public" returntype="Query">
    
    <cfquery name="local.all_recs" datasource="#application.dsn#">
      select a.subject_number, p.PartFName as first_name, p.PartLName as last_name, p.ssn, collected_on=CONVERT(char,i.collected_on,101), 
      tested_on=CONVERT(char,r.tested_on,101), i.notified_of_cprs_entry_at,
      i.id as actions, in_cprs = CASE WHEN i.notified_of_cprs_entry_at IS NULL then 'No' else 'Yes' END,
      is_positive = CASE WHEN r.is_positive = 0 then 'Negative' WHEN r.is_positive = 1 then 'Positive' else 'Unknown' END
      from items i 
      inner join 
      assignments a on i.id = a.item_id
      inner join 
      patientNameAddressStatus p on p.subjectNo = a.subject_number
      inner join 
      fit_results r on i.released_result_id = r.id
      inner join
      items_current_status ics on i.id = ics.item_id
      where a.site_number = <cfqueryparam value="#session.user.site_number#" cfsqltype="CF_SQL_VARCHAR" maxlength="5" null="no"> 
      and i.released_at is not null
      and ics.name != 'RESULT-RELEASEDNEGATIVEOUTOFWINDOW'
      ORDER BY notified_of_cprs_entry_at, subject_number
    </cfquery>

    <cfreturn local.all_recs>
  </cffunction>


  <cffunction name="details" access="public" returntype="Query">
    <cfargument name="id" required="true" type="Numeric">

    <cfquery name="local.rec" datasource="#application.dsn#" maxrows="1">
      select top 1 i.kit_number, a.subject_number, p.PartFName as first_name, p.PartLName as last_name, p.ssn, collected_on=CONVERT(char,i.collected_on,101), 
      tested_on=CONVERT(char,r.tested_on,101), i.notified_of_cprs_entry_at,
      i.id as actions, in_cprs = CASE WHEN i.notified_of_cprs_entry_at IS NULL then 'No' else 'Yes' END,
      is_positive = CASE WHEN r.is_positive = 0 then 'Negative' WHEN r.is_positive = 1 then 'Positive' else 'Unknown' END
      from items i 
      inner join 
      assignments a on i.id = a.item_id
      inner join 
      patientNameAddressStatus p on p.subjectNo = a.subject_number
      inner join 
      fit_results r on i.released_result_id = r.id
      inner join
      items_current_status ics on i.id = ics.item_id
      where  i.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER" null="no">
      and i.released_at is not null
      and ics.name != 'RESULT-RELEASEDNEGATIVEOUTOFWINDOW'
      ORDER BY notified_of_cprs_entry_at, subject_number
    </cfquery>

    <cfreturn local.rec>
  </cffunction>


  <cffunction name="update_cprs_notification_field" access="public" returntype="Void">
    <cfargument name="id" required="true" type="Numeric">
    <cfargument name="in_cprs" required="true" type="Numeric">

    <cfquery name="local.update_rec" datasource="#application.dsn#">
      UPDATE items
      SET
      <cfif arguments.in_cprs EQ 1>
        notified_of_cprs_entry_at = GETDATE()
      <cfelse>
        notified_of_cprs_entry_at = null
      </cfif>
      , updated_at = GETDATE()
      , [user_name] = <cfqueryparam value="#session.user.name#" cfsqltype="CF_SQL_VARCHAR" maxlength=50>
      WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
  </cffunction>
</cfcomponent>
