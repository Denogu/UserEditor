<h3>Edit Accessible Sites</h3>

<ul class="list-group" id="access_sites">
    <cfoutput>
    <cfset sites = arrayNew(1)/>
        <div>
<!---             Current site access: --->
            <cfloop query="local.view_data.user_site_access">
<!---                 <li class="list-group-item">SITE ID: #site_id#</li> --->
                <cfset arrayAppend(sites, site_id)/>
            </cfloop>
        </div>
        <div class='form-group'>
        <cfloop query="local.view_data.sites">
        <div id="site_list" class="checkbox list-group-item">
            <label>
                <li><input type="checkbox" class="site_box" id="site_access" name="site_access" value="#id#" <cfif arrayContains(sites, id)>checked="checked"</cfif>> #HTMLEditFormat(site_name)#</li>
            </label>
        </div>
        </cfloop>
        </div>
    </cfoutput>
</ul>
