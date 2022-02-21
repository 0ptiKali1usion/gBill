<cfsetting enablecfoutputonly="Yes">
<!--- Version 3.2.0 --->
<!--- This is the custom error page. --->
<!--- 3.2.0 09/08/98 --->
<!--- requesterror.cfm --->
<!--- Add a different error page to kill the forever looping --->

<cferror template="requestanerr.cfm" type="request">
<cfparam name="cfmpath" default="#GetDirectoryFromPath(CF_TEMPLATE_PATH)#">
<cfset #pagename# = ReplaceNoCase("#form.Template#","#cfmpath#", "")>

<cfquery name="getname" datasource="#pds#">
	SELECT EMail FROM 
	Admin A, AccountsEMail E 
	WHERE A.AccountID = E.AccountID 
	AND E.PrEMail = 1 
	AND A.AdminID = #MyAdminID# 
</cfquery>

<cfquery datasource="#pds#">
	INSERT INTO ErrorLog (ErrDateTime, Addr, Template, Referrer, Browser, Diag, QString, email)
	VALUES (#CreateODBCDateTime(Now())#, '#form.remoteaddress#', '#form.template#', '#HTTP_REFERER#',
	'#form.browser#', '#FORM.diagnostics#','#form.querystring#','#getname.email#')
</cfquery>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Error</TITLE>
<cfinclude template="coolsheet.cfm"></head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">An error has occurred</font></th>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tdclr#"><font size="4">Error Diagnostic Information</font></td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#">Date/Time:</td>
		<td bgcolor="#tdclr#">#lsdateformat(Now(), '#datemask1#')# #timeformat(Now(), 'hh:mm tt')#</td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#">Browser:</td>
		<td bgcolor="#tdclr#">#form.Browser#</td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#">Remote Address:</td>
		<td bgcolor="#tdclr#">#form.remoteaddress#</td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#">Template:</td>
		<td bgcolor="#tdclr#">#pagename#</td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tbclr#">#form.QueryString# </td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tbclr#">#form.Diagnostics# </td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tbclr#">Please inform the <a href="Mailto:#form.MailTo#">site
administrator</a> that this error has occurred <br>(be sure to
include the contents of this page in your message to
the administrator).</td>
	</tr>
</table>
</center>
</cfoutput>
<br><br> 
<cfinclude template="footer.cfm">
</BODY>
</HTML>
    

