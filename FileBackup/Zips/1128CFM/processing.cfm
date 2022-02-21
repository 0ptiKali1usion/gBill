<cfsetting showdebugoutput="no">
<html>
<head>
<title>Processing ...</title>
</head>
<cfoutput>
<body #colorset# onblur="self.close()">
<center>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Processing ...</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">Please stand by.</td>
	</tr>
</table>
</cfoutput>
</center>
</body>
</html>
