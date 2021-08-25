<cfcomponent output="false" extends="core.model">

    <cffunction name="table_name" returntype="string">
        <cfreturn 'sites'>
    </cffunction>

    <cffunction name="all" access="Public" returntype="Query">

        <cfquery name="local.sites" datasource="#application.dsn#">
            SELECT *
            FROM sites
        </cfquery>

        <cfreturn local.sites>
    </cffunction>
</cfcomponent>