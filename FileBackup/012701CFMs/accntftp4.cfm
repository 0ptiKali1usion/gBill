<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- FTP Account Management. --->
<!---	4.0.0 11/17/99 --->
<!--- accntftp4.cfm --->
<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("UpdateFTP.x")>
	<cfparam name="NewPlanID" default="0">
	<cfquery name="UpdateFTP" datasource="#pds#">
		SELECT * 
		FROM CustomFTPSetup 
		WHERE CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'UserName' 
		AND BOBName <> 'DomainName' 
		AND BOBName In (<cfloop index="B5" list="#FieldNames#">'#B5#',</cfloop>'0') 
		AND ActiveYN = 1 
	</cfquery>
	<cfif UpdateFTP.RecordCount GT 0 OR NewPlanID GT 0>
		<cfquery name="ResetOld" datasource="#pds#">
			UPDATE AccountsFTP SET 
			Read1 = 0, Write1 = 0, Create1 = 0, Delete1 = 0, MKDir1 = 0, RMDir1 = 0, 
			NOReDir1 = 0, AnyDir1 = 0, AnyDrive1 = 0, NoDrive1 = 0, PutAny1 = 0, 
			Super1 = 0, Max_Idle1 = 0, Max_Connect1 = 0 
			WHERE FTPID = #FTPID# 
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE AccountsFTP SET 
			<cfloop query="UpdateFTP">
				<cfif IsDefined("#BOBName#")>
					<cfset TheValue = Evaluate("#BOBName#")>
					#BOBName# = 
						<cfif DataType Is "Text">
							'#TheValue#' 
						<cfelseif DataType Is "Number">
							#TheValue# 
						<cfelseif DataType Is "Date">
							#CreateODBCDateTime(TheValue)# 
						</cfif>
						<cfif CurrentRow Is Not RecordCount>,</cfif> 
				</cfif>
			</cfloop>
			<cfif NewPlanID GT 0>
				, AccntPlanID = #NewPlanID# 
			</cfif>
			WHERE FTPID = #FTPID#
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetInfo" datasource="#pds#">
				SELECT AccountID, UserName 
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
			<cfquery name="NewPlan" datasource="#pds#">
				SELECT PlanDesc 
				FROM Plans 
				WHERE PlanID = 
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #NewPlanID#)
			</cfquery>
			<cfset BOBHistMess = "#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the FTP account: #GetInfo.UserName# for #GetWhoName.FirstName# #GetWhoName.LastName#.">
			<cfif NewPlanID GT 0>
				<cfset BOBHistMess = BOBHistMess & "  The account was moved to the plan: #NewPlanID# #NewPlan.PlanDesc#">
			</cfif>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist 
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#BOBHistMess#')
			</cfquery>
		</cfif>
	</cfif>
	<!---  Scripts  --->
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntftp4.cfm' 
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
	<cfsetting enablecfoutputonly="no">
	<cfset Tab = 3>
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>
<cfquery name="AuthInfo" datasource="#pds#">
	SELECT * 
	FROM AccountsFTP 
	WHERE FTPID = #FTPID# 
</cfquery>
<cfquery name="SelectedPlan" datasource="#pds#">
	SELECT P.PlanID, P.PlanDesc, A.AccntPlanID 
	FROM Plans P, AccntPlans A
	WHERE P.PlanID = A.PlanID 
	AND A.AccntPlanID = #AccntPlanID# 
</cfquery>
<cfquery name="OtherPlans" datasource="#pds#">
	SELECT AP.AccntPlanID, AP.FTPAccounts, P.PlanID, P.PlanDesc, P.FTPNumber, Count(F.FTPID) as IntNumber 
	FROM Plans P, AccntPlans AP, AccountsFTP F 
	WHERE P.PlanID = AP.PlanID 
	AND F.AccntPlanID = AP.AccntPlanID 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND AP.AccntPlanID <> #AccntPlanID# 
	GROUP BY AP.AccntPlanID, AP.FTPAccounts, P.PlanID, P.PlanDesc, P.FTPNumber 
	HAVING Count(F.FTPID) < P.FTPNumber 
	OR Count(F.FTPID) < AP.FTPAccounts 
	UNION 
	SELECT AP.AccntPlanID, AP.FTPAccounts, P.PlanID, P.PlanDesc, P.FTPNumber, 0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID <> #AccntPlanID# 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND (P.FTPNumber > 0 OR AP.FTPAccounts > 0) 
	AND AP.AccntPlanID NOT IN 
		(SELECT AccntPlanID 
		 FROM AccountsFTP)
	ORDER BY PlanDesc 
</cfquery>
<cfquery name="GetFieldInfo" datasource="#pds#">
	SELECT * 
	FROM CustomFTPSetup 
	WHERE ActiveYN = 1 
	AND CFTPID = 
		(SELECT CFTPID 
		 FROM Domains 
		 WHERE DomainID = 
		 	(SELECT DomainID 
			 FROM AccountsFTP 
			 WHERE FTPID = #FTPID#)
		)
	AND BOBName <> 'Password' 
	AND BOBName <> 'UserName' 
	AND BOBName <> 'DomainName' 
	ORDER BY SortOrder, FTPDescription 
</cfquery>
<cfif GetFieldInfo.Recordcount Is 0>
	<cfquery name="GetFieldInfo" datasource="#pds#">
		SELECT S.* 
		FROM CustomFTPSetup S, CustomFTP F
		WHERE S.CFTPID = F.CFTPID 
		AND S.ActiveYN = 1 
		AND F.DefaultYN = 1 
		AND S.BOBName <> 'Password' 
		AND S.BOBName <> 'UserName' 
		AND BOBName <> 'DomainName' 
		ORDER BY SortOrder, FTPDescription 
	</cfquery>
</cfif>
<cfquery name="FTPInfo" datasource="#pds#">
	SELECT #ValueList(GetFieldInfo.BOBName)#, FTPID 
	FROM AccountsFTP 
	WHERE FTPID = #FTPID# 
</cfquery>
<cfset EditOptions = 0>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>FTP</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="tab" value="3">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">FTP</font></th>
	</tr>
</cfoutput>
<form method="post" action="accntftp4.cfm">
	<cfif OtherPlans.Recordcount GT 0>
		<cfset EditOptions = 1>
		<cfoutput>
			<tr>
				<th bgcolor="#thclr#" colspan="2">#SelectedPlan.PlanDesc#</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Change To</td>
		</cfoutput>
				<td><select name="NewPlanID">
					<cfoutput><option value="0">Leave on #SelectedPlan.PlanDesc#</cfoutput>
					<cfoutput query="OtherPlans">
						<option value="#AccntPlanID#">#AccntPlanID# #PlanDesc#
					</cfoutput>
				</select></td>
			</tr>
	</cfif>
<cfloop query="GetFieldInfo">
	<cfif GetOpts.OverRide Is 1>
		<cfset EditOptions = 1>
		<tr>
			<cfoutput>
				<td align="right" bgcolor="#tbclr#">#FTPDescription#</td>
				<cfset DispValue = Evaluate("FTPInfo.#BOBName#")>
				<cfif (ListFind("Start_Dir,Max_Idle1,Max_Connect1","#BOBName#")) OR (CFVarYN Is 0)>
					<td bgcolor="#tdclr#"><input type="text" name="#BOBName#" value="#DispValue#"></td>
				<cfelse>
					<td bgcolor="#tdclr#"><input type="radio" <cfif DispValue Is 1>checked</cfif> name="#BOBName#" value="1"> Yes <input type="radio" <cfif DispValue Is 0>checked</cfif> name="#BOBName#" value="0"> No</td>
				</cfif>
			</cfoutput>
			<cfoutput>
				<input type="hidden" name="#BOBName#_Required" value="Please enter: #FTPDescription#">
			</cfoutput>
		</tr>
	</cfif>
</cfloop>
<cfif EditOptions Is 1>
	<cfoutput>
		<tr>
			<th colspan="2"><input type="image" src="images/update.gif" name="UpdateFTP" border="0"></th>
		</tr>
		<input type="hidden" name="CFTPID" value="#GetFieldInfo.CFTPID#"> 
		<input type="hidden" name="FTPID" value="#FTPInfo.FTPID#">
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
	</cfoutput>
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">There are no editable options.</td>
		</tr>
	</cfoutput>
</cfif>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 