<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- unassigned.cfm --->
<cfset SecurePage = "unassigned.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("UpdateSales.x")>
	<cfquery name="UpdSalesID" datasource="#pds#">
		UPDATE Accounts SET 
		SalesPersonID = #SalesPID# 
		WHERE 
			(SalesPersonID Is Null 
			 OR 
			 SalesPersonID = 0) 
		AND AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 31 
			 AND AdminID = #MyAdminID#) 		
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 31 
		AND AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 31 
			 AND AdminID = #MyAdminID#) 		
	</cfquery>
</cfif>
<cfquery name="GetSalesPeople" datasource="#pds#">
	SELECT A.FirstName, A.LastName, S.AdminID 
	FROM Accounts A, Admin S 
	WHERE A.AccountID = S.AccountID 
	AND S.SalesPersonYN = 1 
	ORDER BY A.LastName, A.FirstName 
</cfquery>

<cfquery name="CheckNow" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 31 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckForMore" datasource="#pds#">
	SELECT AccountID 
	FROM Accounts 
	WHERE SalesPersonID Is Null 
	OR SalesPersonID = 0 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Assign Salesperson</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif CheckNow.RecordCount GT 0>
	<form method="post" action="grplist.cfm">
		<input type="Image" src="images/viewlist.gif" name="GoBack" border="0">
		<input type="Hidden" name="SendReportID" value="31">
		<input type="Hidden" name="SendLetterID" value="0">
		<input type="Hidden" name="SendHeader" value="Name,Address,Company,Phone">
		<input type="Hidden" name="SendFields" value="Name,Address,Company,Phone">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Assign Salesperson</font></th>
	</tr>
</cfoutput>
	<cfif CheckNow.RecordCount GT 0>
		<cfoutput>
		<tr>
			<td bgcolor="#tbclr#">Everyone listed on the report will be assigned to the salesperson you select below.</td>
		</tr>
		<form method="post" action="unassigned2.cfm">
			<tr bgcolor="#tdclr#">
		</cfoutput>
				<td><select name="SalesPID">
					<cfoutput query="GetSalesPeople">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
				</select></td>		
			</tr>
			<tr>
				<th><input type="Image" name="UpdateSales" src="images/update.gif" border="0"></th>
			</tr>
		</form>
	<cfelse>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">You have assigned all the selected signups.
				<cfif CheckForMore.RecordCount GT 0><br><a href="unassigned.cfm">Create New List</a></cfif></td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
