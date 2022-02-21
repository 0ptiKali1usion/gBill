<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page starts the change password process. --->
<!--- 4.0.0 10/15/99 --->
<!--- pass2.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfquery name="AdminCheck" datasource="#pds#">
	SELECT AdminID 
	FROM Admin 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfset TheLogic = 0>
<cfquery name="GetPlans" datasource="#pds#">
	SELECT PlanID, PlanDesc 
	FROM Plans 
	WHERE PlanID <> 0 
	AND 
	<cfif (IsDefined("AuthID")) OR (IsDefined("FTPID")) OR (IsDefined("EMailID"))>
		(
		<cfif IsDefined("AuthID")>
			<cfif AuthID Is Not "">
			 	PlanID In 
				(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID IN 
				 	(Select AccntPlanID 
					 FROM AccountsAuth 
					 WHERE AuthID In (#AuthID#)
					) 
				)
				<cfset TheLogic = 1>
			</cfif>
		</cfif>
		<cfif IsDefined("FTPID")>
			<cfif FTPID Is Not "">
				<cfif TheLogic Is 1>OR</cfif> 
				 PlanID In
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID IN
					 	(SELECT AccntPlanID 
						 FROM AccountsFTP 
						 WHERE FTPID In (#FTPID#)
						 )
					)
				<cfset TheLogic = 1>
			</cfif>
		</cfif>
		<cfif IsDefined("EMailID")>
			<cfif EMailID Is Not "">
				<cfif TheLogic Is 1>OR</cfif> 
				 PlanID In 
					(SELECT PlanID 
					 FROM AccntPlans 
					 WHERE AccntPlanID IN 
					 	(SELECT AccntPlanID 
						 FROM AccountsEMail 
						 WHERE EMailID In (#EMailID#)
						)
					)
			</cfif>
		</cfif>
		)
	<cfelse>
		PlanID = 0 
	</cfif>
	ORDER BY PlanDesc 
</cfquery>
<cfquery name="gBillLoginInfo" datasource="#pds#">
	SELECT Login, Password  
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfset ReqShow = 0>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Change Password</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" name="return" action="pass.cfm">
	<input type="image" name="return" src="images/returncust.gif" border="0">
	<input type="hidden" name="accountid" value="#AccountID#">
	<cfif IsDefined("AuthID")>
		<input type="hidden" name="AuthIDList" value="#AuthID#">
	</cfif>
	<cfif IsDefined("FTPID")>
		<input type="hidden" name="FTPIDList" value="#FTPID#">
	</cfif>
	<cfif IsDefined("EMailID")>
		<input type="hidden" name="EMailIDList" value="#EMailID#">
	</cfif>
</form>
<center>
<table border="#tblwidth#">
</cfoutput>
<form method="post" action="pass3.cfm">
<cfif IsDefined("gBillID")>
	<cfoutput>
		<tr>
			<th colspan="2" bgcolor="#thclr#">gBill Login</th>
			<input type="Hidden" name="gBillID" value="#AccountID#">
			<input type="Hidden" name="gBillLoginName" value="#gBillLoginInfo.Login#"
		</tr>
		<tr>
			<td bgcolor="#tbclr#">#gBillLoginInfo.Login#</td>
			<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
				<td bgcolor="#tdclr#"><input type="text" name="gBillPassword" value=""></td>
			<cfelse>
				<td bgcolor="#tdclr#"><input type="password" name="gBillPassword" value="#gBillLoginInfo.PassWord#"></td>
			</cfif>
		</tr>
	</cfoutput>
</cfif>
<cfloop query="GetPlans">
	<tr>
		<cfoutput><th colspan="2" bgcolor="#thclr#">#PlanDesc#</th></cfoutput>
	</tr>
	<cfset LoopPlanID = PlanID>
	<cfsetting enablecfoutputonly="yes">
		<cfquery name="PlanAuths" datasource="#pds#">
			SELECT R.AuthID, R.UserName, R.Password, R.AccntPlanID, P.PlanID, P.AuthMinPassw, 
			P.AuthMaxPassw, P.AuthMixPassw 
			FROM AccountsAuth R, AccntPlans A, Plans P 
			WHERE R.AccntPlanID = A.AccntPlanID 
			AND A.PlanID = P.PlanID 
			AND R.AccountID = #AccountID# 
			AND P.PlanID = #LoopPlanID# 
			<cfif IsDefined("AuthID")>
				AND R.AuthID In (#AuthID#) 
			<cfelse>
				AND R.AuthID In (0) 
			</cfif>
			ORDER BY R.UserName 
		</cfquery>
		<cfquery name="PlanFTPS" datasource="#pds#">
			SELECT F.FTPID, F.UserName, F.Password, F.AccntPlanID, P.PlanID, P.FTPMinPassw, 
			P.FTPMaxPassw, P.FTPMixPassw 
			FROM AccountsFTP F, AccntPlans A, Plans P 
			WHERE F.AccntPlanID = A.AccntPlanID 
			AND A.PlanID = P.PlanID 
			AND F.AccountID = #AccountID# 
			AND P.PlanID = #LoopPlanID# 
			<cfif IsDefined("FTPID")>
				AND F.FTPID In (#FTPID#) 
			<cfelse>
				AND F.FTPID In (0) 
			</cfif>
			ORDER BY F.UserName 
		</cfquery>
		<cfquery name="PlanEMails" datasource="#pds#">
			SELECT E.EMailID, E.EMail, E.EPass, E.AccntPlanID, P.PlanID, P.MailMinPassw, 
			P.MailMaxPassw, MailMixPassw 
			FROM AccountsEMail E, AccntPlans A, Plans P 
			WHERE E.AccntPlanID = A.AccntPlanID 
			AND A.PlanID = P.PlanID 
			AND E.AccountID = #AccountID# 
			AND P.PlanID = #LoopPlanID# 
			<cfif IsDefined("EMailID")>
				AND E.EMailID In (#EMailID#) 
			<cfelse>
				AND E.EMailID In (0) 
			</cfif>
			ORDER BY E.EMail 
		</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfif PlanAuths.Recordcount GT 0>
		<tr>
			<cfoutput><td colspan="2" bgcolor="#tdclr#">Authentication (#PlanAuths.AuthMinPassw# to #PlanAuths.AuthMaxPassw# characters.<cfif PlanAuths.AuthMixPassw Is 1> Must contain letters and numbers.</cfif>)</td></cfoutput>
		</tr>
	</cfif>
	<cfloop query="PlanAuths">
		<cfif LoopPlanID Is PlanID>
			<cfoutput>
				<tr>
					<td bgcolor="#tbclr#">#UserName#</td>
					<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
						<td bgcolor="#tdclr#"><cfif IsDefined("AuthNoPass")><cfif ListFind(AuthNoPass,AuthID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="text" name="Password#AuthID#" value="#PassWord#" maxlength="#AuthMaxPassw#"></td>
					<cfelse>
						<td bgcolor="#tdclr#"><cfif IsDefined("AuthNoPass")><cfif ListFind(AuthNoPass,AuthID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="password" name="Password#AuthID#" value="#PassWord#" maxlength="#AuthMaxPassw#"></td>
					</cfif>
					<input type="hidden" name="AuthID" value="#AuthID#">
					<input type="Hidden" name="AuthName#AuthID#" value="#UserName#">
					<input type="hidden" name="Password#AuthID#_Required" value="Enter the new password for #UserName#">
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
	<cfif PlanFTPs.Recordcount GT 0>
		<tr>
			<cfoutput><td colspan="2" bgcolor="#tdclr#">FTP (#PlanFTPs.FTPMinPassw# to #PlanFTPs.FTPMaxPassw# characters.<cfif PlanFTPs.FTPMixPassw Is 1> Must contain letters and numbers.</cfif>)</td></cfoutput>
		</tr>
	</cfif>
	<cfloop query="PlanFTPs">
		<cfif LoopPlanID Is PlanID>
			<cfoutput>
				<tr>
					<td bgcolor="#tbclr#">#UserName#</td>
					<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
						<td bgcolor="#tdclr#"><cfif IsDefined("FTPNoPass")><cfif ListFind(FTPNoPass,FTPID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="text" name="FTPPassword#FTPID#" value="#PassWord#" maxlength="#FTPMaxPassw#"></td>
					<cfelse>
						<td bgcolor="#tdclr#"><cfif IsDefined("FTPNoPass")><cfif ListFind(FTPNoPass,FTPID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="password" name="FTPPassword#FTPID#" value="#PassWord#" maxlength="#FTPMaxPassw#"></td>
					</cfif>
					<input type="hidden" name="FTPID" value="#FTPID#">
					<input type="Hidden" name="FTPName#FTPID#" value="#UserName#">
					<input type="hidden" name="FTPPassword#FTPID#_Required" value="Enter the new password for #UserName#">					
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
	<cfif PlanEMails.Recordcount GT 0>
		<tr>
			<cfoutput><td colspan="2" bgcolor="#tdclr#">E-Mail  (#PlanEMails.MailMinPassw# to #PlanEMails.MailMaxPassw# characters.<cfif PlanEMails.MailMixPassw Is 1> Must contain letters and numbers.</cfif>)</td></cfoutput>
		</tr>
	</cfif>
	<cfloop query="PlanEMails">
		<cfif LoopPlanID Is PlanID>
			<cfoutput>
				<tr>
					<td bgcolor="#tbclr#">#EMail#</td>
					<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
						<td bgcolor="#tdclr#"><cfif IsDefined("EMailNoPass")><cfif ListFind(EMailNoPass,EMailID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="text" name="EMailPassword#EMailID#" value="#Epass#" maxlength="#MailMaxPassw#"></td>
					<cfelse>
						<td bgcolor="#tdclr#"><cfif IsDefined("EMailNoPass")><cfif ListFind(EMailNoPass,EMailID) GT 0><cfset ReqShow = 1>*</cfif></cfif><input type="password" name="EMailPassword#EMailID#" value="#Epass#" maxlength="#MailMaxPassw#"></td>
					</cfif>
					<input type="hidden" name="EMailID" value="#EMailID#">
					<input type="Hidden" name="EMailName#EMailID#" value="#EMail#">
					<input type="hidden" name="EMailPassword#EMailID#_Required" value="Enter the new password for #EMail#">	
				</tr>
			</cfoutput>
		</cfif>
	</cfloop>
</cfloop>
<cfif ReqShow Is 1>
	<tr>
		<cfoutput>
			<td colspan="2" bgcolor="#tbclr#">* Problem passwords.  Please change and re submit.</td>
		</cfoutput>
	</tr>
</cfif>
<tr>	
	<th colspan="2"><input type="image" name="ChangePasswords" src="images/custinf2.gif" border="0"></th>
</tr>
<cfoutput>
	<input type="hidden" name="AccountID" value="#AccountID#">
</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 