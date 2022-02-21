<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is the scren that posts the payments. --->
<!--- payment4.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfif OtherAmount Is "SI">
	<cfquery name="GetAmount" datasource="#pds#">
		SELECT Sum(DebitLeft) as AmntLeft 
		FROM TransActions 
		WHERE TransID IN (#AmountIDs#)
	</cfquery>
	<cfset CreditAmount = GetAmount.AmntLeft>
<cfelse>
	<cfset CreditAmount = PayAmount>
</cfif>
<cfquery name="GetIds" datasource="#pds#">
	SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
	FROM AccntPlans
	WHERE AccntPlanID In 
		(SELECT AccntPlanID 
		 FROM TransActions 
		 WHERE TransID In (#AmountIDs#)
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

<cfif PayBy Is "CA">
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
			 FirstName, LastName, PayType)
			VALUES 
			(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
			 #Now()#, #CreditAmount#, 0, 0, 0, #CreditAmount#, 0, 
			 'Cash Payment', 0, '#StaffMemberName.Firstname# #StaffMemberName.LastName#', 
			 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
			 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
			 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
			 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
			 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
			 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
			 'CA', #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
			 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', 'Cash')			 
		</cfquery>
		<cfquery name="NewTopID" datasource="#pds#">
			SELECT Max(TransID) as TopID 
			FROM TransActions 
		</cfquery>
		<cfset TransID = NewTopID.TopID>
	</cftransaction>
	<cfset PaymentType = "Cash">
<cfelseif PayBy Is "Ck">
	<cfset PaymentType = "Check #CkNumber#">
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
			 FirstName,LastName, ChkNumber, PayType)
			VALUES 
			(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
			 #Now()#, #CreditAmount#, 0, 0, 0, #CreditAmount#, 0, 
			 'Payment Check #CkNumber#', 0, '#StaffMemberName.Firstname# #StaffMemberName.LastName#', 
			 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
			 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
			 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
			 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
			 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
			 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
			 'Ck', #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
			 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', '#CkNumber#', 'Check')			 
		</cfquery>
		<cfquery name="NewTopID" datasource="#pds#">
			SELECT Max(TransID) as TopID 
			FROM TransActions 
		</cfquery>
		<cfset TransID = NewTopID.TopID>
	</cftransaction>
<cfelseif PayBy Is "CC">
	<cfif Card GT 0>
		<cfquery name="GetCCInfo" datasource="#pds#">
			SELECT * 
			FROM PayByCC 
			WHERE AccntPlanID = #Card#
		</cfquery>
		<cfset ExpMonth = GetCCInfo.CCMonth>
		<cfset ExpYear = GetCCInfo.CCYear>
		<cfset CardNum = GetCCInfo.CCNumber>
		<cfset Member = GetCCInfo.CCCardHolder>
		<cfset AVSAddr = GetCCInfo.AVSAddress>
		<cfset AVSZip = GetCCInfo.AVSZip>
		<cfset CCType = GetCCInfo.CCType>
	<cfelse>
		<cfset AVSAddr = AVSAddress>
		<cfset Member = CCCardHolder>
	</cfif>
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
	<cf_charge Amount="#CreditAmount#" ExpMonth="#ExpMonth#" ExpYear="#ExpYear#" Card="#CardNum#" 
 	 Member="#Member#" AVSAddress="#AVSAddr#" AVSZip="#AVSZip#" CompName="#varCompanyName#" 
	 Merchant="#varMerchant#" Action="#varSaleCode#" AccountID="#AccountID#">
	<cfif CCRes Is "Ok">
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
				 #Now()#, #CreditAmount#, 0, 0, 0, #CreditAmount#, 0, 
				 '#CCType# Authorization: #CCMess#', 0, '#StaffMemberName.Firstname# #StaffMemberName.LastName#', 
				 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
				 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
				 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
				 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
				 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
				 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
				 'CC', #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
				 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', '#CCMess#', 'Credit Card',
				 #Now()#, '#CCType#')			 
			</cfquery>
			<cfquery name="NewTopID" datasource="#pds#">
				SELECT Max(TransID) as TopID 
				FROM TransActions 
			</cfquery>
			<cfset TransID = NewTopID.TopID>
		</cftransaction>
		<cfset PaymentType = "#CCType# Authorization: #CCMess#">
	<cfelse>
		<cfset MessageStr = CCMess>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="payment6.cfm">
		<cfabort>
	</cfif>
</cfif>
<cfif OtherAmount IS "OA">
	<cfset TheAccountID = AccountID>
	<cfset TransType = "Credit">
	<cfinclude template="cfpayment.cfm">
<cfelse>
	<cftransaction>
		<cfquery name="UpdTrans" datasource="#pds#">
			UPDATE TransActions SET 
			DebitLeft = 0 
			WHERE TransID IN (#AmountIDs#) 
		</cfquery>
		<cfquery name="UpdTrans" datasource="#pds#">
			UPDATE TransActions SET 
			CreditLeft = 0 
			WHERE TransID = #TransID# 
		</cfquery>
	</cftransaction>
</cfif>

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
<title>Payment Finished</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="custinf1.cfm">
	<input type="Image" src="images/return.gif" border="0">
	<input type="Hidden" name="AccountID" value="#AccountID#">
</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Finished</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">Payment: #LSCurrencyFormat(CreditAmount)#<br>
		Paid By: #PaymentType#<br>
		Date: #LSDateFormat(Now(), '#DateMask1#')#</td>
	</tr>
	<tr>
		<form method="post" action="payment5.cfm" Target="_New">
			<th><input type="Image" name="PrintReceipt" src="images/print.gif" border="0"></th>
			<input type="Hidden" name="TransID" value="#TransID#">
			<input type="Hidden" name="PayBy" value="#PayBy#">
		</form>
	</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 

