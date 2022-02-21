<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 04/11/00 --->
<!--- accntnew3.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfparam name="Taxable" default="1">
<cfparam name="WaiveFee" default="0">

<cfquery name="CurPlan" datasource="#pds#">
	SELECT PlanDesc, PlanID, RecurringAmount, RecurringCycle, RecurDiscount, FixedAmount, 
	RAMemo, RDMemo, FAMemo, FDMemo, FixedDiscount, DefAuthServer, DefMailServer, 
	DefFTPServer, SynchBillingYN, SynchDays, ProRatePYN, ProRateCutDays, 
	Taxable, Taxable2, Taxable3, Taxable4, PayDueDays, DeactDays 
	FROM Plans 
	WHERE PlanID = #NewPlanID# 
</cfquery>

<cfset TotalFA1 = 0>
<cfset TotalFD1 = 0>
<cfset TotalRA1 = 0>
<cfset TotalRD1 = 0>
<cfset TotalRA2 = 0>
<cfset TotalRD2 = 0>
<cfset TodayDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
<cfset PayTillDays = DaysInMonth(Now())>

<cfif CurPlan.SynchBillingYN Is 1>
	<cfset TodayDay = Day(Now())>
	<cfloop index="B6" list="#CurPlan.SynchDays#">
		<cfif TodayDay LTE B6>
			<cfset TodayDay = B6>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfif ListFind("#CurPlan.SynchDays#","#TodayDay#") Is 0>
		<cfset TodayDay = ListGetAt(CurPlan.SynchDays,1)>
	</cfif>
	<cfif TodayDay GT PayTillDays>
		<cfset TodayDay = PayTillDays>
	</cfif>
	<cfset PayTill = CreateDateTime(Year(Now()), Month(Now()), TodayDay, 0, 0, 0)>
	<cfif PayTill LT Now()>
		<cfset PayTill = DateAdd("m",CurPlan.RecurringCycle,PayTill)>
	</cfif>
	<cfset DaysDiff = DateDiff("d",TodayDate,PayTill)>
	<cfif DaysDiff LTE CurPlan.ProrateCutDays>
		<cfset NextDue2 = DateAdd("m",CurPlan.RecurringCycle,PayTill)>
		<cfset NextDue2 = DateAdd("d",-1,NextDue2)>
	</cfif>
	<cfset NextDue = PayTill>
<cfelse>
	<cfset NextDue = DateAdd("m",CurPlan.RecurringCycle,Now())>
	<cfset DaysDiff = DateDiff("d",TodayDate,NextDue)>
</cfif>
<cfset NextDueDisp = DateAdd("d",-1,NextDue)>
<cfif CurPlan.ProRatePYN Is 1>
	<cfset Date1 = TodayDate>
	<cfset Date2 = DateAdd("m",CurPlan.RecurringCycle,TodayDate)>
	<cfset NumDays = DateDiff("d",Date1,Date2)>

	<cfset TotalFA1 = TotalFA1 + CurPlan.FixedAmount>
	<cfset TotalFD1 = TotalFD1 + CurPlan.FixedDiscount>
	<cfset TotalRA1 = TotalRA1 + ((CurPlan.RecurringAmount/NumDays)*DaysDiff)>
	<cfset TotalRD1 = TotalRD1 + ((CurPlan.RecurDiscount/NumDays)*DaysDiff)>

	<cfif DaysDiff LTE CurPlan.ProrateCutDays>
		<cfset TotalRA2 = TotalRA2 + CurPlan.RecurringAmount>
		<cfset TotalRD2 = TotalRD2 + CurPlan.RecurDiscount>
	<cfelse>
		<cfset TotalRA2 = TotalRA2 + 0>
		<cfset TotalRD2 = TotalRD2 + 0>
	</cfif>
<cfelse>	
	<cfif DaysDiff LTE CurPlan.ProrateCutDays>
		<cfset TotalFA1 = TotalFA1 + CurPlan.FixedAmount>
		<cfset TotalFD1 = TotalFD1 + CurPlan.FixedDiscount>
		<cfset TotalRA1 = TotalRA1 + CurPlan.RecurringAmount>
		<cfset TotalRD1 = TotalRD1 + CurPlan.RecurDiscount>
		<cfset TotalRA2 = TotalRA2 + CurPlan.RecurringAmount>
		<cfset TotalRD2 = TotalRD2 + CurPlan.RecurDiscount>
	<cfelse>
		<cfset TotalFA1 = TotalFA1 + CurPlan.FixedAmount>
		<cfset TotalFD1 = TotalFD1 + CurPlan.FixedDiscount>
		<cfset TotalRA1 = TotalRA1 + CurPlan.RecurringAmount>
		<cfset TotalRD1 = TotalRD1 + CurPlan.RecurDiscount>
		<cfset TotalRA2 = TotalRA2 + 0>
		<cfset TotalRD2 = TotalRD2 + 0>
	</cfif>
</cfif>
<cfif WaiveFee Is 1>
	<cfset TotalFA1 = 0>
	<cfset TotalFD1 = 0>
</cfif>

<cfquery name="POPInfo" datasource="#pds#">
	SELECT Tax1, Tax2, Tax3, Tax4, TaxDesc1, TaxDesc2, TaxDesc3, TaxDesc4, Tax1Type, 
	Tax2Type, Tax3Type, Tax4Type 
	FROM POPs 
	WHERE POPID = #POPID# 
</cfquery>
<cfset TaxType1 = 0>
<cfset TaxType2 = 0>
<cfset TaxType3 = 0>
<cfset TaxType4 = 0>

<cfif (CurPlan.Taxable GT 0) AND (Taxable Is 1)>
	<!--- Plans 0 = Taxfree  1= Service  2 = Good --->
	<!--- POPs  0 = Service  1 = Good --->
	<cfif POPInfo.Tax1 Is Not "">
		<cfif (CurPlan.Taxable Is 1) AND (POPInfo.Tax1Type Is 0)>
			<cfset TaxType1 = TaxType1 + (TotalRA1 * (POPInfo.Tax1/100))>
			<cfset TaxType1 = TaxType1 + (TotalRA2 * (POPInfo.Tax1/100))>
		<cfelseif (CurPlan.Taxable Is 2) AND (POPInfo.Tax1Type Is 1)>
			<cfset TaxType1 = TaxType1 + (TotalRA1 * (POPInfo.Tax1/100))>
			<cfset TaxType1 = TaxType1 + (TotalRA2 * (POPInfo.Tax1/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax2 Is Not "">
		<cfif (CurPlan.Taxable Is 1) AND (POPInfo.Tax2Type Is 0)>
			<cfset TaxType2 = TaxType2 + (TotalRA1 * (POPInfo.Tax2/100))>
			<cfset TaxType2 = TaxType2 + (TotalRA2 * (POPInfo.Tax2/100))>
		<cfelseif (CurPlan.Taxable Is 2) AND (POPInfo.Tax2Type Is 1)>
			<cfset TaxType2 = TaxType2 + (TotalRA1 * (POPInfo.Tax2/100))>
			<cfset TaxType2 = TaxType2 + (TotalRA2 * (POPInfo.Tax2/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax3 Is Not "">
		<cfif (CurPlan.Taxable Is 1) AND (POPInfo.Tax3Type Is 0)>
			<cfset TaxType3 = TaxType3 + (TotalRA1 * (POPInfo.Tax3/100))>
			<cfset TaxType3 = TaxType3 + (TotalRA2 * (POPInfo.Tax3/100))>
		<cfelseif (CurPlan.Taxable Is 2) AND (POPInfo.Tax3Type Is 1)>
			<cfset TaxType3 = TaxType3 + (TotalRA1 * (POPInfo.Tax3/100))>
			<cfset TaxType3 = TaxType3 + (TotalRA2 * (POPInfo.Tax3/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax4 Is Not "">
		<cfif (CurPlan.Taxable Is 1) AND (POPInfo.Tax4Type Is 0)>
			<cfset TaxType4 = TaxType4 + (TotalRA1 * (POPInfo.Tax4/100))>
			<cfset TaxType4 = TaxType4 + (TotalRA2 * (POPInfo.Tax4/100))>
		<cfelseif (CurPlan.Taxable Is 2) AND (POPInfo.Tax4Type Is 1)>
			<cfset TaxType4 = TaxType4 + (TotalRA1 * (POPInfo.Tax4/100))>
			<cfset TaxType4 = TaxType4 + (TotalRA2 * (POPInfo.Tax4/100))>
		</cfif>
	</cfif>
</cfif>
<cfif (CurPlan.Taxable2 GT 0) AND (Taxable Is 1)>
	<!--- Plans 0 = Taxfree  1= Service  2 = Good --->
	<!--- POPs  0 = Service  1 = Good --->
	<cfif POPInfo.Tax1 Is Not "">
		<cfif (CurPlan.Taxable2 Is 1) AND (POPInfo.Tax1Type Is 0)>
			<cfset TaxType1 = TaxType1 - (TotalRD1 * (POPInfo.Tax1/100))>
			<cfset TaxType1 = TaxType1 - (TotalRD2 * (POPInfo.Tax1/100))>
		<cfelseif (CurPlan.Taxable2 Is 2) AND (POPInfo.Tax1Type Is 1)>
			<cfset TaxType1 = TaxType1 - (TotalRD1 * (POPInfo.Tax1/100))>
			<cfset TaxType1 = TaxType1 - (TotalRD2 * (POPInfo.Tax1/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax2 Is Not "">
		<cfif (CurPlan.Taxable2 Is 1) AND (POPInfo.Tax2Type Is 0)>
			<cfset TaxType2 = TaxType2 - (TotalRD1 * (POPInfo.Tax2/100))>
			<cfset TaxType2 = TaxType2 - (TotalRD2 * (POPInfo.Tax2/100))>
		<cfelseif (CurPlan.Taxable2 Is 2) AND (POPInfo.Tax2Type Is 1)>
			<cfset TaxType2 = TaxType2 - (TotalRD1 * (POPInfo.Tax2/100))>
			<cfset TaxType2 = TaxType2 - (TotalRD2 * (POPInfo.Tax2/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax3 Is Not "">
		<cfif (CurPlan.Taxable2 Is 1) AND (POPInfo.Tax3Type Is 0)>
			<cfset TaxType3 = TaxType3 - (TotalRD1 * (POPInfo.Tax3/100))>
			<cfset TaxType3 = TaxType3 - (TotalRD2 * (POPInfo.Tax3/100))>
		<cfelseif (CurPlan.Taxable2 Is 2) AND (POPInfo.Tax3Type Is 1)>
			<cfset TaxType3 = TaxType3 - (TotalRD1 * (POPInfo.Tax3/100))>
			<cfset TaxType3 = TaxType3 - (TotalRD2 * (POPInfo.Tax3/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax4 Is Not "">
		<cfif (CurPlan.Taxable2 Is 1) AND (POPInfo.Tax4Type Is 0)>
			<cfset TaxType4 = TaxType4 - (TotalRD1 * (POPInfo.Tax4/100))>
			<cfset TaxType4 = TaxType4 - (TotalRD2 * (POPInfo.Tax4/100))>
		<cfelseif (CurPlan.Taxable2 Is 2) AND (POPInfo.Tax4Type Is 1)>
			<cfset TaxType4 = TaxType4 - (TotalRD1 * (POPInfo.Tax4/100))>
			<cfset TaxType4 = TaxType4 - (TotalRD2 * (POPInfo.Tax4/100))>
		</cfif>
	</cfif>
</cfif>
<cfif (CurPlan.Taxable3 GT 0) AND (Taxable Is 1)>
	<!--- Plans 0 = Taxfree  1= Service  2 = Good --->
	<!--- POPs  0 = Service  1 = Good --->
	<cfif POPInfo.Tax1 Is Not "">
		<cfif (CurPlan.Taxable3 Is 1) AND (POPInfo.Tax1Type Is 0)>
			<cfset TaxType1 = TaxType1 + (TotalFA1 * (POPInfo.Tax1/100))>
		<cfelseif (CurPlan.Taxable3 Is 2) AND (POPInfo.Tax1Type Is 1)>
			<cfset TaxType1 = TaxType1 + (TotalFA1 * (POPInfo.Tax1/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax2 Is Not "">
		<cfif (CurPlan.Taxable3 Is 1) AND (POPInfo.Tax2Type Is 0)>
			<cfset TaxType2 = TaxType2 + (TotalFA1 * (POPInfo.Tax2/100))>
		<cfelseif (CurPlan.Taxable3 Is 2) AND (POPInfo.Tax2Type Is 1)>
			<cfset TaxType2 = TaxType2 + (TotalFA1 * (POPInfo.Tax2/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax3 Is Not "">
		<cfif (CurPlan.Taxable3 Is 1) AND (POPInfo.Tax3Type Is 0)>
			<cfset TaxType3 = TaxType3 + (TotalFA1 * (POPInfo.Tax3/100))>
		<cfelseif (CurPlan.Taxable3 Is 2) AND (POPInfo.Tax3Type Is 1)>
			<cfset TaxType3 = TaxType3 + (TotalFA1 * (POPInfo.Tax3/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax4 Is Not "">
		<cfif (CurPlan.Taxable3 Is 1) AND (POPInfo.Tax4Type Is 0)>
			<cfset TaxType4 = TaxType4 + (TotalFA1 * (POPInfo.Tax4/100))>
		<cfelseif (CurPlan.Taxable3 Is 2) AND (POPInfo.Tax4Type Is 1)>
			<cfset TaxType4 = TaxType4 + (TotalFA1 * (POPInfo.Tax4/100))>
		</cfif>
	</cfif>
</cfif>
<cfif (CurPlan.Taxable4 GT 0) AND (Taxable Is 1)>
	<!--- Plans 0 = Taxfree  1= Service  2 = Good --->
	<!--- POPs  0 = Service  1 = Good --->
	<cfif POPInfo.Tax1 Is Not "">
		<cfif (CurPlan.Taxable4 Is 1) AND (POPInfo.Tax1Type Is 0)>
			<cfset TaxType1 = TaxType1 - (TotalFD1 * (POPInfo.Tax1/100))>
		<cfelseif (CurPlan.Taxable4 Is 2) AND (POPInfo.Tax1Type Is 1)>
			<cfset TaxType1 = TaxType1 - (TotalFD1 * (POPInfo.Tax1/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax2 Is Not "">
		<cfif (CurPlan.Taxable4 Is 1) AND (POPInfo.Tax2Type Is 0)>
			<cfset TaxType2 = TaxType2 - (TotalFD1 * (POPInfo.Tax2/100))>
		<cfelseif (CurPlan.Taxable4 Is 2) AND (POPInfo.Tax2Type Is 1)>
			<cfset TaxType2 = TaxType2 - (TotalFD1 * (POPInfo.Tax2/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax3 Is Not "">
		<cfif (CurPlan.Taxable4 Is 1) AND (POPInfo.Tax3Type Is 0)>
			<cfset TaxType3 = TaxType3 - (TotalFD1 * (POPInfo.Tax3/100))>
		<cfelseif (CurPlan.Taxable4 Is 2) AND (POPInfo.Tax3Type Is 1)>
			<cfset TaxType3 = TaxType3 - (TotalFD1 * (POPInfo.Tax3/100))>
		</cfif>
	</cfif>
	<cfif POPInfo.Tax4 Is Not "">
		<cfif (CurPlan.Taxable4 Is 1) AND (POPInfo.Tax4Type Is 0)>
			<cfset TaxType4 = TaxType4 - (TotalFD1 * (POPInfo.Tax4/100))>
		<cfelseif (CurPlan.Taxable4 Is 2) AND (POPInfo.Tax4Type Is 1)>
			<cfset TaxType4 = TaxType4 - (TotalFD1 * (POPInfo.Tax4/100))>
		</cfif>
	</cfif>
</cfif>
<cfif TaxType1 GTE 0.01>
	<cfset TTaxType1 = (Int(TaxType1*100))/100>
<cfelse>
	<cfset TTaxType1 = 0>
</cfif>
<cfif TaxType2 GTE 0.01>
	<cfset TTaxType2 = (Int(TaxType2*100))/100>
<cfelse>
	<cfset TTaxType2 = 0>
</cfif>
<cfif TaxType3 GTE 0.01>
	<cfset TTaxType3 = (Int(TaxType3*100))/100>
<cfelse>
	<cfset TTaxType3 = 0>
</cfif>
<cfif TaxType4 GTE 0.01>
	<cfset TTaxType4 = (Int(TaxType4*100))/100>
<cfelse>
	<cfset TTaxType4 = 0>
</cfif>

<cfif IsDefined("NextDue2")>
	<cfset NextPaymentDue = DateAdd("d",1,NextDue2)>
<cfelse>
	<cfset NextPaymentDue = NextDue>
</cfif>

<cfif IsDefined("MakeItSo.x")>
	<cfquery name="GetIDInfo" datasource="#pds#">
		SELECT POPID, EMailDomainID, EMailServer, FTPDomainID, FTPServer, AuthDomainID, AuthServer, 
		PayBy, AccntPlanID  
		FROM AccntPlans 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetPersonInfo" datasource="#pds#">
		SELECT SalesPersonID, FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cftransaction>
		<cfquery name="InsAccnt" datasource="#pds#">
			INSERT INTO AccntPlans 
			(AccountID, PlanID, NextDueDate, POPID, EMailDomainID, EMailServer, 
			 FTPDomainID, FTPServer, AuthDomainID, AuthServer, StartDate, LastDebitDate, 
			 AccntStatus, PayBy, PostalRem, Taxable, BillingStatus) 
			VALUES
			(#AccountID#, #NewPlanID#, #NextPaymentDue#, #POPID#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null, Null<cfelse>#GetIDInfo.EMailDomainID#, '#GetIDInfo.EMailServer#'</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null, Null<cfelse>#GetIDInfo.FTPDomainID#, '#GetIDInfo.FTPServer#'</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null, Null<cfelse>#GetIDInfo.AuthDomainID#, '#GetIDInfo.AuthServer#'</cfif>, 
			#Now()#, #Now()#, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 0, #Taxable#, 1)
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(AccntPlanID) as TheID 
			FROM AccntPlans
		</cfquery>
	</cftransaction>
	<cfset AccntPlanID = NewID.TheID>
	<cfif (GetIDInfo.EMailDomainID Is "") AND (GetIDInfo.FTPDomainID Is "") AND (GetIDInfo.AuthDomainID Is "")>
		<cfquery name="UpdDomain" datasource="#pds#">
			UPDATE AccntPlans SET 
			AuthDomainID = 
				(SELECT DomainID 
				 FROM Domains 
				 WHERE Primary1 = 1) 
			WHERE AccntPlanID = #AccntPlanID# 
		</cfquery>
	</cfif>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfset HistMessage = "#StaffMemberName.FirstName# #StaffMemberName.LastName# added the plan: #CurPlan.PlanDesc#  for #GetPersonInfo.FirstName# #GetPersonInfo.LastName#.">
		<cfif GetIDInfo.PayBy Is "cc">
			<cfset HistMessage = HistMessage & "  Payment Method: Credit Card.">
		<cfelseif GetIDInfo.PayBy Is "cd">
			<cfset HistMessage = HistMessage & "  Payment Method: Check Debit">
		<cfelseif GetIDInfo.PayBy Is "po">
			<cfset HistMessage = HistMessage & "  Payment Method: Purchase Order">
		<cfelse>
			<cfset HistMessage = HistMessage & "  Payment Method: Check">
		</cfif>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			'#HistMessage#')
		</cfquery>
	</cfif>
	<cfquery name="CheckMulti" datasource="#pds#">
		SELECT PrimaryID 
		FROM Multi 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif CheckMulti.Recordcount Is 0>
		<cfset ThePrimID = AccountID>
	<cfelse>
		<cfset ThePrimID = CheckMulti.PrimaryID>
	</cfif>
	<!--- INSERT INTO PayBy Table --->
	<cfif GetIDInfo.PayBy Is "cc">
		<cfquery name="GetCCInfo" datasource="#pds#" maxrows="1">
			SELECT * 
			FROM PayByCC 
			WHERE AccountID = #ThePrimID# 
		</cfquery>
		<cfquery name="PaySetup" datasource="#pds#">
			INSERT INTO PayByCC 
			(AccntPlanID, AccountID, CCType, CCNumber, CCMonth, CCYear, CCCardHolder, AVSAddress, AVSZip, ActiveYN)
			VALUES 
			(#AccntPlanID#, #ThePrimID#, '#GetCCInfo.CCType#', '#GetCCInfo.CCNumber#', 
			 '#GetCCInfo.CCMonth#', '#GetCCInfo.CCYear#', '#GetCCInfo.CCCardHolder#', 
			 '#GetCCInfo.AVSAddress#', '#GetCCInfo.AVSZip#', 1 )
		</cfquery>
	<cfelseif GetIDInfo.PayBy Is "cd">
		<cfquery name="GetCDInfo" datasource="#pds#" maxrows="1">
			SELECT * 
			FROM PayByCD 
			WHERE AccountID = #ThePrimID# 
		</cfquery>
		<cfquery name="PaySetup" datasource="#pds#">
			INSERT INTO PayByCD 
			(AccntPlanID, AccountID, BankName, BankAddress, RouteNumber, AccntNumber, NameOnAccnt, ActiveYN) 
			VALUES 
			(#AccntPlanID#, #ThePrimID#, '#GetCDInfo.BankName#', '#GetCDInfo.BankAddress#', 
			 '#GetCDInfo.RouteNumber#', '#GetCDInfo.AccntNumber#', '#GetCDInfo.NameOnAccnt#', 1 )
		</cfquery>
	<cfelseif GetIDInfo.PayBy Is "ck">
		<cfquery name="GetCKInfo" datasource="#pds#" maxrows="1">
			SELECT * 
			FROM PayByCK 
			WHERE AccountID = #ThePrimID# 
		</cfquery>
		<cfquery name="PaySetup" datasource="#pds#">
			INSERT INTO PayByCK 
			(AccntPlanID, AccountID, BankName, BankAddress, RouteNumber, AccntNumber, NameOnAccnt, DriversLicense, ActiveYN) 
			VALUES 
			(#AccntPlanID#, #ThePrimID#, '#GetCKInfo.BankName#', '#GetCKInfo.BankAddress#', 
			 '#GetCKInfo.RouteNumber#', '#GetCKInfo.AccntNumber#', '#GetCKInfo.NameOnAccnt#', 
			 '#GetCKInfo.DriversLicense#', 1 )
		</cfquery>
	<cfelseif GetIDInfo.PayBy Is "po">
		<cfquery name="GetPOKInfo" datasource="#pds#" maxrows="1">
			SELECT * 
			FROM PayByPO 
			WHERE AccountID = #ThePrimID# 
		</cfquery>
		<cfquery name="PaySetup" datasource="#pds#">
			INSERT INTO PayByPO 
			(AccntPlanID, AccountID, Contact, ContactPhone, PONumber, ActiveYN) 
			VALUES
			(#AccntPlanID#, #ThePrimID#, '#GetPOInfo.Contact#', '#GetPOInfo.ContactPhone#', 
			 '#GetPOInfo.PONumber#', 1 )
		</cfquery>
	<cfelse>
		<cfquery name="PaySetup" datasource="#pds#">
			INSERT INTO PayByCk 
			(AccountID, AccountID, ActiveYN) 
			VALUES
			(#AccntPlanID#, #ThePrimID#, 1) 
		</cfquery>
	</cfif>
	<cfif CurPlan.PayDueDays Is Not "">
		<cfset PDDate = DateAdd("d",CurPlan.PayDueDays,Now())>
	<cfelse>
		<cfset PDDate = Now()>
	</cfif>
	<cfif CurPlan.PayDueDays Is Not "">
		<cfset CODate = DateAdd("d",CurPlan.PayDueDays,Now())>
	<cfelse>
		<cfset CODate = Now()>
	</cfif>
	<cfif TotalRA1 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TotalRA1#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TotalRA1#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.RAMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, #CreateODBCDateTime(TodayDate)#, #CreateODBCDateTime(NextDueDisp)#)
		</cfquery>
		<cfset TransType = "Debit">
	</cfif>
	<cfif TotalRA2 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TotalRA2#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TotalRA2#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.RAMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, #CreateODBCDateTime(NextDue)#, #CreateODBCDateTime(NextDue2)#)
		</cfquery>
		<cfset TransType = "Debit">
	</cfif>
	<cfif TotalRD1 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TotalRD1#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TotalRD1#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			1, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.RDMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, #CreateODBCDateTime(TodayDate)#, #CreateODBCDateTime(NextDueDisp)#)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfif TotalRD2 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TotalRD2#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TotalRD2#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			1, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.RDMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, #CreateODBCDateTime(NextDue)#, #CreateODBCDateTime(NextDue2)#)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfif TotalFA1 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TotalFA1#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 1, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TotalFA1#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.FAMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	</cfif>
	<cfif TotalFD1 GT 0>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TotalFD1#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
			#NewPlanID#, 0, #AccountID#, 1, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TotalFD1#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			1, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#CurPlan.FDMemo#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	</cfif>
	<cfif TTaxType1 GTE "0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TTaxType1#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 1, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TTaxType1#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc1#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	<cfelseif TTaxType1 LTE "-0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TTaxType1#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 1, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TTaxType1#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc1#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfif TTaxType2 GTE "0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TTaxType2#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 2, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TTaxType2#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc2#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	<cfelseif TTaxType2 LTE "-0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TTaxType2#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 2, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TTaxType2#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc2#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfif TTaxType3 GTE "0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TTaxType3#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 3, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TTaxType3#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc3#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	<cfelseif TTaxType3 LTE "-0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TTaxType3#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 3, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TTaxType3#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc3#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfif TTaxType4 GTE "0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, 0, #TTaxType4#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 4, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, #TTaxType4#, 0, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc4#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Debit">
	<cfelseif TTaxType3 LTE "-0.01">
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO Transactions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
			 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
			 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField, 
			 PaymentDueDate, AccntCutOffDate, DebitFromDate, DebitToDate)
			VALUES 
			(#ThePrimID#, #Now()#, #TTaxType4#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, #POPID#, 
			#NewPlanID#, 4, #AccountID#, 0, 0, 0, 0, 
			<cfif GetIDInfo.PayBy Is "">'ck'<cfelse>'#GetIDInfo.PayBy#'</cfif>, 
			<cfif GetPersonInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#GetPersonInfo.SalesPersonID#</cfif>, 
			#AccntPlanID#, 0, #TTaxType4#, 
			<cfif GetIDInfo.EMailDomainID Is "">Null<cfelse>#GetIDInfo.EMailDomainID#</cfif>, 
			<cfif GetIDInfo.FTPDomainID Is "">Null<cfelse>#GetIDInfo.FTPDomainID#</cfif>, 
			<cfif GetIDInfo.AuthDomainID Is "">Null<cfelse>#GetIDInfo.AuthDomainID#</cfif>, 
			0, '#GetPersonInfo.FirstName#', '#GetPersonInfo.LastName#', Null, 0, '#POPInfo.TaxDesc4#', 
			#CreateODBCDateTime(PDDate)#, #CreateODBCDateTime(CODate)#, Null, Null)
		</cfquery>
		<cfset TransType = "Credit">
	</cfif>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>

<cfset GTotal = 0>
<cfset STotal = 0>
<cfset TTotal = TTaxType1 + TTaxType2 + TTaxType3 + TTaxType4>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Add Plan</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntnew2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
		<input type="hidden" name="accountid" value="#AccountID#">
		<input type="Hidden" name="POPID" value="#POPID#">
		<input type="Hidden" name="NewPlanID" value="#NewPlanID#">
		<input type="Hidden" name="PromoCode" value="#PromoCode#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="3"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Financial</font></th>
	</tr>
</cfoutput>
	<cfoutput query="CurPlan">
		<tr>
			<th colspan="3" bgcolor="#thclr#">#PlanDesc#</th>
		</tr>
		<tr bgcolor="#tbclr#">
			<td align="right">#RAMemo#</td>
			<td>#LSDateFormat(TodayDate, '#DateMask1#')# - #LSDateFormat(NextDueDisp, '#DateMask1#')#</td>
			<td align="right">#LSCurrencyFormat(TotalRA1)#</td>
			<cfset GTotal = GTotal + TotalRA1>
			<cfset STotal = STotal + TotalRA1>
		</tr>
		<cfif TotalRD1 GT 0>
			<tr bgcolor="#tbclr#">
				<td align="right">#RDMemo#</td>
				<td>#LSDateFormat(TodayDate, '#DateMask1#')# - #LSDateFormat(NextDueDisp, '#DateMask1#')#</td>
				<td align="right">-#LSCurrencyFormat(TotalRD1)#</td>
				<cfset GTotal = GTotal - TotalRD1>
				<cfset STotal = STotal - TotalRD1>
			</tr>	
		</cfif>
		<cfif TotalFA1 GT 0>
			<tr bgcolor="#tbclr#">
				<td align="right">#FAMemo#</td>
				<td>#LSDateFormat(TodayDate, '#DateMask1#')# - #LSDateFormat(NextDueDisp, '#DateMask1#')#</td>
				<td align="right">#LSCurrencyFormat(TotalFA1)#</td>
				<cfset GTotal = GTotal + TotalFA1>
				<cfset STotal = STotal + TotalFA1>
			</tr>	
		</cfif>
		<cfif TotalFD1 GT 0>
			<tr bgcolor="#tbclr#">
				<td align="right">#FDMemo#</td>
				<td>#LSDateFormat(TodayDate, '#DateMask1#')# - #LSDateFormat(NextDueDisp, '#DateMask1#')#</td>
				<td align="right">-#LSCurrencyFormat(TotalFD1)#</td>
				<cfset GTotal = GTotal - TotalFD1>
				<cfset STotal = STotal - TotalFD1>
			</tr>	
		</cfif>
		<cfif IsDefined("NextDue2")>
			<tr bgcolor="#tbclr#">
				<td align="right">#RAMemo#</td>
				<td>#LSDateFormat(NextDue, '#DateMask1#')# - #LSDateFormat(NextDue2, '#DateMask1#')#</td>
				<td align="right">#LSCurrencyFormat(TotalRA2)#</td>
				<cfset GTotal = GTotal + TotalRA2>
				<cfset STotal = STotal + TotalRA2>
			</tr>
			<cfif TotalRD2 GT 0>
				<tr bgcolor="#tbclr#">
					<td align="right">#RDMemo#</td>
					<td>#LSDateFormat(NextDue, '#DateMask1#')# - #LSDateFormat(NextDue2, '#DateMask1#')#</td>
					<td align="right">-#LSCurrencyFormat(TotalRD2)#</td>
					<cfset GTotal = GTotal - TotalRD2>
					<cfset STotal = STotal - TotalRD2>
				</tr>	
			</cfif>
		</cfif>
	</cfoutput>
	<cfoutput>
		<cfif TTotal GT 0>
			<tr bgcolor="#thclr#">
				<td align="right" colspan="2">Subtotal</td>
				<td align="right">#LSCurrencyFormat(STotal)#</td>			
			</tr>
			<tr bgcolor="#thclr#">
				<td align="right" colspan="2">Tax</td>
				<td align="right">#LSCurrencyFormat(TTotal)#</td>			
			</tr>
			<cfset GTotal = STotal + TTotal>
		</cfif>
		<tr bgcolor="#thclr#">
			<td align="right" colspan="2">Total</td>
			<td align="right">#LSCurrencyFormat(GTotal)#</td>			
		</tr>
		<form method="post" action="accntnew3.cfm">
			<tr>
				<th colspan="3"><input type="Image" name="MakeItSo" src="images/enter.gif" border="0"></th>
				<input type="hidden" name="accountid" value="#AccountID#">
				<input type="Hidden" name="POPID" value="#POPID#">
				<input type="Hidden" name="NewPlanID" value="#NewPlanID#">
				<input type="Hidden" name="PromoCode" value="#PromoCode#">
			</tr>
		</form>
	</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
