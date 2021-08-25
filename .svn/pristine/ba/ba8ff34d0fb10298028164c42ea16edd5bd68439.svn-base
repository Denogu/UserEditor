<cfcomponent extends="iwrs_controller">
  <cffunction name="is_authorized" access="Public">
    <cfreturn session.user.is_crpcc> 
  </cffunction>


  <cffunction name="records" output="true" access="Public">
    <cfset local.view_data.atm_records = createObject("component", "models.assignment_type_treatment_mapping").find_all()>
    <cfreturn render(local.view_data)>
  </cffunction>


  <cffunction name="edit_assignment_treatment" output="true" access="Public">
    <cfset local.view_data = createObject("component", "models.assignment_type_treatment_mapping").init(this.params.id)>
    <cfreturn render_partial(view_data=local.view_data)>
  </cffunction>


  <cffunction name="update_assignment_treatment" output="true" access="Public">
    <cftransaction>
      <cfset record = createObject("component", "models.assignment_type_treatment_mapping").init(this.params.id)>
      <cfset record.update({cutoff_prior_to_expiration = this.params.cutoff_prior_to_expiration, user_name = session.user.name})>

      <cfset createObject("component", "models.cutoff_to_expiration_history").create(
        {assign_type_treat_map_id = this.params.id, cutoff_prior_to_expiration = this.params.cutoff_prior_to_expiration, 
        user_name = session.user.name, justification = this.params.justification})>
    </cftransaction>

    <!--- Return to management page on success. --->
    <cfreturn redirect(controller='crpccs', action='records')>
  </cffunction>


</cfcomponent>
