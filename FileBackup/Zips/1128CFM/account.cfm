<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the first page of the Account Wizard. --->
<!---	4.0.0 08/14/99
		3.4.0 06/08/99 Added Required * to the extra info fields is set to required.
		3.2.1 09/16/98 Modified to work with the custom OS Options.
		3.2.0 09/08/98 --->
<!-- account.cfm -->

<cfset securepage="account.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("DelSess")>
	<cfquery name="RemoveOne" datasource="#pds#">
		DELETE FROM AccntTemp 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM AccntTempFin 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM AccntTempInfo 
		WHERE AccountID = #AccountID# 
	</cfquery>
</cfif>
<cfset dropby1 = 1>
<cfinclude template="license.cfm">
<cfif IsDefined("greensoft") is "No">
	<cfset maxuser = "1">
</cfif>
<cfquery name="howmany1" datasource="#pds#">
	SELECT Count(accountid) as CID 
	FROM accounts 
	WHERE cancelyn = 0 
</cfquery>
<cfsetting enablecfoutputonly="no">
<cfif howmany1.cid gt maxuser>
	<HTML>
	<HEAD>
	<TITLE>License</TITLE>
	<cfinclude template="coolsheet.cfm">
	</HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
		<font size="5">License Limit</font>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">This copy of gBill has reached it maximum licensed limit of customers.<br>
Please contact GreenSoft Solutions, Inc. to obtain a higher limit or
cancel some of the current customers.</td>
			</tr>
		</table>
	</cfoutput>
	</center>
	<cfinclude template="footer.cfm">
	</BODY>
	</HTML>
	<cfabort>
</cfif>
<cfsetting enablecfoutputonly="yes">
<cfset ViewList = 0>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT T.AdminID, T.AccountID, T.FirstName, T.LastName, 
	C.LastName As ALN, C.FirstName As AFN 
	FROM AccntTemp T, Admin A, Accounts C 
	WHERE T.AdminID = A.AdminID 
	AND A.AccountID = C.AccountID 
	<cfif GetOpts.SUserYN Is 0>
		AND A.AdminID = #MyAdminID# 
	</cfif>
	ORDER BY C.LastName, C.FirstName, T.LastName, T.FirstName 
</cfquery>
<cfif CheckFirst.RecordCount GT 0>
	<cfset ViewList = 1>
</cfif>
<cfif (GetOpts.SUserYN Is 1) OR (GetOpts.OnlineSignup Is 1)>
	<cfquery name="OnlineSignup" datasource="#pds#">
		SELECT T.AdminID, T.AccountID, T.FirstName, T.LastName 
		FROM AccntTemp T 
		WHERE AdminID = 0 
	</cfquery>
	<cfif OnlineSignup.RecordCount GT 0>
		<cfset ViewList = 1>
	</cfif>
</cfif>
<cfif (GetOpts.SUserYN Is 1) OR (GetOpts.OnlineSignup Is 1)>
	<cfset HowWide = 4>
<cfelse>
	<cfset HowWide = 3>
</cfif>
<cfsetting enablecfoutputonly="no">
<cfif ViewList Is 1>
	<HTML>
	<HEAD>
	<TITLE>Account Wizard</TITLE>
	<cfinclude template="coolsheet.cfm">
	</HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<form method="post" action="account1.cfm">
					<td colspan="#HowWide#" align="right"><input type="image" src="images/addnew.gif" border="0"></td>
				</form>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Finish</th>
				<th>Name</th>
				<cfif (GetOpts.SUserYN Is 1) OR (GetOpts.OnlineSignup Is 1)>
					<th>Entered By</th>
				</cfif>
				<th>Delete</th>
			</tr>
	</cfoutput>
			<cfoutput query="CheckFirst">
				<tr>
					<form method="post" action="account1.cfm">
						<th bgcolor="#tdclr#"><input type="radio" name="AccountID" value="#AccountID#" onClick="submit()"></th>
					</form>
					<td bgcolor="#tbclr#">#LastName#, #FirstName#</td>
					<cfif (GetOpts.SUserYN Is 1) OR (GetOpts.OnlineSignup Is 1)>
						<td bgcolor="#tbclr#">#ALN#, #AFN#</td>
					</cfif>
					<form method="post" action="account.cfm" onsubmit="return confirm('Click Ok to confirm deleting this Account Wizard Session.')">
						<input type="hidden" name="DelSess" value="1">
						<input type="Hidden" name="AccountID" value="#AccountID#">
						<th bgcolor="#tdclr#"><input type="Image" src="images/delete.gif" border="0"></th>
					</form>
				</tr>
			</cfoutput>
			<cfif (GetOpts.SUserYN Is 1) OR (GetOpts.OnlineSignup Is 1)>
				<tr>
					<cfoutput>
						<th colspan="#HowWide#" bgcolor="#thclr#">Online Signups</th>
					</cfoutput>
				</tr>
				<cfoutput query="OnlineSignup">
					<tr>
						<form method="post" action="account1.cfm">
							<th bgcolor="#tdclr#"><input type="radio" name="AccountID" value="#AccountID#" onClick="submit()"></th>
						</form>
						<td bgcolor="#tbclr#">#LastName#, #FirstName#</td>
						<td bgcolor="#tbclr#">Online Signup</td>
						<form method="post" action="account.cfm" onsubmit="return confirm('Click Ok to confirm deleting this Online Signup.')">
							<input type="hidden" name="DelSess" value="1">
							<input type="Hidden" name="AccountID" value="#AccountID#">
							<th bgcolor="#tdclr#"><input type="Image" src="images/delete.gif" border="0"></th>
						</form>
					</tr>			
				</cfoutput>
			</cfif>
		</table>
	</center>
	<cfinclude template="footer.cfm">
	</BODY>
	</HTML>
<cfelse>
	<cflocation addtoken="no" url="account1.cfm">
</cfif>  
     