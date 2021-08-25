<cfset req = createObject("core.request").init(cgi,url,form)>
<cfset req.dispatch()>
