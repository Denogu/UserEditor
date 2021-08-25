<!--- This file is used when user accounts require a password and cannot rely on windows authentication.  
      It included provisions for generating a random salt value, securing a plain text pa$sword, generating a strong, random pa$sword 
      and checking the strength of a user generated pa$sword. --->
<cfcomponent name="Password">
  <cfset variables.specials = "~!@##$%^&*()-+=[]"><!--- Valid special characters for pa$sword --->
  <cfset variables.lowercases = "abcdefghijklmnopqrstuvwxyz">
  <cfset variables.uppercases = ucase( variables.lowercases )>
  <cfset variables.numbers = "0123456789">
  <cfset variables.all_valid_characters = variables.specials & variables.lowercases & variables.uppercases & variables.numbers>

  <!--- Used to generate a random base64 string to salt pa$swords --->
  <cffunction name="get_salt" access="public" returnType="string">
      <cfargument name="size" type="numeric" required="false" default="16" />
      <cfscript>
       var byteType = createObject('java', 'java.lang.Byte').TYPE;
       var bytes = createObject('java','java.lang.reflect.Array').newInstance( byteType , size);
       var rand = createObject('java', 'java.security.SecureRandom').nextBytes(bytes);
       return toBase64(bytes);
      </cfscript>
  </cffunction>

  <!--- Main algorithm for securing plain text pa$sword (requires a salt string) --->
  <cffunction name="secure" access="public" returntype="string">
    <cfargument name="password" type="string" required="true">
    <cfargument name="salt" type="string" required="true">
    
    <cfscript>
      var hashed = hash(password & salt, "SHA-512");

      for(i = 1; i < 201; i++) {
        hashed = hash(hashed & salt, "SHA-512");
      }
      return hashed;
    </cfscript>
  </cffunction>

  <!--- Checks a password for the following:
          * At least eight-characters in length
          * Has at least one upper-case character
          * Has at least one lower-case character
          * Has at least one number
          * Has at least one (!@#$%^&*()-+=[]) --->
  <cffunction name="is_strong" access="public" returnType="Boolean">
    <cfargument name="pwd" required="true" type="string">
    
    <!--- Must be at least eight-characters in length --->
    <cfif Len(pwd) lt 8>
      <cfreturn false>
    </cfif>
    <!--- Must contain a lower-case and upper-case character --->
    <cfif (refind('[a-z]', pwd) is 0) or (refind('[A-Z]', pwd) is 0)>
      <cfreturn false>
    </cfif>
    <!--- Must contain a number and a special character --->
    <cfif (refind('[0-9]', pwd) is 0) or (refind('!|@|##|\$|%|\^|&|\*|\(|\)|~|-|=|\+|\[|\]',pwd) is 0)>
      <cfreturn false>
    </cfif>    
    
    <cfreturn true>
  </cffunction>

  <!--- creates a random pa$sword that meets the criteria above.  Used to reset pa$swords --->
  <cffunction name="generate_random_password" access="public" returntype="String">
    <cfset java_rand = CreateObject('java', 'java.security.SecureRandom').getInstance('SHA1PRNG')>
    <cfset local.password = ArrayNew(1)>
    <cfset local.required_number = Mid(variables.numbers,java_rand.nextInt(len(variables.numbers)) + 1,1)> 
    <cfset local.required_lowercase = Mid(variables.lowercases,java_rand.nextInt(len(variables.lowercases)) + 1,1)> 
    <cfset local.required_uppercase = Mid(variables.uppercases,java_rand.nextInt(len(variables.uppercases))+1,1)> 
    <cfset local.required_special = Mid(variables.specials,java_rand.nextInt(len(variables.specials))+1,1)> 

    <cfset ArrayAppend(local.password, local.required_number)>
    <cfset ArrayAppend(local.password, local.required_lowercase)>
    <cfset ArrayAppend(local.password, local.required_uppercase)>
    <cfset ArrayAppend(local.password, local.required_special)>
     
    <cfloop index="i" from="1" to="4">
      <cfset ArrayAppend(local.password, Mid(variables.all_valid_characters, java_rand.nextInt(len(variables.all_valid_characters))+1, 1))>
    </cfloop>
    
    <!--- mix up our characters --->
    <cfset createObject("java", "java.util.Collections").Shuffle(local.password)>

    <cfreturn ArrayToList(local.password,"")>
  </cffunction>

</cfcomponent>
