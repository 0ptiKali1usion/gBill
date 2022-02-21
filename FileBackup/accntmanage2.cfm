<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. Requires the permission to change plans. --->
<!---	4.0.0 11/01/99 --->
<!--- accntmanage2.cfm --->
<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("EditDueDate.x")>
	<cfquery name="OldDate" datasource="#pds#">
		SELECT NextDueDate, PlanID, AccountID, PayBy, EMailDomainID, FTPDomainID, AuthDomainID 
		FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID#
	</cfquery>
	<cfquery name="AccountInfo" datasource="#pds#">
		SELECT SalesPersonID, FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #OldDate.AccountID# 
	</cfquery>
	<cfquery name="CheckMulti" datasource="#pds#">
		SELECT PrimaryID 
		FROM Multi 
		WHERE AccountID = #OldDate.AccountID# 
	</cfquery>
	<cfif CheckMulti.Recordcount Is 0>
		<cfset ThePrimID = OldDate.AccountID>
	<cfelse>
		<cfset ThePrimID = CheckMulti.PrimaryID>
	</cfif>
	<cfset TheFormerDate = OldDate.NextDueDate>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PersonalInfo" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = #OldDate.AccountID# 
		</cfquery>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #OldDate.PlanID# 
		</cfquery>
		<cfquery name="GetLocaleMask" datasource="#pds#">
			SELECT Value1, VarName 
			FROM Setup 
			WHERE VarName In ('Locale','DateMask1') 
		</cfquery>
		<cfloop query="GetLocaleMask">
			<cfset "#VarName#" = Value1>
		</cfloop>
		<cfset MessageString = "#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the next due date from #LSDateFormat(TheFormerDate, '#DateMask1#')# to #LSDateFormat(NextDueDate, '#DateMask1#')# for #PersonalInfo.FirstName# #PersonalInfo.LastName# on #PlanName.PlanDesc#.">
		<cfif ProrateHandle Is 1>
			<cfset MessageString = MessageString & "  The difference of #LSCurrencyFormat(ProRateAmount)# was charged to the customer.">
		<cfelseif ProrateHandle Is 2>
			<cfset MessageString = MessageString & "  The difference of #LSCurrencyFormat(ProRateAmount)# was credited to the customer.">
		<cfelseif ProrateHandle Is 0>
			<cfset MessageString = MessageString & "  The difference of #LSCurrencyFormat(ProRateAmount)# was not #LCase(HowToApply)#ed to the customer.">
		</cfif>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#OldDate.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			 '#MessageString#')
		</cfquery>
		<cfset ChangeDateMessage = 1>
	</cfif>
	<cfquery name="UpdDueDate" datasource="#pds#">
		UPDATE AccntPlans SET 
		NextDueDate = #CreateODBCDateTime(NextDueDate)# 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cftransaction>
		<cfif ProrateHandle Is 1>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
				 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
				 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
				 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField)
				VALUES 
				(#ThePrimID#, #Now()#, 0, #ProRateAmount#, 1, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
				#OldDate.PlanID#, 0, #OldDate.AccountID#, 0, 0, 0, 0, 
				'#OldDate.PayBy#', #AccountInfo.SalesPersonID#, #AccntPlanID#, #ProRateAmount#, 0, #OldDate.EMailDomainID#, #OldDate.FTPDomainID#, 
				#OldDate.AuthDomainID#, 0, '#AccountInfo.FirstName#', '#AccountInfo.LastName#', Null, 0, '#ProrateReason#')
			</cfquery>
			<cfset TransType = "Debit">
		<cfelseif ProrateHandle Is 2>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID, DateTime1, Credit, Debit, AdjustmentYN, EnteredBy, TaxYN, POPID, 
				 PlanID, TaxLevel, SubAccountID, SetUpFeeYN, PrintedYN, EMailStateYN, BatchPendingYN, 
				 PlanPayBy, SalesPersonID, AccntPlanID, DebitLeft, CreditLeft, EMailDomainID, FTPDomainID, 
				 AuthDomainID, DiscountYN, FirstName, LastName, RefundBy, RefundedYN, MemoField)
				VALUES 
				(#ThePrimID#, #Now()#, #ProRateAmount#, 0, 1, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 0, #POPID#, 
				#OldDate.PlanID#, 0, #OldDate.AccountID#, 0, 0, 0, 0, 
				'#OldDate.PayBy#', #AccountInfo.SalesPersonID#, #AccntPlanID#, 0, #ProRateAmount#, #OldDate.EMailDomainID#, #OldDate.FTPDomainID#, 
				#OldDate.AuthDomainID#, 0, '#AccountInfo.FirstName#', '#AccountInfo.LastName#', Null, 0, '#ProrateReason#')
			</cfquery>
			<cfset TransType = "Credit">
		</cfif>
		<cfquery name="GetID" datasource="#pds#">
			SELECT Max(TransID) As NTransID 
			FROM Transactions
		</cfquery>
	</cftransaction>
	<cfset TheAccountID = ThePrimID>
	<cfinclude template="cfpayment.cfm">
	<cfset UpdTab1.x = 1>
</cfif>
<cfif IsDefined("UpdTab1.x")>
	<cfif IsDate("#NextDueDate#")>
		<cfset LocDate = LSParseDateTime("#NextDueDate#")>
	</cfif>
	<cfquery name="OldDate" datasource="#pds#">
		SELECT NextDueDate, PlanID, POPID 
		FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID#
	</cfquery>
	<cfif Not IsDefined("TheFormerDate")>
		<cfset TheFormerDate = OldDate.NextDueDate>
	</cfif>
	<cfquery name="PlansPlans" datasource="#pds#">
		SELECT RecurringAmount, RecurDiscount 
		FROM Plans 
		WHERE PlanID = #OldDate.PlanID#
	</cfquery>
	<cfset PlanAmount = PlansPlans.RecurringAmount - PlansPlans.RecurDiscount>
	<cfif (OldDate.NextDueDate Is Not NextDueDate) AND (PlanAmount GT 0)>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="accntmanage3.cfm">
		<cfabort>
	</cfif>
	<cfquery name="PlanLimits" datasource="#pds#">
		SELECT P.AuthNumber, P.FTPNumber, P.FreeEMails, P.PlanDesc 
		FROM Plans P 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#)
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PrevData" datasource="#pds#">
			SELECT NextDueDate, AuthAccounts, FTPAccounts, EMailAccounts
			FROM AccntPlans 
			WHERE AccntPlanID =  #AccntPlanID# 
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AccntPlans SET 
		POPID = #POPID# 
		<cfif IsDate("#NextDueDate#")>
			, NextDueDate = #CreateODBCDateTime(LocDate)# 
		</cfif>
		<cfif AuthAccounts Is Not PlanLimits.AuthNumber>
			, AuthAccounts = <cfif Trim(AuthAccounts) Is "">Null<cfelse>#AuthAccounts#</cfif>
		<cfelse>
			, AuthAccounts = Null
		</cfif>
		<cfif FTPAccounts Is Not PlanLimits.FTPNumber>
			, FTPAccounts = <cfif Trim(FTPAccounts) Is "">Null<cfelse>#FTPAccounts#</cfif>
		<cfelse>
			, FTPAccounts = Null
		</cfif>
		<cfif EMailAccounts Is Not PlanLimits.FreeEMails>
			, EMailAccounts = <cfif Trim(EMailAccounts) Is "">Null<cfelse>#EMailAccounts#</cfif>
		<cfelse>
			, EMailAccounts = Null
		</cfif>
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWho" datasource="#pds#">
			SELECT FirstName, LastName, AccountID 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = #AccntPlanID#) 
		</cfquery>
		<cfif OldDate.POPID Is Not POPID>
			<cfquery name="OldPOPName" datasource="#pds#">
				SELECT POPName 
				FROM POPs 
				WHERE POPID = #OldDate.POPID# 
			</cfquery>
			<cfquery name="NewPOPName" datasource="#pds#">
				SELECT POPName 
				FROM POPs 
				WHERE POPID = #POPID# 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the POP from #OldPOPName.POPName# to #NewPOPName.POPName# for #GetWho.FirstName# #GetWho.LastName#.')
			</cfquery>
		</cfif>
		<cfif (LocDate Is Not TheFormerDate) AND (Not IsDefined("ChangeDateMessage"))>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# Changed the next due date from #LSDateFormat(TheFormerDate, '#DateMask1#')# to #LSDateFormat(LocDate, '#DateMask1#')# for #GetWho.FirstName# #GetWho.LastName# on #PlanLimits.PlanDesc#.')
			</cfquery>
		</cfif>	
		<cfset CompareValue = PrevData.AuthAccounts>
		<cfif CompareValue Is "">
			<cfset CompareValue = PlanLimits.AuthNumber>
		</cfif>
		<cfif AuthAccounts Is Not CompareValue>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the Auth accounts limit to <cfif Trim(AuthAccounts) Is "">the plan limit<cfelse>#AuthAccounts#</cfif> for #GetWho.FirstName# #GetWho.LastName# on #PlanLimits.PlanDesc#.')
			</cfquery>
		</cfif>
		<cfset CompareValue = PrevData.FTPAccounts>
		<cfif CompareValue Is "">
			<cfset CompareValue = PlanLimits.FTPNumber>
		</cfif>
		<cfif FTPAccounts Is Not CompareValue>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the FTP accounts limit to <cfif Trim(FTPAccounts) Is "">the plan limit<cfelse>#FTPAccounts#</cfif> for #GetWho.FirstName# #GetWho.LastName# on #PlanLimits.PlanDesc#.')
			</cfquery>
		</cfif>
		<cfset CompareValue = PrevData.EMailAccounts>
		<cfif CompareValue Is "">
			<cfset CompareValue = PlanLimits.FreeEMails>
		</cfif>
		<cfif EMailAccounts Is Not CompareValue>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the E-Mail accounts limit to <cfif Trim(EMailAccounts) Is "">the plan limit<cfelse>#EMailAccounts#</cfif> for #GetWho.FirstName# #GetWho.LastName# on #PlanLimits.PlanDesc#.')
			</cfquery>
		</cfif>
	</cfif>
</cfif>

<cfparam name="Tab" default="1">
<cfquery name="PlanInfo" datasource="#pds#">
	SELECT A.*, P.PlanDesc, P.AuthNumber, P.FTPNumber, P.FreeEMails  
	FROM AccntPlans A, Plans P 
	WHERE A.PlanID = P.PlanID 
	AND A.AccntPlanID = #AccntPlanID# 
</cfquery>
<cfif PlanInfo.AuthAccounts Is "">
	<cfset AllowAuth = PlanInfo.AuthNumber>
<cfelse>
	<cfset AllowAuth = PlanInfo.AuthAccounts>
</cfif>
<cfif PlanInfo.FTPAccounts Is "">
	<cfset AllowFTP = PlanInfo.FTPNumber>
<cfelse>
	<cfset AllowFTP = PlanInfo.FTPAccounts>
</cfif>
<cfif PlanInfo.EMailAccounts Is "">
	<cfset AllowEMail = PlanInfo.FreeEMails>
<cfelse>
	<cfset AllowEMail = PlanInfo.EMailAccounts>
</cfif>

<cfif Tab Is 1>
	<cfset HowWide = 2>
	<cfquery name="AvailPOPs" datasource="#pds#">
		SELECT POPID, POPName 
		FROM POPs 
		WHERE POPID NOT IN (#PlanInfo.POPID#)
		<cfif GetOpts.SUserYN Is 0>
			AND POPID IN 
				(SELECT POPID 
				 FROM POPPlans 
				 WHERE PlanID = #PlanInfo.PlanID#) 
			AND POPID IN 
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#) 
		</cfif>
		UNION 
		SELECT POPID, POPName 
		FROM POPs 
		WHERE POPID = #PlanInfo.POPID#
		ORDER BY POPName 
	</cfquery>
<cfelseif Tab Is 2>
	<cfset HowWide = 4>
	<cfquery name="CheckAvails" datasource="#pds#">
		SELECT ForTable 
		FROM CustomAuthSetup 
		WHERE BOBName = 'Accounts' 
		AND DBType = 'Tb' 
		AND ActiveYN = 1 
		AND CAuthID In 
			(SELECT CAuthID 
			 FROM AccountsAuth 
			 WHERE AccntPlanID = #AccntPlanID#)
	</cfquery>
	<cfparam name="ShowType" default="0">
	<cfparam name="ShowLgon" default="0">
	<cfparam name="ShowTime" default="0">
	<cfparam name="ShowIdle" default="0">
	<cfparam name="ShowIPA" default="0">
	<cfquery name="AllAuths" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif CheckAvails.RecordCount GT 0>
		<cfquery name="CheckType" datasource="#pds#">
			SELECT ActiveYN 
			FROM CustomAuthSetup 
			WHERE BOBName = 'AcntType' 
			AND ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE BOBName = 'Accounts' 
				 AND DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID In 
				 	(SELECT CAuthID 
					 FROM AccountsAuth 
					 WHERE AccntPlanID = #AccntPlanID#) 
				)
			AND CAuthID In 
				(SELECT CAuthID 
				 FROM AccountsAuth 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfif ListFind(ValueList(CheckType.ActiveYN),1)>
			<cfset ShowType = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfquery name="CheckLogin" datasource="#pds#">
			SELECT ActiveYN 
			FROM CustomAuthSetup 
			WHERE BOBName = 'LoginLimit' 
			AND ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE BOBName = 'Accounts' 
				 AND DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID In 
				 	(SELECT CAuthID 
					 FROM AccountsAuth 
					 WHERE AccntPlanID = #AccntPlanID#) 
				)
			AND CAuthID In 
				(SELECT CAuthID 
				 FROM AccountsAuth 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfif ListFind("#ValueList(CheckLogin.ActiveYN)#",1)>
			<cfset ShowLgon = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfquery name="CheckCTime" datasource="#pds#">
			SELECT ActiveYN 
			FROM CustomAuthSetup 
			WHERE BOBName = 'MaxConnectTime' 
			AND ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE BOBName = 'Accounts' 
				 AND DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID In 
				 	(SELECT CAuthID 
					 FROM AccountsAuth 
					 WHERE AccntPlanID = #AccntPlanID#) 
				)
			AND CAuthID In 
				(SELECT CAuthID 
				 FROM AccountsAuth 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfif ListFind("#ValueList(CheckCTime.ActiveYN)#",1)>
			<cfset ShowTime = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfquery name="CheckITime" datasource="#pds#">
			SELECT ActiveYN 
			FROM CustomAuthSetup 
			WHERE BOBName = 'MaxIdleTime' 
			AND ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE BOBName = 'Accounts' 
				 AND DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID In 
				 	(SELECT CAuthID 
					 FROM AccountsAuth 
					 WHERE AccntPlanID = #AccntPlanID#) 
				)
			AND CAuthID In 
				(SELECT CAuthID 
				 FROM AccountsAuth 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfif ListFind("#ValueList(CheckITime.ActiveYN)#",1)>
			<cfset ShowIdle = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfquery name="CheckIPA" datasource="#pds#">
			SELECT ActiveYN 
			FROM CustomAuthSetup 
			WHERE BOBName = 'custipaddress' 
			AND ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE BOBName = 'Accounts' 
				 AND DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID In 
				 	(SELECT CAuthID 
					 FROM AccountsAuth 
					 WHERE AccntPlanID = #AccntPlanID#) 
				)
			AND CAuthID In 
				(SELECT CAuthID 
				 FROM AccountsAuth 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfif ListFind("#ValueList(CheckIPA.ActiveYN)#",1)>
			<cfset ShowIPA = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
	<cfelse>
		<cfif ListLen(ValueList(AllAuths.Filter1)) GT 0>
			<cfset ShowType = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfif ListLen(ValueList(AllAuths.IP_Address)) GT 0>
			<cfset ShowIPA = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfif ListLen(ValueList(AllAuths.Max_Connect)) GT 0>
			<cfset ShowTime = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfif ListLen(ValueList(AllAuths.Max_Idle)) GT 0>
			<cfset ShowIdle = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
		<cfif ListLen(ValueList(AllAuths.Max_Logins)) GT 0>
			<cfset ShowLgon = 1>
			<cfset HowWide = HowWide + 1>
		</cfif>
	</cfif>
<cfelseif Tab Is 3>
	<cfset HowWide = 6>
	<cfquery name="AllFTPs" datasource="#pds#">
		SELECT * 
		FROM AccountsFTP 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
<cfelseif Tab Is 4>
	<cfset HowWide = 9>
	<cfquery name="AllEMail" datasource="#pds#">
		SELECT E.AccountID, E.EMailID AS PrEMailID, E.PrEMail, E.EMail, E.ContactYN, 
		E.FullName, E.Alias, E.DomainName, E.Login, E.FullName,  
      A.EMailID, A.EMail AS EMailAlias, C.AllowAlias, C.AllowForward, E.ForwardTo, 1 As Counter 
		FROM AccountsEMail A, AccountsEMail E, CustomEMail C 
		WHERE A.AliasTo =* E.EMailID 
		AND E.CEMailID = C.CEMailID 
		AND E.AccntPlanID = #AccntPlanID# 
		AND E.Alias = 0 
		AND (A.Alias = 1 OR A.Alias Is Null) 
		UNION 
		SELECT E.AccountID, E.EMailID AS PrEMailID, E.PrEMail, E.EMail, E.ContactYN, 
		E.FullName, E.Alias, E.DomainName, E.Login, E.FullName, 
		E.EMailID, NULL, 0, 0, Null, 0 As Counter 
		FROM AccountsEMail E 
		WHERE ContactYN = 1 
		AND E.AccntPlanID = #AccntPlanID# 
		ORDER BY E.PrEMail DESC , E.EMail, A.EMail 
	</cfquery>
	<cfquery name="TotalEMails" datasource="#pds#">
		SELECT Count(EMailID) As CurTotal 
		FROM AccountsEMail 
		WHERE AccntPlanID = #AccntPlanID# 
		AND ContactYN = 0 
	</cfquery>
	<cfset AliasShow = 1>
	<cfset ForwShow = 1>
	<cfset ForwardToList = ListLen(ValueList(AllEMail.ForwardTo))>
	<cfif ForwardToList Is 0>
		<cfset HowWide = HowWide - 1>
	</cfif>
	<cfset AliasList = ValueList(AllEMail.AllowAlias)>
	<cfif ListFind(AliasList,1) Is 0>
		<cfset HowWide = HowWide - 1>
		<cfset AliasShow = 0>
	</cfif>
	<cfset ForwardList = ValueList(AllEMail.AllowForward)>
	<cfif ListFind(ForwardList,1) Is 0>
		<cfset HowWide = HowWide - 1>
		<cfset ForwShow = 0>
	</cfif>
</cfif>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #PlanInfo.AccountID# 
</cfquery>
<cfquery name="GetLocaleMask" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'DateMask1' 
</cfquery>
<cfset DateMask1 = GetLocaleMask.Value1>
	
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Account Management</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif Tab LTE 4>
	<form method="post" action="accntmanage.cfm">
		<input type="image" name="return" src="images/return.gif" border="0">
		<cfoutput><input type="hidden" name="AccountID" value="#PlanInfo.AccountID#"></cfoutput>
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName#<br>#PlanInfo.PlanDesc#</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="accntmanage2.cfm">
						<th bgcolor=<cfif Tab Is "1">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is "1">checked</cfif> value="1" onclick="submit()" id="col1"><label for="col1">General</label></th>
						<th bgcolor=<cfif Tab Is "2">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is "2">checked</cfif> value="2" onclick="submit()" id="col2"><label for="col2">Authentication</label></th>
						<th bgcolor=<cfif Tab Is "3">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is "3">checked</cfif> value="3" onclick="submit()" id="col3"><label for="col3">FTP</label></th>
						<th bgcolor=<cfif Tab Is "4">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is "4">checked</cfif> value="4" onclick="submit()" id="col4"><label for="col4">E-Mail</label></th>
						<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
	<form method="post" action="accntmanage2.cfm">
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">POP</td>
		</cfoutput>
				<td><select name="POPID">
					<cfoutput query="AvailPOPs">
						<option <cfif POPID Is PlanInfo.POPID>selected</cfif> value="#POPID#">#POPName#
					</cfoutput>
				</select></td>
			</tr>
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<td align="right">Next Due Date</td>
				<td bgcolor="#tdclr#"><input type="text" name="NextDueDate" value="#LSDateFormat(PlanInfo.NextDueDate, '#DateMask1#')#" size="12"></td>
			</tr>
		</cfoutput>
		<cfif GetOpts.OverRide Is 1>
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td align="right">Auth Limit</td>
					<td bgcolor="#tdclr#"><input type="text" name="AuthAccounts" value="#AllowAuth#" size="3" maxlength="3"> Plan Limit: #PlanInfo.AuthNumber#</td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">FTP Limit</td>
					<td bgcolor="#tdclr#"><input type="text" name="FTPAccounts" value="#AllowFTP#" size="3" maxlength="3"> Plan Limit: #PlanInfo.FTPNumber#</td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">E-Mail Limit</td>
					<td bgcolor="#tdclr#"><input type="text" name="EMailAccounts" value="#AllowEMail#" size="3" maxlength="3"> Plan Limit: #PlanInfo.FreeEMails#</td>
				</tr>
			</cfoutput>
		</cfif>
		<tr>
			<th colspan="2"><input type="image" src="images/update.gif" name="UpdTab1" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
		</cfoutput>
	</form>
<cfelseif Tab Is 2>
	<cfoutput>
		<cfif AllowAuth GT AllAuths.Recordcount>
			<tr>
				<form method="post" action="accntmanage6.cfm">
					<td align="right" colspan="#HowWide#"><input type="Image" src="images/addnew.gif" name="NewAuth" border="0"></td>
					<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
				</form>
			</tr>
		</cfif>
		<tr bgcolor="#thclr#">
			<th>Edit</th>
			<th>UserName</th>
			<th>Domain Name</th>
			<cfif ShowType Is 1>
				<th>Filter</th>
			</cfif>
			<cfif ShowLgon Is 1>
				<th>Logins</th>
			</cfif>
			<cfif ShowTime Is 1>
				<th>Max Connect</th>
			</cfif>
			<cfif ShowIdle Is 1>
				<th>Idle</th>
			</cfif>
			<cfif ShowIPA Is 1>
				<th>IP</th>
			</cfif>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfoutput query="AllAuths">
		<form method="post" action="accntmanage4.cfm">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="AuthID" value="#AuthID#" onclick="submit()"></th>
				<td>#UserName#</td>
				<td>#DomainName#</td>
				<cfif ShowType Is 1>
					<td>#Filter1#<cfif Trim(Filter1) Is "">&nbsp;</cfif></td>
				</cfif>
				<cfif ShowLgon Is 1>
					<td align="right">#Max_Logins#<cfif Trim(Max_Logins) Is "">&nbsp;</cfif></td>
				</cfif>
				<cfif ShowTime Is 1>
					<td align="right">#Max_Connect#<cfif Trim(Max_Connect) Is "">&nbsp;</cfif></td>
				</cfif>
				<cfif ShowIdle Is 1>
					<td align="right">#Max_Idle#<cfif Trim(Max_Idle) Is "">&nbsp;</cfif></td>
				</cfif>
				<cfif ShowIPA Is 1>
					<td align="right">#IP_Address#<cfif Trim(IP_Address) Is "">&nbsp;</cfif></td>
				</cfif>
				<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
		</form>
		<form method="post" action="accntmanage5.cfm">
				<th bgcolor="#tdclr#"><input type="radio" name="AuthID" value="#AuthID#" onclick="submit()"></th>
				<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
			</tr>
		</form>
	</cfoutput>
<cfelseif Tab Is 3>
	<cfoutput>
		<cfif AllowFTP GT AllFTPs.Recordcount>
			<tr>
				<form method="post" action="accntftp6.cfm">
					<td align="right" colspan="#HowWide#"><input type="Image" src="images/addnew.gif" name="NewFTP" border="0"></td>
					<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
				</form>
			</tr>
		</cfif>
		<tr bgcolor="#thclr#">
			<th>Edit</th>
			<th>UserName</th>
			<th>Domain Name</th>
			<th>Max Connect</th>
			<th>Idle</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfoutput query="AllFTPs">
		<tr bgcolor="#tbclr#">
			<form method="post" action="accntftp4.cfm">
				<th bgcolor="#tdclr#"><input type="radio" name="FTPID" value="#FTPID#" onclick="submit()"><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
				<td>#UserName#</td>
				<td>#DomainName#</td>
				<td align="right">#Max_Connect1#<cfif Trim(Max_Connect1) Is "">&nbsp;</cfif></td>
				<td align="right">#Max_Idle1#<cfif Trim(Max_Idle1) Is "">&nbsp;</cfif></td>
			</form>
			<form method="post" action="accntftp5.cfm">
				<th bgcolor="#tdclr#"><input type="radio" name="FTPID" value="#FTPID#" onclick="submit()"><input type="Hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
			</form>
		</tr>
	</cfoutput>
<cfelseif Tab Is 4>
	<cfoutput>
		<cfif AllowEMail GT TotalEMails.CurTotal>
			<tr>
				<form method="post" action="accntemail6.cfm">
					<td align="right" colspan="#HowWide#"><input type="image" name="NewEMail" src="images/addnew.gif" border="0"><input type="Hidden" name="AccntPlanID" value="#AccntPlanID#"></td>
				</form>
			</tr>
		</cfif>
		<tr>
			<form method="post" action="accntemail7.cfm">
				<td align="right" colspan="#HowWide#"><input type="image" name="NewContact" src="images/contact.gif" border="0"></td>
					<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
			</form>
		</tr>
		<cfset RowHigh  = 1>
		<cfif AliasShow Is 1>
			<cfset RowHigh = 2>
		</cfif>
		<cfif ForwShow Is 1>
			<cfset RowHigh = 2>
		</cfif>
		<tr bgcolor="#thclr#" valign="top">
			<th rowspan="#RowHigh#">Edit</th>
			<th rowspan="#RowHigh#">Type</th>
			<th rowspan="#RowHigh#">E-Mail</th>
			<cfif ForwardToList GT 0>
				<th rowspan="#RowHigh#">Forward To</th>
			</cfif>
			<th rowspan="#RowHigh#">Name</th>
			<th rowspan="#RowHigh#">Domain Name</th>
			<cfset ColWide = 0>
			<cfif AliasShow Is 1>
				<cfset ColWide = ColWide + 1>
			</cfif>
			<cfif ForwShow Is 1>
				<cfset ColWide = ColWide + 1>
			</cfif>
			<cfif ColWide GT 0>
				<th colspan="#ColWide#">Add</th>
			</cfif>
			<th rowspan="#RowHigh#">Delete</th>
		</tr>
		<cfif RowHigh Is 2>
			<tr bgcolor="#thclr#">
				<cfif AliasShow Is 1>
					<th>Alias</th>
				</cfif>
				<cfif ForwShow Is 1>
					<th>Forward</th>
				</cfif>
			</tr>
		</cfif>
	</cfoutput>
	<cfoutput query="AllEMail" group="PrEMailID">
		<cfif ContactYN Is 1>
			<form method="post" action="accntemail7.cfm">
		<cfelse>
			<form method="post" action="accntemail4.cfm">
		</cfif>
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="EMailID" value="#PrEMailID#" onclick="submit()"><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
		</form>
				<cfif ContactYN Is 1>
					<td>Contact</td>
				<cfelse>	
					<td>Account</td>
				</cfif>
				<td>#EMail#</td>
				<cfif ForwardToList GT 0>
					<td><cfif ForwardTo Is "">&nbsp;<cfelse>#ForwardTo#</cfif></td>
				</cfif>
				<td>#FullName#<cfif Trim(FullName) Is "">&nbsp;</cfif></td>
				<cfif ContactYN Is 1>
					<td>&nbsp;</td>
				<cfelse>
					<td>#DomainName#</td>
				</cfif>
				<cfif (Alias Is 0) AND (ContactYN Is 0)>
					<cfif AliasShow Is 1>
						<cfif AllowAlias Is 1>
							<form method="post" action="accntemail9.cfm">
								<th bgcolor="#tdclr#"><input type="Radio" name="EMailID" value="#PrEMailID#" onclick="submit()"><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
							</form>
						<cfelse>
							<td bgcolor="#tdclr#">&nbsp;</td>
						</cfif>
					</cfif>
					<cfif ForwShow Is 1>
						<cfif AllowForward Is 1>
							<form method="post" action="accntemail10.cfm">
								<th bgcolor="#tdclr#"><input type="Radio" name="EMailID" value="#PrEMailID#" onclick="submit()"><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
							</form>
						<cfelse>
							<td bgcolor="#tdclr#">&nbsp;</td>
						</cfif>
					</cfif>
				<cfelse>
					<cfif AliasShow Is 1>
						<td bgcolor="#tdclr#">&nbsp;</td>
					</cfif>
					<cfif ForwShow Is 1>
						<td bgcolor="#tdclr#">&nbsp;</td>
					</cfif>
				</cfif>
		<cfif ContactYN Is 1>
			<form method="post" action="accntemail8.cfm">
		<cfelse>
			<form method="post" action="accntemail5.cfm">
		</cfif>
				<th bgcolor="#tdclr#"><input type="radio" name="EMailID" value="#PrEMailID#" onclick="submit()"><input type="Hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
			</tr>
		</form>
		<cfoutput>
			<cfif EMailAlias Is Not "">
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#">&nbsp;</th>
					<td>Alias</td>
					<td>#EMailAlias#</td>
					<cfif ForwardToList GT 0>
						<td>&nbsp;</td>
					</cfif>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<cfif AliasShow Is 1>
						<th bgcolor="#tdclr#">&nbsp;</th>
					</cfif>
					<cfif ForwShow Is 1>
						<th bgcolor="#tdclr#">&nbsp;</th>
					</cfif>
					<form method="post" action="accntemail5.cfm">
						<th bgcolor="#tdclr#"><input type="radio" name="EMailID" value="#EmailID#" onclick="submit()"><input type="Hidden" name="AccntPlanID" value="#AccntPlanID#"></th>
					</form>
				</tr>
			</cfif>
		</cfoutput>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 