<cfsetting enablecfoutputonly="Yes">

<!--- Version 4.0.0 --->
<!--- 4.0.0 08/22/00 --->
<!--- maintconverter.cfm --->
<!--- 4 Types 
Query Inputs
	TheQuery - The first Query to run.
	TheQuery2 - The second query to run.  This one is optional.
Query Returns
	Sendback - The Result of the last query to run.
	
Letter Inputs
	SelectedLetter - The ID for the letter to be sent.
	AccountID - The AccountID for the person the letter is to be sent to.
Letter Returns 
	Sendback - The word 'Completed' if the letter was sent successfully.

CreditCard Inputs
	LocAVSName - The Card Holders Name.
	LocAVSAddr - The Address for Address verification.
	LocAVSZip - The Zipcode for Address verification.
	LocCCNumber - The Credit Card number.
	LocExpMonth - The expiration month of the credit card.
	LocExpYear - The expiration year of the credit card.
	LocAmount -  The amount to be charged.
	LocAccountID - The AccountID of the person being charged.
CreditCard Returns
	SendBack = Approved or Declined.
				  TransID from the table the payment is stored in if approved.  0 if not approved.  
				  Approval Code if approved.  0 if not approved.
				  Payment message.  
					These values are returned in a ; delimited list.

Script Inputs
	MCPageLocation - The location the script is being called from.  Matching a location in the IntLocations table.
	MCScrAction - Change, Create, Delete.
	MCIntType - 1=Authentication, 2=Domain, 3=FTP, 4=EMail, 5=EMail Alias.
	MCAccountID - The AccountID of the person the script is running for.
	LocAccntPlanID - The AccntPlanID of the plan the script is running for.

	One of the following is needed.
	MCAuthID - The AuthID if the type is Authentication.
	MCFTPID - The FTPID if the type is FTP.
	MCEMailID - The EMailID if the type is EMail.

	LocCEMailID - The Custom EMail values to use.
	LocCFTPID - The Custom FTP values to use.
	LocCAuthID - The Custom Auth values to use.
Script Returns
	Sendback - The word 'Completed' if the scripts were run successfully.


MakePayment
	AccountID - The AccountID of the customer to calculate the paid off debits.
	TheTransType - Credit or Debit based on the financial type.
MakePayment Returns
	Sendback - The word 'Completed' if the process ran successfully.
	
--->

<cfparam name="ResultType" default="Query">
<cfparam name="ExistingUser" default="Yes">
<cfparam name="InfoSendBack" default="0">

<cfif ResultType Is "Query">
	<cfquery name="SetLast" datasource="#pds#">
		UPDATE Accounts SET Notes = '#TheQuery#' 
		WHERE Login = 'gbill' 
		OR Login = 'greensoft' 
	</cfquery>
	<cfif IsDefined("PDS2")>
		<cfset PDS =PDS2>
	</cfif>
	<cftransaction>
		<cfquery name="MyResults" datasource="#pds#">
			#Replace(TheQuery,"''","'","All")#
		</cfquery> 
		<cfif IsDefined("TheQuery2")>
			<cfquery name="MyResults" datasource="#pds#">
				#Replace(TheQuery2,"''","'","All")#
			</cfquery>
		</cfif>
	</cftransaction>
	<cfwddx action="CFML2WDDX" input="#MyResults#" output="SendBack">

<cfelseif ResultType Is "CreditCard">

	<cfset LocAVSName = LocAVSName>
	<cfset LocAVSAddr = LocAVSAddr>
	<cfset LocAVSZip = LocAVSZip>
	<cfset LocCCNumber = LocCCNumber>
	<cfset LocExpMonth = LocExpMonth>
	<cfset LocExpYear = LocExpYear>
	<cfset LocAmount = LocAmount>
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
	<cfif ExistingUser Is "Yes">
		<cfset LocAccountID = AccountID>
		<cf_charge Amount="#LocAmount#" ExpMonth="#LocExpMonth#" ExpYear="#LocExpYear#" Card="#LocCCNumber#" 
	 	 Member="#LocAVSName#" AVSAddress="#LocAVSAddr#" AVSZip="#LocAVSZip#" CompName="#varCompanyName#" 
		 Merchant="#varMerchant#" Action="#varSaleCode#" AccountID="#LocAccountID#">
		<cfif CCRes Is "Ok">
			<cfquery name="GetIds" datasource="#pds#">
				SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
				FROM AccntPlans 
				WHERE AccntPlanID In 
					(SELECT AccntPlanID 
					 FROM AccntPlans 
					 WHERE AccountID = #LocAccountID#) 
			</cfquery>
			<cfquery name="MultiCheck" datasource="#pds#">
				SELECT PrimaryID 
				FROM Multi 
				WHERE AccountID = #LocAccountID#
			</cfquery>
			<cfquery name="PersonalInfo" datasource="#pds#">
				SELECT FirstName, LastName, SalesPersonID 
				FROM Accounts 
				WHERE AccountID = #LocAccountID# 
			</cfquery>
			<cfset CCFirst = Left(LocCCNumber,1)>
			<cfif CCFirst Is "3">
				<cfset CCType = "Am Express">
			<cfelseif CCFirst Is "4">
				<cfset CCType = "Visa">
			<cfelseif CCFirst Is "5">
				<cfset CCType = "MasterCard">
			<cfelseif CCFirst Is "6">
				<cfset CCType = "Discover">
			<cfelse>
				<cfset CCType = "Misc">
			</cfif>
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
					(<cfif MultiCheck.RecordCount Is 0>#LocAccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
					 #Now()#, #LocAmount#, 0, 0, 0, #LocAmount#, 0, 
					 '#CCType# Authorization: #CCMess#', 0, 'Customer Online Payment', 
					 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
					 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
					 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
					 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
					 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
					 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
					 'CC', #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
					 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', '#CCCode#', 'Credit Card',
					 #Now()#, '#CCType#')			 
				</cfquery>
				<cfquery name="NewTopID" datasource="#pds#">
					SELECT Max(TransID) as TopID 
					FROM TransActions 
				</cfquery>
				<cfset TransID = NewTopID.TopID>
			</cftransaction>
			<cfset PaymentType = "#CCType# Authorization: #CCMess#">
			<cfset SendBack = "Approved;#TransID#;#CCCode#;#PaymentType#">
		<cfelse>
			<cfset MessageStr = CCMess>
			<cfset SendBack = "Declined;0;0;#MessageStr#">
		</cfif>
	<cfelse>
		<cf_charge Amount="#LocAmount#" ExpMonth="#LocExpMonth#" ExpYear="#LocExpYear#" Card="#LocCCNumber#" 
	 	 Member="#LocAVSName#" AVSAddress="#LocAVSAddr#" AVSZip="#LocAVSZip#" CompName="#varCompanyName#" 
		 Merchant="#varMerchant#" Action="#varSaleCode#">
		<cfif CCRes Is "Ok">
			<!--- INSERT INTO AccntTransTemp --->
			<cfset CCFirst = Left(LocCCNumber,1)>
			<cfif CCFirst Is "3">
				<cfset CCType = "Am Express">
			<cfelseif CCFirst Is "4">
				<cfset CCType = "Visa">
			<cfelseif CCFirst Is "5">
				<cfset CCType = "MasterCard">
			<cfelseif CCFirst Is "6">
				<cfset CCType = "Discover">
			<cfelse>
				<cfset CCType = "Misc">
			</cfif>
			<cftransaction>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTransTemp 
					(TempAccountID, CCExpMonth, CCExpYear, CCNumber, CCCardHolder, 
					 AVSAddress, AVSZip, CreditAmount, CCProcessDate, CCAuthCode, CCMessage, 
					 PhoneNum ) 
					VALUES
					(#LocTempID#, '#LocExpMonth#', '#LocExpYear#', '#LocCCNumber#', '#LocAVSName#', 
					 '#LocAVSAddr#', '#LocAVSZip#', #LocAmount#, #Now()#, '#CCCode#', '#CCMess#', 
					 '#LocPhoneNum#' )
				</cfquery>
				<cfquery name="NewID" datasource="#pds#">
					SELECT Max(TempTransID) as MaxID 
					FROM AccntTransTemp 
				</cfquery>
				<cfset TransID = NewID.MaxID>
			</cftransaction>

			<cfset PaymentType = "#CCType# Authorization: #CCMess#">
			<cfset SendBack = "Approved;#TransID#;#CCCode#;#PaymentType#">
		<cfelse>
			<cfset MessageStr = CCMess>
			<cfset SendBack = "Declined;0;0;#MessageStr#">
		</cfif>
	</cfif>
<cfelseif ResultType Is "Script">

	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = '#MCPageLocation#' 
		AND L.LocationAction = '#MCScrAction#' 
		AND I.TypeID = #MCIntType# 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfif MCIntType Is 1>
			<cfset LocAuthID = MCAuthID>
		<cfelseif MCIntType Is 3>
			<cfset LocFTPID = MCFTPID>
		<cfelseif MCIntType Is 4>
			<cfset LocEMailID = MCEMailID>
		</cfif>
		<cfset LocAccountID = MCAccountID>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfif InfoSendBack Is "File">
		<cfif (IsDefined("LocFileDr")) AND (IsDefined("LocFileNm"))>
			<cfset SendBack = "#LocFileDr##LocFileNm#">
		<cfelse>
			<cfset SendBack = "Error">
		</cfif>
	<cfelse>
		<cfset SendBack = "Completed">
	</cfif>
<cfelseif ResultType Is "MakePayment">
	<cfset TheAccountID = AccountID>
	<cfset TransType = TheTransType>
	<cfinclude template="cfpayment.cfm">
<cfelseif ResultType Is "Letter">
	<cfquery name="GetLetter" datasource="#pds#">
		SELECT * 
		FROM Integration 
		WHERE IntID = #SelectedLetter# 
	</cfquery>
	<cfset LocScriptID = SelectedLetter>
	<cfset LocAccountID = AccountID>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="runvarvalues.cfm">
	<cfsetting enablecfoutputonly="yes">
	<cfset LocServer = ReplaceList("#GetLetter.EMailServer#","#FindList#","#ReplList#")>
	<cfset LocSvPort = ReplaceList("#GetLetter.EMailServerPort#","#FindList#","#ReplList#")>
	<cfif Trim(LocSvPort) Is "">
		<cfset LocSvPort = 25>
	</cfif>
	<cfset LocEMalTo = ReplaceList("#GetLetter.EMailTo#","#FindList#","#ReplList#")>
	<cfset LocEMFrom = ReplaceList("#GetLetter.EMailFrom#","#FindList#","#ReplList#")>
	<cfset LocEmalCC = ReplaceList("#GetLetter.EMailCC#","#FindList#","#ReplList#")>
	<cfset LocSubjct = ReplaceList("#GetLetter.EMailSubject#","#FindList#","#ReplList#")>
	<cfset LocFileNm = ReplaceList("#GetLetter.EMailFile#","#FindList#","#ReplList#")>
	<cfset LocMessag = ReplaceList("#GetLetter.EMailMessage#","#FindList#","#ReplList#")>
	<cfset TheLocMessag = Replace(LocMessag,")*N/A*(","","All")>
	<cfset LocScriptID = SelectedLetter>
	<cfset LocAccountID = AccountID>
	<cfset TheFindList = FindList>
	<cfset TheReplList = ReplList>
	<cfinclude template="runrepeatvalues.cfm">
	<cfset TheLocMessag = TheLocMessag & RepeatMessage>
	<cfif SendEMail Is 1>
		<cfif LocServer Is Not "">
			<cfmail server="#LocServer#" port="#LocSvPort#"
			 to="#LocEMalTo#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
		<cfelse>
			<cfmail to="#LocEMalTo#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
		</cfif>
	</cfif>
	<cfset SendBack = TheLocMessag>
</cfif>

<cfsetting enablecfoutputonly="No" showdebugoutput="No">
<cfoutput>#SendBack#</cfoutput>
