<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 11/02/99 --->
<!--- accntmanage4.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="GetTheID" datasource="#pds#">
	SELECT CAuthID 
	FROM Domains 
	WHERE DomainID = 
		(SELECT DomainID 
		 FROM AccountsAuth 
		 WHERE AuthID = #AuthID# )
</cfquery>
<cfset CAuthID = GetTheID.CAuthID>

<cfif IsDefined("UpdAuth.x")>
	<cfquery name="GetAuthValues" datasource="#pds#">
		SELECT UserName, AuthServer 
		FROM AccountsAuth 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfset TheUser = GetAuthValues.UserName>
	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT *
		FROM CustomAuthSetup 
		WHERE DBType = 'Fd' 
		AND ActiveYN = 1 
		AND CAuthID = #CAuthID# 
		AND ActiveYN = 1 
		AND BOBName NOT In ('acntpassword','accntlogin') 
		AND ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'Accounts'
			 AND CAuthID = #CAuthID# ) 
		ORDER BY SortOrder
	</cfquery>
	<cfquery name="UpdAuthDatabase" datasource="#AuthDs#">
		UPDATE #AuthTb# SET 
		<cfloop index="B3" from="1" to="#CounterRow#">
			<cfset FieldName = Evaluate("Custom#B3#Fd")>
			<cfset FieldValu = Evaluate("Custom#B3#")>
			<cfset FieldType = Evaluate("Custom#B3#Dt")>
			#FieldName# = 	
			<cfif FieldType Is "Number">
				<cfif Trim(FieldValu) Is "">NULL<cfelse>#FieldValu#</cfif>
			<cfelseif FieldType Is "Text">
				<cfif Trim(FieldValu) Is "">NULL<cfelse>'#FieldValu#'</cfif>
			<cfelseif FieldType Is "Date">
				<cfif Trim(FieldValu) Is "">NULL<cfelse>#CreateODBCDate(FieldValu)#</cfif>
			</cfif> 
			<cfif B3 Is Not CounterRow>,</cfif>
		</cfloop>
		WHERE #AuthLn# = '#TheUser#' 
	</cfquery>
	<cfquery name="UpdBOB" datasource="#pds#">
		UPDATE AccountsAuth SET 
		<cfif NewPlanID GT 0>
			AccntPlanID = #NewPlanID#, 
		</cfif>
		<cfloop index="B3" from="1" to="#CounterRow#">
			<cfset FieldName = Evaluate("Custom#B3#Bn")>
			<cfset EnterLoop = ListFindNoCase("LoginLimit,AcntType,CustIPAddress,MaxIdleTime,MaxConnectTime","#FieldName#")>
			<cfif EnterLoop GT 0>
				<cfif FieldName Is "LoginLimit">
					<cfset TheFieldName = "Max_Logins">
				<cfelseif FieldName Is "AcntType">
					<cfset TheFieldName = "Filter1">
				<cfelseif FieldName Is "MaxConnectTime">
					<cfset TheFieldName = "Max_Connect">
				<cfelseif FieldName Is "MaxIdleTime">
					<cfset TheFieldName = "Max_Idle">
				<cfelseif FieldName Is "CustIPAddress">
					<cfset TheFieldName = "IP_Address">								
				</cfif>
				<cfset FieldValu = Evaluate("Custom#B3#")>
				<cfset FieldType = Evaluate("Custom#B3#Dt")>
				#TheFieldName# = 	
				<cfif FieldType Is "Number">
					<cfif Trim(FieldValu) Is "">NULL<cfelse>#FieldValu#</cfif>
				<cfelseif FieldType Is "Text">
					<cfif Trim(FieldValu) Is "">NULL<cfelse>'#FieldValu#'</cfif>
				<cfelseif FieldType Is "Date">
					<cfif Trim(FieldValu) Is "">NULL<cfelse>#CreateODBCDate(FieldValu)#</cfif>
				</cfif> 
				, 
			</cfif>
		</cfloop>
		AuthServer = '#GetAuthValues.AuthServer#' 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfset RunScript = 1>
</cfif>
<cfif IsDefined("UpdBOB.x")>
	<cfparam name="NewPlanID" default="0">
	<cfquery name="CheckOldIDs" datasource="#pds#">
		SELECT AccntPlanID, PlanID 
		FROM AccntPlans 
		WHERE AccntPlanID = 
			(SELECT AccntPlanID 
			 FROM AccountsAuth 
			 WHERE AuthID = #AuthID#) 
	</cfquery>
	<cfset CheckOldPlanID = CheckOldIds.PlanID>
	<cfif NewPlanID GT 0>
		<cfset AccntPlanID = NewPlanID>
	</cfif>
	<cfquery name="UpdBOBAuth" datasource="#pds#">
		UPDATE AccountsAuth SET 
		<cfif NewPlanID GT 0>
			AccntPlanID = #NewPlanID#, 
		</cfif>
		Filter1 = '#Trim(Filter1)#', 
		IP_Address = '#Trim(IP_Address)#', 
		Max_Idle = #Max_Idle#, 
		Max_Connect = #Max_Connect#, 
		Max_Logins = #Max_Logins# 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfset RunScript = 1>
</cfif>
<cfif IsDefined("RunScript")>
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
		<cfquery name="GetUserName" datasource="#pds#">
			SELECT UserName 
			FROM AccountsAuth 
			WHERE AuthID = #AuthID# 
		</cfquery>
		<cfset BOBHistMess = "#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the auth account: #GetUserName.UserName# for #GetWhoName.FirstName# #GetWhoName.LastName#.">
		<cfif IsDefined("CheckOldPlanID")>
			<cfif NewPlanID GT 0>
				<cfquery name="OldPlanName" datasource="#pds#">
					SELECT PlanDesc 
					FROM Plans 
					WHERE PlanID = #CheckOldPlanID# 
				</cfquery>
				<cfquery name="NewPlanName" datasource="#pds#">
					SELECT PlanDesc 
					FROM Plans 
					WHERE PlanID = #NewPlanID# 
				</cfquery>
				<cfset BOBHistMess = BOBHistMess & "  The account was moved from #OldPlanName.PlanDesc# to #NewPlanName.PlanDesc#.">
			</cfif>
		</cfif>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#GetWhoName.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			 '#BOBHistMess#')
		</cfquery>
	</cfif>	
	<!---  Scripts  --->
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntmanage4.cfm' 
		AND L.LocationAction = 'Change' 
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
	<cfif FileExists(ExpandPath("external#OSType#extchangeauth.cfm"))>
		<cfset SendID = AuthID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="external#OSType#extchangeauth.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfsetting enablecfoutputonly="no">
 	<cfif IsDefined("ReturnTo")>
		<cfinclude template="#returnto#">
	<cfelse>
		<cfinclude template="accntmanage2.cfm">
	</cfif>
	<cfabort>
</cfif>
<cfquery name="AuthInfo" datasource="#pds#">
	SELECT * 
	FROM AccountsAuth 
	WHERE AuthID = #AuthID# 
</cfquery>
<cfquery name="SelectedPlan" datasource="#pds#">
	SELECT P.PlanID, P.PlanDesc, A.AccntPlanID 
	FROM Plans P, AccntPlans A
	WHERE P.PlanID = A.PlanID 
	AND A.AccntPlanID = #AccntPlanID# 
</cfquery>
<cfquery name="OtherPlans" datasource="#pds#">
	SELECT AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber, P.AWStaticIPYN, Count(A.AuthID) as IntNumber 
	FROM Plans P, AccntPlans AP, AccountsAuth A 
	WHERE P.PlanID = AP.PlanID 
	AND A.AccntPlanID = AP.AccntPlanID 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND AP.AccntPlanID <> #AccntPlanID# 
	GROUP BY AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber, P.AWStaticIPYN 
	HAVING Count(A.AuthID) < P.AuthNumber 
	OR Count(A.AuthID) < AP.AuthAccounts 
	UNION 
	SELECT AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber,  P.AWStaticIPYN, 0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID <> #AccntPlanID# 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND (P.AuthNumber > 0 OR AP.AuthAccounts > 0) 
	AND AP.AccntPlanID NOT IN 
		(SELECT AccntPlanID 
		 FROM AccountsAuth)
	ORDER BY P.PlanDesc
</cfquery>
<cfquery name="GetDSValue" datasource="#pds#">
	SELECT * 
	FROM CustomAuthSetup 
	WHERE BOBName = 'AuthODBC' 
	AND ActiveYN = 1 
	AND CAuthID = #CAuthID# 
</cfquery>
<cfquery name="GetFdValues" datasource="#pds#">
	SELECT *
	FROM CustomAuthSetup 
	WHERE DBType = 'Fd' 
	AND ActiveYN = 1 
	AND CAuthID = #CAuthID# 
	AND ActiveYN = 1 
	AND BOBName NOT In ('acntpassword') 
	AND ForTable = 
		(SELECT ForTable 
		 FROM CustomAuthSetup 
		 WHERE BOBName = 'Accounts'
		 AND CAuthID = #CAuthID# ) 
	ORDER BY SortOrder
</cfquery>
<cfquery name="GetUNValue" datasource="#pds#">
	SELECT DBName
	FROM CustomAuthSetup 
	WHERE DBType = 'Fd' 
	AND CAuthID = #CAuthID# 
	AND ActiveYN = 1 
	AND BOBName In ('accntlogin') 
	AND ForTable = 
		(SELECT ForTable 
		 FROM CustomAuthSetup 
		 WHERE BOBName = 'Accounts'
		 AND CAuthID = #CAuthID# ) 
</cfquery>
<cfquery name="GetTbValue" datasource="#pds#">
	SELECT DBName 
	FROM CustomAuthSetup 
	WHERE BOBName = 'Accounts' 
	AND ActiveYN = 1 
	AND CAuthID = #CAuthID# 
</cfquery>
<cfif (GetUNValue.DBName Is Not "") AND (GetDSValue.DBName Is Not "") 
  AND (GetTbValue.DBName Is Not "") AND (GetFdValues.RecordCount GT 0)>
	<cfquery name="AuthDBValues" datasource="#GetDSValue.DBName#">
		SELECT #ValueList(GetFdValues.DBName)# 
		FROM #GetTbValue.DBName# 
		WHERE #GetUNValue.DBName# = '#AuthInfo.UserName#' 
	</cfquery>
	<cfquery name="GetBOBFields" datasource="#pds#">
		SELECT BOBName, DBName 
		FROM CustomAuthSetup 
		WHERE DBName In (#QuotedValueList(GetFdValues.DBName)#) 
		AND CAuthID = #CAuthID# 
		AND ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'accounts' 
			 AND CAuthID = #CAuthID#)
	</cfquery>
<cfelse>
	<cfquery name="BOBDBValues" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AuthID = #AuthID# 
	</cfquery>
</cfif>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Authentication Editor</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif IsDefined("ReturnTo")>
	<cfoutput>
	<form method="post" action="#returnto#">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">
		<input type="hidden" name="page" value="#page#">
	</cfoutput>
<cfelse>
	<form method="post" action="accntmanage2.cfm">
</cfif>
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AuthInfo.AccntPlanID#"></cfoutput>
	<input type="hidden" name="Tab" value="2">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#AuthInfo.UserName#</font></th>
	</tr>
</cfoutput>
<form method="post" action="accntmanage4.cfm">
	<cfif OtherPlans.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th bgcolor="#thclr#" colspan="2">#SelectedPlan.PlanDesc#</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Change To</td>
		</cfoutput>
				<td><select name="NewPlanID">
					<cfoutput><option value="0">Leave on #SelectedPlan.PlanDesc#</cfoutput>
					<cfoutput query="OtherPlans">
						<option <cfif PlanID Is SelectedPlan.PlanID>selected</cfif> value="#AccntPlanID#">#AccntPlanID# #PlanDesc#
					</cfoutput>
				</select></td>
			</tr>
	</cfif>
	<cfif IsDefined("AuthDBValues")>
		<cfoutput>
			<input type="Hidden" name="AuthDs" value="#GetDSValue.DBName#">
			<input type="Hidden" name="AuthTb" value="#GetTbValue.DBName#">
			<input type="Hidden" name="AuthLn" value="#GetUNValue.DBName#">
		</cfoutput>
		<cfset CounterRow = 0>
		<cfloop query="GetFdValues">
			<cfif BOBName Is "AccntLogin">
			<cfelseif BOBName Is "acnttype">
				<cfset CounterRow = CounterRow + 1>
				<cfsetting enablecfoutputonly="yes">
					<cfquery name="GetTypes" datasource="#pds#">
						SELECT * 
						FROM CustomAuthSetup 
						WHERE ActiveYN = 1 
						AND CAuthID = #CAuthID# 
						AND ForTable = 
							(SELECT ForTable 
							 FROM CustomAuthSetup 
							 WHERE BOBName = 'tbacnttypes' 
							 AND CAuthID = #CAuthID#)
					</cfquery>
					<cfloop query="GetTypes">
						<cfset "#BobName#" = DBName>
					</cfloop>
					<cfif (Trim(AcntTypesFd) Is Not "") AND (Trim(TbAcntTypes) Is Not "") AND (GetDSValue.DBName Is Not "")>
						<cfquery name="SelectTypes" datasource="#GetDSValue.DBName#">
							SELECT #AcntTypesFd# AS TheTypesAvail 
							FROM #TbAcntTypes# 
							ORDER BY #AcntTypesFd# 
						</cfquery>
					</cfif>
				<cfsetting enablecfoutputonly="No">
				<cfoutput>
				<tr bgcolor="#tdclr#">
				</cfoutput>
					<cfset DispStr = Evaluate("AuthDBValues.#DBName#")>
					<cfoutput>
						<td align="right" bgcolor="#tbclr#">#Descrip1#</td>
						<input type="Hidden" name="Custom#CounterRow#Fd" value="#DBName#">
						<input type="Hidden" name="Custom#CounterRow#Dt" value="#DataType#">
						<input type="Hidden" name="Custom#CounterRow#Bn" value="#BOBName#">
					</cfoutput>
					<cfif IsDefined("SelectTypes")>
						<cfoutput><td><select name="Custom#CounterRow#"></cfoutput>
							<cfoutput query="SelectTypes">
								<option <cfif TheTypesAvail Is DispStr>selected</cfif> value="#TheTypesAvail#">#TheTypesAvail#
							</cfoutput>
						</select></td>
					<cfelse>
						<cfoutput>
							<td bgcolor="#tdclr#"><input type="text" name="Custom#CounterRow#" value="#DispStr#"></td>
						</cfoutput>
					</cfif>
				</tr>			
			<cfelse>
				<cfset CounterRow = CounterRow + 1>
				<tr>
					<cfset DispStr = Evaluate("AuthDBValues.#DBName#")>
					<cfif DataType Is "Date">
						<cfset DispStr = LSDateFormat(DispStr,'#DateMask1#')>
					</cfif>
					<cfoutput>
						<td align="right" bgcolor="#tbclr#">#Descrip1#</td>
						<td bgcolor="#tdclr#"><input type="Text" name="Custom#CounterRow#" value="#DispStr#"></td>
						<input type="Hidden" name="Custom#CounterRow#Fd" value="#DBName#">
						<input type="Hidden" name="Custom#CounterRow#Dt" value="#DataType#">
						<input type="Hidden" name="Custom#CounterRow#Bn" value="#BOBName#">
					</cfoutput>
				</tr>
			</cfif>
		</cfloop>
		<cfoutput><input type="Hidden" name="CounterRow" value="#CounterRow#"></cfoutput>
		<tr>
			<th colspan="2"><input type="image" src="images/update.gif" name="UpdAuth" border="0"></th>
		</tr>
	<cfelse>
		<cfoutput query="BOBDBValues">
			<tr>
				<td bgcolor="#tbclr#" align="right">Account Type</td>
				<td bgcolor="#tdclr#"><input type="text" name="Filter1" value="#Filter1#" maxlength="50"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">IP Address</td>
				<td bgcolor="#tdclr#"><input type="text" name="IP_Address" value="#IP_Address#" maxlength="25"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Login Limit</td>
				<td bgcolor="#tdclr#"><input type="text" name="Max_Logins" value="#Max_Logins#"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Idle Limit</td>
				<td bgcolor="#tdclr#"><input type="text" name="Max_Idle" value="#Max_Idle#"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Connect Limit</td>
				<td bgcolor="#tdclr#"><input type="text" name="Max_Connect" value="#Max_Connect#"></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/update.gif" name="UpdBOB" border="0"></th>
			</tr>
		</cfoutput>
	</cfif>
	<cfoutput>
		<input type="hidden" name="AuthID" value="#AuthID#">
		<input type="hidden" name="AccntPlanID" value="#AuthInfo.AccntPlanID#">
		<input type="hidden" name="Tab" value="2">
	</cfoutput>
	<cfif IsDefined("ReturnTo")>
		<cfoutput>
			<input type="hidden" name="returnto" value="#returnto#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="page" value="#page#">
		</cfoutput>
	</cfif>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 