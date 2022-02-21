<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page deactivates an account. It needs accountid. 
It runs as cfinclude but functions like a custom tag. --->
<!---	4.0.0 04/22/00 --->
<!--- cfdeactivate.cfm --->

<!--- Get Account Info --->
<cfset TheAccountID = SendAccountID>
<cfparam name="LocAccntPlanID" default="0">
<cfquery name="AllAccounts" datasource="#pds#">
	SELECT * 
	FROM AccntPlans 
	WHERE AccountID = #TheAccountID# 
	<cfif LocAccntPlanID GT 0>
		AND AccntPlanID = #LocAccntPlanID# 
	</cfif>
</cfquery>
<cfquery name="PlanInfo" datasource="#pds#">
	SELECT DeactPassWord 
	FROM Plans 
	WHERE PlanID = #AllAccounts.PlanID#
</cfquery>
<cfset strChar1 = RandRange(33,126)>
<cfset strChar2 = RandRange(33,126)>
<cfset strChar3 = RandRange(33,126)>
<cfset strChar4 = RandRange(33,126)>
<cfset strChar5 = RandRange(33,126)>
<cfset DeactivatedPassword = PlanInfo.DeactPassWord & "ID!#TheAccountID#!" & "#Chr(strChar5)##Chr(strChar4)##Chr(strChar3)##Chr(strChar2)##Chr(strChar1)#">
<cfloop query="AllAccounts">
	<!--- Get all Auth accounts and run scripts --->
	<cfset CarryTheID = POPID>
	<cfquery name="MyAuthAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AccountID = #TheAccountID#  
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
	</cfquery>
	<cfloop query="MyAuthAccounts">
		<!--- Run Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfdeactivate.cfm' 
			AND L.LocationAction = 'Change' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'Auth') 
		</cfquery>		
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocAuthID = AuthID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<cfif FileExists(ExpandPath("external#OSType#extchangeauth.cfm"))>
			<cfset SendID = AuthID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extchangeauth.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
	</cfloop>
	<!--- Get all FTP accounts and run scripts --->
	<cfquery name="MyFTPAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsFTP 
		WHERE AccountID = #TheAccountID#  
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
	</cfquery>
	<cfloop query="MyFTPAccounts">
		<cfquery name="DelData" datasource="#pds#">
			UPDATE AccountsFTP SET 
			OldPassword = Password, 
			Password = '#DeactivatedPassword#' 
			WHERE FTPID = #FTPID# 
		</cfquery>
		<!--- Run Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfdeactivate.cfm' 
			AND L.LocationAction = 'Change' 
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
		<cfif FileExists(ExpandPath("external#OSType#extchangeftp.cfm"))>
			<cfset SendID = FTPID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extchangeftp.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
	</cfloop>
	<!--- Get all EMail accounts and run scripts --->
	<cfquery name="AllEmails" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE AccountID = #AccountID# 
		<cfif LocAccntPlanID GT 0>
			AND AccntPlanID = #LocAccntPlanID# 
		</cfif>
		ORDER BY Alias Desc
	</cfquery>
	<cfloop query="AllEMails">
		<cfquery name="DelData" datasource="#pds#">
			UPDATE AccountsEMail SET 
			OldPassword = EPass, 
			EPass = '#DeactivatedPassword#' 
			WHERE EMailID = #EMailID# 
		</cfquery>
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfdeactivate.cfm' 
			AND L.LocationAction = 'Change' 
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
		<cfif FileExists(ExpandPath("external#OSType#extchangeemail.cfm"))>
			<cfset SendID = EMailID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extchangeemail.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
	</cfloop>
	<!--- Update AccntPlan --->
	<cfquery name="RemovePlan" datasource="#pds#">
		UPDATE AccntPlans SET 
		ReactivateTo = PlanID, 
		PlanID = #DeactAccount# 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif FileExists("#dirpathway#external#OSType#canaccnt.cfm")>
		<cfinclude template="external#OSType#deactaccnt.cfm">
	</cfif>
 </cfloop>

<!--- Update Accounts table --->
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccntPlanID 
	FROM AccntPlans 
	WHERE AccountID = #TheAccountID# 
	AND PlanID <> #DeactAccount# 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfset TheCancelReason = "">
	<cfif IsDefined("LocReason")>
		<cfset TheCancelReason = TheCancelReason & LocReason>
	<cfelse>
		<cfset TheCancelReason = TheCancelReason & "Account was deactivated.">
	</cfif>
	<cfif IsDefined("LocScheduledBy")>
		<cfset TheCancelReason = TheCancelReason & " Scheduled by #LocScheduledBy#.">
	<cfelse>
		<cfset TheCancelReason = TheCancelReason & " Deactivated #DateFormat(Now(), '#DateMask1#')#">
	</cfif>
	<cfquery name="UpdateAccountsTable" datasource="#pds#">
		UPDATE Accounts SET 
		OldPassword = Password, 
		Password = '#DeactivatedPassword#', 
		DeactivatedYN = 1, 
		DeactDate = #Now()#, 
		DeactReason = '#TheCancelReason#' 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="UpdateTheStatus" datasource="#pds#">
		UPDATE AccntPlans SET 
		AccntStatus = 1, 
		DeactDate = #Now()#, 
		DeactReason = '#TheCancelReason#'
		WHERE AccountID = #AccountID# 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="No">
 