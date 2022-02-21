 <cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- accntemail9.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("AddInfo.x")>
		<cfset UNNoPass = "">
		<cfset UNPass = 1>
		<!--- Check for legit email address --->
		<cfquery name="MainEMail" datasource="#pds#">
			SELECT * 
			FROM AccountsEMail 
			WHERE EMailID = #EMailID# 
		</cfquery>
		<cfquery name="GetPlanDefs" datasource="#pds#">
			SELECT MailMinLogin, MailMaxLogin, AWMailLower 
			FROM Plans 
			WHERE PlanID = 
				(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = #MainEMail.AccntPlanID#) 
		</cfquery>
		<cfquery name="SelDomainName" datasource="#pds#">
			SELECT EMailServer, DomainName 
			FROM Domains 
			WHERE DomainID = #MainEMail.DomainID# 
		</cfquery>
		<cfset CheckUserName = AliasAddress>
		<cfif GetPlanDefs.AWMailLower Is 1>
			<cfset CheckUserName = LCASE(AliasAddress)>
		</cfif>
		<cfif Len(CheckUserName) LT GetPlanDefs.MailMinLogin>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckUserName# - Alias is too short.<br>">
		</cfif> 
		<cfif Len(CheckUserName) GT GetPlanDefs.MailMaxLogin>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckUserName# - Alias is too long.<br>">
		</cfif>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT EMailID 
			FROM AccountsEMail 
			WHERE EMail = '#CheckUserName#@#SelDomainName.DomainName#' 
		</cfquery>
		<cfif CheckFirst.Recordcount GT 0>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckUserName# - EMail alias is already taken.<br>">
		</cfif>
		<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckUserName, 1)) gt 0>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckUserName# - Alias can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
		</cfif>
		<cfif UNPass Is 1>
			<cfquery name="PersonalInfo" datasource="#pds#">
				SELECT AccountID, FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = 
					(SELECT AccountID 
					 FROM AccountsEMail 
					 WHERE EMailID = #EMailID#) 
			</cfquery>
			<!--- Insert the entery in AccountsAuth --->
			<cftransaction>
				<cfquery name="BOBAuth" datasource="#pds#">
					INSERT INTO AccountsEMail 
					(AccountID, DomainID, EMail, FName, LName, Alias, PrEMail, AliasTo, ContactYN, 
					 SMTPUserName, DomainName, FullName, AccntPlanID, MailCMD, CEMailID)
					VALUES 
					(#PersonalInfo.AccountID#, #MainEMail.DomainID#, '#CheckUserName#@#SelDomainName.DomainName#', 
					'#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', 1, 0, #EMailID#, 0, '#CheckUserName#', 
					'#SelDomainName.DomainName#', '#PersonalInfo.FirstName# #PersonalInfo.LastName#', #AccntPlanID#, 'ReDir',#MainEMail.CEMailID#)
				</cfquery>
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist 
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,#PersonalInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
						 '#StaffMemberName.FirstName# #StaffMemberName.LastName# entered the email alias address: #CheckUserName#@#SelDomainName.DomainName# for #PersonalInfo.FirstName# #PersonalInfo.LastName#.')
					</cfquery>
				</cfif>
				<!--- Get EMailID --->
				<cfquery name="GetID" datasource="#pds#">
					SELECT Max(EMailID) As NewID 
					FROM AccountsEMail 
				</cfquery>
				<cfset EMailAID = GetID.NewID>
			</cftransaction>
			<!--- Run Scripts --->
			<cfquery name="GetScripts" datasource="#pds#">
				SELECT I.IntID 
				FROM Integration I, IntScriptLoc S, IntLocations L 
				WHERE I.IntID = S.IntID 
				AND S.LocationID = L.LocationID 
				AND L.ActiveYN = 1 
				AND I.ActiveYN = 1 
				AND L.PageName = 'accntemail9.cfm' 
				AND L.LocationAction = 'Create' 
				AND I.TypeID = 
					(SELECT TypeID 
					 FROM IntTypes 
					 WHERE TypeStr = 'EMail Alias') 
			</cfquery>
			<cfif GetScripts.RecordCount GT 0>
				<cfset LocScriptID = ValueList(GetScripts.IntID)>
				<cfset LocAliasID = GetID.NewID>
				<cfset LocEMailID = EMailID>
				<cfset LocAccntPlanID = AccntPlanID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="runintegration.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif>
			<!--- Run external --->
			<cfif FileExists(ExpandPath("external#OSType#extcreateemaila.cfm"))>
				<cfset SendID = GetID.NewID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="external#OSType#extcreateemaila.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif> 
			<cfset Tab = 4>
			<cfsetting enablecfoutputonly="No">
			<cfinclude template="accntmanage2.cfm">
			<cfabort>	
	</cfif>
</cfif>

<cfquery name="MainEMail" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>
<cfquery name="EMailServer" datasource="#pds#">
	SELECT * 
	FROM CustomEMail 
	WHERE CEmailID = 
		(SELECT CEMailID 
		 FROM Domains 
		 WHERE DomainID = #MainEMail.DomainID#)
</cfquery>

<cfquery name="GetPlanDefs" datasource="#pds#">
	SELECT MailMaxLogin, AWMailLower 
	FROM Plans 
	WHERE PlanID = 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = #MainEMail.AccntPlanID#) 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>EMail Setup</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#MainEMail.AccntPlanID#"></cfoutput>
	<input type="hidden" name="tab" value="4">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#MainEMail.EMail#</font></th>
	</tr>
	<form method="post" action="accntemail9.cfm">
		<cfif EMailServer.AllowAlias Is 1>
			<cfif IsDefined("UNNoPass")>
				<tr bgcolor="#tbclr#">
					<td colspan="3">#UNNoPass#</td>
				</tr>
			</cfif>
			<tr bgcolor="#tbclr#">
				<th valign="top" bgcolor="#tdclr#"><input type="Radio" checked name="AddType" value="Alias"></th>
				<td>Email Alias</td>
				<td bgcolor="#tdclr#"><input type="Text" name="AliasAddress" <cfif IsDefined("CheckUserName")>value="#CheckUserName#"</cfif> maxlength="#GetPlanDefs.MailMaxLogin#" size="20">@#MainEMail.DomainName#</td>
			</tr>
			<tr>
				<th colspan="3"><input type="Image" name="AddInfo" src="images/enter.gif" border="0"></th>
			</tr>
		<cfelse>
			<tr>
				<td bgcolor="#tbclr#" colspan="3">#EMailServer.EMailDescription#<br>
				This custom EMail does not support alias addresses.<br>
				<a href="customemail.cfm">Custom EMail Setup</a></td>
			</tr>
		</cfif>
		<input type="hidden" name="AccntPlanID" value="#MainEMail.AccntPlanID#">
		<input type="Hidden" name="EMailID" value="#EMailID#">
	</form>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 