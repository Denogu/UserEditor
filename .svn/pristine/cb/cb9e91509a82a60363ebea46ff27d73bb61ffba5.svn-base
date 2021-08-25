<cfcomponent>

  <cffunction name="send_reset_password" access="public">
    <cfargument name="email_address_to">
    <cfargument name="email_address_from">
    <cfargument name="email_address_cc">
    <cfargument name="reset_url">

    <cfset local.message_body = "To reset your password, please <a href='#arguments.reset_url#'>click here</a>.">

    <cfmail to="#arguments.email_address_to#" from="#arguments.email_address_from#" cc="#arguments.email_address_cc#"
      subject="1033 IWRS - Password Reset" type="html">
      #message_body#
    </cfmail>

    <cfreturn local.message_body>
  </cffunction>

</cfcomponent>