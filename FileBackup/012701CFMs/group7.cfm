<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/26/99 --->
<!--- group7.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="Deacts" datasource="#pds#">
	SELECT * 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	AND DeactivateYN = 1 
</cfquery>
<cfquery name="Reacts" datasource="#pds#">
	SELECT * 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	AND ReactivateYN = 1 
</cfquery>
<cfquery name="Cancels" datasource="#pds#">
	SELECT * 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	AND CancelYN = 1 
</cfquery>
<cfquery name="CancelScheds" datasource="#pds#">
	SELECT * 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	AND CancelSchedYN = 1
</cfquery>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Final Confirmation</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="group5.cfm">
	<input type="Image" name="Return" src="images/return.gif" border="0">
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="BillingID" value="#BillingID#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Final Confirmation</font></th>
	</tr>
</cfoutput>
<form method="post" action="group2.cfm">
	<cfif Deacts.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th colspan="3" bgcolor="#thclr#">Selected to Deactivate</th>
			</tr>
		</cfoutput>
		<cfoutput query="Deacts">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">#Lastname# #FirstName#</td>
				<td><input type="text" name="RunWhen#AccountID#" value="#LSDateFormat(Now(), '#DateMask1#')# #LSTimeFormat(Now(), 'hh:mm tt')#" size="20"></td>
				<td><input type="text" name="Reason#AccountID#" value="Scheduled to be deactivated." size="30" maxlength="150"></td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif Reacts.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th colspan="3" bgcolor="#thclr#">Selected to Reactivate</th>
			</tr>
		</cfoutput>
		<cfoutput query="Reacts">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">#Lastname# #FirstName#</td>
				<td><input type="text" name="RunWhen#AccountID#" value="#LSDateFormat(Now(), '#DateMask1#')# #LSTimeFormat(Now(), 'hh:mm tt')#" size="20"></td>
				<td><input type="text" name="Reason#AccountID#" value="Scheduled to be reactivated." size="30" maxlength="150"></td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif Cancels.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th colspan="3" bgcolor="#thclr#">Selected to Cancel</th>
			</tr>
		</cfoutput>
		<cfoutput query="Cancels">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">#Lastname# #FirstName#</td>
				<td><input type="text" name="RunWhen#AccountID#" value="#LSDateFormat(Now(), '#DateMask1#')# #LSTimeFormat(Now(), 'hh:mm tt')#" size="20"></td>
				<td><input type="text" name="Reason#AccountID#" value="Scheduled to be cancelled." size="30" maxlength="150"></td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif CancelScheds.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th colspan="3" bgcolor="#thclr#">Selected to Cancel a scheduled event</th>
			</tr>
		</cfoutput>
		<cfoutput query="CancelScheds">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">#Lastname# #FirstName#</td>
				<td>#LSDateFormat(WhenRun, '#DateMask1#')# #LSTimeFormat(WhenRun, 'hh:mm tt')#</td>
				<td>#DoAction#</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfoutput>
		<tr>
			<td colspan="3" bgcolor="#tbclr#">Click Continue to commit your selections.<br>
			Click Reset to return to the group list without commiting your selections.</td>
		</tr>
	</cfoutput>
	<tr>
		<th colspan="3">
			<table border="0">
				<tr>
					<th><input type="image" src="images/continue.gif" name="CommitSel" border="0"></th>
					<th><input type="image" src="images/reset.gif" name="CancelSel" border="0"></th>
				</tr>
			</table>
		</th>		
	</tr>
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="BillingID" value="#BillingID#">
		<cfif IsDefined("React")>
			<input type="hidden" name="React" value="#React#">
		</cfif>
		<cfif IsDefined("Deact")>
			<input type="hidden" name="Deact" value="#Deact#">
		</cfif>
		<cfif IsDefined("Cancel")>
			<input type="hidden" name="Cancel" value="#Cancel#">
		</cfif>
		<cfif IsDefined("CancelSched")>
			<input type="hidden" name="CancelSched" value="#CancelSched#">
		</cfif>
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 