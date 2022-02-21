<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Report of Staff gBill History --->
<!--- 4.0.0 10/08/99 --->
<!--- staff.cfm --->

<cfinclude template="security.cfm">

<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 23 
	</cfquery>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 23 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="Range" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, ReportDate, MemoField, ReportTab, 
			 TabType, ReportID, AdminID, ReportTitle, CreateDate) 
			SELECT A.LastName, A.FirstName, A.AccountID, B.ActionDate, B.ActionDesc, B.Action, 
			1, 23, #MyAdminID#, 'Staff gBill History', #Now()#  
			FROM Accounts A, Admin S, BOBHist B 
			WHERE B.AdminID = S.AdminID 
			AND S.AccountID = A.AccountID 
			AND B.AdminID Is Not Null 
			<cfif AdminID Is Not 0>
				AND B.AdminID In (#AdminID#) 
			</cfif>
			<cfif IsDefined("Action")>
				<cfif Action Is Not "0">
					<cfset LogicConnect = 1>
					AND (
					<cfloop index="B5" list="#Action#">
						<cfif LogicConnect Is 1><cfset LogicConnect = 2><cfelse>OR</cfif> B.Action Like '#B5#'
					</cfloop>
					)
				</cfif>
			</cfif>
			AND B.ActionDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
			AND B.ActionDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
		</cfquery>		
	</cfif>
	<cfset SendReportID = 23>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "staff.cfm">
	<cfset SendHeader = "Staff,Date,Time,Action">
	<cfset SendFields = "Name,ReportDate,ReportTime,MemoField">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfquery name="GetActionTypes" datasource="#pds#">
	SELECT Action 
	FROM BOBHist 
	WHERE Action Is Not Null 
	GROUP BY Action 
	ORDER BY Action
</cfquery>
<cfquery name="AllAdmins" datasource="#pds#">
	SELECT A.FirstName, A.LastName, S.AdminID 
	FROM Accounts A, Admin S 
	WHERE A.AccountID = S.AccountID 
	ORDER BY A.LastName, A.FirstName 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 23 
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(ActionDate) as MinDate 
	FROM BOBHist 
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
<title>Customer List</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="jsdates.cfm">
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onLoad="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">gBill History</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<cfoutput>
	<form method="post" name="getdate" action="staff.cfm" onsubmit="return checkdates();MsgWindow()">
		<tr bgcolor="#tdclr#" valign="top">
			<td bgcolor="#tbclr#" align=right>From</td>
	</cfoutput>
			<td><Select name="FromMon" onChange="getdays()">
				<cfloop index="B5" From="01" To="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B5" From="01" To="#NumDays#">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif B5 Is 1>selected</cfif> value="#B5#">#b5#</cfoutput>
				</cfloop>
			</select><SELECT name="FromYear" onChange="getdays()">
				<cfloop index="B4" from="#yy2#" to="#yyy#">
					<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select></td>
		<cfoutput>
			<td bgcolor="#tbclr#" align=right>To</td>
		</cfoutput>		
			<td><Select name="ToMon" onChange="getdays2()">
				<cfloop index="B5" From="01" To="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="ToDay">
				<cfloop index="B5" From="01" To="#NumDays#">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif ddd is B5>selected</cfif> value="#B5#">#b5#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B4" from="#yy2#" to="#yyy#">
					<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
	<cfoutput>
			<tr bgcolor="#thclr#">
				<th colspan="2">Staff</th>
				<th colspan="2">Action</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>
				<td colspan="2"><select name="AdminID" multiple size="10">
					<option selected value="0">All Staff
					<cfoutput query="AllAdmins">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="">______________________________				
				</select></td>
				<td colspan="2"><select name="Action" multiple size="10">
					<option selected value="0">View All
					<cfoutput query="GetActionTypes">
						<option value="#Action#">#Action#
					</cfoutput>
					<option value="">______________________________
				</select></td>
			</tr>
			<tr>
				<th colspan="4"><input type="image" name="CreateReport" src="images/viewlist.gif" border="0"></th>
			</tr>
		</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">This is already a Staff report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="23">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="staff.cfm">
				<input type="hidden" name="SendHeader" value="Staff,Date,Time,Action">
				<input type="hidden" name="SendFields" value="Name,ReportDate,ReportTime,MemoField">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="staff.cfm">
				<th colspan="2" width="50%"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
			</form>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 



