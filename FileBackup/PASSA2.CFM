<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page 2 for admins to change their password. --->
<!--- 3.2.1 09/01/99 --->
<!--- passa2.cfm --->

<cfset securepage = "passa.cfm">
<cfinclude template="security.cfm">

<cfparam name="BOBMinP" default="4">
<cfparam name="BOBMaxP" default="35">

<cfset ChngStat = "Successful">
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccountID 
	FROM Accounts 
	WHERE Login = '#Log#' 
	AND Password = '#oldpasswd#' 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfset ChngStat = "Failed">
</cfif>
<cfif ChngStat Is "Successful">
	<cfset StatCheck = Compare(NewPasswd,ComPasswd)>
	<cfif StatCheck Is Not 0>
		<cfset ChngStat = "NonConfirm">
	</cfif>
</cfif>
<cfif ChngStat Is "Successful">
	<cfset Len1 = Len(NewPasswd)>
	<cfif (Len1 LT #BOBMinP#) OR (Len1 GT #BOBMaxP#)>
		<cfset ChngStat = "PasswordFail">
	</cfif>	
</cfif>
<cfif ChngStat Is "Successful">
	<cfquery name="UpdPassword" datasource="#pds#" debug="no">
		UPDATE Accounts SET 
		Password = '#NewPasswd#' 
		WHERE AccountID = #CheckFirst.AccountID#
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif ChngStat Is "Successful">
	<title>Password Changed</title>
<cfelse>
	<title>Password Problem</title>
</cfif> 
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfif ChngStat Is "Successful">
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#thclr#">Password Changed</th>
		</tr>
	</table>
	</cfoutput>
<cfelseif ChngStat Is "NonConfirm">
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">The new password did not match the confirmation.</td>
			</tr>
			<tr>
				<form method="post" name="return1" action="passa.cfm">
				<th><INPUT type="image" name="tryagain" src="images/tryagain.gif" border="0"></th>
				</form>
			</tr>
		</table>
	</cfoutput>
<cfelseif ChngStat Is "PasswordFail">
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">The new password is not the correct length.<br>
				Passwords should be between #BOBMinP# and #BOBMaxP# characters long.</td>
			</tr>
			<tr>
				<form method="post" name="return1" action="passa.cfm">
				<th><INPUT type="image" name="tryagain" src="images/tryagain.gif" border="0"></th>
				</form>
			</tr>
		</table>
	</cfoutput>
<cfelse>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">Password Change failed.</td>
			</tr>
			<tr>
				<form method="post" name="return1" action="passa.cfm">
				<th><INPUT type="image" name="tryagain" src="images/tryagain.gif" border="0"></th>
				</form>
			</tr>
		</table>
	</cfoutput>
</cfif>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   