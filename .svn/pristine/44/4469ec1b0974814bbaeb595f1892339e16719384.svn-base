<div class="form-group has-feedback">
  <label for="user_name" class="control-label">Username</label>
    <input class="form-control" type="text" name="user_name" data-minlength="3" 
      data-error="You must provide a username." required>
  <span class="glyphicon form-control-feedback"></span>
  <div class="help-block with-errors"></div>
</div>
  
<div class="help-block">
  Password must contain at least:
  <ul>
    <li>8 characters</li>
    <li>One lower-case letter</li>
    <li>One upper-case letter</li>
    <li>One number</li>
    <li>One special character ~!@##$%^&*()-+=[]</li>
  </ul>
</div>

<div class="form-group has-feedback">
  <label for="password" class="control-label">Password</label>  
  <input type="password" pattern="(?=^.{8,}$)((?=.*\d)(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$" 
    class="form-control" name="password" id="password" placeholder="Password" 
      data-error="You must provide a valid password." required style="width: 100%;">
  <span class="glyphicon form-control-feedback" style="padding-right: 30px;"></span>
  <div class="help-block with-errors"></div>
</div>
    
<div class="form-group has-feedback">
  <label for="password_verification" class="control-label">Verify password</label> 
    <input type="password" class="form-control" name="password_verification" id="password_verification" 
      data-match="#password" data-match-error="Must match password" placeholder="Confirm password" required style="width: 100%;">
    <span class="glyphicon form-control-feedback" style="padding-right: 30px;"></span>
    <div class="help-block with-errors"></div>
</div>