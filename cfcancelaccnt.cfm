<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 --->
<!--- cfcancelaccnt.cfm --->
<!--- 
This is now called as a Custom Tag.
Attrributes
AccountID - The accountid of the person to be cancelled.
AccntPlanID - The accounts to be cancelled.  If 0 then all for the accountID are cancelled.
CancelReason - The reason for the cancel.
DeleteHist - If 1 Then delete calls history. If 0 then save history.
ScheduledBy - The admin that scheduled this event.
IntLocation - The page calling cfcancelaccnt.cfm
--->
<cfset pds = caller.pds>
<cfset AccountID = Attributes.AccountID>
<cfset AccntPlanID = Attributes.AccntPlanID>
<cfset IntLocation = Attributes.IntLocation>
<cfset CancelReason = Attributes.CancelReason>
<cfset ScheduledBy = Attributes.ScheduledBy>
<cfif IsDefined("Attributes.DeleteHist")>
	<cfset DeleteHist = Attributes.DeleteHist>
<cfelse>
	<cfset DeleteHist = 1>
</cfif>

<cfquery name="GetWho" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID#
</cfquery>
<cfquery name="GetAccntPlans" datasource="#pds#">
	SELECT * 
	FROM AccntPlans 
	WHERE AccountID = #AccountID#
	<cfif AccntPlanID GT 0>
		AND AccntPlanID = #AccntPlanID# 
	</cfif>
</cfquery>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<!--- Loop on all the plans to be cancelled --->
<cfloop query="GetAccntPlans">
	<!--- Get the Auth accounts for this plan --->
	<cfquery name="AllAuthAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfquery name="SeeAuthScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = '#IntLocation#' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
	 		 WHERE TypeStr = 'Authentication' 
			 ) 
		<cfif AccntPlanID Is Not 0>
			AND I.IntID IN 
				(SELECT IntID 
				 FROM IntPlans 
				 WHERE PlanID = 
				 	(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#)
				)
		</cfif>
	</cfquery>
	<cfloop query="AllAuthAccounts">
		<!--- Get the Custom Auth Values for this Auth --->
		<cfquery name="CheckDS" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'AccntODBC' 
			AND ActiveYN = 1 
			AND CAuthID = #CAuthID# 
			AND DBType = 'Ds' 
		</cfquery>
		<cfquery name="GetUserNameCreate" datasource="#pds#">
			SELECT DataNeed 
			FROM CustomAuthAccount 
			WHERE CAuthID = #CAuthID# 
			AND DBFieldName = 
				(SELECT DBName 
				 FROM CustomAuthSetup 
				 WHERE CAuthID = #CAuthID# 
				 AND BOBName = 'AccntLogin' 
				 AND ActiveYN = 1 )
		</cfquery>
		<cf_cfvarvalues Type="Authentication" ID="#AuthID#" AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
		 Locale="#Locale#" DateMask1="#DateMask1#">
		<cfset locUserName = ReplaceList(GetUserNameCreate.DataNeed,FindList,ReplList)>
		<cfif CheckDS.DBName Is NOT "">
			<cfquery name="CheckTb" datasource="#pds#">
				SELECT DBName 
				FROM CustomAuthSetup 
				WHERE BOBName = 'Accounts' 
				AND ActiveYN = 1 
				AND CAuthID = #CAuthID# 
				AND DBType = 'Tb' 
			</cfquery>
			<cfif CheckTb.DBName Is NOT "">
				<cfquery name="CheckFd" datasource="#pds#">
					SELECT DBName 
					FROM CustomAuthSetup 
					WHERE BOBName = 'AccntLogin' 
					AND ActiveYN = 1 
					AND CAuthID = #CAuthID# 
					AND DBType = 'Fd' 
				</cfquery>
				<cfif CheckFd.DBName Is NOT "">
					<cfset TheDataS = CheckDS.DBName>
					<cfset TheTable = CheckTb.DBName>
					<cfset TheUname = CheckFd.DBName>
					<cfquery name="AuthDelete" datasource="#TheDataS#">
						DELETE FROM #TheTable# 
						WHERE #TheUname# = '#locUserName#'				
					</cfquery>
				</cfif>
			</cfif>
			<cfif DeleteHist Is 1>
				<cfquery name="CheckTb2" datasource="#pds#">
					SELECT DBName 
					FROM CustomAuthSetup 
					WHERE BOBName = 'tbcalls' 
					AND ActiveYN = 1 
					AND CAuthID = #CAuthID# 
					AND DBType = 'Tb' 
				</cfquery>
				<cfif CheckTb.DBName Is NOT "">
					<cfquery name="CheckFd2" datasource="#pds#">
						SELECT DBName 
						FROM CustomAuthSetup 
						WHERE BOBName = 'CallsLogin' 
						AND ActiveYN = 1 
						AND CAuthID = #CAuthID# 
						AND DBType = 'Fd' 
					</cfquery>
					<cfif CheckFd2.DBName Is NOT "">
						<cfset TheDataS = CheckDS.DBName>
						<cfset TheTable = CheckTb2.DBName>
						<cfset TheUname = CheckFd2.DBName>
						<!--- Schedule Calls CleanUP --->
						<!--- BillMethod - 1 = Delete from the calls history; 2 = Update username to username-Cancelled-Date --->
						<cfquery name="InsAutoRun" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, Value1, Value2, EMailFrom, 
							 BillMethod, EMailSubject, AccountID, EMailTo)
							VALUES 
							(#CreateODBCDateTime(Now())#, 'RadiusCleanUp', '#TheDataS#', '#TheTable#', '#TheUname#', 
							 1, '#locUserName#', #AccountID#, '#locUserName#')
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<!--- Run Authentication Delete Scripts --->
		<cfif SeeAuthScripts.RecordCount gt 0>
			<cf_cfrunscripts type="Authentication" location="#IntLocation#" id="#AuthID#" action="Delete" 
			 FindList="#FindList#" ReplList="#ReplList#" AccntPlanID="#AccntPlanID#">
		</cfif>
		<!--- Delete From AccountsAuth ---> 
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AccountsAuth 
			WHERE AuthID = #AuthID# 
		</cfquery>
	</cfloop>
	<!--- Get All FTP Accounts --->
	<cfquery name="AllFTPs" datasource="#pds#">
		SELECT * 
		FROM AccountsFTP 
		WHERE AccountID = #AccountID#  
		<cfif AccntPlanID GT 0>
			AND AccntPlanID = #AccntPlanID# 
		</cfif>
	</cfquery>
	<cfquery name="SeeFTPScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = '#IntLocation#' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
	 		 WHERE TypeStr = 'FTP' 
			 ) 
		<cfif AccntPlanID Is Not 0>
			AND I.IntID IN 
				(SELECT IntID 
				 FROM IntPlans 
				 WHERE PlanID = 
				 	(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#)
				)
		</cfif>
	</cfquery>
	<cfif SeeFTPScripts.RecordCount gt 0>
		<cfloop query="AllFTPs">
			<!--- Run Delete FTP Scripts --->
			<cf_cfvarvalues Type="FTP" ID="#FTPID#" AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
			 Locale="#Locale#" DateMask1="#DateMask1#">
			<cf_cfrunscripts type="FTP" location="#IntLocation#" id="#FTPID#" action="Delete" 
			 FindList="#FindList#" ReplList="#ReplList#">
			<cfquery name="CleanUpFTP" datasource="#pds#">
				DELETE FROM AccountsFTP 
				WHERE FTPID = #FTPID# 
			</cfquery>
		</cfloop>
	<cfelse>
		<cfquery name="RemoveFTPs" datasource="#pds#">
			DELETE FROM AccountsFTP 
			WHERE AccountID = #AccountID#  
			<cfif AccntPlanID GT 0>
				AND AccntPlanID = #AccntPlanID# 
			</cfif>
		</cfquery>
	</cfif>
	<!--- Get All EMails --->
	<cfquery name="SeeEMailScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = '#IntLocation#' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
	 		 WHERE TypeStr In ('EMail','Alias')
			 ) 
		<cfif AccntPlanID Is Not 0>
			AND I.IntID IN 
				(SELECT IntID 
				 FROM IntPlans 
				 WHERE PlanID = 
				 	(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#)
				)
		</cfif>
	</cfquery>
	<cfquery name="AllEMails" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE AccountID = #AccountID# 
		<cfif AccntPlanID GT 0>
			AND AccntPlanID = #AccntPlanID# 
		</cfif>
		AND ContactYN = 0 
		AND Alias = 0 
	</cfquery>
	<cfif SeeEMailScripts.RecordCount gt 0>
		<cfloop query="AllEMails">
			<cfquery name="ThisAlias" datasource="#pds#">
				SELECT * 
				FROM AccountsEMail 
				WHERE Alias = 1 
				AND AliasTo = #EMailID# 
			</cfquery>
			<cfloop query="ThisAlias">
				<cf_cfvarvalues Type="Alias" ID="#EMailID#" AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
				 Locale="#Locale#" DateMask1="#DateMask1#">
				<cf_cfrunscripts type="Alias" location="#IntLocation#" id="#EMailID#" action="Delete" 
				 FindList="#FindList#" ReplList="#ReplList#">
				<cfquery name="AliasCleanUp" datasource="#pds#">
					DELETE FROM AccountsEMail 
					WHERE EMailID = #EMailID#
				</cfquery>
			</cfloop>
				<cf_cfvarvalues Type="EMail" ID="#EMailID#" AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
				 Locale="#Locale#" DateMask1="#DateMask1#">
				<cf_cfrunscripts type="EMail" location="#IntLocation#" id="#EMailID#" action="Delete" 
				 FindList="#FindList#" ReplList="#ReplList#">
				<cfquery name="EMailCleanUP" datasource="#pds#">
					DELETE FROM AccountsEMail 
					WHERE EMailID = #EMailID#
				</cfquery>
		</cfloop>
	</cfif>
	<!--- Run Misc Scripts --->
	<cfquery name="SeeMiscScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = '#IntLocation#' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
	 		 WHERE TypeStr = 'Misc'
			 ) 
		<cfif AccntPlanID Is Not 0>
			AND I.IntID IN 
				(SELECT IntID 
				 FROM IntPlans 
				 WHERE PlanID = 
				 	(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#)
				)
		</cfif>
	</cfquery>
	<cfif SeeMiscScripts.RecordCount GT 0>
		<cf_cfvarvalues Type="Misc" ID="0" AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
		 Locale="#Locale#" DateMask1="#DateMask1#">
		<cf_cfrunscripts type="Misc" location="#IntLocation#" id="0" action="Delete" 
		 FindList="#FindList#" ReplList="#ReplList#" accountid="#AccountID#" accntplanid="#AccntPlanID#">
	</cfif>
	<cfquery name="IfLast" datasource="#pds#">
		SELECT * 
		FROM AccntPlans 
		WHERE AccntPlanID = #AccntPlanID#
	</cfquery>
	<cfquery name="AccntPlanCleanUp" datasource="#pds#">
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
	<!--- Remove the Contact EMails --->
	<cfquery name="CleanUp8" datasource="#pds#">
		DELETE FROM AccountsEMail 
		WHERE AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif FileExists("#caller.dirpathway#external#caller.OSType#canaccnt.cfm")>
		<cfinclude template="external#OSType#canaccnt.cfm">
	</cfif>
</cfloop>
<!--- If cancelled all then add back the cancelled plan --->

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccntPlanID 
	FROM AccntPlans 
	WHERE AccountID = #AccountID#
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="PrmaryDomain" datasource="#pds#">
		SELECT DomainID 
		FROM Domains 
		WHERE Primary1 = 1 
	</cfquery>
	<cfquery name="AddCancelPlan" datasource="#pds#">
		INSERT INTO AccntPlans 
		(AccountID, PlanID, AccntStatus, POPID, BillingStatus, AuthDomainID, 
		 StartDate, PayBy, PostalRem, TaxAble) 
		VALUES
		(#AccountID#, #caller.DelAccount#, 1, #IfLast.POPID#, 0, #PrmaryDomain.DomainID#, 
		 <cfif IfLast.StartDate Is "">Null<cfelse>#CreateODBCDateTime(IfLast.StartDate)#</cfif>, 
		 '#IfLast.PayBy#', #IfLast.PostalRem#, #IfLast.TaxAble#) 
	</cfquery>

	<cfif IsDefined("CancelReason")>
		<cfset TheCancelReason = CancelReason>
	<cfelse>
		<cfset TheCancelReason = "Account was cancelled.">
	</cfif>
	<cfif IsDefined("ScheduledBy")>
		<cfset TheCancelReason = TheCancelReason>
	<cfelse>
		<cfset TheCancelReason = TheCancelReason>
	</cfif>
	<cfquery name="UpdateAccountsTable" datasource="#pds#">
		UPDATE Accounts SET 
		Login = Login, 
		CancelYN = 1, 
		CancelDate = #Now()#, 
		CancelReason = '#TheCancelReason#' 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="CleanUp1" datasource="#pds#">
		UPDATE GrpLists SET 
		AccntPlanID = 1 
		WHERE AccountID = #AccountID# 
		AND ReportID = 4 
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
</cfif>
<cfsetting enablecfoutputonly="No">
