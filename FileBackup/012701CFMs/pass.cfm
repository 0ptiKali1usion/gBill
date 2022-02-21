<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page starts the change password process. --->
<!--- 4.0.0 10/15/99 --->
<!--- pass.cfm --->
<cfif GetOpts.ChPass Is 1>
	<cfset securepage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="AllPlans" datasource="#pds#">
	SELECT A.AccntPlanID, A.AccountID, P.PlanID, P.PlanDesc 
	FROM AccntPlans A, Plans P 
	WHERE A.PlanID =  P.PlanID 
	AND A.AccountID = #AccountID# 
	ORDER BY P.PlanDesc 
</cfquery>
<cfquery name="AdminCheck" datasource="#pds#">
	SELECT AdminID 
	FROM Admin 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="gBillLoginInfo" datasource="#pds#">
	SELECT Login, Password  
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfset HowWide = 3>
<cfset AuthNumber = 0>
<cfset FTPNumber = 0>
<cfset EmailNumber = 0>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Change Passwords</TITLE>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!--
function SelectAll(var1)
	{
	 var lenA = document.accounts.AuthNumber.value;
	 if (lenA == 1)
			{
			 document.accounts.AuthID.checked = var1;
			}
	 else
		{
		 var lenA1 = document.accounts.AuthID.length;
		 var i;  
    	 for(i=0; i<lenA1; i++) 
	 		{
			 document.accounts.AuthID[i].checked=var1;
      	} 
		} 			
	 var lenF = document.accounts.FTPNumber.value;
	 if (lenF == 1)
		{
		 document.accounts.FTPID.checked = var1;
		}
	 else
		{
		 var lenF1 = document.accounts.FTPID.length;
		 var i;  
    	 for(i=0; i<lenF1; i++) 
	 		{
			 document.accounts.FTPID[i].checked=var1;
      	} 
		} 
	 var lenE = document.accounts.EMailNumber.value;
	 if (lenE == 1)
		{
		 document.accounts.EMailID.checked = var1;
		}
	 else
		{
		 var lenE1 = document.accounts.EMailID.length;
		 var i;  
    	 for(i=0; i<lenE1; i++) 
	 		{
			 document.accounts.EMailID[i].checked=var1;
      	} 
		} 
	 return false;     
	}
// -->
</script>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" name="return" action="custinf1.cfm">
	<input type="hidden" name="accountid" value="#AccountID#">
	<input type="image" name="return" src="images/returncust.gif" border="0">
</form>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Change Passwords</font></th>
	</tr>

	<tr>
		<th colspan="#HowWide#" bgcolor="#thclr#">Select the passwords to change.</th>
	</tr>
	<tr>
		<form method="post" action="pass.cfm" name="allselect" onsubmit="return SelectAll(true)">
			<th colspan="#HowWide#">
				<table border="0">
					<tr>
						<td><input type="image" src="images/selectall.gif" name="selectemall" border="0"></td>
						<input type="hidden" name="accountid" value="#accountid#">
		</form>
		<form method="post" action="pass.cfm" name="unselect" onsubmit="return SelectAll(false)">
						<td><input type="image" src="images/clear.gif" name="clearemall" border="0"></td>
						<input type="hidden" name="accountid" value="#accountid#">
					</tr>
				</table>
			</th>
		</form>
	</tr>
</cfoutput>
<form method="post" name="accounts" action="pass2.cfm">
	<cfoutput>
		<tr>
			<th colspan="#HowWide#" bgcolor="#thclr#">gBill Login</th>
		</tr>
		<tr bgcolor="#tbclr#">
			<th bgcolor="#tdclr#"><input type="checkbox" checked <cfif IsDefined("selectemall.x")>checked</cfif> name="gBillID" value="#AccountID#"></th>
			<td>#gBillLoginInfo.Login#</td>
		<!---	<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
				<td>#gBillLoginInfo.Password#</td>
			<cfelse> --->
				<td>************</td>
		<!---	</cfif> --->
		</tr>
	</cfoutput>
<cfloop query="AllPlans">
	<cfsetting enablecfoutputonly="yes">
		<cfquery name="PlanAuths" datasource="#pds#">
			SELECT AuthID, UserName, Password 
			FROM AccountsAuth 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #AccntPlanID# 
			ORDER BY UserName 
		</cfquery>
		<cfquery name="PlanFTPS" datasource="#pds#">
			SELECT FTPID, UserName, Password 
			FROM AccountsFTP 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #AccntPlanID# 
			ORDER BY UserName 
		</cfquery>
		<cfquery name="PlanEMails" datasource="#pds#">
			SELECT EMailID, email, epass 
			FROM AccountsEMail 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #AccntPlanID# 
			AND Alias = 0 
			AND ContactYN = 0 
		</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfoutput>
		<tr>
			<th colspan="#HowWide#" bgcolor="#thclr#">#PlanDesc#</th>
		</tr>
 		<cfif PlanAuths.Recordcount GT 0>
			<tr>
				<td colspan="#HowWide#" bgcolor="#tdclr#">Authentication</td>
			</tr>
		</cfif>
	</cfoutput>
	<cfloop query="PlanAuths">
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" <cfif IsDefined("AuthIDList")><cfif ListFind(AuthIDList,AuthID) GT 0>checked</cfif></cfif><cfif IsDefined("selectemall.x")>checked</cfif> name="AuthID" value="#AuthID#"></th>
				<td>#UserName#</td>
			<!---	<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
					<td>#Password#</td>
				<cfelse> --->
					<td>************</td>
			<!---	</cfif> --->
			</tr>
			<cfset AuthNumber = AuthNumber + 1>
		</cfoutput>
	</cfloop>
	<cfoutput>
		<cfif PlanFTPs.Recordcount GT 0>
			<tr>
				<td colspan="#HowWide#" bgcolor="#tdclr#">FTP</td>
			</tr>
		</cfif>
	</cfoutput>
	<cfloop query="PlanFTPS">
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" <cfif IsDefined("FTPIDList")><cfif ListFind(FTPIDList,FTPID) GT 0>checked</cfif></cfif><cfif IsDefined("selectemall.x")>checked</cfif> name="FTPID" value="#FTPID#"></th>
				<td>#UserName#</td>
			<!---	<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
					<td>#Password#</td>
				<cfelse> --->
					<td>************</td>
			<!---	</cfif> --->
			</tr>
			<cfset FTPNumber = FTPNumber + 1>
		</cfoutput>
	</cfloop>	
	<cfoutput>
		<cfif PlanEMails.Recordcount GT 0>
			<tr>
				<td colspan="#HowWide#" bgcolor="#tdclr#">E-Mail</td>
			</tr>
		</cfif>
	</cfoutput>
	<cfloop query="PlanEMails">
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" <cfif IsDefined("EMailIDList")><cfif ListFind(EMailIDList,EMailID) GT 0>checked</cfif></cfif><cfif IsDefined("selectemall.x")>checked</cfif> name="EMailID" value="#EMailID#"></th>
				<td>#EMail#</td>
			<!---	<cfif (GetOpts.ViewCPasswd Is 1) AND ((AdminCheck.Recordcount Is 0) OR (GetOpts.ViewAPasswd Is 1))>
					<td>#EPass#</td>
				<cfelse> --->
					<td>************</td>
			<!---	</cfif> --->
			</tr>
			<cfset EMailNumber = EMailNumber + 1>
		</cfoutput>
	</cfloop>	
</cfloop>
<tr>
	<cfoutput>
		<th colspan="#HowWide#"><input type="image" src="images/continue.gif" name="ChngPasswd" border="0"></th>
		<input type="hidden" name="accountid" value="#AccountID#">
		<input type="hidden" name="AuthNumber" value="#AuthNumber#">
		<input type="hidden" name="FTPNumber" value="#FTPNumber#">
		<input type="hidden" name="EMailNumber" value="#EMailNumber#">
	</cfoutput>
</tr>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 