<!--- Version 4.0.0 --->
<!--- This page reactivates an account. It needs accountid. 
It runs as cfinclude but functions like a custom tag. --->
<!---	4.0.0 04/20/00 --->
<!--- cfreactivate.cfm --->

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
		<cfset NewPassword = OldPassword>
		<cfquery name="RemoveAuth" datasource="#pds#">
			UPDATE AccountsAuth 
			SET Password = OldPassword, 
			OldPassword = Null 
			WHERE AuthID = #AuthID# 
		</cfquery>
		<!--- Run Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfreactivate.cfm' 
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
			Password = OldPassword, 
			OldPassword = Null  
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
			AND L.PageName = 'cfreactivate.cfm' 
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
		<cfif IsDefined("LocAccntPlanID")>
			<cfif LocAccntPlanID GT 0>
				AND AccntPlanID = #LocAccntPlanID# 
			</cfif>
		</cfif>
		ORDER BY Alias Desc
	</cfquery>
	<cfloop query="AllEMails">
		<cfquery name="DelData" datasource="#pds#">
			UPDATE AccountsEMail SET 
			EPass = OldPassword, 
			OldPassword = Null 
			WHERE EMailID = #EMailID# 
		</cfquery>
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfreactivate.cfm' 
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
	<cfquery name="RemovePlan" datasource="#pds#">
		UPDATE AccntPlans SET 
		PlanID = ReactivateTo, 
		DeactDate = Null, 
		AccntStatus = 0, 
		DeactReason = Null 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif FileExists("#dirpathway#external#OSType#reactaccnt.cfm")>
		<cfinclude template="external/reactaccnt.cfm">
	</cfif>
</cfloop>
<!--- Update Accounts table --->
<cfquery name="UpdateAccountsTable" datasource="#pds#">
	UPDATE Accounts SET 
	Password = OldPassword, 
	DeactivatedYN = 0, 
	DeactDate = Null, 
	DeactReason = Null, 
	OldPassword = Null 
	WHERE AccountID = #AccountID# 
</cfquery>

<cfsetting enablecfoutputonly="No">
 