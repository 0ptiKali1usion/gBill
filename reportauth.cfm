<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all the authentication accounts. --->
<!--- 4.0.1 02/07/01 Fixed the error with PayBy
		4.0.0 10/23/99 --->
<!--- reportauth.cfm --->

<cfinclude template="security.cfm">

<cfset ReportSecure = "reportauth.cfm">
<cfset ReportID = 35>
<cfset LetterID = 35>
<cfset ShowFilters = "1">
<cfset ShowDateRange = "0">
<cfset CriteriaToSearch = "DueDayBegin,PayCk,DueDayEnd,PayCC,AccntActive,PayCD,AccntDeact,PayPO">
<cfset ShowPPDS = "1">
<cfset ShowDeact = "1">
<cfset ShowCancel = "0">
<cfset ShowSalesOnly = "0">
<cfset ReturnPage = "reportauth.cfm">
<cfset SendHeader = "Name,Auth Type,Login,DomainName,Type,IP,Idle,Connect,Logins,Email">
<cfset SendFields = "Name,ReportTab,URL,Address,Phone,Company,NumberInt1,NumberInt2,AccntPlanID,EMail">
<cfset ReportTitle = "Authentication Accounts">
<cfset HowWide = "2">
<cfset TheDomainID = "0">
<cfset ThePOPID = "0">
<cfset ThePlanID = "0">
<cfset SalesPID = "0">

<cfif IsDefined("Report.x")>
	<cfquery name="ReportList" datasource="#pds#">
		INSERT INTO GrpLists 
		(FirstName,LastName,AccountID,CancelYN,DeactYN,ReportStr,Address,Phone,
		 Company, NumberInt1, NumberInt2, AccntPlanID, 
		 ReportTab,ReportID,AdminID,ReportTitle,TabType,ReportURL,ReportURLID) 
		SELECT C.FirstName, C.LastName, C.AccountID, C.CancelYN, C.DeactivatedYN, 
		A.UserName, A.DomainName, A.Filter1, 
		A.IP_Address, A.Max_Idle, A.Max_Connect, A.Max_Logins, 
		CA.AuthDescription, #ReportID#, #MyAdminID#, '#ReportTitle#', 2, 
		'accntmanage4.cfm?accntplanid=' + Convert(varchar, AP.AccntPlanID) + '&authid=', A.AuthID  
		FROM CustomAuth CA, AccountsAuth A, AccntPlans AP, Accounts C 
		WHERE CA.CAuthID = A.CAuthID 
		AND A.AccntPlanID = AP.AccntPlanID 
		AND AP.AccountID = C.AccountID 
		<cfif IsDefined("AccntActive") AND IsDefined("AccntDeact")>
			AND C.CancelYN = 0 
		<cfelseif IsDefined("AccntActive") AND NOT IsDefined("AccntDeact")>
			AND C.CancelYN = 0 
			AND C.DeactivatedYN = 0 
		<cfelseif NOT IsDefined("AccntActive") AND IsDefined("AccntDeact")>
			AND C.CancelYN = 0 
			AND C.DeactivatedYN = 1 
		<cfelseif NOT IsDefined("AccntActive") AND NOT IsDefined("AccntDeact")>
			AND C.CancelYN = 1
		</cfif>
		AND DatePart(dd,AP.NextDueDate) <= #DueDayEnd# 
		AND DatePart(dd,AP.NextDueDate) >= #DueDayBegin# 
		<cfif DomainID Is NOT 0>
			AND A.DomainID In (#DomainID#) 
		<cfelse>
			AND A.DomainID In 
				(SELECT DomainID 
				 FROM DomAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		<cfif PlanID Is NOT 0>
			AND AP.PlanID IN (#PlanID#)
		<cfelse>
			AND AP.PlanID IN 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		<cfif POPID Is NOT 0>
			AND AP.POPID IN (#POPID#) 
		<cfelse>
			AND AP.POPID IN 
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		<cfif SalesPID Is NOT 0>
			AND C.SalesPersonID IN (#SalesPID#) 
		<cfelse>
			AND C.SalesPersonID IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		AND AP.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>'0')
	</cfquery>
	<cfquery name="CheckForTabs" datasource="#pds#">
		SELECT ReportTab 
		FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		GROUP BY ReportTab 
	</cfquery>
	<cfif CheckForTabs.RecordCount Is 1>
		<cfset Pos1 = ListFindNoCase(SendFields,"ReportTab")>
		<cfset SendFields = ListDeleteAt(SendFields,Pos1)>
		<cfset SendHeader = ListDeleteAt(SendHeader,Pos1)>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check/Cash' 
		WHERE ReportTab = 'ck'
		AND AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Credit Card' 
		WHERE ReportTab = 'cc'
		AND AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check Debit' 
		WHERE ReportTab = 'cd'
		AND AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
	</cfquery>
	<cfquery name="UpdTypes" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Purchase Order' 
		WHERE ReportTab = 'po'
		AND AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
<cfinclude template="reportpage.cfm">
  