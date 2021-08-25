<!--- If user logged in, set values here for JavaScript function in main.js to read. --->
<cfif  createObject('component', 'utilities.session_utilities').is_session_current()>
  <div id="timeout_value" style="display:none;"><cfoutput>#application.sessionTime#</cfoutput></div>
  <div id="logout_redirect_url_value" style="display:none;"><cfoutput>#application.url_root#/main.cfm/logins/session_expired</cfoutput></div>
  <div id="logout_url_value" style="display:none;"><cfoutput>#application.url_root#/main.cfm/users/logout</cfoutput></div>
  <div id="keep_alive_url_value" style="display:none;"><cfoutput>#application.url_root#/main.cfm/users/keep_session_alive</cfoutput></div>
  
  <div id="timeout_div"></div>
</cfif>  
