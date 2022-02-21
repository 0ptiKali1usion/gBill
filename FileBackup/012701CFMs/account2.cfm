<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the account wizard. --->
<!---	4.0.1 01/26/01 Fixed an error where custom fields on tab 5 were not getting saved to the database.
		4.0.0 08/14/99 --->
<!-- account2.cfm -->

<cfset securepage="account.cfm">
<cfinclude template="security.cfm">

<cfif tab Is 4>
	<cfparam name="MessDisp" default="0">
	<cfquery name="GetPlanIDs" datasource="#pds#">
		SELECT SelectPlan 
		FROM AccntTemp 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfloop index="B5" list="#GetPlanIDs.SelectPlan#">
		<cfset LoopCount = Evaluate("Setup#B5#AuthNum")>
		<cfloop index="B4" from="1" to="#LoopCount#">
			<cfset TheLogin = Evaluate("Plan#B5#ALogin#B4#")>
			<cfset ThePassw = Evaluate("Plan#B5#APassword#B4#")>
			<cfset TheDomain = Evaluate("Plan#B5#AServer#B4#")>
			<cfif IsDefined("Plan#B5#StaticIP#B4#")>
				<cfset TheStaticIP = 1>
			<cfelse>
				<cfset TheStaticIP = 0>
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #AccountID# 
				AND AdminID = #MyAdminID# 
				AND PlanID = #B5# 
				AND Type = 'Auth' 
				AND Sort = #B4# 
			</cfquery>
			<cfquery name="GetServer" datasource="#pds#">
				SELECT AuthServer, DomainID, DomainName 
				FROM Domains 
				WHERE DomainID = #TheDomain# 
			</cfquery>
			<cfif Trim(TheLogin) Is "">
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM AccntTempInfo 
					WHERE AccountID = #AccountID# 
					AND AdminID = #MyAdminID# 
					AND PlanID = #B5# 
					AND Type = 'Auth' 
					AND Sort = #B4# 
				</cfquery>
			<cfelse>
				<cfif CheckFirst.RecordCount Is 0>
					<cfquery name="InsData" datasource="#pds#">
						INSERT INTO AccntTempInfo 
						(AccountID, AdminID, PlanID, Type, Sort, Login, Password, StaticIP, DomainName,Domain,LastUpdated,DomainID) 
						VALUES 
						(#AccountID#,#MyAdminID#,#B5#,'Auth',#B4#,'#Trim(TheLogin)#','#Trim(ThePassw)#',#TheStaticIP#, '#GetServer.AuthServer#', '#GetServer.DomainName#', #Now()#,#TheDomain#)
					</cfquery>
				<cfelse>
					<cfquery name="CheckBefore" datasource="#pds#">
						SELECT * 
						FROM AccntTempInfo 
						WHERE Login = '#Trim(TheLogin)#' 
						AND DomainName = '#GetServer.AuthServer#' 
						AND Domain = '#GetServer.DomainName#' 
						AND AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'Auth' 
						AND Sort = #B4# 
					</cfquery>
					<cfquery name="UpdData" datasource="#pds#">
						UPDATE AccntTempInfo SET 
						Login = '#Trim(TheLogin)#', 
						Password = '#Trim(ThePassw)#', 
						StaticIP = #TheStaticIP#, 
						<cfif CheckBefore.Recordcount Is 0>
							LastUpdated = #Now()#, 
						</cfif>
						DomainName = '#GetServer.AuthServer#', 
						Domain = '#GetServer.DomainName#', 
						DomainID = #TheDomain# 
						WHERE AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'Auth' 
						AND Sort = #B4#
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<cfset LoopCount2 = Evaluate("Setup#B5#FTPNum")>
		<cfloop index="B3" from="1" to="#LoopCount2#">
			<cfset TheFLogin = Evaluate("Plan#B5#FLogin#B3#")>
			<cfset TheFPassw = Evaluate("Plan#B5#FPassword#B3#")>
			<cfset FTPServer = Evaluate("Setup#B5#FServer")>
			<cfset TheFDomain = Evaluate("Plan#B5#Fserver#B3#")>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #AccountID# 
				AND AdminID = #MyAdminID# 
				AND PlanID = #B5# 
				AND Type = 'FTP' 
				AND Sort = #B3# 
			</cfquery>
			<cfquery name="GetServer" datasource="#pds#">
				SELECT FTPServer, DomainID, DomainName 
				FROM Domains 
				WHERE DomainID = #TheFDomain# 
			</cfquery>
			<cfif Trim(TheFLogin) Is "">
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM AccntTempInfo 
					WHERE AccountID = #AccountID# 
					AND AdminID = #MyAdminID# 
					AND PlanID = #B5# 
					AND Type = 'FTP' 
					AND Sort = #B3# 
				</cfquery>
			<cfelse>
				<cfif CheckFirst.RecordCount Is 0>
					<cfquery name="InsData" datasource="#pds#">
						INSERT INTO AccntTempInfo 
						(AccountID, AdminID, PlanID, Type, Sort, Login, Password, DomainName, Domain, LastUpdated, DomainID) 
						VALUES 
						(#AccountID#,#MyAdminID#,#B5#,'FTP',#B3#,'#Trim(TheFLogin)#','#Trim(TheFPassw)#','#GetServer.FTPServer#', '#GetServer.DomainName#', #Now()#, #GetServer.DomainID#)
					</cfquery>
				<cfelse>
					<cfquery name="CheckBefore" datasource="#pds#">
						SELECT * 
						FROM AccntTempInfo 
						WHERE Login = '#Trim(TheFLogin)#' 
						AND DomainName = '#GetServer.FTPServer#' 
						AND Domain = '#GetServer.DomainName#' 
						AND AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'FTP' 
						AND Sort = #B3# 
					</cfquery>
					<cfquery name="UpdData" datasource="#pds#">
						UPDATE AccntTempInfo SET 
						Login = '#Trim(TheFLogin)#', 
						Password = '#Trim(TheFPassw)#', 
						<cfif CheckBefore.Recordcount Is 0>
							LastUpdated = #Now()#, 
						</cfif>
						DomainName = '#GetServer.FTPServer#', 
						Domain = '#GetServer.DomainName#', 
						DomainID = #GetServer.DomainID# 
						WHERE AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'FTP' 
						AND Sort = #B3#
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<cfset LoopCount3 = Evaluate("Setup#B5#EMailNum")>
		<cfloop index="B2" from="1" to="#LoopCount3#">
			<cfif IsDefined("Plan#B5#ELogin#B2#")>
				<cfset TheELogin = Evaluate("Plan#B5#ELogin#B2#")>
			<cfelse>
				<cfset TheELogin = Evaluate("Plan#B5#EUserName#B2#")>
			</cfif>
			<cfset TheEPassw = Evaluate("Plan#B5#EPassword#B2#")>
			<cfset TheEUserN = Evaluate("Plan#B5#EUserName#B2#")>
			<cfset TheEDoman = Evaluate("Plan#B5#EDomainName#B2#")>
			<cfquery name="DomainName" datasource="#pds#">
				SELECT DomainName 
				FROM Domains 
				WHERE DomainID = #TheEDoman#
			</cfquery>
			<cfset TheEDomNm = DomainName.DomainName>
			<cfquery name="GetServer" datasource="#pds#">
				SELECT POP3Server 
				FROM Domains 
				WHERE DomainName = '#TheEDomNm#' 
			</cfquery>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM AccntTempInfo 
				WHERE AccountID = #AccountID# 
				AND AdminID = #MyAdminID# 
				AND PlanID = #B5# 
				AND Type = 'EMail' 
				AND Sort = #B2# 
			</cfquery>
			<cfif Trim(TheEUserN) Is "">
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM AccntTempInfo 
					WHERE AccountID = #AccountID# 
					AND AdminID = #MyAdminID# 
					AND PlanID = #B5# 
					AND Type = 'EMail' 
					AND Sort = #B2# 
				</cfquery>
			<cfelse>
				<cfif CheckFirst.RecordCount Is 0>
					<cfquery name="InsData" datasource="#pds#">
						INSERT INTO AccntTempInfo 
						(AccountID, AdminID, PlanID, Type, Sort, Login, Password, UserName, DomainName, EMailAddr, DomainID, Domain, LastUpdated) 
						VALUES 
						(#AccountID#,#MyAdminID#,#B5#,'EMail',#B2#,'#Trim(TheELogin)#','#Trim(TheEPassw)#','#Trim(TheEUserN)#','#GetServer.POP3Server#','#Trim(TheEuserN)#@#Trim(TheEDomNm)#',#Trim(TheEDoman)#, '#Trim(TheEDomNm)#', #Now()#)
					</cfquery>
				<cfelse>
					<cfquery name="CheckBefore" datasource="#pds#">
						SELECT * 
						FROM AccntTempInfo 
						WHERE Login = '#Trim(TheELogin)#' 
						AND DomainName = '#GetServer.POP3Server#' 
						AND Domain = '#Trim(TheEDomNm)#' 
						AND AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'EMail' 
						AND Sort = #B2# 
					</cfquery>
					<cfquery name="UpdData" datasource="#pds#">
						UPDATE AccntTempInfo SET 
						Login = '#Trim(TheELogin)#', 
						Password = '#Trim(TheEPassw)#', 
						UserName = '#Trim(TheEUserN)#', 
						<cfif CheckBefore.Recordcount Is 0>
							LastUpdated = #Now()#, 
						</cfif>
						DomainName = '#GetServer.POP3Server#', 
						DomainID = #Trim(TheEDoman)#, 
						EMailAddr = '#Trim(TheEUserN)#@#Trim(TheEDomNm)#', 
						Domain = '#Trim(TheEDomNm)#' 
						WHERE AccountID = #AccountID# 
						AND AdminID = #MyAdminID# 
						AND PlanID = #B5# 
						AND Type = 'EMail' 
						AND Sort = #B2#
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	<CFOBJECT TYPE="COM"
              NAME="objCrypt"
              CLASS="AspCrypt.Crypt"
              ACTION="Create">
        <!--- This Encrypts the password before comparing it --->
    <CFSET strSalt = BOBLogin>
    <CFSET strValue = BOBPassword>
    <CFSET BOBPassword = objCrypt.Crypt(strSalt, strValue)>
	<cfquery name="UPdData" datasource="#pds#">
		UPDATE AccntTemp SET 
		Login = '#BOBLogin#', 
		Password = '#BOBPassword#' 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE PageNumber = 4 
		AND ActiveYN = 1 
		AND AWUseYN = 1 
		AND BOBFieldName <> 'userinfo' 
	</cfquery>
	<cfquery name="UpdateInfo" datasource="#pds#">
		UPDATE AccntTemp SET 
		<cfloop query="GetFields">
				<cfset FieldValue = Evaluate("#BOBFieldName#")>
				#BOBFieldName# = <cfif Trim(FieldValue) Is "">NULL<cfelse><cfif DataType Is "Text">'#FieldValue#'<cfelseif DataType Is "Number">#FieldValue#<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#</cfif></cfif>, 
		</cfloop> 
		AdminID = #MyAdminID#, 
		TabCompleted = 4 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="AllLogins" datasource="#pds#">
		SELECT A.*, P.PlanDesc 
		FROM AccntTempInfo A, Plans P 
		WHERE A.PlanID = P.PlanID 
		AND AccountID = #AccountID# 
		ORDER BY P.PlanDesc, A.Type 
	</cfquery>
	<cfquery name="PlanIDs" datasource="#pds#">
		SELECT P.PlanID 
		FROM Plans P 
		WHERE P.PlanID IN 
			(SELECT A.PlanID 
			 FROM AccntTempInfo A, Plans P 
			 WHERE A.PlanID = P.PlanID 
			 AND AccountID = #AccountID#) 
		ORDER BY P.PlanDesc
	</cfquery>
	<cfloop query="PlanIDs">
		<cfset "Display#PlanID#" = "">
	</cfloop>
	<cfloop query="AllLogins">
		<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<ul>">
		<cfset "Header#PlanID#" = PlanDesc>
		<cfif Type Is "Auth">
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT FTPMatchYN, EMailMatchYN, LowerAWYN, 
				AuthAddChars, AuthMaxLogin, AuthMaxPassw, 
				AuthMixPassw, AuthMinPassw, AuthMinLogin, 
				AuthSufChars 
				FROM Plans 
				WHERE PlanID = #PlanID# 
			</cfquery>
			<cfif PlanDetails.AuthAddChars Is Not "">
				<cfset TheLoginPre = Trim(PlanDetails.AuthAddChars)>
			<cfelse>
				<cfset TheLoginPre = "">
			</cfif>
			<cfif PlanDetails.AuthSufChars Is Not "">
				<cfset TheLoginSuf = Trim(PlanDetails.AuthSufChars)>
			<cfelse>
				<cfset TheLoginSuf = "">
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT UserName 
				FROM AccountsAuth 
				WHERE UserName = '#TheLoginPre##Login##TheLoginSuf#' 
				AND DomainName = '#DomainName#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="CheckFirst" datasource="#pds#">
					SELECT Login 
					FROM AccntTempInfo 
					WHERE Login = '#Login#' 
					AND DomainName = '#DomainName#' 
					AND LastUpdated < #CreateODBCDateTime(LastUpdated)# 
				</cfquery>
			</cfif>
			<cfif PlanDetails.FTPMatchYN Is 1>
				<cfif CheckFirst.Recordcount Is 0>
					<cfquery name="GetFTPInfo" datasource="#pds#">
						SELECT FTPServer 
						FROM Domains 
						WHERE DomainName = '#Domain#' 
					</cfquery>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT UserName 
						FROM AccountsFTP 
						WHERE UserName = '#TheLoginPre##Login##TheLoginSuf#' 
						AND DomainName = '#GetFTPInfo.FTPServer#' 
					</cfquery>
				</cfif>
			</cfif>
			<cfif PlanDetails.EMailMatchYN Is 1>
				<cfif CheckFirst.Recordcount Is 0>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT EMailID 
						FROM AccountsEMail 
						WHERE EMail = '#TheLoginPre##Login##TheLoginSuf#@#Domain#' 
					</cfquery>
				</cfif>
				<cfif CheckFirst.Recordcount Is 0>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT InfoID 
						FROM AccntTempInfo 
						WHERE EMailAddr = '#Login#@#Domain#' 
						AND LastUpdated < #CreateODBCDateTime(LastUpdated)# 
					</cfquery>
				</cfif>
				<cfif CheckFirst.Recordcount Is 0>
					<cfquery name="GetMailInfo" datasource="#pds#">
						SELECT POP3Server 
						FROM Domains 
						WHERE DomainName = '#Domain#' 
					</cfquery>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT EMailID 
						FROM AccountsEMail 
						WHERE Login = '#TheLoginPre##Login##TheLoginSuf#' 
						AND DomainName = '#GetMailInfo.POP3Server#' 
					</cfquery>
					<cfif CheckFirst.Recordcount Is 0>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT InfoID 
							FROM AccntTempInfo 
							WHERE Login = '#Login#' 
							AND DomainName = '#GetMailInfo.POP3Server#' 
							AND LastUpdated < #CreateODBCDateTime(LastUpdated)# 
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<cfif PlanDetails.LowerAWYN Is 1>
				<cfquery name="LowerCaseIt" datasource="#pds#">
					UPDATE AccntTempInfo 
					SET Login = '#LCase(Login)#' 
					WHERE InfoID = #InfoID# 
				</cfquery>
			</cfif>
			<cfset LenL = Len(Login)>
			<cfset LenP = Len(Password)>
			<cfif CheckFirst.RecordCount GT 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> The Login ""#Login#"" is already in use.  Please enter a different login.">
				<cfset MessDisp = 1>
			<cfelse>
				<cfif LenL LT PlanDetails.AuthMinLogin>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too short.  It should be at least #PlanDetails.AuthMinLogin# characters long.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif LenL GT PlanDetails.AuthMaxLogin>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too long.  It should be at the most #PlanDetails.AuthMaxLogin# characters long.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif (FindOneOf("~##@^* ][}{;:<>,/|", Login, 1)) gt 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" cannot have the following characters. ~##@^* ][}{;:<>,/|">
					<cfset MessDisp = 1>
				</cfif>
			</cfif>
			<cfif LenP LT PlanDetails.AuthMinPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" is too short.  It should be at least #PlanDetails.AuthMinPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif LenP GT PlanDetails.AuthMaxPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" is too long.  It should be at the most #PlanDetails.AuthMaxPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif (FindOneOf("~##* ,/|", Password, 1)) gt 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" cannot have the following characters. ~##* ,/|">
				<cfset MessDisp = 1>
			</cfif>
			<cfif PlanDetails.AuthMixPassw Is 1>
				<cfif IsNumeric(Password)>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" must contain letters as well as numbers.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif (FindOneOf("1234567890",Password, 1)) Is 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" must contain numbers as well as letters.">
					<cfset MessDisp = 1>
				</cfif>
			</cfif>
			<cfif FileExists("#cfmpath#/external/extaccount4.cfm")>
				<cfinclude template="external/extaccount4.cfm">
			</cfif>
		<cfelseif Type Is "FTP">
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT AWFTPLower, FTPMaxLogin, FTPMaxPassw, FTPMinLogin, FTPMinPassw, FTPMixPassw  
				FROM Plans 
				WHERE PlanID = #PlanID# 
			</cfquery>	
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT UserName 
				FROM AccountsFTP 
				WHERE UserName = '#Login#' 
				AND DomainName = '#DomainName#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="CheckFirst" datasource="#pds#">
					SELECT InfoID 
					FROM AccntTempInfo 
					WHERE Login = '#Login#' 
					AND DomainName = '#DomainName#' 
					AND LastUpdated < #CreateODBCDateTime(LastUpdated)# 
				</cfquery>
			</cfif>
			<cfif PlanDetails.AWFTPLower Is 1>
				<cfquery name="LowerCaseIt" datasource="#pds#">
					UPDATE AccntTempInfo 
					SET Login = '#LCase(Login)#' 
					WHERE InfoID = #InfoID# 
				</cfquery>
			</cfif>
			<cfset LenL = Len(Login)>
			<cfset LenP = Len(Password)>
			<cfif CheckFirst.RecordCount GT 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> The Login ""#Login#"" is already in use.  Please enter a different login.">
				<cfset MessDisp = 1>
			<cfelse>
				<cfif LenL LT PlanDetails.FTPMinLogin>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too short.  It should be at least #PlanDetails.FTPMinLogin# characters long.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif LenL GT PlanDetails.FTPMaxLogin>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too long.  It should be at the most #PlanDetails.FTPMaxLogin# characters long.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif (FindOneOf("~##@^* ][}{;:<>,/|", Login, 1)) gt 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" cannot have the following characters. ~##@^* ][}{;:<>,/|">
					<cfset MessDisp = 1>
				</cfif>
			</cfif>
			<cfif LenP LT PlanDetails.FTPMinPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" is too short.  It should be at least #PlanDetails.FTPMinPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif LenP GT PlanDetails.FTPMaxPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" is too long.  It should be at the most #PlanDetails.FTPMaxPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif (FindOneOf("~##* ,/|", Password, 1)) gt 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" cannot have the following characters. ~##* ,/|">
				<cfset MessDisp = 1>
			</cfif>
			<cfif PlanDetails.FTPMixPassw Is 1>
				<cfif IsNumeric(Password)>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" must contain letters as well as numbers.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif (FindOneOf("1234567890",Password, 1)) Is 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for login ""#Login#"" must contain numbers as well as letters.">
					<cfset MessDisp = 1>
				</cfif>
			</cfif>
		<cfelseif Type Is "EMail">
			<cfquery name="PlanDetails" datasource="#pds#">
				SELECT EMailLogDiffYN, AWMailLower, MailMaxLogin, 
				MailMaxPassw, MailMinLogin, MailMinPassw, MailMixPassw 
				FROM Plans 
				WHERE PlanID = #PlanID# 
			</cfquery>
			<cfif PlanDetails.AWMailLower Is 1>
				<cfquery name="LowerCaseIt" datasource="#pds#">
					UPDATE AccntTempInfo 
					SET Login = '#LCase(Login)#', 
					UserName = '#LCase(UserName)#', 
					EMailAddr = '#LCase(EMailAddr)#'
					WHERE InfoID = #InfoID# 
				</cfquery>
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT EMailID 
				FROM AccountsEMail 
				WHERE EMail = '#EMailAddr#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="CheckFirst" datasource="#pds#">
					SELECT InfoID 
					FROM AccntTempInfo 
					WHERE EMailAddr = '#EMailAddr#' 
					AND LastUpdated < #CreateODBCDateTime(LastUpdated)# 
				</cfquery>
			</cfif>
			<cfquery name="CheckSecond" datasource="#pds#">
				SELECT EMailID 
				FROM AccountsEMail 
				WHERE Login = '#Login#' 
				AND DomainName = '#DomainName#'
			</cfquery>
			<cfif CheckSecond.Recordcount Is 0>
				<cfquery name="CheckSecond" datasource="#pds#">
					SELECT InfoID 
					FROM AccntTempInfo 
					WHERE Login = '#Login#' 
					AND DomainName = '#DomainName#'
				</cfquery>
			</cfif>
			<cfset LenL = Len(Login)>
			<cfset LenP = Len(Password)>
			<cfif  CheckFirst.Recordcount GT 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> The E-Mail Address ""#EMailAddr#"" is already in use.  Please enter a different address.">		
				<cfset MessDisp = 1>
			</cfif>
			<cfif PlanDetails.EMailLogDiffYN Is 1>
				<cfif CheckSecond.Recordcount GT 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is already in use.  Please enter a different login.">		
					<cfset MessDisp = 1>
				<cfelse>
					<cfif LenL LT PlanDetails.MailMinLogin>
						<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too short.  It should be at least #PlanDetails.MailMinLogin# characters long.">
						<cfset MessDisp = 1>
					</cfif>
					<cfif LenL GT PlanDetails.MailMaxLogin>
						<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" is too long.  It should be at the most #PlanDetails.MailMaxLogin# characters long.">
						<cfset MessDisp = 1>
					</cfif>
					<cfif (FindOneOf("~##@^* ][}{;:<>,/|", Login, 1)) gt 0>
						<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Login ""#Login#"" cannot have the following characters. ~##@^* ][}{;:<>,/|">
						<cfset MessDisp = 1>
					</cfif>			
				</cfif>
			</cfif>
			<cfif LenP LT PlanDetails.MailMinPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for e-mail ""#EmailAddr#"" is too short.  It should be at least #PlanDetails.MailMinPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif LenP GT PlanDetails.MailMaxPassw>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for e-mail ""#EmailAddr#"" is too long.  It should be at the most #PlanDetails.MailMaxPassw# characters long.">
				<cfset MessDisp = 1>
			</cfif>
			<cfif (FindOneOf("~##* ,/|", Password, 1)) gt 0>
				<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for e-mail ""#EmailAddr#"" cannot have the following characters. ~##* ,/|">
				<cfset MessDisp = 1>
			</cfif>
			<cfif PlanDetails.MailMixPassw Is 1>
				<cfif IsNumeric(Password)>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for e-mail ""#EmailAddr#"" must contain letters as well as numbers.">
					<cfset MessDisp = 1>
				</cfif>
				<cfif (FindOneOf("1234567890",Password, 1)) Is 0>
					<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "<li> Password ""#Password#"" for e-mail ""#EmailAddr#"" must contain numbers as well as letters.">
					<cfset MessDisp = 1>
				</cfif>
			</cfif>
		</cfif>
		<cfset "Display#PlanID#" = "#Evaluate("Display#PlanID#")#" & "</ul>">
	</cfloop>
	<cfquery name="CheckLogin" datasource="#pds#">
		SELECT Login 
		FROM Accounts 
		WHERE Login = '#BOBLogin#'
	</cfquery>
	<cfif CheckLogin.Recordcount Is 0>
		<cfquery name="CheckLogin" datasource="#pds#">
			SELECT Login 
			FROM AccntTemp 
			WHERE Login = '#BOBLogin#' 
			AND AccountID <> #AccountID# 
		</cfquery>
	</cfif>
	<cfset LogCheckMess = "<ul>">
	<cfparam name="BOBMinL" default="3">
	<cfparam name="BOBMinP" default="4">
	<cfparam name="BOBMaxL" default="35">
	<cfparam name="BOBMaxP" default="35">
	<cfset BOBLenL = Len(BOBLogin)>
	<cfset BOBLenP = Len(BOBPassword)>
	<cfif CheckLogin.RecordCount GT 0>
		<cfset LogCheckMess = LogCheckMess & "<li> Login ""#BOBLogin#"" is already in use.  Please enter a different gBill login.">
		<cfset MessDisp = 1>
	</cfif>
	<cfif (BOBLenL GT BOBMaxL) OR (BOBLenL LT BOBMinL)>
		<cfset LogCheckMess = LogCheckMess & "<li> Login ""#BOBLogin#"" is not the correct length.  It should be between #BOBMinL# And #BOBMaxL# characters.  Please enter a different gBill login.</ul>">
		<cfset MessDisp = 1>
	</cfif>
	<cfif (BOBLenP GT BOBMaxP) OR (BOBLenP LT BOBMinP)>
		<cfset LogCheckMess = LogCheckMess & "<li> Password ""#BOBPassword#"" is not the correct length.  It should be between #BOBMinP# And #BOBMaxP# characters.  Please enter a different gBill password.</ul>">
		<cfset MessDisp = 1>
	</cfif>
	<cfset LogCheckMess = LogCheckMess & "</ul>">
	
	<cfsetting enablecfoutputonly="no">
	<cfif MessDisp Is "1">
		<cfquery name="UpdateInfo" datasource="#pds#">
			UPDATE AccntTemp SET 
			TabCompleted = 3 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<html>
		<head>
		<title>Account Wizard</TITLE>
		<cfinclude template="coolsheet.cfm">
		</head>
		<cfoutput><body #colorset#></cfoutput>
		<cfinclude template="header.cfm">
		<center>
		<cfoutput>
		<table border="#tblwidth#">
			<cfloop index="B5" list="#ValueList(PlanIDs.PlanID)#">
				<cfset HeaderDisp = Evaluate("Header#B5#")>
				<cfset ErrorDispl = Evaluate("Display#B5#")>
				<cfset ErrorDispl = ReplaceList(ErrorDispl,"<ul></ul>"," ")>
				<cfif Trim(ErrorDispl) Is Not "">
					<tr>
						<th bgcolor="#thclr#">#HeaderDisp#</th>
					</tr>
					<tr>
						<td bgcolor="#tbclr#">#ErrorDispl#</td>
					</tr>
				</cfif>
			</cfloop>
			<cfset LogCheckMess = ReplaceList(LogCheckMess,"<ul></ul>"," ")>
			<cfif Trim(LogCheckMess) Is Not "">
				<tr>
					<th bgcolor="#thclr#">gBill</th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">#LogCheckMess#</td>
				</tr>
			</cfif>
			<tr>
				<form method="post" action="account1.cfm">
					<input type="hidden" name="tab" value="4">
					<input type="hidden" name="accountid" value="#accountid#">
					<th><input type="image" src="images/return.gif" name="GoBack" border="0"></th>
				</form>
			</tr>
		</table>
		</cfoutput>
		</center>
		<cfinclude template="footer.cfm">
		</body>
		</html>
		<cfabort>
	</cfif>
<cfelseif tab Is 5>
	<cfquery name="FieldNames" datasource="#pds#">
		SELECT * 
		FROM PayTypes 
		WHERE ActiveYN = 1 
		AND CFVarYN = 0 
	</cfquery>
	<cfif IsDefined("NoAdvance")>
		<cfset UpdTab = Tab - 1>
	<cfelse>
		<cfset UpdTab = Tab>
	</cfif>
	<cfquery name="BOBExtraFields" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE PageNumber = 5 
		AND ActiveYN = 1 
		AND AWUseYN = 1 
		AND BOBFieldName NOT In ('checkcash','porder','checkdebit','creditcard','taxfree','postalinv')
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AccntTemp SET 
		<cfif IsDefined("CheckD1")>CheckD1 = <cfif Trim(CheckD1) Is "">Null<cfelse>'#Trim(CheckD1)#'</cfif>,</cfif>
		<cfif IsDefined("CheckD2")>CheckD2 = <cfif Trim(CheckD2) Is "">Null<cfelse>'#Trim(CheckD2)#'</cfif>,</cfif>
		<cfif IsDefined("CheckD3")>CheckD3 = <cfif Trim(CheckD3) Is "">Null<cfelse>'#Trim(CheckD3)#'</cfif>,</cfif>
		<cfif IsDefined("CheckD4")>CheckD4 = <cfif Trim(CheckD4) Is "">Null<cfelse>'#Trim(CheckD4)#'</cfif>,</cfif>
		<cfif IsDefined("CheckD5")>CheckD5 = <cfif Trim(CheckD5) Is "">Null<cfelse>'#Trim(CheckD5)#'</cfif>,</cfif>
		<cfif IsDefined("CheckDigit")>CheckDigit = <cfif Trim(CheckDigit) Is "">Null<cfelse>'#Trim(CheckDigit)#'</cfif>,</cfif>
		<cfif IsDefined("CCType")>CCType = '#Trim(CCType)#',</cfif>
		<cfif IsDefined("CCMon")>CCMon = '#Trim(CCMon)#',</cfif>
		<cfif IsDefined("CCYear")>CCYear = '#Trim(CCYear)#',</cfif>
		<cfif IsDefined("CCNum")>CCNum = <cfif Trim(CCNum) Is "">Null<cfelse>'#Trim(CCNum)#'</cfif>,</cfif>
		<cfif IsDefined("CardHold")>CardHold = <cfif Trim(CardHold) Is "">Null<cfelse>'#Trim(CardHold)#'</cfif>,</cfif>
		<cfif IsDefined("AVSAddr")>AVSAddr = <cfif Trim(AVSAddr) Is "">Null<cfelse>'#Trim(AVSAddr)#'</cfif>,</cfif>
		<cfif IsDefined("AVSZip")>AVSZip = <cfif Trim(AVSZip) Is "">Null<cfelse>'#Trim(AVSZip)#'</cfif>,</cfif>
		<cfif IsDefined("PONum")>PONum = <cfif Trim(PONum) Is "">Null<cfelse>'#Trim(PONum)#'</cfif>,</cfif>
		<cfif IsDefined("PostalInv")>PostalInv = #PostalInv#,</cfif>
		<cfif IsDefined("PONumber")>PONumber = '#PONumber#',</cfif>
		<cfloop query="FieldNames">
			<cfif IsDefined("#FieldName#")>
				<cfset TheValue = Evaluate("#FieldName#")>
				#FieldName# = <cfif Trim(TheValue) Is "">NULL<cfelse>'#TheValue#'</cfif>, 
			</cfif>
		</cfloop>
		<cfloop query="BOBExtraFields">
				<cfset FieldValue = Evaluate("#BOBFieldName#")>
				#BOBFieldName# = <cfif Trim(FieldValue) Is "">NULL<cfelse><cfif DataType Is "Text">'#FieldValue#'<cfelseif DataType Is "Number">#FieldValue#<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#</cfif></cfif>, 
		</cfloop> 
		Taxfree = <cfif IsDefined("TaxFree")>#TaxFree#<cfelse>0</cfif>, 
		TabCompleted = #UpdTab# 
		WHERE AccountID = #AccountID# 
	</cfquery>
</cfif>        