<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Limit Report. --->
<!---	4.0.0 11/02/99 --->
<!--- accntreport.cfm --->

<cfinclude template="security.cfm">

<cfset ReportSecure = "accntreport.cfm">
<cfset ReportID = 34>
<cfset LetterID = 34>
<cfset ShowFilters = "1">
<cfset CriteriaToSearch = "DueDayBegin,PayCk,DueDayEnd,PayCC,Null,PayCD,Null,PayPO">
<cfset ShowPPDS = "1">
<cfset ShowDeact = "1">
<cfset ShowCancel = "0">
<cfset ShowSalesOnly = "0">
<cfset ReturnPage = "accntreport.cfm">
<cfset SendHeader = "Name,Plan,Type,Limit,Actual,E-Mail">
<cfset SendFields = "Name,Address,ReportTab,Phone,PhoneWk,EMail">
<cfset ReportTitle = "Accounts Over Limits">
<cfset HowWide = "2">
<cfset TheDomainID = "0">
<cfset ThePOPID = "0">
<cfset ThePlanID = "0">
<cfset TheSalesPID = "0">
<cfset FirstDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone,EMail;EMail Address,Auth;Auth Login,FTP; FTP Login,Accountid;User ID">
<cfset SecondDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone">

<cfif IsDefined("Report.x")>
	<cfquery name="ReportList" datasource="#pds#">
		INSERT INTO GrpLists 
		(FirstName,LastName,AccountID,Phone,Address,PhoneWk,ReportTab,
		 ReportID, AdminID, ReportTitle, TabType) 
		SELECT A.FirstName, A.LastName, A.AccountID, P.AuthNumber As IntNumber, P.PlanDesc, Count(AA.AuthID), 'Authentication', 
		#ReportID#, #MyAdminID#, '#ReportTitle#', 2 
		FROM Accounts A, AccntPlans AP, AccountsAuth AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND DatePart(dd,AP.NextDueDate) <= #DueDayEnd# 
		AND DatePart(dd,AP.NextDueDate) >= #DueDayBegin# 
		<cfif DomainID Is NOT 0>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsAuth 
				 WHERE DomainID In (#DomainID#) 
				)
		<cfelse>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsAuth 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				)
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
			AND A.SalesPersonID IN (#SalesPID#) 
		<cfelse>
			AND A.SalesPersonID IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		AND AP.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>0)
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.AuthNumber, P.PlanDesc 
		HAVING Count(AA.AuthID) > P.AuthNumber
		UNION 
		SELECT A.FirstName, A.LastName, A.AccountID, P.FTPNumber As IntNumber, P.PlanDesc, Count(AA.FTPID), 'FTP', 
		#ReportID#, #MyAdminID#, '#ReportTitle#', 2 
		FROM Accounts A, AccntPlans AP, AccountsFTP AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND DatePart(dd,AP.NextDueDate) <= #DueDayEnd# 
		AND DatePart(dd,AP.NextDueDate) >= #DueDayBegin# 
		<cfif DomainID Is NOT 0>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsFTP 
				 WHERE DomainID In (#DomainID#) 
				)
		<cfelse>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsFTP 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				)
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
			AND A.SalesPersonID IN (#SalesPID#) 
		<cfelse>
			AND A.SalesPersonID IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		AND AP.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>0)
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.FTPNumber, P.PlanDesc 
		HAVING Count(AA.FTPID) > P.FTPNumber
		UNION
		SELECT A.FirstName, A.LastName, A.AccountID, P.FreeEMails As IntNumber, P.PlanDesc, Count(AA.EMailID), 'EMail', 
		#ReportID#, #MyAdminID#, '#ReportTitle#', 2 
		FROM Accounts A, AccntPlans AP, AccountsEMail AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND DatePart(dd,AP.NextDueDate) <= #DueDayEnd# 
		AND DatePart(dd,AP.NextDueDate) >= #DueDayBegin# 
		<cfif DomainID Is NOT 0>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsEMail 
				 WHERE DomainID In (#DomainID#) 
				)
		<cfelse>
			AND AP.AccountID In 
				(SELECT AccountID 
				 FROM AccountsEMail 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				)
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
			AND A.SalesPersonID IN (#SalesPID#) 
		<cfelse>
			AND A.SalesPersonID IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		AND AP.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>0)
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.FreeEMails, P.PlanDesc 
		HAVING Count(AA.EMailID) > P.FreeEMails 
	</cfquery>
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
 