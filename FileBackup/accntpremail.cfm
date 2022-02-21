<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 04/04/00 --->
<!--- accntpremail.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("NewPrEMail")>
	<cftransaction>
		<cfquery name="ClearOld" datasource="#pds#">
			UPDATE AccountsEMail SET 
			PrEMail = 0 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfquery name="SetNew" datasource="#pds#">
			UPDATE AccountsEMail SET 
			PrEMail = 1 
			WHERE EMailID = #NewPrEMail# 
		</cfquery>
	</cftransaction>
</cfif>

<cfquery name="AllAddresses" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE AccountID = #AccountID# 
	AND Alias = 0 
	ORDER BY EMail 
</cfquery>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Select Primary EMail Address</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="accountid" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName#<br>EMail Address</font></th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Primary</th>
		<th>Address</th>
	</tr>
</cfoutput>
	<form method="post" action="accntpremail.cfm">
		<cfoutput query="AllAddresses">
			<tr>
				<th bgcolor="#thclr#"><input type="Radio" <cfif PrEMail Is 1>checked</cfif> name="NewPrEMail" value="#EMailID#" onclick="submit()"></th>
				<td bgcolor="#tbclr#">#EMail#</td>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="Hidden" name="AccountID" value="#AccountID#">
		</cfoutput>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 