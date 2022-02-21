<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Add new ftp accounts. --->
<!---	4.0.0 11/30/99 --->
<!--- accntftp6.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("AddNew.x")>
	<cfparam name="FTPID" default="0">
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CFTPID 
		FROM Domains 
		WHERE DomainID = #FTPDomainID#
	</cfquery>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, FTPMinLogin, FTPMaxLogin, FTPMinPassw, FTPMaxPassw, 
		FTPMixPassw, PlanType, Max_Idle, Max_Connect, AWFTPLower, FTPAddChars, 
		DefFTPServer 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="SelDomainName" datasource="#pds#">
		SELECT FTPServer 
		FROM Domains 
		WHERE DomainID = #FTPDomainID# 
	</cfquery>
	<cfset CheckUserName = UserNameVal>
	<cfset CheckPassword = PasswordVal>
	<cfset UNPass = 1>
	<cfset PWPass = 1>
	<cfset UNNoPass = "">
	<cfset PWNoPass = "">
	<cfif Len(CheckUserName) LT GetPlanDefs.FTPMinLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is too short.<br>">
	</cfif> 
	<cfif Len(CheckUserName) GT GetPlanDefs.FTPMaxLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is too long.<br>">
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT FTPID 
		FROM AccountsFTP 
		WHERE UserName = '#CheckUserName#' 
		AND DomainName = '#SelDomainName.FTPServer#' 
	</cfquery>
	<cfif CheckFirst.Recordcount GT 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is already taken.<br>">
	</cfif>
	<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckUserName, 1)) gt 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
	</cfif>
	<cfif Len(CheckPassword) LT GetPlanDefs.FTPMinPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too short.<br>">
	</cfif> 
	<cfif Len(CheckPassword) GT GetPlanDefs.FTPMaxPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too long.<br>">
	</cfif>
	<cfif GetPlanDefs.FTPMixPassw Is 1>
		<cfif IsNumeric(CheckPassword)>
			<cfset PWPass = 0>
			<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password must also contain letters.<br>">
		</cfif>
		<cfif (FindOneOf("1234567890",CheckPassword, 1)) Is 0>
			<cfset PWPass = 0>
			<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password must also contain numbers.<br>">
		</cfif>
	</cfif>
	<cfif (FindOneOf("~##* ,/|", CheckPassword, 1)) gt 0>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
	</cfif>
	<cfif (UNPass Is 1) AND (PWPass Is 1)>
		<!--- Insert Into gBill DB --->
			<cfquery name="GetInfo" datasource="#pds#">
				SELECT A.AccountID 
				FROM Accounts A 
				WHERE AccountID = 
					(SELECT AccountID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#) 
			</cfquery>
			<cfquery name="GetDomain" datasource="#pds#">
				SELECT DomainName, CFTPID 
				FROM Domains 
				WHERE DomainID = #FTPDomainID#
			</cfquery>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT FTPID 
				FROM AccountsFTP 
				WHERE UserName = '#CheckUserName#' 
				AND DomainName = '#GetDomain.DomainName#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="GetFdValues" datasource="#pds#">
					SELECT * 
					FROM CustomFTPSetup 
					WHERE BOBName <> 'UserName' 
					AND BOBName <> 'Password' 
					AND BOBName <> 'DomainName' 
					AND CFTPID = #CFTPID# 
				</cfquery>
				<cfquery name="BOBAuth" datasource="#pds#">
					INSERT INTO AccountsFTP 
					(DomainID, DomainName, UserName, Password, 
					<cfloop query="GetFdValues">#BOBName#, </cfloop>
					AccountID, AccntPlanID, CFTPID) 
					VALUES 
					(#FTPDomainID#, '#GetDomain.DomainName#', 
					<cfif GetPlanDefs.AWFTPLower Is 1>
						'#GetPlanDefs.FTPAddChars##UCASE(CheckUserName)#', 
					<cfelse>
						'#GetPlanDefs.FTPAddChars##CheckUserName#', 	
					</cfif>
					'#CheckPassword#',
					<cfloop query="GetFDValues">
						<cfset UpdValue = Evaluate("#BOBName#Val")>
						<cfif BOBName Is "Start_Dir">
							<cfset IsSlash = Right(UpdValue,1)>
							<cfif IsSlash Is OSType>
								<cfset UpdValue = UpdValue & GetPlanDefs.FTPAddChars & CheckUserName>
							<cfelse>
								<cfset UpdValue = UpdValue & OSType & GetPlanDefs.FTPAddChars & CheckUserName>
							</cfif>
						</cfif>
						<cfif DataType Is "Text">
							<cfif Trim(UpdValue) Is "">Null<cfelse>'#UpdValue#'</cfif>, 
						<cfelseif DataType Is "Number"> 
							<cfif Trim(UpdValue) Is "">Null<cfelse>#UpdValue#</cfif>, 
						<cfelseif DataType Is "Date">
							<cfif Trim(UpdValue) Is "">Null<cfelse>#CreateODBCDateTime(UpdValue)#</cfif>, 
						</cfif>
					</cfloop>
					 #GetInfo.AccountID#, #AccntPlanID#, #GetDomain.CFTPID#)
				</cfquery>
			</cfif>
			<cfquery name="NewID" datasource="#pds#">
				SELECT FTPID 
				FROM AccountsFTP 
				WHERE UserName = '#GetPlanDefs.FTPAddChars##CheckUserName#' 
				AND DomainName = '#GetDomain.DomainName#'
			</cfquery>
		<!--- Run The Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'accntftp6.cfm' 
			AND L.LocationAction = 'Create' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'FTP') 
		</cfquery>
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocFTPID = NewID.FTPID>
			<cfset LocCFTPID = GetTheID.CFTPID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extcreateftp.cfm"))>
			<cfset SendID = NewID.FTPID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extcreateftp.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif> 
		<cfsetting enablecfoutputonly="no">
		<cfset tab = 3>
		<cfinclude template="accntmanage2.cfm">
		<cfabort>
	<cfelse>
		<cfset AuthID = 0>
	</cfif>
</cfif>
<cfif Not IsDefined("FTPID")>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, FTPMinLogin, FTPMaxLogin, FTPMinPassw, FTPMaxPassw, 
		FTPMixPassw, PlanType, Max_Idle, Max_Connect, AWFTPLower, FTPAddChars, 
		DefFTPServer 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="AvailDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, C.FTPDescription 
		FROM Domains D, CustomFTP C 
		WHERE D.CFTPID = C.CFTPID 
		AND D.DomainID IN 
			(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		AND D.DomainName <> '#GetPlanDefs.DefFTPServer#' 
		<cfif getopts.OverRide Is "0">
			AND D.DomainID IN 
				(SELECT DomainID 
				 FROM DomFPlans 
				 WHERE PlanID = #GetPlanDefs.PlanID#) 
		</cfif>
		UNION 
		SELECT D.DomainID, D.DomainName, C.FTPDescription 
		FROM Domains D, CustomFTP C 
		WHERE D.CFTPID = C.CFTPID 
		AND D.DomainName = '#GetPlanDefs.DefFTPServer#' 
		ORDER BY D.DomainName 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>FTP Editor</title>
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
	<form method="post" action="accntftp6.cfm">
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">FTP</font></th>
			</tr>
			<tr>
				<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
			</tr>
			<tr valign="top" bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Domain</td>
	</cfoutput>
				<cfif IsDefined("FTPDomainID")>
					<cfquery name="GetDomainID" datasource="#pds#">
						SELECT FTPServer 
						FROM Domains 
						WHERE DomainID = #FTPDomainID# 
					</cfquery>
					<cfset ADValue = FTPDomainID>
					<cfset DomDisp = GetDomainID.FTPServer>
				<cfelse>
					<cfquery name="GetDomainID" datasource="#pds#">
						SELECT DomainID 
						FROM Domains 
						WHERE DomainName = '#GetPlanDefs.DefFTPServer#' 
					</cfquery>
					<cfset ADValue = GetDomainID.DomainID>
					<cfset DomDisp = GetPlanDefs.DefFTPServer>
				</cfif>
				<cfif AvailDomains.RecordCount GT 1>
					<td><select name="FTPDomainID">
						<cfoutput query="AvailDomains">
							<option <cfif DomainID Is ADValue>selected</cfif> value="#DomainID#">#DomainName# - #FTPDescription#
						</cfoutput>
					</select></td>
				<cfelse>
					<cfoutput>
						<td>#DomDisp#</td>
						<input type="Hidden" name="FTPDomainID" value="#AvailDomains.DomainID#">
					</cfoutput>
				</cfif>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/continue.gif" name="DomSelected" border="0"></th>
			</tr>
			<cfoutput>
				<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
				<input type="hidden" name="FTPID" value="0">
			</cfoutput>
		</table>
	</form>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CFTPID 
		FROM Domains 
		WHERE DomainID = #FTPDomainID#
	</cfquery>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, FTPMinLogin, FTPMaxLogin, FTPMinPassw, FTPMaxPassw, 
		FTPMixPassw, PlanType, Max_Idle, Max_Connect, AWFTPLower, FTPAddChars, Start_Dir, 
		DefFTPServer, Read1, Write1, Create1, Delete1, MkDir1, RmDir1, NoRedir1, AnyDir1, 
		AnyDrive1, NoDrive1, PutAny1, Super1, FTPAddChars
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT *
		FROM CustomFTPSetup 
		WHERE CFTPID = #GetTheID.CFTPID# 
		AND BOBName <> 'UserName' 
		AND BOBName <> 'Password' 		
		AND BOBName <> 'DomainName' 
		ORDER BY SortOrder, FTPDescription 
	</cfquery>

	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>FTP Editor</title>
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
		<tr>
			<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">FTP</font></th>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
		</tr>
	</cfoutput>
	<form method="post" action="accntftp6.cfm">
		<cfoutput>
			<cfif IsDefined("UNNoPass")>
				<tr bgcolor="#tbclr#">
					<td colspan="2">#UNNoPass#
					<cfif PWNoPass Is Not "">#PWNoPass#</cfif></td>
				</tr>
			</cfif>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">UserName</td>
				<cfif IsDefined("UserNameVal")>
					<cfset PWValue = Evaluate("UserNameVal")>
				<cfelse>
					<cfset PWValue = "">
				</cfif>
				<td bgcolor="#tdclr#">#GetPlanDefs.FTPAddChars#<input type="text" name="UserNameVal" value="#PWValue#"></td>
				<input type="hidden" name="UserNameVal_Required" value="Please enter: UserName">
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Password</td>
				<cfif IsDefined("PasswordVal")>
					<cfset PWValue = Evaluate("PasswordVal")>
				<cfelse>
					<cfset PWValue = "">
				</cfif>
				<td bgcolor="#tdclr#"><input type="text" name="PasswordVal" value="#PWValue#"></td>
				<input type="hidden" name="PasswordVal_Required" value="Please enter: Password">
			</tr>
		</cfoutput>
		<cfloop query="GetFdValues">
			<cfoutput>
				<tr bgcolor="#tbclr#" valign="top">
					<td align="right">#FTPDescription#</td>
			</cfoutput>
			<cfif IsDefined("#BOBName#Val")>
				<cfset ATValue = Evaluate("#BOBName#Val")>
			<cfelse>
				<cfset ATValue = "">
			</cfif>
			<cfif CFVarYN Is 1>
				<cfif BOBName Is "Start_Dir">
					<cfif Not IsDefined("#BOBName#Val")>
						<cfset ATValue = GetPlanDefs.start_dir>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #FTPDescription#">
					</cfoutput>
				<cfelseif BOBName Is "Max_Idle1">
					<cfif Not IsDefined("#BOBName#Val")>
						<cfset ATValue = GetPlanDefs.Max_Idle>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" size="6" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #FTPDescription#">
					</cfoutput>
				<cfelseif BOBName Is "Max_Connect1">
					<cfif Not IsDefined("#BOBName#Val")>
						<cfset ATValue = GetPlanDefs.Max_Connect>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" size="6" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #FTPDescription#">
					</cfoutput>
				<cfelse>
					<cfif Not IsDefined("#BOBName#Val")>
						<cfset ATValue = Evaluate("GetPlanDefs.#BOBName#")>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input name="#BOBName#Val" <cfif ATValue Is 1>checked</cfif> type="radio" value="1"> Yes <input name="#BOBName#Val" <cfif ATValue Is 0>checked</cfif> type="radio" value="0"> No</td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #FTPDescription#">
					</cfoutput>
				</cfif>
			<cfelse>
				<cfif IsDefined("#BOBName#Val")>
					<cfset ATValue = Evaluate("#BOBName#Val")>
				<cfelse>
					<cfset ATValue = GetPlanDefs.start_dir>
				</cfif>
				<cfoutput>
					<td bgcolor="#tdclr#"><input type="Text" name="#BOBName#Val" maxlength="25" value="#ATValue#"></td>
				</cfoutput>
			</cfif>
		</cfloop>
		<tr>
			<th colspan="2"><input type="image" src="images/enter.gif" name="AddNew" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="CFTPID" value="#GetTheID.CFTPID#">
			<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
			<input type="hidden" name="FTPDomainID" value="#FTPDomainID#">
		</cfoutput>
	</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif> 
  