<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.TransactionRollbackDecorator">
  <cfinclude template="../../helpers/injected_methods.cfm">
   
   <cfset SITE_NUMBER = '999'/>
   <cfset USER_NAME = 'tester_guy' />
  
  <cffunction name="setup" access="public">
     <cfset this.myComp = CreateObject("component", "#application.root#.models.participant") />
     <cfset this.valid_randomization_form = StructNew()>
     <cfset this.valid_randomization_form.subject_number = '#SITE_NUMBER#0001'>
     <cfset this.valid_randomization_form.check_code = 'aaaa'>
     <cfset this.valid_randomization_form.first_name = 'Unittests'>
     <cfset this.valid_randomization_form.middle_name = 'Help'>
     <cfset this.valid_randomization_form.last_name = 'Confidence'>
     <cfset this.valid_randomization_form.ssn = '722-36-9457'>
     <cfset this.valid_randomization_form.ssn_verification = '722-36-9457'>
     <cfset this.valid_randomization_form.is_icf_on_file = 'YES'>
     <cfset this.valid_randomization_form.icf_with_pharmacist = 'YES'>
     <cfset this.valid_randomization_form.utc_offset = '360'>
     <cfset this.valid_randomization_form.form_number = 'TESTGUY-123456789'>
  </cffunction>

  
  <cffunction name="beforeTests" access="public">
  	<cflock scope="Session" timeout="10" type="Exclusive">
     	<cfif isdefined("session.user")>
          <cfset structdelete(session, "user")>
        </cfif>  
        <cfparam name=session.user default=#StructNew()#>
        <cfparam name=session.user.name default='tester_guy'>
        <cfparam name=session.user.site_number default='#SITE_NUMBER#'>
     </cflock>
  </cffunction>
  
  <cffunction name="tearDown" access="public">
  </cffunction>
  

  <!--- for overriding check_randomization_eligibility function --->
  <cffunction name="randomization_eligibility_results" access="private">
    <cfargument name="form_fields" type="Struct" required="true">

    <cfset local.eligibility_results = StructNew()>
    <cfset local.eligibility_results.eligible = arguments.form_fields.eligible>
    <cfset local.eligibility_results.validation_errors = ArrayNew(1)>
    <cfif not arguments.form_fields.eligible>
      <cfset ArrayAppend(local.eligibility_results.validation_errors, 'Ineligible')>
    </cfif>

    <cfreturn local.eligibility_results>
  </cffunction>



  <!--- for overriding find_by function --->
  <cffunction name="returns_zero_records" access="private">
    <cfargument name="field_name" type="string" required="true">
    <cfargument name="field_value" type="string" required="true">

    <cfquery name="local.no_rec" datasource="#application.dsn#">
      SELECT id from iwrs_participants where 0 = 1
    </cfquery>

    <cfreturn local.no_rec>
  </cffunction>  
  


  <!--- for overriding find_by function --->
  <cffunction name="returns_one_record_with_field_value_as_id" access="private">
    <cfargument name="field_name" type="string" required="true">
    <cfargument name="field_value" type="string" required="true">

    <cfquery name="local.rec" datasource="#application.dsn#">
      SELECT <cfqueryparam value="#arguments.field_value#"> as id
    </cfquery>

    <cfreturn local.rec>
  </cffunction>



  <!--- for overriding find_by function --->
  <cffunction name="returns_two_records_with_field_value_as_id" access="private">
    <cfargument name="field_name" type="string" required="true">
    <cfargument name="field_value" type="string" required="true">

    <cfquery name="local.recs" datasource="#application.dsn#">
      SELECT <cfqueryparam value="#arguments.field_value#"> as id
      UNION ALL
      SELECT <cfqueryparam value="#arguments.field_value#"> as id
    </cfquery>

    <cfreturn local.recs>
  </cffunction>



   <!--- for overriding get_next_available_participant_record_for_site function --->
  <cffunction name="no_available_randomization_records" access="private">
    <cfquery name="local.no_rec" datasource="#application.dsn#">
      SELECT id from iwrs_participants where 0 = 1
    </cfquery>

    <cfreturn local.no_rec>
  </cffunction> 
  


  <cffunction name="update_participant_record" output="false" access="private">
    <cfargument name="site_number" type="string" required="true">
    <cfargument name="subject_number" type="string" required="true">
    <cfargument name="check_code" type="string" required="true">
    <cfargument name="ssn" type="string" required="true">
    
  	<cfquery name="insert_alpha_code_rec" datasource="#application.dsn#">
    	Update TOP (1) [iwrs_participants] 
        SET subject_number = <cfqueryparam value="#arguments.subject_number#" cfsqltype="cf_sql_varchar">,
         check_code = <cfqueryparam value="#arguments.check_code#" cfsqltype="cf_sql_varchar">,
         ssn = <cfqueryparam value="#arguments.ssn#" cfsqltype="cf_sql_varchar">,
         user_name = <cfqueryparam value="#USER_NAME#" cfsqltype="cf_sql_varchar">,
         is_available = 0 
        WHERE 
        site_number = <cfqueryparam value="#arguments.site_number#"> 
        and is_available = 1
    </cfquery>
    <cfreturn>
  </cffunction>
  
  
  <cffunction name="insert_participant_record" output="false" access="private">
    <cfargument name="site_number" type="string" required="true">
    <cfargument name="treatment_arm_name" type="string" required="true">
    <cfargument name="treatment_description" type="string" required="true">
    
  	<cfquery name="insert_alpha_code_rec" datasource="#application.dsn#" result="local.partcipant_rec">
    	insert into [iwrs_participants] ([site_number], [treatment_arm_name], [treatment_description])
        VALUES
        (
         <cfqueryparam value="#arguments.site_number#" >,
         <cfqueryparam value="#arguments.treatment_arm_name#" >,
          <cfqueryparam value="#arguments.treatment_description#" >         
        )
    </cfquery>
    <cfreturn this.myComp.init(local.partcipant_rec.generatedKey) />
  </cffunction>  


  <cffunction name="get_randomized_participant" access="private">
    <cfquery name="local.randomized_rec" datasource="#application.dsn#" maxrows="1">
      SELECT TOP 1 * 
      FROM [iwrs_participants]
      WHERE site_number = <cfqueryparam value="#SITE_NUMBER#">
      and is_available = 0
      and subject_number is not null
    </cfquery>
    <cfreturn local.randomized_rec>
  </cffunction>
   


  <cffunction name="get_next_available_participant_id_for_site" access="private">
    <cfquery name="local.next_available_randomization_record" datasource="#application.dsn#" maxrows="1">
      SELECT TOP 1 ID 
      FROM [iwrs_participants]
      WHERE site_number = <cfqueryparam value="#SITE_NUMBER#" cfsqltype="cf_sql_integer">
        and subject_number is null
        and is_available = 1 
      ORDER by id
    </cfquery>

    <cfreturn local.next_available_randomization_record.id>
  </cffunction>




<!--- #find_participant_by_subject_number_and_check_code TESTS ---> 




<!--- If no participant record is found, the model should return an error of type IWRS.Participant.MissingRecord --->
  <cffunction name="test_Find_Participant_By_Subject_Number_And_Check_Code_NoRecord" >  	
    <cfset local.subject_number = '#SITE_NUMBER#0777' />
    <cfset local.check_code = 'NOPE' />
   
    <cfset expectException('IWRS.Participant.MissingRecord','Expected IWRS.Participant.MissingRecord error.')>
    <cfset local.obj = this.myComp.find_participant_by_subject_number_and_check_code(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#') />
  </cffunction> 
   

   
<!--- If more than one participant record is found, the model should return an error of type IWRS.Participant.MultipleRandomizations --->  
  <cffunction name="test_Find_Participant_By_Subject_Number_And_Alpha_Code_More_Than_One_Exists" >  	
    <cfset local.subject_number = '5010999' />
    <cfset local.check_code = 'dirs' />
    <cfset local.ssn = '000-00-0000' />
    
    <cfset update_participant_record(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#', ssn = local.ssn) />
    <cfset update_participant_record(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#', ssn = local.ssn) />
   
    <cfset expectException("IWRS.Participant.MultipleRandomizations")> 
    <cfset local.obj = this.myComp.find_participant_by_subject_number_and_check_code(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#') />
  </cffunction> 
  
  
  
<!--- If the participant has been randomized, we should be able to retrieve the participant record using the subject_number and the check_code --->
  <cffunction name="test_Find_Participant_By_Subject_Number_And_Alpha_Code_Exists" >  	
    <cfset local.subject_number = '#SITE_NUMBER#0999' />
    <cfset local.check_code = 'dirs' />
    <cfset local.ssn = '000-00-0000'>
    
    <cfset update_participant_record(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#', ssn = local.ssn) />       
        
    <cfset local.obj = this.myComp.find_participant_by_subject_number_and_check_code(site_number="#SITE_NUMBER#", subject_number="#local.subject_number#", check_code='#local.check_code#') />
        
    <cfset assertTrue(local.obj.site_number EQ '#SITE_NUMBER#' 
      and local.obj.check_code EQ '#local.check_code#' 
      and local.obj.subject_number EQ "#local.subject_number#" 
      and local.obj.is_available EQ 0, 
      "Test fails for find_participant_by_subject_number_and_check_code() when participant record exists") 
    /> 
  </cffunction> 



<!--- #all_for_site() tests --->



<!--- all_for_site should return all the records for site where randomized_at is not null --->
  <cffunction name="test_All_For_Site_Returns_Correct_Number_Of_Records" >  	
    <cfquery name="local.get_count_for_site" datasource="#application.dsn#" maxrows="1">
      SELECT count(*) as total_count from iwrs_participants
      WHERE site_number = #SITE_NUMBER# and randomized_at is not null
    </cfquery> 
    <cfset local.expected_result = local.get_count_for_site.total_count>
        
    <cfset local.obj = this.myComp.all_for_site() />
        
    <cfset assertEquals(local.obj.recordCount, local.expected_result, "all_for_site() should have returned the correct number of records.")/> 
  </cffunction> 


<!--- #check_randomization_eligibility() tests --->
  
  <!--- Requires form_fields parameter. --->
  <cffunction name="test_check_randomization_eligibility_requires_form_fields_parameter">
    <cfset expectException("Application")>
    <cfset this.mycomp.check_randomization_eligibility()>
  </cffunction>



  <cffunction name="test_check_randomization_eligibility_Subject_Number_Check_Code_Mismatch">
    <cfset local.expected_error = 'Subject number and check code do not match.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = 'zzzz'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error for subject number check code mismatch.")>
  </cffunction>



  <cffunction name="test_check_randomization_eligibility_Subject_Number_Randomized">
    <cfset local.expected_error = 'Subject number already randomized.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.subject_number = '#SITE_NUMBER#1000'>
    <cfset local.randomization_form.check_code = 'zzzz'>
<!---Fake Randomization--->
    <cfset update_participant_record(
      subject_number = local.randomization_form.subject_number, 
      check_code = local.randomization_form.check_code, 
      site_number = SITE_NUMBER,
      ssn = local.randomization_form.ssn
    )>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if subject number already randomized.")>
  </cffunction>



  <cffunction name="test_check_randomization_eligibility_SSN_Randomized">
    <cfset local.expected_error = 'Social security number already randomized.'>
    <cfset local.randomization_form = this.valid_randomization_form>
<!---Fake Randomization--->
    <cfset update_participant_record(
      subject_number = local.randomization_form.subject_number, 
      check_code = local.randomization_form.check_code, 
      site_number = SITE_NUMBER,
      ssn = local.randomization_form.ssn
    )>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if SSN already randomized.")>
  </cffunction>
  

   <cffunction name="test_check_randomization_eligibility_Subject_Number_Blank">
    <cfset local.expected_error = 'Subject number must be your 3-digit site number followed by 4 digits.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.subject_number = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if subject number is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomization_eligibility_Eight_Digit_Subject_Number">
    <cfset local.expected_error = 'Subject number must be your 3-digit site number followed by 4 digits.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.subject_number = '#SITE_NUMBER#12345'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if subject number is too long.")>
  </cffunction>


  <cffunction name="test_check_randomization_eligibility_Six_Digit_Subject_Number">
    <cfset local.expected_error = 'Subject number must be your 3-digit site number followed by 4 digits.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.subject_number = '#SITE_NUMBER#123'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if subject number is too short.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Subject_Number_For_Different_Site">
    <cfset local.expected_error = 'The subject number does not match a subject number for your site.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.subject_number = '1111234'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if subject number is for a different site.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_Check_Code_Blank">
    <cfset local.expected_error = 'Check code must be your 4 characters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if check code is blank.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_Five_Character_Check_Code">
    <cfset local.expected_error = 'Check code must be your 4 characters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = 'ABCDE'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if check code is too long.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Three_Character_Check_Code">
    <cfset local.expected_error = 'Check code must be your 4 characters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = 'ABC'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if check code is too short.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Check_Code_Has_Numeric">
    <cfset local.expected_error = 'Check code must be your 4 characters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = 'ABC5'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if check code has number.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_Check_Code_Way_Too_Long">
    <cfset local.expected_error = 'Check code must be your 4 characters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.check_code = 'ABCdfsjkajkajlkadfsjlkdfsalkjdfsajlkdfsajlkdfsak'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if check code is way too long.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_First_Name_Blank">
    <cfset local.expected_error = 'First name cannot be blank.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.first_name = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if first name is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_First_Name_One_Character">
    <cfset local.expected_error = 'First name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.first_name = 'A'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if first name is one character.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_First_Name_Fifty_One_Characters">
    <cfset local.expected_error = 'First name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.first_name = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if first name is too long.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_First_Name_Contains_Number">
    <cfset local.expected_error = 'First name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.first_name = 'J0hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if first name has a number.")>
  </cffunction> 
  

  <cffunction name="test_check_randomation_eligibility_First_Name_Contains_Period">
    <cfset local.expected_error = 'First name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.first_name = 'J.hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if first name has special character.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Middle_Name_Blank">
    <cfset local.expected_error = 'Middle name cannot be blank.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.middle_name = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if middle name is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Middle_Name_Fifty_One_Characters">
    <cfset local.expected_error = 'Middle name must be between 1 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.middle_name = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if middle name is too long.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Middle_Name_Contains_Number">
    <cfset local.expected_error = 'Middle name must be between 1 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.middle_name = 'J0hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if middle name has a number.")>
  </cffunction> 
  

  <cffunction name="test_check_randomation_eligibility_Middle_Name_Contains_Period">
    <cfset local.expected_error = 'Middle name must be between 1 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.middle_name = 'J.hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if middle name has special character.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Last_Name_Blank">
    <cfset local.expected_error = 'Last name cannot be blank.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.last_name = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if last name is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Last_Name_One_Character">
    <cfset local.expected_error = 'Last name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.last_name = 'A'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if last name is one character.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Last_Name_Fifty_One_Characters">
    <cfset local.expected_error = 'Last name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.last_name = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if last name is too long.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Last_Name_Contains_Number">
    <cfset local.expected_error = 'Last name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.last_name = 'J0hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if last name has a number.")>
  </cffunction> 
  

  <cffunction name="test_check_randomation_eligibility_Last_Name_Contains_Period">
    <cfset local.expected_error = 'Last name must be between 2 and 50 characters and can only contain letters.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.last_name = 'J.hn'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if last name has special character.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_SSN_Has_No_Dashes">
    <cfset local.expected_error = 'Social security number must be ######-####-########.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.ssn = '123456789'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if ssn missing dashes.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_SSN_Has_Extra_Digit">
    <cfset local.expected_error = 'Social security number must be ######-####-########.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.ssn = '123-45-67899'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if ssn has extra digit.")>
  </cffunction> 

  
  
  <cffunction name="test_check_randomation_eligibility_SSN_Has_Missing_Digit">
    <cfset local.expected_error = 'Social security number must be ######-####-########.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.ssn = '123-45-678'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if ssn is missing digit.")>
  </cffunction> 
  


  <cffunction name="test_check_randomation_eligibility_SSN_Contains_Alpha">
    <cfset local.expected_error = 'Social security number must be ######-####-########.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.ssn = '123-45-678P'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if ssn has a letter.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_SSN_Verification_Not_Equal_To_SSN">
    <cfset local.expected_error = 'You must confirm the social security number.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.ssn_verification = '999-99-9999'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if ssn verification does not match SSN.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_Is_ICF_On_File_Blank">
    <cfset local.expected_error = 'A signed informed consent form must be on file.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.is_icf_on_file = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if is_icf_on_file is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_Is_ICF_On_File_No">
    <cfset local.expected_error = 'A signed informed consent form must be on file.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.is_icf_on_file = 'NO'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if is_icf_on_file is no.")>
  </cffunction> 



  <cffunction name="test_check_randomation_eligibility_icf_with_pharmacist_Blank">
    <cfset local.expected_error = 'A copy of the signed consent form must be given to the research pharmacist.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.icf_with_pharmacist = ''>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if icf_with_pharmacist is blank.")>
  </cffunction> 


  <cffunction name="test_check_randomation_eligibility_icf_with_pharmacist_No">
    <cfset local.expected_error = 'A copy of the signed consent form must be given to the research pharmacist.'>
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.randomization_form.icf_with_pharmacist = 'NO'>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertFalse(local.eligibility_results.eligible, "Subject should not be eligible.")>
    <cfset assertTrue(ArrayContains(local.eligibility_results.validation_errors, local.expected_error), "Eligibility check should contain error if icf_with_pharmacist is no.")>
  </cffunction> 

  
  <cffunction name="test_check_randomation_eligibility_Valid_Randomization_Form">
    <cfset local.randomization_form = this.valid_randomization_form>
    <cfset local.eligibility_results = this.mycomp.check_randomization_eligibility(local.randomization_form)>
    <cfset assertTrue(local.eligibility_results.eligible, "Subject should be eligible.")>
    <cfset assertTrue(ArrayIsEmpty(local.eligibility_results.validation_errors), "Eligibility check should not contain errors if randomization form is valid.")>
  </cffunction> 


<!--- #randomize() tests --->
  
  <!--- Requires form_fields parameter. --->
  <cffunction name="test_randomize_requires_form_fields_parameter">
    <cfset expectException("Application")>
    <cfset this.mycomp.randomize()>
  </cffunction>



  <!--- Throws error if check_randomization_eligibility returns ineligible --->
  <cffunction name="test_randomize_throws_error_if_participant_is_ineligible">
    <cfset injectMethod(this.myComp, this, "randomization_eligibility_results", "check_randomization_eligibility")>
    <cfset local.form_fields = {eligible = false}>
    <cfset expectException("IWRS.ParticipantIneligible")>
    <cfset this.mycomp.randomize(local.form_fields)>
  </cffunction>


  <!--- If form number exists in the iwrs_participants table the randomize function returns the id of the record.  This behavior is to handle duplicate requests that cause a race condition. --->
  <cffunction name="test_randomize_returns_id_of_participant_record_for_existing_form_number">
    <cfset injectMethod(this.myComp, this, "randomization_eligibility_results", "check_randomization_eligibility")>
    <cfset injectMethod(this.myComp, this, "returns_one_record_with_field_value_as_id", "find_by")><!--- Injected method echoes form number as id of form number record. --->
    <cfset local.expected_rec_id = 1>
    <cfset local.form_fields = {eligible = true, form_number = local.expected_rec_id}>
    <cfset local.actual_id = this.mycomp.randomize(local.form_fields)>
    <cfset assertEquals(local.expected_rec_id, local.actual_id, "The id that randomize() returns should match the id of the participant number for the previously submitted form number.")>
  </cffunction>



  <!--- If form number exists more than once, something has gone terribly wrong. Throw an error --->
  <cffunction name="test_randomize_throws_error_if_more_than_one_participant_record_exists_for_form_number">
    <cfset injectMethod(this.myComp, this, "randomization_eligibility_results", "check_randomization_eligibility")>
    <cfset injectMethod(this.myComp, this, "returns_two_records_with_field_value_as_id", "find_by")><!--- Injected method echoes form number twice as id. --->
    <cfset expectException("IWRS.DuplicateFormSubmissions")>

    <cfset local.form_fields = {eligible = true, form_number = 1}>
    <cfset local.participant_id = this.mycomp.randomize(local.form_fields)>
  </cffunction>



  <!--- Throws error if there are no available participant records for randomization --->
  <cffunction name="test_randomize_throws_error_if_no_available_participant_records">
    <cfset injectMethod(this.myComp, this, "randomization_eligibility_results", "check_randomization_eligibility")>
    <cfset injectMethod(this.myComp, this, "returns_zero_records", "find_by")>
    <cfset injectMethod(this.myComp, this, "no_available_randomization_records", "get_next_available_participant_record_for_site")>
    <cfset local.form_fields = {eligible = true, form_number = 1}>
    <cfset expectException("IWRS.NoAvailableParticipantRecords")>
    <cfset this.mycomp.randomize(local.form_fields)>
  </cffunction>



  <!--- Valid randomization request --->
  <cffunction name="test_randomize_valid_request">
    <cfset local.form_fields = this.valid_randomization_form>
    <cftransaction>
      <cfset local.expected_participant_id = get_next_available_participant_id_for_site()>
      <cfset local.actual_id = this.mycomp.randomize(local.form_fields)>
    </cftransaction>
    <cfset assertEquals(local.expected_participant_id, local.actual_id, "The participant ID returned by randomize() should be the next available participant ID for site.")>
  </cffunction>

  
  <!--- Valid randomization request participant record should not be available --->
  <cffunction name="test_randomized_participant_record_is_not_available">
    <cfset local.form_fields = this.valid_randomization_form>
      <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
      <cfset local.participant = This.myComp.init(local.participant_id)>

    <cfset assertEquals(0, local.participant.is_available, "An allocated participant record should not be available.")>
  </cffunction>



  <!--- Valid randomization request participant record should be updated with participant information --->
  <cffunction name="test_randomized_participant_record_updated_with_subject_information">
    <cfset local.form_fields = this.valid_randomization_form>
      <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
      <cfset local.participant = This.myComp.init(local.participant_id)>

    <cfset assertEquals(local.form_fields.subject_number, local.participant.subject_number, "participant subject_number should match user input.")>
    <cfset assertEquals(local.form_fields.check_code, local.participant.check_code, "participant check_code should match user input.")>
    <cfset assertEquals(local.form_fields.first_name, local.participant.first_name, "participant first_name should match user input.")>
    <cfset assertEquals(local.form_fields.middle_name, local.participant.middle_name, "participant middle_name should match user input.")>
    <cfset assertEquals(local.form_fields.last_name, local.participant.last_name, "participant last_name should match user input.")>
    <cfset assertEquals(local.form_fields.ssn, local.participant.ssn, "participant ssn should match user input.")>
  </cffunction>



  <!--- Valid randomization request participant should be active --->
  <cffunction name="test_randomized_participant_is_active">
    <cfset local.form_fields = this.valid_randomization_form>
      <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
      <cfset local.participant = This.myComp.init(local.participant_id)>

    <cfset assertEquals(1, local.participant.is_active, "A newly randomized participant should be active in the study.")>
  </cffunction>



<!--- #update_status Tests. --->



  <cffunction name="test_update_status_throws_error_if_participant_is_unblinded">
    <cfset expectException("Participant.UpdateStatus.Unblinded")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectMethod(this.myComp, this, "returns_true", "is_participant_unblinded")>
    <cfset local.reason = 'good reason'>
    <cfset local.is_active = 1>

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
  </cffunction>



  <cffunction name="test_update_status_requires_reason">
    <cfset expectException("Participant.UpdateStatus.MissingReason")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset local.reason = ''>
    <cfset local.is_active = 1>

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
  </cffunction>

   
  
  <cffunction name="test_update_status_invalid_active_status">
    <cfset expectException("Participant.UpdateStatus.UnknownStatus")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset local.reason = 'Some reason.'>
    <cfset local.is_active = '2'>

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
  </cffunction> 


  
  <cffunction name="test_update_status_active_participant_active_status">
    <cfset expectException("Participant.UpdateStatus.SameStatus")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectProperty(local.participant,"is_active", '1')>
    <cfset local.reason = 'Some reason.'>
    <cfset local.is_active = '1'>

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
  </cffunction>



  <cffunction name="test_update_status_inactive_participant_inactive_status">
    <cfset expectException("Participant.UpdateStatus.SameStatus")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectProperty(local.participant,"is_active", '0')>
    <cfset local.reason = 'Some reason.'>
    <cfset local.is_active = '0'>

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
  </cffunction>



  <cffunction name="test_update_status_active_participant_inactive_status">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset local.reason = 'Some reason.'>
    <cfset local.is_active = '0'><!--- Newly randomized participant is_active. --->

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
    <cfset local.updated_participant = This.myComp.init(local.participant_id)>
    <cfset AssertEquals('0', local.updated_participant.is_active, "The participant should not be active.")>
  </cffunction>



  <cffunction name="test_update_status_active_participant_inactive_status_back_to_active">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset local.reason = 'Some reason.'>
    <cfset local.is_active = '0'><!--- Newly randomized participant is_active. --->

    <cfset local.participant.update_status(is_active = local.is_active, reason = local.reason)>
    <cfset local.participant.update_status(is_active = '1', reason = 'second reason.')>
    <cfset local.updated_participant = This.myComp.init(local.participant_id)>
    <cfset AssertEquals('1', local.updated_participant.is_active, "The participant should be active.")>
  </cffunction>



<!--- #is_participant_unblinded tests --->
  

  <cffunction name="test_is_participant_unblinded_false_by_default">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    
    <cfset AssertFalse(local.participant.is_participant_unblinded(), "The participant should not be unblinded right after randomization.")>
  </cffunction>
  


  <cffunction name="test_is_participant_unblinded_false_if_is_unblinded_equals_zero">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectProperty(local.participant, "is_unblinded", "0")>
    
    <cfset AssertFalse(local.participant.is_participant_unblinded(), "The participant should not be unblinded if is_unblinded = 0.")>
  </cffunction>



  <cffunction name="test_is_participant_unblinded_true_if_is_unblinded_equals_one">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectProperty(local.participant, "is_unblinded", "1")>
    
    <cfset AssertTrue(local.participant.is_participant_unblinded(), "The participant should be unblinded if is_unblinded = 1.")>
  </cffunction>


<!--- #unblind tests --->


  <cffunction name="test_unblind_returns_error_if_unblinded">
    <cfset expectException("Participant.Unblind.AlreadyUnblinded")>
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>
    <cfset injectMethod(this.myComp, this, "returns_true", "is_participant_unblinded")>

    <cfset local.participant.unblind()>
  </cffunction>



  <cffunction name="test_unblind_unblinds_participant">
    <cfset local.form_fields = this.valid_randomization_form>
    <cfset local.participant_id = this.myComp.randomize(local.form_fields)>
    <cfset local.participant = This.myComp.init(local.participant_id)>

    <cfset local.participant.unblind()>
    <cfset AssertEquals('0', local.participant.is_active, "The participant should not be active if unblinded.")>
    <cfset AssertEquals('1', local.participant.is_unblinded, "The participant should not be active if unblinded.")>

    <cfset local.refreshed_participant = This.myComp.init(local.participant.id)>
    <cfset AssertTrue(local.participant.is_participant_unblinded(), "The participant should be unblinded if the participant was unblinded.")>
    <cfset AssertEquals('0', local.participant.is_active, "The participant should not be active if unblinded.")>
    <cfset AssertEquals('1', local.participant.is_unblinded, "The participant should not be active if unblinded.")>
  </cffunction>


</cfcomponent>
