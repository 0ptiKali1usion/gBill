<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/22/99 --->
<!--- group3.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfquery name="GetGroups" datasource="#pds#">
	SELECT A.FirstName, A.LastName, A.Company, M.BillingID 
	FROM Accounts A, Multi M 
	WHERE A.AccountID = M.AccountID 
	AND M.BillTo = 1 
	ORDER BY A.LastName, A.FirstName 
</cfquery>

<cfsetting enablecfoutputonly="no">
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
		<th bgcolor="#ttclr#" colspan="3"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Group Accounts</font></th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Select</th>
		<th>Name</th>
		<th>Comapny</th>
	</tr>
</cfoutput>
<form method="post" action="group2.cfm">
	<cfoutput query="GetGroups">
		<tr bgcolor="#tbclr#">
			<th bgcolor="#tdclr#"><input type="radio" name="BillingID" value="#BillingID#" onclick="submit()"></th>
			<td>#LastName#, #FirstName#</td>
			<td>#Company#<cfif Trim(Company) Is "">&nbsp;</cfif></td>
		</tr>
	</cfoutput>
	<input type="hidden" name="AddTo" value="1">
	<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
