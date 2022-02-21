<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page calls the different tabs for editing domains.
--->
<!--- 4.0.0 08/01/99
		3.5.0 07/05/99
		3.2.0 09/08/98 --->
<!--- domains2.cfm --->
<cfif IsDefined("SetInt.x")>
	<cfif IsDefined("AvailAuths")>
		<cfif AvailAuths Is Not "">
			<cfquery name="SetTheInts" datasource="#pds#">
				UPDATE Domains SET 
				CAuthID = #AvailAuths# 
				WHERE DomainID = #DomainID# 
			</cfquery>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT AuthDescription 
					FROM CustomAuth 
					WHERE CAuthID = #AvailAuths# 
				</cfquery>
				<cfquery name="TheName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #DomainID# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,0,#MyAdminID#, #Now()#,'Domain',
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# set the auth to #GetWhoName.AuthDescription# for #TheName.DomainName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfif IsDefined("AvailEMails")>
		<cfif AvailEMails Is Not "">
			<cfquery name="SetTheInts" datasource="#pds#">
				UPDATE Domains SET 
				CEMailID = #AvailEMails# 
				WHERE DomainID = #DomainID# 
			</cfquery>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT EMailDescription 
					FROM CustomEMail 
					WHERE CEMailID = #AvailEmails# 
				</cfquery>
				<cfquery name="TheName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #DomainID# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,0,#MyAdminID#, #Now()#,'Domain',
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# set the Email to #GetWhoName.EMailDescription# for #TheName.DomainName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfif IsDefined("AvailFTPs")>
		<cfif AvailFTPs Is Not "">
			<cfquery name="SetTheInts" datasource="#pds#">
				UPDATE Domains SET 
				CFTPID = #AvailFTPs# 
				WHERE DomainID = #DomainID# 
			</cfquery>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT FTPDescription 
					FROM CustomFTP 
					WHERE CFTPID = #AvailFTPs# 
				</cfquery>
				<cfquery name="TheName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #DomainID# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,0,#MyAdminID#, #Now()#,'Domain',
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# set the FTP to #GetWhoName.FTPDescription# for #TheName.DomainName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfif (IsDefined("MvLt")) AND (IsDefined("SelAccounts"))>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheName" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID# 
		</cfquery>
	</cfif>
	<cfloop index="B5" list="#SelAccounts#">
		<cfif B5 GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM DomAccnt 
				WHERE DomainID = #DomainID# 
				AND AccountID = #B5#
			</cfquery>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT FirstName, LastName 
					FROM Accounts 
					WHERE AccountID = #B5# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#B5#,#MyAdminID#, #Now()#,'Domain', 
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed #GetWhoName.FirstName# #GetWhoName.LastName# from #TheName.DomainName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("AddThese.x")) AND (IsDefined("AccountID"))>
	<cfloop index="B5" list="#AccountID#">
		<cfif B5 GT 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO DomAccnt 
				(AccountID,DomainID)
				VALUES 
				(#B5#,#DomainID#)
			</cfquery>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="TheName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #DomainID# 
				</cfquery>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT FirstName, LastName 
					FROM Accounts 
					WHERE AccountID = #B5# 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#B5#,#MyAdminID#, #Now()#,'Domain', 
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# added #GetWhoName.FirstName# #GetWhoName.Lastname# to #TheName.DomainName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("SelAdmins"))>
	<cfloop index="B5" list="#SelAdmins#">
		<cfif B5 Is Not 0>
			<cfquery name="AddOne" datasource="#pds#">
				DELETE FROM DomAdm  
				WHERE DomainID = #DomainID# 
				AND AdminID = #B5#
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheName" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID# 
		</cfquery>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName + ' ' + LastName As FullName 
			FROM Accounts 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID IN (#SelAdmins#) 
				 ) 
			ORDER BY LastName, FirstName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain', 
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following to #TheName.DomainName#: #ValueList(GetWhoName.FullName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvRt")) AND (IsDefined("AvailAdmins"))>
	<cfloop index="B5" list="#AvailAdmins#">
		<cfif B5 Is Not 0>
			<cfquery name="AddOne" datasource="#pds#">
				INSERT INTO DomAdm 
				(DomainID, AdminID) 
				VALUES 
				(#DomainID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheName" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID# 
		</cfquery>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName + ' ' + LastName As FullName 
			FROM Accounts 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID IN (#AvailAdmins#) 
				 ) 
			ORDER BY LastName, FirstName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain', 
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following to #TheName.DomainName#: #ValueList(GetWhoName.FullName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("SelPlans"))>
	<cfloop index="B5" list="#SelPlans#">
		<cfif B5 Is Not 0>
			<cfquery name="AddOne" datasource="#pds#">
				DELETE FROM DomPlans 
				WHERE DomainID = #DomainID# 
				AND PlanID = #B5#
			</cfquery>
			<cfquery name="AddOne" datasource="#pds#">
				DELETE FROM DomAPlans 
				WHERE DomainID = #DomainID# 
				AND PlanID = #B5#
			</cfquery>
			<cfquery name="AddOne" datasource="#pds#">
				DELETE FROM DomFPlans 
				WHERE DomainID = #DomainID# 
				AND PlanID = #B5#
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheName" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID# 
		</cfquery>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID In (#SelPlans#) 
			ORDER BY PlanDesc
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain', 
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following plans to #TheName.DomainName#: #ValueList(GetWhoName.PlanDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvRt")) AND (IsDefined("AvailPlans"))>
	<cfloop index="B5" list="#AvailPlans#">
		<cfif B5 Is Not 0>
			<cfquery name="AddOne" datasource="#pds#">
				INSERT INTO DomPlans 
				(DomainID, PlanID) 
				VALUES 
				(#DomainID#,#B5#)
			</cfquery>
			<cfquery name="AddOne" datasource="#pds#">
				INSERT INTO DomAPlans 
				(DomainID, PlanID) 
				VALUES 
				(#DomainID#,#B5#)
			</cfquery>
			<cfquery name="AddOne" datasource="#pds#">
				INSERT INTO DomFPlans 
				(DomainID, PlanID) 
				VALUES 
				(#DomainID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheName" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID# 
		</cfquery>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID In (#AvailPlans#) 
			ORDER BY PlanDesc
		</cfquery>
		<cfset AllTheNames = ValueList(GetWhoName.PlanDesc)>
		<cfset AllTheNames = PreserveSingleQuotes(AllTheNames)>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain', 
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following plans to #TheName.DomainName#: #AllTheNames#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("AddNewDomain.x")>
	<cftransaction>
		<cfquery name="CheckPrimary" datasource="#pds#">
			SELECT * 
			FROM Domains 
			WHERE Primary1 = 1 
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT DomainID 
			FROM Domains 
			WHERE DomainName = '#DomainName#' 
		</cfquery>
		<cfif CheckFirst.RecordCount Is 0>
			<cfquery name="addadom" datasource="#pds#">
				INSERT INTO domains 
				(DomainName, ShowYN, PrivateYN, UseAddr, DomName, DomContact, DomAdd1, DomAdd2, 
				 DomCity, DomState, DomZip, DomPhone, NewsServer, EMailServer, AuthServer, 
				 FTPServer, POP3Server, NewsServerIP, EMailServerIP, AuthServerIP, 
				 FTPServerIP, POP3ServerIP, DNS1, DNS2, AccntLimit, WebsiteIP, Primary1)
				VALUES 
				('#Trim(DomainName)#', #showyn#, #privateYN#, #useaddr#, 
				 <cfif Trim(DomName) Is "">Null<cfelse>'#DomName#'</cfif>, 
				 <cfif Trim(DomContact) Is "">Null<cfelse>'#DomContact#'</cfif>, 
				 <cfif Trim(DomAdd1) Is "">Null<cfelse>'#DomAdd1#'</cfif>,  
				 <cfif Trim(DomAdd2) Is "">Null<cfelse>'#DomAdd2#'</cfif>, 
				 <cfif Trim(DomCity) Is "">Null<cfelse>'#DomCity#'</cfif>, 
				 '#DomState#', 
				 <cfif Trim(DomZip) Is "">Null<cfelse>'#DomZip#'</cfif>, 
				 <cfif Trim(DomPhone) Is "">Null<cfelse>'#DomPhone#'</cfif>, 
				 <cfif Trim(NewsServer) Is "">Null<cfelse>'#NewsServer#'</cfif>, 
				 <cfif Trim(EMailServer) Is "">Null<cfelse>'#form.emailserver#'</cfif>, 
				 <cfif Trim(AuthServer) Is "">Null<cfelse>'#form.AuthServer#'</cfif>, 
				 <cfif Trim(FTPServer) Is "">Null<cfelse>'#form.FTPServer#'</cfif>, 
				 <cfif Trim(POP3Server) Is "">Null<cfelse>'#form.POP3Server#'</cfif>, 
				 <cfif Trim(NewsServerIP) Is "">Null<cfelse>'#NewsServerIP#'</cfif>, 
				 <cfif Trim(EMailServerIP) Is "">Null<cfelse>'#EMailServerIP#'</cfif>, 
				 <cfif Trim(AuthServer) Is "">Null<cfelse>'#AuthServerIP#'</cfif>, 
				 <cfif Trim(FTPServer) Is "">Null<cfelse>'#FTPServerIP#'</cfif>, 
				 <cfif Trim(POP3ServerIP) Is "">Null<cfelse>'#POP3ServerIP#'</cfif>, 
				 <cfif trim(DNS1) Is "">Null<cfelse>'#DNS1#'</cfif>, 
				 <cfif trim(DNS2) Is "">Null<cfelse>'#DNS2#'</cfif>, 
				 <cfif Trim(AccntLimit) Is "">Null<cfelse>#Trim(AccntLimit)#</cfif>, 
				 <cfif Trim(WebsiteIP) Is "">Null<cfelse>'#Trim(WebsiteIP)#'</cfif>, 
				 <cfif CheckPrimary.RecordCount Is 0>1<cfelse>0</cfif> 
				)
			</cfquery>
		</cfif>
		<cfquery name="GetNewId" datasource="#pds#">
			SELECT max(DomainID) as DomID 
			FROM domains
		</cfquery>
		<cfset DomainID = GetNewId.DomID>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Domain', 
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the domain: #Trim(DomainName)#.')
			</cfquery>
		</cfif>
	</cftransaction>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'domains2.cfm' 
		AND L.LocationAction = 'Create' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'Domain') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfset LocDomainID = DomainID>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfif FileExists(ExpandPath("external#OSType#domainnameadd.cfm"))>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#domainnameadd.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
</cfif>
<cfif IsDefined("EditDomain.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Domains SET 
		DomainName = '#domainname#', 
		ShowYN = #showyn#, 
		PrivateYN = #privateYN#, 
		UseAddr = #useaddr#, 
		AccntLimit = <cfif Trim(AccntLimit) Is "">Null<cfelse>#AccntLimit#</cfif>, 
		DomName = <cfif Trim(DomName) Is "">Null<cfelse>'#DomName#'</cfif>, 
		DomContact = <cfif Trim(DomContact) Is "">Null<cfelse>'#DomContact#'</cfif>, 
		DomAdd1 = <cfif Trim(DomAdd1) Is "">Null<cfelse>'#DomAdd1#'</cfif>,  
		DomAdd2 = <cfif Trim(DomAdd2) Is "">Null<cfelse>'#DomAdd2#'</cfif>, 
		DomCity = <cfif Trim(DomCity) Is "">Null<cfelse>'#DomCity#'</cfif>, 
		DomState = '#DomState#', 
		DomZip = <cfif Trim(DomZip) Is "">Null<cfelse>'#DomZip#'</cfif>, 
		DomPhone = <cfif Trim(DomPhone) Is "">Null<cfelse>'#DomPhone#'</cfif>, 
		NewsServer = <cfif Trim(NewsServer) Is "">Null<cfelse>'#NewsServer#'</cfif>, 
		EMailServer = <cfif Trim(EMailServer) Is "">Null<cfelse>'#form.emailserver#'</cfif>, 
		AuthServer = <cfif Trim(AuthServer) Is "">Null<cfelse>'#form.AuthServer#'</cfif>, 
		FTPServer = <cfif Trim(FTPServer) Is "">Null<cfelse>'#form.FTPServer#'</cfif>, 
		POP3Server = <cfif Trim(POP3Server) Is "">Null<cfelse>'#form.POP3Server#'</cfif>, 
		NewsServerIP = <cfif Trim(NewsServerIP) Is "">Null<cfelse>'#NewsServerIP#'</cfif>, 
		EMailServerIP = <cfif Trim(EMailServerIP) Is "">Null<cfelse>'#EMailServerIP#'</cfif>, 
		AuthServerIP = <cfif Trim(AuthServer) Is "">Null<cfelse>'#AuthServerIP#'</cfif>, 
		FTPServerIP = <cfif Trim(FTPServer) Is "">Null<cfelse>'#FTPServerIP#'</cfif>, 
		DNS1 = <cfif Trim(DNS1) Is "">Null<cfelse>'#DNS1#'</cfif>, 
		DNS2 = <cfif Trim(DNS2) Is "">Null<cfelse>'#DNS2#'</cfif>, 		
		POP3ServerIP = <cfif Trim(POP3Server) Is "">Null<cfelse>'#POP3ServerIP#'</cfif>, 
		WebsiteIP = <cfif Trim(WebsiteIP) Is "">Null<cfelse>'#WebsiteIP#'</cfif>, 
		EditedYN = 1 
		WHERE domainid = #DomainID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetDom" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #DomainID#
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domain #GetDom.DomainName#.')
		</cfquery>
	</cfif>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'domains2.cfm' 
		AND L.LocationAction = 'Change' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'Domain') 		
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfset LocDomainID = DomainID>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfif FileExists(ExpandPath("external#OSType#domainnameedit.cfm"))>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#domainnameedit.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
</cfif>
<cfparam name="DomainID" default="0">
<cfparam name="tab" default="1">
<cfquery name="OneDomain" datasource="#pds#">
	SELECT * 
	FROM Domains 
	WHERE DomainID = #DomainID#
</cfquery>
<cfif tab Is 1>
	<cfset HowWide = 2>
	<cfquery name="GetStates" datasource="#pds#">
		SELECT StateName, Abbr, DefState 
		FROM States 
		WHERE ActiveYN = 1 
		ORDER BY StateYN desc, StateName
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 3>
	<cfquery name="GetCurPlans" datasource="#pds#">
		SELECT P.PlanID, P.PlanDesc 
		FROM Plans P, DomPlans D 
		WHERE P.PlanID = D.PlanID 
		AND D.DomainID = #DomainID# 
		ORDER BY P.PlanDesc
	</cfquery>
	<cfquery name="GetAvailPlans" datasource="#pds#">
		SELECT P.PlanID, P.PlanDesc 
		FROM Plans P 
		WHERE P.PlanID Not In 
			(SELECT P.PlanID 
			 FROM Plans P, DomPlans D 
			 WHERE P.PlanID = D.PlanID 
			 AND D.DomainID = #DomainID#) 
		ORDER BY P.PlanDesc
	</cfquery>
<cfelseif tab Is 3>
	<cfset HowWide = 3>
	<cfquery name="Getwhohas" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A, DomAdm D 
		WHERE D.DomainID = #DomainID# 
		AND C.AccountID = A.AccountID 
		AND A.AdminID = D.AdminID 
		ORDER BY C.LastName, C.FirstName
	</cfquery>
	<cfquery name="Getwhowants" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID Not In 
			(SELECT A.AdminID 
			 FROM Accounts C, Admin A, DomAdm D 
			 WHERE D.DomainID = #DomainID# 
			 AND C.AccountID = A.AccountID 
			 AND A.AdminID = D.AdminID)
		Order By C.LastName, C.FirstName 
	</cfquery>
<cfelseif tab Is 4>
	<cfset HowWide = 2>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT A.LastName, A.FirstName, A.AccountID, A.Company 
		FROM Accounts A, DomAccnt D 
		WHERE A.AccountID = D.AccountID 
		AND D.DomainID = #DomainID# 
	</cfquery>
	<cfif IsDefined("SearchFor.x")>
		<cfset HowWide = 4>
		<cfquery name="LookingFor" datasource="#pds#">
			SELECT A.*, E.EMail 
			FROM Accounts A Left Join AccountsEMail E
			On E.AccountID = A.AccountID 
			WHERE A.#FirstParam# 
			<cfif LogicParam Is "Contains">
				Like '%#SecondParam#%'
			<cfelse>
				Like '#SecondParam#%'
			</cfif>
			AND (E.PrEMail = 1 OR E.PrEMail Is Null)
			AND A.AccountID Not In 
				(SELECT C.AccountID 
				 FROM Accounts C, DomAccnt D 
				 WHERE C.AccountID = D.AccountID 
				 AND D.DomainID = #DomainID#)
			ORDER BY A.#FirstParam#
		</cfquery>
	</cfif>
<cfelseif Tab Is 5>
	<cfset HowWide = 2>
	<cfquery name="GetTheAuths" datasource="#pds#">
		SELECT * 
		FROM CustomAuth 
		ORDER BY AuthDescription
	</cfquery>
	<cfquery name="GetTheEMails" datasource="#pds#">
		SELECT * 
		FROM CustomEMail 
		ORDER BY EMailDescription
	</cfquery>
	<cfquery name="GetTheFTPs" datasource="#pds#">
		SELECT * 
		FROM CustomFTP 
		ORDER BY FTPDescription 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Domain Name</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfif tab Is 1>
	<cfoutput><body #colorset# onLoad="document.info.DomainName.focus()"></cfoutput>
<cfelse>
	<cfoutput><body #colorset#></cfoutput>
</cfif>
<cfinclude template="header.cfm">
<cfoutput>
	<table>
		<tr>
			<form method="post" action="domains.cfm">
				<input type="hidden" name="page" value="#page#">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<td><input type="image" src="images/return.gif" border="0"></td>
			</form>
		</tr>
	</table>
	<center>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#perfontname#"</cfif> size="#ttsize#"><cfif OneDomain.DomainName Is Not "">#OneDomain.DomainName#<cfelse>Domain Name</cfif></font></th>
		</tr>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="domains2.cfm">
							<input type="hidden" name="Page" value="#Page#">
							<input type="hidden" name="DomainID" value="#DomainID#">
							<input type="hidden" name="Orddir" value="#Orddir#">
							<input type="hidden" name="Ordby" value="#Ordby#">
							<td bgcolor=<cfif Tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onClick="submit()" id="tab1"><label for="tab1">General</label></td>
							<cfif OneDomain.RecordCount GT 0>
								<td bgcolor=<cfif Tab Is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onClick="submit()" id="tab5"><label for="tab5">Integration</label></td>
								<td bgcolor=<cfif Tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onClick="submit()" id="tab2"><label for="tab2">Plans</label></td>
								<td bgcolor=<cfif Tab Is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onClick="submit()" id="tab3"><label for="tab3">Staff</label></td>
								<td bgcolor=<cfif Tab Is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onClick="submit()" id="tab4"><label for="tab4">Users</label></td>
							<cfelse>
								<td bgcolor="#tdclr#">Integration</td>
								<td bgcolor="#tdclr#">Plans</td>
								<td bgcolor="#tdclr#">Staff</td>
								<td bgcolor="#tdclr#">Users</td>
							</cfif>
						</form>
					</tr>
				</table>
			</th>
		</tr>
</cfoutput>
<cfif tab Is 1>
	<cfoutput>
		<form method=post name="info" action="domains2.cfm?RequestTimeout=500">
			<input type="hidden" name="page" value="#page#">
			<input type="hidden" name="orddir" value="#orddir#">
			<input type="hidden" name="ordby" value="#ordby#">
			<input type="hidden" name="DomainID" value="#DomainID#">
			<tr>
				<td align="right" bgcolor="#tbclr#">Domain Name</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomainName" value="#OneDomain.DomainName#" maxlength="75"></td> 
				<input type="hidden" name="DomainName_Required" value="Please enter the Domain Name">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Private</td>
				<td bgcolor="#tdclr#"><input <cfif OneDomain.PrivateYN Is 1>checked</cfif> type="radio" name="PrivateYN" value="1"> Yes <input <cfif OneDomain.PrivateYN Is Not 1>checked</cfif> type="radio" name="PrivateYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Account Limit<br><font size="1">(For Private Domains only.)</font></td>
				<td bgcolor="#tdclr#"><input type="text" name="AccntLimit" value="#OneDomain.AccntLimit#" maxlength="5" size="5"></td> 
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Show In Online Signup</td>
				<td bgcolor="#tdclr#"><input <cfif OneDomain.ShowYN Is 1>checked</cfif> type="radio" name="ShowYN" value="1"> Yes <input <cfif OneDomain.ShowYN Is Not 1>checked</cfif> type="radio" name="ShowYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Send Payments To</td>
				<td bgcolor="#tdclr#"><input <cfif OneDomain.UseAddr Is 1>checked</cfif> type="radio" name="UseAddr" value="1"> This Company <input <cfif OneDomain.UseAddr Is Not 1>checked</cfif> type="radio" name="UseAddr" value="0"> Default Domain Address</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Phone</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomPhone" value="#OneDomain.DomPhone#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Company Name</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomName" value="#OneDomain.DomName#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Contact</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomContact" value="#OneDomain.DomContact#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Address</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomAdd1" value="#OneDomain.DomAdd1#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Address 2</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomAdd2" value="#OneDomain.DomAdd2#" maxlength="50"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">City</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomCity" value="#OneDomain.DomCity#" maxlength="35"></td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">State/Prov</td>
	</cfoutput>	
				<cfif GetStates.RecordCount GT 0>
					<td><select name="DomState">
						<cfoutput query="GetStates">
							<option <cfif DomainID Is 0><cfif GetStates.DefState Is 1>selected</cfif><cfelse><cfif OneDomain.DomState Is Abbr>selected</cfif></cfif> value="#Abbr#">#StateName#
						</cfoutput>
					</select></td>
				<cfelse>
					<td>No Active States/Provs</td>
				</cfif>			
			</tr>
	<cfoutput>
			<tr>
				<td align="right" bgcolor="#tbclr#">Zip/Postal</td>
				<td bgcolor="#tdclr#"><input type="text" name="DomZip" value="#OneDomain.DomZip#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Authentication Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="AuthServer" value="#OneDomain.AuthServer#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Authentication Server IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="AuthServerIP" value="#OneDomain.AuthServerIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">FTP Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="FTPServer" value="#OneDomain.FTPServer#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">FTP Server IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="FTPServerIP" value="#OneDomain.FTPServerIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">E-Mail POP3 Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="POP3Server" value="#OneDomain.POP3Server#" maxlength="75"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">E-Mail POP3 Server IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="POP3ServerIP" value="#OneDomain.POP3ServerIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">E-Mail SMTP Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="EMailServer" value="#OneDomain.EMailServer#" maxlength="40"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">E-Mail SMTP Server IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="EmailServerIP" value="#OneDomain.EmailServerIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">News Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="NewsServer" value="#OneDomain.NewsServer#" maxlength="40"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">News Server IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="NewsServerIP" value="#OneDomain.NewsServerIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Website IP</td>
				<td bgcolor="#tdclr#"><input type="text" name="WebsiteIP" value="#OneDomain.WebsiteIP#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Primary DNS</td>
				<td bgcolor="#tdclr#"><input type="text" name="DNS1" value="#OneDomain.DNS1#" maxlength="20"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Secondary DNS</td>
				<td bgcolor="#tdclr#"><input type="text" name="DNS2" value="#OneDomain.DNS2#" maxlength="20"></td>
			</tr>
			<tr>
				<cfif OneDomain.RecordCount Is 0>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewDomain" border="0"></th>
				<cfelse>
					<th colspan="2"><input type="image" src="images/edit.gif" name="EditDomain" border="0"></th>
				</cfif>
			</tr>
		</cfoutput>	
		</form>
	</table>
<cfelseif tab Is 2>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Plans Available</th>
			<th>Action</th>
			<th>These Plans Have Access</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<form method="post" action="domains2.cfm">
				<input type="hidden" name="page" value="#page#">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<input type="hidden" name="DomainID" value="#DomainID#">
				<input type="hidden" name="tab" value="#tab#">
	</cfoutput>
				<td><select name="AvailPlans" multiple size="10">
					<cfoutput query="GetAvailPlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">_____________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MvRt" value="---->"><br>
					<input type="submit" name="MvLt" value="<----"><br>
				</td>
				<td><select name="SelPlans" multiple size="10">
					<cfoutput query="GetCurPlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">_____________________________
				</select></td>
			</form>
		</tr>
	</table>
<cfelseif tab Is 3>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Staff Available</th>
			<th>Action</th>
			<th>Selected Staff</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<form method="post" action="domains2.cfm">
				<input type="hidden" name="page" value="#page#">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<input type="hidden" name="DomainID" value="#DomainID#">
				<input type="hidden" name="tab" value="#tab#">
	</cfoutput>
				<td><select name="AvailAdmins" multiple size="10">
					<cfoutput query="Getwhowants">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="0">_____________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MvRt" value="---->"><br>
					<input type="submit" name="MvLt" value="<----"><br>
				</td>
				<td><select name="SelAdmins" multiple size="10">
					<cfoutput query="GetWhoHas">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="0">_____________________________
				</select></td>
			</form>
		</tr>
	</table>
<cfelseif tab Is 4>
	<cfif OneDomain.PrivateYN Is 1>
		<cfif IsDefined("LookFor.x")>
			<cfoutput>
			<form method="post" action="domains2.cfm">
				<input type="hidden" name="page" value="#page#">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<input type="hidden" name="DomainID" value="#DomainID#">
				<input type="hidden" name="tab" value="#tab#">
				<tr>
					<th bgcolor="#thclr#" colspan="2">Search criteria</th>
				</tr>
				<tr>
					<td bgcolor="#tdclr#"><select name="FirstParam">
						<option value="LastName">Last Name
						<option value="FirstName">First Name
						<option value="Company">Company
						<option value="Login">Login
					</select></td>
					<td bgcolor="#tdclr#"><select name="LogicParam">
						<option value="Starts">Starts With
						<option value="Contains">Contains
					</select></td>
				</tr>
				<tr>
					<td colspan="2" bgcolor="#tdclr#"><input type="text" name="SecondParam" size="25"></td>
				</tr>
				<tr>
					<th colspan="2"><input type="image" src="images/search.gif" name="SearchFor" border="0"></th>
				</tr>
			</form>
			</cfoutput>
		<cfelseif IsDefined("SearchFor.x")>
			<cfoutput>
				<tr>
					<form method="post" action="domains2.cfm">
						<input type="hidden" name="page" value="#page#">
						<input type="hidden" name="orddir" value="#orddir#">
						<input type="hidden" name="ordby" value="#ordby#">
						<input type="hidden" name="DomainID" value="#DomainID#">
						<input type="hidden" name="tab" value="#tab#">
						<td align="right" colspan="4"><input type="image" name="LookFor" src="images/search.gif" border="0"></td>
					</form>
				</tr>
			</cfoutput>
			<cfif LookingFor.Recordcount Is 0>
				<cfoutput>
					<tr>
						<td bgcolor="#tbclr#" colspan="4">Nothing matched your search criteria.</td>
					</tr>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<tr bgcolor="#thclr#">
						<th>Select</th>
						<th>Name</th>
						<th>Company</th>
						<th>E-Mail</th>
					</tr>
				</cfoutput>
				<form method="post" action="domains2.cfm">
					<cfoutput>
						<input type="hidden" name="page" value="#page#">
						<input type="hidden" name="orddir" value="#orddir#">
						<input type="hidden" name="ordby" value="#ordby#">
						<input type="hidden" name="DomainID" value="#DomainID#">
						<input type="hidden" name="tab" value="#tab#">
					</cfoutput>
					<cfoutput query="LookingFor">
						<tr bgcolor="#tbclr#">
							<th bgcolor="#tdclr#"><input type="checkbox" name="AccountID" value="#AccountID#"></th>
							<td>#LastName#, #FirstName#</td>
							<td><cfif Trim(Company) Is "">&nbsp;<cfelse>#Company#</cfif></td>
							<td><cfif Trim(EMail) Is "">&nbsp;<cfelse>#EMail#</cfif></td>
						</tr>
					</cfoutput>
					<tr>
						<th colspan="4"><input type="image" name="AddThese" src="images/Add.gif" border="0"></th>
					</tr>
				</form>
			</cfif>
		<cfelse>
			<cfoutput>
			<form method="post" action="domains2.cfm">
				<tr>
					<td align="right" colspan="2"><input type="image" src="images/search.gif" name="LookFor" border="0"></td>
				</tr>
				<tr bgcolor="#thclr#">
					<th>Remove</th>
					<th>Selected Customers</th>
				</tr>
				<tr bgcolor="#tdclr#">
					<input type="hidden" name="page" value="#page#">
					<input type="hidden" name="orddir" value="#orddir#">
					<input type="hidden" name="ordby" value="#ordby#">
					<input type="hidden" name="DomainID" value="#DomainID#">
					<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
					<td align="center" valign="middle">
						<input type="submit" name="MvLt" value="<----"><br>
					</td>
					<td><select name="SelAccounts" multiple size="10">
						<cfoutput query="GetWhoHas">
							<option value="#AccountID#">#LastName#, #FirstName# - #Company#
						</cfoutput>
						<option value="0">_____________________________
					</select></td>
				</form>
			</tr>
			<tr>
				<cfoutput>
					<td bgcolor="#tbclr#" colspan="2">Only the selected customers will be able to see this domain.</td>
				</cfoutput>
			</tr>
		</cfif>	
	<cfelse>
		<cfoutput>
			<tr>
				<td colspan="2" bgcolor="#tbclr#">This feature is only for domains set as private.<br>  
				Setting a domain as private hides it from everyone in the Customer area<br> except those you specifically select to have access.</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>
<cfelseif Tab Is 5>
	<cfoutput>
		<form method="post" action="domains2.cfm">
				<input type="hidden" name="page" value="#page#">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<input type="hidden" name="DomainID" value="#DomainID#">
				<input type="hidden" name="tab" value="#tab#">
			<tr bgcolor="#thclr#">
				<th colspan="#HowWide#">Select the Integration Setups to use for this Domain</th>
			</tr>
	</cfoutput>
			<cfif GetTheAuths.RecordCount Is 0>
				<tr>
					<cfoutput>
						<td bgcolor="#tbclr#" colspan="#HowWide#">Please setup the <a href="customauthsetup.cfm">Custom Auths</a> before proceeding.</td>
					</cfoutput>
				</tr>
			<cfelse>
				<cfoutput>
				<tr bgcolor="#tdclr#">
					<td align="right" bgcolor="#tbclr#">Authentication</td>
				</cfoutput>
					<td><select name="AvailAuths">
						<cfoutput query="GetTheAuths">
							<option <cfif CAuthID Is OneDomain.CAuthID>selected</cfif> value="#CAuthID#">#AuthDescription#
						</cfoutput>
						<cfif (OneDomain.CAuthID Is "") OR (OneDomain.CAuthID Is 0)><option selected value="">Please Select the Correct Auth setup for this domain</cfif>
					</select></td>
				</tr>
			</cfif>
			<cfif GetTheEMails.RecordCount Is 0>
				<tr>
					<cfoutput>
						<td bgcolor="#tbclr#" colspan="#HowWide#">Please setup the <a href="customemail.cfm">Custom Emails</a> before proceeding.</td>
					</cfoutput>
				</tr>
			<cfelse>
				<cfoutput>
				<tr bgcolor="#tdclr#">
					<td align="right" bgcolor="#tbclr#">EMail</td>
				</cfoutput>	
					<td><select name="AvailEMails">
					<cfoutput query="GetTheEMails">
						<option <cfif CEMailID Is OneDomain.CEmailID>selected</cfif> value="#CEMailID#">#EMailDescription#
					</cfoutput>
					<cfif (OneDomain.CEmailID Is "") OR (OneDomain.CEmailID Is 0)><option selected value="">Please Select the Correct EMail setup for this domain</cfif>
				</select></td>
				</tr>
			</cfif>
			<cfif GetTheFTPs.RecordCount Is 0>
				<tr>
					<cfoutput>
						<td bgcolor="#tbclr#" colspan="#HowWide#">Please setup the <a href="customftp.cfm">Custom FTPs</a> before proceeding.</td>
					</cfoutput>
				</tr>
			<cfelse>
				<cfoutput>
				<tr bgcolor="#tdclr#">
					<td align="right" bgcolor="#tbclr#">FTP</td>
				</cfoutput>	
					<td><select name="AvailFTPs">
					<cfoutput query="GetTheFTPs">
						<option <cfif CFTPID Is OneDomain.CFTPID>selected</cfif> value="#CFTPID#">#FTPDescription#
					</cfoutput>
					<cfif (OneDomain.CFTPID Is "") OR (OneDomain.CFTPID Is 0)><option selected value="">Please Select the Correct FTP setup for this domain</cfif>
				</select></td>
				</tr>
			</cfif>
			<tr>
				<cfoutput>
					<th colspan="#HowWide#"><input type="Image" name="SetInt" src="images/edit.gif" border="0"></th>
				</cfoutput>
			</tr>
		</form>
	</table>
</cfif>
</center>
<cfinclude template="footer.cfm">
</body>
</html>




