<cfoutput>
<cfif session.user.is_crpcc>
  <cffunction name="get_reports" returntype="array">
    <cfargument name="dir_path" type="string" required="true">
    <cfargument name="report_filter" type="string" required="true">
    
    <cfset report_links = ArrayNew(1) />
    <cfset dir_listings = 
      DirectoryList('#arguments.dir_path#', false, 'name', '#arguments.report_filter#', 'asc') >
    
    <cfloop array="#dir_listings#" index="rec">
      <cfset link = StructNew() />      
      <cfset rec = REReplaceNoCase(rec, '.cfm$', '') /> <!--- remove .cfm extension --->
      <cfset link['file_name'] = rec />
      <cfset rec = REReplace(rec, '_', ' ', 'ALL') /> <!--- replace underscores with space--->
      <cfset link['report_name'] = REReplace(rec, "\b(\S)(\S*)\b", "\u\1\L\2", "all") /> <!--- Title case --->
      <cfset ArrayAppend(report_links, link) />
    </cfloop>
    <cfreturn report_links />
  </cffunction>


  <cffunction name="get_dropdown_for_reports" returntype="string">
    <cfargument name="reports_dir" type="string" required="true" />
    <cfset controller = arguments.reports_dir />
    <cfset action = 'reports' >
    <cfset reports = get_reports( report_filter='*_report.cfm',
      dir_path='#application.rootDirectory#/views/#arguments.reports_dir#') />    
    <cfset dropdown = ''>
    <cfloop array="#reports#" index="rec">
      <cfset href = "#application.url_root#/main.cfm/#controller#/#action#?name=#rec.file_name#" />
      <cfset dropdown &= '<li><a href="#href#">#rec.report_name#</a></li>'/>
    </cfloop>
    <cfreturn dropdown />

  </cffunction>




  <cfset links_enabled = []>
  <cfset role_obj = createObject("component", "models.role").init(session.user.role_id) />

  <cfset ArrayAppend(links_enabled,'<a href="#application.url_root#/main.cfm/items/fit_results">FIT Results</a>')>
  <cfset ArrayAppend(links_enabled,'<a href="#application.url_root#/main.cfm/user_managers/records">Manage Users</a>')>
   
  <ul class="nav navbar-nav">
    <cfloop index="i" from="1" to="#arrayLen(links_enabled)#">
      <li>
          #links_enabled[i]#
      </li>
    </cfloop>
  </ul>

  <a class="btn btn-info navbar-btn navbar-right" href="../users/logout">
    <span class="glyphicon glyphicon-log-out"></span> Sign out
  </a>

</cfif>
</cfoutput>
