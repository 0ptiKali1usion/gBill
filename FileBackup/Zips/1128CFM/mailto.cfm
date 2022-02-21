 <cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Sends email and tracks it in gBill history --->
<!---	4.0.0 04/29/00 --->
<!--- mailto.cfm --->

<cfif IsDefined("SendIt.x")>
	<cfquery name="GetInfo" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE EMail = '#EMail#'
	</cfquery>
	<cfif SendEMail Is 1>
		<cfif GetOpts.SendEMail Is 1>
			<cfmail to="#EMail#" from="#WhoFrom#" subject="#Subject#">
#MailMessage#
</cfmail>
		</cfif>
	</cfif>
	<cfquery name="BOBHistory" datasource="#pds#">
		INSERT INTO BOBHist 
		(ActionEmail, AccountID, AdminID, ActionDate, Action, ActionDesc) 
		VALUES 
		('#MailMessage#', #GetInfo.AccountID#, #MyAdminID#, #Now()#, 'E-Mailed', 
		 '#StaffMemberName.FirstName# #StaffMemberName.Lastname# sent an email to #GetInfo.FullName#') 
	</cfquery>
	<cfset MessageStr = "Message sent">
</cfif>

<cfquery name="GetInfo" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMail = '#EMail#'
</cfquery>
<cfquery name="GetWhoFrom" datasource="#pds#">
	SELECT EMail 
	FROM AccountsEMail 
	WHERE PrEMail = 1 
	AND AccountID = 
		(SELECT AccountID 
		 FROM Admin 
		 WHERE AdminID = #MyAdminID#)
</cfquery>
<cfif GetWhoFrom.RecordCount GT 0>
	<cfset WhoFrom = GetWhoFrom.EMail>
<cfelse>
	<cfset WhoFrom = ServMail>
</cfif>

<cfsetting enablecfoutputonly="No">

<HTML>
<HEAD>
<TITLE>E-Mail</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">E-Mail Form</font></th>
	</tr>
	<cfif IsDefined("MessageStr")>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">#MessageStr#</td>
		</tr>
	<cfelse>
		<form method="post" action="mailto.cfm">
			<tr bgcolor="#tbclr#">
				<td align="right">To:</td>
				<td>#EMail#</td>
				<input type="Hidden" name="EMail" value="#EMail#">
			</tr>
			<tr bgcolor="#tbclr#">
				<td align="right">From</td>
				<td>#WhoFrom#</td>
				<input type="Hidden" name="WhoFrom" value="#WhoFrom#">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Subject</td>
				<td bgcolor="#tdclr#"><input type="Text" name="Subject" size="35"></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Message</td>
				<td bgcolor="#tdclr#"><textarea name="MailMessage" cols="35" rows="8"></textarea></td>
			</tr>
			<tr>
				<th colspan="2"><input type="Image" name="SendIt" src="images/sendemail.gif" border="0"></th>
			</tr>
		</form>
	</cfif>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
