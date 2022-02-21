<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page allows users to signup online. --->
<!--- 4.0.1 01/25/01 Added support for IPAD Email directory structure.
		4.0.0 10/10/00 --->
<!--- signup8.cfm --->

<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
	<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
FROM Setup 
WHERE VarName = 'DateMask1' 
OR VarName = 'Locale' ">
</cfhttp>
<cfset TheResult = cfhttp.FileContent>
<cfwddx action="WDDX2CFML" input="#TheResult#" output="SetDefaults">
<cfloop query="SetDefaults">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
	<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
	FROM AccntTemp 
	WHERE AccountID = #AccountID# ">
</cfhttp>
<cfset TheResult = cfhttp.FileContent>
<cfwddx action="WDDX2CFML" input="#TheResult#" output="AccntInfo">

<cfset OldAccountID = AccountID>

<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
	<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT AutoActCK, AutoActCD, AutoActCC, AutoActPO, FileCreate 
		FROM Plans 
		WHERE PlanID IN (#AccntInfo.SelectPlan#) ">
</cfhttp>
<cfset TheResult = cfhttp.FileContent>
<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanDetails">

<cfif PayByCur Is "Ck">
	<cfset CreateAcnts = ListFind("#ValueList(PlanDetails.AutoActCK)#","1")>
<cfelseif PayByCur Is "Cc">
	<cfset CreateAcnts = ListFind("#ValueList(PlanDetails.AutoActCC)#","1")>
<cfelseif PayByCur Is "Cd">
	<cfset CreateAcnts = ListFind("#ValueList(PlanDetails.AutoActCD)#","1")>
<cfelseif PayByCur Is "Po">
	<cfset CreateAcnts = ListFind("#ValueList(PlanDetails.AutoActPO)#","1")>
</cfif>

<cfif CreateAcnts GT "0">
	<!--- Insert to Accounts --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
		FROM Accounts 
		WHERE Login = '#AccntInfo.Login#' ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckFirst">
	
	<cfif CheckFirst.RecordCount Is 0>
		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO Accounts
			(Login, Password, LastName, FirstName, Initial, Address1, Address2, Address3, 
			 City, State, Zip, DayPhone, EvePhone, Fax, PCType, ModemSpeed, OSVersion, Notes, 
			 CancelYN, StartDate, DeactivatedYN, Company, Modem, SalesPersonID, Country) 
			SELECT Login, Password, LastName, FirstName, Initial, Address1, Address2, Address3, 
			City, State, Zip, DayPhone, EvePhone, Fax, PCType, ModemSpeed, OSVersion, Notes, 
			CancelYN, StartDate, DeactivatedYN, Company, Modem, SalesPersonID, Country 
			FROM AccntTemp 
			WHERE AccountID = #AccountID#  ">
			<cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(AccountID) as NewID 
			FROM Accounts ">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="MaxID">
		<cfset NewAccountID = MaxID.NewID>
	<cfelse>
		<cfset NewAccountID = CheckFirst.AccountID>
	</cfif>
	<!--- Loop on Plans --->
	<cfset Looper = 0>
	<cfset EMailNum = 1>
	<cfloop index="B50" list="#AccntInfo.SelectPlan#">
		<!--- Insert to AccntPlans --->
		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
			FROM AccntPlans 
			WHERE AccountID = #NewAccountID# 
			AND PlanID = #B50# ">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckFirst">
		<cfif CheckFirst.RecordCount Is 0>
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT Max(EndDate) as DueDate 
				FROM AccntTempFin 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="NextDue">
		
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT DomainID, EMailServer
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'EMail') ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="EMailID">
		
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT DomainID, FTPServer
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'FTP') ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="FTPID">
		
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT DomainID, AuthServer 
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'Auth') ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="AuthDomID">
		
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT DomainID 
				FROM Domains 
				WHERE Primary1 = 1 ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="DefDomain">
		
			<cfset DefDomainID = DefDomain.DomainID>
			<cfset PayBy = PayByFut>
			<cfset LocQuery = "INSERT INTO AccntPlans
					(AccountID, PlanID, NextDueDate, POPID, EMailDomainID, EMailServer, 
					 FTPDomainID, FTPServer, AuthDomainID, AuthServer, StartDate, 
					 LastDebitDate, AccntStatus, PayBy, PostalRem, Taxable, BillingStatus)
					VALUES
					(#NewAccountID#, #B50#, ">
					<cfif NextDue.DueDate Is "">
						<cfset LocQuery = LocQuery & "#Now()#">
					<cfelse>
						<cfset LocQuery = LocQuery & "#CreateODBCDateTime(NextDue.DueDate)#">
					</cfif>
					<cfset LocQuery = LocQuery & ", #AccntInfo.POPID#, ">
					<cfif EMailID.DomainID Is "">
						<cfset LocQuery = LocQuery & "#DefDomainID#, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "#EMailID.DomainID#, ">
					</cfif> 
					<cfif EMailID.EMailServer Is "">
						<cfset LocQuery = LocQuery & "Null, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "'#EMailID.EMailServer#', ">
					</cfif> 
					<cfif FTPID.DomainID Is "">
						<cfset LocQuery = LocQuery & "#DefDomainID#, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "#FTPID.DomainID#, ">
					</cfif> 
					<cfif FTPID.FTPServer Is "">
						<cfset LocQuery = LocQuery & "Null, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "'#FTPID.FTPServer#', ">
					</cfif> 
					<cfif AuthDomID.DomainID Is "">
						<cfset LocQuery = LocQuery & "#DefDomainID#, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "#AuthDomID.DomainID#, ">
					</cfif> 
					<cfif AuthDomID.AuthServer Is "">
						<cfset LocQuery = LocQuery & "Null, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "'#AuthDomID.AuthServer#', ">
					</cfif> 
					<cfset LocQuery = LocQuery & "#Now()#, #Now()#, 0, '#PayBy#', ">
					<cfif AccntInfo.PostalInv Is "">
						<cfset LocQuery = LocQuery & "Null, ">
					<cfelse>
						<cfset LocQuery = LocQuery & "#AccntInfo.PostalInv#, ">
					</cfif> 
					<cfset LocQuery = LocQuery & "#AccntInfo.TaxFree#, 1) ">
			<cftransaction>
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">
					 <cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(AccntPlanID) as NewID 
						FROM AccntPlans ">
				</cfhttp>
				<cfset TheResult = cfhttp.FileContent>
				<cfwddx action="WDDX2CFML" input="#TheResult#" output="TheID">

				<cfset "AccntPlanID#Looper#" = TheID.NewID>
				
				<cfif (EMailID.DomainID Is "") AND (FTPID.DomainID Is "") AND (AuthDomID.DomainID Is "")>
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccntPlans SET 
						AuthDomainID = 
							(SELECT DomainID 
							 FROM Domains 
							 WHERE Primary1 = 1) 
						WHERE AccntPlanID = #TheID.NewID#">
				</cfhttp>
				</cfif>
				<cfset AccountPlanID = TheID.NewID>
				<cfif AccntInfo.ContactEMail Is Not "">
					<cfset Cond1 = FindNoCase("@",AccntInfo.ContactEMail)>
					<cfif Cond1 GT 0>
						<cfset Pos1 = Cond1>
					<cfelse>
						<cfset Pos1 = 1>
					</cfif>
					<cfset Cond2 = FindNoCase(".",AccntInfo.ContactEMail,Pos1)>
					<cfif (Cond1 GT 0) AND (Cond2 GT 0)>
						<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
							<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT EmailID 
							FROM AccountsEMail 
							WHERE AccountID = #NewAccountID# 
							AND EMail = '#AccntInfo.ContactEMail#' ">
						</cfhttp>
						<cfset TheResult = cfhttp.FileContent>
						<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckFirst">

						<cfif CheckFirst.RecordCount Is 0>
							<cfset EMailToCheck = Trim(AccntInfo.ContactEMail)>
							<cfset Pos1 = FindNoCase("@",EMailToCheck)>
							<cfif Pos1 GT 0>
								<cfset EMFirst = Left(EMailToCheck,Pos1)>
								<cfset Len1 = Len(EMailToCheck) - Pos1>
								<cfset EMSecond = Right(EMailToCheck,Len1)>
								<cfset EMFirst = ReplaceList(EMFirst,"@","")>
								<cfset EMSecond = ReplaceList(EMSecond,"@","")>
							<cfelse>
								<cfset EMFirst = "">
								<cfset EMSecond = "">
							</cfif>
							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AccountsEMail 
								(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
								PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
								EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit, CEMailID)
								VALUES 
								(#NewAccountID#, 0, 
								 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
								 '#AccntInfo.ContactEMail#', Null, 
								 '#AccntInfo.FirstName#', '#AccntInfo.LastName#', 0, 1, 1, 
								 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
								 <cfif Trim(EMSecond) Is "">Null<cfelse>'#EMSecond#'</cfif>, 
								 '#AccntInfo.FirstName# #AccntInfo.LastName#', Null, #AccountPlanID#, Null, Null, Null, 0)  ">
							</cfhttp>
						</cfif>
					</cfif>
				</cfif>
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT ExpireTo, ExpireDays, PlanDesc 
					FROM Plans 
					WHERE PlanID = #B50#">
				</cfhttp>
				<cfset TheResult = cfhttp.FileContent>
				<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanRollbacks">
						
				<cfif PlanRollbacks.ExpireDays GT 0>
					<!--- Set The Rollback --->
					<cfset DateToRollBack = DateAdd("d",PlanRollbacks.ExpireDays,Now())>
					<cfset DateRollBack = CreateDateTime(Year(DateToRollBack),Month(DateToRollBack),Day(DateToRollBack),0,0,0)>

					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT PlanID, PlanDesc 
						FROM Plans 
						WHERE PlanID = #PlanRollbacks.ExpireTo#">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckFirst">
						
					<cfif CheckFirst.Recordcount GT 0>
						<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
							<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AutoRun 
							(WhenRun, DoAction, PlanID, Memo1, Memo2, AccountID, AccntPlanID, AuthID, ScheduledBy) 
							VALUES 
							(#CreateODBCDateTime(DateRollBack)#, 'Rollback', #PlanRollbacks.ExpireTo#,
							 'Scheduled to change from #PlanRollbacks.PlanDesc# to #CheckFirst.PlanDesc#', 
							 'Scheduled to change from #PlanRollbacks.PlanDesc# to #CheckFirst.PlanDesc# on #LSDateFormat(DateRollBack, '#DateMask1#')#',
							 #NewAccountID#, #AccountPlanID#, 0, 'Online Signup')">
						</cfhttp>
					</cfif>
				</cfif>
				<cfif PayBy Is "CC">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 2">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="FieldNames">
					
					<cfset LocQuery = "INSERT INTO PayByCC 
						(AccntPlanID, AccountID, CCType, CCNumber, CCMonth, CCYear, 
						 CCCardHolder, AVSAddress, AVSZip, ">
					<cfloop query="FieldNames">
						<cfset LocQuery = LocQuery & "#FieldName#, ">
					</cfloop>
					<cfset LocQuery = LocQuery & "ActiveYN)
					VALUES
					(#AccountPlanID#, #NewAccountID#, '#AccntInfo.CCType#', '#AccntInfo.CCNum#', '#AccntInfo.CCMon#', '#AccntInfo.CCYear#', 
					 '#AccntInfo.CardHold#', '#AccntInfo.AVSAddr#', '#AccntInfo.AVSZip#', ">
					<cfloop query="FieldNames">
					 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
					 	<cfif DataType Is "Text">
							<cfset LocQuery = LocQuery & "'#DispStr#', ">
					 	<cfelseif DataType Is "Number">	
							<cfset LocQuery = LocQuery & "#DispStr#, ">
						<cfelseif DateType Is "Date">
							<cfset LocQuery = LocQuery & "#LSDateFormat(DispStr, '#DateMask1#')#, ">
						<cfelse>
							<cfset LocQuery = LocQuery & "Null, ">
						</cfif>
				 	</cfloop> 
					<cfset LocQuery = LocQuery & "1)">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">					 				 
					</cfhttp>
				
				<cfelseif PayBy Is "CD">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 1">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="FieldNames">
					
					<cfset LocQuery = "INSERT INTO PayByCD 
						(AccntPlanID, AccountID, BankName, BankAddress, RouteNumber, AccntNumber, 
						 NameOnAccnt, CheckDigit, ">
					<cfloop query="FieldNames">
						<cfset LocQuery = LocQuery & "#FieldName#, ">
					</cfloop>
					<cfset LocQuery = LocQuery & "ActiveYN) 
						VALUES
						(#AccountPlanID#, #NewAccountID#, '#AccntInfo.CheckD1#', '#AccntInfo.CheckD4#', '#AccntInfo.CheckD2#', '#AccntInfo.CheckD3#', 
						 '#AccntInfo.CardHold#', '#AccntInfo.CheckDigit#', ">
					<cfloop query="FieldNames">
					 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
					 	<cfif DataType Is "Text">
							<cfset LocQuery = LocQuery & "'#DispStr#', ">
					 	<cfelseif DataType Is "Number">
							<cfset LocQuery = LocQuery & "#DispStr#, ">
						<cfelseif DateType Is "Date">
							<cfset LocQuery = LocQuery & "#LSDateFormat(DispStr, '#DateMask1#')#, ">
						<cfelse>
							<cfset LocQuery = LocQuery & "Null, ">
						</cfif>
				 	</cfloop>
					<cfset LocQuery = LocQuery & "1)">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">
					</cfhttp>
				
				<cfelseif PayBy Is "CK">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 4 ">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="FieldNames">
					
					<cfset LocQuery = "INSERT INTO PayByCK 
						(AccntPlanID, AccountID, ">
					<cfloop query="FieldNames">
						<cfset LocQuery = LocQuery & "#FieldName#, ">
					</cfloop>
					<cfset LocQuery = LocQuery & "ActiveYN) 
						VALUES
						(#AccountPlanID#, #NewAccountID#, ">
					<cfloop query="FieldNames">
					 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
					 	<cfif DataType Is "Text">
							<cfset LocQuery = LocQuery & "'#DispStr#', ">
					 	<cfelseif DataType Is "Number">
							<cfset LocQuery = LocQuery & "#DispStr#, ">
						<cfelseif DateType Is "Date">
							<cfset LocQuery = LocQuery & "#LSDateFormat(DispStr, '#DateMask1#')#, ">
						<cfelse>
							<cfset LocQuery = LocQuery & "Null, ">
						</cfif>
					</cfloop>
					<cfset LocQuery = LocQuery & "1) ">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">
					</cfhttp>
					
				<cfelseif PayBy Is "PO">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 3 ">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="FieldNames">
					
					<cfset LocQuery = "INSERT INTO PayByPO 
						(AccntPlanID, AccountID, PONumber, ">
					<cfloop query="FieldNames">
						<cfset LocQuery = LocQuery & "#FieldName#, ">
					</cfloop>
					<cfset LocQuery = LocQuery & " ActiveYN) 
						VALUES 
						(#AccountPlanID#, #NewAccountID#, '#AccntInfo.PONumber#', ">
					<cfloop query="FieldNames">
					 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
					 	<cfif DataType Is "Text">
							<cfset LocQuery = LocQuery & "'#DispStr#', ">
					 	<cfelseif DataType Is "Number">
							<cfset LocQuery = LocQuery & "#DispStr#, ">
						<cfelseif DateType Is "Date">
							<cfset LocQuery = LocQuery & "#LSDateFormat(DispStr, '#DateMask1#')#, ">
						<cfelse>
							<cfset LocQuery = LocQuery & "Null, ">
						</cfif>
					</cfloop>
					<cfset LocQuery = LocQuery & "1) ">
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">
					</cfhttp>

				</cfif>
			</cftransaction>
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'Auth' ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetAuth">

			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT Filter1, PlanType, LoginLimit, Max_Idle1, Max_Connect1, Max_Logins, 
				AuthAddChars, AuthSufChars, FTPMatchYN, FTPNumber, EMailMatchYN, FreeEmails 
				FROM Plans 
				WHERE PlanID = #B50# ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanDetails">

			<cfloop query="GetAuth">
				<!--- Insert into Accounts Auth --->
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT CAuthID, AuthServer 
						FROM Domains 
						WHERE DomainID = #DomainID# ">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetTheCID">

					<cftransaction>
						<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
							<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AccountsAuth 
							(AccountID, DomainID, DomainName, UserName, 
							 Password, Filter1, Max_Idle, Max_Connect, Max_Logins, 
							 EMailedYN, AccntPlanID, CAuthID, AuthServer)
							VALUES 
							(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', 
							 '#Password#', '#PlanDetails.PlanType#', #PlanDetails.Max_Idle1#, #PlanDetails.Max_Connect1#, 
							 #PlanDetails.Max_Logins#, 0, #AccountPlanID#, #GetTheCID.CAuthID#, '#GetTheCID.AuthServer#') ">
							<cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(AuthID) as AuthID 
							FROM AccountsAuth">
						</cfhttp>
						<cfset TheResult = cfhttp.FileContent>
						<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewAuthID">
						<cfif (PlanDetails.FTPMatchYN Is 1) AND (PlanDetails.FTPNumber GT 0)>
							<!--- Insert AccountsFTP --->
							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT Start_Dir, Read1, Write1, Create1, Delete1, MkDir1, RMDir1, 
								NoRedir1, AnyDir1, AnyDrive1, NoDrive1, PutAny1, Super1, Max_Idle, 
								Max_Connect, FTPAddChars, FTPSufChars 
								FROM Plans 
								WHERE PlanID = #B50#  ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="FTPPlanDetails">

							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT CFTPID, FTPServer 
								FROM Domains 
								WHERE DomainID = #DomainID# ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetTheFCID">

							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AccountsFTP 
								(AccountID, DomainID, DomainName, UserName, Password, Start_Dir, 
								 Read1, Write1, Create1, Delete1, MKDir1, RMDir1, NOReDir1, AnyDir1, 
								 AnyDrive1, NoDrive1, Max_Idle1, Max_Connect1, PutAny1, Super1, 
								 AccntPlanID, CFTPID, FTPServer)
								VALUES 
								(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', 
								 '#Password#', '#FTPPlanDetails.Start_Dir#', #FTPPlanDetails.Read1#, #FTPPlanDetails.Write1#, #FTPPlanDetails.Create1#, 
								  #FTPPlanDetails.Delete1#, #FTPPlanDetails.MKDir1#, #FTPPlanDetails.RMDir1#, #FTPPlanDetails.NOReDir1#, 
								  #FTPPlanDetails.AnyDir1#, #FTPPlanDetails.AnyDrive1#, #FTPPlanDetails.NoDrive1#, #FTPPlanDetails.Max_Idle#, 
								  #FTPPlanDetails.Max_Connect#, #FTPPlanDetails.PutAny1#, #FTPPlanDetails.Super1#, #AccountPlanID#, 
								  #GetTheFCID.CFTPID#, '#GetTheFCID.FTPServer#') ">
								<cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(FTPID) as FTPID 
								FROM AccountsFTP">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewFTPID">
							
						</cfif>
						<cfif (PlanDetails.EMailMatchYN Is 1) AND (PlanDetails.FreeEMails GT 0)>
							<!--- Insert AccountsEMail --->
							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT MailBox, MailBoxLimit 
								FROM Plans 
								WHERE PlanID = #B50# ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanEMDetails">

							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT CEmailID, EMailServer 
								FROM Domains 
								WHERE DomainID = #DomainID# ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetTheEMCID">

							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT EMailID 
								FROM AccountsEMail 
								WHERE AccountID = #NewAccountID# ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckFirst">

							<cfif CheckFirst.RecordCount Is 0>
								<cfset PrEM = 1>
							<cfelse>
								<cfset PrEm = 0>
							</cfif>
							<cfset LocQuery = "INSERT INTO AccountsEMail 
								(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
								 PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
								 EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit, CEMailID)
								VALUES 
								(#NewAccountID#, #DomainID#, '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#@#Domain#', 
								 '#Password#', '#AccntInfo.FirstName#', '#AccntInfo.LastName#', 0, #PrEM#, 0, 
								 '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', '#Domain#', '#AccntInfo.FirstName# #AccntInfo.LastName#', 
								 '#GetTheEMCID.EMailServer#', #AccountPlanID#, 'POP3', #GetTheEMCID.CEMailID# ">
							<cfif PlanEMDetails.MailBox Is "">
								<cfset LocQuery = LocQuery & "Null, ">
							<cfelse>
									<cfset LocQuery = LocQuery & "'#PlanEMDetails.MailBox#', ">
							</cfif>
							<cfif PlanEMDetails.MailBoxLimit Is "">
								<cfset LocQuery = LocQuery & "Null )">
							<cfelse>
								<cfset LocQuery = LocQuery & "'#PlanEMDetails.MailBoxLimit#' )">
							</cfif>
							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="#LocQuery#">
								<cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(EMailID) as EMailID 
								FROM AccountsEMail ">
							</cfhttp>
							<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewEMailID">

							<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
								<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT ActiveYN 
										FROM CustomEMailSetup 
										WHERE CEMailID = #GetTheEMCID.CEMailID# 
										AND BOBName = 'MailCMD' ">
								<cfset TheResult = cfhttp.FileContent>
							<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckIPAD">
							<cfif CheckIPAD.ActiveYN Is "1">
								<cfif Len(NewEMailID.EMailID) GTE 2>
									<cfset TheDir = Right(NewEMailID.EMailID,2)>
								<cfelse>
									<cfset TheDir = "0" & NewEMailID.EMailID>
								</cfif>
								<cfset IPADMailBoxPath = GetPlanDefs.MailBox & TheDir & "\" & NewEMailID.EMailID>
								<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
									<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
											MailBoxPath = '#IPADMailBoxPath#' 
											WHERE EMailID = #NewEMailID.EMailID# ">
								</cfhttp>
							</cfif>
							
							
							
						</cfif>
						<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
							<cfhttpparam name="TheQuery" type="FORMFIELD" value="DELETE FROM AccntTempInfo 
							WHERE InfoID = #InfoID# ">
						</cfhttp>

					</cftransaction>
				<!--- Run scripts --->
				<cfset CreateAccount = NewAccountID>
				<cfset LocAuthID = NewAuthID.AuthID>
				<cfset LocCAuthID = GetTheCID.CAuthID>
				<cfset LocAccntPlanID = AccountPlanID>

				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
					<cfhttpparam type="FORMFIELD" name="MCIntType" value="1">
					<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
					<cfhttpparam type="FORMFIELD" name="MCAuthID" value="#LocAuthID#">
					<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#CreateAccount#">
					<cfhttpparam type="FORMFIELD" name="LocAccntPlanID" value="#LocAccntPlanID#">
					<cfhttpparam type="FORMFIELD" name="LocCAuthID" value="#LocCAuthID#">
					<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="signup8.cfm">
				</cfhttp>		

				<!--- FTP Match Setup --->
				<cfif (PlanDetails.FTPMatchYN Is 1) AND (PlanDetails.FTPNumber GT 0)>

					<cfset LocFTPID = NewFTPID.FTPID>
					<cfset LocCFTPID = GetTheFCID.CFTPID>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfset CreateAccount = NewAccountID>
					
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
						<cfhttpparam type="FORMFIELD" name="MCIntType" value="3">
						<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
						<cfhttpparam type="FORMFIELD" name="MCFTPID" value="#LocFTPID#">
						<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#CreateAccount#">
						<cfhttpparam type="FORMFIELD" name="LocAccntPlanID" value="#LocAccntPlanID#">
						<cfhttpparam type="FORMFIELD" name="LocCFTPID" value="#LocCFTPID#">
						<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="signup8.cfm">
					</cfhttp>		

				</cfif>
				<!--- EMail Match Setup --->		
				<cfif (PlanDetails.EMailMatchYN Is 1) AND (PlanDetails.FreeEMails GT 0)>
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
						UniqueIdentifier = EMailID 
						WHERE EMailID = #NewEMailID.EMailID# ">
					</cfhttp>
					<cfset LocEMailID = NewEMailID.EMailID>
					<cfset LocCEMailID = GetTheEMCID.CEMailID>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfset CreateAccount = NewAccountID>	
					
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
						<cfhttpparam type="FORMFIELD" name="MCIntType" value="4">
						<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
						<cfhttpparam type="FORMFIELD" name="MCEMailID" value="#LocEMailID#">
						<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#CreateAccount#">
						<cfhttpparam type="FORMFIELD" name="LocAccntPlanID" value="#LocAccntPlanID#">
						<cfhttpparam type="FORMFIELD" name="LocCEMailID" value="#LocCEMailID#">
						<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="signup8.cfm">
					</cfhttp>		
				</cfif>
			</cfloop>			
			<!--- FTP setup --->
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'FTP' ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetFTP">
			
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT Start_Dir, Read1, Write1, Create1, Delete1, MkDir1, RMDir1, 
				NoRedir1, AnyDir1, AnyDrive1, NoDrive1, PutAny1, Super1, Max_Idle, 
				Max_Connect, FTPAddChars, FTPSufChars 
				FROM Plans 
				WHERE PlanID = #B50# ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanDetails">
	
			<cfloop query="GetFTP">
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT CFTPID, FTPServer 
					FROM Domains 
					WHERE DomainID = #DomainID# ">
				</cfhttp>
				<cfset TheResult = cfhttp.FileContent>
				<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetTheCID">
	
				<cftransaction> 
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="TheQuery" value="INSERT INTO AccountsFTP 
						(AccountID, DomainID, DomainName, UserName, Password, Start_Dir, 
						 Read1, Write1, Create1, Delete1, MKDir1, RMDir1, NOReDir1, AnyDir1, 
						 AnyDrive1, NoDrive1, Max_Idle1, Max_Connect1, PutAny1, Super1, 
						 AccntPlanID, CFTPID, FTPServer)
						VALUES 
						(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.FTPAddChars)##Login##Trim(PlanDetails.FTPSufChars)#', 
						 '#Password#', '#PlanDetails.Start_Dir#', #PlanDetails.Read1#, #PlanDetails.Write1#, #PlanDetails.Create1#, 
						  #PlanDetails.Delete1#, #PlanDetails.MKDir1#, #PlanDetails.RMDir1#, #PlanDetails.NOReDir1#, 
						  #PlanDetails.AnyDir1#, #PlanDetails.AnyDrive1#, #PlanDetails.NoDrive1#, #PlanDetails.Max_Idle#, 
						  #PlanDetails.Max_Connect#, #PlanDetails.PutAny1#, #PlanDetails.Super1#, #AccountPlanID#, 
						  #GetTheCID.CFTPID#, '#GetTheCID.FTPServer#') ">
						<cfhttpparam type="FORMFIELD" name="TheQuery2" value="SELECT Max(FTPID) as FTPID 
						FROM AccountsFTP">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewFTPID">

					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="TheQuery" value="DELETE FROM AccntTempInfo 
						WHERE InfoID = #InfoID#">
					</cfhttp>
				</cftransaction>				

					<cfset LocFTPID = NewFTPID.FTPID>
					<cfset LocCFTPID = GetTheCID.CFTPID>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfset CreateAccount = NewAccountID>
					
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
						<cfhttpparam type="FORMFIELD" name="MCIntType" value="3">
						<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
						<cfhttpparam type="FORMFIELD" name="MCFTPID" value="#LocFTPID#">
						<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#CreateAccount#">
						<cfhttpparam type="FORMFIELD" name="LocAccntPlanID" value="#LocAccntPlanID#">
						<cfhttpparam type="FORMFIELD" name="LocCFTPID" value="#LocCFTPID#">
						<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="signup8.cfm">
					</cfhttp>		
			</cfloop>
			<!--- EMail setup --->
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'EMail'">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetEMail">

			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT MailBox, MailBoxLimit 
				FROM Plans 
				WHERE PlanID = #B50#">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanDetails">

			<cfloop query="GetEMail">

				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT CEmailID, EMailServer 
					FROM Domains 
					WHERE DomainID = #DomainID#">
				</cfhttp>
				<cfset TheResult = cfhttp.FileContent>
				<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetTheCID">

				<cfif EMailNum Is 1>
					<cfset PrEM = 1>
				<cfelse>
					<cfset PrEM = 0>
				</cfif>
				<cftransaction>
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="TheQuery" value="INSERT INTO AccountsEMail 
						(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
						 PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
						 EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit, CEMailID) 
						VALUES 
						(#NewAccountID#, #DomainID#, '#Login#', '#EMailAddr#', '#Password#', 
						 '#AccntInfo.FirstName#', '#AccntInfo.LastName#', 0, #PrEM#, 0, 
						 '#UserName#', '#Domain#', '#AccntInfo.FirstName# #AccntInfo.LastName#', 
						 '#GetTheCID.EMailServer#', #AccountPlanID#, 'POP3', 
						 '#PlanDetails.MailBox#', '#PlanDetails.MailBoxLimit#', #GetTheCID.CEMailID#)">
						<cfhttpparam type="FORMFIELD" name="TheQuery2" value="SELECT Max(EMailID) as EMailID 
						FROM AccountsEMail">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewEMailID">

					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT ActiveYN 
								FROM CustomEMailSetup 
								WHERE CEMailID = #GetTheEMCID.CEMailID# 
								AND BOBName = 'MailCMD' ">
						<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckIPAD">
					<cfif CheckIPAD.ActiveYN Is "1">
						<cfif Len(NewEMailID.EMailID) GTE 2>
							<cfset TheDir = Right(NewEMailID.EMailID,2)>
						<cfelse>
							<cfset TheDir = "0" & NewEMailID.EMailID>
						</cfif>
						<cfset IPADMailBoxPath = GetPlanDefs.MailBox & TheDir & "\" & NewEMailID.EMailID>
						<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
							<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
									MailBoxPath = '#IPADMailBoxPath#' 
									WHERE EMailID = #NewEMailID.EMailID# ">
						</cfhttp>
					</cfif>
					
					<cfset EMailNum = 2>
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam type="FORMFIELD" name="TheQuery" value="DELETE FROM AccntTempInfo 
						WHERE InfoID = #InfoID#">
					</cfhttp>
				</cftransaction>
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="TheQuery" value="UPDATE AccountsEMail SET 
					UniqueIdentifier = EMailID 
					WHERE EMailID = #NewEMailID.EMailID#">
				</cfhttp>

				<cfset LocEMailID = NewEMailID.EMailID>
				<cfset LocCEMailID = GetTheCID.CEMailID>
				<cfset LocAccntPlanID = AccountPlanID>
				<cfset CreateAccount = NewAccountID>
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
					<cfhttpparam type="FORMFIELD" name="MCIntType" value="4">
					<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
					<cfhttpparam type="FORMFIELD" name="MCEMailID" value="#LocEMailID#">
					<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#CreateAccount#">
					<cfhttpparam type="FORMFIELD" name="LocAccntPlanID" value="#LocAccntPlanID#">
					<cfhttpparam type="FORMFIELD" name="LocCEMailID" value="#LocCEMailID#">
					<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="signup8.cfm">
				</cfhttp>		
			</cfloop>	
		</cfif>
	</cfloop>	
	<!--- Welcome Letter --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT I.IntID, P.PlanID, I.EMailServer, I.EMailServerPort, I.EMailFrom, I.EMailTo, I.EMailCC, 
		I.EMailFile, I.EmlAttachWait, I.EMailDelay, I.EMailSubject, I.EMailMessage, I.EMailRepeatMsg 
		FROM Integration I, Plans P 
		WHERE I.IntID = P.EMailLetterID 
		AND I.ActiveYN = 1 
		AND P.PlanID IN 
			(#AccntInfo.SelectPlan#)">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetLetters">

	<cfif GetLetters.RecordCount GT 0>
		<cfset CreateAccount = NewAccountID>
		<cfloop query="GetLetters">
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="ResultType" value="Letter">
				<cfhttpparam type="FORMFIELD" name="SelectedLetter" value="#IntID#">
				<cfhttpparam type="FORMFIELD" name="AccountID" value="#CreateAccount#">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfset LocMessag = TheResult>
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT AccountID, FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = #NewAccountID#">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetWhoIs">

			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT EMail 
				FROM AccountsEMail 
				WHERE AccountID = #NewAccountID# 
				AND PrEMail = 1 ">
			</cfhttp>
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="MainEMail">
			<cfif MainEMail.EMail Is "">
				<cfset EMailTo = "">
			<cfelse>
				<cfset EMailTo = MainEMail.EMail>
			</cfif>
			
			<cfif Not IsDefined("NoBOBHist")>
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="TheQuery" value="INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					('#Trim(LocMessag)#',#NewAccountID#,0, #Now()#,'E-Mailed','Online Signup e-mailed #GetWhoIs.FirstName# #GetWhoIs.LastName# at #EMailTo#.')">
				</cfhttp>
			</cfif>
		</cfloop>
	</cfif>	
	<!--- Insert to TransActions --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT * 
			FROM AccntTempFin 
			WHERE AccountID = #OldAccountID# 
			AND PlanID In (#AccntInfo.SelectPlan#)">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="FinTrans">

	<cfloop query="FinTrans">
		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT DomainID 
				FROM Domains 
				WHERE DomainName = 
					(SELECT DefMailServer 
					 FROM Plans 
					 WHERE PlanID = #PlanID# )">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="EMailInfo">

		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT DomainID 
			FROM Domains 
			WHERE DomainName = 
				(SELECT DefFTPServer 
				 FROM Plans 
				 WHERE PlanID = #PlanID# )">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="FTPInfo">

		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT DomainID 
			FROM Domains 
			WHERE DomainName = 
				(SELECT DefAuthServer 
				 FROM Plans 
				 WHERE PlanID = #PlanID# )">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="AuthInfo">

		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT PayDueDays, DeactDays
			FROM Plans 
			WHERE PlanID = #PlanID#">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanDetails">

		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT AccntPlanID 
			FROM AccntPlans 
			WHERE AccountID = #NewAccountID# 
			AND PlanID = #PlanID#">
		</cfhttp>
		<cfset TheResult = cfhttp.FileContent>
		<cfwddx action="WDDX2CFML" input="#TheResult#" output="AcntID">

		<cfset LocQuery = "INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
				 MemoField,AdjustmentYN,EnteredBy,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
				 SubAccountID,SetUpFeeYN,
				 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
				 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
				 PlanPayBy,SalesPersonID,AccntPlanID,DiscountYN,
				 FirstName,LastName)
				VALUES 
				(#NewAccountID#, #Now()#,">
		<cfif TransactionType Is "RA">
			 <cfset LocQuery = LocQuery & "0, #TransAmount#, 0, 0, 0, #TransAmount#, ">
			 <cfset TType = "Debit">
		<cfelseif TransactionType Is "FA">
			 <cfset LocQuery = LocQuery & "0, #TransAmount#, 0, 0, 0, #TransAmount#, ">
			 <cfset TType = "Debit">
		<cfelseif TransactionType Is "RD">
			 <cfset LocQuery = LocQuery & "#TransAmount#, 0, 0, 0, #TransAmount#, 0, ">
			 <cfset TType = "Credit">
		<cfelseif TransactionType Is "FD">
			<cfset LocQuery = LocQuery & "#TransAmount#, 0, 0, 0, #TransAmount#, 0, ">
			<cfset TType = "Credit">
		<cfelseif TransactionType Is "TX">
			<cfset LocQuery = LocQuery & "0, #TransAmount#, 1, #TaxLevel#, 0, #TransAmount#, ">
			<cfset TType = "Debit">
		<cfelseif TransactionType Is "PO">
			<cfset LocQuery = LocQuery & "0, #TransAmount#, 0, 0, 0, #TransAmount#, ">
			<cfset TType = "Debit">
		</cfif>
		<cfset LocQuery = LocQuery & "'#TransMemo#', 0, 'Online Signup', ">
		<cfif EMailInfo.DomainID Is "">
			<cfset LocQuery = LocQuery & "Null, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#EMailInfo.DomainID#, ">
		</cfif> 
		<cfif FTPInfo.DomainID Is "">
			<cfset LocQuery = LocQuery & "Null, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#FTPInfo.DomainID#, ">
		</cfif> 
		<cfif AuthInfo.DomainID Is "">
			<cfset LocQuery = LocQuery & "Null">
		<cfelse>
			<cfset LocQuery = LocQuery & "#AuthInfo.DomainID#">
		</cfif>
		<cfset LocQuery = LocQuery & ", #AccntInfo.POPID#, #PlanID#, 0, #AccountID#, ">
		<cfif (TransactionType Is "FA") OR (TransactionType Is "FD")>
			<cfset LocQuery = LocQuery & "1, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "0, ">
		</cfif>
		<cfset LocQuery = LocQuery & "#Now()#, ">
		<cfif PlanDetails.DeactDays Is 0>
			<cfset LocQuery = LocQuery & "Null, 0, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#DateAdd("d",PlanDetails.DeactDays,Now())#, 0, ">
		</cfif> 
		<cfif PlanDetails.PayDueDays Is 0>
			<cfset LocQuery = LocQuery & "Null, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#DateAdd("d",PlanDetails.PayDueDays,Now())#, ">
		</cfif>
		<cfset LocQuery = LocQuery & "0, 0, 0, ">
		<cfif StartDate Is "">
			<cfset LocQuery = LocQuery & "Null, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#CreateODBCDateTime(StartDate)#, ">
		</cfif>
		<cfif EndDate Is "">
			<cfset LocQuery = LocQuery & "Null, ">
		<cfelse>
			<cfset LocQuery = LocQuery & "#CreateODBCDateTime(EndDate)#, ">
		</cfif>
		<cfset LocQuery = LocQuery & "'#PayByCur#', 0, #AcntID.AccntPlanID#, 0, 
			'#AccntInfo.FirstName#', '#AccntInfo.LastName#' )">
		<cftransaction>
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="#LocQuery#">
			</cfhttp>	
				
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="DELETE FROM AccntTempFin 
				WHERE FinancialID = #FinancialID#">
			</cfhttp>
		</cftransaction>
	</cfloop>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="ResultType" value="MakePayment">
		<cfhttpparam type="FORMFIELD" name="AccountID" value="#NewAccountID#">
		<cfhttpparam type="FORMFIELD" name="TheTransType" value="Debit">
	</cfhttp>

	<!--- If Payment exists Insert to TransActions --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT * 
		FROM AccntTransTemp 
		WHERE TempAccountID = #AccountID# ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="PaymentInfo">	
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT 
		FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
		FROM AccntPlans
		WHERE AccntPlanID IN (#LocAccntPlanID#) ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetIds">	
	
	
	<cfloop query="PaymentInfo">
		<cfif Left(CCNumber,1) Is "3">
			<cfset CCType = "Am Express">
		<cfelseif Left(CCNumber,1) Is "4">
			<cfset CCType = "Visa">
		<cfelseif Left(CCNumber,1) Is "5">
			<cfset CCType = "Mastercard">
		<cfelseif Left(CCNumber,1) Is "6">
			<cfset CCType = "Discover">
		</cfif>
		
		<cfset LocQuery = "INSERT INTO Transactions 
			(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
			 MemoField,AdjustmentYN,EnteredBy,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
			 SubAccountID,SetUpFeeYN,
			 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
			 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
			 PlanPayBy,SalesPersonID,AccntPlanID,DiscountYN,
			 FirstName,LastName, CCAuthCode, PayType, CCProcessDate, CCPayType)
			VALUES 
			(#NewAccountID#, #Now()#, #CreditAmount#, 0, 0, 0, #CreditAmount#, 0, 
			 '#CCType# Authorization: #CCAuthCode#', 0, 'Online Signup', ">
			 <cfif GetIds.EMailDomainID Is "">
			 	<cfset LocQuery = LocQuery & "Null, ">
			 <cfelse>
			 	<cfset LocQuery = LocQuery & "#GetIds.EMailDomainID#, ">
			 </cfif>
			 <cfif GetIds.FTPDomainID Is "">
			 	<cfset LocQuery = LocQuery & "Null, ">
			 <cfelse>
			 	<cfset LocQuery = LocQuery & "#GetIds.FTPDomainID#, ">
			 </cfif>
			 <cfif GetIds.AuthDomainID Is "">
			 	<cfset LocQuery = LocQuery & "Null, ">
			 <cfelse>
			 	<cfset LocQuery = LocQuery & "#GetIds.AuthDomainID#, ">
			 </cfif>
			 <cfif GetIds.POPID Is "">
			 	<cfset LocQuery = LocQuery & "Null, ">
			 <cfelse>
			 	<cfset LocQuery = LocQuery & "#GetIds.POPID#, ">
			 </cfif> 
			 <cfif GetIds.PlanID Is "">
			 	<cfset LocQuery = LocQuery & "Null">
			 <cfelse>
			 	<cfset LocQuery = LocQuery & "#GetIds.PlanID#">
			 </cfif>
			 <cfset LocQuery = LocQuery & ", 0, 
			 #NewAccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
			 'CC', 0, #GetIds.AccntPlanID#, 0, 
			 '#AccntInfo.FirstName#', '#AccntInfo.LastName#', '#CCAuthCode#', 'Credit Card',
			 #CCProcessDate#, '#CCType#') ">
		<cftransaction>
			<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
				<cfhttpparam type="FORMFIELD" name="TheQuery" value="#LocQuery#">
				<cfhttpparam type="FORMFIELD" name="TheQuery2" value="SELECT Max(TransID) as MaxID 
				FROM TransActions">
			</cfhttp>	
			<cfset TheResult = cfhttp.FileContent>
			<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewID">				 
			
			<cfif NewID.MaxID Is Not "">
				<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
					<cfhttpparam type="FORMFIELD" name="TheQuery" value="DELETE FROM 
						AccntTransTemp WHERE TempTransID = #TempTransID# ">
				</cfhttp>
			</cfif>
		</cftransaction>
	</cfloop>

	<cfif PaymentInfo.RecordCount GT 0>
		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam type="FORMFIELD" name="ResultType" value="MakePayment">
			<cfhttpparam type="FORMFIELD" name="AccountID" value="#NewAccountID#">
			<cfhttpparam type="FORMFIELD" name="TheTransType" value="Debit">
		</cfhttp>
	</cfif>

	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="DELETE FROM 
			AccntTemp WHERE AccountID = #AccountID# ">
	</cfhttp>
</cfif>

<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
	<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'buildscript.cfm' 
		AND L.LocationAction = 'Create' 
		AND I.IntID In 
			(SELECT IntID 
			 FROM IntPlans 
			 WHERE PlanID In (#AccntInfo.SelectPlan#) 
			)
		AND I.TypeID = 6 ">
</cfhttp>	
<cfset TheResult = cfhttp.FileContent>
<cfwddx action="WDDX2CFML" input="#TheResult#" output="Check4Script">				 

<cfif HTTP_USER_AGENT contains "MSIE">
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="TheQuery" value="SELECT * 
			FROM pops 
			WHERE popid = #AccntInfo.POPID#">
	</cfhttp>	
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="GetMyPOP">				 
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Signup Online</title>
</head>
<cfoutput>
<body #PageColors#>
</cfoutput>
<center>
	<cfoutput>
		<table border="#TblBorder#">
			<tr>
				<th bgcolor="#TblTitleColor#"><font color="#TblTitleText#" size="#TblTitleSize#">Signup Online</font></th>
			</tr>
			<cfif CreateAcnts GT "0">
				<tr>
					<td bgcolor="#tbclr#">Your accounts have been created</td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Visit our Customer Support Online area.<br>
					<a href="login.cfm">Login</a></td>
				</tr>
			<cfelse>
				<tr>
					<td bgcolor="#tbclr#">Your accounts have been submitted and will be activated within 3 business days.</td>
				</tr>
			</cfif>
			<cfif (Check4Script.RecordCount GT "0") AND (HTTP_USER_AGENT contains "MSIE") AND (ShowIEAK Is 1)>
				<cfset CreateAccount = NewAccountID>
				<cfset ExtPathway = ExpandPath("buildscript.cfm")>
				<cfif FileExists("#ExtPathway#")>
					<cfset IEAKAccountID = CreateAccount>
					<cfset IEAKAccntPlanID = LocAccntPlanID>
					<cfinclude template="buildscript.cfm">
				</cfif>
			</cfif>
		</table>
	</cfoutput>
</center>
</body>
</html>
 