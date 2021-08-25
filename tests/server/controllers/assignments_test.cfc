/**
* @mxunit:decorators mxunit.framework.decorators.TransactionRollbackDecorator 
**/

component extends="mxunit.framework.TestCase" {
 
 //nvd, need participant record inserted too, what does participant.randomize do? check appropriate sub num and alpha code
  SUBJECT_NUMBER_1 = 1001;
  ALPHA_CODE_1 = 'TSPY';
  SITE_NUMBER_1 = 301;

  SUBJECT_NUMBER_BAD = 8888;
  ALPHA_CODE_BAD = 'ZZZZ';
  SITE_NUMBER_BAD = 311;

  QUESTION_NUMBER_1 = 77;
  ERROR_MESSAGE_1 = 'Wrong answer.';
  ID_1 = 1;
  GOOD_RESPONSE_1 = 2;
  BAD_RESPONSE_1 = 1;

  QUESTION_NUMBER_2 = 78;
  ERROR_MESSAGE_2 = 'Wrong answer again.';
  ID_2 = 2;
  GOOD_RESPONSE_2 = 3;
  BAD_RESPONSE_2 = 2;

  UTC_OFFSET = 360; 
  USER_NAME = 'mxunit_assignments_test';
  CUTOFF_TO_EXPIRATION = 90; 
  PACKAGE_DEFINITION_ID = 272;
  LOT_ID = 28956;
  BOTTLE_NUMBER = 3222;
  SITE_ID = 5678;
	
	
	public function setup() {
		this.assign_cntrlr = createObject("component", "controllers.assignments");
	}


  // Simple test to determine if errors are returned.
  function get_next_available_fail() {
 		try {
    	this.assign_cntrlr.get_next_available_item_id(
    		item_service = createObject("component", "utilities.item_services"), 
    		package_definition_id = PACKAGE_DEFINITION_ID, 
    		cutoff_prior_to_expiration = CUTOFF_TO_EXPIRATION, 
    		site_number = SITE_NUMBER_1);
    } catch (custom ex) {
    	assertEquals(this.assign_cntrlr.ERROR_MESSAGE_INVENTORY, ex.message);
    }
  }
  
  
  // Determine if item_services being utilized correctly.
  function get_next_available_success() {
  	var item_service = createObject("component", "mocks.item_services_mock");
  	
  	assertEquals(item_service.item_id_to_return(), this.assign_cntrlr.get_next_available_item_id(
  		item_service = item_service, package_definition_id = PACKAGE_DEFINITION_ID, 
    	cutoff_prior_to_expiration = CUTOFF_TO_EXPIRATION, site_number = SITE_NUMBER_1));
  }

  
	function create_assignment_and_status_record_success() {
    var params = {site_number=SITE_NUMBER_1, subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
  		user_name=USER_NAME, utc_offset=UTC_OFFSET};
    
    var item = createobject("component", "models.item").create({package_definition_id = PACKAGE_DEFINITION_ID, 
    	site_id = SITE_NUMBER_1, lot_id = LOT_ID, user_name = USER_NAME, number = BOTTLE_NUMBER});
    
		assertTrue(isnumeric(this.assign_cntrlr.create_assignment_and_status_record(
			params = params, assignment_type_treat_map_id = 1, item_id = item.id)));
	}


	// Eligibility failure should never happen when saving assignment, but this checks anyway.
	function save_assignment_bad_eligibility_fail() {
		init_db();
		
		var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=BAD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
      
    session.user.site_number = SITE_NUMBER_1;
    session.user.utc_offset = UTC_OFFSET;
    session.user.name = USER_NAME;
        
    var result = this.assign_cntrlr.save_assignment(params);
    assertFalse(result.is_success);
    assertEquals('Assignment error: Wrong answer.', result.message);
	}


	// Site number not valid for subject number and alpha code.
	function save_assignment_bad_site_fail() {
		init_db();
		
		var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=GOOD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
      
    session.user.site_number = SITE_NUMBER_BAD;
    session.user.utc_offset = UTC_OFFSET;
    session.user.name = USER_NAME;
        
    var result = this.assign_cntrlr.save_assignment(params);
    assertFalse(result.is_success);
    assertEquals('Assignment error: Subject number and alpha code not valid for this site.', result.message);
	}


	function save_assignment_no_inventory_fail() {
		init_db();
		
		var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=GOOD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
      
    session.user.site_number = SITE_NUMBER_1;
    session.user.utc_offset = UTC_OFFSET;
    session.user.name = USER_NAME;
    	    
    injectMethod(this.assign_cntrlr, this, 'get_next_available_item_id_mock_throw_exception', 'get_next_available_item_id');
		debug(this.assign_cntrlr.save_assignment(params));
		
		var elg_form_record = createobject("component", "models.elg_form").find_one(site_number = SITE_NUMBER_1,
			subject_number = SUBJECT_NUMBER_1, alpha_code = ALPHA_CODE_1);
		assertEquals(0, elg_form_record.RecordCount);
		
		expectException('custom');
		createobject("component", "models.participant")
			.find_participant_by_subject_number_and_alpha_code(subject_number = SUBJECT_NUMBER_1,
				alpha_code = ALPHA_CODE_1, site_number = SITE_NUMBER_1);
	}


	function save_assignment_unexpected_exception_transaction_rollback() {
		local.exception_1 = false;
		local.exception_2 = false;
		
		init_db();
		
		var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=GOOD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
      
    session.user.site_number = SITE_NUMBER_1;
    session.user.utc_offset = UTC_OFFSET;
    session.user.name = USER_NAME;
    	    
    injectMethod(this.assign_cntrlr, this, 'create_assignment_and_status_record_mock_throw_exception', 
    	'create_assignment_and_status_record');
    try {
		this.assign_cntrlr.save_assignment(params);
		} catch (any e) {
			local.exception_1 = true;
		}
		
		var elg_form_record = createobject("component", "models.elg_form").find_one(site_number = SITE_NUMBER_1,
			subject_number = SUBJECT_NUMBER_1, alpha_code = ALPHA_CODE_1);
		assertEquals(0, elg_form_record.RecordCount);

		try {
		var participant_record = createobject("component", "models.participant")
			.find_participant_by_subject_number_and_alpha_code(subject_number = SUBJECT_NUMBER_1,
				alpha_code = ALPHA_CODE_1, site_number = SITE_NUMBER_1);
		} catch (any e) {
			local.exception_2 = true;
		}

		assertTrue(local.exception_1 AND local.exception_2);
	}
	

	function save_assignment_success() {
		init_db();
		
		var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=GOOD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
      
    session.user.site_number = SITE_NUMBER_1;
    session.user.utc_offset = UTC_OFFSET;
    session.user.name = USER_NAME;
    	    
    injectMethod(this.assign_cntrlr, this, 'get_next_available_item_id_mock', 'get_next_available_item_id');
    var assignment_id_created = this.assign_cntrlr.save_assignment(params).assignment_id;
		assertTrue(isnumeric(assignment_id_created));
		
		var elg_form_record = createobject("component", "models.elg_form").find_one(site_number = SITE_NUMBER_1,
			subject_number = SUBJECT_NUMBER_1, alpha_code = ALPHA_CODE_1);
		assertEquals(1, elg_form_record.RecordCount);
			
		var elg_form_responses = createobject("component", "models.elg_form_response")
			.find_all_by_elg_form_id(elg_form_record.id);
		assertEquals(2, elg_form_responses.RecordCount);
		
		var participant_record = createobject("component", "models.participant")
			.find_participant_by_subject_number_and_alpha_code(subject_number = SUBJECT_NUMBER_1,
				alpha_code = ALPHA_CODE_1, site_number = SITE_NUMBER_1);
		assertTrue(isnumeric(participant_record.id));
		
		var assignment_record = createobject("component", "models.assignment").init(assignment_id_created);
		assertEquals(assignment_id_created, assignment_record.id);
		
		//nvd, bad bad bad
		var item_status_record = createobject("component", "models.item_status").find_by_item_id(assignment_record.item_id);
		assertEquals(2, item_status_record.status_id);
	}

	
  // Simple test to determine if errors are returned.
  function check_elibigility_has_errors() {
    init_db();
    var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=BAD_RESPONSE_1, question_2=BAD_RESPONSE_2};
    session.user.site_number = SITE_NUMBER_1;

    var result = createObject('component', 'controllers.assignments').check_randomization_eligibility(params);
    assertEquals(2, ArrayLen(result.errors));
  }


  function check_elibigility_has_success() {
    init_db();
    var params = {subject_number=SUBJECT_NUMBER_1, alpha_code=ALPHA_CODE_1, 
      question_1=GOOD_RESPONSE_1, question_2=GOOD_RESPONSE_2};
    session.user.site_number = SITE_NUMBER_1;

    var result = createObject('component', 'controllers.assignments').check_randomization_eligibility(params);
    assertEquals(0, ArrayLen(result.errors));
  }
	
	
	function save_assignment_lock_timeout() {
		as_ctrlr = createObject('component', 'controllers.assignments').init();
		injectMethod(as_ctrlr, this, 'create_assignment_mock_with_sleep', 'create_assignment');		
		
		thread action="run" name="myThread1" {
			try {
			 WriteOutput(as_ctrlr.save_assignment({}).message);
 			} catch(any e) {
 				
 					WriteOutput(e.message);
 			}
		}

		thread action="run" name="myThread2" {
			try {
				WriteOutput(as_ctrlr.save_assignment({}).message);
 			} catch(any e) {
 				WriteOutput(e.message);
 			}
		}
	
		thread action="join" name="myThread1,myThread2";	

		var error_message = 'Assignment error: It appears that the form was submitted more than once.'; 

		if(!((error_message IS trim(cfthread.myThread1.output)) OR (error_message IS trim(cfthread.myThread2.output)))){
			fail('Should have received lock exception for timeout.');
		}
	}


	private function create_assignment_mock_with_sleep() {
		var ctrlr = createObject('component', 'controllers.assignments').init();
		var timeout_milliseconds = (ctrlr.LOCK_TIMEOUT_SECONDS + 2) * 1000;
		sleep(timeout_milliseconds);
	}
	

	private function next_available_item_id() {
		return 6781;
	}
	
	
	private function get_next_available_item_id_mock () {
		var item = createobject("component", "models.item").create({site_id = 5678, 
			package_definition_id = 272, lot_id = 28956, number = 3222,
    	user_name = 'mxunit_assignments_test'});
    
    return item.id;
	}
	
	
	private function get_next_available_item_id_mock_throw_exception() {
		throw(type = "custom", message = "mock inventory exception"); 
	}
	
	
	private function create_assignment_and_status_record_mock_throw_exception() {
		throw(type="weird", message="weird mock exception");
	}
		
		
  private function init_db() {
    var alpha_code = createObject("component", "models.alpha_code");
    alpha_code.delete_one(site_number=SITE_NUMBER_1, subject_number=SUBJECT_NUMBER_1, 
      alpha_code=ALPHA_CODE_1);
    alpha_code.create({'site_number'=SITE_NUMBER_1, 'subject_number'=SUBJECT_NUMBER_1, 
      'alpha_code'=ALPHA_CODE_1});

    var elg_question = createObject("component", "models.elg_question");
    elg_question.delete_all();
    elg_question.create({'id'=ID_1, 'elg_question_type_id'=1, 'text'='Is this a question?', 
      'question_number'=QUESTION_NUMBER_1, 'elg_question_type_option_id_success'=GOOD_RESPONSE_1, 
      'error_message'=ERROR_MESSAGE_1, 'user_name'='mxunit'});
    elg_question.create({'id'=ID_2, 'elg_question_type_id'=1, 'text'='Is this not a question?', 
      'question_number'=QUESTION_NUMBER_2, 'elg_question_type_option_id_success'=GOOD_RESPONSE_2, 
      'error_message'=ERROR_MESSAGE_2, 'user_name'='mxunit'});

    var stmt = new query(name='qry', datasource=application.dsn);
    stmt.setSql("
      INSERT [iwrs_users] ([user_name], [first_name], [last_name], [email], [site_number], [is_locked], 
      [authorized_at], [authorized_by], [role_id], [all_site_access], [can_manage_users], [can_unblind], [is_crpcc], 
      [current_session_id], [created_at], [updated_at], [updated_by]) 
      VALUES (N'" & USER_NAME & "', N'na', N'van', N'nathan.vandelinder@va.gov', N'301', 
      0, CAST(N'2017-05-22T00:00:00.000' AS DateTime), N'me', 2, 1, 1, 1, 1, NULL, CAST(N'2017-05-22T20:48:52.463' AS DateTime), 
      CAST(N'2017-05-22T20:48:52.463' AS DateTime), N'nvd')
    ");
    stmt.execute();
  }
  
}