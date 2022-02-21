<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a list of customers with a credit. --->
<!---	4.0.0 09/03/99 --->
<!--- balcredit.cfm --->

<cfinclude template="security.cfm">

<cfset ReportSecure = "balcredit.cfm">
<cfset ReportID = 5>
<cfset LetterID = 5>
<cfset ShowFilters = "1">
<cfset ShowLogicNameA = "0">
<cfset ShowLogicNameB = "0">
<cfset ShowDateRange = "0">
<cfset CriteriaToSearch = "DueDayBegin,PayCk,DueDayEnd,PayCC,CreditMin,PayCD,CreditMax,PayPO,Null,AccntCancel,Null,AccntDeact">
<cfset ShowPPDS = "1">
<cfset ShowDeact = "1">
<cfset ShowCancel = "1">
<cfset ShowSalesOnly = "0">
<cfset ReturnPage = "balcredit.cfm">
<cfset SendHeader = "Name,Company,Amount,Phone,E-Mail">
<cfset SendFields = "Name,Company,CurBal,Phone,EMail">
<cfset ReportTitle = "Customers With Credit">
<cfset HowWide = "2">
<cfset TheDomainID = "0">
<cfset ThePOPID = "0">
<cfset ThePlanID = "0">
<cfset TheSalesPID = "0">
<cfset FirstDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone,EMail;EMail Address,Auth;Auth Login,FTP; FTP Login,Accountid;User ID">
<cfset SecondDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone">

<cfif IsDefined("Report.x")>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'Locale'
	</cfquery>
	<cfset Locale = GetLocale.Value1>
	<cfquery name="getit" datasource="#pds#">
		INSERT INTO GrpLists 
		(LastName, FirstName, Login, City, AccountID, Company, Phone, ReportHeader, 
		 ReportID, AdminID, ReportTitle, CurBal, CreateDate) 
		SELECT A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Company, 
		A.DayPhone, '#CreditMin#', #ReportID#, #MyAdminID#, 
		'Customers with Credit', SUM (T.CreditLeft - T.DebitLeft ), #Now()# 
		FROM Accounts A, Transactions T 
		WHERE A.AccountID = T.AccountID 
		<cfif Not IsDefined("Form.AccntCancel")>
			AND A.CancelYN = 0 
		</cfif>
		<cfif Not IsDefined("Form.AccntDeact")>
			AND A.DeactivatedYN = 0 
		</cfif>
		<cfif DomainID Is 0>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccountsAuth 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)
				 UNION 
				 SELECT AccountID 
				 FROM AccountsFTP 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)
				 UNION 
				 SELECT AccountID 
				 FROM AccountsEMail 
				 WHERE DomainID In 
				 	(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)
				 UNION 
				 SELECT AccountID 
				 FROM AccntPlans 
				 WHERE AccntPlanID Not In 
				 	(SELECT AccntPlanID 
					 FROM AccountsAuth 
					 WHERE DomainID In 
					 	(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#)
					 UNION 
					 SELECT AccntPlanID 
					 FROM AccountsFTP 
					 WHERE DomainID In 
					 	(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#)
					 UNION 
					 SELECT AccntPlanID 
					 FROM AccountsEMail 
					 WHERE DomainID In 
					 	(SELECT DomainID 
						 FROM DomAdm 
						 WHERE AdminID = #MyAdminID#)
					)
				)
		<cfelse>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccountsAuth 
				 WHERE DomainID In (#DomainID#) 
				 UNION 
				 SELECT AccountID 
				 FROM AccountsFTP 
				 WHERE DomainID In (#DomainID#) 
				 UNION 
				 SELECT AccountID 
				 FROM AccountsEMail 
				 WHERE DomainID In (#DomainID#) 
				 UNION 
				 SELECT AccountID 
				 FROM AccntPlans 
				 WHERE AccntPlanID Not In 
				 	(SELECT AccntPlanID 
					 FROM AccountsAuth 
					 WHERE DomainID In (#DomainID#) 
					 UNION 
					 SELECT AccntPlanID 
					 FROM AccountsFTP 
					 WHERE DomainID In (#DomainID#) 
					 UNION 
					 SELECT AccntPlanID 
					 FROM AccountsEMail 
					 WHERE DomainID In (#DomainID#)
					) 
				)
		</cfif>
		<cfif PlanID Is 0>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE PlanID In 
				 	(SELECT PlanID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
				)
		<cfelse>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE PlanID In (#PlanID#)
				)
		</cfif>
		<cfif POPID Is 0>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE POPID In 
				 	(SELECT POPID 
					 FROM PlanAdm 
					 WHERE AdminID = #MyAdminID#)
				)
		<cfelse>
			AND A.AccountID In 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE POPID In (#POPID#)
				)
		</cfif>
		<cfif SalesPID Is 0>
			AND A.SalesPersonID In 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#)
		<cfelse>
			AND A.SalesPersonID In (#SalesPID#)
		</cfif>
		AND A.AccountID In 
			(SELECT AccountID 
			 FROM AccntPlans AP 
			 WHERE PayBy In (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>0) 
			 AND (AP.NextDueDate Is Null 
			 		OR (DatePart(dd,AP.NextDueDate) <= #DueDayEnd# 
						 AND DatePart(dd,AP.NextDueDate) >= #DueDayBegin#)
					)
			)
		GROUP BY A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Company, 
		A.DayPhone 
		<cfif IsNumeric(CreditMin) OR IsNumeric(CreditMax)>
			Having 
			<cfif IsNumeric(CreditMin)>
				SUM(T.CreditLeft - T.DebitLeft) > #CreditMin# 
			</cfif>
			<cfif IsNumeric(CreditMin) AND IsNumeric(CreditMax)>
				AND 
			</cfif>
			<cfif IsNumeric(CreditMax)>
				SUM (T.CreditLeft - T.DebitLeft) < #CreditMax# 
			</cfif>
		<cfelse>
			Having SUM(T.CreditLeft - T.DebitLeft) >= 0.01
		</cfif>
	</cfquery>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = #ReportID# 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = #LetterID#  
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="No">
<cfinclude template="reportpage.cfm">
  