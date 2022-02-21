<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This page handles the Credit Card batch processes. --->
<!---	4.0.0 09/16/99 --->
<!--- ccbatch.cfm Report No. 19 LetterID No. 19 --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 19 
	</cfquery>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpListInfo 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 19 
	</cfquery>
	<cfif IsDefined("TheBatches")>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CCBatchDetail 
			WHERE BatchID IN (#TheBatches#)
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CCBatchHist 
			WHERE BatchID In (#TheBatches#) 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 19 
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
			AND ReportID = 19 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,ReportID,FilterName,FirstParam,SecondParam,FirstAction,SecondAction,
				 FirstField,SecondField,LogicConnect,ActiveStatus,FromMon,FromDay,FromYear,ToMon,ToDay,ToYear) 
				VALUES 
				(#MyAdminID#,19,
				 <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 '#BegDay#', '#EndDay#',
				 <cfif Trim(MinAmnt) Is "">Null<cfelse>'#MinAmnt#'</cfif>,
				 <cfif Trim(MinCredit) Is "">Null<cfelse>'#MinCredit#'</cfif>,
				 <cfif Not IsDefined("Credit")>Null<cfelse>'#Credit#'</cfif>, 
				 <cfif Not IsDefined("CheckD")>Null<cfelse>'#CheckD#'</cfif>, 
				 <cfif Not IsDefined("Postal")>Null<cfelse>'#Postal#'</cfif>,
				 <cfif Not IsDefined("GroupSubs")>Null<cfelse>'#GroupSubs#'</cfif>,
				 #FromMon#,#FromDay#,#FromYear#,#ToMon#,#ToDay#,#ToYear#)
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
	<cfif Not IsNumeric(MinAmnt)>
		<cfset MinAmnt = 0>
	</cfif>
	<cfif Not IsNumeric(MinCredit)>
		<cfset MinCredit = 0>
	</cfif>
	<cfquery name="CCBal" datasource="#pds#">
		INSERT INTO GrpLists 
		(FirstName, LastName, AccountID, AccntPlanID, Company, ReportTab,
		 CurBal, Curbal2, AdminID, ReportID, ReportTitle, CreateDate)
		<cfif IsDefined("Credit")>
			SELECT A.FirstName, A.LastName, A.AccountID, T.AccntPlanID, 
			A.Company, 'Debit', 
			Sum(T.DebitLeft), 
			0,#MyAdminID#, 19, 'Credit Card Batch Output', #Now()#
			FROM Accounts A, Transactions T  
			WHERE A.AccountID = T.AccountID 
			AND T.PlanPayBy = 'cc' 
			AND T.BatchPendingYN = 0  
			AND A.AccountID In 
				(SELECT P.AccountID 
				 FROM AccntPlans P 
				 WHERE 0=0 
				 AND DatePart(dd,P.NextDueDate) <= #endday# 
				 AND DatePart(dd,P.NextDueDate) >= #begday# 
				<cfif PlanID Is "0">
					AND P.PlanID In 
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND P.PlanID In (#PlanID#) 
				</cfif>
				<cfif POPID Is "0">
					AND P.POPID In 
						(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND P.POPID In (#POPID#) 
				</cfif>
				<cfif DomainID Is "0">
					AND (P.FTPDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
							OR P.EMailDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)			
							OR P.AuthDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
						  )
				<cfelse>
					AND (P.FTPDomainID In (#DomainID#)
						  OR P.EMailDomainID In (#DomainID#) 
						  OR P.AuthDomainID In (#DomainID#) )
				</cfif>
				<cfif SalesPID Is "0">
					AND A.SalesPersonID IN 
						(SELECT SalesID 
						 FROM SalesAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND A.SalesPersonID In (#SalesPID#) 
				</cfif>
				)
			GROUP BY A.FirstName, A.LastName, A.AccountID, T.AccntPlanID, A.Company 
			HAVING Sum(T.DebitLeft) > #MinAmnt# 
		</cfif>
		<cfif (IsDefined("CheckD")) AND (IsDefined("Credit"))>UNION</cfif>
		<cfif IsDefined("CheckD")>
			SELECT A.FirstName, A.LastName, A.AccountID, T.AccntPlanID, A.Company, 'Credit', 0,
			Sum(T.Credit), #MyAdminID#, 19, 'Credit Card Batch Output', #Now()#
			FROM Accounts A, Transactions T  
			WHERE A.AccountID = T.AccountID 
			AND T.RefundBy = 'cc' 
			AND T.RefundedYN = 0 
			AND T.BatchPendingYN = 0 
			AND A.AccountID In 
				(SELECT P.AccountID 
				 FROM AccntPlans P 
				 WHERE 0=0 
				 AND DatePart(dd,P.NextDueDate) <= #endday# 
				 AND DatePart(dd,P.NextDueDate) >= #begday# 
				<cfif PlanID Is "0">
					AND P.PlanID In 
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND P.PlanID In (#PlanID#) 
				</cfif>
				<cfif POPID Is "0">
					AND P.POPID In 
						(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND P.POPID In (#POPID#) 
				</cfif>
				<cfif DomainID Is "0">
					AND (P.FTPDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
							OR P.EMailDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)			
							OR P.AuthDomainID In 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#)
						  )
				<cfelse>
					AND P.FTPDomainID In (#DomainID#)
					AND P.EMailDomainID In (#DomainID#) 
					AND P.AuthDomainID In (#DomainID#) 
				</cfif>
				<cfif SalesPID Is "0">
					AND A.SalesPersonID IN 
						(SELECT SalesID 
						 FROM SalesAdm 
						 WHERE AdminID = #MyAdminID#)
				<cfelse>
					AND A.SalesPersonID In (#SalesPID#) 
				</cfif>
				)
			GROUP BY A.FirstName, A.LastName, A.AccountID, T.AccntPlanID, A.Company  
			HAVING Sum(T.Credit) > #MinCredit# 
		</cfif>
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 19 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AdminID 
		FROM GrpListInfo 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 19 
		AND DestinationCFM = 'ccoutput.cfm'
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG)
			VALUES 
			(19, #MyAdminID#, 'ccoutput.cfm', 'beginoutput.gif')
		</cfquery>
	</cfif>
	<cfset ReportID = 19>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "ccbatch.cfm">
	<cfset SendHeader = "Name,Company,Amount,Credit,E-Mail">
	<cfset SendFields = "Name,Company,CurBal,CurBal2,EMail">
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
	<cfset ReportID = 19>
	<cfset BegDay = GetFilter.FirstParam>
	<cfset EndDay = GetFilter.SecondParam>
	<cfset MinAmnt = GetFilter.FirstAction>
	<cfset MinCredit = GetFilter.SecondAction>
	<cfset Credit = GetFilter.FirstField>
	<cfset CheckD = GetFilter.SecondField>
	<cfset Postal = GetFilter.LogicConnect>
	<cfset GroupSubs = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
	<cfset ToYear = GetFilter.ToYear>
	<cfset ToMon = GetFilter.ToMon>
	<cfset ToDay = GetFilter.ToDay>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID, ReportURLID2 
	FROM GrpLists 
	WHERE ReportID = 19 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 19 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfparam name="SavedFilter" default="0">
	<cfparam name="FilterName" default="">
	<cfparam name="BegDay" default="1">
	<cfparam name="Credit" default="1">
	<cfparam name="EndDay" default="31">
	<cfparam name="CheckD" default="1">
	<cfparam name="MinAMnt" default="0">
	<cfparam name="Postal" default="1">
	<cfparam name="MinCredit" default="0">
	<cfparam name="GroupSubs" default="1">
	<cfparam name="FromYear" default="#Year(Now())#">
	<cfparam name="FromMon" default="#Month(Now())#">
	<cfparam name="FromDay" default="1">
	<cfparam name="ToYear" default="#Year(Now())#">
	<cfparam name="ToMon" default="#Month(Now())#">
	<cfparam name="ToDay" default="#Day(Now())#">
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Credit Card Batch Management</title>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=19','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
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
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Credit Card Batch Management</font></th>
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
								<form method="post" action="ccbatch.cfm">
									<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
								</form>
								<form method="post" action="ccbatch.cfm">
							</cfoutput>
									<td><select name="SavedFilter">
										<cfloop query="SavedFilters">
											<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
										</cfloop>
									</select> <input type="submit" name="UseExisting" value="Load"></td>
								</form>
						</cfif>
	<form name="getdate" method="post" action="ccbatch.cfm?RequestTimeout=300" onsubmit="MsgWindow()">
						<cfoutput>
							<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
						</cfoutput>
					</tr>
				</table>
			</td>
		</tr>
		<cfoutput>
		<tr bgcolor="#tdclr#">
		</cfoutput>
			<td align="right"><select name="BegDay">
				<cfloop index="B5" from="1" to="31">
					<cfoutput><option <cfif BegDay Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select></td>
			<cfoutput>
				<td bgcolor="#tbclr#">Beginning Due Day</td>
				<td align="right"><input type="checkbox" <cfif Credit Is "1">Checked</cfif> name="Credit" value="1"></td>
				<td bgcolor="#tbclr#">Include Debits</td>			
			</cfoutput>
		</tr>
		<cfoutput>
		<tr bgcolor="#tdclr#">
		</cfoutput>
			<td align="right"><select name="EndDay">
				<cfloop index="B5" from="1" to="31">
					<cfoutput><option <cfif EndDay Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select></td>
		<cfoutput>
			<td bgcolor="#tbclr#">Ending Due Day</td>
			<td align="right"><input type="checkbox" <cfif CheckD Is "1">Checked</cfif> name="CheckD" value="1"></td>
			<td bgcolor="#tbclr#">Include Credits</td>			
		</tr>
		<tr bgcolor="#tdclr#">
			<td align="right"><input type="text" name="MinAmnt" value="#MinAmnt#" size="5"></td>
			<td bgcolor="#tbclr#">Minimum Debit</td>
			<td align="right"><input type="text" name="MinCredit" value="#MinCredit#" size="5"></td>
			<td bgcolor="#tbclr#">Minimum Credit</td>
		</tr>
		</cfoutput>		
		<tr>
			<th colspan="4"><input type="image" name="CreateReport" src="images/viewlist.gif" border="0"></th>
		</tr>
		<cfinclude template="searchcriteria.cfm">
		<input type="hidden" name="FromDay" value="0">
		<input type="hidden" name="FromMon" value="0">
		<input type="hidden" name="FromYear" value="0">
		<input type="hidden" name="ToDay" value="0">
		<input type="hidden" name="ToMon" value="0">
		<input type="hidden" name="ToYear" value="0">
		<input type="hidden" name="GroupSubs" value="0">
		<input type="hidden" name="Postal" value="0">
	</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">There is already a credit card batch in progress.</td>
		</tr>
		<tr>
			<cfif CheckFirst.ReportURLID2 Is 1>
				<form method="post" action="ccoutput.cfm">
			<cfelse>
				<form method="post" action="grplist.cfm">
			</cfif>
				<input type="hidden" name="SendReportID" value="19">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="ccbatch.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Amount,Credit,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,CurBal,CurBal2,EMail">
				<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="ccbatch.cfm">
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
       