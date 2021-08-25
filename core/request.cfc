<cfcomponent name="request">
  
  <cffunction name="init" access="public" output="false">
    <cfargument name="request_headers" required="true">
    <cfargument name="url_parameters" required="true">
    <cfargument name="form_parameters" required="true">
    <cfset this.path = arguments.request_headers.path_info>
    <cfset this.url_params = arguments.url_parameters>
    <cfset this.form_params = arguments.form_parameters>
    <cfset this.request_params = all_request_params()>
    <cfreturn this>
  </cffunction>

  

  <cffunction name="dispatch" access="public">
    <cfset local.dispatcher = createObject("core.dispatcher").init(this).dispatch()>
  </cffunction>



  <cffunction name="all_request_params" access="private" returntype="Struct">
    <cfset local.request_params = StructNew()>
    <cfset StructAppend(local.request_params, this.url_params)>
    <cfset StructAppend(local.request_params, this.form_params)>
    <cfreturn local.request_params>
  </cffunction>
</cfcomponent>
