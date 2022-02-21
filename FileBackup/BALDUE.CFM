<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a list of all customers that owe. --->
<!--- 4.0.0 09/06/99 --->
<!--- baldue.cfm --->

<cfinclude template="security.cfm">
<cfif (IsDefined("RemoveSelected.x")) AND (IsDefined("DeleteID"))>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 8 
		AND GrpListID In (#DeleteID#)
	</cfquery>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 8 
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
			AND ReportID = 8 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,ReportID,FilterName,FirstParam,SecondParam,FirstAction,SecondAction,
				 FirstField,SecondField,LogicConnect,ActiveStatus) 
				VALUES 
				(#MyAdminID#,8,
				 <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 '#BegDay#', '#EndDay#',
				 <cfif Trim(MinAmnt) Is "">Null<cfelse>'#MinAmnt#'</cfif>,
				 <cfif Trim(MinCredit) Is "">Null<cfelse>'#MinCredit#'</cfif>,
				 <cfif Not IsDefined("Credit")>Null<cfelse>'#Credit#'</cfif>, 
				 <cfif Not IsDefined("CheckD")>Null<cfelse>'#CheckD#'</cfif>, 
				 <cfif Not IsDefined("Postal")>Null<cfelse>'#Postal#'</cfif>,
				 <cfif Not IsDefined("GroupSubs")>Null<cfelse>'#GroupSubs#'</cfif>)
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
<cfif IsDefined("CarryOn.x")>
	<cfparam name="postal" default="0">
	<cfparam name="credit" default="0">
	<cfparam name="GroupSubs" default="0">
	<cfparam name="CheckD" default="0">
	<cfquery name="InsData" datasource="#PDS#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, ReportTab, AdminID, ReportID, CurBal, ReportTitle, CreateDate)
		SELECT A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
		A.Company, T.PlanPayBy, #MyAdminID#, 8, Sum(T.DebitLeft), 'Customers Due', #Now()# 
		FROM Accounts A, Transactions T 
		WHERE A.AccountID = T.AccountID 
		AND A.CancelYN = 0 
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans 
			 WHERE AccountID > 0 
		<cfif (GroupSubs Is "1") 
		   OR (Credit Is "1")
			OR (CheckD Is "1")
			OR (Postal Is "1")>
			AND (<cfset LogicConnect = "">
				<cfif GroupSubs Is "1">
					#LogicConnect# PayBy = 'ck' 
					<cfset LogicConnect = "OR">
				</cfif>
				<cfif Credit Is "1">
					#LogicConnect# PayBy = 'cc'
					<cfset LogicConnect = "OR">
				</cfif>
				<cfif CheckD Is "1">
					#LogicConnect# PayBy = 'cd' 
					<cfset LogicConnect = "OR">
				</cfif>
				<cfif Postal Is "1">
					#LogicConnect# PayBy = 'po'
				</cfif>
				)
		<cfelse>
			AND T.PlanPayBy Is Null
		</cfif>	
			)
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans P 
			 WHERE DatePart(dd,P.NextDueDate) <= #endday# 
			 And DatePart(dd,P.NextDueDate) >= #begday# 
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
			AND 
			<cfif SalesPID Is 0>
				A.SalesPersonID IN 
					(SELECT SalesID 
					 FROM SalesAdm 
					 WHERE AdminID = #MyAdminID#)
			<cfelse>
				A.SalesPersonID In (#SalesPID#) 
			</cfif>
		)
		GROUP BY A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
		A.Company, T.PlanPayBy 
		<cfif IsDefined("MinAmnt")>
			<cfif MinAmnt Is "NA">
				HAVING Sum(DebitLeft) > 0.009
			<cfelseif MinAmnt GT 0>
				HAVING Sum(DebitLeft) > #MinAmnt# 
			<cfelse>
				HAVING Sum(DebitLeft) > 0.009
			</cfif>
		<cfelse>
			HAVING Sum(DebitLeft) > 0.009
		</cfif>
	</cfquery>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 8 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG, ReportTab) 
			VALUES 
			(8, #MyAdminID#, 'debitcc.cfm', 'debitall.gif', 'Credit Card')
		</cfquery>
	</cfif>
	<cfquery name="SetDef" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Unknown' 
		WHERE ReportTab Is Null 
		AND ReportID = 8 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 8 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check' 
		WHERE ReportTab = 'ck'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check Debit' 
		WHERE ReportTab = 'cd'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Credit Card' 
		WHERE ReportTab = 'cc'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Purchase Order' 
		WHERE ReportTab = 'po'
	</cfquery>
	<cfquery name="LoopRecords" datasource="#pds#">
		SELECT * 
		FROM GrpLists 
		WHERE ReportID = 8 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 8>
	<cfset SendLetterID = 8>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 8 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "baldue.cfm">
	<cfset SendHeader = "Name,Company,Pay By,Amount,Phone,E-Mail">
	<cfset SendFields = "Name,Company,ReportTab,CurBal,Phone,EMail">
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
	<cfset ReportID = 8>
	<cfset BegDay = GetFilter.FirstParam>
	<cfset EndDay = GetFilter.SecondParam>
	<cfset MinAmnt = GetFilter.FirstAction>
	<cfset MinCredit = GetFilter.SecondAction>
	<cfset Credit = GetFilter.FirstField>
	<cfset CheckD = GetFilter.SecondField>
	<cfset Postal = GetFilter.LogicConnect>
	<cfset GroupSubs = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 8 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 8 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 8 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfquery name="getemail" datasource="#pds#">
		SELECT EMail 
		FROM AccountsEMail 
		WHERE PrEMail = 1 
		AND AccountID = 
			(SELECT AccountID 
			 FROM Admin 
			 WHERE AdminID = #MyAdminID#)
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
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Customers Due Criteria</TITLE>
<script language="javascript">
<!--  
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=8','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
	<cfinclude template="coolsheet.cfm"></head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select Criteria</font></th>
		</tr>
		<tr>
			<th colspan="4" bgcolor="#tdclr#"><table border="0" width="100%">
	</cfoutput>
			<tr>
				<cfif SavedFilters.RecordCount GT 0>
					<form method="post" action="baldue.cfm">
						<td colspan="2"><table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
					</form>
					<form method="post" action="baldue.cfm">
										<td><select name="SavedFilter">
											<cfloop query="SavedFilters">
												<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
											</cfloop>
										</select> <input type="submit" name="UseExisting" value="Load"></td>
									</tr>									
								</table></td>
						</form>
					</cfif>
		<form method="post" action="baldue.cfm?RequestTimeout=300">
						<cfoutput>
							<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
						</cfoutput>
				</tr>
			</table></th>
		</tr>
		<cfoutput>
			<tr valign="top" bgcolor="#tdclr#">
		</cfoutput>
				<td align="right"><select name="begday">
					<cfloop index="B5" from="1" to="31">
						<cfif #B5# lt 10><cfset #B5# = "0" & #B5#></cfif>
						<cfoutput><option <cfif BegDay Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
					</cfloop>
				</select></td>
				<cfoutput>
				<td bgcolor="#tbclr#">Beginning Due Day</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Credit Is 1>checked</cfif> name="Credit" value="1"></td>
				<td bgcolor="#tbclr#">Include Credit Card Customers</td>
				</cfoutput>
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
			</cfoutput>
				<td align="right"><select name="EndDay">
					<cfloop index="B5" from="1" to="31">
						<cfif #B5# lt 10><cfset #B5# = "0" & #B5#></cfif>
						<cfoutput><option <cfif EndDay Is B5>Selected</cfif> value="#B5#">#B5#</cfoutput>
					</cfloop>	
				</select></td>			
			<cfoutput>
				<td bgcolor="#tbclr#">Ending Due Day</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif CheckD Is 1>checked</cfif> name="CheckD" value="1"></td>
				<td bgcolor="#tbclr#">Include Check Debit Customers</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#" align="right"><input type="text" name="MinAmnt" size="5" value="#MinAmnt#"></td>
				<td bgcolor="#tbclr#">Min Amount Owed</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
				<td bgcolor="#tbclr#">Include Purchase Order Customers</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#" align="right">&nbsp;</td>
				<input type="hidden" name="MinCredit" value="NA">
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif GroupSubs Is 1>checked</cfif> name="GroupSubs" value="1"></td>
				<td bgcolor="#tbclr#">Include Check/Cash Customers</td>
			</tr>
			<tr>
				<th colspan="4"><input type="image" src="images/continue.gif" name="CarryOn" border="0"></th>
			</tr>
			</cfoutput>
			<cfinclude template="searchcriteria.cfm">
		</form>
	</table>
	</center>
		<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Session In Progress</title>
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td align="center" colspan="2" bgcolor="#thclr#">Customers That Owe</td>
	</cfoutput>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="8">
				<input type="hidden" name="SendLetterID" value="8">
				<input type="hidden" name="ReturnPage" value="baldue.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Amount,Phone,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,ReportTab,CurBal,Phone,EMail">
				<td><input type="image" src="images/viewlist.gif" name="continue" border="0"></td>
			</form>
			<form method="post" action="baldue.cfm">
				<td><input type="image" src="images/changecriteria.gif" name="startover" border="0"></td>
			</form>
		</tr>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>
 