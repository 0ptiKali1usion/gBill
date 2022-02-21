 <cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- accntemail10.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("DelInfo.x")>
	<cfquery name="ClearInfo" datasource="#pds#">
		UPDATE AccountsEMail SET 
		ForwardTo = Null 
		WHERE EMailID = #EMailID#
	</cfquery>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntemail10.cfm' 
		AND L.LocationAction = 'Delete' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'EMail') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfset LocEMailID = EMailID>
		<cfset LocAccntPlanID = AccntPlanID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfset Tab = 4>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="accntmanage2.cfm">
	<cfabort>	
</cfif>
<cfif IsDefined("AddInfo.x")>
		<cfset UNNoPass = "The forwarding address in not a valid EMail address.">
		<!--- Check for legit email address --->
		<cfset EMailCheck = ForwAddress>
		<cfset Pos1 = Find("@",ForwAddress)>
		<cfif Pos1 GT 0>
			<cfset Str1 = Pos1>
		<cfelse>
			<cfset Str1 = 1>
		</cfif>
		<cfset Pos2 = Find(".",ForwAddress,Str1)>
		<cfif (Pos1 GT 0) AND (Pos2 GT 0)>
			<cfquery name="UpdForward" datasource="#pds#">
				UPDATE AccountsEMail SET 
				ForwardTo = '#ForwAddress#' 
				WHERE EMailID = #EMailID# 
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetAddr" datasource="#pds#">
					SELECT EMail, AccountID 
					FROM AccountsEMail 
					WHERE EMailID = #EMailID# 
				</cfquery>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT FirstName, LastName 
					FROM Accounts 
					WHERE AccountID = 
						(SELECT AccountID 
						 FROM AccountsEMail 
						 WHERE EMailID = #EMailID#) 
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#GetAddr.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
					 '#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the email address #GetAddr.EMail# and changed the Forward to #ForwAddress# for #GetWhoName.FirstName# #GetWhoName.LastName#.')
				</cfquery>
			</cfif>
			<cfquery name="GetScripts" datasource="#pds#">
				SELECT I.IntID 
				FROM Integration I, IntScriptLoc S, IntLocations L 
				WHERE I.IntID = S.IntID 
				AND S.LocationID = L.LocationID 
				AND L.ActiveYN = 1 
				AND I.ActiveYN = 1 
				AND L.PageName = 'accntemail10.cfm' 
				AND L.LocationAction = 'Create' 
				AND I.TypeID = 
					(SELECT TypeID 
					 FROM IntTypes 
					 WHERE TypeStr = 'EMail') 
			</cfquery>
			<cfif GetScripts.RecordCount GT 0>
				<cfset LocScriptID = ValueList(GetScripts.IntID)>
				<cfset LocEMailID = EMailID>
				<cfset LocAccntPlanID = AccntPlanID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="runintegration.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif>
			<!--- Run external --->
			<cfif FileExists(ExpandPath("external#OSType#extcreateemail.cfm"))>
				<cfset SendID = EMailID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="external#OSType#extcreateemail.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif> 
			<cfset Tab = 4>
			<cfsetting enablecfoutputonly="No">
			<cfinclude template="accntmanage2.cfm">
			<cfabort>	
		</cfif>
</cfif>

<cfquery name="MainEMail" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>
<cfquery name="EMailServer" datasource="#pds#">
	SELECT * 
	FROM CustomEMail 
	WHERE CEmailID = 
		(SELECT CEMailID 
		 FROM Domains 
		 WHERE DomainID = #MainEMail.DomainID#)
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>EMail Setup</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#MainEMail.AccntPlanID#"></cfoutput>
	<input type="hidden" name="tab" value="4">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#MainEMail.EMail#</font></th>
	</tr>
	<cfif EMailServer.AllowForward Is 1>
		<form method="post" action="accntemail10.cfm">
			<cfif IsDefined("UNNoPass")>
				<tr bgcolor="#tbclr#">
					<td colspan="3">#UNNoPass#</td>
				</tr>
			</cfif>
			<tr bgcolor="#tbclr#">
				<th valign="top" bgcolor="#tdclr#"><input type="Radio" checked name="AddType" value="Alias"></th>
				<td>Email Forward</td>
				<td bgcolor="#tdclr#"><input type="Text" name="ForwAddress" <cfif IsDefined("ForwAddress")>value="#ForwAddress#"<cfelse>value="#MainEMail.ForWardTo#"</cfif> maxlength="150" size="35"></td>
			</tr>
			<tr>
				<th colspan="3">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td><input type="Image" name="AddInfo" src="images/enter.gif" border="0"></td>
							<td><input type="Image" name="DelInfo" src="images/delete.gif" border="0"></td>
						</tr>
					</table>
				</th>
			</tr>
			<input type="hidden" name="AccntPlanID" value="#MainEMail.AccntPlanID#">
			<input type="Hidden" name="EMailID" value="#EMailID#">
		</form>
	<cfelse>
			<tr>
				<td bgcolor="#tbclr#" colspan="3">#EMailServer.EMailDescription#<br>
				This custom EMail does not support EMail forwarding.<br>
				<a href="customemail.cfm">Custom EMail Setup</a></td>
			</tr>
	</cfif>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 