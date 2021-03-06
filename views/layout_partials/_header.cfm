<cfoutput>
  <head>
    <!-- The following 3 meta tags must come first in the header; any other header content must come after these tags. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>#application.study_acronym# IWRS</title>
    <link rel="shortcut icon" type="image/png" href="#application.url_root#/images/bowl_of_hygeia.ico">
    <link rel="stylesheet" href="#application.url_root#/javascript/libraries/Bootstrap-3.3.7/css/bootstrap.min.css" >
    
    
     <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]> 
      <script src="#application.url_root#/javascript/libraries/Bootstrap-3.3.7/js/html5shiv.min.js"></script>
      <script src="#application.url_root#/javascript/libraries/Bootstrap-3.3.7/js/respond.min.js"></script>       
    <![endif] -->
    
    
    <link rel="stylesheet" type="text/css" href="#application.url_root#/javascript/libraries/DataTables-1.10.13/css/dataTables.bootstrap.css"/>
    <link rel="stylesheet" type="text/css" href="#application.url_root#/javascript/libraries/Buttons-1.2.4/css/buttons.bootstrap.css"/>
    <link rel="stylesheet" type="text/css" href="#application.url_root#/javascript/libraries/bootstrap-datepicker-1.6.4-dist/css/bootstrap-datepicker3.css"/>
    <link rel="stylesheet" type="text/css" href="#application.url_root#/stylesheets/main.css" media="screen" />
     
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/jQuery-2.2.4/jquery-2.2.4.min.js"></script>    
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Bootstrap-3.3.7/js/bootstrap.min.js"></script> 
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/DataTables-1.10.13/js/jquery.dataTables.min.js"></script>    
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/DataTables-1.10.13/js/dataTables.bootstrap.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/dataTables.buttons.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/buttons.bootstrap.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/buttons.flash.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/jszip.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/pdfmake.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/vfs_fonts.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/buttons.html5.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/Buttons-1.2.4/js/buttons.print.min.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/bootstrap-datepicker-1.6.4-dist/js/bootstrap-datepicker.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/bootstrap-validator/js/validator.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/timeout-dialog/js/timeout-dialog.js"></script>
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/moment/min/moment.min.js"></script> 
    <script type="text/javascript" src="#application.url_root#/javascript/libraries/datetime-moment.js"></script> 

    <script type="text/javascript" src="#application.url_root#/javascript/main.js"></script>
	
    <!--- The controller_name and action_name variables are defined in index.cfm. --->
    <cfset js_file_path = "javascript/#controller_name#/#action_name#.js">

    <!--- Tries to load a JavaScript file that corresponds with the request. --->
    <cfif FileExists('#application.rootDirectory##js_file_path#')>
    	<script type="text/javascript" src="#application.url_root#/#js_file_path#"></script> 
    </cfif>
	 
  </head>
</cfoutput>
