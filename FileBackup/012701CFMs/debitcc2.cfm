<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page continues the debit all credit card process. --->
<!--- 4.0.0 10/23/00 --->
<!--- debitcc2.cfm --->

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccountID 
	FROM CCDebitAll 
	WHERE AdminID <> #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount GT 0>
	<cflocation addtoken="No" url="debitcc.cfm">
</cfif>

<cfif IsDefined("RemoveProbs.x")>
	<cfquery name="RemoveSome" datasource="#pds#">
		DELETE FROM CCDebitAll 
		WHERE CCNumber = '123456789' 
	</cfquery>
</cfif>
<!--- Select top records from CCDebitAll --->
<cfparam name="HowMany" default="3">
<!--- Lock the current ones --->
<cfquery name="GetSomeToDebit" datasource="#pds#" maxrows="#HowMany#">
	SELECT * 
	FROM CCDebitAll 
</cfquery>
<cfloop query="GetSomeToDebit">
	<cfquery name="SetToPending" datasource="#pds#">
		UPDATE CCDebitAll SET 
		CCAuthCode = 'Pending' 
		WHERE DebitID = #DebitID# 
	</cfquery>
	<!--- Call the Charge Tag --->
	<cfquery name="GetMerchant" datasource="#pds#">
		SELECT FieldValue, FieldName1 
		FROM CustomCCOutput 
		WHERE FieldName1 In ('Merchant', 'CompanyName') 
		AND UseTab = 5 
	</cfquery>
	<cfloop query="GetMerchant">
		<cfset "var#FieldName1#" = FieldValue>
	</cfloop>
	<cfquery name="GetCodes" datasource="#pds#">
		SELECT FieldValue, FieldName1 
		FROM CustomCCOutput 
		WHERE FieldName1 In ('SaleCode', 'RefundCode')
		AND UseTab = 8 
	</cfquery>
	<cfloop query="GetCodes">
		<cfset "var#FieldName1#" = FieldValue>
	</cfloop>
	<cf_charge Amount="#CCAmount#" ExpMonth="#CCExpMonth#" ExpYear="#CCExpYear#" Card="#CCNumber#" 
 	 Member="#CCCardHolder#" AVSAddress="#AVSAddress#" AVSZip="#AVSZip#" CompName="#varCompanyName#" 
	 Merchant="#varMerchant#" Action="#varSaleCode#" AccountID="#AccountID#">
	<!--- If Approved then Insert TransActions --->
	<cfif CCRes Is "Ok">
		<cfquery name="GetIds" datasource="#pds#">
			SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
			FROM AccntPlans
			WHERE AccntPlanID In 
				(SELECT AccntPlanID 
				 FROM TransActions 
				 WHERE AccountID = #AccountID#
				)
		</cfquery>
		<cfif GetIDs.Recordcount IS 0>
			<cfquery name="GetIds" datasource="#pds#">
				SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
				FROM AccntPlans 
				WHERE AccntPlanID In 
					(SELECT AccntPlanID 
					 FROM AccntPlans 
					 WHERE AccountID = #AccountID#) 
			</cfquery>
		</cfif>
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
		<cfif Left(CCNumber,1) Is "3">
			<cfset CCType = "Am Express">
		<cfelseif Left(CCNumber,1) Is "4">
			<cfset CCType = "Visa">
		<cfelseif Left(CCNumber,1) Is "5">
			<cfset CCType = "Mastercard">
		<cfelseif Left(CCNumber,1) Is "6">
			<cfset CCType = "Discover">
		</cfif>
		<cfif Len(CCCode) GT 25>
			<cfset CCCode = Left(CCCode,25)>
		</cfif>
		<cfset CCCode = Trim(CCCode)>
		<cftransaction>
			<cfquery name="InsPayment" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
				 MemoField,AdjustmentYN,EnteredBy,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
				 SubAccountID,SetUpFeeYN,
				 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
				 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
				 PlanPayBy,SalesPersonID,AccntPlanID,DiscountYN,
				 FirstName,LastName, CCAuthCode, PayType, CCProcessDate, CCPayType)
				VALUES 
				(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
				 #Now()#, #CCAmount#, 0, 0, 0, #CCAmount#, 0, 
				 '#CCType# Authorization: #CCMess#', 0, '#StaffMemberName.Firstname# #StaffMemberName.LastName#', 
				 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
				 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
				 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
				 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
				 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
				 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
				 'CC', <cfif PersonalInfo.SalesPersonID Is "">#MyAdminID#<cfelse>#PersonalInfo.SalesPersonID#</cfif>, 
				 #GetIds.AccntPlanID#, 0, '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', 
				 '#CCCode#', 'Credit Card',
				 #Now()#, '#CCType#')			 
			</cfquery>
			<cfquery name="NewTopID" datasource="#pds#">
				SELECT Max(TransID) as TopID 
				FROM TransActions 
			</cfquery>
		</cftransaction>
		<cfset TransID = NewTopID.TopID>
		<cfset PaymentType = "#CCType# Authorization: #CCMess#">
		<cfset TheAccountID = AccountID>
		<cfset TransType = "Credit">
		<cfinclude template="cfpayment.cfm">
		<!--- BOB History --->
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
				(Null,<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>,
				 #MyAdminID#, #Now()#,'Financial',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# ran a credit card debit or #LSCurrencyFormat(CCAmount)# for #PersonalInfo.FirstName# #PersonalInfo.LastName#.')
			</cfquery>
		</cfif>
		<!--- Remove From All ReportID = 8 --->
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE AccountID = #AccountID# 
			AND ReportID = 8 
		</cfquery>
	<cfelse>
		<cfquery name="UpdGrpList" datasource="#pds#">
			UPDATE GrpLists SET 
			MemoField = '#CCMess#' 
			WHERE AccountID = #AccountID# 
			AND ReportID = 8 
			AND ReportTab = 'Credit Card' 
		</cfquery>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetWhoName" datasource="#pds#">
				SELECT FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = #AccountID#
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#AccountID#,#MyAdminID#, #Now()#,'Financial',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# attempted to debit #GetWhoName.FirstName# #GetWhoName.LastName#.  Response:#CCMess#')
			</cfquery>
		</cfif>
	</cfif>
	<!--- Remove from CCDebitAll --->
 	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM CCDebitAll 
		WHERE DebitID = #DebitID# 
	</cfquery>
</cfloop>

<cfquery name="CheckAny" datasource="#pds#">
	SELECT * 
	FROM CCDebitAll 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Debit All In Progress</title>
<cfif CheckAny.RecordCount GT 0>
	<META HTTP-Equiv=Refresh content="5; URL=debitcc2.cfm">
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<cfif CheckAny.RecordCount Is 0>
	<form method="post" action="grplist.cfm">
		<input type="hidden" name="SendReportID" value="8">
		<input type="hidden" name="SendLetterID" value="8">
		<input type="hidden" name="ReturnPage" value="baldue.cfm">
		<input type="Hidden" name="SelectedTab" value="Credit Card">
		<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Amount,Phone,E-Mail,Notes">
		<input type="hidden" name="SendFields" value="Name,Company,ReportTab,CurBal,Phone,EMail,MemoField">
		<td><input type="image" src="images/viewlist.gif" name="continue" border="0"></td>
	</form>
</cfif>
<center>
<table border="#tblwidth#">
	<tr>
		<cfif CheckAny.RecordCount GT 0>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Debit All In Progress</font></th>
		<cfelse>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Debit All Session Completed</font></th>
		</cfif>
	</tr>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
