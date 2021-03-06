<cfoutput>
<cfif isDefined('session.user')>
  <cfif session.user.is_crpcc>
    <nav class="navbar navbar-default navbar-static-top ">
        <div class="container-fluid">

            <div class="navbar-header">            	
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="##myNavbar">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span> 
                </button>                
            </div>

            <div class="collapse navbar-collapse" id="myNavbar">  
                <cfif  createObject('component', 'utilities.session_utilities').is_session_current()>
                    <cfinclude template="./_logged_in_menu.cfm">          
                <cfelse>
                    <ul class="nav navbar-nav navbar-right">
                        <li>
                            <a href="../logins/login_form">
                                <span class="glyphicon glyphicon-log-in"></span> Sign in
                            </a>
                        </li>
                        <li>
                            <a href="../logins/registration_form">
                                <span class="glyphicon glyphicon-user"></span> Register
                            </a>
                        </li>
                    </ul>
                </cfif>                  
            </div>

        </div>
    </nav>

  </cfif>
  </cfif>
</cfoutput>
