<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- about.cfm --->

<cfset dropby1 = 1>
<cfinclude template="license.cfm">
<cfif IsDefined("greensoft") is "No">
	<cfset maxuser = "1">
</cfif>
<cfquery name="GetHowMany" datasource="#pds#">
	SELECT count(AccountID) as CID 
	FROM Accounts 
	WHERE CancelYN = 0 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>About gBill</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Internet Back Office Billing</font></th>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Current License</td>
		<td bgcolor="#tbclr#">#MaxUser#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Current Count</td>
		<td bgcolor="#tbclr#">#GetHowMany.CID#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Server Name</td>
		<td bgcolor="#tbclr#">#servername1#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Server IP</td>
		<td bgcolor="#tbclr#">#serverip1#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">License Expires</td>
		<td bgcolor="#tbclr#">#expdate#</td>
	</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 