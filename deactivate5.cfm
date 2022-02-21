<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Runs the deact scripts or schedules the deactivations. --->
<!---	4.0.0 10/09/99 --->
<!--- deactivate5.cfm --->

<cfif GetOpts.DeactC Is 1>
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

<!--- Select the AccntPlans involved --->
<cfquery name="DeactPlans" datasource="#pds#">
	SELECT AccountID, DeactivatedYN 
	FROM Accounts A 
	WHERE A.CancelYN = 0 
	AND A.AccountID 
	<cfif SubStatus Is "All">
		IN (SELECT AccountID 
			 FROM Multi 
			 WHERE PrimaryID = #AccountID#)
	<cfelse>
		= #AccountID# 
	</cfif>
</cfquery>
<cfquery name="DeactInfo" datasource="#pds#">
	SELECT FirstName, LastName, SalesPersonID 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="AccntPlanInfo" datasource="#pds#">
	SELECT AccntPlanID, PayBy 
	FROM AccntPlans 
	WHERE AccountID = #AccountID# 
</cfquery>
<!--- Insert the Refund transaction if a refund --->
<cfif AmntStatus Is "Refund">
	<cfif DeactWhen Is "Now">
		<cfset AccountMessage = "This account was deactivated on #LSDateFormat(Now(), '#DateMask1#')# and a refund was given for the credit left on the account.">
	<cfelseif DeactWhen Is "Later">
		<cfset AccountMessage = "This account was scheduled to be deactivated on #LSDateFormat(WhenRun, '#DateMask1#')# and a refund was given for the credit left on the account.">
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT TransID 
		FROM Transactions 
		WHERE AccountID = #AccountID# 
		AND Credit = #AmntAmount# 
		AND EnteredBY = '#StaffMemberName.FirstName# #StaffMemberName.LastName#' 
		AND MemoField = '#AccountMessage#' 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cftransaction>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO TransActions 
				(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, DomainID, POPID, 
				 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
				 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
				 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField)
				VALUES 
				(#AccountID#, #Now()#, #AmntAmount#, 0, 1, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, Null, Null, 
				 Null, 0, #AccountID#, 0, 0, 0, 0, '#AccntPlanInfo.PayBy#', #DeactInfo.SalesPersonID#, #AccntPlanInfo.AccntPlanID#, #AmntAmount#, 0 , Null, Null, Null, 0, 
				 '#DeactInfo.FirstName#', '#DeactInfo.LastName#', '#RefundMethod#', 0, '#AccountMessage#')
			</cfquery>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(TransID) As NTransID 
				FROM Transactions
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetLocale" datasource="#pds#">
					SELECT Value1 
					FROM Setup 
					WHERE VarName = 'Locale' 
				</cfquery>
				<cfset Locale = GetLocale.Value1>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# credited #DeactInfo.FirstName# #DeactInfo.LastName# for #LSCurrencyFormat(AmntAmount)#.  #AccountMessage#')
				</cfquery>
			</cfif>
		</cftransaction>
		<cfset TheAccountID = AccountID>
		<cfset TransType = "Credit">
		<cfinclude template="cfpayment.cfm">
	</cfif>
</cfif>
<!--- Loop on the AccntPlans --->
<cfloop query="DeactPlans">
	<cfif DeactWhen Is "Now">
		<!--- Run the scripts --->
		<cfset SendAccountID = AccountID>
		<cfset LocScheduledBy = "#StaffMemberName.FirstName# #StaffMemberName.LastName#">
		<cfset LocReason = MemoReason>
		<cfinclude template="cfdeactivate.cfm">
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetWhoName" datasource="#pds#">
				SELECT FirstName, LastName, AccountID
				FROM Accounts 
				WHERE AccountID = #SendAccountID#
			</cfquery>		
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWhoName.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# deactivated #GetWhoName.FirstName# #GetWhoName.LastName#.  #MemoReason#')
			</cfquery>
		</cfif>
	<cfelseif DeactWhen Is "Later">
		<!--- Schedule in AutoRun --->
		<cfif Trim(MemoReason) Is "">
			<cfset MemoReason = "Account was scheduled to be deactivated.">
		</cfif>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT AutoRunID 
			FROM AutoRun 
			WHERE AccountID = #AccountID# 
			AND DoAction In ('Deactivate','Reactivate','Cancel') 
		</cfquery>
		<cfif CheckFirst.Recordcount GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AccountID = #AccountID# 
				AND DoAction In ('Deactivate','Reactivate','Cancel') 
			</cfquery>
		</cfif>
		<cfif DeactivatedYN Is 0>
			<cfquery name="ScheduleTheEvents" datasource="#pds#">
				INSERT INTO AutoRun 
				(Memo1, WhenRun, DoAction, AccountID, AccntPlanID, PlanID, ScheduledBy, BillMethod)
				VALUES 
				('#MemoReason#', #WhenRun#, 'Deactivate', #AccountID#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', #BillMethod#)
			</cfquery>	
			<cfquery name="SetBilling" datasource="#pds#">
				UPDATE AccntPlans SET 
				BillingStatus = 
				<cfif BillMethod Is 1>
					0
				<cfelseif BillMethod Is 2>
					2
				</cfif>
				WHERE AccountID = #AccountID#
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWho" datasource="#pds#">
					SELECT FirstName, LastName 
					FROM Accounts 
					WHERE AccountID = #AccountID# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#AccountID#,#MyAdminID#, #Now()#,'Deactivate Scheduled','#StaffMemberName.FirstName# #StaffMemberName.LastName# scheduled #GetWho.FirstName# #GetWho.LastName# to be deactivated on #LSDateFormat(WhenRun, '#DateMask1#')#. #MemoReason#')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
</cfloop>
<cfif DeactWhen Is "Now">
	<cfquery name="GetWho" datasource="#pds#">
		SELECT A.FirstName, A.LastName, '#LSDateFormat(Now(), '#DateMask1#')#' AS WhenRun, 'Deactivate' AS DoAction, '#MemoReason#' AS Memo1 
		FROM Accounts A 
		WHERE A.CancelYN = 0 
		AND A.AccountID 
		<cfif SubStatus Is "All">
			IN (SELECT AccountID 
				 FROM Multi 
				 WHERE PrimaryID = #AccountID#)
		<cfelse>
			= #AccountID# 
		</cfif>
		ORDER BY A.LastName, A.FirstName 
	</cfquery>
<cfelse>
	<cfquery name="GetWho" datasource="#pds#">
		SELECT A.FirstName, A.LastName, R.WhenRun, R.DoAction, R.ScheduledBy, R.Memo1 
		FROM Accounts A, AutoRun R 
		WHERE A.AccountID = R.AccountID 
		AND R.DoAction IN ('Deactivate','Reactivate','Cancel') 
		AND A.CancelYN = 0 
		AND A.AccountID 
		<cfif SubStatus Is "All">
			IN (SELECT AccountID 
				 FROM Multi 
				 WHERE PrimaryID = #AccountID#)
		<cfelse>
			= #AccountID# 
		</cfif>
		ORDER BY A.LastName, A.FirstName 
	</cfquery>
</cfif>
<cfquery name="GetReason" datasource="#pds#">
	SELECT CxReason
	FROM LU_CxReason
	WHERE CxReasonID = #GetWho.Memo1#
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Process Complete</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="Image" src="images/return.gif" border="0">
	<cfoutput><input type="Hidden" name="accountid" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Process complete</font></th>
	</tr>
<cfif DeactWhen Is "Now">
	<tr>
		<th colspan="3" bgcolor="#thclr#">The following accounts have been deactivated.</th>
	</tr>
<cfelse>
	<tr>
		<th colspan="3" bgcolor="#thclr#">The following accounts have been scheduled for deactivation.</th>
	</tr>
</cfif>
	<tr>
		<td colspan="3" bgcolor="#tbclr#">#GetReason.CxReason#</td>
	</tr>
</cfoutput>
	<cfoutput query="GetWho">
		<tr bgcolor="#tbclr#">
			<td>#LastName#, #FirstName#</td>
			<td>#DoAction#</td>
			<td>#WhenRun#</td>
		</tr>
	</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 