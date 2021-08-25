<!---TODO Make sure to create iwrs_application_settings and iwrs_access_log tables in Production prior to deployment. --->

<cfcomponent>
  <cfset this.Name = "577FITResultIWRS">

  <!--- Session and Application timeout after 30 minutes --->
  <cfset THIS.ApplicationTimeout = createTimeSpan(0,0,30,0)>
  <cfset THIS.sessionTimeout = createTimeSpan(0,0,30,00)>

  <cfset THIS.clientManagement = false>
  <cfset THIS.SetClientCookies = false>
  <cfset THIS.SetDomainCookies = false>
  <cfset THIS.SessionManagement = true>
  <cfset THIS.ScriptProtect = "All">
  <cfset THIS.sessioncookie.httponly = true>

<!--- Application Specific mappings --->
  <cfset this.rootDirectory= getDirectoryFromPath(getCurrentTemplatePath())>
  <cfset this.mappings['/application_root'] = "#this.rootDirectory#">
  <cfset this.mappings['/core'] = "#this.rootDirectory#core/">
  <cfset this.mappings['/models'] = "#this.rootDirectory#models/">
  <cfset this.mappings['/utilities'] = "#this.rootDirectory#utilities/">
  <cfset this.mappings['/views'] = "#this.rootDirectory#views/">
  <cfset this.mappings['/controllers'] = "#this.rootDirectory#controllers/">
  <cfset this.mappings['/templates'] = "#this.rootDirectory#templates/">

  <!--- Set debug to false when going to production and global template timeout at 20 seconds. 
  <cfsetting requesttimeout="20" showdebugoutput="false" enablecfoutputonly="false">
  --->

  <cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false">
    <!--- Fields from database are enviroment, maintenance_message, maintenance_message_end,
          maintenance_message_start, password_expiration_days, password_history_enforced_count,
          password_reset_token_expiration_hours, error_message_reset_password, url.  
          Database should have notify value of "abqcspweb@va.gov".--->

    <cfset application.dsn="577">
    <cfset application.environment="DEVELOPMENT">
              
    <cfquery name = "local.records" datasource = "#application.dsn#" >
      SELECT name, value
      FROM iwrs_application_settings
    </cfquery>

    <cfloop query="local.records">
      <cfset application[#local.records.name#] = #local.records.value#>
    </cfloop>

  	<cfset application.sessionTime = THIS.sessionTimeout />
    <cfset application.rootDirectory = getDirectoryFromPath(getCurrentTemplatePath())>
    <cfset application.study_acronym = application.study>

    <cfreturn true>
  </cffunction>

  <!--- Processes all requests.  If the user is not authorized or logged in they are sent to the welcome page. --->
  <cffunction name="OnRequest" access="public" returntype="boolean" output="true">
    <cfargument name="TargetPage" type="string" required="true">


    <cfif ucase(application.environment) EQ 'PRODUCTION'>
    <!--- Force Secure connection for all requests --->
    <cfset oRequest = getPageContext().getRequest() />
    <cfif NOT oRequest.isSecure()>
      <cflocation url="https://#oRequest.getServerName()##oRequest.getRequestURI()#?#oRequest.getQueryString()#" addtoken="false" />
    </cfif>
    </cfif>

    <!--- Reset the application. --->
    <cfif structKeyExists( url, "reset" ) AND url.reset IS "abqcspcrpcc">
		  <cfset ApplicationStop() />
      <cfabort>
  	</cfif>

    <cfif structKeyExists(url, "internet") and url.internet IS "1">
      <cfset application.intranet_site = 0 />
    </cfif>

   <cfif GetFileFromPath(arguments.TargetPage) EQ 'main.cfm'>   	  
      <cfinclude template="main.cfm">
   </cfif>

    <cfreturn true>
  </cffunction>


  <cffunction name="onError" returnType="void" output="true">
    <cfargument name="exception" required="true">
    <cfargument name="eventname" type="string" required="true">
    
    <cfif is_production_env()>
      <cflog file="#application.study#" text="#arguments.exception.message#">

      <cfsavecontent variable="local.error_details">
        <cfoutput>
          An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />
          Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />
          <cfdump var="#arguments.exception#" label="Error">
          <cfdump var="#form#" label="Form">
          <cfdump var="#url#" label="URL">
        </cfoutput>
      </cfsavecontent>

      <cfmail to="#application.notify#" from="#application.notify#" 
        subject="Error:#application.study# - #arguments.exception.message#" type="html">
        #local.error_details#
      </cfmail>

      <cflocation url="../logins/error" addtoken="false">
    <cfelse>
      <cfdump var="#arguments.exception#" label="Error">
    </cfif>
  </cffunction>


  <!--- Log CGI to table. --->
  <cffunction name="onRequestEnd" returnType="void" output="false">
    
      <cfset local.user_name = 'not signed in'>

      <cfif isdefined('session.user')>
        <cfset local.user_name = session.user.name>
      </cfif>

      <cfquery name="local.qryInsertStats" datasource="#application.dsn#">
        INSERT INTO iwrs_access_log (user_name,template,query_string,referer,user_agent,remote_address)
        VALUES(        
          <cfqueryparam value="#local.user_name#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#CGI.PATH_INFO#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#CGI.QUERY_STRING#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#CGI.HTTP_REFERER#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#CGI.HTTP_USER_AGENT#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">
        )
      </cfquery>
    
  </cffunction>


  <!--- We are using the cfid and cftoken as the basis for our security so we want to force session
  only cookies for cfid and cftoken. So when browser closes user is logged out.--->
  <cffunction name="OnSessionStart" access="public" returntype="void" output="false" >
    <cfif is_development_env()>
      <cfcookie name="CFID" value="#SESSION.CFID#" httponly="true">
      <cfcookie name="CFTOKEN" value="#SESSION.CFTOKEN#" httponly="true">
      <cfcookie name="CFSESSIONID" value="#SESSION.SESSIONID#" httponly="true">
    <cfelse>
      <cfcookie name="CFID" value="#SESSION.CFID#" httponly="true" secure="yes">
      <cfcookie name="CFTOKEN" value="#SESSION.CFTOKEN#" httponly="true" secure="yes">
      <cfcookie name="CFSESSIONID" value="#SESSION.SESSIONID#" httponly="true" secure="yes">
    </cfif>
  </cffunction>


  <!--- Fires when the session is terminated.--->
  <cffunction name="OnSessionEnd" access="public" returntype="void" output="false" >
    <cfargument name="SessionScope" type="struct" required="true"/>
    <cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#"/>
    
    <!--- We need to force a logout if session ends abnormally. --->
    <cfif isdefined("arguments.SessionScope.user") and isStruct(arguments.SessionScope.user)>
      <cfinvoke component="models.user" method="logout">
        <cfinvokeargument name="user_id" value="#arguments.SessionScope.user.id#">
        <cfinvokeargument name="session_scope" value="#arguments.SessionScope#">
        <cfinvokeargument name="application_scope" value="#arguments.ApplicationScope#">
      </cfinvoke>
    </cfif>
  </cffunction>


  <cffunction name="is_development_env" access="private">
    <cfreturn ucase(application.environment) EQ 'DEVELOPMENT'>
  </cffunction>


  <cffunction name="is_production_env" access="private">
    <cfreturn ucase(application.environment) EQ 'PRODUCTION'>
  </cffunction>

</cfcomponent>
