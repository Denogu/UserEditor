<cftry>
  <cfif not isDefined('id')>
    <cfthrow message="You must specify a user.">
  </cfif>

  <cfif not session.user.can_manage_users>
    <cfthrow message = "You are not authorized to access this page.">
  </cfif>

  <cfset revoked_by = session.user.name>
  <cfset user = CreateObject("component", "models.user").init(id)>
  <cfset user.revoke_user_access(revoked_by)>


  <cflocation url="./manage.cfm">
<cfcatch>
  <cfoutput>
    <div class="error_message">#cfcatch.message#</div>
  </cfoutput>
</cfcatch>
</cftry>
