<cfcomponent>

  <cffunction name="init" access="Public">
    <cfargument name="params" type="Struct" default={}>
    <cfset this.params = build_params(arguments.params)>
    <cfreturn this>
  </cffunction>


  <!--- To be called before each method invocation. Can override in subclass. --->
  <cffunction name="is_authorized" access="Public">
    <cfreturn true>
  </cffunction>


  <!--- Indicates user variable should be in session for controller access. --->
  <cffunction name="requires_current_session" access="Public">
    <cfreturn true>
  </cffunction>


  <!--- Indicates if request is of type POST. --->
  <cffunction name="is_post" access="public" returntype="boolean">
    <cfreturn CompareNoCase(cgi.request_method, "POST") IS 0>
  </cffunction>


  <cffunction name="model" access="private">
    <cfargument name="name" required="true">
    <cfreturn createObject("component", "models.#arguments.name#")>
  </cffunction>


  <cffunction name="execute_action" access="public" returntype="struct">
    <cfargument name="action" type="string" required="true">

    <!--- Check if action is permitted. Must be implemented by subclasses. --->
    <cfset local.render_params = enforce_access_restraints()>
    
    <cfif StructIsEmpty(local.render_params)>
      <cfinvoke component="#this#" method="#arguments.action#" returnvariable="local.render_params">
    </cfif>

    <cfreturn local.render_params>
  </cffunction>


  <cffunction name="render_json" access="private" returntype="struct">
    <cfargument name="view_data" required="false" type="struct" default="#StructNew()#">
    
    <cfset local.render_params.view_data = arguments.view_data>
    <cfset local.render_params.format = "json">
    <cfreturn local.render_params>
  </cffunction>


  <cffunction name="render_json_success" access="private">
    <cfargument name="message" required="true">
    
    <cfset local.view_data.message = arguments.message>
    <cfset local.view_data.is_success = true>

    <cfreturn render_json(local.view_data)>
  </cffunction>


  <cffunction name="render_json_error" access="private">
    <cfargument name="message" required="true">

    <cfset local.view_data.message = arguments.message>
    <cfset local.view_data.is_success = false>

    <cfreturn render_json(local.view_data)>
  </cffunction>


  <cffunction name="render_success" access="private">
    <cfargument name="message" required="true">
    <cfset view_data['message'] =arguments.message />
    <cfreturn render(view_data=view_data, view_path='success.cfm')>
  </cffunction>


  <cffunction name="render_error" access="private">
    <cfargument name="message" required="true">
    <cfset view_data['message'] =arguments.message />    
    <cfreturn render(view_data=view_data, view_path='error.cfm')>
  </cffunction>


  <cffunction name="render_partial" access="private">
    <cfargument name="view_data" required="false" default="#StructNew()#">
    <cfargument name="view_path" required="false" default=''>
    
    <cfreturn render(view_data=arguments.view_data, is_partial=true, view_path = arguments.view_path)>
  </cffunction>


  <cffunction name="render" access="private" returntype="struct">
    <cfargument name="view_data" required="false" default="#StructNew()#">
    <cfargument name="layout" required="false" default='#this.params.layout#'>
    <cfargument name="is_partial" required="false" default=false>
    <cfargument name="view_path" required="false" default=''>

    <cfset local.render_params = StructNew()>  
    <cfset local.render_params.view_data = arguments.view_data>
    <cfset local.render_params.layout = arguments.layout>
    <cfif arguments.is_partial>
      <cfset local.render_params.partial = true>
    </cfif>
    <cfif arguments.view_path NEQ ''>
      <cfset local.render_params.template = arguments.view_path>
    </cfif>

    <cfreturn local.render_params>
  </cffunction>
  

  <cffunction name="redirect" access="public" returntype="struct">
    <cfargument name="path" type="string" required="true">
    <cfreturn {is_redirect=true, path=arguments.path}>
  </cffunction>


  <cffunction name="build_params" access="private" output="false" returntype="Struct">
    <cfargument name="params" type="Struct" required="true">

    <cfset local.all_params = StructNew()>
    <cfset local.default_params = {
      layout = 'layout.cfm',
      format = 'html',
      is_partial = false,
      controller = 'controller'
    }>

    <cfset StructAppend(local.all_params, local.default_params)>
    <cfset StructAppend(local.all_params, arguments.params)>
    <cfreturn local.all_params>
  </cffunction>

  <!--- Subclasses can override with specific behavior. --->
  <cffunction name="enforce_access_restraints" access="private" returntype="struct">
    <cfreturn StructNew()>
  </cffunction>


  <cffunction name="flash_success" access="public">
    <cfargument name="message" type="any" required="true">
    <cfset session.flash.message = arguments.message>
    <cfset session.flash.type = "success">
  </cffunction>


  <cffunction name="flash_error" access="public">
    <cfargument name="message" type="any" required="true">
    <cfset session.flash.message = arguments.message>
    <cfset session.flash.type = "error">
  </cffunction>


  <cffunction name="flash_warning" access="public">
    <cfargument name="message" type="any" required="true">
    <cfset session.flash.message = arguments.message>
    <cfset session.flash.type = "warning">
  </cffunction>


  <cffunction name="flash_info" access="public">
    <cfargument name="message" type="any" required="true">
    <cfset session.flash.message = arguments.message>
    <cfset session.flash.type = "info">
  </cffunction>

</cfcomponent>