<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of debit activity during a selected date range. --->
<!--- 4.0.0 04/28/00 --->
<!--- reportdebits.cfm --->

<cfinclude template="security.cfm">
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 28 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("Report.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 28 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset Date1 = CreateDate(FromYear,FromMon,FromDay)>
		<cfset Date2 = CreateDate(ToYear,ToMon,ToDay)>
		<cfif Not IsNumeric(MinAmount)>
			<cfset TheMinAmount = 0>
		<cfelse>
			<cfset TheMinAmount = MinAmount>
		</cfif>
		<cfif Not IsNumeric(MaxAmount)>
			<cfset TheMaxAmount = 0>
		<cfelse>
			<cfset TheMaxAmount = MaxAmount>
		</cfif>
		<cfquery name="Range" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, Company, Phone, CurBal, CurBal2, 
			 ReportDate2, MemoField, ReportID, AdminID, ReportTitle, CreateDate) 	
			SELECT A.LastName, A.FirstName, A.AccountID, A.Company, A.Dayphone,
			T.Debit, T.DebitLeft, T.DateTime1, T.MemoField, 28, #MyAdminID#, 
			'Debits from #LSDateFormat(date1, '#DateMask1#')# to #LSDateFormat(date2, '#DateMask1#')#', #Now()# 
			FROM TransActions T, Accounts A 
			WHERE A.AccountID = T.AccountID 
			AND T.Debit <> 0 
			AND T.Debit > #TheMinAmount# 
			<cfif MaxAmount GT 0>
				AND T.Debit < #TheMaxAmount# 
			</cfif>
			<cfif Not IsDefined("IncAdj")>
				AND T.AdjustmentYN = 0 
			</cfif>
			<cfif IsDefined("IncUnp")>
				AND T.DebitLeft > 0 
			</cfif>
			<cfif Not IsDefined("IncTax")>
				AND T.TaxYN = 0 
			</cfif>
			<cfif Not IsDefined("IncSuf")>
				AND T.SetupFeeYN = 0 
			</cfif>
			AND T.AccountID In 
				(SELECT P.AccountID 
				 FROM AccntPlans P 
				 WHERE P.POPID IN 
				 	<cfif POPID Is Not 0>
						(#POPID#)
					<cfelse>
				 		(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#) 
					</cfif>
				 AND P.PlanID IN 
				 	<cfif PlanID Is Not 0>
						(#PlanID#)
					<cfelse>
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#) 
					</cfif>
					<cfif DomainID Is 0>
						AND 
							(P.AuthDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
							 OR P.EMailDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
							 OR P.FTPDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
							)
					<cfelse>
						AND 
							(P.AuthDomainID In (#DomainID#) 
							 OR P.EMailDomainID In (#DomainID#) 
							 OR P.FTPDomainID In (#DomainID#) 
							)
					</cfif>
				)
			AND T.DateTime1 < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
			AND T.DateTime1 > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
			<cfif SalesPID Is 0>
				AND A.SalesPersonID In 
					(SELECT SalesID 
					 FROM SalesAdm 
					 WHERE AdminID = #MyAdminID#) 
			<cfelse>
				AND A.SalesPersonID In (#SalesPID#)
			</cfif>
		</cfquery>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 28 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="GetSalesperson" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportHeader = A.FirstName + ' ' + A.LastName 
		FROM Accounts A, Admin S, GrpLists G 
		WHERE A.AccountID = S.AccountID 
		AND S.AdminID = G.AccntPlanID 
		AND G.ReportID = 28 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 28>
	<cfset SendLetterID = 28>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 28 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "reportdebits.cfm">
	<cfset SendHeader = "Amount,UnPaid,Name,Date,Memo,Phone,E-Mail">
	<cfset SendFields = "CurBal,CurBal2,Name,ReportDate2,MemoField,Phone,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 28 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(DateTime1) as MinDate 
	FROM TransActions 
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
<title>Debits Report</TITLE>
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
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Debit Activity</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<cfoutput>
	<form name="getdate" method=post action="reportdebits.cfm" onsubmit="return checkdates();MsgWindow()">
	<tr bgcolor="#tdclr#" valign="top">
		<td bgcolor="#tbclr#" align=right>From</td>
	</cfoutput>
		<td><Select name="FromMon" onChange="getdays()">
			<cfloop index="B5" From="01" To="12">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #mmm# is "#B5#">selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
			</cfloop>
		</select><SELECT name="FromDay">
			<cfloop index="B5" From="01" To="#numdays#">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option value="#B5#">#b5#</cfoutput>
			</cfloop>
		</select><SELECT name="FromYear" onChange="getdays()">
			<cfloop index="B4" from="#yy2#" to="#yyy#">
				<cfoutput><option <cfif #yyy# is "#B4#">selected</cfif> value="#B4#">#B4#</cfoutput>
			</cfloop>
		</select></td>
	<cfoutput>
		<td bgcolor="#tbclr#" align=right>To</td>
	</cfoutput>		
		<td><Select name="ToMon" onChange="getdays2()">
			<cfloop index="B5" From="01" To="12">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #mmm# is "#B5#">selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
			</cfloop>
		</select><SELECT name="ToDay">
			<cfloop index="B5" From="01" To="#numdays#">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #ddd# is "#B5#">selected</cfif> value="#B5#">#b5#</cfoutput>
			</cfloop>
		</select><SELECT name="ToYear" onChange="getdays2()">
			<cfloop index="B4" from="#yy2#" to="#yyy#">
				<cfoutput><option <cfif #yyy# is "#B4#">selected</cfif> value="#B4#">#B4#</cfoutput>
			</cfloop>
		</select></td>
	</tr>
	<cfoutput>
	<tr bgcolor="#tbclr#">
		<td bgcolor="#tdclr#" align="right"><input type="Text" name="MinAmount" value="0" size="5"></td>
		<td>Min Amount</td>
		<td align="right" bgcolor="#tdclr#"><input type="Checkbox" name="IncSuf" checked value="1"></td>
		<td bgcolor="#tbclr#">Include Setup Fees</td>
	</tr>
	<tr bgcolor="#tbclr#">
		<td bgcolor="#tdclr#" align="right"><input type="Text" name="MaxAmount" value="0" size="5"></td>
		<td>Max Amount</td>
		<td align="right" bgcolor="#tdclr#"><input type="Checkbox" name="IncTax" checked value="1"></td>
		<td bgcolor="#tbclr#">Include Taxes</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right"><input type="Checkbox" name="IncUnp" checked value="1"></td>
		<td bgcolor="#tbclr#">Unpaid Debits only</td>
		<td align="right"><input type="Checkbox" name="IncAdj" checked value="1"></td>
		<td bgcolor="#tbclr#">Include Adjustments</td>
	</tr>
	<tr>
		<th colspan="4"><input type="image" name="Report" src="images/viewlist.gif" border="0"></td>
	</tr>
	</cfoutput>
	<cfinclude template="searchcriteria.cfm">
	</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">This is already a Debit report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="28">
				<input type="hidden" name="SendLetterID" value="28">
				<input type="hidden" name="ReturnPage" value="reportdebits.cfm">
				<input type="hidden" name="SendHeader" value="Amount,Name,Date,Memo,Phone,E-Mail">
				<input type="hidden" name="SendFields" value="CurBal,Name,ReportDate2,MemoField,Phone,EMail">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="reportdebits.cfm">
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
 