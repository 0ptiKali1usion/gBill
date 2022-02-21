<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the date selector for cancelled accounts. --->
<!---	4.0.0 09/07/99 --->
<!--- cancelacc.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 6 
	</cfquery>
</cfif>
<cfif IsDefined("Report.x")>
	<cfset Date1 = CreateDate(FromYear, FromMon, FromDay)>
	<cfset Date2 = CreateDate(ToYear,ToMon,ToDay)>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfquery name="getaccounts" datasource="#pds#">
		INSERT INTO GrpLists 
		(LastName, FirstName, City, AccountID, Phone, Company, ReportDate, ReportHeader, ReportID, 
		AdminID, ReportTitle, CreateDate) 
		Select A.LastName, A.FirstName, A.City, A.AccountID, A.Dayphone, A.Company, A.CancelDate, 
		A.CancelReason, 6, #MyAdminID#, 'Cancelled between #LSDateFormat(Date1, '#DateMask1#')# and #LSDateFormat(Date2, '#DateMask1#')#', #Now()# 
		FROM Accounts A 
		WHERE A.CancelDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
		AND A.CancelDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
		AND A.CancelYN = 1 
	</cfquery>
	<cfset SendReportID = 6>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "cancelacc.cfm">
	<cfset SendHeader = "Name,City,Cancel Date,Reason">
	<cfset SendFields = "Name,City,ReportDate,ReportHeader">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 6
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(CancelDate) as MinDate 
	FROM Accounts 
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
<title>View Cancelled Accounts</TITLE>
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
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Cancelled Accounts</font></th>
	</tr>
</cfoutput>
	<cfif CheckFirst.Recordcount Is 0>
		<cfoutput>
		<form name="getdate" method=post action="cancelacc.cfm?RequestTimeout=500" onsubmit="return checkdates();MsgWindow()">
			<tr>
				<td bgcolor="#thclr#" align=center colspan=2>Select Date Range for report</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align=right>From</td>
		</cfoutput>
				<td><Select name="FromMon" onChange="getdays()">
					<cfloop index="B5" From="01" To="12">
						<cfif B5 lt 10><cfset B5 = "0" & "#B5#"></cfif>
						<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
					</cfloop>
				</select><SELECT name="FromDay">
					<cfloop index="B5" From="01" To="#NumDays#">
						<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
						<cfoutput><option value="#B5#">#b5#</cfoutput>
					</cfloop>
				</select><SELECT name="FromYear" onChange="getdays()">
					<cfloop index="B4" from="#yy2#" to="#yyy#">
						<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
					</cfloop>
				</select></td>
			</tr>
	<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align=right>To:</td>
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
			<tr>
				<th colspan=2><input type="image" name="Report" src="images/lookup.gif" border="0"></td>
			</tr>
		</form>
	</cfoutput>
<cfelse>
	<cfoutput>
		<tr>
			<td bgcolor="#tbclr#" colspan="2">There is already a cancelled customers list.</td>
		</tr>			
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="6">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="cancelacc.cfm">
				<input type="hidden" name="SendHeader" value="Name,City,Cancel Date,Reason">
				<input type="hidden" name="SendFields" value="Name,City,ReportDate,ReportHeader">
				<th><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
		</form>
			<form method="post" action="cancelacc.cfm">
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
   