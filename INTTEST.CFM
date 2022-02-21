<cfsetting enablecfoutputonly="yes">
<!--- Version 3.5.0 --->
<!--- This is the page that tests a script. --->
<!--- 3.5.0 07/07/99 --->
<!--- inttest.cfm --->

<cfset securepage="integration.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("ScriptTest")>
	<cfif IDField Is "AccountID">
		<cfset LocAccountID = IDValue>
	<cfelseif IDField Is "AccntPlanID">
		<cfset LocAccntPlanID = IDValue>
	<cfelseif IDField IS "DomainID">
		<cfset LocDomainID = IDValue>
	<cfelseif IDField IS "POPID">
		<cfset LocPOPID = IDValue>
	<cfelseif IDField IS "PlanID">
		<cfset LocPlanID = IDValue>
	<cfelseif IDField IS "EMailID">
		<cfset LocEMailID = IDValue>
	<cfelseif IDField IS "AliasID">
		<cfset LocAliasID = IDValue>
	</cfif>
	<cfset LocScriptID = IntID>
	<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
	<cfsetting enablecfoutputonly="yes">
</cfif>
<cfquery name="OneScript" datasource="#pds#">
	SELECT * 
	FROM Integration 
	WHERE IntID = #IntID#
</cfquery>
<cfquery name="GetUserID" datasource="#pds#">
	SELECT AccountID 
	FROM Admin 
	WHERE AdminID = #MyAdminID#
</cfquery>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Script Test</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="integration.cfm">
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="3" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Test Script - #OneScript.IntDesc#</font></th>
		</tr>
		<cfif IsDefined("ScriptTest")>
			<tr>
				<form method="post" action="inttest.cfm">
					<input type="hidden" name="IntID" value="#IntID#">
					<td align="right" colspan="3"><input type="image" src="images/changecriteria.gif" border="0"></td>
				</form>
			</tr>
			<tr>
				<td colspan="3" bgcolor="#tbclr#">Test ran without a Cold Fusion error.  Please check the script results to complete this test.</td>
			</tr>
			<tr>
				<form method="post" action="inttest.cfm">
					<input type="hidden" name="IntID" value="#IntID#">
					<input type="hidden" name="IDField" value="#IDField#">
					<input type="hidden" name="IDValue" value="#IDValue#">
					<th colspan="3"><input type="submit" name="ScriptTest" value="Test Again"></th>
				</form>
			</tr>
		<cfelse>
			<tr>
				<form method="post" action="inttest.cfm">
					<input type="hidden" name="IntID" value="#IntID#">
					<td align="right" bgcolor="#tdclr#"><select name="IDField">
						<option value="AccountID">Customer UserID
						<option value="AccntPlanID">Customer Plan ID
						<option value="DomainID">Domain ID
						<option value="POPID">POP ID
						<option value="PlanID">Plan ID
						<option value="EMailID">EMail ID
						<option value="AliasID">EMail Alias ID
					</select></td>
					<td bgcolor="#tdclr#"><input type="text" name="IDValue" value="#GetUserID.AccountID#" size="4"></td>
					<td bgcolor="#tdclr#"><input type="submit" name="ScriptTest" value="Run Test"></td>
				</form>
			</tr>
		</cfif>
</cfoutput>

</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>



