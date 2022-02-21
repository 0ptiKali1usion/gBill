<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/22/99 --->
<!--- group.cfm --->
<cfif GetOpts.ViewOther Is 1>
	<cfset securepage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT MultiID 
	FROM Multi 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="CheckGroups" datasource="#pds#">
	SELECT MultiID 
	FROM Multi 
	WHERE BillTo = 1 
</cfquery>

<cfsetting enablecfoutputonly="no">
<cfif CheckFirst.Recordcount Is 0>
<html>
<head>
<title>Group Accounts</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
	</cfoutput>
</form>
<center>
<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Group Accounts</font></th>
		</tr>
		<form method="post" action="group4.cfm">
			<tr>
				<td bgcolor="#tdclr#"><input type="radio" name="SetupType" value="0" onclick="submit()"></td>
				<td bgcolor="#tbclr#">Make this account the primary and add accounts to this group.</td>
			</tr>
			<input type="hidden" name="AccountID" value="#AccountID#">
		</form>
		<cfif CheckGroups.Recordcount GT 0>
			<form method="post" action="group3.cfm">
				<tr>
					<td bgcolor="#tdclr#"><input type="radio" name="SetupType" value="1" onclick="submit()"></td>
					<td bgcolor="#tbclr#">Make this account part of an existing group.</td>
				</tr>
				<input type="hidden" name="AccountID" value="#AccountID#">
			</form>
		</cfif>
	</cfoutput>
	</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
<cfelse>
	<cfinclude template="group2.cfm">
</cfif>
 