<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a list of all customers that owe. --->
<!--- 4.0.0 09/06/99 --->
<!--- baldue.cfm --->

<cfset ReportSecure = "baldue.cfm">
<cfset ReportID = 8>
<cfset LetterID = 8>
<cfset ShowFilters = "1">
<cfset ShowLogicNameA = "1">
<cfset CriteriaToSearch = "DueDayBegin,PayCk,DueDayEnd,PayCC,OwedMin,PayCD,AccntDeact,PayPO,AccntCancel,Null">
<cfset ShowPPDS = "1">
<cfset ShowDeact = "1">
<cfset ShowCancel = "1">
<cfset ShowSalesOnly = "0">
<cfset ReturnPage = "baldue.cfm">
<cfset SendHeader = "Name,Company,Plan,Pay By,Amount,Phone,E-Mail">
<cfset SendFields = "Name,Company,TextField,ReportTab,CurBal,Phone,EMail">
<cfset ReportTitle = "Customers Due">
<cfset HowWide = "2">
<cfset TheDomainID = "0">
<cfset ThePOPID = "0">
<cfset ThePlanID = "0">
<cfset TheSalesPID = "0">
<cfset FirstDropDown = "0;None,LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone,EMail;EMail Address,Auth;Auth Login,FTP; FTP Login,Accountid;User ID">
<cfset SecondDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone">

<cfif IsDefined("Report.x")>
	<cfquery name="InsData" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, AccntPlanID, NumberFloat1, NumberInt1, NumberInt2, ReportTab, CurBal, 
		 AdminID, ReportID, ReportTitle, TabType, CreateDate) 
		SELECT T.AccountID, P.AccntPlanID, T.AccntPlanID, P.PlanID, T.PlanID, P.PayBy, Sum(T.DebitLeft), 
		#MyAdminID#, #ReportID#, 'Customers Due', 2, #Now()# 
		FROM TransActions T, AccntPlans P 
		WHERE T.AccntPlanID *= P.AccntPlanID 
		AND DatePart(dd,P.NextDueDate) <= #DueDayEnd# 
		AND DatePart(dd,P.NextDueDate) >= #DueDayBegin# 
		AND P.PayBy IN (<cfif IsDefined("PayCk")>'ck',</cfif><cfif IsDefined("PayCC")>'cc',</cfif><cfif IsDefined("PayCD")>'cd',</cfif><cfif IsDefined("PayPO")>'po',</cfif>'0') 
		<cfif FirstParam Is Not "0">
			AND T.AccountID IN 
				(SELECT AccountID 
				 FROM Accounts A 
				 WHERE <cfif FirstParam Is Not "AccountID">A.#FirstParam#<cfelse>Convert(varchar(10),A.AccountID)</cfif> 
				 <cfif FirstAction Is "Starts">Like '#FirstField#%' 
				 <cfelseif FirstAction Is "Contains">Like '%#FirstField#%' 
				 <cfelseif FirstAction Is "Like">Like '#FirstField#' 
				 <cfelseif FirstAction Is "NotStarts">Not Like '#FirstField#%' 
				 <cfelseif FirstAction Is "NotContains">Not Like '%#FirstField#%' 
				 <cfelseif FirstAction Is "Not">Not Like '#FirstField#' 
				 </cfif>
				)
		</cfif>
		<cfif DomainID Is 0>
			AND P.AccountID In 
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
			AND P.AccountID In 
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
			AND P.PlanID In 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND P.PlanID In (#PlanID#) 
		</cfif>
		<cfif POPID Is 0>
			AND P.POPID In 
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#) 
		<cfelse>
			AND P.POPID In (#POPID#) 
		</cfif>
		GROUP BY T.AccountID, P.AccntPlanID, T.AccntPlanID, P.PlanID, T.PlanID, P.PayBy 
		<cfif OwedMin Is "NA">
			HAVING Sum(T.DebitLeft) > 0.009 
		<cfelse>
			HAVING Sum(T.DebitLeft) > #OwedMin# 
		</cfif>
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		FirstName = E.FirstName, 
		LastName = E.LastName, 
		City = E.City, 
		Address = E.Address1, 
		Phone = E.DayPhone, 
		Company = E.Company, 
		DeactYN = E.DeactivatedYN, 
		CancelYN = E.CancelYN, 
		NumberFloat2 = E.SalesPersonID 
		FROM Accounts E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND G.ReportID = #ReportID# 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="RemoveSome" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		AND NumberFloat2 NOT IN 
			<cfif SalesPID Is 0>
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#) 
			<cfelse>
				(#SalesPID#) 
			</cfif>
	</cfquery>
	<cfif NOT IsDefined("Form.AccntCancel")>
		<cfquery name="RemoveCancels" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE CancelYN = 1 
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfif NOT IsDefined("Form.AccntDeact")>
		<cfquery name="RemoveDeacts" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE DeactYN = 1 
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		TextField = Convert(varchar, G.AccntPlanID) + ' ' + P.PlanDesc 
		FROM Plans P, GrpLists G 
		WHERE P.PlanID = G.NumberInt1 
		AND G.ReportID = #ReportID# 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		TextField = Convert(varchar, G.NumberFloat1) + ' ' + P.PlanDesc 
		FROM Plans P, GrpLists G 
		WHERE P.PlanID = G.NumberInt2 
		AND G.ReportID = #ReportID# 
		AND G.AdminID = #MyAdminID# 
		AND G.TextField Is Null
	</cfquery>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG, ReportTab) 
			VALUES 
			(#ReportID#, #MyAdminID#, 'debitcc.cfm', 'debitall.gif', 'Credit Card')
		</cfquery>
	</cfif>
	<cfquery name="SetDef" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Unknown' 
		WHERE ReportTab Is Null 
		AND ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = #ReportID# 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfif IsDefined("PayCk")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			ReportTab = 'Check' 
			WHERE ReportTab = 'ck'
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	<cfelse>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'ck' 
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'check' 
		</cfquery>
	</cfif>
	<cfif IsDefined("PayCD")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			ReportTab = 'Check Debit' 
			WHERE ReportTab = 'cd'
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	<cfelse>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'cd' 
		</cfquery>
	</cfif>
	<cfif IsDefined("PayCC")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			ReportTab = 'Credit Card' 
			WHERE ReportTab = 'cc'
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	<cfelse>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'cc' 
		</cfquery>
	</cfif>
	<cfif IsDefined("PayPO")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			ReportTab = 'Purchase Order' 
			WHERE ReportTab = 'po'
			AND ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
		</cfquery>
	<cfelse>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = #ReportID# 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'po' 
		</cfquery>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="No">
<cfinclude template="reportpage.cfm">
 