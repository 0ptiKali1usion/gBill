<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a list of Postal customers. --->
<!---	4.0.0 09/08/99 --->
<!--- postal.cfm --->

<cfset securepage="postal.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 9 
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
			AND ReportID = 9 
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
				(#MyAdminID#,9,
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
	<cfparam name="Postal" default="0">
	<cfparam name="GroupSubs" default="0">
	<cfparam name="CheckD" default="0">
	<cfparam name="Credit" default="0">
	<cfquery name="PostalCustomers" datasource="#pds#">
		INSERT INTO GrpLists 
		(LastName, FirstName, Login, City, AccountID, Address, Phone, Company, 
		 ReportID, AdminID, ReportTitle, CurBal, CreateDate) 
		SELECT A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Address1, 
		A.DayPhone, A.Company, 9, #MyAdminID#, 'Postal Invoice Customers', 
		Sum(T.Debit-T.Credit), #Now()# 
		FROM Accounts A, Transactions T 
		WHERE A.AccountID = T.AccountID 
		<cfif SalesPID Is 0>
			AND A.SalesPersonID In 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND A.SalesPersonID In (#SalesPID#) 
		</cfif>
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans P
			 WHERE P.PostalRem = 1
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
			AND (<cfset LogicConnect = "">
			<cfif GroupSubs Is "1">
				#LogicConnect# P.PayBy = 'ck' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Credit Is "1">
				#LogicConnect# P.PayBy = 'cc'
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif CheckD Is "1">
				#LogicConnect# P.PayBy = 'cd' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Postal Is "1">
				#LogicConnect# P.PayBy = 'po'
			</cfif>
				)
			AND DatePart(dd,P.NextDueDate) <= #endday# 
			And DatePart(dd,P.NextDueDate) >= #begday# 
			 ) 
		GROUP BY A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Address1, A.DayPhone, A.Company 
	</cfquery>
	<cfif MinAmnt Is Not "NA">
		<cfquery name="RemoveWrongBals" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE CurBal < #MinAmnt# 
			<cfif MinCredit Is Not "NA">
				AND CurBal >= 0 
			</cfif>
			AND AdminID = #MyAdminID# 
			AND ReportID = 9 
		</cfquery>
	</cfif>
	<cfif MinCredit Is Not "NA">
		<cfquery name="RemoveWrongCredits" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE CurBal <= 0 
			<cfif MinAmnt Is Not "NA">
				AND CurBal > -#MinCredit# 
			</cfif>
			AND AdminID = #MyAdminID# 
			AND ReportID = 9 
		</cfquery>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 9  
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 9>
	<cfset SendLetterID = 9>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 9 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "postal.cfm">
	<cfset SendHeader = "Name,Address,City,Phone,Amount,E-Mail">
	<cfset SendFields = "Name,Address,City,Phone,CurBal,EMail">
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
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 9 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 9 
	AND AdminID = #MyAdminID#
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 9 
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
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Postal Customers</title>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=9','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Postal Statement Customers</font></th>
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
						<form method="post" action="postal.cfm">
							<td colspan="2">
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
						</form>
						<form method="post" action="postal.cfm">
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
	<form method="post" action="postal.cfm?RequestTimeout=300" onsubmit="MsgWindow()">
						<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
					</tr>
				</table>
			</td>
		</tr>
	</cfoutput>
	<cfoutput>
	<tr valign="top" bgcolor="#tdclr#">
	</cfoutput>
					<td><select name="begday">
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
					<td><select name="EndDay">
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
					<td bgcolor="#tdclr#"><input type="text" name="MinAmnt" size="5" value="#MinAmnt#"></td>
					<td bgcolor="#tbclr#">Min Amount Owed</td>
					<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
					<td bgcolor="#tbclr#">Include Purchase Order Customers</td>
				</tr>
				<tr>
					<td bgcolor="#tdclr#"><input type="text" name="MinCredit" size="5" value="#MinCredit#"></td>
					<td bgcolor="#tbclr#">Min Credit Amount</td>
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
		</td>
	</tr>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">There is already a Postal Statement Customer List.</td>
		</tr>
		<tr>	
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="9">
				<input type="hidden" name="SendLetterID" value="9">
				<input type="hidden" name="ReturnPage" value="postal.cfm">
				<input type="hidden" name="SendHeader" value="Name,Address,City,Phone,Amount,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Address,City,Phone,CurBal,EMail">
				<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" border="0" name="ViewExisting"></th>
			</form>
			<form method="post" action="postal.cfm">
				<th colspan="2"><input type="image" src="images/changecriteria.gif" border="0" name="StartOver"></th>
			</form>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>>>>