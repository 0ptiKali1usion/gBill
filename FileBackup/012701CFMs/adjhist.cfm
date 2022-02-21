<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a report of all adjustments from a selected date range. --->
<!--- 4.0.0 09/10/99
		3.2.0 09/08/98 --->
<!--- adjhist.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 13 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("Report.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 13 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset Date1 = CreateDate(FromYear,FromMon,FromDay)>
		<cfset Date2 = CreateDate(ToYear,ToMon,ToDay)>
		<cfquery name="GetLocale" datasource="#pds#">
			SELECT Value1, VarName 
			FROM Setup 
			WHERE VarName In ('Locale','DateMask1')
		</cfquery>
		<cfloop query="GetLocale">
			<cfset "#VarName#" = Value1>
		</cfloop>
		<cfquery name="allcredits" datasource="#PDS#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, ReportDate, CurBal, CurBal2, ReportHeader, 
			 ReportID, AdminID, ReportTitle, CreateDate) 	
			SELECT A.LastName, A.FirstName, A.AccountID, T.DateTime1, T.Credit, T.debit, 
			T.MemoField, 13, #MyAdminID#, 'Financial Adjustment Report - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', #Now()# 
			FROM Transactions T, Accounts A 
			WHERE T.AccountID = A.AccountID 
			AND T.Datetime1 < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
			AND T.Datetime1 > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
			AND T.AdjustmentYN = 1 
		</cfquery>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 13 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdCredits" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Credit' 
		WHERE ReportID = 13 
		AND AdminID = #MyAdminID# 
		AND CurBal > 0 
	</cfquery>
	<cfquery name="UpdCredits" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Debit' 
		WHERE ReportID = 13 
		AND AdminID = #MyAdminID# 
		AND CurBal2 > 0 
	</cfquery>
	<cfset SendReportID = 13>
	<cfset SendLetterID = 13>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 13 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "adjhist.cfm">
	<cfset SendHeader = "Name,Date,Credit,Debit,Memo,E-Mail">
	<cfset SendFields = "Name,ReportDate,CurBal,CurBal2,ReportHeader,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 13 
	AND AdminID = #MyAdminID#  
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(DateTime1) as MinDate 
	FROM Transactions 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDates = LowDate.MinDate>
<cfelse>
	<cfset StartDates = Now()>
</cfif>
<cfset mm2 = Month(StartDates)>
<cfset yy2 = Year(StartDates)>
<cfset dd2 = Day(StartDates)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Adjustments Report</TITLE>
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
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Adjustment Report</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<form name="getdate" method=post action="adjhist.cfm" onsubmit="return checkdates();MsgWindow()">
		<cfoutput>
		<tr>
			<th bgcolor="#thclr#" colspan=2>Select date range for report</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>From</td>
		</cfoutput>
			<td><Select name="FromMon" onChange="getdays()">
				<cfloop index="B5" from="1" to="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B4" from="1" to="#Numdays#">
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
				<cfloop index="B4" from="1" to="#Numdays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif ddd is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B3" from="#yy2#" to="#yyy#">
					<cfoutput><option <cfif yyy is "#B3#">Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<tr>
			<th colspan=2><input type="image" name="Report" src="images/viewlist.gif" border="0"></th>
		</tr>
	</form>
<cfelse>
		<cfoutput>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">There is already an adjustment report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="13">
				<input type="hidden" name="SendLetterID" value="13">
				<input type="hidden" name="ReturnPage" value="adjhist.cfm">
				<input type="hidden" name="SendHeader" value="Name,Date,Credit,Debit,Memo,E-Mail">
				<input type="hidden" name="SendFields" value="Name,ReportDate,CurBal,CurBal2,ReportHeader,EMail">
				<th><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="adjhist.cfm">
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
      