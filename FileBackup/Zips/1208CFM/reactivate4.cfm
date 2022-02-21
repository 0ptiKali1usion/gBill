<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Reactivates entire account. --->
<!---	4.0.0 04/19/00 --->
<!--- reactivate4.cfm --->

<cfif GetOpts.ReactAcnt Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif (IsDefined("ChargReactFee")) AND (IsNumeric(ReactFee))>
	<!--- Insert the Reactivation Fee into TransActions --->
	<cfquery name="AccntInfo" datasource="#pds#">
		SELECT POPID, AuthDomainID, FTPDomainID, EMailDomainID, PlanID, ReactivateTo, PayBy, AccntPlanID 
		FROM AccntPlans 
		WHERE AccountID = #AccountID# 
		AND PlanID = #DeactAccount# 
	</cfquery>
	<cfquery name="MultiCheck" datasource="#pds#">
		SELECT PrimaryID 
		FROM Multi 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="PersonalInfo" datasource="#pds#">
		SELECT FirstName, LastName, SalesPersonID 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="PlanInfo" datasource="#pds#">
		SELECT DeactDays, PayDueDays 
		FROM Plans 
		WHERE PlanID = #AccntInfo.ReactivateTo# 
	</cfquery>
	<cfset LateDate = DateAdd("d", PlanInfo.PayDueDays, WhenRun)>
	<cfset DeactDate = DateAdd("d", PlanInfo.DeactDays, WhenRun)>
	<cftransaction>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO TransActions 
			(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
			 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
	 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
			 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
			 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
			 LastName, RefundedYN, MemoField)
			VALUES 
			(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
			 #CreateODBCDateTime(WhenRun)#, 0, #ReactFee#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, 
			 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 0, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
			 #CreateODBCDateTime(LateDate)#, 0, 0, 0, Null, Null, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #AccntInfo.AccntPlanID#, #ReactFee#, 
			 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
			 '#PersonalInfo.LastName#', 0, '#MemoReason#')
		</cfquery>
		<cfquery name="GetID" datasource="#pds#">
			SELECT Max(TransID) As NTransID 
			FROM Transactions
		</cfquery>
	</cftransaction>
	<cfset TheAccountID = AccountID>
	<cfset TransType = "Credit">
	<cfinclude template="cfpayment.cfm">
</cfif>
<cfif IsDefined("ReactPlans") AND (BillMethod Is Not 1)>
	<cfloop index="B5" list="#ReactPlans#">
		<!--- Insert the Prorated fees into Transactions --->
		<cfquery name="AccntInfo" datasource="#pds#">
			SELECT AccountID, POPID, AuthDomainID, FTPDomainID, EMailDomainID, PlanID, ReactivateTo, PayBy, AccntPlanID 
			FROM AccntPlans 
			WHERE AccntPlanID = #B5# 
		</cfquery>
		<cfquery name="MultiCheck" datasource="#pds#">
			SELECT PrimaryID 
			FROM Multi 
			WHERE AccountID = #AccntInfo.AccountID#
		</cfquery>
		<cfquery name="PersonalInfo" datasource="#pds#">
			SELECT FirstName, LastName, SalesPersonID 
			FROM Accounts 
			WHERE AccountID = #AccntInfo.AccountID# 
		</cfquery>
		<cfquery name="PlanInfo" datasource="#pds#">
			SELECT DeactDays, PayDueDays 
			FROM Plans 
			WHERE PlanID = #AccntInfo.ReactivateTo# 
		</cfquery>
		<cfset LateDate = DateAdd("d", PlanInfo.PayDueDays, WhenRun)>
		<cfset DeactDate = DateAdd("d", PlanInfo.DeactDays, WhenRun)>
		<cfset RctAmount = Evaluate("MyTotalBill#B5#")>
		<cfset TaxAmount = Evaluate("MyTotalTax#B5#")>
		<cfset WhenTill = Evaluate("LastDate#B5#")>
		<cfset TheReason = Evaluate("ReactReason#B5#")>
		<cfset Tax1Amount = Evaluate("MyTax1A#B5#")>
		<cfset Tax2Amount = Evaluate("MyTax2A#B5#")>
		<cfset Tax3Amount = Evaluate("MyTax3A#B5#")>
		<cfset Tax4Amount = Evaluate("MyTax4A#B5#")>
		<cfset Tax1Description = Evaluate("MyTax1Desc#B5#")>
		<cfset Tax2Description = Evaluate("MyTax2Desc#B5#")>
		<cfset Tax3Description = Evaluate("MyTax3Desc#B5#")>
		<cfset Tax4Description = Evaluate("MyTax4Desc#B5#")>
		<cftransaction>
			<cfif RctAmount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO TransActions 
					(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
					 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
			 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
					 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
					 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
					 LastName, RefundedYN, MemoField)
					VALUES 
					(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #CreateODBCDateTime(WhenRun)#, 0, #RctAmount#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, 
					 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 0, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
					 #CreateODBCDateTime(LateDate)#, 0, 0, 0, #WhenRun#, #WhenTill#, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #B5#, #RctAmount#, 
					 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
					 '#PersonalInfo.LastName#', 0, '#TheReason#')
				</cfquery>
			</cfif>
			<!--- Tax Info --->
			<cfif Tax1Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO TransActions 
					(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
					 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
			 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
					 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
					 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
					 LastName, RefundedYN, MemoField)
					VALUES 
					(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #CreateODBCDateTime(WhenRun)#, 0, #Tax1Amount#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, 
					 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 1, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
					 #CreateODBCDateTime(LateDate)#, 0, 0, 0, #WhenRun#, #WhenTill#, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #B5#, #Tax1Amount#, 
					 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
					 '#PersonalInfo.LastName#', 0, '#Tax1Description#')
				</cfquery>				
			</cfif>
			<cfif Tax2Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO TransActions 
					(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
					 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
			 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
					 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
					 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
					 LastName, RefundedYN, MemoField)
					VALUES 
					(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #CreateODBCDateTime(WhenRun)#, 0, #Tax2Amount#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, 
					 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 2, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
					 #CreateODBCDateTime(LateDate)#, 0, 0, 0, #WhenRun#, #WhenTill#, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #B5#, #Tax2Amount#, 
					 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
					 '#PersonalInfo.LastName#', 0, '#Tax2Description#')
				</cfquery>				
			</cfif>
			<cfif Tax3Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO TransActions 
					(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
					 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
			 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
					 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
					 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
					 LastName, RefundedYN, MemoField)
					VALUES 
					(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #CreateODBCDateTime(WhenRun)#, 0, #Tax3Amount#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, 
					 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 3, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
					 #CreateODBCDateTime(LateDate)#, 0, 0, 0, #WhenRun#, #WhenTill#, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #B5#, #Tax3Amount#, 
					 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
					 '#PersonalInfo.LastName#', 0, '#Tax3Description#')
				</cfquery>				
			</cfif>
			<cfif Tax4Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO TransActions 
					(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
					 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PaymentDueDate, AccntCutOffDate, PrintedYN, 
			 		 PaymentLateDate, EMailStateYN, BatchPendingYN, DepositedYN, 
					 DebitFromDate, DebitToDate, PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, 
					 CreditLeft, EMailDomainID, FTPDomainID, AuthDomainID, DiscountYN, FirstName, 
					 LastName, RefundedYN, MemoField)
					VALUES 
					(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #CreateODBCDateTime(WhenRun)#, 0, #Tax4Amount#, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 1, 
					 #AccntInfo.POPID#, #AccntInfo.ReactivateTo#, 4, #AccountID#, 0, #CreateODBCDateTime(WhenRun)#, #CreateODBCDateTime(DeactDate)#, 0, 
					 #CreateODBCDateTime(LateDate)#, 0, 0, 0, #WhenRun#, #WhenTill#, '#AccntInfo.PayBy#', #PersonalInfo.SalesPersonID#, #B5#, #Tax4Amount#, 
					 0, #AccntInfo.EMailDomainID#, #AccntInfo.FTPDomainID#, #AccntInfo.AuthDomainID#, 0, '#PersonalInfo.FirstName#', 
					 '#PersonalInfo.LastName#', 0, '#Tax3Description#')
				</cfquery>				
			</cfif>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(TransID) As NTransID 
				FROM Transactions
			</cfquery>
		</cftransaction>
		<cfset TheAccountID = AccountID>
		<cfset TransType = "Debit">
		<cfinclude template="cfpayment.cfm">
	</cfloop>
</cfif>
<cfif DeactWhen Is "Now">
	<cfif SubStatus Is "All">
		<cfquery name="AllTheIDs" datasource="#pds#">
			SELECT Distinct A.AccountID 
			FROM AccntPlans A 
			WHERE AccntPlanID In (#AllIDs#)
		</cfquery>
		<cfloop query="AllTheIDs">
			<cfset SendAccountID = AccountID>
			<cfsetting enablecfoutputonly="No">
			<cfinclude template="cfreactivate.cfm">	
			<cfsetting enablecfoutputonly="Yes">
		</cfloop>
	<cfelse>
		<cfset SendAccountID = AccountID>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="cfreactivate.cfm">	
		<cfsetting enablecfoutputonly="Yes">
	</cfif>
<cfelse>
	<!--- Schedule The Reactivations --->
	<cfloop index="B5" list="#AllIDs#">
		<cfquery name="PersInfo" datasource="#pds#">
			SELECT * 
			FROM AccntPlans 
			WHERE AccntPlanID = #B5# 
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			DELETE FROM AutoRun 
			WHERE AccountID = #PersInfo.AccountID# 
			AND AccntPlanID = #B5# 
			AND DoAction = 'Reactivate' 
		</cfquery>
		<cfset MyDateValue = Evaluate("NextDueDate#B5#")>
		<cfquery name="InsAutoRun" datasource="#pds#">
			INSERT INTO AutoRun 
			(WhenRun, DoAction, ScheduledBy, 
			 AccountID, AccntPlanID, AuthID, PlanID, Memo1, Date1)
			VALUES 
			(#CreateODBCDateTime(WhenRun)#, 'Reactivate', '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
			 #PersInfo.AccountID#, #B5#, 0, #PersInfo.ReactivateTo#, '#MemoReason#', #CreateODBCDateTime(MyDateValue)#)
		</cfquery>
	</cfloop>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Final Verification</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="custinf1.cfm">
		<input type="image" src="images/return.gif" name="GoBack" border="0">
		<input type="hidden" name="AccountID" value="#AccountID#">
	</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Process complete</font></th>
	</tr>
	<cfif DeactWhen Is "Now">
		<tr>
			<th bgcolor="#thclr#">Account has been Reactivated.</th>
		</tr>
	<cfelse>
		<tr>
			<th bgcolor="#thclr#">Account has been scheduled for Reactivation.</th>
		</tr>
	</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 