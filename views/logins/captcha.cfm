<cfinvoke component="utilities.captcha" method="random_captcha_string" returnvariable="captcha_string"></cfinvoke>
<cfset session.captcha = captcha_string><!--- Shouldn't need to lock this since this is the only place we are writing to the session variable. --->

<div>
  <cfimage action="captcha" text="#session.captcha#" difficulty="medium" fontSize="25" width="225" height="80" 
    style="display: inline-block; vertical-align: middle;">
  <span class="ui-state-default ui-corner-all" style="padding: 4px 5px 0px 5px; vertical-align: bottom;">
    <a href="" id="new_captcha_link" style="display: inline-block;">
      <span class="glyphicon glyphicon-refresh"></span>
    </a>
  </span>
</div>