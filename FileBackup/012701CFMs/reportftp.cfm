<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all the ftp accounts. --->
<!--- 4.0.0 10/23/99 --->
<!--- reportftp.cfm --->

<cfinclude template="security.cfm">


<cfset ReportSecure = "reportftp.cfm">
<cfset ReportID = 36>
<cfset LetterID = 36>
<cfset ShowFilters = "1">
<cfset ShowDateRange = "0">
<cfset CriteriaToSearch = "DueDayBegin,PayCk,DueDayEnd,PayCC,AccntActive,PayCD,AccntDeact,PayPO">
<cfset ShowPPDS = "1">
<cfset ShowDeact = "1">
<cfset ShowCancel = "0">
<cfset ShowSalesOnly = "0">
<cfset ReturnPage = "reportftp.cfm">
<cfset SendHeader = "Name,FTP Type,Login,DomainName,Idle,Connect,Email">
<cfset SendFields = "Name,ReportTab,URL,Address,NumberInt1,NumberInt2,EMail">
<cfset ReportTitle = "FTP Accounts">
<cfset HowWide = "2">
<cfset TheDomainID = "0">
<cfset ThePOPID = "0">
<cfset ThePlanID = "0">
<cfset SalesPID = "0">

<cfif IsDefined("Report.x")>
	<cfquery name="ReportList" datasource="#pds#">
		INSERT INTO GrpLists 
		(FirstName,LastName,AccountID,CancelYN,DeactYN,
		 ReportStr,Address,NumberInt1, NumberInt2,ReportTab,ReportID,
		 AdminID,ReportTitle,TabType,ReportURL,ReportURLID) 
		SELECT C.FirstName, C.LastName, C.AccountID, C.CancelYN, C.DeactivatedYN, 
		F.UserName, F.DomainName, F.Max_Idle1, F.Max_Connect1,CA.FTPDescription, #ReportID#, 
		#MyAdminID#, '#ReportTitle#', 2,	
		'accntftp4.cfm?accntplanid=' + Convert(varchar, AP.AccntPlanID) + '&ftpid=', F.FTPID 
		FROM CustomFTP CA, AccountsFTP F, AccntPlans AP, Accounts C 
		WHERE CA.CFTPID = F.CFTPID 
		AND F.AccntPlanID = AP.AccntPlanID 
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
			AND F.DomainID In (#DomainID#) 
		<cfelse>
			AND F.DomainID In 
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
		AND AP.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>0)
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
 