<!--- Utility to facilitate use of captcha on forms. --->

<cffunction name="random_captcha_string" returntype="string" output="false">
  <cfset local.pool = "23456789abdefghqrtABCDEFGHJKLMNPQRSTWXYZ">
  <cfset local.random_length = randRange(5,8)>
  <cfset local.random_string = "">
  <cfset local.i = "">
  <cfset local.random_char = "">

  <cfscript>
    for(i=1; i<=local.random_length; i++) {
      local.random_char = mid(local.pool, randRange(1, len(local.pool)), 1);
      local.random_string &= local.random_char;
    }
  </cfscript>
  <cfreturn local.random_string>
</cffunction>
