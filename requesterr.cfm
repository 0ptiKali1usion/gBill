<!--- Version 4.0.0 --->
<!--- This is the page that calls the custom error page whan an error occurs. --->
<!--- 4.0.0 09/29/99
		3.2.0 09/08/98 --->
<!--- requesterr.cfm --->

<html>
<head>
<title>Error</TITLE>
</head>
<body bgcolor="708090" onLoad="setTimeout('document.forms[0].submit();',50)">
<cfoutput>
<font size="5">One moment please...</font><br>
<form name="goon" method="post" action="requesterror.cfm">
<input type="hidden" name="remoteaddress" value="#error.remoteaddress#">
<input type="hidden" name="Template" value="#Error.Template#">
<input type="hidden" name="MailTo" value="#Error.MailTo#">
<input type="hidden" name="Browser" value="#Error.Browser#">
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
<textarea rows="1" cols="1" name="QueryString">#Error.QueryString#</textarea>
<textarea rows="1" cols="1" name="Diagnostics">#Error.Diagnostics#</textarea>
</form>
</cfoutput>
</BODY>
</HTML>
  

