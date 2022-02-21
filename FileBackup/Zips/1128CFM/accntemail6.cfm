<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Add new EMail accounts. --->
<!---	4.0.0 11/30/99 --->
<!--- accntemail6.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("AddNew.x")>
	<cfparam name="EMailID" default="0">
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT CEMailID 
		FROM Domains 
		WHERE DomainID = #EMailDomainID#
	</cfquery>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, MailMinLogin, MailMaxLogin, MailMinPassw, MailMaxPassw, 
		MailMixPassw, PlanType, Max_Idle, Max_Connect, AWMailLower, DefMailServer, MailBox  
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="SelDomainName" datasource="#pds#">
		SELECT EMailServer, DomainName 
		FROM Domains 
		WHERE DomainID = #EMailDomainID# 
	</cfquery>
	<cfif GetPlanDefs.AWMailLower Is 1>
		<cfset UserNameVal = LCASE(UserNameVal)>
	</cfif>
	<cfset CheckUserName = UserNameVal>
	<cfset CheckPassword = EPassVal>
	<cfset UNPass = 1>
	<cfset PWPass = 1>
	<cfset UNNoPass = "">
	<cfset PWNoPass = "">
	<cfif LoginDiff Is "Yes">
		<cfset CheckLogin = LoginVal>
		<cfif Len(CheckLogin) LT GetPlanDefs.MailMinLogin>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckLogin# - Login is too short.<br>">
		</cfif> 
		<cfif Len(CheckLogin) GT GetPlanDefs.MailMaxLogin>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckLogin# - Login is too long.<br>">
		</cfif>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT EMailID 
			FROM AccountsEMail 
			WHERE Login = '#CheckLogin#' 
			AND DomainName = '#SelDomainName.DomainName#' 
		</cfquery>
		<cfif CheckFirst.Recordcount GT 0>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckLogin# - Login is already taken.<br>">
		</cfif>
		<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckLogin, 1)) gt 0>
			<cfset UNPass = 0>
			<cfset UNNoPass = UNNoPass & "#CheckLogin# - Login can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
		</cfif>
	</cfif>
	<cfif Len(CheckUserName) LT GetPlanDefs.MailMinLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - Address is too short.<br>">
	</cfif> 
	<cfif Len(CheckUserName) GT GetPlanDefs.MailMaxLogin>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - Address is too long.<br>">
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT EMailID 
		FROM AccountsEMail 
		WHERE SMTPUserName = '#CheckUserName#' 
		AND DomainName = '#SelDomainName.DomainName#' 
	</cfquery>
	<cfif CheckFirst.Recordcount GT 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - Address is already taken.<br>">
	</cfif>
	<cfif (FindOneOf("~##@^* ][}{;:<>,/|", CheckUserName, 1)) gt 0>
		<cfset UNPass = 0>
		<cfset UNNoPass = UNNoPass & "#CheckUserName# - Address can not contain these characters ( ~##@^* ][}{;:<>,/| ).<br>">
	</cfif>
	<cfif Len(CheckPassword) LT GetPlanDefs.MailMinPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too short.<br>">
	</cfif> 
	<cfif Len(CheckPassword) GT GetPlanDefs.MailMaxPassw>
		<cfset PWPass = 0>
		<cfset PWNoPass = PWNoPass & "#CheckPassword# - Password is too long.<br>">
	</cfif>
	<cfif GetPlanDefs.MailMixPassw Is 1>
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
				SELECT EMailServer, DomainName 
				FROM Domains 
				WHERE DomainID = #EMailDomainID#
			</cfquery>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT EMailID 
				FROM AccountsEMail 
				WHERE EMail = '#CheckUserName#@#GetDomain.DomainName#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="GetFdValues" datasource="#pds#">
					SELECT * 
					FROM CustomEMailSetup 
					WHERE BOBName <> 'Login' 
					AND BOBName <> 'EPass' 
					AND BOBName <> 'DomainName' 
					AND ActiveYN = 1 
					AND CEMailID = #CEMailID# 
				</cfquery>
				<cfquery name="CheckForEmails" datasource="#pds#">
					SELECT EMailID 
					FROM AccountsEMail 
					WHERE AccountID = #GetInfo.AccountID#
				</cfquery>
				<cfif CheckForEmails.RecordCount Is 0>
					<cfset PrimaryEMail = 1>
				<cfelse>
					<cfset PrimaryEMail = 0>
				</cfif>
				<cfquery name="BOBAuth" datasource="#pds#">
					INSERT INTO AccountsEMail 
					(DomainID, DomainName, Login, EPass, EMail, SMTPUserName, 
					<cfloop query="GetFdValues">#BOBName#, </cfloop>
					AccountID, AccntPlanID, FullName, Alias, EMailServer, ContactYN, PrEMail) 
					VALUES 
					(#EMailDomainID#, '#GetDomain.DomainName#', <cfif LoginDiff Is "Yes">'#CheckLogin#'<cfelse>'#CheckUserName#'</cfif>, 
					'#CheckPassword#', '#CheckUserName#@#GetDomain.DomainName#', 
					'#CheckUserName#', 
					<cfloop query="GetFDValues">
						<cfset UpdValue = Evaluate("#BOBName#Val")>
						<cfif DataType Is "Text">
							<cfif Trim(UpdValue) Is "">Null<cfelse>'#UpdValue#'</cfif>, 
						<cfelseif DataType Is "Number"> 
							<cfif Trim(UpdValue) Is "">Null<cfelse>#UpdValue#</cfif>, 
						<cfelseif DataType Is "Date">
							<cfif Trim(UpdValue) Is "">Null<cfelse>#CreateODBCDateTime(UpdValue)#</cfif>, 
						</cfif>
					</cfloop>
					#GetInfo.AccountID#, #AccntPlanID#, 
					<cfif (IsDefined("FNameVal")) AND (IsDefined("LNameVal"))>
				 		'#FNameVal# #LNameVal#' 
					<cfelse>
						Null
					</cfif>, 0, '#GetDomain.EMailServer#', 0, #PrimaryEMail#
					 )
				</cfquery>
				<cfif IsDefined("UniqueIdentifierVal")>
					<cfif UniqueIdentifierVal Is 1>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccountsEMail SET 
							UniqueIdentifier = EMailID 
							WHERE EMail = '#CheckUserName#@#GetDomain.DomainName#'
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<cfquery name="NewID" datasource="#pds#">
				SELECT EMailID 
				FROM AccountsEMail 
				WHERE Login = '#CheckUserName#' 
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
			AND L.PageName = 'accntemail6.cfm' 
			AND L.LocationAction = 'Create' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'EMail') 
		</cfquery>
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocEMailID = NewID.EMailID>
			<cfset LocCEMailID = GetTheID.CEMailID>
			<cfset LocAccntPlanID = AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
		<!--- Run external --->
		<cfif FileExists(ExpandPath("external#OSType#extcreateemail.cfm"))>
			<cfset SendID = NewID.EMailID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="external#OSType#extcreateemail.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif> 
		<cfsetting enablecfoutputonly="no">
		<cfset tab = 4>
		<cfinclude template="accntmanage2.cfm">
		<cfabort>
	<cfelse>
		<cfset AuthID = 0>
	</cfif>
</cfif>
<cfif Not IsDefined("EMailID")>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, MailMinLogin, MailMaxLogin, MailMinPassw, MailMaxPassw, 
		MailMixPassw, PlanType, Max_Idle, Max_Connect, AWMailLower, DefMailServer 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="AvailDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, C.EMailDescription 
		FROM Domains D, CustomEMail C 
		WHERE D.CEMailID = C.CEMailID 
		AND D.DomainID IN 
			(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		<cfif GetOpts.OverRide Is "0">
			AND D.DomainID IN 
				(SELECT DomainID 
				 FROM DomPlans 
				 WHERE PlanID = #GetPlanDefs.PlanID#) 
		</cfif>
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>EMail Editor</title>
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
	<form method="post" action="accntemail6.cfm">
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">EMail</font></th>
			</tr>
			<tr>
				<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
			</tr>
	</cfoutput>
			<cfif AvailDomains.RecordCount Is 0>
				<tr>
					<td>There domains available to this plan are currently not setup correctly.<br>
					Please go to the Domains Setup to enter the needed information.</td>
				</tr>
			<cfelse>
				<cfoutput>
				<tr valign="top" bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align="right">Domain</td>
				</cfoutput>
					<cfif IsDefined("EMailDomainID")>
						<cfquery name="GetDomainID" datasource="#pds#">
							SELECT EMailServer 
							FROM Domains 
							WHERE DomainID = #EMailDomainID# 
						</cfquery>
						<cfset ADValue = EMailDomainID>
						<cfset DomDisp = GetDomainID.EMailServer>
					<cfelse>
						<cfquery name="GetDomainID" datasource="#pds#">
							SELECT DomainID 
							FROM Domains 
							WHERE DomainName = '#GetPlanDefs.DefMailServer#' 
						</cfquery>
						<cfset ADValue = GetDomainID.DomainID>
						<cfset DomDisp = GetPlanDefs.DefMailServer>
					</cfif>
					<cfif AvailDomains.RecordCount GT 1>
						<td><select name="EMailDomainID">
							<cfoutput query="AvailDomains">
								<option <cfif DomainID Is ADValue>selected</cfif> value="#DomainID#">#DomainName# - #EMailDescription#
							</cfoutput>
						</select></td>
					<cfelse>
						<cfoutput>
							<td>#AvailDomains.DomainName#</td>
							<input type="Hidden" name="EMailDomainID" value="#AvailDomains.DomainID#">
						</cfoutput>
					</cfif>
				</tr>
				<tr>
					<th colspan="2"><input type="image" src="images/continue.gif" name="DomSelected" border="0"></th>
				</tr>
				<cfoutput>
					<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					<input type="hidden" name="EMailID" value="0">
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
		SELECT CEMailID 
		FROM Domains 
		WHERE DomainID = #EMailDomainID#
	</cfquery>
	<cfquery name="GetPlanDefs" datasource="#pds#">
		SELECT PlanID, PlanDesc, MailMinLogin, MailMaxLogin, MailMinPassw, MailMaxPassw, 
		MailMixPassw, AWMailLower, DefMailServer, EMailLogDiffYN, MailBox, Limit1 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) 
	</cfquery>
	<cfquery name="GetFdValues" datasource="#pds#">
		SELECT *
		FROM CustomEMailSetup 
		WHERE CEMailID = #GetTheID.CEMailID# 
		AND BOBName <> 'Login' 
		AND BOBName <> 'EPass' 		
		AND BOBName <> 'DomainName' 
		AND ActiveYN = 1 
		ORDER BY SortOrder, EMailDescription 
	</cfquery>
	<cfquery name="DomainPart" datasource="#pds#">
		SELECT Domainname 
		FROM Domains 
		WHERE DomainID = #EMailDomainID#
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>EMail Editor</title>
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
			<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">EMail</font></th>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="2">Add to: #GetPlanDefs.PlanDesc#</th>
		</tr>
	</cfoutput>
	<form method="post" action="accntemail6.cfm">
		<cfoutput>
			<cfif IsDefined("UNNoPass")>
				<tr bgcolor="#tbclr#">
					<td colspan="2">#UNNoPass#
					<cfif PWNoPass Is Not "">#PWNoPass#</cfif></td>
				</tr>
			</cfif>
			<tr bgcolor="#tdclr#" valign="top">
				<td align="right" bgcolor="#tbclr#">Address</td>
				<cfif IsDefined("UserNameVal")>
					<cfset PWValue = Evaluate("UserNameVal")>
				<cfelse>
					<cfset PWValue = "">
				</cfif>
				<cfif GetPlanDefs.MailMaxLogin GT 20>
					<cfset maxlen = 20>
				<cfelse>
					<cfset maxlen = GetPlanDefs.MailMaxLogin>
				</cfif>
				<cfif GetPlanDefs.MailMaxLogin IS "">
					<cfset MxLen = 25>
				<cfelse>
					<cfset MxLen= GetPlanDefs.MailMaxLogin>
				</cfif>
				<td><input type="text" name="UserNameVal" value="#PWValue#" maxlength="#MxLen#" size="#maxlen#">@#DomainPart.DomainName#</td>
				<input type="hidden" name="UserNameVal_Required" value="Please enter: Username">
			</tr>
			<cfif GetPlanDefs.EMailLogDiffYN Is "1">
				<tr bgcolor="#tbclr#" valign="top">
					<td align="right">Login</td>
					<cfif IsDefined("LoginVal")>
						<cfset PWValue = Evaluate("LoginVal")>
					<cfelse>
						<cfset PWValue = "">
					</cfif>
					<td bgcolor="#tdclr#"><input type="text" name="LoginVal" value="#PWValue#" maxlength="#maxlen#"></td>
					<input type="hidden" name="LoginVal_Required" value="Please enter: Login">
					<input type="Hidden" name="LoginDiff" value="Yes">
				</tr>
			<cfelse>
				<input type="Hidden" name="LoginDiff" value="No">
			</cfif>
			<tr bgcolor="#tdclr#" valign="top">
				<td align="right" bgcolor="#tbclr#">Password</td>
				<cfif IsDefined("EPassVal")>
				    <CFOBJECT TYPE="COM"
		              NAME="objCrypt"
				      CLASS="AspCrypt.Crypt"
				      ACTION="Create">
		            
		            <cfset strSalt = LoginVal>
		            <cfset strValue = EPassVal>
		            <cfset EPassVal = objCrypt.Crypt(strSalt, strValue)>
					<cfset PWValue = Evaluate("EPassVal")>
				<cfelse>
					<cfset PWValue = "">
				</cfif>
				<cfif GetPlanDefs.MailMaxPassw GT 20>
					<cfset maxlen = 20>
				<cfelse>
					<cfset maxlen = GetPlanDefs.MailMaxPassw>
				</cfif>
				<td><input type="text" name="EPassVal" value="#PWValue#" maxlength="#maxlen#"></td>
				<input type="hidden" name="EPassVal_Required" value="Please enter: Password">
			</tr>
			
		</cfoutput>
		<cfloop query="GetFdValues">
			<cfif BOBName Is Not "UniqueIdentifier">
				<cfoutput>
					<tr bgcolor="#tbclr#" valign="top">
						<td align="right">#EMailDescription#</td>
				</cfoutput>
			</cfif>
			<cfif IsDefined("#BOBName#Val")>
				<cfset ATValue = Evaluate("#BOBName#Val")>
			<cfelse>
				<cfset ATValue = "">
			</cfif>
			<cfif CFVarYN Is 1>
				<cfif BOBName Is "FName">
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #EMailDescription#">
					</cfoutput>
				<cfelseif BOBName Is "LName">
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #EMailDescription#">
					</cfoutput>
				<cfelseif BOBName Is "MailBoxLimit">
					<cfif IsDefined("AddNew.x")>
						<cfset ATValue = ATValue>
					<cfelse>
						<cfset ATValue = GetPlanDefs.Limit1>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" size="15" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #EMailDescription#">
					</cfoutput>
				<cfelseif BOBName Is "UniqueIdentifier">
					<cfoutput>
						<input type="hidden" name="UniqueIdentifierVal" value="1">
					</cfoutput>
				<cfelseif BOBName Is "MailBoxPath">
					<cfif IsDefined("AddNew.x")>
						<cfset ATValue = ATValue>
					<cfelse>
						<cfset ATValue = GetPlanDefs.MailBox>
					</cfif>
					<cfoutput>
						<td bgcolor="#tdclr#"><input type="text" name="#BOBName#Val" size="35" value="#ATValue#"></td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #EMailDescription#">
					</cfoutput>
				<cfelse>
					<cfoutput>
						<td bgcolor="#tdclr#"><input name="#BOBName#Val" type="radio" value="1"> Yes <input checked name="#BOBName#Val" type="radio" value="0"> No</td>
						<input type="hidden" name="#BOBName#Val_Required" value="Please enter: #EMailDescription#">
					</cfoutput>
				</cfif>
			<cfelse>
				<cfif IsDefined("#BOBName#Val")>
					<cfset ATValue = Evaluate("#BOBName#Val")>
				<cfelse>
					<cfset ATValue = "">
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
			<input type="hidden" name="CEMailID" value="#GetTheID.CEMailID#">
			<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
			<input type="hidden" name="EMailDomainID" value="#EMailDomainID#">
		</cfoutput>
	</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif> 
  