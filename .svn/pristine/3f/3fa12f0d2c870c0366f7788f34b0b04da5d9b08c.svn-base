<cfoutput>
<cfif isDefined('session.user')>
<cfif session.user.is_crpcc>
    <!--- Row containing logo/title on left and user/site info on right. --->
    <div class="row" style="margin-top: 0.2em;"> 

        <div class="col-sm-6">        	
        <div class="pull-left"> 
                <span class="text-nowrap">         
                    <a href="../logins/welcome" 
                        style="font-size: 2.2em; color: ##286090; font-weight: bold; text-decoration: none;">
                        <img src="#application.url_root#/images/bowl_of_hygeia.png" alt="Bowl Of Hygeia" height="70" width="70"/>
                            #application.study_acronym# IWRS
                    </a>
                </span>
            </div> 
        </div>

        <div class="col-sm-6">
            <div class="pull-right" style="padding-top: 1em;">

                <cfif createObject('component', 'utilities.session_utilities').is_session_current()>
                    <div class="row">        
                        <div class="col-sm-12">
                            <span class="text-nowrap  text-uppercase" id="user_name">
                                <b>#session.user.first_name#&nbsp;#session.user.last_name#</b>
                            </span>
                            <br/> 
                        </div>
                    </div>
                    
                    <div class="row text-nowrap">
                        <div class="col-sm-12"> 
                            <cfif NOT createObject("component", "models.role").init(session.user.role_id).is_study_team() 
                                OR session.user.is_crpcc>
                                <span class="text-nowrap" id="user_site_number">
                                    <b>Site: #session.user.site_number#&nbsp;</b>
                                </span>
                            </cfif>
                            
                            <!--- <cfif isdefined('session.user.all_site_access') AND session.user.all_site_access>
                                (<a href="#application.url_root#/main.cfm/all_site_accesses/switch_site_form?current_site=#session.user.site_number#" 
                                    id="switch_site_link_admin" data-toggle="modal" data-target="##switch_site_form_modal_admin" 
                                    data-backdrop="static">change</a>)                                                              
                            </cfif> --->
                            
                            <a id="switch_site_link_user" href="../all_site_accesses/site_dropdown" 
                            class="btn btn-default" data-toggle="modal" data-target="##switch_site_form_modal_user">Switch</a>
                        </div>
                    </div>
                </cfif>

            </div>
        </div>

    </div>

</cfif>
</cfif>        
</cfoutput>
