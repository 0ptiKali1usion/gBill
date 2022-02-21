<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page starts the change password process. --->
<!--- 4.0.0 10/15/99 --->
<!--- pass2.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfset AuthNoPass = "">
<cfset AuthNoPassMsg = "">
<cfset AuthPass = "">
<cfset AuthPassMsg = "">
<cfset FTPNoPass = "">
<cfset FTPNoPassMsg = "">
<cfset FTPPass = "">
<cfset FTPPassMsg = "">
<cfset EMailNoPass = "">
<cfset EMailNoPassMsg = "">
<cfset EMailPass = "">
<cfset EMailPassMsg = "">
<cfset gBillPassMsg = "">
<!--- Change gBill Password --->
<cfif IsDefined("gBillID")>
	<cfif Trim(gBillPassword) Is Not "">
		<CFOBJECT TYPE="COM"
        		  NAME="objCrypt"
          		  CLASS="AspCrypt.Crypt"
        		  ACTION="Create">
<!--- This Encrypts the password before comparing it --->
		<CFSET strSalt = gBillLoginName>
		<CFSET strValue = gBillPassword>
		<CFSET gBillPassword = objCrypt.Crypt(strSalt, strValue)>
		<cfquery name="AccountUpdate" datasource="#pds#">
			UPDATE Accounts SET 
			Password = '#gBillPassword#' 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfset gBillPassMsg = "gBill password changed.">
	</cfif>
</cfif>
<!---  Loop on the Auth Password Changes --->
<cfif IsDefined("AuthID")>
	<cfloop index="B5a" list="#AuthID#">
		<cfquery name="PlanInfo" datasource="#pds#">
			SELECT P.AuthMinPassw, P.AuthMaxPassw, P.AuthMixPassw 
			FROM Plans P 
			WHERE PlanID = 
				(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = 
				 	(SELECT AccntPlanID 
					 FROM AccountsAuth 
					 WHERE AuthID = #B5a#)
				)
		</cfquery>
		<cfset PasswordToCheck = Evaluate("Password#B5a#")>
		<cfset UserNameToCheck = Evaluate("AuthName#B5a#")>
		<cfset Pass = 1>
		<cfif (Len(PasswordToCheck) Lt PlanInfo.AuthMinPassw) OR (Len(PasswordToCheck) Gt PlanInfo.AuthMaxPassw)>
			<cfset Pass = 0>
			<cfset AuthNoPassMsg = AuthNoPassMsg & "#UserNameToCheck# Password is too short.<br>">
		</cfif>
		<cfif (FindOneOf("~##* ,/|", PasswordToCheck, 1)) gt 0>
			<cfset Pass = 0>
			<cfset AuthNoPassMsg = AuthNoPassMsg & "#UserNameToCheck# Password can not contain these special characters. (~##* ,/|).<br>">
		</cfif>
		<cfif PlanInfo.AuthMixPassw Is 1>
			<cfif IsNumeric(PasswordToCheck)>
				<cfset Pass = 0>
				<cfset AuthNoPassMsg = AuthNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
			<cfif (FindOneOf("1234567890",PasswordToCheck, 1)) Is 0>
				<cfset Pass = 0>
								<cfset AuthNoPassMsg = AuthNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
		</cfif>
		<cfif Pass Is 0>
			<cfset AuthNoPass = ListAppend(AuthNoPass,B5a)>
		<cfelse>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT Password 
				FROM AccountsAuth 
				WHERE AuthID = #B5a#
			</cfquery>
			<cfif CheckFirst.Password Is Not Trim(PasswordToCheck)>
				<cfset AuthPass = ListAppend(AuthPass,B5a)>
				<cfset AuthPassMsg = AuthPassMsg & "#UserNameToCheck# - Password Changed.<br>">
				<CFOBJECT TYPE="COM"
              			  NAME="objCrypt"
              	  		  CLASS="AspCrypt.Crypt"
              	  		  ACTION="Create">
        <!--- This Encrypts the password before comparing it --->
    			<CFSET strSalt = UserNameToCheck>
    			<CFSET strValue = PasswordToCheck>	
    			<CFSET PasswordToCheck = objCrypt.Crypt(strSalt, strValue)>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE AccountsAuth SET 
					OldPassword = Password, 
					Password = '#PasswordToCheck#' 
					WHERE AuthID = #B5a# 
				</cfquery>
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'passw.cfm' 
					AND L.LocationAction = 'Change' 
					AND I.TypeID = 1 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocAuthID = B5a>
					<cfset LocAccountID = AccountID>
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<cfif FileExists(ExpandPath("external#OSType#chngpass.cfm"))>
					<cfset IntType = "Auth">
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="external#OSType#chngpass.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
			<cfelse>
				<cfset AuthPass = ListAppend(AuthPass,B5a)>
				<cfset AuthPassMsg = AuthPassMsg & "#UserNameToCheck# - The new password was the same as the old password. Password not changed.<br>">
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<!--- Loop on the FTP Password Changes --->
<cfif IsDefined("FTPID")>
	<cfloop index="B5f" list="#FTPID#">
		<cfquery name="PlanInfo" datasource="#pds#">
			SELECT P.FTPMinPassw, P.FTPMaxPassw, P.FTPMixPassw 
			FROM Plans P 
			WHERE PlanID = 
				(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = 
				 	(SELECT AccntPlanID 
					 FROM AccountsFTP 
					 WHERE FTPID = #B5f#)
				)
		</cfquery>
		<cfset PasswordToCheck = Evaluate("FTPPassword#B5f#")>
		<cfset UserNameToCheck = Evaluate("FTPName#B5f#")>
		<cfset Pass = 1>
		<cfif (Len(PasswordToCheck) Lt PlanInfo.FTPMinPassw) OR (Len(PasswordToCheck) Gt PlanInfo.FTPMaxPassw)>
			<cfset Pass = 0>
			<cfset FTPNoPassMsg = FTPNoPassMsg & "#UserNameToCheck# Password is too short.<br>">
		</cfif>
		<cfif (FindOneOf("~##* ,/|", PasswordToCheck, 1)) gt 0>
			<cfset Pass = 0>
			<cfset FTPNoPassMsg = FTPNoPassMsg & "#UserNameToCheck# Password can not contain these special characters. (~##* ,/|).<br>">
		</cfif>
		<cfif PlanInfo.FTPMixPassw Is 1>
			<cfif IsNumeric(PasswordToCheck)>
				<cfset Pass = 0>
				<cfset FTPNoPassMsg = FTPNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
			<cfif (FindOneOf("1234567890",PasswordToCheck, 1)) Is 0>
				<cfset Pass = 0>
								<cfset FTPNoPassMsg = FTPNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
		</cfif>
		<cfif Pass Is 0>
			<cfset FTPNoPass = ListAppend(FTPNoPass,B5f)>
		<cfelse>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT Password 
				FROM AccountsFTP 
				WHERE FTPID = #B5f# 
			</cfquery>
			<cfif CheckFirst.Password Is Not Trim(PasswordToCheck)>
				<cfset FTPPass = ListAppend(FTPPass,B5f)>
				<cfset FTPPassMsg = FTPPassMsg & "#UserNameToCheck# - Password Changed.<br>">
				<CFOBJECT TYPE="COM"
              			  NAME="objCrypt"
              	  		  CLASS="AspCrypt.Crypt"
              	  		  ACTION="Create">
        <!--- This Encrypts the password before comparing it --->
    			<CFSET strSalt = UserNameToCheck>
    			<CFSET strValue = PasswordToCheck>	
    			<CFSET PasswordToCheck = objCrypt.Crypt(strSalt, strValue)>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE AccountsFTP SET 
					OldPassword = Password, 
					Password = '#PasswordToCheck#' 
					WHERE FTPID = #B5f# 
				</cfquery>
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'passw.cfm' 
					AND L.LocationAction = 'Change' 
					AND I.TypeID = 3 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocFTPID = B5f>
					<cfset LocAccountID = AccountID>
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<cfif FileExists(ExpandPath("external#OSType#chngpass.cfm"))>
					<cfset IntType = "FTP">
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="external#OSType#chngpass.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
			<cfelse>
				<cfset FTPPass = ListAppend(FTPPass,B5f)>
				<cfset FTPPassMsg = FTPPassMsg & "#UserNameToCheck# - The new password was the same as the old password. Password not changed.<br>">
			</cfif>
		</cfif>
	</cfloop>
</cfif>


<!--- Loop on the EMail Password Changes --->
<cfif IsDefined("EMailID")>
	<cfloop index="B5e" list="#EMailID#">
		<cfquery name="PlanInfo" datasource="#pds#">
			SELECT P.MailMinPassw, P.MailMaxPassw, P.MailMixPassw 
			FROM Plans P 
			WHERE PlanID = 
				(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = 
				 	(SELECT AccntPlanID 
					 FROM AccountsEMail 
					 WHERE EMailID = #B5e#)
				)
		</cfquery>
		<cfset PasswordToCheck = Evaluate("EMailPassword#B5e#")>
		<cfset UserNameToCheck = Evaluate("EMailName#B5e#")>
		<cfset Pass = 1>
		<cfif (Len(PasswordToCheck) Lt PlanInfo.MailMinPassw) OR (Len(PasswordToCheck) Gt PlanInfo.MailMaxPassw)>
			<cfset Pass = 0>
			<cfset EMailNoPassMsg = EMailNoPassMsg & "#UserNameToCheck# Password is too short.<br>">
		</cfif>
		<cfif (FindOneOf("~##* ,/|", PasswordToCheck, 1)) gt 0>
			<cfset Pass = 0>
			<cfset EMailNoPassMsg = EMailNoPassMsg & "#UserNameToCheck# Password can not contain these special characters. (~##* ,/|).<br>">
		</cfif>
		<cfif PlanInfo.MailMixPassw Is 1>
			<cfif IsNumeric(PasswordToCheck)>
				<cfset Pass = 0>
				<cfset EMailNoPassMsg = EMailNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
			<cfif (FindOneOf("1234567890",PasswordToCheck, 1)) Is 0>
				<cfset Pass = 0>
				<cfset EMailNoPassMsg = EMailNoPassMsg & "#UserNameToCheck# Password must contain both letters and numbers.<br>">
			</cfif>
		</cfif>
		<cfif Pass Is 0>
			<cfset EMailNoPass = ListAppend(EMailNoPass,B5e)>
		<cfelse>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT EPass 
				FROM AccountsEMail 
				WHERE EMailID = #B5e# 
			</cfquery>
			<cfif CheckFirst.EPass Is Not Trim(PasswordToCheck)>
				<cfset EMailPass = ListAppend(EMailPass,B5e)>
				<cfset EMailPassMsg = EMailPassMsg & "#UserNameToCheck# - Password Changed.<br>">
				<CFOBJECT TYPE="COM"
              			  NAME="objCrypt"
              	  		  CLASS="AspCrypt.Crypt"
              	  		  ACTION="Create">
        <!--- This Encrypts the password before comparing it --->
    			<CFSET strSalt = UserNameToCheck>
    			<CFSET strValue = PasswordToCheck>	
    			<CFSET PasswordToCheck = objCrypt.Crypt(strSalt, strValue)>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE AccountsEMail SET 
					OldPassword = EPass, 
					EPass = '#PasswordToCheck#' 
					WHERE EMailID = #B5e# 
				</cfquery>
				<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'passw.cfm' 
					AND L.LocationAction = 'Change'
					AND I.TypeID = 4 
				</cfquery>
				<cfif GetScripts.RecordCount GT 0>
					<cfset LocScriptID = ValueList(GetScripts.IntID)>
					<cfset LocEMailID = B5e>
					<cfset LocAccountID = AccountID>
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="runintegration.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
				<cfif FileExists(ExpandPath("external#OSType#chngpass.cfm"))>
					<cfset IntType = "EMail">
					<cfsetting enablecfoutputonly="no">
						<cfinclude template="external#OSType#chngpass.cfm">
					<cfsetting enablecfoutputonly="yes">
				</cfif>
			<cfelse>
				<cfset EMailPass = ListAppend(EMailPass,B5e)>
				<cfset EMailPassMsg = EMailPassMsg & "#UserNameToCheck# - The new password was the same as the old password. Password not changed.<br>">
			</cfif>
		</cfif>
	</cfloop>
</cfif>


<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Change Password</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<cfif (AuthNoPass Is Not "") OR (FTPNoPass Is Not "") OR (EMailNoPass Is Not "")>
		<cfif AuthNoPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">Authentication Problems</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#AuthNoPassMsg#</td>
			</tr>
		</cfif>
		<cfif FTPNoPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">FTP Problems</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#FTPNoPassMsg#</td>
			</tr>
		</cfif>
		<cfif EMailNoPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">EMail Problems</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#EMailNoPassMsg#</td>
			</tr>
		</cfif>
		<form method="post" action="pass2.cfm">
			<tr>
				<td bgcolor="#tbclr#">Click Return to change the passwords with problems.</td>
			</tr>
			<tr>
				<th><input type="image" src="images/return.gif" border="0"></th>
			</tr>
			<cfif FTPNoPass Is Not "">
				<input type="hidden" name="FTPID" value="#FTPNoPass#">
			</cfif>
			<input type="hidden" name="FTPNoPass" value="#FTPNoPass#">
			<cfif AuthNoPass Is Not "">
				<input type="hidden" name="AuthID" value="#AuthNoPass#">
			</cfif>
			<input type="hidden" name="AuthNoPass" value="#AuthNoPass#">
			<cfif EMailNoPass Is Not "">
				<input type="hidden" name="EMailID" value="#EMailNoPass#">
			</cfif>
			<input type="hidden" name="EMailNoPass" value="#EMailNoPass#">
			<input type="hidden" name="AccountID" value="#AccountID#">
		</form>
	</cfif>
	<cfif (AuthPass Is Not "") OR (FTPPass Is Not "") OR (EMailPass Is Not "") OR (gBillPassMsg Is Not "")>
		<cfif AuthPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">Authentication Passwords</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#AuthPassMsg#</td>
			</tr>
		</cfif>
		<cfif FTPPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">FTP Passwords</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#FTPPassMsg#</td>
			</tr>
		</cfif>
		<cfif EMailPass Is Not "">
			<tr>
				<th bgcolor="#thclr#">EMail Passwords</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#EMailPassMsg#</td>
			</tr>
		</cfif>
		<cfif gBillPassMsg Is Not "">
			<tr>
				<th bgcolor="#thclr#">gBill Passwords</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">#gBillPassMsg#</td>
			</tr>
		</cfif>
		<form method="post" action="custinf1.cfm">
			<tr>
				<th><input type="image" src="images/returncust.gif" border="0"></th>
			</tr>
			<input type="hidden" name="AccountID" value="#AccountID#">
		</form>
	</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

