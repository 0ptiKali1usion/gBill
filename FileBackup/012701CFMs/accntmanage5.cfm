<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 11/09/99 --->
<!--- accntmanage5.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="GetTheCAuthID" datasource="#pds#">
	SELECT CAuthID 
	FROM Domains 
	WHERE DomainID = 
		(SELECT DomainID 
		 FROM AccountsAuth 
		 WHERE AuthID = #AuthID# )
</cfquery>
<cfif IsDefined("DelAuth.x")>
	<!--- Run Scripts --->
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntmanage5.cfm' 
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
	<!--- Run external --->
	<cfif FileExists(ExpandPath("external#OSType#extdeleteauth.cfm"))>
		<cfset SendID = AuthID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="external#OSType#extdeleteauth.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetWhoName" datasource="#pds#">
				SELECT AccountID, FirstName, LastName 
				FROM Accounts 
				WHERE AccountID = 
					(SELECT AccountID 
					 FROM AccountsAuth 
					 WHERE AuthID = #AuthID#) 
			</cfquery>
			<cfquery name="GetUsername" datasource="#pds#">
				SELECT UserName 
				FROM AccountsAuth 
				WHERE AuthID = #AuthID# 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWhoName.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the auth account: #GetUsername.UserName# for #GetWhoName.FirstName# #GetWhoName.LastName#.')
			</cfquery>
		</cfif>
	<!--- Delete From AccountsAuth --->
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM AccountsAuth 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfset tab = 2>
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>

<cfquery name="AuthAccount" datasource="#pds#">
	SELECT * 
	FROM AccountsAuth 
	WHERE AuthID = #AuthID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Authentication Editor</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="Tab" value="2">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<form method="post" action="accntmanage5.cfm">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Delete Authentication</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">You have selected to delete #AuthAccount.UserName#.  Click continue to confirm.</td>
		</tr>
		<tr>
			<th><input type="image" src="images/continue.gif" name="DelAuth" border="0"></th>
		</tr>
		<input type="hidden" name="AuthID" value="#AuthID#">
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 