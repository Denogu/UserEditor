<cfcomponent extends="iwrs_controller">

  <cffunction name="is_authorized" access="Public">
    <cfreturn session.user.can_manage_users>
  </cffunction>



  <cffunction name="records" access="Public">
    <cfset local.view_data.users = createObject("component","models.user").all_readable() />
    <cfreturn render(view_data=local.view_data)>
  </cffunction>



  <cffunction name="edit" access="Public">
  <cfset local.view_data.sites = createObject("component", "models.site").all() />
	  <cfset local.view_data.user = createObject("component", "models.user").init(this.params.id) />
    <cfset local.view_data.user_site_access = createObject("component", "models.user_site_access").sites_for_user(local.view_data.user.id) />
    <cfset local.view_data.roles = createObject("component", "models.role").all_readable()>
    <cfreturn render_partial(view_data=local.view_data) />
  </cffunction>


  <cffunction name="update" access="Public">
    <cfset local.user = createObject("component", "models.user").init_from_user_name(this.params['user_name']) />
    <cfset local.user_site_access = createObject("component", "models.user_site_access").sites_for_user(local.user.id)/>
    <cfset local.result = {is_success= true, message=""} />
    <cfset local.user_form = StructNew() />
    <cfset local.user_form['is_authorized'] = 0 />   
    <!--- This will be undefined if the user unchecks the is_authorized checkbox. --->
    

    <!--- Section for updating user_site_access      --->
    <cfset current_sites = valueArray(local.user_site_access, "site_id")>
    <cfset new_sites = listToArray(this.params.SITE_ACCESS)>
    <cfset delete_sites = []>
    <cfset add_sites = []>

    <cfif arrayToList(current_sites) IS arrayToList(new_sites)>
    
    <cfelse>
      <cfoutput>
        <cfloop array="#new_sites#" item="id" index="idx">
<!--- Some script to compare the two arrays and return what needs to be deleted and what needs to be added.            --->
          <cfscript>
            if (arrayFind(current_sites, #id#) == 0)
            {
              arrayAppend(add_sites, #id#);
            }
          </cfscript>
        </cfloop>

        <cfloop array="#current_sites#" item="id" index="idx">
          <cfscript>
            if (arrayFind(new_sites, #id#) == 0)
            {
              arrayAppend(delete_sites, #id#);
            }
          </cfscript>
        </cfloop>
      </cfoutput>
    

      <cfif arrayIsEmpty(add_sites)>

      <cfelse>
        <cftry>
          <cfset local.user_sites_to_edit = createObject("component", "models.user_site_access")>
          <cfloop array="#add_sites#" item="item" index="index">
            <cfset local.add_site_result = local.user_sites_to_edit.add_user_site(add_sites[index], local.user.id)>
          </cfloop>
          <cfcatch>
            <cfoutput>
              #cfcatch.detail#
            </cfoutput>
          </cfcatch>
        </cftry>
      </cfif>

      <cfif arrayIsEmpty(delete_sites)>

      <cfelse>
        <cftry>
          <cfset local.user_sites_to_edit = createObject("component", "models.user_site_access")>
          <cfloop array="#delete_sites#" item="item" index="index">
            <cfset local.delete_site_result = local.user_sites_to_edit.delete_user_site(delete_sites[index], local.user.id)>
          </cfloop>
          <cfcatch>
            <cfoutput>
              #cfcatch.detail#
            </cfoutput>
          </cfcatch>
        </cftry>
      </cfif>
    
      <cfset local.update_user_sites = createObject("component", "models.user_site_access")>
      <cfset session.user.user_site_access = local.update_user_sites.sites_for_user(session.user.id)>

    </cfif>

    <cftry>
      <cfset local.update_user_sites = createObject("component", "models.user_site_access")>
      <cfset local.add_record_result = local.update_user_sites.add_change_record(this.params['justification'], local.user.id, arrayToList(add_sites), arrayToList(delete_sites))>

    <cfcatch>
      <cfoutput>
        #cfcatch.message#
      </cfoutput>
    </cfcatch>
    </cftry>

    <cfloop collection="#this.params#" item="key">
      <cfif ArrayContains(['first_name', 'last_name', 'email', 'role_id', 'site_number', 'is_authorized'], lcase(key))>
        <cfset local.user_form[lcase(key)] = this.params[key] />
      </cfif> 
    </cfloop>

    <cftry>
      <cfset local.result = local.user.update_user_details(local.user_form) />
    <cfcatch type="custom">
      <cfset local.result.message = cfcatch.Message />
      <cfset local.result.is_success = false />
    </cfcatch>
    </cftry>    
    <cfreturn render_json(local.result) />
     
  </cffunction>
<!------>

</cfcomponent>
