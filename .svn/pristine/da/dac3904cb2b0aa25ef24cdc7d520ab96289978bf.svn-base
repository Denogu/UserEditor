<cfoutput>
  <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
      <h4 class="modal-title">Change Site</h4>    
    </div> 

    <div class="modal-body">
        <form id="switch_site_form" name="switch_site" action="#application.url_root#/main.cfm/all_site_accesses/switch_site">
          <div class="form-group">
            <label for="new_site_number">Site</label>
            <input class="form-control" type="text" name="new_site_number" data-minlength="2" maxlength="3" data-error="You must provide your site number." required>
          </div>
          <hr />
          <input type="submit" class="btn btn-primary" name="submit_button" value="Change"/>
          <button type="button" class="btn btn-danger pull-right" id="cancel_button" data-dismiss="modal">Cancel</button>
        </form>
    </div>
  </div>
</cfoutput>
