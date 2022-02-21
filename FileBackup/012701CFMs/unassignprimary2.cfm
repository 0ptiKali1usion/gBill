<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 12/28/00 --->
<!--- unassignprimary2.cfm --->
<cfset SecurePage = "unassignprimary.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("UpdateSales.x")>
	<cfquery name="LoopList" datasource="#pds#">
		SELECT AccountID 
		FROM GrpLists 
		WHERE ReportID = 36 
		AND AdminID = #MyAdminID# 
		AND ReportTab = 'No Primary'
	</cfquery>
	<cfloop query="LoopList">
		<cfquery name="GetAnAddress" datasource="#pds#">
			SELECT Min(EMailID) as MEMailID 
			FROM AccountsEMail 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif GetAnAddress.MEMailID Is Not "">
			<cfquery name="SetPrimary" datasource="#pds#">
				UPDATE AccountsEMail SET 
				PrEMail = 1 
				WHERE EMailID = #GetAnAddress.MEMailID# 
			</cfquery>
			<cfquery name="RemoveList" datasource="#pds#">
				DELETE FROM 
				GrpLists 
				WHERE ReportID = 36 
				AND AdminID = #MyAdminID# 
				AND AccountID = #AccountID# 
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfquery name="CheckNow" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 36 
	AND AdminID = #MyAdminID# 
	AND ReportTab = 'No Primary'
</cfquery>
<cfquery name="CheckNow2" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 36 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckForMore" datasource="#pds#">
	SELECT AccountID 
	FROM Accounts 
	WHERE AccountID NOT In 
		(SELECT AccountID 
		 FROM AccountsEMail 
		 WHERE PrEMail = 1) 
	AND AccountID In 
		(SELECT AccountID 
		 FROM AccountsEMail)
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Assign A Primary</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif CheckNow2.RecordCount GT 0>
	<form method="post" action="grplist.cfm">
		<input type="Image" src="images/viewlist.gif" name="GoBack" border="0">
		<input type="Hidden" name="SendReportID" value="36">
		<input type="Hidden" name="SendLetterID" value="0">
		<input type="Hidden" name="SendHeader" value="Name,Address,Company,Phone">
		<input type="Hidden" name="SendFields" value="Name,Address,Company,Phone">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Problem EMail</font></th>
	</tr>
</cfoutput>
	<cfif CheckNow.RecordCount GT 0>
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#">Everyone listed on the report with no primary address will be assigned an EMail address as their primary.</td>
			</tr>
			<form method="post" action="unassignprimary2.cfm">
				<tr>
					<th><input type="Image" name="UpdateSales" src="images/update.gif" border="0"></th>
				</tr>
			</form>
		</cfoutput>
	<cfelse>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">You have assigned all the selected EMail addresses.
				<cfif CheckForMore.RecordCount GT 0><br><a href="unassignprimary.cfm">Create New List</a></cfif></td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
