<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 04/11/00 --->
<!--- accntmanage9.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfif IsDefined("AllDone.x")>
	<cfif AmountType Is 1>
		<cfset CreditAmount = CreditBack>
		<cfset DebitAmount = 0>
	<cfelseif AmountType Is 4>
		<cfset CreditAmount = 0>
		<cfset DebitAmount = DAmount>
	<cfelseif AmountType Is 5>
		<cfset CreditAmount = CAmount>
		<cfset DebitAmount = 0>
	</cfif>
	<cfquery name="GetID" datasource="#pds#">
		SELECT AccountID 
		FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfset AccountID = GetID.AccountID>
	<cfquery name="CheckPrimary" datasource="#pds#">
		SELECT PrimaryID 
		FROM Multi 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="PersInfo" datasource="#pds#">
		SELECT FirstName, LastName, SalesPersonID 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif CheckPrimary.RecordCount GT 0>
		<cfset PrimaryAccountID = CheckPrimary.PrimaryID>
	<cfelse>
		<cfset PrimaryAccountID = AccountID>
	</cfif>
	<cfquery name="CurPlan" datasource="#pds#">
		SELECT PlanDesc, PlanID, RecurringAmount, RecurringCycle, RecurDiscount 
		FROM Plans 
		WHERE PlanID = #CurPlanID# 
	</cfquery>
	<cfquery name="AccntPlanInfo" datasource="#pds#">
		SELECT * 
		FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cftransaction>
		<cfquery name="SchedChange" datasource="#pds#">
			INSERT INTO AutoRun 
			(DoAction, WhenRun, AccountID, AccntPlanID, PlanID, ScheduledBy, Memo1, Memo2)
			VALUES 
			('Cancel', #CreateODBCDateTime(SchedDT)#, #AccountID#, #AccntPlanID#, #DelAccount#, 
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName#', '#DReason#', 'Plan scheduled to change from #CurPlan.PlanDesc# to cancel on #LSDateFormat(SchedDT, '#Datemask1#')#.')
		</cfquery>
		<cfset HistMessage = "#StaffMemberName.FirstName# #StaffMemberName.LastName# scheduled a plan to change from #CurPlan.PlanDesc# to cancel on #LSDateFormat(SchedDT, '#Datemask1#')#">
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(AccountID, AdminID, ActionDate, Action, ActionDesc) 
			VALUES 
			(#AccountID#, #GetOpts.AdminID#, #Now()#, 'Edited Customer Info','#HistMessage#')
		</cfquery>
		<cfset CreditAmount = LSParseCurrency(CreditAmount)>
		<cfset DebitAmount = LSParseCurrency(DebitAmount)>
		<cfif (CreditAmount GT 0) OR (DebitAmount GT 0)>
			<cfquery name="MakeTrans" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES 
				(#PrimaryAccountID#, #CreateODBCDateTime(Now())#, #CreditAmount#, #DebitAmount#, '#DReason#', 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, 
				 #AccntPlanInfo.EMailDomainID#, #AccntPlanInfo.FTPDomainID#, #AccntPlanInfo.AuthDomainID#, #AccntPlanInfo.POPID#, #AccntPlanInfo.PlanID#, 0, 0, 
				 #AccountID#, 0, Null, Null, 0, 
				 Null, 0, 0, 0, Null, 
				 Null, '#AccntPlanInfo.PayBy#', #PersInfo.SalesPersonID#, #AccntPlanID#, #DebitAmount#, #CreditAmount#, 0, 
				 '#PersInfo.FirstName#','#PersInfo.LastName#')
			</cfquery>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(TransID) As NTransID 
				FROM Transactions
			</cfquery>
			<cfset TheAccountID = PrimaryAccountID>
			<cfif CreditAmount GT 0>
				<cfset TransType = "Credit">
			<cfelseif DebitAmount GT 0>
				<cfset TransType = "Debit">
			</cfif> 
			<cfinclude template="cfpayment.cfm">
		</cfif>
	</cftransaction>
	<cfset Tab = 2>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="accntmanage.cfm">
	<cfabort>
</cfif>

<cfparam name="Tab" default="1">
<cfparam name="SchedDT" default="#Now()#">
<cfparam name="SchedWhen" default="Now">
<cfparam name="AmountType" default="3">

<cfquery name="CurInfo" datasource="#pds#">
	SELECT * 
	FROM AccntPlans 
	WHERE AccntPlanID = #AccntPlanID# 
</cfquery>
<cfset CurPlanID = CurInfo.PlanID>
<cfquery name="CurPlan" datasource="#pds#">
	SELECT PlanDesc, PlanID, RecurringAmount, RecurringCycle, RecurDiscount 
	FROM Plans 
	WHERE PlanID = #CurPlanID# 
</cfquery>

<cfif Tab Is 2>
	<cfif SchedWhen Is "Now">
		<cfset SchedDT = Now()>
	</cfif>
	<cfset NumDays = DateDiff("d",SchedDT,CurInfo.NextDueDate)>
	<cfset PerDay = (CurPlan.RecurringAmount - CurPlan.RecurDiscount)/(CurPlan.RecurringCycle*(365/12))>
	<cfset CreditBack = PerDay * NumDays>
	<cfset FinType = "Credit">
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'Locale'
	</cfquery>
	<cfset Locale = GetLocale.Value1>
</cfif>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #CurInfo.AccountID# 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<cfoutput><title>Cancel #CurPlan.PlanDesc#</title></cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccountID" value="#CurInfo.AccountID#"></cfoutput>
	<input type="hidden" name="Tab" value="2">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName#<br>Cancel #CurPlan.PlanDesc#</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="2">You have selected to cancel #CurPlan.PlanDesc#.</td>
	</tr>
	<form method="post" action="accntmanage9.cfm">
		<cfif Tab Is 1>
			<tr>
				<td bgcolor="#tbclr#" valign="top">When</td>
				<td bgcolor="#tdclr#"><input type="Radio" name="SchedWhen" <cfif SchedWhen Is "Now">checked</cfif> value="Now"> Now<br>
				<input type="Radio" name="SchedWhen" <cfif SchedWhen Is "Later">checked</cfif> value="Later"> Later <input type="Text" name="SchedDT" value="#LSDateFormat(SchedDT,'#DateMask1#')# #LSTimeFormat(SchedDT,'HH:mm:ss')#"></td>
			</tr>
			<input type="Hidden" name="Tab" value="2">
			<tr>
				<td bgcolor="#tbclr#" colspan="2">All Auth, FTP and EMail accounts on this plan will also be cancelled.<br>
				Click Continue to confirm.</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/continue.gif" border="0" name="CancelPlan"></th>
			</tr>
		<cfelseif Tab Is 2>
			<tr bgcolor="#tbclr#">
				<td align="right">When</td>
				<td bgcolor="#tdclr#"><cfif SchedWhen Is "Now">Now<cfelse>#LSDateFormat(SchedDT,'#DateMask1#')# #LSTimeFormat(SchedDT,'HH:mm:ss')#</cfif></td>
				<input type="Hidden" name="SchedDT" value="#SchedDT#">
				<input type="Hidden" name="SchedWhen" value="#SchedWhen#">
			</tr>
			<tr bgcolor="#tbclr#"> 
				<td align="right">Next Due Date</td>
				<td bgcolor="#tdclr#">#LSDateFormat(CurInfo.NextDueDate, '#DateMask1#')#</td>
			</tr>
			<input type="Hidden" name="NextDue" value="#CurInfo.NextDueDate#">
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Amount</td>
				<td bgcolor="#tdclr#"><input checked type="Radio" name="AmountType" value="1"> Credit #LSCurrencyFormat(CreditBack)# for dropping #CurPlan.PlanDesc#.<br>
				<input type="Radio" name="AmountType" value="4"> Debit &nbsp;<input type="Text" name="DAmount" value="#LSCurrencyFormat(0)#" size="6"><br>
				<input type="Radio" name="AmountType" value="5"> Credit <input type="Text" name="CAmount" value="#LSCurrencyFormat(0)#" size="6"></td>
			</tr>
			<input type="Hidden" name="CreditBack" value="#LSCurrencyFormat(CreditBack)#">
			<tr>
				<td align="right" bgcolor="#tbclr#">Reason</td>
				<td bgcolor="#tdclr#"><input type="Text" name="dreason" size="35"></td>
				<input type="Hidden" name="dreason_required" value="Please enter the reason for the financial transaction.">
			</tr>
			<tr>
				<th colspan="2"><input type="Image" name="AllDone" src="images/continue.gif" border="0"></th>
			</tr>
		</cfif>	
		<input type="hidden" name="CurPlanID" value="#CurPlanID#">
		<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
	</form>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 