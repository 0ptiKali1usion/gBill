<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 11/02/99 --->
<!--- accntmanage6.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfif IsDefined("AddNewNonDB.x")>
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
		SELECT DomainName 
		FROM Domains 
		WHERE DomainID = #AuthDomainID# 
	</cfquery>
	<!--- Do the Checks --->
	<cfset CheckUserName = UserName>
	<cfset CheckPassword = Password>
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
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AuthID 
		FROM AccountsAuth 
		WHERE UserName = '#CheckUserName#' 
		AND DomainName = '#SelDomainName.DomainName#' 
	</cfquery>
	<cfif CheckFirst.Recordcount GT 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName is already taken.<br>">
	</cfif>
	<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckUserName, 1)) gt 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - UserName can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
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
			<cfquery name="GetInfo" datasource="#pds#">
				SELECT A.AccountID 
				FROM Accounts A 
				WHERE AccountID = 
					(SELECT AccountID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#) 
			</cfquery>
			<cfquery name="GetPlanInfo" datasource="#pds#">
				SELECT BaseHours, HoursUp, RollBackTo, EMailWarn 
				FROM Plans P 
				WHERE P.PlanID = 
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#) 
			</cfquery>
			<cfset BaseSeconds = GetPlanInfo.BaseHours * 3600>
			<cfset BaseWarn = GetPlanInfo.EMailWarn * 3600>
			<cfquery name="GetDomain" datasource="#pds#">
				SELECT DomainName 
				FROM Domains 
				WHERE DomainID = #AuthDomainID#
			</cfquery>
			<cfif IsDefined("Filter1")>
				<cfset Field1 = Filter1>
			<cfelse>
				<cfset Field1 = "">
			</cfif>
			<cfif IsDefined("IP_Address")>
				<cfset Field2 = IP_Address>
			<cfelse>
				<cfset Field2 = "">
			</cfif>
			<cfif IsDefined("Max_Idle")>
				<cfset Field3 = Max_Idle>
			<cfelse>
				<cfset Field3 = "">
			</cfif>
			<cfif IsDefined("Max_Connect")>
				<cfset Field4 = Max_Connect>
			<cfelse>
				<cfset Field4 = "">
			</cfif>
			<cfif IsDefined("Max_Logins")>
				<cfset Field5 = Max_Logins>
			<cfelse>
				<cfset Field5 = "">
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AuthID 
				FROM AccountsAuth 
				WHERE UserName = '#CheckUserName#' 
				AND DomainName = '#GetDomain.DomainName#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="BOBAuth" datasource="#pds#">
					INSERT INTO AccountsAuth 
					(AccountID, DomainID, DomainName, UserName, Password, 
					 Filter1, IP_Address, Max_Idle, Max_Connect, Max_Logins, 
					 EMailedYN, SecondsLeft, EMailSecsLeft, MonthTotalTime, 
					 AccntPlanID, FilterLockYN, WarningTimeLeft, WarningAction) 
					VALUES 
					(#GetInfo.AccountID#, #AuthDomainID#, '#GetDomain.DomainName#', '#CheckUserName#', '#CheckPassword#',
					 <cfif Field1 Is "">Null<cfelse>'#Filter1#'</cfif>, 
					 <cfif Field2 Is "">Null<cfelse>'#IP_Address#'</cfif>, 
					 <cfif Field3 Is "">Null<cfelse>#Max_Idle#</cfif>, 
					 <cfif Field4 Is "">Null<cfelse>#Max_Connect#</cfif>, 
					 <cfif Field5 Is "">Null<cfelse>#Max_Logins#</cfif>, 
					 0, #BaseSeconds#, #BaseWarn#, #BaseSeconds#, #AccntPlanID#, 0, 0, #GetPlanInfo.HoursUp#)
				</cfquery>
			</cfif>
			<cfquery name="NewID" datasource="#pds#">
				SELECT AuthID 
				FROM AccountsAuth 
				WHERE UserName = '#CheckUserName#' 
			</cfquery>
		<cfquery name="GetTheID" datasource="#pds#">
			SELECT CAuthID 
			FROM Domains 
			WHERE DomainID = #AuthDomainID#
		</cfquery>
		<cfset CreateAccount = GetInfo.AccountID>
		<cfset LocAuthID = NewID.AuthID>
		<cfset LocCAuthID = GetTheID.CAuthID>
		<cfset LocAccntPlanID = AccntPlanID>
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
			<cfset LocAuthID = NewID.AuthID>
			<cfset LocCAuthID = GetTheID.CAuthID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extcreateauth.cfm"))>
			<cfset SendID = NewID.AuthID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extcreateauth.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif> 
		<cfsetting enablecfoutputonly="no">
		<cfset tab = 2>
		<cfinclude template="accntmanage2.cfm">
		<cfabort>
	</cfif>
	<cfset AuthID = 0>
</cfif>

<cfif IsDefined("AddAuthDB.x")>
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CAuthID 
		FROM Domains 
		WHERE DomainID = #AuthDomainID#
	</cfquery>
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
		SELECT AuthServer 
		FROM Domains 
		WHERE DomainID = #AuthDomainID# 
	</cfquery>
	<!--- Do the Checks --->
	<cfset CheckUserName = Evaluate("#LoginFieldName#")>
	<cfset CheckPassword = Evaluate("#PasswFieldName#")>
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
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AuthID 
		FROM AccountsAuth 
		WHERE UserName = '#CheckUserName#' 
		AND DomainName = '#SelDomainName.AuthServer#' 
	</cfquery>
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
				SELECT BaseHours, HoursUp, RollBackTo, EMailWarn 
				FROM Plans P 
				WHERE P.PlanID = 
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID = #AccntPlanID#) 
			</cfquery>
			<cfset BaseSeconds = GetPlanInfo.BaseHours * 3600>
			<cfset BaseWarn = GetPlanInfo.EMailWarn * 3600>
			<cfquery name="GetDomain" datasource="#pds#">
				SELECT AuthServer 
				FROM Domains 
				WHERE DomainID = #AuthDomainID#
			</cfquery>
		 	<cfquery name="GetFdValues" datasource="#pds#">
				SELECT *
				FROM CustomAuthSetup 
				WHERE DBType = 'Fd' 
				AND DBName Is Not Null 
				AND CAuthID = #GetTheID.CAuthID# 
				AND ForTable = 
					(SELECT ForTable 
					 FROM CustomAuthSetup 
					 WHERE BOBName = 'Accounts' 
					 AND CAuthID = #GetTheID.CAuthID# ) 
				ORDER BY SortOrder
			</cfquery>
			<cfloop query="GetFDValues">
				<cfif IsDefined("#DBName#Val")>
					<cfset "#BOBName#Value" = Evaluate("#DBName#Val")>
				</cfif>
			</cfloop>
			<cfif IsDefined("acnttypeValue")>
				<cfset PlanTypeValue = acnttypeValue>
			</cfif>
			<cfif IsDefined("loginlimitValue")>
				<cfset LLFieldValue = loginlimitValue>
			</cfif>
			<cfif IsDefined("custipaddressValue")>
				<cfset IPFieldValue = custipaddressValue>
			</cfif>
			<cfif IsDefined("maxconnecttimeValue")>
				<cfset MCFieldValue = maxconnecttimeValue>
			</cfif>
			<cfif IsDefined("maxidletimeValue")>
				<cfset MIFieldValue = maxidletimeValue>
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AuthID 
				FROM AccountsAuth 
				WHERE UserName = '#CheckUserName#' 
				AND DomainName = '#GetDomain.AuthServer#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="BOBAuth" datasource="#pds#">
					INSERT INTO AccountsAuth 
					(AccountID, DomainID, DomainName, UserName, Password, 
					 Filter1, IP_Address, Max_Connect, Max_Idle, Max_Logins, 
					 EMailedYN, SecondsLeft, EMailSecsLeft, MonthTotalTime, 
					 AccntPlanID, FilterLockYN, WarningTimeLeft, WarningAction) 
					VALUES 
					(#GetInfo.AccountID#, #AuthDomainID#, '#GetDomain.AuthServer#', '#CheckUserName#', '#CheckPassword#',
					 <cfif IsDefined("PlanTypeValue")>'#PlanTypeValue#'<cfelse>Null</cfif>, 
					 <cfif IsDefined("IPFieldValue")>'#IPFieldValue#'<cfelse>Null</cfif>, 
					 <cfif IsDefined("MCFieldValue")>#MCFieldValue#<cfelse>Null</cfif>, 
					 <cfif IsDefined("MIFieldValue")>#MIFieldValue#<cfelse>Null</cfif>, 
					 <cfif IsDefined("LLFieldValue")>#LLFieldValue#<cfelse>Null</cfif>, 
					 0, #BaseSeconds#, #BaseWarn#, #BaseSeconds#, #AccntPlanID#, 0, 0, #GetPlanInfo.HoursUp#)
				</cfquery>
			</cfif>
			<cfquery name="NewID" datasource="#pds#">
				SELECT AuthID 
				FROM AccountsAuth 
				WHERE UserName = '#CheckUserName#' 
			</cfquery>
		<!--- Insert Into Radius DB --->
		<cfquery name="getvalues" datasource="#pds#">
			SELECT * 
			FROM CustomAuthSetup 
			WHERE CAuthID = #GetTheID.CAuthID# 
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
			<cfset LocAuthID = NewID.AuthID>
			<cfset LocCAuthID = GetTheID.CAuthID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extcreateauth.cfm"))>
			<cfset SendID = NewID.AuthID>
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
						<td>#DomDisp#</td>
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
 	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT *
		FROM CustomAuthSetup 
		WHERE DBType = 'Fd' 
		AND DBName Is Not Null 
		AND CAuthID = #GetTheID.CAuthID# 
		AND ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'Accounts' 
			 AND CAuthID = #GetTheID.CAuthID# ) 
		ORDER BY SortOrder
	</cfquery>
	<cfquery name="GetTbValue" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE BOBName = 'Accounts' 
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
	<cfif GetDSValue.DBName Is Not "">
		<form method="post" action="accntmanage6.cfm">
			<cfoutput>
				<cfif IsDefined("UNNoPass")>
					<tr bgcolor="#tbclr#">
						<td colspan="2">#UNNoPass#
						<cfif PWNoPass Is Not "">#PWNoPass#</cfif></td>
					</tr>
				</cfif>
				<input type="hidden" name="AuthDomainID" value="#AuthDomainID#">
			</cfoutput>
			<cfloop query="GetFdValues">
				<cfoutput>
					<tr bgcolor="#tbclr#" valign="top">
						<td align="right">#DBName#</td>
				</cfoutput>
						<cfif BOBName Is "AcntType">
							<cfif IsDefined("#DBName#Val")>
								<cfset ATValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset ATValue = GetPlanDefs.PlanType>
							</cfif>
							<cfif GetOpts.OverRide Is 1>
								<cfif TbAcntTypes Is "">
									<cfoutput>
										<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#ATValue#"></td>
									</cfoutput>
								<cfelse>
									<cfif IsDefined("SelectTypes")>
										<cfoutput>
											<td bgcolor="#tdclr#"><select name="#DBName#Val">
											<input type="hidden" name="PlanTypeField" value="#DBName#Val">
										</cfoutput>
												<cfoutput query="SelectTypes">
													<option <cfif TheTypesAvail Is ATValue>selected</cfif> value="#TheTypesAvail#">#TheTypesAvail#
												</cfoutput>
											</select></td>
									<cfelse>
										<cfoutput>
											<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#ATValue#"></td>
										</cfoutput>
									</cfif>
								</cfif>
							<cfelse>
								<cfoutput>
									<td bgcolor="#tdclr#">#GetPlanDefs.PlanType#</td>
									<input type="hidden" name="#DBName#Val" value="#ATValue#">
									<input type="hidden" name="PlanTypeField" value="#DBName#Val">
							</cfoutput>
							</cfif>
						<cfelseif BOBName Is "AccntLogin">
							<cfif IsDefined("#DBName#Val")>
								<cfset UNValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset UNValue = "">
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><cfif GetPlanDefs.AuthAddChars Is Not ""><b>#Trim(GetPlanDefs.AuthAddChars)#</b></cfif><input type="text" name="#DBName#Val" maxlength="#GetPlanDefs.AuthMaxLogin#" value="#UNValue#"><cfif GetPlanDefs.AuthSufChars Is Not ""><b>#Trim(GetPlanDefs.AuthSufChars)#</b></cfif><br>
								<font size="2">#DBName# must be between #GetPlanDefs.AuthMinLogin# and #GetPlanDefs.AuthMaxLogin# characters long.
								<cfif GetPlanDefs.LowerAWYN Is 1><br>#DBName# must be all lowercase.</cfif></font></td>
								<input type="hidden" name="LoginFieldName" value="#DBName#Val">
								<input type="Hidden" name="AuthAddChars" value="#GetPlanDefs.AuthAddChars#">
								<input type="Hidden" name="AuthSufChars" value="#GetPlanDefs.AuthSufChars#">
							</cfoutput>
						<cfelseif BOBName Is "AcntPassword">
							<cfif IsDefined("#DBName#Val")>
								<cfset PWValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset PWValue = "">
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="text" name="#DBName#Val" value="#PWValue#" maxlength="#GetPlanDefs.AuthMaxPassw#"><br>
								<font size="2">Passwords must be between #GetPlanDefs.AuthMinPassw# and #GetPlanDefs.AuthMaxPassw# characters long.
								<cfif GetPlanDefs.AuthMixPassw Is 1><br>Passwords must contain both numbers and letters.</cfif></font></td>
								<input type="hidden" name="PasswFieldName" value="#DBName#Val">
							</cfoutput>
						<cfelseif BOBName Is "LoginLimit">
							<cfif IsDefined("#DBName#Val")>
								<cfset PWValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset PWValue = GetPlanDefs.LoginLimit>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#PWValue#"></td>
								<input type="hidden" name="LLFieldName" value="#DBName#Val">
							</cfoutput>
						<cfelseif BOBName Is "MaxConnectTime">
							<cfif IsDefined("#DBName#Val")>
								<cfset PWValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset PWValue = GetPlanDefs.Max_Connect1>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="text" name="#DBName#Val" maxlength="25" value="#PWValue#"></td>
								<input type="hidden" name="MCFieldName" value="#DBName#Val">
							</cfoutput>
						<cfelseif BOBName Is "MaxIdleTime">
							<cfif IsDefined("#DBName#Val")>
								<cfset PWValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset PWValue = GetPlanDefs.Max_Idle1>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="text" name="#DBName#Val" maxlength="25" value="#PWValue#"></td>
								<input type="hidden" name="MIFieldName" value="#DBName#Val">
							</cfoutput>
						<cfelseif BOBName Is "CustIPAddress">
							<cfif (GetPlanDefs.AWStaticIPYN Is 1) OR (GetOpts.OverRide Is 1)>
								<cfif IsDefined("#DBName#Val")>
									<cfset PWValue = Evaluate("#DBName#Val")>
								<cfelse>
									<cfset PWValue = "">
								</cfif>
								<cfoutput>
									<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#PWValue#"></td>
									<input type="hidden" name="IPFieldName" value="#DBName#Val">
								</cfoutput>
							</cfif>
						<cfelseif BOBName Is "ExpireDate">
							<cfquery name="CheckFor" datasource="#pds#">
								SELECT DataNeed 
								FROM CustomAuthAccount 
								WHERE DBFieldName = '#DBName#' 
								AND CAuthID = #CAuthID# 
							</cfquery>
							<cfif TheExpireDate Is "">
								<cfset TheExpireDate = CheckFor.DataNeed>
							</cfif>
							<cfif Not IsDate(TheExpireDate)>
								<cfset TheExpireDate = DateAdd("yyyy",10,Now())>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#DateFormat(TheExpireDate, '#DateMask1#')#"></td>
								<input type="hidden" name="#DBName#Val_Date" value="Please enter the expiration date.">
							</cfoutput>						
						<cfelse>
							<cfif IsDefined("#DBName#Val")>
								<cfset PWValue = Evaluate("#DBName#Val")>
							<cfelse>
								<cfset PWValue = "">
							</cfif>
							<cfif DataType Is "date">
								<cfset PWValue = DateFormat(PWValue, '#Datemask1#')>
							</cfif>
							<cfquery name="CheckFor" datasource="#pds#">
								SELECT DataNeed 
								FROM CustomAuthAccount 
								WHERE DBFieldName = '#DBName#' 
								AND CAuthID = #CAuthID# 
							</cfquery>
							<cfif PWValue Is "">
								<cfset PWValue = CheckFor.DataNeed>
							</cfif>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="Text" name="#DBName#Val" maxlength="25" value="#PWValue#"></td>
							</cfoutput>
						</cfif>
					</tr>
					<cfoutput>
						<cfif (DataType Is "Number") AND (CFVarYN Is 1)>
							<input type="hidden" name="#DBName#Val_Int" value="Please enter a number for #DBName#">
						<cfelseif (DataType Is "Number") AND (CFVarYN Is 0)>
							<input type="hidden" name="#DBName#Val_float" value="Please enter a number for #DBName#">
						<cfelseif DataType Is "Date">
							<input type="hidden" name="#DBName#Val_date" value="Please enter a valid date for #DBName#">
						</cfif>
					</cfoutput>
			</cfloop>
			<cfoutput>
				<tr>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddAuthDB" border="0"></th>
				</tr>
				<input type="hidden" name="PlanID" value="#GetPlanDefs.PlanID#">
				<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
			</cfoutput>
		</form>
	<cfelse>
		<form method="post" action="accntmanage6.cfm">
			<cfoutput>
				<cfif IsDefined("UNNoPass")>
					<tr bgcolor="#tbclr#">
						<td colspan="2">#UNNoPass#
						<cfif PWNoPass Is Not "">#PWNoPass#</cfif></td>
					</tr>
				</cfif>
				<tr>
					<td bgcolor="#tbclr#">UserName</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Username")>value="#UserName#"</cfif> name="UserName" maxlength="#GetPlanDefs.AuthMaxLogin#"></td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Password</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Password")>value="#Password#"</cfif> name="Password" maxlength="#GetPlanDefs.AuthMaxPassw#"></td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Filter</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Filter1")>value="#Filter1#"</cfif> name="Filter1" maxlength="50"></td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">IP Address</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("IP_Address")>value="#IP_Address#"</cfif> name="IP_Address" maxlength="25"></td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Max Idle Time</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Max_Idle")>value="#Max_Idle#"</cfif> name="Max_Idle" maxlength="25" size="10"> seconds</td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Max Connect Time</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Max_Connect")>value="#Max_Connect#"</cfif> name="Max_Connect" maxlength="25" size="10"> seconds</td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Max Logins</td>
					<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("Max_Logins")>value="#Max_Logins#"</cfif> name="Max_Logins" maxlength="25" size="5"></td>
				</tr>
				<tr>
					<th colspan="2"><input type="Image" src="images/addnew.gif" border="0" name="AddNewNonDB"></th>
				</tr>
				<input type="hidden" name="AuthDomainID" value="#AuthDomainID#">
				<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
				<input type="Hidden" name="UserName_Required" value="Please enter the Username for this authentication account.">
				<input type="Hidden" name="Password_Required" value="Please enter the password for this authentication account.">
			</cfoutput>
		</form>
	</cfif>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif> 
 