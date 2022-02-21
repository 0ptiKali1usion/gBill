<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.2 01/29/01 Fixed an error pointing a cancelled account to the deactivated plan.
		4.0.1 01/18/01 Fixed a date format error in query AddPlan
		4.0.0	03/12/00 --->
<!--- CFcancel.cfm --->
<!--- Get Account Info --->
<!--- 
SendAccountID - The accountid of the person to be cancelled.
SendLogin - The loginname from Accounts table to be cancelled.
LocAccntPlanID - The accounts to be cancelled.  If 0 then all for the accountid are cancelled.
LocReason - The reason.
LocDelete - If 1 Then delete calls history. If 0 then save history.
LocScheduledBy - The admin that scheduled this event.
--->
<!--- Check for entire account or individual --->
<cfparam name="LocDelete" default="1">
<cfparam name="LocAccntPlanID" default="0">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfquery name="GetID" datasource="#pds#">
	SELECT AccountID, Login 
	FROM Accounts 
	<cfif IsDefined("SendLogin")>
		WHERE Login = '#SendLogin#'
	<cfelse>
		WHERE AccountID = #SendAccountID# 
	</cfif>
</cfquery>
<cfset NewLoginName = GetID.Login>
<cfset TheAccountID = GetID.AccountID>
<cfquery name="AllAccounts" datasource="#pds#">
	SELECT * 
	FROM AccntPlans 
	WHERE AccountID = #GetID.AccountID# 
	<cfif LocAccntPlanID GT 0>
		AND AccntPlanID = #LocAccntPlanID# 
	</cfif>
</cfquery>
<cfloop query="AllAccounts">
	<!--- Get all Auth accounts and run scripts --->
	<cfset CarryTheID = POPID>
	<cfquery name="MyAuthAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AccountID = #TheAccountID#  
		<cfif IsDefined("DelAuthIDs")>
			AND AuthID In (#DelAuthIDs#) 
		</cfif>
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
	</cfquery>
	<cfloop query="MyAuthAccounts">
		<cfquery name="MyGetAuthDetails" datasource="#pds#">
			SELECT C.DBName, C.CAuthID, A.AuthDescription 
			FROM CustomAuthSetup C, CustomAuth A 
			WHERE C.CAuthID = A.CAuthID 
			AND C.BOBName = 'accntodbc' 
			AND A.CAuthID = 
				(SELECT CAuthID 
				 FROM Domains 
				 WHERE DomainID = 
				 	(SELECT DomainID 
					 FROM AccountsAuth 
					 WHERE AuthID = #AuthID#)
				)
		</cfquery>
		<cfif MyGetAuthDetails.CAuthID Is "">
			<cfset CAuthID = 0>
		<cfelse>
			<cfset CAuthID = MyGetAuthDetails.CAuthID>
		</cfif>
		<cfset AuthODBC = MyGetAuthDetails.DBName>
		<cfquery name="GetTBName" datasource="#pds#">
			SELECT DBName, CRSID 
			FROM CustomAuthSetup 
			WHERE BOBName = 'tbcalls' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetUserName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'callslogin' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetSessName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'acntsestime' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetDateName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'calldatetime' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfif GetDateName.DBName Is "">
			<cfquery name="GetDateName" datasource="#pds#">
				SELECT DBName 
				FROM CustomAuthSetup 
				WHERE BOBName = 'calldate' 
				AND CAuthID = #CAuthID#
			</cfquery>			
		</cfif>
		<cfif (GetTBName.DBName is not "") AND (GetUserName.DBName is not "")
   	 AND (GetSessName.DBName is not "") AND (GetDateName.DBName is not "")>
			<cfset LocDatasource = MyGetAuthDetails.DBName>
			<cfset LocTableName = GetTBName.DBName>
			<cfset LocFieldName = GetUserName.DBName>
			<cfif LocDelete Is "">
				<cfset LocDelete = 0>
			</cfif>
			<cfquery name="InsAutoRun" datasource="#pds#">
				INSERT INTO AutoRun 
				(WhenRun, DoAction, Value1, Value2, EMailFrom, 
				 BillMethod, EMailSubject, AccountID, EMailTo)
				VALUES 
				(#CreateODBCDateTime(Now())#, 'RadiusCleanUp', '#LocDatasource#', '#LocTableName#', '#LocFieldName#', 
				 #LocDelete#, '#UserName#', #AccountID#, '#NewLoginName#')
			</cfquery>
		</cfif>
		<!--- Remove From Radius Table --->		
		<cfquery name="GetMyAuthDetails" datasource="#pds#">
			SELECT C.DBName, C.CAuthID, A.AuthDescription 
			FROM CustomAuthSetup C, CustomAuth A 
			WHERE C.CAuthID = A.CAuthID 
			AND C.BOBName = 'authodbc' 
			AND A.CAuthID = 
				(SELECT CAuthID 
				 FROM Domains 
				 WHERE DomainID = 
				 	(SELECT DomainID 
					 FROM AccountsAuth 
					 WHERE AuthID = #AuthID#)
				)
		</cfquery>
		<cfif GetMyAuthDetails.CAuthID Is "">
			<cfset CAuthID = 0>
		<cfelse>
			<cfset CAuthID = GetMyAuthDetails.CAuthID>
		</cfif>
		<cfquery name="GetTableName" datasource="#pds#">
			SELECT DBName, CRSID 
			FROM CustomAuthSetup 
			WHERE BOBName = 'accounts' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetLoginName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'accntlogin' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetPassWord" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'acntpassword' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfif (GetTableName.DBName is not "") AND (GetLoginName.DBName is not "")
   	 AND (GetMyAuthDetails.DBName is not "")>
			<cfset LocDatasource = GetMyAuthDetails.DBName>
			<cfset LocTableName = GetTableName.DBName>
			<cfset LocFieldName = GetLoginName.DBName>
			<cfset LocPassField = GetPassWord.DBName>
			<cfquery name="SetNewPassword" datasource="#LocDatasource#">
				DELETE FROM #LocTableName# 
				WHERE #LocFieldName# = '#Username#'				
			</cfquery>
		</cfif>
		<!--- Run Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfcancel.cfm' 
			AND L.LocationAction = 'Delete' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'Authentication') 
		</cfquery>		
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocAuthID = AuthID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfif FileExists(ExpandPath("external#OSType#extdeleteauth.cfm"))>
			<cfset SendID = AuthID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extdeleteauth.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfquery name="RemoveAuth" datasource="#pds#">
			DELETE FROM AccountsAuth 
			WHERE AuthID = #AuthID# 
		</cfquery>
	</cfloop>
	<!--- Get all FTP accounts and run scripts --->
	<cfquery name="MyFTPAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsFTP 
		WHERE AccountID = #TheAccountID#  
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
		<cfif IsDefined("DelFTPIDs")>
			AND FTPID In (#DelFTPIDs#) 
		</cfif>
	</cfquery>
	<cfloop query="MyFTPAccounts">
		<!--- Run Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfcancel.cfm' 
			AND L.LocationAction = 'Delete' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'FTP') 
		</cfquery>
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocFTPID = FTPID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfif FileExists(ExpandPath("external#OSType#extdeleteftp.cfm"))>
			<cfset SendID = FTPID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extdeleteftp.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM AccountsFTP 
			WHERE FTPID = #FTPID# 
		</cfquery>
	</cfloop>
	<!--- Get all EMail accounts and run scripts --->
	<cfquery name="AllEmails" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE AccountID = #AccountID# 
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
		<cfif IsDefined("DelEMailIDs")>
			AND EMailID In (#DelEMailIDs#) 
		</cfif>		
		ORDER BY Alias Desc
	</cfquery>
	<cfloop query="AllEMails">
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfcancel.cfm' 
			AND L.LocationAction = 'Delete' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 <cfif AllEmails.Alias Is 1>
			 		WHERE TypeStr = 'EMail Alias' 
				 <cfelse>
				 	WHERE TypeStr = 'EMail'
				 </cfif>
				 ) 
		</cfquery>
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocEMailID = EMailID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extdeleteemail.cfm"))>
			<cfset SendID = EMailID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extdeleteemail.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM AccountsEMail 
			WHERE EMailID = #EMailID# 
		</cfquery>
	</cfloop>
	<!--- Delete AccntPlan --->
	<cfquery name="RemovePlan" datasource="#pds#">
		DELETE FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM IPADMail 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp2" datasource="#pds#">
		DELETE FROM MassActions 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp3" datasource="#pds#">
		DELETE FROM PayByCC 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp4" datasource="#pds#">
		DELETE FROM PayByCD 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp5" datasource="#pds#">
		DELETE FROM PayByCK 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp6" datasource="#pds#">
		DELETE FROM PayByPO 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="CleanUp7" datasource="#pds#">
		DELETE FROM TempDebit 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif FileExists("#dirpathway#external#OSType#canaccnt.cfm")>
		<cfinclude template="external#OSType#canaccnt.cfm">
	</cfif>
</cfloop>
<!--- Update Accounts table --->
<cfif LocAccntPlanID Is 0>
	<cfset TheCancelReason = MemoReason>
	<cfif IsDefined("LocReason")>
		<cfset TheCancelReason = MemoReason>
	<cfelse>
		<cfset TheCancelReason = MemoReason>
	</cfif>
	<cfif IsDefined("LocScheduledBy")>
		<cfset TheCancelReason = MemoReason>
	<cfelse>
		<cfset TheCancelReason = MemoReason>
	</cfif>
	<cfquery name="UpdateAccountsTable" datasource="#pds#">
		UPDATE Accounts SET 
		Login = '#NewLoginName#',
		CancelYN = 1, 
		CancelDate = #Now()#, 
		CancelReason = '#TheCancelReason#' 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="FollowUp2" datasource="#pds#">
		DELETE FROM Multi 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="FollowUp3" datasource="#pds#">
		DELETE FROM TimeStore 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="FollowUp4" datasource="#pds#">
		DELETE FROM TimeTemp 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="GetAnID" datasource="#pds#">
		SELECT POPID 
		FROM POPs 
		WHERE DefPOP = 1 
	</cfquery>
	<cfparam name="CarryTheID" default="#GetAnID.POPID#">
	<cfquery name="PrmaryDomain" datasource="#pds#">
		SELECT DomainID 
		FROM Domains 
		WHERE Primary1 = 1 
	</cfquery>
	<cfquery name="AddPlan" datasource="#pds#">
		INSERT INTO AccntPlans 
		(AccountID, PlanID, AccntStatus, POPID, BillingStatus, AuthDomainID) 
		VALUES 
		(#AccountID#, #DelAccount#, 1, #CarryTheID#, 0, #PrmaryDomain.DomainID#)
	</cfquery>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccntPlanID 
	FROM AccntPlans 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="PrmaryDomain" datasource="#pds#">
		SELECT DomainID 
		FROM Domains 
		WHERE Primary1 = 1 
	</cfquery>
	<cfquery name="CancelledAccntInfo" datasource="#pds#">
		SELECT StartDate 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="AddPlan" datasource="#pds#">
		INSERT INTO AccntPlans 
		(AccountID, PlanID, AccntStatus, POPID, BillingStatus, AuthDomainID, 
		 StartDate, PayBy, PostalRem) 
		VALUES 
		(#AccountID#, #DelAccount#, 1, #CarryTheID#, 0, #PrmaryDomain.DomainID#, 
		 <cfif CancelledAccntInfo.StartDate Is "">Null<cfelse>#CreateODBCDateTime(CancelledAccntInfo.StartDate)#</cfif>, 
		 'ck', 0) 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="No">
 