<!--- table name --->
<cfset sTableName = "FIT_results" />
 
<!--- list of database columns which should be read and sent back to DataTables --->
<cfset listColumns = "subject_number, first_name, last_name, ssn, is_positive, collected_on, tested_on, in_cprs, id" />
 
<!--- Indexed column --->
<cfset sIndexColumn = "local_assigned_at" />
  
<!--- ColdFusion Datasource for the MySQL connection --->
<cfset coldfusionDatasource = "#application.dsn#"/>
 

<!--- Pagination parameters.--->
<!---TODO: Each page change re queries entire dataset and then renders appropriate page.  Should just get records associated with page. --->
<cfparam name="url.start" default="0" type="integer" />
<cfparam name="url.length" default="10" type="integer" />

<!--- Search parameters is treated like a whitespace delimited list. ---> 
<cfparam name="url['search[value]']" default="" type="string" />
<cfset search_parameters = url['search[value]']>

<!--- Ordering parameters --->
<cfparam name="url['order[0][column]']" default="0" type="integer" />
<cfparam name="url['order[0][dir]']" default="" type="string" />
<cfset order_column_position = url['order[0][column]']>
<cfset order_direction = url['order[0][dir]']>

<!--- To make Fortify happy and thwart sql injection attacks. --->
<!--- <cfswitch expression = "#url['order[0][column]']#">
  <cfcase value="1">
    <cfset order_column_position = "1">
  </cfcase>
  <cfcase value="2">
    <cfset order_column_position = "2">
  </cfcase>
  <cfcase value="3">
    <cfset order_column_position = "3">
  </cfcase>
  <cfcase value="4">
    <cfset order_column_position = "4">
  </cfcase>
  <cfcase value="5">
    <cfset order_column_position = "5">
  </cfcase>
  <cfdefaultcase>
    <cfset order_column_position = "0">
  </cfdefaultcase>
</cfswitch>

<!--- To make Fortify happy and thwart sql injection attacks. --->
<cfswitch expression = "#UCASE(url['order[0][dir]'])#">
  <cfcase value="ASC">
    <cfset order_direction = "asc">
  </cfcase>
  <cfcase value="DESC">
    <cfset order_direction = "desc">
  </cfcase>
  <cfdefaultcase>
    <cfset order_direction = "">
  </cfdefaultcase>
</cfswitch> --->
 
<!---
    SQL queries
    Get data to display
 --->
 
<!--- Data set after filtering --->
<cfquery datasource="#coldfusionDatasource#" name="qFiltered">
  ; WITH MySelectedRows AS (
    SELECT ROW_NUMBER() OVER (
      <cfif order_column_position gte 0 and (order_direction EQ 'asc' or order_direction EQ 'desc')>
        ORDER BY #ListGetAt(listColumns, order_column_position + 1)# #order_direction#
      <cfelse>
        ORDER BY local_assigned_at DESC 
      </cfif>
    ) as RowNumber, #listColumns#
    FROM #sTableName#
    WHERE
    site_number = <cfqueryparam value="#session.user.site_number#" cfsqltype="CF_SQL_VARCHAR">
    <cfif len(trim(search_parameters))>
    AND
    
    <cfloop list="#search_parameters#" delimiters=" " index="search_parameter">
      <cfif search_parameter neq listFirst(search_parameters, " ")> 
        and 
      </cfif>
      (
      <cfloop list="#listColumns#" index="thisColumn">
        <cfif thisColumn neq listFirst(listColumns)> 
          OR 
        </cfif>
          #thisColumn# LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(search_parameter)#%" />
      </cfloop>
      )
    </cfloop>
    
    </cfif>
  )  
  SELECT #listColumns# FROM MySelectedRows 
  WHERE RowNumber BETWEEN <cfqueryparam value="#url.start + 1#" cfsqltype="CF_SQL_INTEGER"> AND <cfqueryparam value="#(url.start + url.length + 1)#" cfsqltype="CF_SQL_INTEGER">;
</cfquery>
 
<!--- Total data set length --->
<cfquery datasource="#coldfusionDatasource#" name="qCount">
  SELECT COUNT(#sIndexColumn#) as total
  FROM   #sTableName#
</cfquery>

<cfset filtered_count = qCount.total>
<cfif len(trim(search_parameters))>
  <cfquery datasource="#coldfusionDatasource#" name="qFilteredCount">
    SELECT COUNT(#sIndexColumn#) as total
    FROM   #sTableName#
    WHERE 
    <cfloop list="#search_parameters#" delimiters=" " index="search_parameter">
      <cfif search_parameter neq listFirst(search_parameters, " ")> 
        and 
      </cfif>
      (
      <cfloop list="#listColumns#" index="thisColumn">
        <cfif thisColumn neq listFirst(listColumns)> 
          OR 
        </cfif>
          #thisColumn# LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(search_parameter)#%" />
      </cfloop>
      )
    </cfloop>
  </cfquery>
  <cfset filtered_count = qFilteredCount.total>
</cfif> 
<!---
    Output
 --->

<cfcontent reset="Yes" />
{
  "draw": <cfoutput>#val(url.draw)#</cfoutput>,
  "recordsTotal": <cfoutput>#qCount.total#</cfoutput>,
  "recordsFiltered": <cfoutput>#filtered_count#</cfoutput>,
  "data": [
    <cfoutput query="qFiltered">
      <cfif currentRow gt 1>,</cfif>
      {
        "DT_RowId": "Row_#jsStringFormat(qFiltered[sIndexColumn][qFiltered.currentRow])#",
        "DT_RowData": 
        {
          "pkey":  "#jsStringFormat(qFiltered[sIndexColumn][qFiltered.currentRow])#"
        }
        <cfloop list="#listColumns#" index="thisColumn">
          ,"#column_index#": "#jsStringFormat(qFiltered[thisColumn][qFiltered.currentRow])#"
          <cfset column_index += 1>
        </cfloop>

        <!--- "0": "<a href='./details.cfm?id=#sanitize(id)#' class='assignment_details_link'><img src='#application.url_root#/images/iconedit.gif'/></a>",
        "0": "#sanitize(subject_number)#",
        "1": "#sanitize(first_name)#",
        "2": "#sanitize(last_name)#",
        "3": "#sanitize(ssn)#",
        "4": "#sanitize(is_positive)#",
        "5": "#DateFormat(collected_on, 'mm/dd/yyyy')# #TimeFormat(collected_on, 'medium')#",
        "6": "#DateFormat(tested_on, 'mm/dd/yyyy')# #TimeFormat(tested_on, 'medium')#",
        "7": "#sanitize(in_cprs)#",
        "8": "#sanitize(id)#" --->
      }
    </cfoutput> 
  ] 
}
