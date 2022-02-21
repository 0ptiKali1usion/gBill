<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 04/30/00 --->
<!--- Commission.cfm --->

<cfset securepage="commreport.cfm">
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
	<cfquery name="GetID" datasource="#pds#">
		SELECT ReportID 
		FROM CommReport 
		WHERE KeepYN = 0 
		AND AdminID = #MyAdminID#
	</cfquery>
	<cfset DelReportID = GetID.ReportID>
	<cftransaction>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM CommDetail 
			WHERE ReportID = #DelReportID# 
		</cfquery>
		<cfquery name="CleanUp2" datasource="#pds#">
			DELETE FROM CommCriteria 
			WHERE ReportID = #DelReportID# 
		</cfquery>
		<cfquery name="StartOver" datasource="#pds#">
			DELETE FROM CommReport 
			WHERE ReportID = #DelReportID# 
		</cfquery>
	</cftransaction>
</cfif>
<cfif IsDefined("Report.x")>
	<cfset Date1 = CreateDateTime(FromYear,FromMon,FromDay, 0,0,0)>
	<cfset Date2 = CreateDateTime(ToYear,ToMon,ToDay,23,59,59)>
	<cfif TransType Is 1>
		<cftransaction>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO CommReport 
				(AdminID, StartDate, EndDate, IncSetupFee, TransType, DebitPerc, 
				 DebitSet, SetupPerc, SetupSet, PayPerc, PaySet, KeepYN, ReportMade, 
				 ReportTitle, CreatedBy)
				VALUES
				(#MyAdminID#, #CreateODBCDateTime(Date1)#, #CreateODBCDateTime(Date2)#, 
				 <cfif IsDefined("IncSetupFee")>1<cfelse>0</cfif>, #TransType#, 
				 <cfif Trim(DebitPerc) Is "">Null<cfelse>#DebitPerc#</cfif>, 
				 <cfif Trim(DebitSet) Is "">Null<cfelse>#DebitSet#</cfif>, 
				 <cfif Trim(SetupPerc) Is "">Null<cfelse>#SetupPerc#</cfif>, 
				 <cfif Trim(SetupSet) Is "">Null<cfelse>#SetupSet#</cfif>, 
				 <cfif Trim(PayPerc) Is "">Null<cfelse>#PayPerc#</cfif>, 
				 <cfif Trim(PaySet) Is "">Null<cfelse>#PaySet#</cfif>, 0, 
				 #Now()#, 'Report for #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName#' )
			</cfquery>
			<cfquery name="TheID" datasource="#pds#">
				SELECT Max(ReportID) as NewID 
				FROM CommReport 
			</cfquery>
			<cfset ReportID = TheID.NewID>
			<cfquery name="PlanDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, PlanID, 1, PlanDesc 
				FROM Plans 
				<cfif PlanID Is 0>
					WHERE PlanID In 
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					WHERE PlanID In (#PlanID#) 
				</cfif>				
			</cfquery>
			<cfquery name="POPDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, POPID, 2, POPName 
				FROM POPs 
				<cfif POPID Is 0>
					WHERE POPID In 
						(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					WHERE POPID In (#POPID#) 
				</cfif>
			</cfquery>
			<cfquery name="SalesDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, S.AdminID, 4, A.FirstName + ' ' + A.LastName 
				FROM Accounts A, Admin S 
				WHERE A.AccountID = S.AccountID 
				<cfif SalesPID Is 0>
					AND S.AdminID In 
						(SELECT SalesID 
						 FROM SalesAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND S.AdminID In (#SalesPID#) 
				</cfif>
			</cfquery>
			<cfquery name="DomainDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, DomainID, 3, DomainName 
				FROM Domains 
				<cfif DomainID Is 0>
					WHERE DomainID In 
						(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					WHERE DomainID In (#DomainID#) 
				</cfif>
			</cfquery>
			<cfquery name="DetailsDetails" datasource="#pds#">
				INSERT INTO CommDetail 
				(ReportID,AccountID, TransID, TransDate, TransAmount, AmountPerc, AmountSet, 
				 POPID, AccntPlanID, PlanID, SalesPersonID, SetupFeeYN, FirstName, LastName)
				SELECT #ReportID#, A.AccountID, T.TransID, T.DateTime1, T.Debit, 0, 0, 
				A.POPID, A.AccntPlanID, A.PlanID, U.SalesPersonID, T.SetUpFeeYN, 
				U.FirstName, U.LastName 
				FROM Accounts U, AccntPlans A, TransActions T 
				WHERE U.AccountID = A.AccountID 
				AND A.AccountID = T.AccountID 
				AND T.TaxYN = 0 
				AND T.Debit > 0 
				AND T.AdjustmentYN = 0 
				AND T.DateTime1 <= #CreateODBCDateTime(Date2)#
				AND T.DateTime1 >= #CreateODBCDateTime(Date1)#
				<cfif SalesPID Is 0>
					AND U.SalesPersonID In 
						(SELECT SalesID 
						 FROM SalesAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					AND U.SalesPersonID In (#SalesPID#) 
				</cfif>
				<cfif POPID Is 0>
					AND A.POPID In 
						(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					AND A.POPID In (#POPID#) 
				</cfif>
				<cfif PlanID Is 0>
					AND A.PlanID In 
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#) 
				<cfelse>
					AND A.PlanID In (#PlanID#) 
				</cfif>
				<cfif DomainID Is 0>
					AND 
					(A.FTPDomainID In 
						(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#) 
					 OR A.EMailDomainID In 
						(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#) 
					 OR A.AuthDomainID In 
						(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#) 
					)
				<cfelse>
					AND 
					(A.FTPDomainID In (#DomainID#) 
					 OR A.EMailDomainID In (#DomainID#) 
					 OR A.AuthDomainID In (#DomainID#) 
					)
				</cfif>
				<cfif Not IsDefined("IncSetupFee")>
					AND T.SetUpFeeYN = 0 
				</cfif>
			</cfquery>
		</cftransaction>
		<cfquery name="UpdAmnts" datasource="#pds#">
			UPDATE CommDetail SET 
			AmountPerc = (TransAmount * #DebitPerc#)/100, 
			AmountSet = #DebitSet# 
			WHERE SetupFeeYN = 0 
			AND ReportID = #ReportID# 
		</cfquery>
		<cfquery name="UpdAmnts" datasource="#pds#">
			UPDATE CommDetail SET 
			AmountPerc = (TransAmount * #SetupPerc#)/100, 
			AmountSet = #SetupSet# 
			WHERE SetupFeeYN = 1 
			AND ReportID = #ReportID# 
		</cfquery>
		<cfquery name="GetAmount" datasource="#pds#">
			SELECT sum(AmountPerc) as PercDue, 
			Sum(AmountSet) as SetDue 
			FROM CommDetail 
			WHERE ReportID = #ReportID# 
		</cfquery>
		<cfif GetAmount.PercDue Is "">
			<cfset TheAmountPerc = 0>
		<cfelse>
			<cfset TheAmountPerc = GetAmount.PercDue>
		</cfif>
		<cfif GetAmount.SetDue Is "">
			<cfset TheAmountSet = 0>
		<cfelse>
			<cfset TheAmountSet = GetAmount.SetDue>
		</cfif>
		<cfset TotalDue = TheAmountPerc + TheAmountSet>
		<cfquery name="UpdReport" datasource="#pds#">
			UPDATE CommReport SET 
			TotalDue = #TotalDue# 
			WHERE ReportID = #ReportID# 
		</cfquery>
	<cfelseif TransType Is 2>
		<cftransaction>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO CommReport 
				(AdminID, StartDate, EndDate, IncSetupFee, TransType, DebitPerc, 
				 DebitSet, SetupPerc, SetupSet, PayPerc, PaySet, KeepYN, ReportMade, 
				 ReportTitle, CreatedBy)
				VALUES
				(#MyAdminID#, #CreateODBCDateTime(Date1)#, #CreateODBCDateTime(Date2)#, 
				 <cfif IsDefined("IncSetupFee")>1<cfelse>0</cfif>, 2, 
				 <cfif Trim(DebitPerc) Is "">Null<cfelse>#DebitPerc#</cfif>, 
				 <cfif Trim(DebitSet) Is "">Null<cfelse>#DebitSet#</cfif>, 
				 <cfif Trim(SetupPerc) Is "">Null<cfelse>#SetupPerc#</cfif>, 
				 <cfif Trim(SetupSet) Is "">Null<cfelse>#SetupSet#</cfif>, 
				 <cfif Trim(PayPerc) Is "">Null<cfelse>#PayPerc#</cfif>, 
				 <cfif Trim(PaySet) Is "">Null<cfelse>#PaySet#</cfif>, 0, 
				 #Now()#, 'Report for #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', 
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName#')
			</cfquery>
			<cfquery name="TheID" datasource="#pds#">
				SELECT Max(ReportID) as NewID 
				FROM CommReport 
			</cfquery>
			<cfset ReportID = TheID.NewID>
			<cfquery name="PlanDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, PlanID, 1, PlanDesc 
				FROM Plans 
				<cfif PlanID Is Not 0>
					WHERE PlanID In (#PlanID#) 
				</cfif>				
			</cfquery>
			<cfquery name="POPDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, POPID, 2, POPName 
				FROM POPs 
				<cfif POPID Is Not 0>
					WHERE POPID In (#POPID#) 
				</cfif>
			</cfquery>
			<cfquery name="SalesDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, S.AdminID, 4, A.FirstName + ' ' + A.LastName 
				FROM Accounts A, Admin S 
				WHERE A.AccountID = S.AccountID 
				<cfif SalesPID Is Not 0>
					AND S.AdminID In (#SalesPID#) 
				</cfif>
			</cfquery>
			<cfquery name="DomainDetails" datasource="#pds#">
				INSERT INTO CommCriteria 
				(ReportID, SelectID, TypeID, TypeStr) 
				SELECT #ReportID#, DomainID, 3, DomainName 
				FROM Domains 
				<cfif DomainID Is Not 0>
					WHERE DomainID In (#DomainID#) 
				</cfif>
			</cfquery>
			<cfquery name="DetailsDetails" datasource="#pds#">
				INSERT INTO CommDetail 
				(ReportID,AccountID, TransID, TransDate, TransAmount, AmountPerc, AmountSet, 
				 POPID, AccntPlanID, PlanID, SalesPersonID, SetupFeeYN, FirstName, LastName)
				SELECT #ReportID#, A.AccountID, T.TransID, T.DateTime1, T.Credit, 0, 0, 
				A.POPID, A.AccntPlanID, A.PlanID, U.SalesPersonID, T.SetUpFeeYN, 
				U.FirstName, U.LastName 
				FROM Accounts U, AccntPlans A, TransActions T 
				WHERE U.AccountID = A.AccountID 
				AND A.AccountID = T.AccountID 
				AND T.TaxYN = 0 
				AND T.Credit > 0 
				AND T.AdjustmentYN = 0 
				AND T.DateTime1 <= #CreateODBCDateTime(Date2)#
				AND T.DateTime1 >= #CreateODBCDateTime(Date1)#
				<cfif SalesPID Is Not 0>
					AND U.SalesPersonID In (#SalesPID#) 
				</cfif>
				<cfif POPID Is Not 0>
					AND A.POPID In (#POPID#) 
				</cfif>
				<cfif PlanID Is Not 0>
					AND A.PlanID In (#PlanID#) 
				</cfif>
				<cfif Not IsDefined("IncSetupFee")>
					AND T.SetUpFeeYN = 0 
				</cfif>
			</cfquery>
		</cftransaction>
		<cfquery name="UpdAmnts" datasource="#pds#">
			UPDATE CommDetail SET 
			AmountPerc = (TransAmount * #PayPerc#)/100, 
			AmountSet = #PaySet# 
			WHERE SetupFeeYN = 0 
			AND ReportID = #ReportID# 
		</cfquery>
		<cfquery name="GetAmount" datasource="#pds#">
			SELECT sum(AmountPerc) as PercDue, 
			Sum(AmountSet) as SetDue 
			FROM CommDetail 
			WHERE ReportID = #ReportID# 
		</cfquery>
		<cfif GetAmount.PercDue Is "">
			<cfset TheAmountPerc = 0>
		<cfelse>
			<cfset TheAmountPerc = GetAmount.PercDue>
		</cfif>
		<cfif GetAmount.SetDue Is "">
			<cfset TheAmountSet = 0>
		<cfelse>
			<cfset TheAmountSet = GetAmount.SetDue>
		</cfif>
		<cfset TotalDue = TheAmountPerc + TheAmountSet>
		<cfquery name="UpdReport" datasource="#pds#">
			UPDATE CommReport SET 
			TotalDue = #TotalDue# 
			WHERE ReportID = #ReportID# 
		</cfquery>
	</cfif>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="commview.cfm">
	<cfabort>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AdminID, ReportID 
	FROM CommReport 
	WHERE KeepYN = 0 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfset CheckAdminID = CheckFirst.AdminID>
<cfset EReport = CheckFirst.ReportID>
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
<title>Commission Report</TITLE>
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
<form method="post" action="commreport.cfm">
	<input type="Image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Commission Report</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<cfoutput>
	<form name="getdate" method=post action="commission.cfm" onsubmit="return checkdates();MsgWindow()">
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
	<tr bgcolor="#tdclr#">
		<td align="right"><input type="Radio" checked name="TransType" value="2">Payments</td>
		<td colspan="3">Percent:<input type="Text" name="PayPerc" value="0" size="5">% and/or Set Fee: $<input type="Text" name="PaySet" value="0" size="5"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right" rowspan="2" valign="top"><input type="Radio" name="TransType" value="1">Debits</td>
		<td colspan="3">Percent:<input type="Text" name="DebitPerc" value="0" size="5">% and/or Set Fee: $<input type="Text" name="DebitSet" value="0" size="5"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td colspan="3"><input type="Checkbox" name="IncSetupFee" value="1"> Include Setup Fees<br>
		Percent:<input type="Text" name="SetupPerc" value="0" size="5">% and/or Set Fee: $<input type="Text" name="SetupSet" value="0" size="5"></td>
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
			<td colspan="4" bgcolor="#tbclr#">This is already a New Commission report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="commview.cfm">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
				<input type="Hidden" name="ReportID" value="#EReport#">
			</form>
			<form method="post" action="commission.cfm">
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
 