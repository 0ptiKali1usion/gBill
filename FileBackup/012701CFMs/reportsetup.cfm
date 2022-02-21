<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 01/23/01 --->
<!--- reportsetup.cfm --->

<cfinclude template="security.cfm">

<cfif IsDefined("MoveRightS") AND IsDefined("AvailSearch")>
	<cfif AvailSearch GT 0>
		<cfquery name="AddSales" datasource="#pds#">
			INSERT INTO ReportValues 
			(ReportID, AdminID, WizID, FieldName, ActiveYN, SortOrder) 
			SELECT 4, #MyAdminID#, WizID, BOBFieldName, 1, 1 
			FROM WizardSetup 
			WHERE WizID IN (#AvailSearch#)
		</cfquery>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="AddFields" datasource="#pds#">
				SELECT BOBFieldName 
				FROM WizardSetup 
				WHERE WizID IN (#AvailSearch#)
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'System',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following search criteria: #ValueList(AddFields.BOBFieldName)#.')
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftS") AND IsDefined("HaveSearch")>
	<cfif HaveSearch GT 0>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="AddFields" datasource="#pds#">
				SELECT BOBFieldName 
				FROM WizardSetup 
				WHERE WizID IN 
					(SELECT WizID 
					 FROM ReportValues 
					 WHERE RVID IN (#HaveSearch#)
					)
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'System',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following search criteria: #ValueList(AddFields.BOBFieldName)#.')
			</cfquery>
		</cfif>
		<cfquery name="AddSales" datasource="#pds#">
			DELETE FROM ReportValues 
			WHERE RVID IN (#HaveSearch#)
		</cfquery>
	</cfif>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT ReportID 
	FROM ReportSetup 
	WHERE ReportID = 4
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="AddIt" datasource="#pds#">
		INSERT INTO ReportSetup 
		(ReportID, AdminID, SaveOptYN)
		VALUES
		(4, #MyAdminID#, 0)
	</cfquery>
</cfif>
<cfquery name="GetExtraSearch" datasource="#pds#">
	SELECT V.FieldName, W.ScreenPrompt, V.RVID, W.WizID 
	FROM ReportSetup S, ReportValues V, WizardSetup W 
	WHERE S.ReportID = V.ReportID 
	AND V.WizID = W.WizID 
	AND S.ReportID = 4 
	AND V.ActiveYN = 1
	ORDER BY V.SortOrder 
</cfquery>
<cfquery name="AllSearch" datasource="#pds#">
	SELECT W.WizID, W.ScreenPrompt 
	FROM WizardSetup W 
	WHERE W.CFVarYN = 0 
	AND BOBFieldName <> 'WaiveA' 
	AND BOBFieldName <> 'WaiveAReason' 
	AND BOBFieldName <> 'SelectPlan' 
	AND BOBFieldName <> 'UserInfo' 
	AND BOBFieldName <> 'contactemail' 
	AND BOBFieldName <> 'postalinv' 
	AND BOBFieldName <> 'taxfree' 
	AND BOBFieldName <> 'creditcard' 
	AND BOBFieldName <> 'checkdebit' 
	AND BOBFieldName <> 'porder' 
	AND BOBFieldName <> 'checkcash' 
	AND BOBFieldName <> 'POPID' 
	AND BOBFieldName <> 'PromoCode' 
	AND BOBFieldName <> 'SalespersonID' 
	AND BOBFieldName <> 'Notes' 
	AND BOBFieldName <> 'Company' 
	AND BOBFieldName <> 'DayPhone' 
	AND W.ScreenPrompt <> ''
	AND W.ActiveYN = 1 
	AND W.WizID NOT IN 
		(SELECT W.WizID 
		 FROM ReportSetup S, ReportValues V, WizardSetup W 
		 WHERE S.ReportID = V.ReportID 
		 AND V.WizID = W.WizID 
		 AND S.ReportID = 4 
		 AND V.ActiveYN = 1)
	ORDER BY W.ScreenPrompt
</cfquery>
<cfset HowWide = 3>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfoutput><title>Customer Search Setup</title></cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Customer Search Setup</font></th>
	</tr>
	<tr bgcolor="#thclr#">
		<th colspan="#HowWide#">Customer Search Setup</th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Available</th>
		<th>Action</th>
		<th>Currently Added</th>
	</tr>
</cfoutput>
	<form method="post" action="reportsetup.cfm">
		<tr>
			<td align="center"><select name="AvailSearch" Multiple size=10>
				<cfoutput query="AllSearch">
					<option value="#WizID#">#ScreenPrompt#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
			<td align="center" valign="middle">
				<input type="submit" name="MoveRightS" value="---->"><br>
				<input type="submit" name="MoveLeftS" value="<----"><br>
			</td>
			<td align="center"><select name="HaveSearch" Multiple size=10>
				<cfoutput query="GetExtraSearch">
					<option value="#RVID#">#ScreenPrompt#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
		</tr>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 