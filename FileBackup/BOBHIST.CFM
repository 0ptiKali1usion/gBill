<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page displays the customers gBill history. --->
<!---	4.0.0 09/28/99 --->
<!--- bobhist.cfm --->

<cfif IsDefined("ReturnID")>
	<cfset AccountID = ReturnID>
</cfif>
<cfquery name="AdminCheck" datasource="#pds#">
	SELECT AdminID 
	FROM Admin 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif (GetOpts.BOBHist Is 1) AND (AdminCheck.RecordCount Is 0)>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfif (GetOpts.BOBAHist Is 1) AND (AdminCheck.RecordCount GT 0)>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="CheckFor" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 22 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfset CheckID = CheckFor.AccountID>
<cfif CheckID Is Not AccountID>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 22 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 22 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("Report.x")>
	<cfset Date1 = CreateDateTime(ToYear,ToMon,ToDay,23,59,59)>
	<cfset Date2 = CreateDateTime(FromYear,FromMon,FromDay,0,0,0)>
	<cfquery name="GetInfo" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="InsData" datasource="#pds#">
		INSERT INTO GrpLists 
		(ReportURLID2, AccountID, City, MemoField, ReportDate, 
		 ReportID, AdminID, ReportTitle, CreateDate) 
		SELECT B.BOBHistID, B.AccountID, B.Action, B.ActionDesc, B.ActionDate, 
		22, #MyAdminID#, 'gBill History for #GetInfo.FirstName# #GetInfo.LastName#', #Now()# 
		FROM BOBHist B 
		WHERE B.ActionDate <= #CreateODBCDateTime(Date1)#
		AND B.ActionDate > #CreateODBCDateTime(Date2)# 
		<cfif Action GT "0">
			AND B.Action = '#Action#'
		</cfif>
		AND B.AccountID = #AccountID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportStr = 'View E-Mail', 
		ReportURL = 'viewmail.cfm?BOBHistID=' 
		WHERE ReportID = 22 
		AND AdminID = #MyAdminID# 
		AND City = 'E-Mailed' 
	</cfquery>
	<cfquery name="CheckFor" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 22 
		AND AdminID = #MyAdminID# 
		AND City = 'E-Mailed' 
	</cfquery>
	<cfset SendReportID = 22>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "bobhist.cfm">
	<cfset ReturnID = AccountID>
	<cfset SendHeader = "Date,Time,Description">
	<cfset SendFields = "ReportDate,ReportTime,MemoField">
	<cfif CheckFor.RecordCount GT 0>
		<cfset SendHeader = ListAppend(SendHeader,"View")>
		<cfset SendFields = ListAppend(SendFields,"URL")>
	</cfif>
	
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfset Today = Now()>
<cfparam name="mmm2" default="#Month(Today)#">
<cfparam name="ddd2" default="#Day(Today)#">
<cfparam name="yyy2" default="#Year(Today)#">
<cfparam name="mmm" default="#Month(Today)#">
<cfparam name="ddd" default="#Day(Today)#">
<cfparam name="yyy" default="#Year(Today)#">
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID, AccountID 
	FROM GrpLists 
	WHERE ReportID = 22 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount GT 0>
	<cfquery name="CheckFor" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 22 
		AND AdminID = #MyAdminID# 
		AND City = 'E-Mailed' 
	</cfquery>
</cfif>
<cfif Not IsDefined("accountid")>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="GetID" datasource="#pds#">
			SELECT VariableValue 
			FROM TempValues 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 22 
			AND VariableName = 'AccountID' 
		</cfquery>
		<cfset AccountID = GetID.VariableValue>
		<cfquery name="RemoveID" datasource="#pds#">
			DELETE FROM TempValues 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 22 
			AND VariableName = 'AccountID' 
		</cfquery>
	<cfelse>
		<cfset AccountID = CheckFirst.AccountID>
	</cfif>
</cfif>
<cfquery name="BOBActions" datasource="#pds#">
	SELECT Action 
	FROM BOBHist 
	WHERE AccountID = #AccountID# 
	GROUP BY Action
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(ActionDate) as MinDate 
	FROM BOBHist 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDates = LowDate.MinDate>
<cfelse>
	<cfset StartDates = Now()>
</cfif>
<cfset mm2 = Month(StartDates)>
<cfset yy2 = Year(StartDates)>
<cfset dd2 = Day(StartDates)>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>gBill History Criteria</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
<cfinclude template="jsdates.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<cfoutput>
		<input type="hidden" name="accountid" value="#accountid#">
	</cfoutput>
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select criteria for gBill History</font></th>
	</tr>
</cfoutput>
<cfif BOBActions.Recordcount Is 0>
	<tr>
		<cfoutput>
			<th colspan="2" bgcolor="#tbclr#">There is no history currently for this person.</th>
		</cfoutput>
	</tr>
<cfelseif CheckFirst.Recordcount Is 0>
	<form name="getdate" method=post action="bobhist.cfm" onsubmit="return checkdates();MsgWindow()">
		<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>From</td>
		</cfoutput>
			<td><Select name="FromMon" onChange="getdays()">
				<cfloop index="B5" from="1" to="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B4" from="1" to="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="FromYear" onChange="getdays()">
				<cfloop index="B3" from="#yy2#" to="#yyy#">
					<cfoutput><option <cfif yyy is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>To</td>
		</cfoutput>
			<td><Select name="ToMon" onChange="getdays2()">
				<cfloop index="B5" from="1" to="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="ToDay">
				<cfloop index="B4" from="1" to="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif ddd is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B3" from="#yy2#" to="#yyy#">
					<cfoutput><option <cfif yyy is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<cfoutput>
		<tr>
			<th colspan=2><input type="image" name="Report" src="images/viewlist.gif" border="0"></th>
			<cfoutput>
				<input type="hidden" name="accountid" value="#AccountID#">
			</cfoutput>
		</tr>
	</form>
<cfelse>
		<cfoutput>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">There is already a gBill history report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="22">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="bobhist.cfm">
				<cfif CheckFor.RecordCount GT 0>
					<input type="hidden" name="SendHeader" value="Date,Time,Description,View">
					<input type="hidden" name="SendFields" value="ReportDate,ReportTime,MemoField,URL">
				<cfelse>
					<input type="hidden" name="SendHeader" value="Date,Time,Description">
					<input type="hidden" name="SendFields" value="ReportDate,ReportTime,MemoField">
				</cfif>
				<input type="Hidden" name="ReturnID" value="#AccountID#">
				<th><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="bobhist.cfm">
				<input type="hidden" name="accountID" value="#AccountID#">
				<th><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
			</form>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 