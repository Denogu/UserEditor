<cfcomponent name="dispatcher">
  
  <cffunction name="init" access="public" output="false">
    <cfargument name="req" required="true">
    <cfset variables.req = arguments.req>
    <cfset variables.path_patterns = default_path_patterns()>
    <cfset this.parsed_path = parse_path()>
    <cfreturn this>
  </cffunction>



  <cffunction name="dispatch" access="public">
    <cfset local.render_params = StructNew()>
    <cfset local.controller_params = StructNew()>

    <cfset StructAppend(local.controller_params,variables.req.request_params)>
    <cfset StructAppend(local.controller_params, this.parsed_path)>
    
    <cfset local.controller = CreateObject('component', 'controllers.' & this.parsed_path.controller)
      .init(local.controller_params)>

    <cfset local.render_params = local.controller.execute_action(this.parsed_path.action)>

    <cfset local.renderer = createObject("core.renderer").init(
      controller_name=this.parsed_path.controller, 
      action_name=this.parsed_path.action, 
      render_params=local.render_params)>

    <cfset local.renderer.render()>
  </cffunction>



  <cffunction name="parse_path" access="private" output="false" returntype="Struct">
    <cfset local.parsed_path = StructNew()>
    <cfset local.path_pattern = match_path_pattern()>
    <cfset local.pattern_map = local.path_pattern[2]>
    <cfset local.req_path_parts = get_path_parts(variables.req.path)>
    <cfloop collection="#local.pattern_map#" item="key">
      <cfset local.map_value = local.pattern_map[key]>
      <cfif isNumeric(local.map_value)>
        <cfset StructAppend(local.parsed_path, { #key# = local.req_path_parts[local.map_value] })>
      <cfelse>
        <cfset StructAppend(local.parsed_path, { #key# = local.map_value })>
      </cfif>
    </cfloop>
    <cfreturn local.parsed_path>
  </cffunction>



  <cffunction name='match_path_pattern' access="private" output="false" returntype="Array">
    <cftry>
    <cfloop array="#variables.path_patterns#" index="path_pattern">
      <cfif REFIND(path_pattern[1],variables.req.path) NEQ 0 >
        <cfreturn path_pattern>
      <cfelse>
        <cfreturn "https://vhaabqcspwebdev.v18.med.va.gov/csp/ctsc/577/main.cfm/logins/welcome">
      </cfif>
    </cfloop>
    <cfcatch type="exception">
      <cfthrow type="Dispatcher.InvalidPath" message="The request path does not match any predefined pattern.">
    </cfcatch>
    </cftry>
  </cffunction>



  <cffunction name="get_path_parts" access="private" output="false" returntype="Array">
    <cfargument name="path" type="string" required="true">
    <cfset local.path_parts = ArrayNew(1)>
    <cfset local.prepped_path = REReplace(arguments.path, "\.[a-zA-Z]+/?$","")><!--- Strip the format identifier off of the path if it exists. --->
    <cfset local.prepped_path = REReplace(local.prepped_path, "/_","/")><!--- Strip partial identifier off since the partial key is already set to either true or false. --->
    <cfset local.path_parts = ListToArray(local.prepped_path, '/')>
    <cfreturn local.path_parts>
  </cffunction>




  <!--- /[controller]/[action]/ e.g. /assignments/index/ --->
  <cffunction name="default_path_patterns" access="private" output="false" returntype="Array">
    <cfset local.paths = ArrayNew(2)>
    <cfset local.paths = [
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+/?$", { controller = 1, action = 2, partial = false, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+\.html/?$", { controller = 1, action = 2, partial = false, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+\.json/?$", { controller = 1, action = 2, partial = false, format = 'json' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[a-zA-Z][a-zA-Z_]+/?$", { controller = 1, action = 2, partial = true, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[a-zA-Z][a-zA-Z_]+\.html/?$", { controller = 1, action = 2, partial = true, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}/?$", { controller = 1, action = 2, partial = false, id = 3, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}\.html/?$", { controller = 1, action = 2, partial = false, id = 3, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}\.json/?$", { controller = 1, action = 2, partial = false, id = 3, format = 'json' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}/?$", { controller = 1, action = 2, partial = true, id = 3, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}\.html/?$", { controller = 1, action = 2, partial = true, id = 3, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}/?$", { controller = 1, action = 'details', partial = false, id = 2, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}\.html/?$", { controller = 1, action = 'details', partial = false, id = 2, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/[0-9]{1,8}\.json/?$", { controller = 1, action = 'details', partial = false, id = 2, format = 'json' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[0-9]{1,8}/?$", { controller = 1, action = 'details', partial = true, id = 2, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/_[0-9]{1,8}\.html/?$", { controller = 1, action = 'details', partial = true, id = 2, format = 'html' }],
      ["^/[a-zA-Z][a-zA-Z_]+/?$", { controller = 1, action = 'index', partial = false, format = 'html' }]
    ]>
    <cfreturn local.paths>
  </cffunction>

</cfcomponent>
