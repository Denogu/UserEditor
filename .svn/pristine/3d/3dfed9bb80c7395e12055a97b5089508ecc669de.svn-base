<cfset response = StructNew()>
<cfset response.cprs_field_value = 'No&nbsp;'>
<cfif local.view_data.in_cprs EQ '1'>
  <cfset response.cprs_field_value = 'Yes&nbsp;'>
</cfif>

<cfif local.view_data.success EQ 1>
  <cfset response.message='<div class="alert alert-success">#local.view_data.message#</div>'>
<cfelse>
  <cfset response.message='<div class="alert alert-danger">#local.view_data.message#</div>'>
</cfif>

<cfoutput>#SERIALIZEJSON(response)#</cfoutput>
