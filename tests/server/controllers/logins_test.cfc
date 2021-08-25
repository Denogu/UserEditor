component extends="mxunit.framework.TestCase" {

  USER_NAME = "test_user";
  EMAIL = "nathan.vandelinder@yahoo.com";
  HOURS_UNTIL_EXPIRE = 1;

  //Sample fake token.
  TEST_TOKEN = 22;


  public function setup() {
      var user = createObject("component", "models.user");
      makePublic(user, "create", "create");
      user.create(user_name = USER_NAME, first_name = "test_first_name", 
          last_name = "test_last_name", site_number = "999", 
          email = EMAIL, password="test_password", role_id = 1);   
  }


  public function teardown() {
    //Delete password history and user records.
    var selectStmt = new query(datasource = application.dsn);
    selectStmt.addParam(name = "user_name", value = USER_NAME);

    var selectQuery = selectStmt.execute(sql = "
      SELECT id 
      FROM iwrs_users
      WHERE user_name = :user_name
    ");

    var password_history = createObject("component", "models.user_password_history").init(createObject("component","utilities.password"));
    password_history.delete(selectQuery.getResult().id);

    var deleteStmt = new query(datasource = application.dsn);
    deleteStmt.addParam(name = "user_name", value = USER_NAME);
    deleteStmt.execute(sql = "
      DELETE 
      FROM iwrs_users
      WHERE user_name = :user_name
    ");
  }
  

  public function reset_password() {
    createObject("component", "controllers.logins").reset_password();    
  }


  public function reset_password_success() {
    params.user_name = USER_NAME;
    params.email = EMAIL;

    var response = createObject("component", "controllers.logins").reset_password(params);
    assertTrue(Find('reset link has been sent', response.message) GT 0); 
  }


  public function reset_password_bad_email() {
    params.user_name = USER_NAME;
    params.email = 'bad@bad.com';

    var response = createObject("component", "controllers.logins").reset_password(params);
    assertFalse(response.is_success); 
  }


  public function reset_password_bad_user_name() {
    params.user_name = USER_NAME & 'X';
    params.email = 'EMAIL';

    var response = createObject("component", "controllers.logins").reset_password(params);
    assertFalse(response.is_success);
    assert(Find('record not found', response.message) GT 0); 
  }


  public function update_password_form_failure() {
    set_token(TEST_TOKEN);
    params.token = "bad token";

    var response = createObject("component", "controllers.logins").update_password(params);
    assertFalse(response.is_success); 
  }


  public function update_password_success() {
    set_token(TEST_TOKEN);
    
    params.user_name = USER_NAME;
    params.password = "Mypassword1!";
    params.password_verification = "Mypassword1!";
    params.password_reset_token = TEST_TOKEN;


    var response = createObject("component", "controllers.logins").update_password(params);
    assertTrue(response.is_success); 
  }


  public function update_password_try_to_reuse_old_password() {
    set_token(TEST_TOKEN);
    params.user_name = USER_NAME;
    params.password = "Mypassword1!";
    params.password_verification = "Mypassword1!";
    params.password_reset_token = TEST_TOKEN;
    var response = createObject("component", "controllers.logins").update_password(params);
    assertTrue(response.is_success); 


    set_token(TEST_TOKEN);
    params.user_name = USER_NAME;
    params.password = "Mypassword1!2";
    params.password_verification = "Mypassword1!2";
    params.password_reset_token = TEST_TOKEN;
    response = createObject("component", "controllers.logins").update_password(params);
    assertTrue(response.is_success); 

    set_token(TEST_TOKEN);
    params.user_name = USER_NAME;
    params.password = "Mypassword1!";
    params.password_verification = "Mypassword1!";
    params.password_reset_token = TEST_TOKEN;
    var response = createObject("component", "controllers.logins").update_password(params);
    assertFalse(response.is_success); 
    assertEquals(response.message, "Password has already been used. Please choose a new password.");

    // Check that transaction rollback succeeded in controller.
    // Try to log in with previous password.
    user = createObject("component", "models.user").init_from_user_name(USER_NAME);
    makePublic(user, "authorize", "authorize");
    user.authorize("test_authorizer");
    assertTrue(createObject("component", "models.user").login(USER_NAME, "Mypassword1!2"));  
  }


  public function update_password_bad_token() {
    var BAD_TOKEN = 254;
    set_token(BAD_TOKEN);
    
    params.user_name = USER_NAME;
    params.password = "Mypassword1!";
    params.password_verification = "Mypassword1!";
    params.password_reset_token = TEST_TOKEN;


    var response = createObject("component", "controllers.logins").update_password(params);
    assertFalse(response.is_success); 
  }


  private function set_token(token) {
    var statement = new query(datasource = application.dsn);
    statement.execute(sql = '
        UPDATE iwrs_users
        SET password_reset_token = #token#,
          password_reset_token_expires_at = DATEADD("hh", 1, GETUTCDATE())'
          & "WHERE user_name = '#user_name#'");
  }
  
}