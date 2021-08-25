<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator" >
  <cfset USER_NAME = "MXUnitTestUser" />
  <cfset EMAIL = "zachary.taylor2@va.gov" />
  <cfset SITE_NUMBER = "501" />


  <cffunction name="setup" access="public">
    <cfset myComp = CreateObject("component", "models.emergency_unblinding") />
    <cfset session.user.site_number = SITE_NUMBER>
    <cfset session.user.name = USER_NAME>
  </cffunction>
  

  
  <cffunction name="beforeTests" access="public">
  </cffunction>
  


  <cffunction name="tearDown" access="public">    
  </cffunction>


  <cffunction name="test_table_name">
    <cfset assertEquals('iwrs_emergency_unblindings', myComp.table_name(), "The table name should be iwrs_emergency_unblindings.")>
  </cffunction>



  <!--- #unblind_participant tests --->


  <cffunction name="test_unblind_participant_throws_error_if_blank_reason_given">
    <cfset local.participant = mock() >
    <cfset local.justification = ' '>

    <cfset expectException("EmergencyUnblinding.UnblindParticipant.MissingJustification")>
    <cfset myComp.unblind_participant(local.participant, local.justification)>    
  </cffunction>



  <cffunction name="test_unblind_participant_throws_error_if_participant_is_unblinded">
    <cfset local.participant = mock() >
    <cfset local.participant.is_participant_unblinded().returns(true)>
    <cfset local.justification = 'test'>

    <cfset expectException("EmergencyUnblinding.UnblindParticipant.ParticipantAlreadyUnblinded")>
    <cfset myComp.unblind_participant(local.participant, local.justification)>    
  </cffunction>



<!--- I use this test to make sure that #unblind_participant calls #unblind on the participant object. --->
  <cffunction name="test_unblind_participant_calls_unblind_on_participant_object">
    <cfset local.participant = mock()>
    <cfset local.participant.id = 1>
    <cfset local.participant.is_participant_unblinded().returns(false)>
    <cfset local.participant.unblind().throws("Unblinded")>
    <cfset local.justification = 'test'>

    <cfset expectException("Unblinded")>
    <cfset myComp.unblind_participant(local.participant, local.justification)>    
  </cffunction>



  <cffunction name="test_unblind_participant_creates_emergency_unblinding">
    <cfset local.participant = mock()>
    <cfset local.participant.id = 88>
    <cfset local.participant.is_participant_unblinded().returns(false)>
    <cfset local.participant.unblind().returns(true)>
    <cfset local.justification = 'test'>

    <cfset local.unblinding = myComp.unblind_participant(local.participant, local.justification)>    
    <cfset assertEquals(local.participant.id, local.unblinding.participant_id, "The participant_id should match the id of the participant.")>
    <cfset assertEquals(local.justification, local.unblinding.justification, "The justification should match.")>
    <cfset assertEquals(local.justification, local.unblinding.justification, "The justification should match.")>
    <cfset assertEquals(session.user.name, local.unblinding.user_name, "The user_name should match the session user.")>
  </cffunction>


<!--- PRIVATE METHODS --->


  <cffunction name="get_number_of_emergency_unblindings" access="private" returntype="Numeric">
    <cfquery name="local.unblinding" datasource="#application.dsn#" maxrows="1">
      SELECT count(*) as rec_count
      FROM emergency_unblindings
    </cfquery>

    <cfreturn local.unblinding.rec_count>
  </cffunction>



  <cffunction name="get_participant" access="private">
    <cfquery name="local.participant_rec" datasource="#application.dsn#" maxrows="1">
      SELECT TOP 1 id FROM iwrs_participants
    </cfquery>

    <cfreturn createObject("models.participant").init(local.participant_rec.id)>
  </cffunction>


</cfcomponent>
