<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the account wizard. --->
<!---	4.0.2 01/31/01 Added the feature to connect the new account to a group if added from the group list.
		4.0.1 01/26/01 Fixed an error that was not copying the custom fields from AccntTemp to Accounts.
		4.0.0 08/14/99 --->
<!--- account4.cfm --->

<cfset securepage="account.cfm">
<cfinclude template="security.cfm">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfif IsDefined("makeaccnt.x")>
	<cfquery name="AccntInfo" datasource="#pds#">
		SELECT * 
		FROM AccntTemp 
		WHERE AccountID = #OldAccountID# 
	</cfquery>
	<cfquery name="PersInfo" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #NewAccountID# 
	</cfquery>
	<cfset Looper = 0>
	<cfset EMailNum = 1>
	<cfloop index="B50" list="#AccntInfo.SelectPlan#">
		<cfset Looper = Looper + 1>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM AccntPlans 
			WHERE AccountID = #NewAccountID# 
			AND PlanID = #B50#
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="NextDue" datasource="#pds#">
				SELECT Max(EndDate) as DueDate 
				FROM AccntTempFin 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
			</cfquery>
			<cfquery name="EMailID" datasource="#pds#">
				SELECT DomainID, EMailServer
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'EMail')		
			</cfquery>
			<cfquery name="FTPID" datasource="#pds#">
				SELECT DomainID, FTPServer
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'FTP')		
			</cfquery>
			<cfquery name="AuthDomID" datasource="#pds#">
				SELECT DomainID, AuthServer 
				FROM Domains 
				WHERE DomainName = 
					(SELECT Top 1 Domain 
					 FROM AccntTempInfo 
					 WHERE AccountID = #OldAccountID# 
					 AND PlanID = #B50# 
					 AND Type = 'Auth')
			</cfquery>
			<cfquery name="DefDomain" datasource="#pds#">
				SELECT DomainID 
				FROM Domains 
				WHERE Primary1 = 1 
			</cfquery>
			<cfset DefDomainID = DefDomain.DomainID>
			<cfset PayBy = Evaluate("PayBy#B50#")>
			<cftransaction>
				<cfquery name="InsPlan" datasource="#pds#">
					INSERT INTO AccntPlans
					(AccountID, PlanID, NextDueDate, POPID, EMailDomainID, EMailServer, 
					 FTPDomainID, FTPServer, AuthDomainID, AuthServer, StartDate, 
					 LastDebitDate, AccntStatus, PayBy, PostalRem, Taxable, BillingStatus)
					VALUES
					(#NewAccountID#, #B50#, 
					 <cfif NextDue.DueDate Is "">#Now()#<cfelse>#CreateODBCDateTime(NextDue.DueDate)#</cfif>, #AccntInfo.POPID#, 
					 <cfif EMailID.DomainID Is "">#DefDomainID#<cfelse>#EMailID.DomainID#</cfif>, 
					 <cfif EMailID.EMailServer Is "">Null<cfelse>'#EMailID.EMailServer#'</cfif>, 
					 <cfif FTPID.DomainID Is "">#DefDomainID#<cfelse>#FTPID.DomainID#</cfif>, 
					 <cfif FTPID.FTPServer Is "">Null<cfelse>'#FTPID.FTPServer#'</cfif>, 
					 <cfif AuthDomID.DomainID Is "">#DefDomainID#<cfelse>#AuthDomID.DomainID#</cfif>, 
					 <cfif AuthDomID.AuthServer Is "">Null<cfelse>'#AuthDomID.AuthServer#'</cfif>, 
					 #Now()#, #Now()#, 0, '#PayBy#', <cfif AccntInfo.PostalInv Is "">Null<cfelse>#AccntInfo.PostalInv#</cfif>, 
					 #AccntInfo.TaxFree#, 1)
				</cfquery>
				<cfquery name="TheID" datasource="#pds#">
					SELECT Max(AccntPlanID) as NewID 
					FROM AccntPlans 
				</cfquery>
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="PlanName" datasource="#pds#">
						SELECT PlanDesc 
						FROM Plans 
						WHERE PlanID = #B50# 
					</cfquery>
					<cfset HistMessage = "#StaffMemberName.FirstName# #StaffMemberName.LastName# setup the plan: #PlanName.PlanDesc# for #PersInfo.FirstName# #PersInfo.LastName#.">
					<cfif PayBy Is "cc">
						<cfset HistMessage = HistMessage & "  Payment method: Credit Card.">
					<cfelseif PayBy Is "cd">
						<cfset HistMessage = HistMessage & "  Payment method: Check Debit.">
					<cfelseif PayBy Is "ck">
						<cfset HistMessage = HistMessage & "  Payment method: Check.">
					<cfelseif PayBy Is "po">
						<cfset HistMessage = HistMessage & "  Payment method: Purchase Order.">
					</cfif>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
						'#HistMessage#')
					</cfquery>
				</cfif>
				<cfset "AccntPlanID#Looper#" = TheID.NewID>
				<cfset AccountPlanID = TheID.NewID>
				<cfif (EMailID.DomainID Is "") AND (FTPID.DomainID Is "") AND (AuthDomID.DomainID Is "")>
					<cfquery name="UpdDomain" datasource="#pds#">
						UPDATE AccntPlans SET 
						AuthDomainID = 
							(SELECT DomainID 
							 FROM Domains 
							 WHERE Primary1 = 1) 
						WHERE AccntPlanID = #AccountPlanID# 
					</cfquery>
				</cfif>
				<cfif AccntInfo.ContactEMail Is Not "">
					<cfset Cond1 = FindNoCase("@",AccntInfo.ContactEMail)>
					<cfif Cond1 GT 0>
						<cfset Pos1 = Cond1>
					<cfelse>
						<cfset Pos1 = 1>
					</cfif>
					<cfset Cond2 = FindNoCase(".",AccntInfo.ContactEMail,Pos1)>
					<cfif (Cond1 GT 0) AND (Cond2 GT 0)>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT EmailID 
							FROM AccountsEMail 
							WHERE AccountID = #NewAccountID# 
							AND EMail = '#AccntInfo.ContactEMail#' 
						</cfquery>
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
							<cfquery name="InsContact" datasource="#pds#">
								INSERT INTO AccountsEMail 
								(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
								PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
								EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit,CEMailID)
								VALUES 
								(#NewAccountID#, 0, 
								 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
								 '#AccntInfo.ContactEMail#', Null, 
								 '#PersInfo.FirstName#', '#PersInfo.LastName#', 0, 1, 1, 
								 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
								 <cfif Trim(EMSecond) Is "">Null<cfelse>'#EMSecond#'</cfif>, 
								 '#PersInfo.FirstName# #PersInfo.LastName#', Null, #AccountPlanID#, Null, Null, Null,Null) 
							</cfquery>
							<cfif Not IsDefined("NoBOBHist")>
								<cfquery name="BOBHist" datasource="#pds#">
									INSERT INTO BOBHist
									(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
									VALUES 
									(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
									'#StaffMemberName.FirstName# #StaffMemberName.LastName# setup the contact email address: #AccntInfo.ContactEMail# for #PersInfo.FirstName# #PersInfo.LastName#.')
								</cfquery>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
				<cfquery name="PlanRollbacks" datasource="#pds#">
					SELECT ExpireTo, ExpireDays, PlanDesc 
					FROM Plans 
					WHERE PlanID = #B50#
				</cfquery>
				<cfif PlanRollbacks.ExpireDays GT 0>
					<!--- Set The Rollback --->
					<cfset DateToRollBack = DateAdd("d",PlanRollbacks.ExpireDays,Now())>
					<cfset DateRollBack = CreateDateTime(Year(DateToRollBack),Month(DateToRollBack),Day(DateToRollBack),0,0,0)>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT PlanID, PlanDesc 
						FROM Plans 
						WHERE PlanID = #PlanRollbacks.ExpireTo# 
					</cfquery>
					<cfif CheckFirst.Recordcount GT 0>
						<cfquery name="RollBackSched" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, PlanID, Memo1, Memo2, AccountID, AccntPlanID, AuthID, ScheduledBy) 
							VALUES 
							(#CreateODBCDateTime(DateRollBack)#, 'Rollback', #PlanRollbacks.ExpireTo#,
							 'Scheduled to change from #PlanRollbacks.PlanDesc# to #CheckFirst.PlanDesc#', 
							 'Scheduled to change from #PlanRollbacks.PlanDesc# to #CheckFirst.PlanDesc# on #LSDateFormat(DateRollBack, '#DateMask1#')#',
							 #NewAccountID#, #AccountPlanID#, 0, '#StaffMemberName.FirstName# #StaffMemberName.Lastname#') 
						</cfquery>
					</cfif>
				</cfif>
				<cfif PayBy Is "CC">
					<cfquery name="FieldNames" datasource="#pds#">
						SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 2 
					</cfquery>
					<cfquery name="PayType" datasource="#pds#">
						INSERT INTO PayByCC 
						(AccntPlanID, AccountID, CCType, CCNumber, CCMonth, CCYear, 
						 CCCardHolder, AVSAddress, AVSZip, 
						 <cfloop query="FieldNames">#FieldName#,</cfloop>
						 ActiveYN)
						VALUES
						(#AccountPlanID#, #NewAccountID#, '#AccntInfo.CCType#', '#AccntInfo.CCNum#', '#AccntInfo.CCMon#', '#AccntInfo.CCYear#', 
						 '#AccntInfo.CardHold#', '#AccntInfo.AVSAddr#', '#AccntInfo.AVSZip#', 
						 <cfloop query="FieldNames">
						 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
						 	<cfif DataType Is "Text">'#DispStr#'
						 	<cfelseif DataType Is "Number">#DispStr#
							<cfelseif DateType Is "Date">#LSDateFormat(DispStr, '#DateMask1#')#
							<cfelse>Null
							</cfif>,
						 </cfloop>
						 1)
					</cfquery>
				<cfelseif PayBy Is "CD">
					<cfquery name="FieldNames" datasource="#pds#">
						SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 1 
					</cfquery>
					<cfquery name="PayType" datasource="#pds#">
						INSERT INTO PayByCD 
						(AccntPlanID, AccountID, BankName, BankAddress, RouteNumber, AccntNumber, 
						 NameOnAccnt, CheckDigit, 
						 <cfloop query="FieldNames">#FieldName#,</cfloop>
						 ActiveYN) 
						VALUES
						(#AccountPlanID#, #NewAccountID#, '#AccntInfo.CheckD1#', '#AccntInfo.CheckD4#', '#AccntInfo.CheckD2#', '#AccntInfo.CheckD3#', 
						 '#AccntInfo.CardHold#', '#AccntInfo.CheckDigit#', 
						 <cfloop query="FieldNames">
						 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
						 	<cfif DataType Is "Text">'#DispStr#'
						 	<cfelseif DataType Is "Number">#DispStr#
							<cfelseif DateType Is "Date">#LSDateFormat(DispStr, '#DateMask1#')#
							<cfelse>Null
							</cfif>,
						 </cfloop>
						 1)
					</cfquery>
				<cfelseif PayBy Is "CK">
					<cfquery name="FieldNames" datasource="#pds#">
						SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 4 
					</cfquery>
					<cfquery name="PayType" datasource="#pds#">
						INSERT INTO PayByCK 
						(AccntPlanID, AccountID, 
						<cfloop query="FieldNames">#FieldName#,</cfloop>
						ActiveYN)
						VALUES
						(#AccountPlanID#, #NewAccountID#, 
						 <cfloop query="FieldNames">
						 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
						 	<cfif DataType Is "Text">'#DispStr#'
						 	<cfelseif DataType Is "Number">#DispStr#
							<cfelseif DateType Is "Date">#LSDateFormat(DispStr, '#DateMask1#')#
							<cfelse>Null
							</cfif>,
						 </cfloop>
						 1)
					</cfquery>
				<cfelseif PayBy Is "PO">
					<cfquery name="FieldNames" datasource="#pds#">
						SELECT * 
						FROM PayTypes 
						WHERE ActiveYN = 1 
						AND CFVarYN = 0 
						AND UseTab = 3 
					</cfquery>
					<cfquery name="PayType" datasource="#pds#">
						INSERT INTO PayByPO 
						(AccntPlanID, AccountID, PONumber, 
						 <cfloop query="FieldNames">#FieldName#,</cfloop>
						 ActiveYN) 
						VALUES 
						(#AccountPlanID#, #NewAccountID#, '#AccntInfo.PONumber#', 
						 <cfloop query="FieldNames">
						 	<cfset DispStr = Evaluate("AccntInfo.#FieldName#")>
						 	<cfif DataType Is "Text">'#DispStr#'
						 	<cfelseif DataType Is "Number">#DispStr#
							<cfelseif DateType Is "Date">#LSDateFormat(DispStr, '#DateMask1#')#
							<cfelse>Null
							</cfif>,
						 </cfloop>
						 1)
					</cfquery>
				</cfif>
			</cftransaction>
			<cfquery name="GetAuth" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'Auth' 
			</cfquery>
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT Filter1, PlanType, LoginLimit, Max_Idle1, Max_Connect1, Max_Logins, 
				AuthAddChars, AuthSufChars, FTPMatchYN, FTPNumber, EMailMatchYN, FreeEmails 
				FROM Plans 
				WHERE PlanID = #B50# 
			</cfquery>
			<cfloop query="GetAuth">
				<!--- Insert AccountsAuth --->
					<cfquery name="GetTheCID" datasource="#pds#">
						SELECT CAuthID, AuthServer 
						FROM Domains 
						WHERE DomainID = #DomainID#
					</cfquery>
					<cftransaction>
						<cfquery name="AuuAccount" datasource="#pds#">
							INSERT INTO AccountsAuth 
							(AccountID, DomainID, DomainName, UserName, 
							 Password, Filter1, Max_Idle, Max_Connect, Max_Logins, 
							 EMailedYN, AccntPlanID, CAuthID, AuthServer)
							VALUES 
							(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', 
							 '#Password#', '#PlanDetails.PlanType#', #PlanDetails.Max_Idle1#, #PlanDetails.Max_Connect1#, 
							 #PlanDetails.Max_Logins#, 0, #AccountPlanID#, #GetTheCID.CAuthID#, '#GetTheCID.AuthServer#')
						</cfquery>
						<cfquery name="NewAuthID" datasource="#pds#">
							SELECT Max(AuthID) as AuthID 
							FROM AccountsAuth
						</cfquery>
						<!--- BOB History --->
						<cfif Not IsDefined("NoBOBHist")>
							<cfquery name="BOBHist" datasource="#pds#">
								INSERT INTO BOBHist
								(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
								VALUES 
								(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
								'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the auth account: #Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)# for #PersInfo.FirstName# #PersInfo.LastName#.')
							</cfquery>
						</cfif>						
						<cfif (PlanDetails.FTPMatchYN Is 1) AND (PlanDetails.FTPNumber GT 0) AND (Type Is "Auth")>
							<!--- Insert AccountsFTP --->
							<cfquery name="FTPPlanDetails" datasource="#pds#">
								SELECT Start_Dir, Read1, Write1, Create1, Delete1, MkDir1, RMDir1, 
								NoRedir1, AnyDir1, AnyDrive1, NoDrive1, PutAny1, Super1, Max_Idle, 
								Max_Connect, FTPAddChars, FTPSufChars, FTPExecFile, FTPListDirs, FTPInheritD 
								FROM Plans 
								WHERE PlanID = #B50# 
							</cfquery>
							<cfquery name="GetTheFCID" datasource="#pds#">
								SELECT CFTPID, FTPServer 
								FROM Domains 
								WHERE DomainID = #DomainID#
							</cfquery>
							<cfquery name="AddFTP" datasource="#pds#">
								INSERT INTO AccountsFTP 
								(AccountID, DomainID, DomainName, UserName, Password, Start_Dir, 
								 Read1, Write1, Create1, Delete1, MKDir1, RMDir1, NOReDir1, AnyDir1, 
								 AnyDrive1, NoDrive1, Max_Idle1, Max_Connect1, PutAny1, Super1, 
								 AccntPlanID, CFTPID, FTPExecFile, FTPListDirs, FTPInheritD, FTPServer)
								VALUES 
								(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', 
								 '#Password#', '#FTPPlanDetails.Start_Dir#', #FTPPlanDetails.Read1#, #FTPPlanDetails.Write1#, #FTPPlanDetails.Create1#, 
								  #FTPPlanDetails.Delete1#, #FTPPlanDetails.MKDir1#, #FTPPlanDetails.RMDir1#, #FTPPlanDetails.NOReDir1#, 
								  #FTPPlanDetails.AnyDir1#, #FTPPlanDetails.AnyDrive1#, #FTPPlanDetails.NoDrive1#, #FTPPlanDetails.Max_Idle#, 
								  #FTPPlanDetails.Max_Connect#, #FTPPlanDetails.PutAny1#, #FTPPlanDetails.Super1#, #AccountPlanID#, 
								  #GetTheFCID.CFTPID#,#FTPPlanDetails.FTPExecFile#, #FTPPlanDetails.FTPListDirs#, #FTPPlanDetails.FTPInheritD#, 
								  '#GetTheFCID.FTPServer#')
							</cfquery>
							<cfquery name="NewFTPID" datasource="#pds#">
								SELECT Max(FTPID) as FTPID 
								FROM AccountsFTP
							</cfquery>
							<!--- BOB History --->
							<cfif Not IsDefined("NoBOBHist")>
								<cfquery name="BOBHist" datasource="#pds#">
									INSERT INTO BOBHist
									(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
									VALUES 
									(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
									'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the FTP account: #Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)# for #PersInfo.FirstName# #PersInfo.LastName#.')
								</cfquery>
							</cfif>						
						</cfif>
						<cfif (PlanDetails.EMailMatchYN Is 1) AND (PlanDetails.FreeEMails GT 0) AND (Type Is "Auth")>
							<!--- Insert AccountsEMail --->
							<cfquery name="PlanEMDetails" datasource="#pds#">
								SELECT MailBox, MailBoxLimit 
								FROM Plans 
								WHERE PlanID = #B50# 
							</cfquery>
							<cfquery name="GetTheEMCID" datasource="#pds#">
								SELECT CEmailID, EMailServer 
								FROM Domains 
								WHERE DomainID = #DomainID# 
							</cfquery>
							<cfquery name="CheckFirst" datasource="#pds#">
								SELECT EMailID 
								FROM AccountsEMail 
								WHERE AccountID = #NewAccountID# 
							</cfquery>
							<cfif CheckFirst.RecordCount Is 0>
								<cfset PrEM = 1>
							<cfelse>
								<cfset PrEm = 0>
							</cfif>
							<cfquery name="AddEMail" datasource="#pds#">
								INSERT INTO AccountsEMail 
								(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
								 PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
								 EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit, CEMailID)
								VALUES 
								(#NewAccountID#, #DomainID#, '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#@#Domain#', 
								 '#Password#', '#PersInfo.FirstName#', '#PersInfo.LastName#', 0, #PrEM#, 0, 
								 '#Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#', '#Domain#', '#PersInfo.FirstName# #PersInfo.LastName#', 
								 '#GetTheEMCID.EMailServer#', #AccountPlanID#, 'POP3', 
								 <cfif PlanEMDetails.MailBox Is "">Null<cfelse>'#PlanEMDetails.MailBox##Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#'</cfif>, 
								 <cfif PlanEMDetails.MailBoxLimit Is "">Null<cfelse>'#PlanEMDetails.MailBoxLimit#'</cfif>, #GetTheEMCID.CEMailID#)	
							</cfquery>
							<!--- BOB History --->
							<cfif Not IsDefined("NoBOBHist")>
								<cfquery name="BOBHist" datasource="#pds#">
									INSERT INTO BOBHist
									(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
									VALUES 
									(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
									'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the EMail account: #Trim(PlanDetails.AuthAddChars)##Login##Trim(PlanDetails.AuthSufChars)#@#Domain# for #PersInfo.FirstName# #PersInfo.LastName#.')
								</cfquery>
							</cfif>						
							<cfquery name="NewEMailID" datasource="#pds#">
								SELECT Max(EMailID) as EMailID 
								FROM AccountsEMail 
							</cfquery>
							<cfquery name="CheckIPAD" datasource="#pds#">
								SELECT ActiveYN 
								FROM CustomEMailSetup 
								WHERE CEMailID = #GetTheEMCID.CEMailID# 
								AND BOBName = 'MailCMD' 
							</cfquery>
							<cfif CheckIPAD.ActiveYN Is "1">
								<cfif Len(NewEMailID.EMailID) GTE 2>
									<cfset TheDir = Right(NewEMailID.EMailID,2)>
								<cfelse>
									<cfset TheDir = "0" & NewEMailID.EMailID>
								</cfif>
								<cfset IPADMailBoxPath = PlanEMDetails.MailBox & TheDir & "\" & NewEMailID.EMailID>
								<cfquery name="UpdMailBoxPath" datasource="#pds#">
									UPDATE AccountsEMail SET 
									MailBoxPath = '#IPADMailBoxPath#' 
									WHERE EMailID = #NewEMailID.EMailID# 
								</cfquery>
							</cfif>
						</cfif>
						<cfquery name="CleanUp" datasource="#pds#">
							DELETE FROM AccntTempInfo 
							WHERE InfoID = #InfoID#
						</cfquery>
					</cftransaction>
				<!--- Run scripts --->
				<cfset CreateAccount = NewAccountID>
				<cfset LocAuthID = NewAuthID.AuthID>
				<cfset LocCAuthID = GetTheCID.CAuthID>
				<cfset LocAccntPlanID = AccountPlanID>
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'account4.cfm' 
					AND L.LocationAction = 'Create' 
					AND I.TypeID = 
						(SELECT TypeID 
						 FROM IntTypes 
						 WHERE TypeStr = 'Authentication') 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<!--- Run external --->
				<cfif FileExists(ExpandPath("external#OSType#extcreateauth.cfm"))>
					<cfset SendID = NewAuthID.AuthID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="external#OSType#extcreateauth.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif> 
				<!--- FTP Match Setup --->
				<cfif (PlanDetails.FTPMatchYN Is 1) AND (PlanDetails.FTPNumber GT 0)>
					<cfquery name="GetScripts" datasource="#pds#">
						SELECT I.IntID 
						FROM Integration I, IntScriptLoc S, IntLocations L 
						WHERE I.IntID = S.IntID 
						AND S.LocationID = L.LocationID 
						AND L.ActiveYN = 1 
						AND I.ActiveYN = 1 
						AND L.PageName = 'account4.cfm' 
						AND L.LocationAction = 'Create' 
						AND I.TypeID = 
							(SELECT TypeID 
							 FROM IntTypes 
							 WHERE TypeStr = 'FTP') 
					</cfquery>
					<cfif GetScripts.RecordCount GT 0>
						<cfset LocScriptID = ValueList(GetScripts.IntID)>
						<cfset LocFTPID = NewFTPID.FTPID>
						<cfset LocCFTPID = GetTheFCID.CFTPID>
						<cfset LocAccntPlanID = AccountPlanID>
						<cfsetting enablecfoutputonly="no">
						<cfinclude template="runintegration.cfm">
						<cfsetting enablecfoutputonly="yes">
					</cfif>
					<!--- Run external --->
					<cfif FileExists(ExpandPath("external#OSType#extcreateftp.cfm"))>
						<cfset SendID = NewFTPID.FTPID>
						<cfsetting enablecfoutputonly="no">
						<cfinclude template="external#OSType#extcreateftp.cfm">
						<cfsetting enablecfoutputonly="yes">
					</cfif>
				</cfif>
				<!--- EMail Match Setup --->		
				<cfif (PlanDetails.EMailMatchYN Is 1) AND (PlanDetails.FreeEMails GT 0)>
					<cfquery name="UpdIdent" datasource="#pds#">
						UPDATE AccountsEMail SET 
						UniqueIdentifier = EMailID 
						WHERE EMailID = #NewEMailID.EMailID# 
					</cfquery>
					<cfquery name="GetScripts" datasource="#pds#">
						SELECT I.IntID 
						FROM Integration I, IntScriptLoc S, IntLocations L 
						WHERE I.IntID = S.IntID 
						AND S.LocationID = L.LocationID 
						AND L.ActiveYN = 1 
						AND I.ActiveYN = 1 
						AND L.PageName = 'account4.cfm' 
						AND L.LocationAction = 'Create' 
						AND I.TypeID = 
							(SELECT TypeID 
							 FROM IntTypes 
							 WHERE TypeStr = 'EMail') 
					</cfquery>
					<cfif GetScripts.RecordCount GT 0>
						<cfset LocScriptID = ValueList(GetScripts.IntID)>
						<cfset LocEMailID = NewEMailID.EMailID>
						<cfset LocCEMailID = GetTheEMCID.CEMailID>
						<cfset LocAccntPlanID = AccountPlanID>
						<cfsetting enablecfoutputonly="no">
						<cfinclude template="runintegration.cfm">
						<cfsetting enablecfoutputonly="yes">
					</cfif>
					<!--- Run external --->
					<cfif FileExists(ExpandPath("external#OSType#extcreateemail.cfm"))>
						<cfset SendID = NewEMailID.EMailID>
						<cfsetting enablecfoutputonly="no">
						<cfinclude template="external#OSType#extcreateemail.cfm">
						<cfsetting enablecfoutputonly="yes">
					</cfif> 
				</cfif>
			</cfloop>			
			<!--- FTP setup --->
			<cfquery name="GetFTP" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'FTP' 
			</cfquery>
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT Start_Dir, Read1, Write1, Create1, Delete1, MkDir1, RMDir1, 
				NoRedir1, AnyDir1, AnyDrive1, NoDrive1, PutAny1, Super1, Max_Idle, 
				Max_Connect, FTPAddChars, FTPSufChars, FTPExecFile, FTPListDirs, FTPInheritD 
				FROM Plans 
				WHERE PlanID = #B50# 
			</cfquery>
			<cfloop query="GetFTP">
				<cfquery name="GetTheCID" datasource="#pds#">
					SELECT CFTPID, FTPServer 
					FROM Domains 
					WHERE DomainID = #DomainID#
				</cfquery>
				<cftransaction> 
					<cfquery name="AddFTP" datasource="#pds#">
						INSERT INTO AccountsFTP 
						(AccountID, DomainID, DomainName, UserName, Password, Start_Dir, 
						 Read1, Write1, Create1, Delete1, MKDir1, RMDir1, NOReDir1, AnyDir1, 
						 AnyDrive1, NoDrive1, Max_Idle1, Max_Connect1, PutAny1, Super1, 
						 AccntPlanID, CFTPID, FTPExecFile, FTPListDirs, FTPInheritD, FTPServer)
						VALUES 
						(#NewAccountID#, #DomainID#, '#Domain#', '#Trim(PlanDetails.FTPAddChars)##Login##Trim(PlanDetails.FTPSufChars)#', 
						 '#Password#', '#PlanDetails.Start_Dir#', #PlanDetails.Read1#, #PlanDetails.Write1#, #PlanDetails.Create1#, 
						  #PlanDetails.Delete1#, #PlanDetails.MKDir1#, #PlanDetails.RMDir1#, #PlanDetails.NOReDir1#, 
						  #PlanDetails.AnyDir1#, #PlanDetails.AnyDrive1#, #PlanDetails.NoDrive1#, #PlanDetails.Max_Idle#, 
						  #PlanDetails.Max_Connect#, #PlanDetails.PutAny1#, #PlanDetails.Super1#, #AccountPlanID#, 
						  #GetTheCID.CFTPID#, #PlanDetails.FTPExecFile#, #PlanDetails.FTPListDirs#, #PlanDetails.FTPInheritD#, 
						  '#GetTheCID.FTPServer#') 
					</cfquery>
					<cfquery name="NewFTPID" datasource="#pds#">
						SELECT Max(FTPID) as FTPID 
						FROM AccountsFTP
					</cfquery>
					<cfif Not IsDefined("NoBOBHist")>
						<cfquery name="BOBHist" datasource="#pds#">
							INSERT INTO BOBHist
							(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
							VALUES 
							(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
							'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the FTP account: #Trim(PlanDetails.FTPAddChars)##Login##Trim(PlanDetails.FTPSufChars)# for #PersInfo.FirstName# #PersInfo.LastName#.')
						</cfquery>
					</cfif>						
					<cfquery name="CleanUp" datasource="#pds#">
						DELETE FROM AccntTempInfo 
						WHERE InfoID = #InfoID#
					</cfquery>
				</cftransaction>				
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'account4.cfm' 
					AND L.LocationAction = 'Create' 
					AND I.TypeID = 
						(SELECT TypeID 
						 FROM IntTypes 
						 WHERE TypeStr = 'FTP') 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocFTPID = NewFTPID.FTPID>
					<cfset LocCFTPID = GetTheCID.CFTPID>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<!--- Run external --->
				<cfif FileExists(ExpandPath("external#OSType#extcreateftp.cfm"))>
					<cfset SendID = NewFTPID.FTPID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="external#OSType#extcreateftp.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
			</cfloop>

			<!--- EMail setup --->
			<cfquery name="GetEMail" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #OldAccountID# 
				AND PlanID = #B50# 
				AND Type = 'EMail' 
			</cfquery>
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT MailBox, MailBoxLimit 
				FROM Plans 
				WHERE PlanID = #B50# 
			</cfquery>
			<cfloop query="GetEMail">
				<cfquery name="GetTheCID" datasource="#pds#">
					SELECT CEmailID, EMailServer 
					FROM Domains 
					WHERE DomainID = #DomainID# 
				</cfquery>
				<cfif EMailNum Is 1>
					<cfset PrEM = 1>
				<cfelse>
					<cfset PrEM = 0>
				</cfif>
				<cftransaction>
					<cfquery name="AddEMail" datasource="#pds#">
						INSERT INTO AccountsEMail 
						(AccountID, DomainID, Login, EMail, EPass, FName, LName, Alias,
						 PrEmail, ContactYN, SMTPUserName, DomainName, FullName, 
						 EMailServer, AccntPlanID, MailCMD, MailBoxPath, MailBoxLimit, CEMailID)
						VALUES 
						(#NewAccountID#, #DomainID#, '#Login#', '#EMailAddr#', '#Password#', 
						 '#PersInfo.FirstName#', '#PersInfo.LastName#', 0, #PrEM#, 0, 
						 '#UserName#', '#Domain#', '#PersInfo.FirstName# #PersInfo.LastName#', 
						 '#GetTheCID.EMailServer#', #AccountPlanID#, 'POP3', 
						 '#PlanDetails.MailBox##Login#', '#PlanDetails.MailBoxLimit#', #GetTheCID.CEMailID#)	
					</cfquery>
					<cfif Not IsDefined("NoBOBHist")>
						<cfquery name="BOBHist" datasource="#pds#">
							INSERT INTO BOBHist
							(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
							VALUES 
							(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
							'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the EMail account: #EMailAddr# for #PersInfo.FirstName# #PersInfo.LastName#.')
						</cfquery>
					</cfif>						
					<cfset EMailNum = 2>
					<cfquery name="NewEMailID" datasource="#pds#">
						SELECT Max(EMailID) as EMailID 
						FROM AccountsEMail 
					</cfquery>
					<cfquery name="CheckIPAD" datasource="#pds#">
						SELECT ActiveYN 
						FROM CustomEMailSetup 
						WHERE CEMailID = #GetTheCID.CEMailID# 
						AND BOBName = 'MailCMD' 
					</cfquery>
					<cfif CheckIPAD.ActiveYN Is "1">
						<cfif Len(NewEMailID.EMailID) GTE 2>
							<cfset TheDir = Right(NewEMailID.EMailID,2)>
						<cfelse>
							<cfset TheDir = "0" & NewEMailID.EMailID>
						</cfif>
						<cfset IPADMailBoxPath = PlanDetails.MailBox & TheDir & "\" & NewEMailID.EMailID>
						<cfquery name="UpdMailBoxPath" datasource="#pds#">
							UPDATE AccountsEMail SET 
							MailBoxPath = '#IPADMailBoxPath#' 
							WHERE EMailID = #NewEMailID.EMailID# 
						</cfquery>
					</cfif>
					<cfquery name="CleanUp" datasource="#pds#">
						DELETE FROM AccntTempInfo 
						WHERE InfoID = #InfoID#
					</cfquery>
				</cftransaction>
				<cfquery name="UpdIdent" datasource="#pds#">
					UPDATE AccountsEMail SET 
					UniqueIdentifier = EMailID 
					WHERE EMailID = #NewEMailID.EMailID# 
				</cfquery>
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'account4.cfm' 
					AND L.LocationAction = 'Create' 
					AND I.TypeID = 
						(SELECT TypeID 
						 FROM IntTypes 
						 WHERE TypeStr = 'EMail') 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocEMailID = NewEMailID.EMailID>
					<cfset LocCEMailID = GetTheCID.CEMailID>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<!--- Run Misc Scripts --->
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'account4.cfm' 
					AND L.LocationAction = 'Create' 
					AND I.TypeID = 
						(SELECT TypeID 
						 FROM IntTypes 
						 WHERE TypeStr = 'Misc') 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocAccntPlanID = AccountPlanID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<!--- Run external --->
				<cfif FileExists(ExpandPath("external#OSType#extcreateemail.cfm"))>
					<cfset SendID = NewEMailID.EMailID>
					<cfsetting enablecfoutputonly="no">
					<cfinclude template="external#OSType#extcreateemail.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif> 
			</cfloop>	
		</cfif>
	</cfloop>
	<!--- Add the EMail Welcome Letter --->
	<cfquery name="GetLetters" datasource="#pds#">
		SELECT I.IntID, P.PlanID, I.EMailServer, I.EMailServerPort, I.EMailFrom, I.EMailTo, I.EMailCC, 
		I.EMailFile, I.EmlAttachWait, I.EMailDelay, I.EMailSubject, I.EMailMessage, I.EMailRepeatMsg 
		FROM Integration I, Plans P 
		WHERE I.IntID = P.EMailLetterID 
		AND I.ActiveYN = 1 
		AND P.PlanID IN 
			(#AccntInfo.SelectPlan#)
	</cfquery>
	<cfif GetLetters.RecordCount GT 0>
		<cfloop query="GetLetters">
			<cfset LocScriptID = IntID>
			<cfset LocAccountID = NewAccountID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runvarvalues.cfm">
			<cfsetting enablecfoutputonly="yes">
			<cfset LocServer = ReplaceList("#EMailServer#","#FindList#","#ReplList#")>
			<cfset LocSvPort = ReplaceList("#EMailServerPort#","#FindList#","#ReplList#")>
			<cfif Trim(LocSvPort) Is "">
				<cfset LocSvPort = 25>
			</cfif>
			<cfset LocEMalTo = ReplaceList("#EMailTo#","#FindList#","#ReplList#")>
			<cfset LocEMFrom = ReplaceList("#EMailFrom#","#FindList#","#ReplList#")>
			<cfset LocEmalCC = ReplaceList("#EMailCC#","#FindList#","#ReplList#")>
			<cfset LocSubjct = ReplaceList("#EMailSubject#","#FindList#","#ReplList#")>
			<cfset LocFileNm = ReplaceList("#EMailFile#","#FindList#","#ReplList#")>
			<cfset LocMessag = ReplaceList("#EMailMessage#","#FindList#","#ReplList#")>
			<cfset TheLocMessag = Replace(LocMessag,")*N/A*(","","All")>
			<cfset LocScriptID = IntID>
			<cfset LocAccountID = NewAccountID>
			<cfset TheFindList = FindList>
			<cfset TheReplList = ReplList>
			<cfinclude template="runrepeatvalues.cfm">
			<cfset TheLocMessag = TheLocMessag & RepeatMessage>
			<cfif EMailDelay Is "">
				<cfset TheDelay = "1">
			<cfelse>
				<cfset TheDelay = EMailDelay>
			</cfif>
			<cfset WhenToSend = DateAdd("n",TheDelay,Now())>
			<cfquery name="SchedEMail" datasource="#pds#">
				INSERT INTO AutoRun 
				(WhenRun, DoAction, AccountID, EMailFrom, EMailSubject, EMailTo, 
				 EMailCC, FileAttach, Value1, Value2, Memo1, ScheduledBy, Memo2, PlanID) 
				VALUES 
				(#CreateODBCDateTime(WhenToSend)#, 'EMailDelay', #NewAccountID#, '#LocEMFrom#', '#LocSubjct#', '#LocEMalTo#', 
				 <cfif LocEmalCC Is "">Null<cfelse>'#LocEmalCC#'</cfif>, 
				 <cfif LocFileNm Is "">Null<cfelse>'#LocFileNm#'</cfif>, 
				 <cfif LocServer Is "">Null<cfelse>'#LocServer#'</cfif>, 
				 <cfif LocSvPort Is "">Null<cfelse>'#LocSvPort#'</cfif>, 
				 <cfif TheLocMessag Is "">Null<cfelse>'#TheLocMessag#'</cfif>, 
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 'Plan Welcome letter scheduled', 
				 #PlanID#) 
			</cfquery>
			<cfquery name="GetWhoIs" datasource="#pds#">
				SELECT AccountID, FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = #NewAccountID# 
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					('#LocMessag#',#NewAccountID#,#MyAdminID#, #Now()#,'E-Mailed','#StaffMemberName.FirstName# #StaffMemberName.LastName# e-mailed #GetWhoIs.FirstName# #GetWhoIs.LastName# at #LocEMalTo#.')
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>	
	<!--- End Send Welcome Letter --->
	<cfquery name="FinTrans" datasource="#pds#">
		SELECT * 
		FROM AccntTempFin 
		WHERE AccountID = #OldAccountID# 
		AND PlanID In (#AccntInfo.SelectPlan#)
	</cfquery>
	<cfloop query="FinTrans">
		<cfquery name="EMailInfo" datasource="#pds#">
			SELECT DomainID 
			FROM Domains 
			WHERE DomainName = 
				(SELECT DefMailServer 
				 FROM Plans 
				 WHERE PlanID = #PlanID# )
		</cfquery>
		<cfquery name="FTPInfo" datasource="#pds#">
			SELECT DomainID 
			FROM Domains 
			WHERE DomainName = 
				(SELECT DefFTPServer 
				 FROM Plans 
				 WHERE PlanID = #PlanID# )
		</cfquery>
		<cfquery name="AuthInfo" datasource="#pds#">
			SELECT DomainID 
			FROM Domains 
			WHERE DomainName = 
				(SELECT DefAuthServer 
				 FROM Plans 
				 WHERE PlanID = #PlanID# )
		</cfquery>
		<cfquery name="PlanDetails" datasource="#pds#">
			SELECT PayDueDays, DeactDays
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="AcntID" datasource="#pds#">
			SELECT AccntPlanID 
			FROM AccntPlans 
			WHERE AccountID = #NewAccountID# 
			AND PlanID = #PlanID# 
		</cfquery>
		<!--- Check For Group --->
		<cfquery name="GroupCheck" datasource="#pds#">
			SELECT PrimaryID 
			FROM Multi 
			WHERE AccountID = #NewAccountID#
		</cfquery>
		<cfif GroupCheck.RecordCount Is 0>
			<cfset PrimID = NewAccountID>
		<cfelse>
			<cfset PrimID = GroupCheck.PrimaryID>
		</cfif>
		<cftransaction>
			<cfquery name="TransAdd" datasource="#pds#">
				INSERT INTO Transactions 
				(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
				 MemoField,AdjustmentYN,EnteredBy,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
				 SubAccountID,SetUpFeeYN,
				 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
				 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
				 PlanPayBy,SalesPersonID,AccntPlanID,DiscountYN,
				 FirstName,LastName)
				VALUES 
				(#PrimID#, #Now()#,
				<cfif TransactionType Is "RA">
					 0, #TransAmount#, 0, 0, 0, #TransAmount#, 
					 <cfset TType = "Debit">
				<cfelseif TransactionType Is "FA">
					 0, #TransAmount#, 0, 0, 0, #TransAmount#, 
					 <cfset TType = "Debit">
				<cfelseif TransactionType Is "RD">
					 #TransAmount#, 0, 0, 0, #TransAmount#, 0, 
					 <cfset TType = "Credit">
				<cfelseif TransactionType Is "FD">
					#TransAmount#, 0, 0, 0, #TransAmount#, 0, 
					<cfset TType = "Credit">
				<cfelseif TransactionType Is "TX">
					0, #TransAmount#, 1, #TaxLevel#, 0, #TransAmount#, 
					<cfset TType = "Debit">
				<cfelseif TransactionType Is "PO">
					0, #TransAmount#, 0, 0, 0, #TransAmount#, 
					<cfset TType = "Debit">
				</cfif>
				'#TransMemo#', 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
				<cfif EMailInfo.DomainID Is "">Null<cfelse>#EMailInfo.DomainID#</cfif>, 
				<cfif FTPInfo.DomainID Is "">Null<cfelse>#FTPInfo.DomainID#</cfif>, 
				<cfif AuthInfo.DomainID Is "">Null<cfelse>#AuthInfo.DomainID#</cfif>, #AccntInfo.POPID#, #PlanID#, 0, 
				#AccountID#, <cfif (TransactionType Is "FA") OR (TransactionType Is "FD")>1<cfelse>0</cfif>, 
				#Now()#, <cfif PlanDetails.DeactDays Is 0>Null<cfelse>#DateAdd("d",PlanDetails.DeactDays,Now())#</cfif>, 0, 
				<cfif PlanDetails.PayDueDays Is 0>Null<cfelse>#DateAdd("d",PlanDetails.PayDueDays,Now())#</cfif>, 
				0, 0, 0, <cfif StartDate Is "">Null<cfelse>#CreateODBCDateTime(StartDate)#</cfif>, <cfif EndDate Is "">Null<cfelse>#CreateODBCDateTime(EndDate)#</cfif>, 
				'#Evaluate("PayByCur#PlanID#")#', #GetOpts.AdminID#, #AcntID.AccntPlanID#, 0, 
				'#PersInfo.FirstName#', '#PersInfo.LastName#'
				)
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM AccntTempFin 
				WHERE FinancialID = #FinancialID# 
			</cfquery>
		</cftransaction>
	</cfloop>
	<cfquery name="CheckFor" datasource="#pds#">
		SELECT * 
		FROM AccntTransTemp 
		WHERE TempAccountID = #OldAccountID# 
	</cfquery>
	<cfif CheckFor.RecordCount GT 0>
		<cfloop query="CheckFor">
			<cfquery name="GetIds" datasource="#pds#">
				SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
				FROM AccntPlans
				WHERE AccntPlanID IN 
					(SELECT AccntPlanID 
					 FROM AccntPlans 
					 WHERE AccountID = #NewAccountID#)
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
				(#PrimID#, #Now()#, #CreditAmount#, 0, 0, 0, #CreditAmount#, 0, 
				 '#CCType# Authorization: #CCAuthCode#', 0, 'Online Signup',
				 <cfif GetIds.EMailDomainID Is ""> Null<cfelse> #GetIds.EMailDomainID#</cfif>, 
				 <cfif GetIds.FTPDomainID Is ""> Null<cfelse> #GetIds.FTPDomainID#</cfif>, 
				 <cfif GetIds.AuthDomainID Is ""> Null<cfelse> #GetIds.AuthDomainID#</cfif>, 
				 <cfif GetIds.POPID Is ""> Null<cfelse> #GetIds.POPID#</cfif>, 
				 <cfif GetIds.PlanID Is ""> Null<cfelse>#GetIds.PlanID#</cfif>, 0, 
				 #NewAccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
				 'CC', 0, #GetIds.AccntPlanID#, 0, 
				 '#AccntInfo.FirstName#', '#AccntInfo.LastName#', '#CCAuthCode#', 'Credit Card',
				 #CCProcessDate#, '#CCType#')
			</cfquery>
		</cfloop>
	</cfif>
	<cfquery name="JustInCase" datasource="#pds#">
		SELECT * 
		FROM AccntTemp 
		WHERE AccountID = #OldAccountID#
	</cfquery>
	<cfquery name="WeBeDone" datasource="#pds#">
		DELETE FROM AccntTemp 
		WHERE AccountID = #OldAccountID# 
	</cfquery>
	<cfsetting enablecfoutputonly="No">
	<cfset AccountID = NewAccountID>
	<cfinclude template="payment.cfm">
	<cfabort>
</cfif>

<cfquery name="Accounts" datasource="#pds#">
	SELECT A.*, P.PlanDesc, P.RecurringAmount, P.RecurDiscount, 
	P.FixedDiscount, P.FixedAmount, P.RAMemo, P.RDMemo, P.FAMemo, 
	P.FDMemo, P.RecurringCycle, P.AuthAddChars, P.AuthSufChars, 
	P.FTPAddChars, P.FTPSufChars, P.FTPMatchYN, P.FTPNumber, P.EmailMatchYN, 
	P.FreeEmails 
	FROM Plans P, AccntTempInfo A 
	WHERE P.PlanID = A.PlanID 
	AND A.AccountID = #AccountID# 
	Order By P.PlanDesc, A.Type 
</cfquery>
<cfquery name="AccntInfo" datasource="#pds#">
	SELECT * 
	FROM AccntTemp 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif IsDefined("MakeBOBAcnt")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Accounts 
		WHERE Login = '#AccntInfo.Login#'
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="BOBCustomFields" datasource="#pds#">
			SELECT BOBFieldName, DataType 
			FROM WizardSetup 
			WHERE ActiveYN = 1 
			AND AWUseYN = 1 
			AND IsDeletable = 1
		</cfquery>	
		<cftransaction>
			<cfquery name="MakeBOB" datasource="#pds#">
				INSERT INTO Accounts 
				(Login, Password, LastName, FirstName, Initial, Address1, Address2, Address3, 
				 City, State, Zip, DayPhone, EvePhone, Fax, PCType, ModemSpeed, OSVersion, Notes, 
				 CancelYN, StartDate, DeactivatedYN, Company, Modem, SalesPersonID, 
				 <cfloop query="BOBCustomFields">#BOBFieldName#, </cfloop> Country) 
				SELECT Login, Password, LastName, FirstName, Initial, Address1, Address2, Address3, 
				 City, State, Zip, DayPhone, EvePhone, Fax, PCType, ModemSpeed, OSVersion, Notes, 
				 CancelYN, StartDate, DeactivatedYN, Company, Modem, SalesPersonID, 
				 <cfloop query="BOBCustomFields">#BOBFieldName#, </cfloop> Country 
				FROM AccntTemp 
				WHERE AccountID = #AccountID# 
			</cfquery>
			<cfquery name="TheID" datasource="#pds#">
				SELECT Max(AccountID) as NewID 
				FROM Accounts
			</cfquery>
			<cfset NewAccountID = TheID.NewID>
		</cftransaction>
		<!--- Check SalesPersonId --->
		<cfquery name="CheckSalesID" datasource="#pds#">
			SELECT SalesPersonID 
			FROM Accounts 
			WHERE AccountID = #NewAccountID# 
		</cfquery>
		<cfif CheckSalesID.SalesPersonID Is "">
			<cfquery name="UpdSales" datasource="#pds#">
				UPDATE Accounts SET 
				SalesPersonID = #MyAdminID# 
				WHERE AccountID = #NewAccountID# 
			</cfquery>
		</cfif>
		<cfif (AccntInfo.GroupID Is Not "") AND (AccntInfo.GroupID GT 0)>
			<cfquery name="GetGroup" datasource="#pds#">
				SELECT * 
				FROM Multi 
				WHERE BillingID = #AccntInfo.GroupID# 
				AND BillTo = 1 
			</cfquery>
			<cfquery name="MakePartGroup" datasource="#pds#">
				INSERT INTO Multi 
				(AccountID, BillingID, BillTo, PrimaryID, ViewPrivYN, AddAccntYN) 
				VALUES 
				(#NewAccountID#, #AccntInfo.GroupID#, 0, #GetGroup.PrimaryID#, 0, 0) 
			</cfquery>
		</cfif>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetWhoName" datasource="#pds#">
				SELECT FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = #NewAccountID#
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#NewAccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the customer #GetWhoName.FirstName# #GetWhoName.LastName#.')
			</cfquery>
		</cfif>
	<cfelse>
		<cfset NewAccountID = CheckFirst.AccountID>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Account Wizard</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="3"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Signup - #AccntInfo.FirstName# #AccntInfo.Lastname#</font></th>
	</tr>
</cfoutput>
	<cfoutput query="Accounts" group="PlanID">
		<tr bgcolor="#thclr#">
			<th colspan="3">#PlanDesc#</th>
		</tr>
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<td>#Type#</td>
				<cfif Type Is "Auth">
					<td>#Trim(AuthAddChars)##Login##Trim(AuthSufChars)#</td>
					<td>#DomainName#</td>
				<cfelseif Type Is "FTP">
					<td>#Trim(FTPAddChars)##Login##Trim(FTPSufChars)#</td>
					<td>#DomainName#</td>
				<cfelse>
					<td colspan="2">#EMailAddr#</td>
				</cfif>
			</tr>
			<cfif (FTPMatchYN Is 1) AND (FTPNumber GT 0) AND (Type Is "Auth")>
				<tr bgcolor="#tbclr#">
					<td>FTP</td>
					<td>#Trim(AuthAddChars)##Login##Trim(AuthSufChars)#</td>
					<td>#DomainName#</td>
				</tr>
			</cfif>
			<cfif (EMailMatchYN Is 1) AND (FreeEMails GT 0) AND (Type Is "Auth")>
				<cfquery name="GetDomainName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #DomainID#
				</cfquery>
				<tr bgcolor="#tbclr#">
					<td>EMail</td>
					<td>#Trim(AuthAddChars)##Login##Trim(AuthSufChars)#@#GetDomainName.DomainName#</td>
					<td>#DomainName#</td>
				</tr>
			</cfif>
		</cfoutput>
	</cfoutput>
	<form method="post" action="account4.cfm">
		<cfoutput>
			<tr>
				<th colspan="3" bgcolor="#thclr#">Click continue to create the above accounts.</th>
			</tr>
			<tr>
				<th colspan="3"><input type="Image" src="images/continue.gif" name="makeaccnt" border="0"></th>
			</tr>
			<input type="Hidden" name="NewAccountID" value="#NewAccountID#">
			<input type="Hidden" name="OldAccountID" value="#AccountID#">
			<cfloop index="B5" list="#AccntInfo.SelectPlan#">
				<cfset DispStr = Evaluate("PayBy#B5#")>
				<cfset DispStr2 = Evaluate("PayByCur#B5#")>
				<input type="Hidden" name="PayBy#B5#" value="#DispStr#">
				<input type="Hidden" name="PayByCur#B5#" value="#DispStr2#">
			</cfloop>
		</cfoutput>
	</form>
</table>
<cfoutput>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 