<!--- Thanks to Ben Nadel. --->

<!--- Set up our test suite. --->
<cfset testSuite = createObject( "component", "mxunit.framework.TestSuite" ).TestSuite() />

<cfset testSuite.addAll( "server.models.user_test") />
<cfset testSuite.addAll( "server.models.participant_test") />
<cfset testSuite.addAll( "server.models.check_code_test") />
<cfset testSuite.addAll( "server.models.emergency_unblinding_test") />


<cfset results = testSuite.run() />

<!--- Output the results. Pass in the web-root of the MXUnit
    folder so that the rendering can properly set up the CSS
    and JavaScript URLs. --->
<cfoutput>#results.getHtmlResults( "mxunit" )#</cfoutput>
