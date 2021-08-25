<!--- TOOL DRAWER:  contains useful function(s) --->



<!--- Thanks Ben Nadel --->
<cffunction name="arrayAppendAll" access="public" returntype="array" output="false" hint="I append (concat) the entire incoming array to the target array.">

	<!--- Define arguments. --->
	<cfargument name="targetArray" type="array" required="true" hint="I am the array being augmented" />
	<cfargument name="incomingArray" type="array" required="true" hint="I am the array being added to the target array." />

	<!--- Define the local scope. --->
	<cfset var local = {} />

	<!---
		Loop over the incoming array and add each value to the
		target array. If we wanted to get *naughty*, we could use
		the Collection-based interface of the array:

		array.addAll( array )

		However, to keep things ColdFusion-friendly, we'll perform
		the array augmentation manually.
	--->
	<cfloop index="local.incomingValue" array="#arguments.incomingArray#">

		<!--- Append the incoming value. --->
		<cfset arrayAppend(arguments.targetArray, local.incomingValue) />

	</cfloop>

	<!---
		Since arrays are passed by VALUE in ColdFusion, we have to
		return the resultant array.
	--->
	<cfreturn arguments.targetArray />
</cffunction>





<cffunction name="arrayIsContainedIn" access="public" returntype="boolean" hint="I check if the first array is completely contained in second array">
  <cfargument name="smallerArray" type="array" required="true" hint="I am the smaller array or the search item">
  <cfargument name="targetArray" type="array" required="true" hint="I am the bigger array to be searched">

  <cfif ArrayLen(smallerArray) EQ 0 and ArrayLen(targetArray) EQ 0>
    <cfreturn true /> <!---when both are empty --->
  </cfif>

  <cfif ArrayLen(smallerArray) EQ 0>
    <cfreturn true /> <!--- an empty array would be part of every array. --->
  </cfif>

  <cfif ArrayLen(targetArray) EQ 0>
    <cfreturn false /> <!---Target array should not be empty--->
  </cfif>

  <cfloop index="i" from=1 to=#ArrayLen(arguments.smallerArray)#>
    <cfif NOT arrayContains(arguments.targetArray, arguments.smallerArray[i])>
      <cfreturn false>
    </cfif>
  </cfloop>
  
  <cfreturn true>
</cffunction>


<cffunction name="getApplicationVariables" output="false">
	<cfreturn application.intranet_site />
</cffunction>

