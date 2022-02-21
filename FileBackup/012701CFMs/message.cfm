<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Staff Message Management. --->
<!---	4.0.0 11/17/99 --->
<!--- message.cfm --->

<cfinclude template="security.cfm">

<cfquery name="GetAllMessages" datasource="#pds#">
	SELECT * 
	FROM StaffMessages 
	ORDER BY ExpireDate 
</cfquery>
<cfif GetAllMessages.Recordcount Is 0>
	<cfset HowWide = 1>
<cfelse>
	<cfset HowWide = 6>
</cfif>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Staff Messages</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Staff Messages</font></th>
	</tr>
	<tr>
		<form method="post" action="message2.cfm">
			<td align="right" colspan="#HowWide#"><input type="image" name="AddNew" src="images/addnew.gif" border="0"></td>
		</form>
	</tr>
</cfoutput>
<cfif GetAllMessages.Recordcount Is 0>
	<cfoutput>
		<tr>
			<td bgcolor="#tbclr#" colspan="#HowWide#">No staff messages at this time.</td>
		</tr>
	</cfoutput>
<cfelse>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Edit</th>
			<th>Active</th>
			<th>Message</th>
			<th>Start</th>
			<th>Expire</th>
			<th>Display</th>
		</tr>
	</cfoutput>
	<cfoutput query="GetAllMessages">
		<form method="post" action="message2.cfm">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="MessageID" value="#MessageID#" onclick="submit()"></th>
				<td>#YesNoFormat(ActiveYN)#</td>
				<td>#Mid(Message,1,50)#...</td>
				<td>#LSDateFormat(StartDate, '#DateMask1#')#</td>
				<td>#LSDateFormat(ExpireDate, '#DateMask1#')#</td>			
				<cfif DisplayCode Is 1>
					<td>Read Once</td>
				<cfelseif DisplayCode Is 2>
					<td>Acknowledge Reading</td>
				<cfelseif DisplayCode Is 3>
					<td>Expire Date</td>
				</cfif>
			</tr>
		</form>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 