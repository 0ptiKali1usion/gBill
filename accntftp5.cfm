<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Deletes an FTP account. --->
<!---	4.0.0 11/30/99 --->
<!-- accntftp5.cfm -->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="GetTheID" datasource="#pds#">
	SELECT CFTPID 
	FROM Domains 
	WHERE DomainID = 
		(SELECT DomainID 
		 FROM AccountsFTP 
		 WHERE FTPID = #FTPID# )
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
		AND L.PageName = 'accntftp5.cfm' 
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
	<!--- Run external --->
	<cfif FileExists(ExpandPath("external#OSType#extdeleteftp.cfm"))>
		<cfset SendID = FTPID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="external#OSType#extdeleteftp.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="AccntInfo" datasource="#pds#">
			SELECT UserName, AccountID 
			FROM AccountsFTP 
			WHERE FTPID = #FTPID# 
		</cfquery>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM AccountsFTP 
				 WHERE FTPID = #FTPID#) 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#AccntInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the FTP account: #AccntInfo.UserName# for #GetWhoName.FirstName# #GetWhoName.LastName#.')
		</cfquery>
	</cfif>
	<!--- Delete From AccountsFTP --->
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM AccountsFTP 
		WHERE FTPID = #FTPID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfset tab = 3>
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>


<cfquery name="FTPAccount" datasource="#pds#">
	SELECT * 
	FROM AccountsFTP 
	WHERE FTPID = #FTPID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Delete FTP Account</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="Tab" value="3">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<form method="post" action="accntftp5.cfm">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Delete FTP</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">You have selected to delete #FTPAccount.UserName#.  Click continue to confirm.</td>
		</tr>
		<tr>
			<th><input type="image" src="images/continue.gif" name="DelAuth" border="0"></th>
		</tr>
		<input type="hidden" name="FTPID" value="#FTPID#">
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 