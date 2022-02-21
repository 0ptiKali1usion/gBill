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
<cfif IsDefined("UpdBOB.x")>
	<cfquery name="UpdBOBAuth" datasource="#pds#">
		UPDATE AccountsAuth SET 
		Filter1 = '#Trim(Filter1)#', 
		IP_Address = '#Trim(IP_Address)#', 
		Max_Idle = #Max_Idle#, 
		Max_Connect = #Max_Connect#, 
		Max_Logins = #Max_Logins#, 
		AccntPlanID = #NewPlanID# 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfset AccntPlanID = NewPlanID>
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
<cfif IsDefined("UpdAuth.x")>
	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT *
		FROM CustomAuthSetup 
		WHERE DBType = 'Fd' 
		AND BOBName <> 'accntlogin' 
		AND BOBName <> 'acntpassword' 
		AND DBName Is Not Null 
		AND CAuthID = #GetTheID.CAuthID# 
		AND ForTable = 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE BOBName = 'Accounts'
			 AND CAuthID = #GetTheID.CAuthID#) 
		ORDER BY SortOrder
	</cfquery>
	<cfquery name="GetDSValue" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE BOBName = 'AuthODBC'
		AND CAuthID = #GetTheID.CAuthID# 
	</cfquery>
	<cfquery name="GetTbValue" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE BOBName = 'Accounts' 
		AND CAuthID = #GetTheID.CAuthID# 
	</cfquery>
	<cfloop query="GetFdValues">
		<cfset "#BobName#" = DBName>
	</cfloop>
	<cfif GetFDValues.Recordcount GT 0>
		<cfquery name="CheckFirst" datasource="#GetDSValue.DBName#">
			SELECT * 
			FROM #GetTbValue.DBName# 
			WHERE #LoginFieldName# = '#LoginUserName#' 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="GetPassField" datasource="#pds#">
				SELECT *
				FROM CustomAuthSetup 
				WHERE DBType = 'Fd' 
				AND BOBName = 'acntpassword' 
				AND DBName Is Not Null 
				AND CAuthID = #GetTheID.CAuthID# 
				AND ForTable = 
					(SELECT ForTable 
					 FROM CustomAuthSetup 
					 WHERE BOBName = 'Accounts'
					 AND CAuthID = #GetTheID.CAuthID#) 
				ORDER BY SortOrder
			</cfquery>
			<cfquery name="Getpassword" datasource="#pds#">
				SELECT Password 
				FROM AccountsAuth 
				WHERE AuthID = #AuthID# 
			</cfquery>
			<cfquery name="UpdRadius" datasource="#GetDSValue.DBName#">
				INSERT INTO #GetTbValue.DBName# 
				(<cfoutput query="GetFdValues">
					<cfif IsDefined("#DBName#DT")>
						<cfset DataType1 = Evaluate("#DBName#DT")>
						<cfset DataValue1 = Evaluate("#DBName#Val")>
						#DBName#, 
					</cfif>
				</cfoutput>#LoginFieldName#, #GetPassField.DBName# )
				VALUES 
				(<cfoutput query="GetFdValues">
					<cfif IsDefined("#DBName#DT")>
						<cfset DataType1 = Evaluate("#DBName#DT")>
						<cfset DataValue1 = Evaluate("#DBName#Val")>
						<cfif DataType1 Is "Text">
							<cfif Trim(DataValue1) Is "">Null<cfelse>'#Trim(DataValue1)#'</cfif>
						<cfelseif DataType1 Is "Number">
							<cfif Trim(DataValue1) Is "">Null<cfelse>#DataValue1#</cfif>
						<cfelseif DataType1 Is "Date">
							<cfif Not IsDate(DataValue1)>Null<cfelse>#CreateODBCDateTime(DataValue1)#</cfif>
						</cfif>
						,
					</cfif>
				</cfoutput>'#LoginUserName#', '#Getpassword.Password#' )
			</cfquery>
		<cfelse>
			<cfquery name="UpdRadius" datasource="#GetDSValue.DBName#">
				UPDATE #GetTbValue.DBName# SET 
				<cfoutput query="GetFdValues">
					<cfif IsDefined("#DBName#DT")>
						<cfset DataType1 = Evaluate("#DBName#DT")>
						<cfset DataValue1 = Evaluate("#DBName#Val")>
						#DBName# = 
						<cfif DataType1 Is "Text">
							<cfif Trim(DataValue1) Is "">Null<cfelse>'#Trim(DataValue1)#'</cfif>
						<cfelseif DataType1 Is "Number">
							<cfif Trim(DataValue1) Is "">Null<cfelse>#DataValue1#</cfif>
						<cfelseif DataType1 Is "Date">
							<cfif Not IsDate(DataValue1)>Null<cfelse>#CreateODBCDateTime(DataValue1)#</cfif>
						</cfif>
						<cfif CurrentRow Is Not GetFDValues.Recordcount>,</cfif>
					</cfif>
				</cfoutput>
				WHERE #LoginFieldName# = '#LoginUserName#'		
			</cfquery>
		</cfif>
	</cfif>
	<cfquery name="UpdPlanID" datasource="#pds#">
		UPDATE AccountsAuth SET 
		AccntPlanID = #NewPlanID# 
		WHERE AuthID = #AuthID# 
	</cfquery>
	<cfif GetFDValues.Recordcount GT 0>
		<cfquery name="UpdAuthTable" datasource="#pds#">
			UPDATE AccountsAuth SET 
		 	<cfoutput query="GetFdValues">
				<cfset DataValue1 = Evaluate("#DBName#Val")>
				<cfif BOBName Is "acnttype">
					Filter1 = '#Trim(DataValue1)#', 
				<cfelseif BOBName Is "loginlimit">
					Max_Logins = #DataValue1#, 
				<cfelseif BOBName Is "maxidletime">
					Max_Idle = #DataValue1#, 
				<cfelseif BOBName Is "maxconnecttime">
					Max_Connect = #DataValue1#, 
				</cfif>
			</cfoutput>
			UserName = '#LoginUserName#' 
			WHERE AuthID = #AuthID#
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
	SELECT PlanID, PlanDesc 
	FROM Plans 
	WHERE PlanID = 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = 
		 	(SELECT AccntPlanID 
			 FROM AccountsAuth 
			 WHERE AuthID = #AuthID#)
		)
</cfquery>
<cfquery name="OtherPlans" datasource="#pds#">
	SELECT AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber, P.AWStaticIPYN, 
	Count(A.AuthID) as IntNumber 
	FROM Plans P, AccntPlans AP, AccountsAuth A 
	WHERE P.PlanID = AP.PlanID 
	AND A.AccntPlanID = AP.AccntPlanID 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND AP.AccntPlanID <> #AccntPlanID# 
	GROUP BY AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber, P.AWStaticIPYN 
	HAVING Count(A.AuthID) < P.AuthNumber 
	OR Count(A.AuthID) < AP.AuthAccounts 
	UNION 
	SELECT AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber,  P.AWStaticIPYN, 
	0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID <> #AccntPlanID# 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND (P.AuthNumber > 0 OR AP.AuthAccounts > 0) 
	AND AP.AccntPlanID NOT IN 
		(SELECT AccntPlanID 
		 FROM AccountsAuth)
	UNION 
	SELECT AP.AccntPlanID, AP.AuthAccounts, P.PlanID, P.PlanDesc, P.AuthNumber,  P.AWStaticIPYN, 
	0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID = #AccntPlanID# 
	ORDER BY P.PlanDesc
</cfquery>
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
	AND BOBName <> 'acntpassword' 
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
<cfloop query="GetFdValues">
	<cfset "#BobName#" = DBName>
	<cfset "#DBName#DataType" = DataType>
	<cfset "#DBName#BOBName" = BOBName>
</cfloop>
<cfif (IsDefined("accntlogin")) AND (GetDSValue.DBName Is Not "") AND (GetTbValue.DBName Is Not "")>
	<cfquery name="AuthDBValues" datasource="#GetDSValue.DBName#">
		SELECT 
		<cfloop query="GetFdValues">#GetFdValues.DBName#<cfif CurrentRow Is Not GetFdValues.Recordcount>,</cfif>
		</cfloop>
		FROM #GetTbValue.DBName# 
		WHERE #accntlogin# = '#AuthInfo.UserName#' 
	</cfquery>
<cfelse>
	<cfquery name="BOBDBValues" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE AuthID = #AuthID# 
	</cfquery>
</cfif>

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
					<cfoutput query="OtherPlans">
						<option <cfif PlanID Is SelectedPlan.PlanID>selected</cfif> value="#AccntPlanID#">#PlanDesc#
					</cfoutput>
				</select></td>
			</tr>
	</cfif>
	<cfif IsDefined("AuthDBValues")>
		<cfloop index="B5" list="#AuthDBValues.ColumnList#">
			<cfset OutStr = Evaluate("AuthDBValues.#B5#")>
			<cfset DataType = Evaluate("#B5#DataType")>
			<cfset BOBName = Evaluate("#B5#BOBName")>
				<cfif BOBName Is "accntlogin">
					<cfoutput>
						<input type="hidden" name="LoginFieldName" value="#B5#">
						<cfif AuthDBValues.RecordCount Is 0>
							<input type="hidden" name="LoginUserName" value="#AuthInfo.UserName#">
						<cfelse>
							<input type="hidden" name="LoginUserName" value="#OutStr#">
						</cfif>
					</cfoutput>
				<cfelseif BOBName Is "custipaddress">
					<cfif (GetOpts.OverRide Is 1) OR (OtherPlans.AWStaticIPYN Is 1)>
						<cfoutput>
							<tr bgcolor="#tbclr#">
								<cfset FirstChar = Mid(B5,1,1)>
								<cfset Len1 = Len(B5) - 1>
								<cfset NextChar = LCase(Right(B5,Len1))>
								<td align="right">#FirstChar##NextChar#</td>
								<td bgcolor="#tdclr#"><input type="text" name="#B5#Val" value="#OutStr#"></td>
								<input type="hidden" name="#B5#DT" value="#DataType#">
							</tr>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<input type="hidden" name="#B5#Val" value="#OutStr#">
							<input type="hidden" name="#B5#DT" value="#DataType#">
						</cfoutput>
					</cfif>
				<cfelseif BOBName Is "acnttype">
					<cfoutput>
						<tr bgcolor="#tbclr#">
							<cfset FirstChar = Mid(B5,1,1)>
							<cfset Len1 = Len(B5) - 1>
							<cfset NextChar = LCase(Right(B5,Len1))>
							<td align="right">#FirstChar##NextChar#</td>
					</cfoutput>
					<cfsetting enablecfoutputonly="yes">
						<cfquery name="GetTypes" datasource="#pds#">
							SELECT * 
							FROM CustomAuthSetup 
							WHERE ForTable = 
								(SELECT ForTable 
								 FROM CustomAuthSetup 
								 WHERE BOBName = 'tbacnttypes' 
								 AND CAuthID = #GetTheID.CAuthID#)
						</cfquery>
						<cfloop query="GetTypes">
							<cfset "#BobName#" = DBName>
						</cfloop>
						<cfif (Trim(AcntTypesFd) Is Not "") AND (Trim(TbAcntTypes) Is Not "") AND (GetDSValue.DBName Is Not "")>
							<cfquery name="SelectTypes" datasource="#GetDSValue.DBName#">
								SELECT #AcntTypesFd# AS TheTypesAvail 
								FROM #TbAcntTypes# 
							</cfquery>
						</cfif>
					<cfsetting enablecfoutputonly="no">
					<cfif IsDefined("SelectTypes")>
						<cfoutput>
							<td bgcolor="#tdclr#"><select name="#B5#Val">
						</cfoutput>
								<cfoutput query="SelectTypes">
									<option <cfif TheTypesAvail Is OutStr>selected</cfif> value="#TheTypesAvail#">#TheTypesAvail#
								</cfoutput>
							</select></td>
					<cfelse>
						<cfoutput>
							<td bgcolor="#tdclr#"><input type="text" name="#B5#Val" value="#OutStr#"></td>
						</cfoutput>
					</cfif>
						</tr>
						<cfoutput><input type="hidden" name="#B5#DT" value="#DataType#"></cfoutput>
				<cfelse>
					<cfoutput>
						<tr bgcolor="#tbclr#">
							<cfset FirstChar = Mid(B5,1,1)>
							<cfset Len1 = Len(B5) - 1>
							<cfset NextChar = LCase(Right(B5,Len1))>
							<td align="right">#FirstChar##NextChar#</td>
					</cfoutput>
					<cfif DataType Is "Date">
						<cfoutput>
							<td bgcolor="#tdclr#"><input type="text" name="#B5#Val" value="#LSDateFormat(OutStr, '#DateMask1#')#"></td>
							<input type="hidden" name="#B5#DT" value="#DataType#">
						</cfoutput>
					<cfelse>
						<cfoutput>
							<td bgcolor="#tdclr#"><input type="text" name="#B5#Val" value="#OutStr#"></td>
							<input type="hidden" name="#B5#DT" value="#DataType#">
						</tr>
						</cfoutput>
					</cfif>		
				</cfif>
		</cfloop>
		<cfif IsDefined("ReturnTo")>
			<cfoutput>
				<input type="hidden" name="returnto" value="#returnto#">
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
				<input type="hidden" name="page" value="#page#">
			</cfoutput>
		</cfif>
		<tr>
			<th colspan="2"><input type="image" src="images/update.gif" name="UpdAuth" border="0"></th>
		</tr>
	<cfelse>
		<cfoutput query="BOBDBValues">
			<tr>
				<td bgcolor="#tbclr#" align="right">Login Limit</td>
				<td bgcolor="#tdclr#"><input type="text" name="Max_Logins" value="#Max_Logins#"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Account Type</td>
				<td bgcolor="#tdclr#"><input type="text" name="Filter1" value="#Filter1#" maxlength="50"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">IP Address</td>
				<td bgcolor="#tdclr#"><input type="text" name="IP_Address" value="#IP_Address#" maxlength="25"></td>
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
		<cfif IsDefined("ReturnTo")>
			<cfoutput>
				<input type="hidden" name="returnto" value="#returnto#">
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
				<input type="hidden" name="page" value="#page#">
			</cfoutput>
		</cfif>
	</cfif>
	<cfoutput>
		<input type="hidden" name="AuthID" value="#AuthID#">
		<input type="hidden" name="AccntPlanID" value="#AuthInfo.AccntPlanID#">
		<input type="hidden" name="Tab" value="2">
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 