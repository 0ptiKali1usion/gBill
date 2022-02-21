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
	<cfquery name="UpdateFTP" datasource="#pds#">
		SELECT * 
		FROM CustomFTPSetup 
		WHERE CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'UserName' 
		AND BOBName <> 'DomainName' 
		AND ActiveYN = 1 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AccountsFTP SET 
		<cfloop query="UpdateFTP">
			<cfset TheValue = Evaluate("#BOBName#")>
			#BOBName# = 
				<cfif DataType Is "Text">
					'#TheValue#' 
				<cfelseif DataType Is "Number">
					#TheValue# 
				<cfelseif DataType Is "Date">
					#CreateODBCDateTime(TheValue)# 
				</cfif>
				,
		</cfloop>
		AccntPlanID = #NewPlanID# 
		WHERE FTPID = #FTPID# 
	</cfquery>
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
	SELECT PlanID, PlanDesc 
	FROM Plans 
	WHERE PlanID = 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = 
		 	(SELECT AccntPlanID 
			 FROM AccountsFTP 
			 WHERE FTPID = #FTPID#)
		)
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
	UNION 
	SELECT AP.AccntPlanID, AP.FTPAccounts, P.PlanID, P.PlanDesc, P.FTPNumber, 	0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID = #AccntPlanID# 
	ORDER BY P.PlanDesc
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
		<cfoutput>
			<tr>
				<th bgcolor="#thclr#" colspan="2">#SelectedPlan.PlanDesc#</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Change To</td>
		</cfoutput>
				<td><select name="NewPlanID">
					<cfoutput query="OtherPlans">
						<option <cfif PlanID Is SelectedPlan.PlanID>selected</cfif> value="#AccntPlanID#">#PlanDesc#
					</cfoutput>
				</select></td>
			</tr>
	</cfif>
<cfloop query="GetFieldInfo">
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
</cfloop>
<cfoutput>
	<tr>
		<th colspan="2"><input type="image" src="images/update.gif" name="UpdateFTP" border="0"></th>
	</tr>
	<input type="hidden" name="CFTPID" value="#GetFieldInfo.CFTPID#"> 
	<input type="hidden" name="FTPID" value="#FTPInfo.FTPID#">
	<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 