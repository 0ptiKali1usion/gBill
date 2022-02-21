<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 3 of the debitor. --->
<!--- 4.0.0 09/14/99 --->
<!--- monthinv3.cfm --->

<cfparam name="JumpSecs" default="5">
<cfset Mrows = Mrow * 3>
<cfparam name="SendRows" default="#Mrows#">
<cfquery name="GetAddresses" datasource="#pds#" maxrows="#SendRows#">
	SELECT * 
	FROM TempDebit 
	WHERE AdminID = #MyAdminID# 
	ORDER BY LastName, FirstName 
</cfquery>
<cfloop query="GetAddresses">
	<!--- Put the entries into transactions --->
	<cfset InsBOBHistory = 0>
	<cftransaction>
	<cfif DebitAmount GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 0 
			AND TaxLevel = 0 
			AND DiscountYN = 0
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,0,#DebitAmount#,'#MemoField#',0,
				 '#EnteredBy#',0,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(AuthDomainID) Is "">Null<cfelse>#AuthDomainID#</cfif>,
				 #POPID#,#PlanID#,0,0,#AccountID#,0,#CreateODBCDateTime(DebitFromDate)#,
				 <cfif CutOffDate Is "">Null<cfelse>#CreateODBCDateTime(CutOffDate)#</cfif>,0,
				 <cfif PayDueDate Is "">Null<cfelse>#CreateODBCDateTime(PayDueDate)#</cfif>,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,#DebitAmount#,0,0,
				 '#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory + DebitAmount>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(TransID) As NTransID 
				FROM Transactions
			</cfquery>
			<cfset NewtransID = GetID.NTransID>
		</cfif>
	</cfif>
	<cfif DebitDiscount GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 0 
			AND TaxLevel = 0 
			AND DiscountYN = 1 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,#DebitDiscount#,0,'#MemoDiscount#',0,
				 '#EnteredBy#',0,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 #POPID#,#PlanID#,0,0,#AccountID#,0,Null,Null,0,Null,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,0,
				 #DebitDiscount#,1,'#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory - DebitDiscount>
			<cfif Not IsDefined("NewtransID")>
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(TransID) As NTransID 
					FROM Transactions
				</cfquery>
				<cfset NewtransID = GetID.NTransID>			
			</cfif>
		</cfif>
	</cfif>
	<cfif TotalTax1 GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 1 
			AND TaxLevel = 1 
			AND DiscountYN = 0 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,0,#TotalTax1#,'#TaxDesc1#',0,
				 '#EnteredBy#',1,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 #POPID#,#PlanID#,1,0,#AccountID#,0,#CreateODBCDateTime(DebitFromDate)#,
				 <cfif CutOffDate Is "">Null<cfelse>#CreateODBCDateTime(CutOffDate)#</cfif>,0,
				 <cfif PayDueDate Is "">Null<cfelse>#CreateODBCDateTime(PayDueDate)#</cfif>,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,
				 #TotalTax1#,0,0,'#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory + TotalTax1>
			<cfif Not IsDefined("NewtransID")>
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(TransID) As NTransID 
					FROM Transactions
				</cfquery>
				<cfset NewtransID = GetID.NTransID>			
			</cfif>
		</cfif>
	</cfif>
	<cfif TotalTax2 GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 1 
			AND TaxLevel = 2 
			AND DiscountYN = 0 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,0,#TotalTax2#,'#TaxDesc2#',0,
				 '#EnteredBy#',1,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 #POPID#,#PlanID#,2,0,#AccountID#,0,#CreateODBCDateTime(DebitFromDate)#,
				 <cfif CutOffDate Is "">Null<cfelse>#CreateODBCDateTime(CutOffDate)#</cfif>,0,
				 <cfif PayDueDate Is "">Null<cfelse>#CreateODBCDateTime(PayDueDate)#</cfif>,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,
				 #TotalTax2#,0,0,'#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory + TotalTax2>
			<cfif Not IsDefined("NewtransID")>
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(TransID) As NTransID 
					FROM Transactions
				</cfquery>
				<cfset NewtransID = GetID.NTransID>			
			</cfif>
		</cfif>
	</cfif>
	<cfif TotalTax3 GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 1 
			AND TaxLevel = 3 
			AND DiscountYN = 0 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,0,#TotalTax3#,'#TaxDesc3#',0,
				 '#EnteredBy#',1,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 #POPID#,#PlanID#,3,0,#AccountID#,0,#CreateODBCDateTime(DebitFromDate)#,
				 <cfif CutOffDate Is "">Null<cfelse>#CreateODBCDateTime(CutOffDate)#</cfif>,0,
				 <cfif PayDueDate Is "">Null<cfelse>#CreateODBCDateTime(PayDueDate)#</cfif>,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,
				 #TotalTax3#,0,0,'#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory + TotalTax3>
			<cfif Not IsDefined("NewtransID")>
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(TransID) As NTransID 
					FROM Transactions
				</cfquery>
				<cfset NewtransID = GetID.NTransID>			
			</cfif>
		</cfif>
	</cfif>
	<cfif TotalTax4 GT 0>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT TransID 
			FROM Transactions 
			WHERE AccountID = #PrimaryAccountID# 
			AND DebitFromDate = #CreateODBCDateTime(DebitFromDate)# 
			AND DebitToDate = #CreateODBCDateTime(DebitToDate)# 
			AND DateTime1 = #CreateODBCDateTime(DebitDate)# 
			AND AccntPlanID = #AccntPlanID# 
			AND TaxYN = 1 
			AND TaxLevel = 4 
			AND DiscountYN = 0 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
				 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
				 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
				 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
				 FirstName,LastName)
				VALUES (#PrimaryAccountID#,#CreateODBCDateTime(DebitDate)#,0,#TotalTax4#,'#TaxDesc4#',0,
				 '#EnteredBy#',1,<cfif Trim(EMailDomainID) Is "">Null<cfelse>#EMailDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 <cfif Trim(FTPDomainID) Is "">Null<cfelse>#FTPDomainID#</cfif>,
				 #POPID#,#PlanID#,4,0,#AccountID#,0,#CreateODBCDateTime(DebitFromDate)#,
				 <cfif CutOffDate Is "">Null<cfelse>#CreateODBCDateTime(CutOffDate)#</cfif>,0,
				 <cfif PayDueDate Is "">Null<cfelse>#CreateODBCDateTime(PayDueDate)#</cfif>,0,0,0,
				 #CreateODBCDateTime(DebitFromDate)#,#CreateODBCDateTime(DebitToDate)#,'#PayBy#',#SalesPersonID#,#AccntPlanID#,
				 #TotalTax4#,0,0,'#FirstName#','#LastName#')
			</cfquery>
			<cfset InsBOBHistory = InsBOBHistory + TotalTax4>
			<cfif Not IsDefined("NewtransID")>
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(TransID) As NTransID 
					FROM Transactions
				</cfquery>
				<cfset NewtransID = GetID.NTransID>			
			</cfif>
		</cfif>
	</cfif>
	<cfset TheNextDueDate = DateAdd("d",1,DebitToDate)>
	<cfset TheNextDueDate = CreateDateTime(Year(TheNextDueDate),Month(TheNextDueDate),Day(TheNextDueDate),0,0,0)>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AccntPlans SET 
		NextDueDate = #CreateODBCDateTime(TheNextDueDate)#, 
		LastDebitDate = #CreateODBCDateTime(DebitDate)# 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfif InsBOBHistory GT 0>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#PrimaryAccountID#,#MyAdminID#, #Now()#,'Debited','#StaffMemberName.FirstName# #StaffMemberName.LastName# ran the debitor for #FirstName# #LastName#.  #LSCurrencyFormat(InsBOBHistory)# was debited for #LSDateFormat(DebitFromDate, '#DateMask1#')# to #LSDateFormat(DebitToDate, '#DateMask1#')#.')
			</cfquery>
		</cfif>
	</cfif>
	</cftransaction>
	<!--- Run the page that calculates and pays off the older transactions --->
	<cfset TheAccountID = PrimaryAccountID>
	<cfset TransType = "Debit">
	<cfinclude template="cfpayment.cfm">
	<!--- If letter is selected then replace the letter variables and send the letter --->	
	<cfif (EMailAddr Is Not "") 
	  AND ((DebitAmount - DebitDiscount + TotalTax1 + TotalTax2 + TotalTax3 + TotalTax4) GT 0) 
	  AND (SelectedLetter GT 0) >	
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
		<cfset LocEMFrom = ReplaceList("#GetLetter.EMailFrom#","#FindList#","#ReplList#")>
		<cfset LocEMTo = ReplaceList("#GetLetter.EMailTo#","#FindList#","#ReplList#")>
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
				 to="#LocEMTo#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
			<cfelse>
				<cfmail to="#LocEMTo#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
			</cfif>
		</cfif>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				('#LocMessag#',#AccountID#,#MyAdminID#, #Now()#,'E-Mailed','#StaffMemberName.FirstName# #StaffMemberName.LastName# e-mailed #GetWhoIs.FirstName# #GetWhoIs.LastName# at #LocEMTo#.')
			</cfquery>
		</cfif>
		<cfif IsDefined("NewtransID")>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE Transactions SET 
				EMailStateYN = 1, EMailStateDate = #Now()# 
				WHERE EMailStateYN = 0 
				AND AccountID = #AccountID# 
				AND TransID >= #NewTransID# 
			</cfquery>
		</cfif>
	</cfif>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM TempDebit 
		WHERE AdminID = #MyAdminID# 
		AND AccountID = #AccountID#
	</cfquery>
</cfloop>

<cfquery name="CheckFinished" datasource="#pds#">
	SELECT DebitID
	FROM TempDebit 
	WHERE AdminID = #MyAdminID#
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif CheckFinished.Recordcount Is 0>
	<title>Finished Processing</title>
<cfelse>
	<cfoutput><META HTTP-EQUIV=REFRESH CONTENT="#JumpSecs#; URL=monthinv3.cfm?RequestTimeout=500"></cfoutput>
	<title>Processing</title>
</cfif>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif CheckFinished.Recordcount Is 0>
	<form method="post" action="monthinv.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
	<cfif CheckFinished.Recordcount GT 0>
		<td bgcolor="#tbclr#">Processing!  Please Wait!</td>
	<cfelse>
		<td bgcolor="#tbclr#">gBill has finished processing the debit list.</td>
	</cfif>
	</tr>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

