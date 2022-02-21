<cfsetting enablecfoutputonly="Yes">

<!--- Version 4.0.0 --->
<!--- 4.0.0 11/22/00 --->
<!--- reportamounts.cfm --->

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Transaction Check</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Select settings</font></th>
	</tr>
	<form method="post" action="reportamounts2.cfm">
		<tr>
			<td bgcolor="#tbclr#" align="right">Report Only</td>
			<td bgcolor="#tdclr#"><input type="Radio" checked name="UpdateAmounts" value="1"></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">Report and Update</td>
			<td bgcolor="#tdclr#"><input type="Radio" name="UpdateAmounts" value="0"></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">Use this Customer UserID</td>
			<td bgcolor="#tdclr#"><input type="Text" name="UserID" size="5xfs"></td>
		</tr>
		<tr>
			<th colspan="2"><input type="Submit" name="MakeItSo" value="Run"></th>
		</tr>
	</form>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
