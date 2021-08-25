<cfoutput>
<input type="hidden" name="form_number" value="#session.user.name#-ts{#DATEFORMAT(NOW(),'yyyy-mm-dd')#T#TimeFormat(now(),'HH:mm:ss.l')#}"/>
</cfoutput>
