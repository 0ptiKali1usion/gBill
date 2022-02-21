<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is a list of tax information. --->
<!---	4.0.0 09/16/99 --->
<!-- taxreport.cfm -->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 18 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 18 
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
			AND ReportID = 18 
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
				(#MyAdminID#,18,
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
	<cfset Date1 = CreateDateTime(FromYear,FromMon,FromDay,0,0,0)>
	<cfset Date2 = CreateDateTime(ToYear,ToMon,ToDay,23,59,59)>
	<cfif ReportType Is "Plans">
		<cfquery name="TaxInfo" datasource="#pds#">
			INSERT INTO GrpLists
			(AccountID, AccntPlanID, ReportHeader, Login, Address, CurBal, CurBal2,ReportID,AdminID,City,ReportTitle, CreateDate)
			SELECT T.POPID, T.PlanID, T.MemoField, P.POPName, S.PlanDesc,Sum(T.Debit),
			Sum(T.Debit-T.DebitLeft),18,#MyAdminID#,'Plans','Tax Report by Plans - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', #Now()#
			FROM TransActions T, POPS P, Plans S 
			WHERE T.POPID = P.POPID 
			AND T.PlanID = S.PlanID 
			AND T.TaxYN = 1 
			<cfif PlanID Is Not "0">
				AND T.PlanID In (#PlanID#)
			<cfelse>
				AND T.PlanID In 
					(SELECT PlanID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>
  			<cfif POPID Is Not "0">
				AND T.POPID In (#POPID#)
			<cfelse>
				AND T.POPID In 
					(SELECT POPID 
					 FROM POPAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>			
			<cfif SalesPID Is "0">
				<cfif GetOpts.WhatView Is 0>
					AND T.SalesPersonID = #MyAdminID#
				</cfif>
			<cfelse>
				AND T.SalesPersonID In (#SalesPID#) 
			</cfif>
			<cfif DomainID Is Not "0">
				AND T.AuthDomainID In (0,#DomainID#) 
				AND T.EMailDomainID In (0,#DomainID#) 
				AND T.FTPDomainID In (0,#DomainID#) 
			<cfelse>
				AND (T.AuthDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.AuthDomainID = 0 )
				AND (T.EMailDomainID In 
					  		(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.EMailDomainID = 0)
				AND (T.FTPDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.FTPDomainID = 0)
			</cfif>
			AND T.DateTime1 <= #CreateODBCDateTime(Date2)# 
			AND T.DateTime1 >= #CreateODBCDateTime(Date1)# 
			GROUP BY T.POPID, T.PlanID, T.MemoField, P.POPName, S.PlanDesc 
		</cfquery>
		<cfset SendHeader = "Plan,POP,Tax,Debited,Collected">
		<cfset SendFields = "Address,Login,ReportHeader,CurBal,CurBal2">
	<cfelseif ReportType Is "POPs">
		<cfquery name="TaxInfo" datasource="#pds#">
			INSERT INTO GrpLists 
			(AccountID, ReportHeader, Login, CurBal, CurBal2, ReportID, AdminID,City,ReportTitle, CreateDate)
			SELECT T.POPID, T.MemoField, P.POPName, Sum(T.Debit),
			Sum(T.Debit-T.DebitLeft),18,#MyAdminID#,'POPs','Tax Report by POPs - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', #Now()# 
			FROM Transactions T, POPs P 
			WHERE T.POPID = P.POPID 
			AND TaxYN = 1 
			<cfif PlanID Is Not "0">
				AND T.PlanID In (#PlanID#)
			<cfelse>
				AND T.PlanID In 
					(SELECT PlanID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>
  			<cfif POPID Is Not "0">
				AND T.POPID In (#POPID#)
			<cfelse>
				AND T.POPID In 
					(SELECT POPID 
					 FROM POPAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>			
			<cfif SalesPID Is "0">
				<cfif GetOpts.WhatView Is 0>
					AND T.SalesPersonID = #MyAdminID#
				</cfif>
			<cfelse>
				AND T.SalesPersonID In (#SalesPID#) 
			</cfif>
			<cfif DomainID Is Not "0">
				AND T.AuthDomainID In (0,#DomainID#) 
				AND T.EMailDomainID In (0,#DomainID#) 
				AND T.FTPDomainID In (0,#DomainID#) 
			<cfelse>
				AND (T.AuthDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.AuthDomainID = 0 )
				AND (T.EMailDomainID In 
					  		(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.EMailDomainID = 0)
				AND (T.FTPDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.FTPDomainID = 0)
			</cfif>
			AND T.DateTime1 <= #CreateODBCDateTime(Date2)# 
			AND T.DateTime1 >= #CreateODBCDateTime(Date1)# 
			GROUP BY T.POPID, T.MemoField, P.POPName 
		</cfquery>
		<cfset SendHeader = "POP,Tax,Debited,Collected">
		<cfset SendFields = "Login,ReportHeader,CurBal,CurBal2">
	<cfelseif ReportType Is "Sales">
		<cfquery name="TaxInfo" datasource="#pds#">
			INSERT INTO GrpLists 
			(AccntPlanID, ReportHeader, Login, LastName, FirstName, AccountID, CurBal, CurBal2, ReportID, AdminID,City,ReportTitle, CreateDate)
			SELECT T.POPID, T.MemoField, P.POPName, C.LastName, C.FirstName, C.AccountID, 
			Sum(T.Debit), Sum(T.Debit-T.DebitLeft),18,#MyAdminID#,'Sales',
			'Tax Report by Salesperson - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', #Now()# 
			FROM Transactions T, POPs P, Admin A, Accounts C 
			WHERE T.POPID = P.POPID 
			AND T.SalesPersonID = A.AdminID 
			AND A.AccountID = C.AccountID 
			<cfif PlanID Is Not "0">
				AND T.PlanID In (#PlanID#)
			<cfelse>
				AND T.PlanID In 
					(SELECT PlanID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>
  			<cfif POPID Is Not "0">
				AND T.POPID In (#POPID#)
			<cfelse>
				AND T.POPID In 
					(SELECT POPID 
					 FROM POPAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>			
			<cfif SalesPID Is "0">
				<cfif GetOpts.WhatView Is 0>
					AND T.SalesPersonID = #MyAdminID#
				</cfif>
			<cfelse>
				AND T.SalesPersonID In (#SalesPID#) 
			</cfif>
			<cfif DomainID Is Not "0">
				AND T.AuthDomainID In (0,#DomainID#) 
				AND T.EMailDomainID In (0,#DomainID#) 
				AND T.FTPDomainID In (0,#DomainID#) 
			<cfelse>
				AND (T.AuthDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.AuthDomainID = 0 )
				AND (T.EMailDomainID In 
					  		(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.EMailDomainID = 0)
				AND (T.FTPDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.FTPDomainID = 0)
			</cfif>
			AND TaxYN = 1 
			AND T.DateTime1 <= #CreateODBCDateTime(Date2)# 
			AND T.DateTime1 >= #CreateODBCDateTime(Date1)# 
			GROUP BY T.POPID, T.MemoField, P.POPName, C.LastName, C.FirstName, C.AccountID 
		</cfquery>
		<cfset SendHeader = "Salesperson,POP,Tax,Debited,Collected">
		<cfset SendFields = "Name,Login,ReportHeader,CurBal,CurBal2">
	<cfelseif ReportType Is "Domains">
		<cfquery name="TaxInfo" datasource="#pds#">
			INSERT INTO GrpLists 
			(ReportHeader, Login, AccountID, ReportURLID2, AccntPlanID, CurBal, CurBal2, ReportID, AdminID,City,ReportTitle, CreateDate)
			SELECT T.MemoField, P.POPName, T.EMailDomainID, T.AuthDomainID, T.FTPDomainID, Sum(T.Debit), 
			Sum(T.Debit-T.DebitLeft),18,#MyAdminID#,'Domains','Tax Report by Domain - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', #Now()# 
			FROM Transactions T, POPs P 
			WHERE T.POPID = P.POPID 
			AND TaxYN = 1 
			<cfif PlanID Is Not "0">
				AND T.PlanID In (#PlanID#)
			<cfelse>
				AND T.PlanID In 
					(SELECT PlanID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>
  			<cfif POPID Is Not "0">
				AND T.POPID In (#POPID#)
			<cfelse>
				AND T.POPID In 
					(SELECT POPID 
					 FROM POPAdm 
					 WHERE AdminID = #MyAdminID#)
			</cfif>			
			<cfif SalesPID Is "0">
				<cfif GetOpts.WhatView Is 0>
					AND T.SalesPersonID = #MyAdminID#
				</cfif>
			<cfelse>
				AND T.SalesPersonID In (#SalesPID#) 
			</cfif>
			<cfif DomainID Is Not "0">
				AND T.AuthDomainID In (0,#DomainID#) 
				AND T.EMailDomainID In (0,#DomainID#) 
				AND T.FTPDomainID In (0,#DomainID#) 
			<cfelse>
				AND (T.AuthDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.AuthDomainID = 0 )
				AND (T.EMailDomainID In 
					  		(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.EMailDomainID = 0)
				AND (T.FTPDomainID In 
							(SELECT A.DomainID 
							 FROM DomAdm A
							 WHERE AdminID = #MyAdminID#) 
					  OR T.FTPDomainID = 0)
			</cfif>
			AND T.DateTime1 <= #CreateODBCDateTime(Date2)# 
			AND T.DateTime1 >= #CreateODBCDateTime(Date1)# 
			GROUP BY T.POPID, T.MemoField, P.POPName, T.EMailDomainID, T.AuthDomainID, T.FTPDomainID 
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET GrpLists.Address = D.DomainName 
			FROM Domains D, GrpLists G 
			WHERE D.DomainID = G.AccountID 
		</cfquery>
		<cfquery name="UpdDate" datasource="#pds#">
			UPDATE GrpLists SET GrpLists.Address = D.DomainName 
			FROM Domains D, GrpLists G 
			WHERE D.DomainID = G.ReportURLID2 
			AND G.Address Is Null 
		</cfquery>
		<cfquery name="UpdDate" datasource="#pds#">
			UPDATE GrpLists SET GrpLists.Address = D.DomainName 
			FROM Domains D, GrpLists G 
			WHERE D.DomainID = G.AccntPlanID 
			AND G.Address Is Null 
		</cfquery>
		<cfset SendHeader = "Domain,POP,Tax,Debited,Collected">
		<cfset SendFields = "Address,Login,ReportHeader,CurBal,CurBal2">
	</cfif>
	<cfset SendReportID = 18>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "taxreport.cfm">
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
	<cfset ReportID = 18>
	<cfset BegDay = GetFilter.FirstParam>
	<cfset EndDay = GetFilter.SecondParam>
	<cfset MinAmnt = GetFilter.FirstAction>
	<cfset MinCredit = GetFilter.SecondAction>
	<cfset Credit = GetFilter.FirstField>
	<cfset CheckD = GetFilter.SecondField>
	<cfset Postal = GetFilter.LogicConnect>
	<cfset GroupSubs = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
	<cfset FromMon = GetFilter.FromMon>
	<cfset FromDay = GetFilter.FromDay>
	<cfset FromYear = GetFilter.FromYear>
	<cfset ToMon = GetFilter.ToMon>
	<cfset ToDay = GetFilter.ToDay>
	<cfset ToYear = GetFilter.ToYear>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 18 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 18 
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
	<cfparam name="FromYear" default="#Year(Now())#">
	<cfparam name="FromMon" default="#Month(Now())#">
	<cfparam name="FromDay" default="1">
	<cfparam name="ToYear" default="#Year(Now())#">
	<cfparam name="ToMon" default="#Month(Now())#">
	<cfparam name="ToDay" default="#Day(Now())#">
<cfelse>
	<cfquery name="GetReportType" datasource="#pds#">
		SELECT City 
		FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 18 
	</cfquery>
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

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Tax Report</title>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=18','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
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
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Tax Report</font></th>
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
								<form method="post" action="taxreport.cfm">
									<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
								</form>
								<form method="post" action="taxreport.cfm">
							</cfoutput>
									<td><select name="SavedFilter">
										<cfloop query="SavedFilters">
											<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
										</cfloop>
									</select> <input type="submit" name="UseExisting" value="Load"></td>
								</form>
						</cfif>
	<form name="getdate" method="post" action="taxreport.cfm?RequestTimeout=300" onsubmit="return checkdates();MsgWindow()">
						<cfoutput>
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
			<td><select name="FromMon" onChange="getdays()">
				<cfloop index="B5" From="1" To="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
					<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><select name="FromDay">
				<cfloop index="B4" From="1" To="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif B4 Is 1>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><select name="FromYear" onChange="getdays()">
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
			</select><select name="ToDay">
				<cfloop index="B4" From="1" To="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
					<cfoutput><option <cfif ddd Is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><select name="ToYear" onChange="getdays2()">
				<cfloop index="B3" From="#yy2#" To="#yyy#">
					<cfoutput><option <cfif yyy Is B3>Selected</cfif> value="#B3#" >#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<tr>
			<th colspan="4"><input type="image" name="CreateReport" src="images/viewlist.gif" border="0"></th>
		</tr>
		<cfoutput>
		<tr valign="top" bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" colspan="2"><input checked type="radio" name="ReportType" value="Plans">Plans</td>
			<td colspan="2" bgcolor="#tbclr#"><input type="radio" name="ReportType" value="POPs">POPs</td>
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
			<td colspan="2" bgcolor="#tbclr#"><input type="radio" name="ReportType" value="Domains">Domains</td>
			<td bgcolor="#tbclr#" colspan="2"><input type="radio" name="ReportType" value="Sales">Salesperson</td>
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
		<input type="hidden" name="BegDay" value="1">
		<input type="hidden" name="EndDay" value="31">
		<input type="hidden" name="MinAmnt" value="NA">
		<input type="hidden" name="MinCredit" value="NA">
		<input type="hidden" name="Credit" value="0">
		<input type="hidden" name="CheckD" value="0">
		<input type="hidden" name="GroupSubs" value="0">
		<input type="hidden" name="Postal" value="0">
	</form>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">There is already a tax report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="18">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="taxreport.cfm">
				<cfif GetReportType.City Is "Plans">
					<input type="hidden" name="SendHeader" value="Plan,POP,Tax,Debited,Collected">
					<input type="hidden" name="SendFields" value="Address,Login,ReportHeader,CurBal,CurBal2">
				<cfelseif GetReportType.City Is "POPs">
					<input type="hidden" name="SendHeader" value="POP,Tax,Debited,Collected">
					<input type="hidden" name="SendFields" value="Login,ReportHeader,CurBal,CurBal2">
				<cfelseif GetReportType.City Is "Domains">
					<input type="hidden" name="SendHeader" value="Domain,POP,Tax,Debited,Collected">
					<input type="hidden" name="SendFields" value="Address,Login,ReportHeader,CurBal,CurBal2">
				<cfelseif GetReportType.City Is "Sales">
					<input type="hidden" name="SendHeader" value="Salesperson,POP,Tax,Debited,Collected">
					<input type="hidden" name="SendFields" value="Name,Login,ReportHeader,CurBal,CurBal2">
				</cfif>
				<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="taxreport.cfm">
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
   