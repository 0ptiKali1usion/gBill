<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all payments in a selected date range.--->
<!--- 4.0.0. 09/13/99
		3.2.0 09/08/98 --->
<!--- payhist.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 16 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 16 
		AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
	</cfquery>
	<cfif CheckFirst.RecordCount GT 0>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterDomains 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPlans 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPOPs 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterSalesp 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="ChangeFilter" datasource="#pds#">
			DELETE FROM Filters 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM Filters 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 16 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,ReportID,FilterName,FirstParam,SecondParam,FirstAction,SecondAction,
				 FirstField,SecondField,LogicConnect,ActiveStatus,FromYear,FromMon,FromDay,ToYear,ToMon,ToDay) 
				VALUES 
				(#MyAdminID#,16,
				 <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 '#BegDay#', '#EndDay#',
				 <cfif Trim(MinAmnt) Is "">Null<cfelse>'#MinAmnt#'</cfif>,
				 <cfif Trim(MinCredit) Is "">Null<cfelse>'#MinCredit#'</cfif>,
				 <cfif Not IsDefined("Credit")>Null<cfelse>'#Credit#'</cfif>, 
				 <cfif Not IsDefined("CheckD")>Null<cfelse>'#CheckD#'</cfif>, 
				 <cfif Not IsDefined("Postal")>Null<cfelse>'#Postal#'</cfif>,
				 <cfif Not IsDefined("GroupSubs")>Null<cfelse>'#GroupSubs#'</cfif>,
				 <cfif IsDefined("FromYear")>#FromYear#<cfelse>Null</cfif>, 
				 <cfif IsDefined("FromMon")>#FromMon#<cfelse>Null</cfif>, 
				 <cfif IsDefined("FromDay")>#FromDay#<cfelse>Null</cfif>, 
				 <cfif IsDefined("ToYear")>#ToYear#<cfelse>Null</cfif>, 
				 <cfif IsDefined("ToMon")>#ToMon#<cfelse>Null</cfif>, 
				 <cfif IsDefined("ToDay")>#ToDay#<cfelse>Null</cfif>)
			</cfquery>
			<cfquery name="NewFilter" datasource="#pds#">
				SELECT Max(FilterID) as NewID 
				FROM Filters 
			</cfquery>
			<cfset FilterID = NewFilter.NewID>
		</cftransaction>
		<cfloop index="B5" list="#PlanID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPlans 
					(FilterID, PlanID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#POPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPOPs 
					(FilterID, POPID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#DomainID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterDomains 
					(FilterID, DomainID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#SalesPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterSalesp 
					(FilterID, AdminID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfset ReturnPage = "payhist.cfm">
	<cfparam name="Postal" default="0">
	<cfparam name="GroupSubs" default="0">
	<cfparam name="CheckD" default="0">
	<cfparam name="Credit" default="0">
	<cfquery name="allcredits" datasource="#PDS#">
		INSERT INTO GrpLists
		(FirstName,LastName,AccountID,ReportDate,ReportTab,CurBal,ReportHeader,
		 ReportTitle,ReportID,AdminID, CreateDate)
		SELECT A.FirstName, A.LastName, A.AccountID, T.DateTime1, 
		T.Paytype, T.Credit, T.MemoField, 'Payments Totals',16,#MyAdminID#, #Now()#  
		FROM Transactions T, Accounts A 
		WHERE T.Credit > 0 
		AND T.Datetime1 <= {ts'#toyear#-#tomon#-#today# 23:59:59'} 
		AND T.Datetime1 >= {ts'#fromyear#-#frommon#-#fromday# 00:00:00'}
		AND T.Adjustmentyn = 0 
		AND A.Accountid = T.Accountid 
		<cfif SalesPID Is 0>
			AND A.SalesPersonID In 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND A.SalesPersonID In (#SalesPID#) 
		</cfif>
		AND (<cfset LogicConnect = "">
			<cfif GroupSubs Is "1">
				#LogicConnect# T.PayType = 'check' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Credit Is "1">
				#LogicConnect# T.PayType = 'credit card'
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif CheckD Is "1">
				#LogicConnect# T.PayType = 'check debit' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Postal Is "1">
				#LogicConnect# T.PayType = 'money order' 
				OR T.PayType = 'cash' 
			</cfif>
		)
		<cfif PlanID Is 0>
			AND T.PlanID In 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND T.PlanID In (#PlanID#) 
		</cfif>
		<cfif POPID Is 0>
			AND T.POPID In 
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND T.POPID In (#POPID#) 
		</cfif>
		<cfif DomainID Is 0>
			AND 
			(T.AuthDomainID In 
				(SELECT DomainID 
				 FROM DomAdm 
				 WHERE AdminID = #MyAdminID#) 
			 OR T.FTPDomainID In 
			 	(SELECT DomainID 
				 FROM DomAdm 
				 WHERE AdminID = #MyAdminID#) 
			 OR T.EMailDomainID In 
			 	(SELECT DomainID 
				 FROM DomAdm 
				 WHERE AdminID = #MyAdminID#) 
			)
		<cfelse>
			AND 
			(T.AuthDomainID In (#DomainID#) 
			 OR T.FTPDomainID In (#DomainID#) 
			 OR T.EMailDomainID In (#DomainID#) 
			)
		</cfif>
	</cfquery>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 16 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 16>
	<cfset SendLetterID = 16>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 16 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "payhist.cfm">
	<cfset SendHeader = "Name,Date,Pay Method,Amount,Memo,E-Mail">
	<cfset SendFields = "Name,ReportDate,ReportTab,CurBal,ReportHeader,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfif IsDefined("UseExisting")>
	<cfquery name="GetFilter" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="DomainsFilter" datasource="#pds#">
		SELECT DomainID 
		FROM FilterDomains 
		WHERE FilterID = #SavedFilter#
	</cfquery>
	<cfquery name="PlansFilter" datasource="#pds#">
		SELECT PlanID 
		FROM FilterPlans 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="POPsFilter" datasource="#pds#">
		SELECT POPID 
		FROM FilterPOPs 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="SalesFilter" datasource="#pds#">
		SELECT AdminID 
		FROM FilterSalesp 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfif DomainsFilter.RecordCount GT 0>
		<cfset TheDomainID = ValueList(DomainsFilter.DomainID)>
	</cfif>
	<cfif PlansFilter.RecordCOunt GT 0>
		<cfset ThePlanID = ValueList(PlansFilter.PlanID)>
	</cfif>
	<cfif POPsFilter.RecordCount GT 0>
		<cfset ThePOPID = ValueList(POPsFilter.POPID)>
	</cfif>
	<cfif SalesFilter.RecordCount GT 0>
		<cfset SalesPID = ValueList(SalesFilter.AdminID)>
	</cfif>
	<cfset ReportID = 16>
	<cfset BegDay = GetFilter.FirstParam>
	<cfset EndDay = GetFilter.SecondParam>
	<cfset MinAmnt = GetFilter.FirstAction>
	<cfset MinCredit = GetFilter.SecondAction>
	<cfset Credit = GetFilter.FirstField>
	<cfset CheckD = GetFilter.SecondField>
	<cfset Postal = GetFilter.LogicConnect>
	<cfset GroupSubs = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
	<cfset FromYear = GetFilter.FromYear>
	<cfset FromMon = GetFilter.FromMon>
	<cfset FromDay = GetFilter.FromDay>
	<cfset ToYear = GetFilter.ToYear>
	<cfset ToMon = GetFilter.ToMon>
	<cfset ToDay = GetFilter.ToDay>
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 16 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 16 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfparam name="SavedFilter" default="0">
	<cfparam name="FilterName" default="">
	<cfparam name="BegDay" default="1">
	<cfparam name="Credit" default="1">
	<cfparam name="EndDay" default="31">
	<cfparam name="CheckD" default="1">
	<cfparam name="MinAMnt" default="NA">
	<cfparam name="Postal" default="1">
	<cfparam name="MinCredit" default="NA">
	<cfparam name="GroupSubs" default="1">
	<cfparam name="FromYear" default="#Year(Now())#">
	<cfparam name="FromMon" default="#Month(Now())#">
	<cfparam name="FromDay" default="1">
	<cfparam name="ToYear" default="#Year(Now())#">
	<cfparam name="ToMon" default="#Month(Now())#">
	<cfparam name="ToDay" default="#Day(Now())#">
</cfif>

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
<title>Payments Report</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=16','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
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
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Report</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<tr>
		<cfoutput>
		<td colspan="4" align="right" bgcolor="#tdclr#">
		</cfoutput>
			<table border="0">
				<tr>
					<cfif SavedFilters.RecordCount GT 0>
						<cfoutput>
						<form method="post" action="payhist.cfm?RequestTimeout=300">
							<td colspan="2">
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
						</form>
						<form method="post" action="payhist.cfm">
						</cfoutput>
										<td><select name="SavedFilter">
											<cfloop query="SavedFilters">
												<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
											</cfloop>
										</select> <input type="submit" name="UseExisting" value="Load"></td>
									</tr>									
								</table>
							</td>
						</form>
					</cfif>
	<cfoutput>
	<form name="getdate" method="post" action="payhist.cfm?RequestTimeout=300" onsubmit="return checkdates();MsgWindow()">
						<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
	</cfoutput>
					</tr>
				</table>
			</td>
		</tr>
	<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>From</td>
	</cfoutput>
			<td><Select name="FromMon" onChange="getdays()">
				<cfloop index="B5" From="1" To="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B4" From="1" To="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif B4 Is 1>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="FromYear" onChange="getdays()">
				<cfloop index="B3" From="#yy2#" To="#yyy#">
					<cfoutput><option <cfif yyy Is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		<cfoutput>
			<td bgcolor="#tbclr#" align=right>To</td>
		</cfoutput>
			<td><Select name="ToMon" onChange="getdays2()">
				<cfloop index="B5" From="1" To="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm Is B5>Selected</cfif> value="#B5#" >#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="ToDay">
				<cfloop index="B4" From="1" To="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif ddd Is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B3" From="#yy2#" To="#yyy#">
					<cfoutput><option <cfif yyy Is B3>Selected</cfif> value="#B3#" >#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<cfoutput>
		<tr bgcolor="#tdclr#">
			<td align="right"><input type="checkbox" <cfif Credit Is 1>checked</cfif> name="Credit" value="1"></td>
			<td bgcolor="#tbclr#">Credit Card Payments</td>
			<td align="right"><input type="checkbox" <cfif CheckD Is 1>checked</cfif> name="CheckD" value="1"></td>
			<td bgcolor="#tbclr#">Check Debit Payments</td>						
		</tr>
		<tr bgcolor="#tdclr#">
			<td align="right"><input type="checkbox" <cfif GroupSubs Is 1>checked</cfif> name="GroupSubs" value="1"></td>
			<td bgcolor="#tbclr#">Check Payments</td>
			<td align="right"><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
			<td bgcolor="#tbclr#">Cash/Money Order Payments</td>
		</tr>
		</cfoutput>
		<tr>
			<th colspan="4"><input type="image" name="CreateReport" src="images/viewlist.gif" border="0"></th>
		</tr>
		<cfinclude template="searchcriteria.cfm">
		<input type="hidden" name="BegDay" value="1">
		<input type="hidden" name="EndDay" value="31">
		<input type="hidden" name="MinAmnt" value="NA">
		<input type="hidden" name="MinCredit" value="NA">
	</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">There is already a payments report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="16">
				<input type="hidden" name="SendLetterID" value="16">
				<input type="hidden" name="ReturnPage" value="payhist.cfm">
				<input type="hidden" name="SendHeader" value="Name,Date,Pay Method,Amount,Memo,E-Mail">
				<input type="hidden" name="SendFields" value="Name,ReportDate,ReportTab,CurBal,ReportHeader,EMail">
				<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="payhist.cfm">
				<th colspan="2"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
			</form>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   