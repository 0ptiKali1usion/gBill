<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Deletes an EMail account. --->
<!---	4.0.0 12/03/99 --->
<!-- accntemail5.cfm -->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="GetTheID" datasource="#pds#">
	SELECT CEMailID 
	FROM Domains 
	WHERE DomainID = 
		(SELECT DomainID 
		 FROM AccountsEMail 
		 WHERE EMailID = #EMailID# )
</cfquery>
<cfif IsDefined("DelAuth.x")>
	<!--- Get Type --->
	<cfquery name="EMailType" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<!--- Run Scripts --->
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntemail5.cfm' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 <cfif EMailType.Alias Is 1>
			 	WHERE TypeStr = 'EMail Alias' 
			 <cfelse>
			 	WHERE TypeStr = 'EMail'
			 </cfif>
			 ) 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfif EMailType.Alias Is 1>
			<cfset LocAliasID = EMailID>
			<cfquery name="GetOldID" datasource="#pds#">
				SELECT AliasTo 
				FROM AccountsEMail 
				WHERE EMailID = #EMailID# 
			</cfquery>
			<cfset LocEMailID = GetOldID.AliasTo>
		<cfelse>
			<cfset LocEMailID = EMailID>
		</cfif>
		
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
	<!--- Delete From AccountsEMail --->
	<cfquery name="DelAlias" datasource="#pds#">
		DELETE FROM AccountsEMail 
		WHERE AliasTo = #EMailID# 
	</cfquery>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfset tab = 4>
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>


<cfquery name="EMailAccount" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE AliasTo = #EMailID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Delete EMail Account</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="Tab" value="4">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Delete EMail</font></th>
	</tr>
	<cfif EMailAccount.PrEMail Is 1>
		<tr>
			<td bgcolor="#tbclr#">This is the primary email address for this account.  You must select another address before deleting this address.</td>
		</tr>
		<tr>
			<form method="post" action="accntpremail.cfm">
				<th><input type="Image" name="GoTo" src="images/select.gif" border="0"></th>
				<input type="Hidden" name="AccountId" value="#EMailAccount.AccountID#">
			</form>
		</tr>
	<cfelse>
		<tr>
			<td bgcolor="#tbclr#">You have selected to delete #EMailAccount.Email#.  Click continue to confirm.</td>
		</tr>
		<cfif CheckFirst.RecordCount GT 0>
			<tr>
				<td bgcolor="#tbclr#">There are #CheckFirst.Recordcount# alias accounts that will be deleted also.</td>
			</tr>
		</cfif>
		<tr>
			<form method="post" action="accntemail5.cfm">
				<th><input type="image" src="images/continue.gif" name="DelAuth" border="0"></th>
				<input type="Hidden" name="EMailID" value="#EMailID#">
				<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
			</form>
		</tr>
	</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 