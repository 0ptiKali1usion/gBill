<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that searches the deposits. --->
<!---	4.0.0 09/13/99 --->
<!--- depositsearch.cfm --->

<cfset securepage="deposithist.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 15 
		AND AdminID = #MyAdminID#
	</cfquery>
</cfif>
<cfif IsDefined("ShowReport.x")>
	<cfquery name="SearchResults" datasource="#pds#">
		INSERT INTO GrpLists 
		(ReportDate, ReportStr, ReportURLID2, FirstName, LastName, AccountID, ReportDate2,CurBal,
		 ReportTab,City,ReportID,AdminID,ReportTitle,ReportURL, CreateDate) 
		SELECT DepositDate,DepositNumber,DepositNumID,FirstName,LastName,AccountID,PaymentDate,PayAmount,
		PayType,ChkNumber,15,#MyAdminID#,'Deposit History Search Results','deposithist2.cfm?DepositNumID=', #Now()# 
		FROM DepositHist 
		WHERE PaymentDate <= {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
		AND PaymentDate >= {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
		<cfif Trim(AmountLook) Is Not "">
			AND PayAmount <cfif AmountDir Is "GT">><cfelse><</cfif> #AmountLook#
		</cfif>
		AND #FieldSearch# Like 
		<cfif FieldType Is "Starts">'#FieldLook#%'
		<cfelseif FieldType Is "Contains">'%#FieldLook#%'
		<cfelseif FieldType Is "Like">'#FieldLook#'
		</cfif>
	</cfquery>
	<cfset SendReportID = 15>
	<cfset SendLetterID = 0>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 10 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "depositsearch.cfm">
	<cfset SendHeader = "Deposit Number,Name,Payment Date,Amount,Payment Type,Chk No.">
	<cfset SendFields = "URL,Name,ReportDate2,CurBal,ReportTab,City">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 15
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(PaymentDate) as MinDate 
	FROM DepositHist 
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
<title>Deposit History Search</title>
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
<form method="post" action="deposithist.cfm" name="Return">
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Deposit Search</font></th>
	</tr>
</cfoutput>
	<cfif CheckFirst.Recordcount Is 0>
		<cfoutput>
		<form method="post" action="depositsearch.cfm" name="getdate" onsubmit="return checkdates();MsgWindow()">
			<tr bgcolor="#tdclr#">
				<td align="right"><select name="FieldSearch">
					<option value="LastName">Last Name
					<option value="FirstName">First Name
					<option value="ChkNumber">Check Number
				</select></td>
				<td><input type="radio" checked name="FieldType" value="Starts">Starts <input type="radio" name="FieldType" value="Contains">Contains <input type="radio" name="FieldType" value="Like">Like</td>
				<td><input type="text" name="FieldLook"></td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Payment Date Between</td>
		</cfoutput>
				<td><Select name="FromMon" onChange="getdays()">
					<cfloop index="B5" From="01" To="12">
						<cfif B5 lt 10><cfset B5 = "0" & "#B5#"></cfif>
						<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
					</cfloop>
				</select><SELECT name="FromDay">
					<cfloop index="B5" From="01" To="#NumDays#">
						<cfif B5 lt 10><cfset B5 = "0" & "#B5#"></cfif>
						<cfoutput><option <cfif B5 IS 1>selected</cfif> value="#B5#">#b5#</cfoutput>
					</cfloop>
				</select><SELECT name="FromYear" onChange="getdays()">
					<cfloop index="B4" from="#yy2#" to="#yyy#">
						<cfoutput><option <cfif yyy Is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
					</cfloop>
				</select></td>
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
				<tr bgcolor="#tdclr#">
					<td align="right" bgcolor="#tbclr#">Payment Amount</td>
			</cfoutput>
				<td><input type="radio" checked name="AmountDir" value="GT">Greater Than <input type="radio" name="AmountDir" value="LT">Less Than</td>
				<td><input type="text" name="AmountLook" size="5" maxlength="5" value="0"></td>
			</tr>
			<tr>
				<th colspan="3"><input type="image" src="images/search.gif" name="ShowReport" border="0"></th>
			</tr>
		</form>
	<cfelse>
		<cfoutput>
			<tr>
				<td colspan="2" bgcolor="#tbclr#">There is currently a search results list.<br>
				Click Change Criteria to start over with a new search.<br>
				Click View List to continue with the current search results.</td>
			</tr>
			<tr>
				<form method="post" action="grplist.cfm">
					<input type="hidden" name="SendReportID" value="15">
					<input type="hidden" name="SendLetterID" value="0">
					<input type="hidden" name="ReturnPage" value="depositsearch.cfm">
					<input type="hidden" name="SendHeader" value="Deposit Number,Name,Payment Date,Amount,Payment Type,Chk No.">
					<input type="hidden" name="SendFields" value="URL,Name,ReportDate2,CurBal,ReportTab,City">
					<th><input type="image" name="ViewList" src="images/viewlist.gif" border="0"></th>
				</form>
				<form method="post" action="depositsearch.cfm">
					<th><input type="image" name="StartOver" src="images/changecriteria.gif" border="0"></th>
				</form>
			</tr>
		</cfoutput>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 