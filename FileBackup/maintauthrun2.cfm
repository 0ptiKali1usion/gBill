<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 03/14/00 --->
<!--- maintauthrun2.cfm --->

<!--- Select those whose time left is less than time warning and email date is null --->
<cfquery name="GetWarnings" datasource="#pds#">
	SELECT AA.AccntPlanID, AA.AuthID 
	FROM AccountsAuth AA 
	WHERE AA.EmailedYN = 0 
	AND AA.SecondsLeft < AA.EMailSecsLeft 
	AND AA.WarningAction > 0 
</cfquery>

<cfloop query="GetWarnings">
	<!--- Get email address and letterid --->
	<cfquery name="CustInfo" datasource="#pds#">
		SELECT EmailID, AccountID, EMail  
		FROM AccountsEMail 
		WHERE PREMail = 1 
		AND AccntPlanID = #AccntPlanID# 
	</cfquery>
	<cfif CustInfo.Recordcount GT 0>
		<cfquery name="GetLetter" datasource="#pds#">
			SELECT IntID, EMailMessage, EMailFrom, EMailSubject, EMailRepeatMsg, EMailServer, 
			EMailServerPort, EMailCC, EMailFile  
			FROM Integration 
			WHERE IntID = 
				(SELECT WarningLetterID 
				 FROM Plans 
				 WHERE PlanID = 
				 	(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#)
				)
		</cfquery>
		<cfif GetLetter.Recordcount GT 0>
			<!--- Run the Values pages --->
			<cfset LocScriptID = GetLetter.IntID>
			<cfset LocAccountID = CustInfo.AccountID>
			<cfset LocEMailID = CustInfo.EmailID>
			<cfsetting enablecfoutputonly="no">
				<cfinclude template="runvarvalues.cfm">
			<cfsetting enablecfoutputonly="yes">
			<cfset LocServer = ReplaceList("#GetLetter.EMailServer#","#FindList#","#ReplList#")>
			<cfset LocSvPort = ReplaceList("#GetLetter.EMailServerPort#","#FindList#","#ReplList#")>
			<cfif Trim(LocSvPort) Is "">
				<cfset LocSvPort = 25>
			</cfif>
			<cfset LocEMFrom = ReplaceList("#GetLetter.EMailFrom#","#FindList#","#ReplList#")>
			<cfset LocEmalCC = ReplaceList("#GetLetter.EMailCC#","#FindList#","#ReplList#")>
			<cfset LocSubjct = ReplaceList("#GetLetter.EMailSubject#","#FindList#","#ReplList#")>
			<cfset LocFileNm = ReplaceList("#GetLetter.EMailFile#","#FindList#","#ReplList#")>
			<cfset LocMessag = ReplaceList("#GetLetter.EMailMessage#","#FindList#","#ReplList#")>
			<cfset TheLocMessag = Replace(LocMessag,")*N/A*(","","All")>
			<cfset TheFindList = FindList>
			<cfset TheReplList = ReplList>
			<cfinclude template="runrepeatvalues.cfm">
			<cfset TheLocMessag = TheLocMessag & RepeatMessage>
			<!--- Insert the email into autorun --->
			<cfquery name="AddEMail" datasource="#pds#">
				INSERT INTO AutoRun 
				(AccountID, WhenRun, DoAction, EMailFrom, EMailSubject, EMailTo, 
				 EMailCC, FileAttach, Value1, Value2, Memo1, ScheduledBy)
				VALUES 
				(#CustInfo.AccountID#, #Now()#, 'EMailDelay','#LocEMFrom#','#LocSubjct#','#CustInfo.EMail#',
				 '#LocEMalCC#', Null, '#LocServer#', '#LocSvPort#', '#TheLocMessag#', 'gBill Auto Hour Check')
			</cfquery>
			<!--- Update accountsauth --->
			<cfquery name="UpdAuth" datasource="#pds#">
				UPDATE AccountsAuth SET 
				EMailedYN = 1, 
				EMailDate = #Now()# 
				WHERE AuthID = #AuthID# 
			</cfquery>
		</cfif>
	</cfif>
</cfloop>
<cfsetting enablecfoutputonly="No"> 
 