<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 11/02/99 --->
<!--- accntmanage6.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="GetMask" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'DateMask1' 
</cfquery>
<cfset DateMask1 = GetMask.Value1>

<cfif IsDefined("AddAuthDB.x")>
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CAuthID 
		FROM Domains 
		WHERE DomainID = #AuthDomainID#
	</cfquery>
	<cfset CAuthID = GetTheID.CAuthID>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, AuthMinLogin, AuthMaxLogin, AuthMinPassw, AuthMaxPassw, 
		AuthMixPassw, PlanType, LoginLimit, Max_Idle1, Max_Connect1, LowerAWYN, AuthAddChars, 
		DefAuthServer, AWStaticIPYN 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="SelDomainName" datasource="#pds#">
		SELECT AuthServer, DomainName 
		FROM Domains 
		WHERE DomainID = #AuthDomainID# 
	</cfquery>
	<!--- Get the Unique By setting  1-Domain 2-Auth Only 3-Globally --->
	<cfquery name="UniqueByIs" datasource="#pds#">
		SELECT UniqueBy 
		FROM CustomAuth 
		WHERE CAuthID = #CAuthID# 
	</cfquery>
	<cfset TheUniqueIs = UniqueByIs.UniqueBy>
	<!--- Do the Checks --->
	<cfset CheckUserName = LoginFieldName>
	<cfset CheckPassword = PasswFieldName>
	<cfset UNPass = 1>
	<cfset PWPass = 1>
	<cfset UNNoPass = "">
	<cfset PWNoPass = "">

	<cfif Len(CheckUserName) LT GetPlanDefs.AuthMinLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is too short.<br>">
	</cfif> 
	<cfif Len(CheckUserName) GT GetPlanDefs.AuthMaxLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is too long.<br>">
	</cfif>
	<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckUserName, 1)) gt 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
	</cfif>
	<cfif AuthAddChars Is Not "">
		<cfset CheckUserName = AuthAddChars & CheckUserName>
	</cfif>
	<cfif AuthSufChars Is Not "">
		<cfset CheckUserName = CheckUserName & AuthSufChars>
	</cfif>
	<cfif TheUniqueIs Is 1>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT AuthID 
			FROM AccountsAuth 
			WHERE UserName = '#CheckUserName#' 
			AND DomainName = '#SelDomainName.DomainName#' 
		</cfquery>
	<cfelseif TheUniqueIs Is 2>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT AuthID 
			FROM AccountsAuth 
			WHERE UserName = '#CheckUserName#' 
			AND CAuthID = #CAuthID# 
		</cfquery>
	<cfelse>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT AuthID 
			FROM AccountsAuth 
			WHERE UserName = '#CheckUserName#' 
		</cfquery>
	</cfif>
	<cfif CheckFirst.Recordcount GT 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is already taken.<br>">
	</cfif>
	<cfif Len(CheckPassword) LT GetPlanDefs.AuthMinPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too short.<br>">
	</cfif> 
	<cfif Len(CheckPassword) GT GetPlanDefs.AuthMaxPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too long.<br>">
	</cfif>
	<cfif GetPlanDefs.AuthMixPassw Is 1>
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
			<cfquery name="GetPlanInfo" datasource="#pds#">
				SELECT BaseHours, HoursUp, RollBackTo, EMailWarn, Filter1 
				FROM Plans P 
				WHERE P.PlanID = 
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#) 
			</cfquery>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfinclude template="runvarvalues.cfm">
			<cfset BaseSeconds = GetPlanInfo.BaseHours * 3600>
			<cfset BaseWarn = GetPlanInfo.EMailWarn * 3600>
			<cfquery name="GetDomain" datasource="#pds#">
				SELECT AuthServer, CAuthID, DomainName 
				FROM Domains 
				WHERE DomainID = #AuthDomainID#
			</cfquery>
		 	<cfquery name="GetFdValues" datasource="#pds#">
				SELECT A.DBFieldName, A.DataNeed, A.DataType, S.Descrip1, S.BOBName 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.DBType = 'Fd' 
				AND S.ForTable = 
					(SELECT ForTable 
					 FROM CustomAuthSetup 
					 WHERE BOBName = 'accounts' 
					 AND CAuthID = #CAuthID#) 
				AND A.DBFieldName Not In 
					(SELECT DBName 
					 FROM CustomAuthSetup 
					 WHERE CAuthID = #CAuthID# 
					 AND BOBName In ('accntlogin','acntpassword') 
					)
				ORDER BY S.SortOrder, A.DBFieldName 
			</cfquery>
			<cfloop query="GetFDValues">
				<cfif IsDefined("#DBFieldName#")>
					<cfset "#BOBName#" = Evaluate("#DBFieldName#")>
				</cfif>
			</cfloop>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AuthID 
				FROM AccountsAuth 
				WHERE UserName = '#CheckUserName#' 
				AND DomainName = '#GetDomain.DomainName#' 
			</cfquery>
			<cfquery name="FilterCheck" datasource="#pds#">
				SELECT A.DataNeed 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.BOBName = 'acnttype'
			</cfquery>
			<cfset ATValue = FilterCheck.DataNeed>
			<cfset Pos1 = ListFind(FindList,FilterCheck.DataNeed)>
			<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
				<cfset ATValue = ListGetAt(ReplList,Pos1)>
			</cfif>
			<cfif (ATValue Is ")*N/A*(") OR (ATValue Is "")>
				<cfset ATValue = GetPlanDefs.PlanType>
			</cfif>
			<cfif IsDefined("AcntType")>
				<cfset ATValue = AcntType>
			</cfif>
			<cfquery name="IPACheck" datasource="#pds#">
				SELECT A.DataNeed 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.BOBName = 'custipaddress'
			</cfquery>
			<cfset ATValue2 = IPACheck.DataNeed>
			<cfset Pos1 = ListFind(FindList,IPACheck.DataNeed)>
			<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
				<cfset ATValue2 = ListGetAt(ReplList,Pos1)>
			</cfif>
			<cfif (ATValue2 Is ")*N/A*(") OR (ATValue2 Is "")>
				<cfset ATValue2 = "">
			</cfif>
			<cfif IsDefined("custipaddress")>
				<cfset ATValue2 = custipaddress>
			</cfif>
			<cfquery name="MCCheck" datasource="#pds#">
				SELECT A.DataNeed 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.BOBName = 'maxconnecttime'
			</cfquery>
			<cfset ATValue3 = MCCheck.DataNeed>
			<cfset Pos1 = ListFind(FindList,MCCheck.DataNeed)>
			<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
				<cfset ATValue3 = ListGetAt(ReplList,Pos1)>
			</cfif>
			<cfif (ATValue3 Is ")*N/A*(") OR (ATValue3 Is "")>
				<cfset ATValue3 = GetPlanDefs.Max_Connect1>
			</cfif>
			<cfif IsDefined("maxconnecttime")>
				<cfset ATValue3 = maxconnecttime>
			</cfif>
			<cfquery name="MICheck" datasource="#pds#">
				SELECT A.DataNeed 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.BOBName = 'maxidletime'
			</cfquery>
			<cfset ATValue4 = MICheck.DataNeed>
			<cfset Pos1 = ListFind(FindList,MICheck.DataNeed)>
			<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
				<cfset ATValue4 = ListGetAt(ReplList,Pos1)>
			</cfif>
			<cfif (ATValue4 Is ")*N/A*(") OR (ATValue4 Is "")>
				<cfset ATValue4 = GetPlanDefs.Max_Idle1>
			</cfif>
			<cfif IsDefined("maxidletime")>
				<cfset ATValue4 = maxidletime>
			</cfif>
			<cfquery name="MLCheck" datasource="#pds#">
				SELECT A.DataNeed 
				FROM CustomAuthAccount A, CustomAuthSetup S 
				WHERE A.DBFieldName = S.DBName 
				AND A.CAuthID = #CAuthID# 
				AND S.CAuthID = #CAuthID# 
				AND S.BOBName = 'loginlimit'
			</cfquery>
			<cfset ATValue5 = MLCheck.DataNeed>
			<cfset Pos1 = ListFind(FindList,MLCheck.DataNeed)>
			<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
				<cfset ATValue5 = ListGetAt(ReplList,Pos1)>
			</cfif>
			<cfif (ATValue5 Is ")*N/A*(") OR (ATValue5 Is "")>
				<cfset ATValue5 = GetPlanDefs.LoginLimit>
			</cfif>
			<cfif IsDefined("loginlimit")>
				<cfset ATValue5 = loginlimit>
			</cfif>
			<cfif CheckFirst.Recordcount Is 0>
				<cftransaction>
					<cfquery name="BOBAuth" datasource="#pds#">
						INSERT INTO AccountsAuth 
						(AccountID, DomainID, DomainName, UserName, Password, 
						 Filter1, IP_Address, Max_Connect, Max_Idle, Max_Logins, 
						 EMailedYN, SecondsLeft, EMailSecsLeft, MonthTotalTime, 
						 AccntPlanID, FilterLockYN, WarningTimeLeft, WarningAction, 
						 CAuthID, AuthServer) 
						VALUES 
						(#GetInfo.AccountID#, #AuthDomainID#, '#GetDomain.DomainName#', '#CheckUserName#', '#CheckPassword#',
						 '#ATValue#', '#ATValue2#', #ATValue3#, #ATValue4#, #ATValue5#, 
						 0, #BaseSeconds#, #BaseWarn#, #BaseSeconds#, #AccntPlanID#, 0, 0, 
						 #GetPlanInfo.HoursUp#, #GetDomain.CAuthID#, '#GetDomain.AuthServer#')
					</cfquery>
					<cfquery name="NewID" datasource="#pds#">
						SELECT Max(AuthID) As MaxID 
						FROM AccountsAuth 
					</cfquery>
				</cftransaction>
				<cfset AuthID = NewID.MaxID>
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="GetWhoName" datasource="#pds#">
						SELECT FirstName, LastName 
						FROM Accounts 
						WHERE AccountID = #GetInfo.AccountID#
					</cfquery>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,#GetInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
						 '#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the auth account: #CheckUserName# for #GetWhoName.FirstName# #GetWhoName.LastName#.')
					</cfquery>
				</cfif>				
			</cfif>
		<!--- Insert Into Radius DB --->
		<cfquery name="getvalues" datasource="#pds#">
			SELECT * 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfloop query="getvalues">
			<cfset "#BobName#" = #DBName#>
		</cfloop>	
		<cfset CreateAccount = GetInfo.AccountID>
		<!--- Run The Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'accntmanage6.cfm' 
			AND L.LocationAction = 'Create' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'Authentication') 
		</cfquery>
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocAuthID = AuthID>
			<cfset LocCAuthID = CAuthID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extcreateauth.cfm"))>
			<cfset SendID = AuthID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extcreateauth.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif> 
		<cfsetting enablecfoutputonly="no">
		<cfset tab = 2>
		<cfinclude template="accntmanage2.cfm">
		<cfabort>
	<cfelse>
		<cfset AuthID = 0>
	</cfif>
</cfif>
<cfif Not IsDefined("AuthID")>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, AuthMinLogin, AuthMaxLogin, AuthMinPassw, AuthMaxPassw, 
		AuthMixPassw, PlanType, LoginLimit, Max_Idle1, Max_Connect1, LowerAWYN, AuthAddChars, 
		DefAuthServer, AWStaticIPYN 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="AvailDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, C.AuthDescription 
		FROM Domains D, CustomAuth C 
		WHERE D.CAuthID = C.CAuthID 
		AND D.DomainID IN 
			(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		AND D.DomainName <> '#GetPlanDefs.DefAuthServer#' 
		<cfif GetOpts.OverRide Is "0">
			AND D.DomainID IN 
				(SELECT DomainID 
				 FROM DomAPlans 
				 WHERE PlanID = #GetPlanDefs.PlanID#) 
		</cfif>
		UNION 
		SELECT D.DomainID, D.DomainName, C.AuthDescription 
		FROM Domains D, CustomAuth C 
		WHERE D.CAuthID = C.CAuthID 
		AND D.DomainName = '#GetPlanDefs.DefAuthServer#' 
		ORDER BY D.DomainName 
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
	<form method="post" action="accntmanage6.cfm">
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Authentication</font></th>
			</tr>
			<tr>
				<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
			</tr>
	</cfoutput>
			<cfif AvailDomains.RecordCount Is 0>
				<tr>
					<cfoutput>
						<td bgcolor="#tbclr#">The domains available to this plan are currently not setup correctly.<br>
						Please go to the Domains Setup to enter the needed information.</td>
					</cfoutput>
				</tr>
			<cfelse>
				<cfoutput>
					<tr valign="top" bgcolor="#tdclr#">
						<td bgcolor="#tbclr#" align="right">Domain</td>
				</cfoutput>
				<cfif IsDefined("AuthDomainID")>
					<cfquery name="GetDomainID" datasource="#pds#">
						SELECT AuthServer 
						FROM Domains 
						WHERE DomainID = #AuthDomainID# 
					</cfquery>
					<cfset ADValue = AuthDomainID>
					<cfset DomDisp = GetDomainID.AuthServer>
				<cfelse>
					<cfquery name="GetDomainID" datasource="#pds#">
						SELECT DomainID 
						FROM Domains 
						WHERE DomainName = '#GetPlanDefs.DefAuthServer#' 
					</cfquery>
					<cfset ADValue = GetDomainID.DomainID>
					<cfset DomDisp = GetPlanDefs.DefAuthServer>
				</cfif>
				<cfif AvailDomains.RecordCount GT 1>
					<td><select name="AuthDomainID">
						<cfoutput query="AvailDomains">
							<option <cfif DomainID Is ADValue>selected</cfif> value="#DomainID#">#DomainName# - #AuthDescription#
						</cfoutput>
					</select></td>
				<cfelse>
					<cfoutput>
						<td bgcolor="#tbclr#">#DomDisp#</td>
						<input type="Hidden" name="AuthDomainID" value="#AvailDomains.DomainID#">
					</cfoutput>
				</cfif>
				</tr>
				<tr>
					<th colspan="2"><input type="image" src="images/continue.gif" name="DomSelected" border="0"></th>
				</tr>
				<cfoutput>
					<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					<input type="hidden" name="AuthID" value="0">
				</cfoutput>
			</cfif>
		</table>
	</form>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CAuthID 
		FROM Domains 
		WHERE DomainID = #AuthDomainID#
	</cfquery>
	<cfset CAuthID = GetTheID.CAuthID>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, AuthMinLogin, AuthMaxLogin, AuthMinPassw, AuthMaxPassw, AuthMixPassw, 
		PlanType, LoginLimit, Max_Idle1, Max_Connect1, LowerAWYN, AuthAddChars, DefAuthServer, AWStaticIPYN, 
		ExpireDays, ExpireTo, AuthSufChars 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfif (GetPlanDefs.ExpireTo Is "") OR (GetPlanDefs.ExpireTo Is 0)>
		<cfset TheExpireDate = "">
	<cfelse>
		<cfset TheExpireDate = DateAdd("d",GetPlanDefs.ExpireDays,Now())>
	</cfif>
	<cfquery name="GetDSValue" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE BOBName = 'AuthODBC' 
		AND CAuthID = #GetTheID.CAuthID# 
	</cfquery>
	<cfquery name="GetTypes" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'tbacnttypes' 
			 AND CAuthID = #GetTheID.CAuthID# ) 
		AND CAuthID = #GetTheID.CAuthID# 
	</cfquery>
	<cfloop query="GetTypes">
		<cfset "#BobName#" = DBName>
	</cfloop>
	<cfif (Trim(AcntTypesFd) Is Not "") AND (Trim(TbAcntTypes) Is Not "") AND (GetDSValue.DBName Is Not "")>
		<cftry>
			<cfquery name="SelectTypes" datasource="#GetDSValue.DBName#">
				SELECT #AcntTypesFd# AS TheTypesAvail 
				FROM #TbAcntTypes# 
			</cfquery>
			<cfcatch type="Any">
				<cfset ShowDisplayTypes = 0>
			</cfcatch>
		</cftry>
	</cfif>
 	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT A.DBFieldName, A.DataNeed, A.DataType, S.Descrip1, S.CFVarYN 
		FROM CustomAuthAccount A, CustomAuthSetup S 
		WHERE A.DBFieldName = S.DBName 
		AND A.CAuthID = #GetTheID.CAuthID# 
		AND S.CAuthID = #GetTheID.CAuthID# 
		AND S.DBType = 'Fd' 
		AND S.ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'accounts' 
			 AND CAuthID = #GetTheID.CAuthID#) 
		AND A.DBFieldName Not In 
			(SELECT DBName 
			 FROM CustomAuthSetup 
			 WHERE CAuthID = #GetTheID.CAuthID# 
			 AND BOBName In ('accntlogin','acntpassword') 
			)
		ORDER BY S.SortOrder, A.DBFieldName 
	</cfquery>
	<cfset LocAccntPlanID = AccntPlanID>
	<cfinclude template="runvarvalues.cfm">

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
		<tr>
			<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Authentication</font></th>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
		</tr>
	</cfoutput>
	<form method="post" action="accntmanage6.cfm">
		<cfoutput>
			<cfif IsDefined("UNNoPass")>
				<tr bgcolor="#tbclr#">
					<td colspan="2">#UNNoPass#
					<cfif PWNoPass Is Not "">#PWNoPass#</cfif></td>
				</tr>
			</cfif>
			<input type="hidden" name="AuthDomainID" value="#AuthDomainID#">
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Login</td>
				<td bgcolor="#tdclr#"><cfif GetPlanDefs.AuthAddChars Is Not ""><b>#Trim(GetPlanDefs.AuthAddChars)#</b></cfif><input type="text" name="LoginFieldName" <cfif IsDefined("LoginFieldName")>value="#LoginFieldName#"</cfif> maxlength="#GetPlanDefs.AuthMaxLogin#"><cfif GetPlanDefs.AuthSufChars Is Not ""><b>#Trim(GetPlanDefs.AuthSufChars)#</b></cfif><br>
				<font size="2">Login must be between #GetPlanDefs.AuthMinLogin# and #GetPlanDefs.AuthMaxLogin# characters long.
				<cfif GetPlanDefs.LowerAWYN Is 1><br>Login must be all lowercase.</cfif></font></td>
				<input type="Hidden" name="AuthAddChars" value="#GetPlanDefs.AuthAddChars#">
				<input type="Hidden" name="AuthSufChars" value="#GetPlanDefs.AuthSufChars#">
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Password</td>
				<td bgcolor="#tdclr#"><input type="text" name="PasswFieldName" <cfif IsDefined("PasswFieldName")>value="#PasswFieldName#"</cfif> size="35" maxlength="#GetPlanDefs.AuthMaxPassw#"><br>
				<font size="2">Passwords must be between #GetPlanDefs.AuthMinPassw# and #GetPlanDefs.AuthMaxPassw# characters long.
				<cfif GetPlanDefs.AuthMixPassw Is 1><br>Passwords must contain both numbers and letters.</cfif></font></td>
			</tr>
		</cfoutput>
		<cfif GetOpts.OverRide Is 1>
			<cfloop query="GetFdValues">
				<cfif DBFieldName Is "AccountType">
					<cfsetting enablecfoutputonly="Yes">
						<cfquery name="GetDS" datasource="#pds#">
							SELECT DBName 
							FROM CustomAuthSetup 
							WHERE CAuthID = #CAuthID# 
							AND DBType = 'Ds' 
							AND ActiveYN = 1 
							AND BOBName = 'authodbc' 
						</cfquery>
						<cfif GetDS.DBName Is Not "">
							<cfquery name="GetTable" datasource="#pds#">
								SELECT DBName 
								FROM CustomAuthSetup 
								WHERE CAuthID = #CAuthID# 
								AND DBType = 'Tb' 
								AND ActiveYN = 1 
								AND BOBName = 'tbacnttypes' 
							</cfquery>
							<cfif GetTable.DBName Is Not "">
								<cfquery name="GetFields" datasource="#pds#">
									SELECT DBName 
									FROM CustomAuthSetup 
									WHERE CAuthID = #CAuthID# 
									AND DBType = 'Fd' 
									AND ActiveYN = 1 
									AND BOBName = 'acnttypesfd' 
								</cfquery>
								<cfif GetFields.DBName Is Not "">
									<cfquery name="AllTheTypes" datasource="#GetDS.DBName#">
										SELECT #GetFields.DBName# As AccntType 
										FROM #GetTable.DBName# 
										ORDER BY #GetFields.DBName# 
									</cfquery>
								</cfif>
							</cfif>
						</cfif>
					<cfsetting enablecfoutputonly="No">
					<tr>
						<cfoutput>
							<td bgcolor="#tbclr#" align="right">#Descrip1#</td>
						</cfoutput>
						<cfif IsDefined("AllTheTypes")>
							<cfoutput><td bgcolor="#tdclr#"></cfoutput><select name="AccountType">
								<cfloop query="AllTheTypes">
									<cfoutput><option <cfif GetPlanDefs.PlanType Is AccntType>selected</cfif> value="#AccntType#">#AccntType#</cfoutput>
								</cfloop>
							</select></td>
						<cfelse>
							<cfset ATValue = DataNeed>
							<cfset Pos1 = ListFind(FindList,DataNeed)>
							<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
								<cfset ATValue = ListGetAt(ReplList,Pos1)>
							</cfif>
							<cfif ATValue Is ")*N/A*(">
								<cfset ATValue = GetPlanDefs.PlanType>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="Text" name="AccountType" value="#ATValue#"></td>
							</cfoutput>
						</cfif>
					</tr>
				<cfelseif DBFieldName Is "LoginLimit">
					<cfset ATValue = DataNeed>
					<cfset Pos1 = ListFind(FindList,DataNeed)>
					<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
						<cfset ATValue = ListGetAt(ReplList,Pos1)>
					</cfif>
					<cfif ATValue Is ")*N/A*(">
						<cfset ATValue = GetPlanDefs.LoginLimit>
					</cfif>
					<tr>
						<cfoutput>
							<td bgcolor="#tbclr#" align="right">Login limit</td>
							<td bgcolor="#tdclr#"><input type="Text" name="LoginLimit" value="#ATValue#"></td>
						</cfoutput>
					</tr>
				<cfelseif DBFieldName Is "IdleTime">
					<cfset ATValue = DataNeed>
					<cfset Pos1 = ListFind(FindList,DataNeed)>
					<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
						<cfset ATValue = ListGetAt(ReplList,Pos1)>
					</cfif>
					<cfif ATValue Is ")*N/A*(">
						<cfset ATValue = GetPlanDefs.Max_Idle1>
					</cfif>
					<tr>
						<cfoutput>
							<td bgcolor="#tbclr#" align="right">Idle Time Limit</td>
							<td bgcolor="#tdclr#"><input type="Text" name="IdleTime" value="#ATValue#"></td>
						</cfoutput>
					</tr>
				<cfelseif DBFieldName Is "MaxConnect">
					<cfset ATValue = DataNeed>
					<cfset Pos1 = ListFind(FindList,DataNeed)>
					<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
						<cfset ATValue = ListGetAt(ReplList,Pos1)>
					</cfif>
					<cfif ATValue Is ")*N/A*(">
						<cfset ATValue = GetPlanDefs.Max_Connect1>
					</cfif>
					<tr>
						<cfoutput>
							<td bgcolor="#tbclr#" align="right">Maximum Connect Time</td>
							<td bgcolor="#tdclr#"><input type="Text" name="MaxConnect" value="#ATValue#"></td>
						</cfoutput>
					</tr>
				<cfelse>
					<cfset ATValue = DataNeed>
					<cfset Pos1 = ListFind(FindList,DataNeed)>
					<cfif (Pos1 GT 0) AND (Pos1 LTE ListLen(FindList))>
						<cfset ATValue = ListGetAt(ReplList,Pos1)>
					</cfif>
					<cfif ATValue Is ")*N/A*(">
						<cfset ATValue = DataNeed>
					</cfif>
					<tr>
						<cfoutput>
							<td bgcolor="#tbclr#" align="right">#Descrip1#</td>
							<td bgcolor="#tdclr#"><input type="Text" name="#DBFieldName#" value="#ATValue#"></td>
						</cfoutput>
					</tr>
				</cfif>
				<cfoutput>
					<cfif (DataType Is "Number") AND (CFVarYN Is 1)>
						<input type="hidden" name="#DBFieldName#_Int" value="Please enter a number for #Descrip1#.">
					<cfelseif (DataType Is "Number") AND (CFVarYN Is 0)>
						<input type="hidden" name="#DBFieldName#_float" value="Please enter a number for #Descrip1#.">
					<cfelseif DataType Is "Date">
						<input type="hidden" name="#DBFieldName#_date" value="Please enter a valid date for #Descrip1#.">
					</cfif>
				</cfoutput>
			</cfloop>
		<cfelse>
			<cfloop query="GetFdValues">
				<cfif DBFieldName Is "AccountType">
					<cfoutput>
						<input type="Hidden" name="#DBFieldName#" value="#GetPlanDefs.PlanType#">
					</cfoutput>
				<cfelseif DBFieldName Is "LoginLimit">
					<cfoutput>
						<input type="Hidden" name="#DBFieldName#" value="#GetPlanDefs.LoginLimit#">
					</cfoutput>
				<cfelseif DBFieldName Is "IdleTime">
					<cfoutput>
						<input type="Hidden" name="#DBFieldName#" value="#GetPlanDefs.Max_Idle1#">
					</cfoutput>
				<cfelseif DBFieldName Is "MaxConnect">
					<cfoutput>
						<input type="Hidden" name="#DBFieldName#" value="#GetPlanDefs.Max_Connect1#">
					</cfoutput>
				</cfif>
			</cfloop>
		</cfif>
		<cfoutput>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddAuthDB" border="0"></th>
			</tr>
			<input type="hidden" name="PlanID" value="#GetPlanDefs.PlanID#">
			<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
		</cfoutput>
	</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif> 
 