<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- List of all customers. --->
<!--- 4.0.0 09/20/99 --->
<!--- paytype.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 20
	</cfquery>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 20 
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
			AND ReportID = 20 
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
				(#MyAdminID#,20,
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
<cfif IsDefined("Report.x")>
	<cfparam name="Postal" default="0">
	<cfparam name="GroupSubs" default="0">
	<cfparam name="CheckD" default="0">
	<cfparam name="Credit" default="0">
	<cfquery name="Debits" datasource="#PDS#">
		INSERT INTO GrpLists 
		(FirstName,LastName, Phone, Company, AccountID, ReportTab, ReportID,AdminID, CreateDate)
		SELECT A.FirstName, A.LastName, A.Dayphone, A.Company, A.AccountID, 
		AP.PayBy, 20, #MyAdminID#, #Now()# 
		FROM Accounts A, AccntPlans AP 
		WHERE A.AccountID = AP.AccountID 
		<cfif BODBCType is "SQL">
			AND DatePart(dd,AP.NextDueDate) <= #EndDay# 
			And DatePart(dd,AP.NextDueDate) >= #BegDay# 
		<cfelseif BODBCType is "access">
			AND DatePart('d',AP.NextDueDate) <= #EndDay# 
			AND DatePart('d',AP.NextDueDate) >= #BegDay# 
		</cfif>
		<cfif PlanID Is Not "0">
			AND AP.PlanID In (#PlanID#) 
		</cfif>
		<cfif POPID Is Not "0">
			AND AP.POPID In (#POPID#) 
		</cfif>
		<cfif DomainID Is Not "0">
			AND (AP.EMailDomainID IN (#DomainID#) 
					OR FTPDomainID IN (#DomainID#) 
					OR AuthDomainID IN (#DomainID#)
				 )
		</cfif>		
		AND (<cfset LogicConnect = "">
			<cfif GroupSubs Is "1">
				#LogicConnect# AP.PayBy = 'ck' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Credit Is "1">
				#LogicConnect# AP.PayBy = 'cc' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif CheckD Is "1">
				#LogicConnect# AP.PayBy = 'cd' 
				<cfset LogicConnect = "OR">
			</cfif>
			<cfif Postal Is "1">
				#LogicConnect# AP.PayBy = 'po' 
			</cfif>
			)
	</cfquery>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check/Cash' 
		WHERE ReportTab = 'ck'
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Credit Card' 
		WHERE ReportTab = 'cc'
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check Debit' 
		WHERE ReportTab = 'cd'
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Purchase Order' 
		WHERE ReportTab = 'po'
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfset ReportID = 20>
	<cfset LetterID = 20>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 20 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "paytype.cfm">
	<cfset SendHeader = "Name,Company,Pay By,Phone,E-Mail">
	<cfset SendFields = "Name,Company,ReportTab,Phone,EMail">
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
	<cfset ReportID = 20>
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
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 20 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 20 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfquery name="GetPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In 
			(SELECT P.PlanID 
			 FROM PlanAdm P, Admin A 
			 WHERE P.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY PlanDesc
	</cfquery>
	<cfquery name="GetDomains" datasource="#pds#">
		SELECT DomainID, DomainName 
		FROM Domains 
		WHERE DomainID In 
			(SELECT D.DomainID 
			 FROM DomAdm D, Admin A 
			 WHERE D.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY DomainName
	</cfquery>
	<cfquery name="GetPOPs" datasource="#pds#">
		SELECT POPID, POPName 
		FROM POPs 
		WHERE POPID In 
			(SELECT P.POPID 
			 FROM POPAdm P, Admin A 
			 WHERE P.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY POPName
	</cfquery>
	<cfquery name="GetSalesP" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID
		FROM Accounts C, Admin A 
		WHERE C.AccountID = A.AccountID 
		AND A.SalesPersonYN = 1 
		<cfif GetOpts.EditName Is 0>
			AND AdminID = #MyAdminID# 
		</cfif>
		ORDER BY LastName, FirstName 
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
	<cfparam name="TheDomainID" default="0">
	<cfparam name="ThePlanID" default="0">
	<cfparam name="ThePOPID" default="0">
	<cfparam name="SalesPID" default="0">
	<cfset TheMonth = Now()>
	<cfset TheMonth = DateAdd("m",1,TheMonth)>
	<cfparam name="FromYear" default="#Year(TheMonth)#">
	<cfparam name="FromMon" default="#Month(TheMonth)#">
	<cfparam name="FromDay" default="1">
	<cfparam name="ToYear" default="#Year(Now())#">
	<cfparam name="ToMon" default="#Month(Now())#">
	<cfparam name="ToDay" default="#Day(Now())#">
</cfif>

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
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=20','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Customer List</font></th>
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
						<form method="post" action="monthinv.cfm?RequestTimeout=300">
							<td colspan="2">
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
						</form>
						<form method="post" action="monthinv.cfm">
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
	<form name="getdate" method="post" action="paytype.cfm?RequestTimeout=500" onsubmit="MsgWindow()">
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
			</cfoutput>
			<td><select name="EndDay">
				<cfloop index="B5" from="1" to="31">
					<cfif #B5# lt 10><cfset #B5# = "0" & #B5#></cfif>
					<cfoutput><option <cfif EndDay Is B5>Selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>	
			</select></td>			
			<cfoutput>
				<td bgcolor="#tbclr#">Ending Due Day</td>
			</cfoutput>			
		</tr>
	<cfoutput>
			<tr bgcolor="#tdclr#">
				<td><input type="checkbox" <cfif Credit Is 1>checked</cfif> name="Credit" value="1"></td>
				<td bgcolor="#tbclr#">Credit Card Customers</td>
				<td><input type="checkbox" <cfif CheckD Is 1>checked</cfif> name="CheckD" value="1"></td>
				<td bgcolor="#tbclr#">Check Debit Customers</td>						
			</tr>
			<tr bgcolor="#tdclr#">
				<td><input type="checkbox" <cfif GroupSubs Is 1>checked</cfif> name="GroupSubs" value="1"></td>
				<td bgcolor="#tbclr#">Check/ Cash Customers</td>
				<td><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
				<td bgcolor="#tbclr#">Purchase Order Customers</td>
			</tr>
		</cfoutput>		
		<tr>
			<th colspan="4"><input type="image" name="report" src="images/continue.gif" border="0"></th>
		</tr>
		<cfoutput>
		<tr valign="top" bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" colspan="2">Plans</td>
			<td colspan="2" bgcolor="#tbclr#">POPs</td>			
		</tr>
		<tr bgcolor="#tdclr#">
		</cfoutput>
			<td colspan="2"><select name="PlanID" multiple size="6">
				<option <cfif ThePlanID Is "0">selected</cfif> value="0">All Plans
				<cfoutput query="GetPlans">
					<option <cfif ListFind(ThePlanID,PlanID) GT 0>selected</cfif> value="#PlanID#">#PlanDesc#
				</cfoutput>
				<option value="">______________________________
			</select></td>
			<td colspan="2"><select name="POPID" multiple size="6">
				<option <cfif ThePOPID Is 0>selected</cfif> value="0">All POPs
				<cfoutput query="GetPOPS">
					<option <cfif ListFind(ThePOPID,POPID) GT 0>selected</cfif> value="#POPID#">#POPName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
		</tr>
		<cfoutput>
		<tr valign="top" bgcolor="#tdclr#">
			<td colspan="2" bgcolor="#tbclr#">Domains</td>
			<td bgcolor="#tbclr#" colspan="2">Salesperson</td>
		</tr>
		<tr valign="top" bgcolor="#tdclr#">
		</cfoutput>
			<td colspan="2"><select name="DomainID" multiple size="6">
				<option <cfif TheDomainID Is "0">selected</cfif> value="0">All Domains
				<cfoutput query="GetDomains">
					<option <cfif ListFind(TheDomainID,DomainID) GT 0>selected</cfif> value="#DomainID#">#DomainName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
			<td colspan="2"><select name="SalesPID" multiple size="6">
				<option <cfif SalesPID Is "0">selected</cfif> value="0">All Salespersons
				<cfoutput query="GetSalesP">
					<option <cfif ListFind(SalesPID,AdminID) GT 0>selected</cfif> value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="">______________________________
				</select></td>
		</tr>
		<input type="hidden" name="MinAmnt" value="NA">
		<input type="hidden" name="MinCredit" value="NA">
	</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">There is already a customer list in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="20">
				<input type="hidden" name="SendLetterID" value="20">
				<input type="hidden" name="ReturnPage" value="paytype.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Phone,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,ReportTab,Phone,EMail">
				<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="paytype.cfm">
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
 