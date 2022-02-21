<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the email setup. --->
<!--- 4.0.0 11/09/99 --->
<!--- customemail2.cfm --->

<cfset securepage="customemail.cfm">
<cfinclude template="security.cfm">

<cfif (IsDefined("MvRt")) AND (IsDefined("TheHaveNots"))>
	<cfquery name="MvEmRight" datasource="#pds#">
		UPDATE Domains SET 
		CemailID = #CemailID# 
		WHERE DomainID IN (#TheHaveNots#)
	</cfquery>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("TheHaves"))>
	<cfquery name="MvEmLeft" datasource="#pds#">
		UPDATE Domains SET 
		CemailID = 0 
		WHERE DomainID IN (#TheHaves#)
	</cfquery>
</cfif>
<cfif IsDefined("UpdSelected.x")>
	<cfquery name="SetUse" datasource="#pds#">
		UPDATE CustomemailSetup 
		SET ActiveYN = 0 
		WHERE CemailID = #CemailID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
	</cfquery>
	<cfquery name="SetSelect" datasource="#pds#">
		UPDATE CustomemailSetup 
		SET ActiveYN = 1 
		WHERE CustomemailID IN (#CustomemailID#) 
	</cfquery>
	<cfquery name="UpdEMail" datasource="#pds#">
		UPDATE CustomEMail SET
		<cfif IsDefined("AllowAlias")>
			AllowAlias = 1, 
		<cfelse>
			AllowAlias = 0,
		</cfif>
		<cfif IsDefined("AllowForward")>
			AllowForward = 1 
		<cfelse>
			AllowForward = 0 
		</cfif>
		WHERE CemailID = #CemailID# 
	</cfquery>
</cfif>

<cfparam name="Tab" default="1">
<cfif Tab Is 1>
	<cfset HowWide = 3>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT * 
		FROM CustomemailSetup 
		WHERE CemailID = #CemailID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
		ORDER BY BOBName 
	</cfquery>
<cfelse>
	<cfset HowWide = 3>
	<cfquery name="GetSelected" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, Customemail A 
		WHERE D.CemailID = A.CemailID 
		AND D.CemailID = #CemailID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="AvailOnes" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, A.emailDescription 
		FROM Domains D, Customemail A 
		WHERE D.CemailID = A.CemailID 
		AND D.CemailID <> #CemailID# 
		UNION 
		SELECT D.DomainID, D.DomainName, 'None' as emailDescription 
		FROM Domains D 
		WHERE D.CemailID = 0 
		OR D.CemailID IS NULL 
		ORDER BY DomainName 
	</cfquery>
</cfif>
<cfquery name="Getemail" datasource="#pds#">
	SELECT EMailDescription, AllowAlias, AllowForward 
	FROM Customemail 
	WHERE CemailID = #CemailID# 
</cfquery>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfoutput><title>#Getemail.emailDescription# Setup</title></cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="customemail.cfm">
	<input type="image" name="retrun" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#Getemail.emailDescription# Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="customemail2.cfm">
						<th bgcolor=<cfif tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Database</label></th>
						<th bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Domains</label></th>
						<input type="hidden" name="CemailID" value="#CemailID#">
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Use</th>
				<th>FieldName</th>
				<th>Description</th>
			</tr>
		</cfoutput>
		<form method="post" action="customemail2.cfm">
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#"><input type="checkbox" <cfif Getemail.AllowAlias Is "1">checked</cfif> name="AllowAlias" value="1"></th>
					<td>&nbsp;</td>
					<td>Scriptable Alias</td>
				</tr>
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#"><input type="checkbox" <cfif Getemail.AllowForward Is "1">checked</cfif> name="AllowForward" value="1"></th>
					<td>&nbsp;</td>
					<td>Scriptable Forwarding</td>
				</tr>
			</cfoutput>
			<cfloop query="GetFields">
				<cfoutput>
					<tr bgcolor="#tbclr#">
						<th bgcolor="#tdclr#"><input type="checkbox" <cfif ActiveYN Is "1">checked</cfif> name="CustomemailID" value="#CustomemailID#"></th>
						<td>#BOBName#</td>
						<td>#emailDescription#</td>
					</tr>
				</cfoutput>
			</cfloop>
			<cfoutput>
				<input type="hidden" name="CemailID" value="#CemailID#">
			</cfoutput>
			<tr>
				<th colspan="3"><input type="image" src="images/update.gif" name="UpdSelected" border="0"></th>
			</tr>
		</form>
<cfelseif Tab Is 2>
	<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Available Domains</th>
		<th>Action</th>
		<th>Selected Domains</th>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<form method="post" action="customemail2.cfm">
			<th><select name="TheHaveNots" multiple size="10">
				<cfloop query="AvailOnes">
					<cfoutput><option value="#DomainID#">#DomainName# - #emailDescription#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select><br>Selecting a domain will override<br>the current setup for the selected domain.</th>
			<th align="center" valign="middle"><input type="submit" name="MvRt" value="---->"><br>
			<input type="submit" name="MvLt" value="<----"><br></th>
			<th><select name="TheHaves" multiple size="10">
				<cfloop query="GetSelected">
					<cfoutput><option value="#DomainID#">#DomainName#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select></th>
			<cfoutput>
				<input type="hidden" name="CemailID" value="#CemailID#">
				<input type="hidden" name="tab" value="2">
			</cfoutput>
		</form>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 