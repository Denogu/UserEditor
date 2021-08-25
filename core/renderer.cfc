<cfcomponent name="renderer">

  <cffunction name="init" access="public" output="false">
    <cfargument name="controller_name" type="string" required="true">
    <cfargument name="action_name" type="string" required="true">
    <cfargument name="render_params" type="struct" default={}>

    <cfset this.controller_name = arguments.controller_name>
    <cfset this.action_name = arguments.action_name>
    <cfset this.render_params = build_params(arguments.render_params)>

    <cfreturn this>
  </cffunction>


  <cffunction name="render" access="public" returntype="void">
    <cfif ucase(this.render_params.format) EQ 'JSON'>
      <cfset render_json()>
    <cfelseif StructKeyExists(this.render_params, "is_redirect")>
      <cflocation url='#application.url_root#/main.cfm#this.render_params.path#' addtoken='false'>
    <cfelse>
      <cfset render_template()>
    </cfif>
  </cffunction>


  <cffunction name="render_json" access="public" returntype="void">
    <cfset WriteOutput(SerializeJSON(this.render_params.view_data))>
  </cffunction>


  <cffunction name='render_template' access="public" returntype="void">
    <cfset local.template_path = get_template_path()>    

    <cfsavecontent variable='local.content_to_render'>
      <cfset local.view_data = this.render_params.view_data>

      <cfif FileExists('#application.rootDirectory#views/helpers.cfm')>
        <cfinclude template="../views/helpers.cfm">
      </cfif>

      <cfinclude template="#local.template_path#">
    </cfsavecontent>

    <cfif StructKeyExists(this.render_params, 'partial')>
      <cfset WriteOutput(local.content_to_render)>
    <cfelse>
      <cfset render_content_in_layout(local.content_to_render)>
    </cfif>
  </cffunction>



  <cffunction name="render_content_in_layout" access="private" returntype="void">
    <cfargument name="content_to_render" required="true">

    <cfsavecontent variable='local.content_to_render_in_layout'>
      <cfset local.content_to_render = arguments.content_to_render>
      <cfset local.controller_name = this.controller_name>
      <cfset local.action_name = this.action_name>
      <cfinclude template="../views/#this.render_params.layout#">
    </cfsavecontent>
    <cfset WriteOutput(local.content_to_render_in_layout)>
  </cffunction>



  <cffunction name="default_template_path" access="private" output="false" returntype="string">
    <cfreturn "../views/#this.controller_name#/#this.action_name#.cfm">
  </cffunction>



  <cffunction name="get_template_path" access="private" output="false" returntype="string">
    <cfif StructKeyExists(this.render_params, 'template')>
      <cfreturn "../views/#this.render_params.template#">
    <cfelse>
      <cfreturn default_template_path()>
    </cfif>
  </cffunction>



  <cffunction name="build_params" access="private" output="false" returntype="Struct">
    <cfargument name="params" type="Struct" required="true">
    <cfset local.all_params = StructNew()>
    <cfset local.default_params = {
      format = 'html',
      layout = 'layout.cfm'
    }>
    <cfset StructAppend(local.all_params, local.default_params)>
    <cfset StructAppend(local.all_params, arguments.params)>
    <cfreturn local.all_params>
  </cffunction>


  <cffunction name="render_flash" output="true" access="public">
    <cfset var alert_type = "alert-info">
    
    <cfif StructKeyExists(session, "flash")>
      <cfif session.flash.type IS "success">
        <cfset alert_type = "alert-success">
      <cfelseif session.flash.type IS "warning">
        <cfset alert_type = "alert-warning">
      <cfelseif session.flash.type IS "error">
        <cfset alert_type = "alert-danger">
      </cfif>

      <div class="alert #alert_type#">
        <cfif IsArray(session.flash.message) AND ArrayLen(session.flash.message) GT 0>
          #session.flash.message[1]#
          <cfloop index="i" from="2" to="#ArrayLen(session.flash.message)#">
            <br /><br />
            #session.flash.message[i]#
          </cfloop>
        <cfelseif session.flash.message NEQ "">
          #session.flash.message#
        </cfif>
      </div>

      <cfset StructDelete(session, "flash")>
    </cfif>
  </cffunction>
  
</cfcomponent>