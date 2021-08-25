<cfcomponent>
  <cfset variables.validation_errors = ArrayNew(1)>
  <cfset variables.unique_keys = ArrayNew(1)>
  <cfset variables.foreign_keys = ArrayNew(1)>
  <cfset variables.custom_validation_functions = ArrayNew(1)>
	<cfset variables.has_many_models = ''>
	<cfset variables.has_one_models = ''>
  <cfset variables.belongs_to_models = ''>
  <cfset variables.non_blank_columns = ''>
  
  <cfset this.ERROR_MESSAGE_NO_RECORD_FOUND = "No record found.">

  <!--- ID initialized to default value. --->
  <cfset this.id = -1>  

	<cffunction name="init" access="public">
		<cfargument name="id" required="false" type="any" default="">
    <cfargument name="is_build_associations_as_arrays" required="false" type="boolean" default="true">

    <cfif arguments.id NEQ "">
      <cfset local.rec = find_by_id(arguments.id)>	
      <cfset load(local.rec)>
      <cfset build_associations(arguments.is_build_associations_as_arrays)>
    </cfif>

		<cfreturn this>
	</cffunction>


  <cffunction name="find_by_id" access="public" returntype="query">
		<cfargument name="id" required="true" type="any">
		
		<cfquery name="local.record" datasource="#application.dsn#">
			SELECT TOP 1 * 
      FROM #this.table_name()#
			WHERE id = <cfqueryparam value="#arguments.id#">
		</cfquery>
		
    <cfif local.record.RecordCount IS 0>
      <cfthrow type="custom" message="Record not found with ID of #arguments.id#">
    <cfelse>
      <cfreturn local.record>
    </cfif>
	</cffunction>


  <cffunction name="find_by" access="public" returntype="query">
    <cfargument name="attributes" type="struct" required="true">
    <cfargument name="is_throws_exception" type="boolean" required="false" default="true">

    <cfquery name="local.records" datasource="#application.dsn#">
			SELECT * 
      FROM #this.table_name()#
      WHERE 
        <cfloop collection="#arguments.attributes#" item="key">
          #key# = <cfqueryparam value='#arguments.attributes[key]#'>
          AND
        </cfloop>
        1 = 1
		</cfquery>

    <cfif (local.records.RecordCount IS 0) AND arguments.is_throws_exception>
      <cfthrow type="custom" message="#this.ERROR_MESSAGE_NO_RECORD_FOUND#">
    </cfif>

    <cfreturn local.records>
  </cffunction>


  <cffunction name="find_one_by" access="public">
    <cfargument name="field_name" type="string" required="true">
    <cfargument name="field_value" type="string" required="true">
    <cfargument name="is_throws_exception" type="boolean" required="false" default="true">

    <cfquery name="local.recs" datasource="#application.dsn#">
			SELECT TOP 1 id 
      FROM #this.table_name()#
      WHERE #arguments.field_name# = <cfqueryparam value="#arguments.field_value#"> 
		</cfquery>
    
    <cfif local.recs.RecordCount IS 0>
      <cfif arguments.is_throws_exception>
        <cfthrow type="custom" message="#this.ERROR_MESSAGE_NO_RECORD_FOUND#">
      <cfelse>
        <cfreturn "">
      </cfif>
    <cfelse>
      <cfreturn model(get_component_name()).init(local.recs.id)>
    </cfif>
  </cffunction>


  <cffunction name="find_all" access="public" returnType="query">
		<cfquery name="local.records" datasource="#application.dsn#">
			SELECT *
      FROM #this.table_name()#
		</cfquery>

    <cfreturn local.records>
  </cffunction>	  


	<cffunction name="count" access="public" returntype="numeric">
		<cfquery name="countRecs" datasource="#application.dsn#">
			SELECT COUNT(*) AS rec_count 
      FROM #this.table_name()# 
		</cfquery>
	
  	<cfreturn countRecs.rec_count>
	</cffunction>


  <!--- This is a class/static method. --->
  <cffunction name="create" access="public" returnType="model">
  	<cfargument name="attributes" required="true" type="struct">
    <cfargument name="is_do_not_validate" required="false" type="boolean" default='false'>
    <cfargument name="is_throws_validation_exception" required="false" type="boolean" default='true'>

    <cfset local.new_obj = model(get_component_name()).init()>

    <cfloop collection="#arguments.attributes#" item="key">
      <cfset local.new_obj[key]= arguments.attributes[key]>
    </cfloop>

    <cfset before_create(arguments.attributes)>

    <!--- Validate if desired. --->
    <cfif arguments.is_do_not_validate || local.new_obj.validates()>       
      <cfset local.attribute_list = ArrayToList(StructKeyArray(arguments.attributes))>
      <cfset local.attribute_list_length = ListLen(local.attribute_list)>
      <cfset local.attribute_count = 1>

      <cfquery result="local.new_record" datasource='#application.dsn#'>
        INSERT INTO #table_name()# (#local.attribute_list#)
        VALUES(
          <cfloop index = "key" list = "#local.attribute_list#">
            <!--- Check for numbers first becuase decimals can be interpreted as dates. --->
            <cfif IsNumeric(arguments.attributes[key])>
              <cfqueryparam value='#arguments.attributes[key]#'>
            <cfelseif IsDate(arguments.attributes[key])>
              <cfqueryparam value='#arguments.attributes[key]#' cfsqltype="cf_sql_date">
            <cfelse>
              <cfqueryparam value='#arguments.attributes[key]#'>
            </cfif>
            
            <cfif local.attribute_list_length GT local.attribute_count>
              ,
              <cfset local.attribute_count = local.attribute_count + 1>
            </cfif>
          </cfloop>
        )
      </cfquery>

      <cfif IsDefined('local.new_record.generatedKey')>
        <cfset local.record_id = local.new_record.generatedKey>
      <cfelse>
        <cfset local.record_id = attributes.id>
      </cfif> 

      <cfreturn init(local.record_id)>
    <cfelse>
      <cfif arguments.is_throws_validation_exception>
        <cfthrow type="custom" message="#SerializeJSON(local.new_obj.error_messages())#">
      <cfelse>
        <cfreturn local.new_obj>
      </cfif>
    </cfif>
	</cffunction>


  <!--- This is an instance method.  --->  	  
	<cffunction name="update" access="public" returnType="void">
    <cfargument name="attributes" required="true" type="struct">

    <cfset before_update(attributes)>
    <cfset local.is_valid = validates()>

    <cfif NOT local.is_valid> 
      <cfthrow type="custom" message="#SerializeJSON(this.error_messages())#">
    <cfelse>
      <cfquery result="local.result" datasource="#application.dsn#">
        UPDATE #table_name()#
        SET 
          <cfloop collection="#arguments.attributes#" item="key">
            <cfif IsNumeric(arguments.attributes[key])>
              #key# = <cfqueryparam value='#arguments.attributes[key]#'>,
            <cfelseif IsDate(arguments.attributes[key])>
              #key# = <cfqueryparam value='#arguments.attributes[key]#' cfsqltype="cf_sql_date">,
            <cfelseif ucase(arguments.attributes[key]) IS "NULL">
              #key# = NULL,
            <cfelse>
              #key# = <cfqueryparam value='#arguments.attributes[key]#'>,
            </cfif>
          </cfloop>
          updated_at = GETUTCDATE()
        WHERE id = <cfqueryparam value="#this.id#">
      </cfquery> 

      <!--- Set instance variables to argument values. --->
      <cfloop collection="#arguments.attributes#" item="key">
        <cfset this[key]= arguments.attributes[key]>
      </cfloop> 

      <!--- Set updated_at in this object, since SQL Server date function used. --->
      <cfset this["updated_at"] = model(get_component_name()).init(this.id).updated_at>
    </cfif>
  </cffunction>	


  <cffunction name="error_messages" returntype="array" access="public">
    <cfset local.error_items = this.errors()>
    <cfset local.error_messages = ArrayNew(1)>

    <cfloop index = "i" from = "1" to = "#ArrayLen(local.error_items)#">
      <cfset ArrayAppend(local.error_messages, local.error_items[i].message)>  
    </cfloop>

    <cfreturn local.error_messages>
  </cffunction>


  <cffunction name="validates" access="public" returntype="boolean">
    <cfset ArrayClear(variables.validation_errors)>

    <cfset validate_non_blank_fields()>
    <cfset validate_unique_keys()>
    <cfset validate_foreign_keys()>
    <cfset custom_validate()> 
                 
    <cfreturn is_valid()>
  </cffunction>  


  <cffunction name="validate_non_blank_fields" access="private" returntype="void">
    <cfset local.result = find_table_info()>
    
    <cfloop query='local.result'>
      <cfif ListContainsNoCase(variables.non_blank_columns, column_name) 
        AND (NOT StructKeyExists(this, column_name) OR get_this_value(column_name) IS "")>
        <cfset add_validation_error(field=column_name, error='blank', 
          message=format_readable_column_name(column_name) & ' is blank.')>  
      </cfif>
    </cfloop>
  </cffunction>

  <!--- For message format, uppercase column first letter and remove underscores. --->
  <cffunction name="format_readable_column_name" access="private" returntype="any">
    <cfargument name="column_name" required="true" type="string">

    <cfreturn UCase(Left(arguments.column_name, 1))
      & Right(Replace(arguments.column_name, '_', ' ', 'all'), Len(arguments.column_name) - 1)>
  </cffunction>


  <!--- The this and variables scope can have variable values set in structure notation (e.g. this['y'] = 'x'). 
    The cfdump tag does not show that these variables are ever arrays. If one sets a "this" variable with 
    dot notation (e.g. this.y = 'x'), then the structure notation (e.g. this['y'] = 'x') is no longer an array 
    but a scalar. This behavior is very strange. --->
  <cffunction name="get_this_value" access="private" returntype="any">
    <cfargument name="variable_name" required="true" type="string">

    <cfreturn IsArray(this[arguments.variable_name]) ? 
      this[arguments.variable_name][1] : this[arguments.variable_name]>
  </cffunction>


  <!--- Will cause exception if key name not defined in "this" object.  --->
  <cffunction name="validate_unique_keys" access="private" returntype="void">
    <!--- Must use intermediate variable because cfqueryparam chokes on this[key]. --->
    <cfset local.param_value_id = this["id"]>

    <cfloop index="i" from="1" to="#ArrayLen(variables.unique_keys)#">
      <cfquery result="local.result" datasource="#application.dsn#">
        SELECT TOP 1 id
        FROM #table_name()#
        WHERE 
          <cfloop list="#variables.unique_keys[i]#" index="key">
            <!--- Trim key value in case comma-separated list had spaces. --->
            <cfset local.param_value = get_this_value(trim(key))>
            #key# = <cfqueryparam value="#local.param_value#">
            AND
          </cfloop>
          id <> <cfqueryparam value="#local.param_value_id#">
      </cfquery>

      <cfif local.result.RecordCount IS 1>
        <cfset add_validation_error(field="unique_key", error='unique key', 
          message="Unique key violated: #variables.unique_keys[i]#")> 
      </cfif>
    </cfloop>
	</cffunction>  


  <!--- Will cause exception if key name not defined in "this" object.  
          Only works for single column (not composite) foreign key. --->
  <cffunction name="validate_foreign_keys" access="private" returntype="void">
    <cfloop index="i" from="1" to="#ArrayLen(variables.foreign_keys)#">
      <!--- Get model name from column name. --->
      <cfset local.foreign_key = variables.foreign_keys[i]>
      <cfset local.field_name_parts = ListToArray(local.foreign_key, "_")>
      <cfset ArrayDeleteAt(local.field_name_parts, ArrayLen(local.field_name_parts))>
      <cfset local.model_name = ArrayToList(local.field_name_parts, "_")>

      <cftry>
        <cfset model(local.model_name).find_by_id(this[local.foreign_key])>
        <cfcatch type="custom">
          <cfset add_validation_error(field="foriegn_key", error='foreign key', 
            message="Foreign key not found: #local.foreign_key#")> 
        </cfcatch>
      </cftry> 
    </cfloop>
	</cffunction>

	<cffunction name="load" access="private" returntype="void">
		<cfargument name="record" required="true" type="Query">

    <cfloop list="#record.ColumnList#" index="column">
      <cfset this[column]= record[column]>
    </cfloop>
	</cffunction>


  <cffunction name="custom_validate" access="private" returntype="void">
    <cfloop index="i" from="1" to="#ArrayLen(variables.custom_validation_functions)#">
      <cfset local.method_name = variables.custom_validation_functions[i]>
      <cfinvoke component = "#this#" method = "#local.method_name#">
    </cfloop>
  </cffunction>   


  <cffunction name="is_valid" access="public" returntype="boolean">
    <cfreturn ArrayLen(variables.validation_errors) IS 0>  
  </cffunction>


  <cffunction name="errors" access="public" returntype="array">
    <cfreturn variables.validation_errors>  
  </cffunction>


  <cffunction name="add_validation_error" access="private" returntype="void">
    <cfargument name="field" type="string" required="false" default="">
    <cfargument name="error" type="string" required="false" default="">
    <cfargument name="message" type="string" required="true">

    <cfset ArrayAppend(variables.validation_errors, 
      {'field'=arguments.field, 'error'=arguments.error, 'message'=arguments.message})>  
  </cffunction>


  <cffunction name="find_table_info" access="public" returntype="query">
    <cfquery name="local.result" datasource="#application.dsn#">
      SELECT column_name, is_nullable, data_type, character_maximum_length 
      FROM information_schema.columns
      WHERE table_name = <cfqueryparam value="#table_name()#">
    </cfquery> 

    <cfreturn local.result>
  </cffunction>  


	<cffunction name="delete_all" access="public" returnType="void">
		<cfquery name="local.records" datasource="#application.dsn#">
			DELETE
      FROM #table_name()#
		</cfquery>
  </cffunction>	  


  <cffunction name="build_associations" access="public" returnType="void">
    <cfargument name="is_build_associations_as_arrays" required="true" type="boolean">
    
    <cfloop index="model_name" list="#variables.has_many_models#">
      <cfset local.component_name = get_component_name()>
      <cfset local.model_table_name = model(model_name).table_name()>
      <cfset local.where_clause = "#local.component_name#_id = #this.id#">

      <cfquery name="local.records" datasource="#application.dsn#">
        SELECT *
        FROM #local.model_table_name#
        WHERE #local.where_clause#
      </cfquery>

      <cfif arguments.is_build_associations_as_arrays>
        <cfset this['#model_name#s'] = model(model_name).query_to_objects(local.records)>
      <cfelse>
        <cfset this['#model_name#s'] = local.records>
      </cfif>
    </cfloop>

    <cfloop index="model_name" list="#variables.has_one_models#">
      <cfset this['#model_name#'] = model(model_name)
        .init(this['#model_name#_id'])>
    </cfloop>

    <cfloop index="model_name" list="#variables.belongs_to_models#">
      <cfif not StructKeyExists(this, "#model_name#_id")>
        <cfthrow type="custom" message="#this.table_name()# cannot belong to #model_name#.  It does not have a '#model_name#_id' field.">
      </cfif>

      <cfset this['#model_name#'] = model(model_name)
        .init(this['#model_name#_id'])>
    </cfloop>
  </cffunction>


  <cffunction name="query_to_objects" output="false" access="public" returnType="array">
    <cfargument name="records" required="true" type="query">
    <cfset local.record_objects = ArrayNew(1)>
    <cfset local.component_name = get_component_name()>

    <cfloop query='arguments.records'>
      <cfset ArrayAppend(local.record_objects, model(local.component_name).init(id))>
    </cfloop> 

    <cfreturn local.record_objects>
  </cffunction>


	<cffunction name="has_many" access="private" returnType="void">
		<cfargument name="associated_model_name">
		<cfset variables.has_many_models = ListAppend(variables.has_many_models, arguments.associated_model_name)>
	</cffunction>


	<cffunction name="has_one" access="private" returnType="void">
		<cfargument name="associated_model_name">
		<cfset variables.has_one_models = ListAppend(variables.has_one_models, arguments.associated_model_name)>
	</cffunction>


	<cffunction name="non_blank_fields" access="private" returnType="void">
		<cfargument name="fields">
		<cfset variables.non_blank_columns = ListAppend(variables.non_blank_columns, arguments.fields)>
	</cffunction>


	<cffunction name="belongs_to" access="private" returnType="void">
		<cfargument name="associated_model_name">
		<cfset variables.belongs_to_models = ListAppend(variables.belongs_to_models, arguments.associated_model_name)>
	</cffunction>


	<cffunction name="add_custom_validation" access="private" returnType="void">
		<cfargument name="function_name" type="string" required="true">
		<cfset ArrayAppend(variables.custom_validation_functions, arguments.function_name)>
	</cffunction>


	<cffunction name="foreign_key" access="private" returnType="void">
		<cfargument name="key" type="string" required="true">
		<cfset ArrayAppend(variables.foreign_keys, arguments.key)>
	</cffunction>


	<cffunction name="unique_key" access="private" returnType="void">
		<cfargument name="key" type="string" required="true">

    <cfset local.arr = ArrayNew(1)>
    <cfset ArrayAppend(local.arr, arguments.key)>
		<cfset ArrayAppend(variables.unique_keys, ArrayToList(local.arr))>
	</cffunction>


  <cffunction name="model" access="private" returnType="component">
    <cfargument name="name" required="true">
    <cfreturn createObject("component", "models.#arguments.name#")>
  </cffunction>


  <cffunction name="get_component_name" access="private" returnType="string">
    <cfreturn ListToArray(GetMetaData(this).name, '.')[2]>
  </cffunction>


  <cffunction name="before_create" access="private">
    <cfargument name="attributes" type="struct" required="true">
  </cffunction>


  <cffunction name="before_update" access="private">
    <cfargument name="attributes" type="struct" required="true">
  </cffunction>

</cfcomponent>