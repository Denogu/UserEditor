<cfcomponent output="false" extends="core.model">

    <cffunction name="table_name" returntype="string">
        <cfreturn 'sites'>
    </cffunction>

    <cfset variables.field_names = [
                                  'id',
                                  'iwrs_user_id',
                                  'site_id',
                                  'site_name'
                                ]/>

    <cffunction name="sites_for_user" access="Public" returntype="Query">
        <cfargument name="user_id" required="true" type="numeric">
        <cfquery name="session.user_sites" datasource="#application.dsn#">
            SELECT iwrs_user_sites.iwrs_user_id, iwrs_user_sites.site_id, sites.site_name
            FROM iwrs_user_sites, sites
            WHERE iwrs_user_id = <cfqueryparam value="#user_id#" cfsqltype="CF_CQL_INT" null="No"> 
            AND sites.id = iwrs_user_sites.site_id
            ORDER BY site_id
        </cfquery>

        <cfif isNull(session.user_sites)>
            <cfquery name="session.nullSites" datasource="#application.dsn#">
                SELECT iwrs_user_id, site_id
                FROM iwrs_user_sites
                WHERE iwrs_user_id = 0
                ORDER BY site_id
            </cfquery>
            <cfreturn session.nullSites>
        <cfelse>
            <cfreturn session.user_sites>
        </cfif>

    </cffunction>
l
    <cffunction name="delete_user_site" access="Public" returntype="struct">
        <cfargument name="delete_site_id" type="numeric" required="yes">
        <cfargument name="edit_user_id" type="numeric" required="yes">
        
        <cfquery name="session.delete_sites" datasource="#application.dsn#">
            DELETE
            FROM iwrs_user_sites
            WHERE iwrs_user_id = <cfqueryparam value="#edit_user_id#" cfsqltype="CF_CQL_INT" null="No">
            AND site_id = <cfqueryparam value="#delete_site_id#" cfsqltype="CF_CQL_INT" null="No">
        </cfquery>
        <cfreturn {result="Delete site(s) succeeded"}>
    </cffunction>

    <cffunction name="add_user_site" access="Public" returntype="struct">
        <cfargument name="add_site_id" type="numeric" required="yes">
        <cfargument name="edit_user_id" type="numeric" required="yes">

        <cfquery name="session.add_sites" datasource="#application.dsn#">
            INSERT INTO iwrs_user_sites (iwrs_user_id, site_id)
            VALUES (<cfqueryparam value="#edit_user_id#" cfsqltype="CF_CQL_INT" null="No">, <cfqueryparam value="#add_site_id#" cfsqltype="CF_CQL_INT" null="No">);
        </cfquery>
        <cfreturn {result="Add site(s) succeeded"}>
    </cffunction>

    <cffunction name="add_change_record" access="Public" returntype="struct">
        <cfargument name="justification" type="string" required="yes">
        <cfargument name="user_id_updated" type="numeric" required="yes">
        <cfargument name="add_list" type="string" required="no">
        <cfargument name="delete_list" type="string" required="no">

        <cfquery name="add_user_site_change" datasource="#application.dsn#">
            INSERT INTO iwrs_user_site_changes (justification, user_id_updated, additions, removals, updated_at, updated_by)
            VALUES (<cfqueryparam value="#justification#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="No">
            , <cfqueryparam value="#user_id_updated#" cfsqltype="CF_CQL_INT" null="No">
            , <cfqueryparam value="#add_list#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">
            , <cfqueryparam value="#delete_list#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">
            , GETUTCDATE(), <cfqueryparam value="#session.user.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50" null="No">);
        </cfquery>

        <cfreturn {result = "Change record added"}>
    </cffunction>
</cfcomponent>