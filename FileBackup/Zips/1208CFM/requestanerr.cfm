<!--- Version 4.0.0 --->
<!--- This is the page that calls the custom error page whan an error occurs. --->
<!--- 4.0.0 09/29/99
		3.2.0 09/08/98 --->
<!--- requestanerr.cfm --->

<html>
<head>
<title>Error</TITLE>
</head>
<body bgcolor="ffffff">
<cfoutput>
<table border ="3">
	<tr>
		<td>Error Page</td>
		<td>#Error.Template#</td>
	</tr>
	<tr>
		<td>Query String</td>
		<td>#Error.QueryString#&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">#Error.Diagnostics#&nbsp;</td>
	</tr>
</table>
</cfoutput>
</BODY>
</HTML>
        