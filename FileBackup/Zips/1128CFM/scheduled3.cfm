<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page lists scheduled events in the auto run table. --->
<!--- 4.0.0 09/29/99
		3.2.0 09/08/98 --->
<!--- scheduled3.cfm --->

<cfquery name="EditIt" datasource="#pds#">
	SELECT R.* 
	FROM AutoRun R 
	WHERE AutoRunID = #AutoRunID# 
</cfquery>
<cfset DoAction = EditIt.DoAction>
<cfif (DoAction Is "Reactivate") OR (DoAction Is "Deactivate") OR (DoAction Is "Cancel")>
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #EditIt.AccountID#
	</cfquery>


<cfelseif DoAction Is "Rollback">
	<cfquery NAME="GetPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc, FixedAmount, RecurringAmount, 
		(FixedAmount+RecurringAmount-RecurDiscount-FixedDiscount) As TOT 
		FROM Plans 
	   WHERE PlanID In 
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		ORDER BY PlanDesc 
	</cfquery>
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #EditIt.AccountID#
	</cfquery>
<cfelseif DoAction Is "EMail">
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #EditIt.AccountID#
	</cfquery>
<cfelseif DoAction Is "DeleteFile">
<cfelseif DoAction Is "IPAD">
<cfelseif DoAction Is "EMailDelay">
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #EditIt.AccountID#
	</cfquery>
<cfelseif DoAction Is "RunCustom">
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #EditIt.AccountID#
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Edit Events</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form action="scheduled2.cfm" method="POST">
	<cfoutput>
		<cfif IsDefined("accountid")>
			<input type="Hidden" name="accountid" value="#accountid#">
		</cfif>
		<input type="Hidden" name="FromMon" value="#FromMon#">
		<input type="Hidden" name="ToMon" value="#ToMon#">
		<input type="Hidden" name="FromYear" value="#FromYear#">
		<input type="Hidden" name="FromDay" value="#FromDay#">
		<input type="Hidden" name="ToYear" value="#ToYear#">
		<input type="Hidden" name="ToDay" value="#ToDay#">
	</cfoutput>
<INPUT type="image" name="return" src="images/return.gif" border="0">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">#DoAction# Scheduled Event</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="right">Scheduled</td>
		<td bgcolor="#tdclr#"><input type="text" name="WhenRun" value="#LSDateFormat(EditIt.WhenRun, '#DateMask1#')# #TimeFormat(EditIt.WhenRun, 'hh:mm tt')#"</td>
	</tr>
</cfoutput>
<cfloop query="EditIt">
	<cfif (DoAction Is "Reactivate") OR (DoAction Is "Deactivate") OR (DoAction Is "Cancel")>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">#DoAction#</td>
				<td>All accounts for #GetWho.FirstName# #GetWho.LastName#.</td>
			</tr>
		</cfoutput>
	<cfelseif DoAction Is "Rollback">
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Rollback to</td>
		</cfoutput>
				<td><select name="PlanID">
					<cfoutput query="GetPlans">
					<option <cfif PlanID Is EditIt.PlanID>selected</cfif> value="#PlanID#">#PlanDesc#</cfoutput>
				</select></td>
			</tr>
			<tr>
				<cfoutput>
					<td bgcolor="#tbclr#" align="right">Reason</td>
					<td bgcolor="#tdclr#"><input type="Text" name="value2" size="33" value="#EditIt.Value2#"></td>
				</cfoutput>
			</tr>
	<cfelseif DoAction Is "EMail">
		<cfoutput>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Subject</td>
				<td bgcolor="#tdclr#"><input type="Text" name="Value1"  value="#EditIt.Value1#" maxlength="50"></td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">From</td>
				<td bgcolor="#tdclr#"><input type="Text" name="Value2" size="33" value="#EditIt.Value2#" maxlength="50"></td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Memo</td>
				<td bgcolor="#tdclr#"><textarea name="Memo1" rows="3" cols="50">#EditIt.Memo1#</textarea></td>
			</tr>
		</cfoutput>
	<cfelseif DoAction Is "DeleteFile">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">File</td>
				<td bgcolor="#tdclr#"><input type="text" name="FileAttach" value="#FileAttach#" maxlength="150" size="35"></td>
			</tr>
		</cfoutput>
	<cfelseif DoAction Is "IPAD">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">Type</td>
				<td bgcolor="#tdclr#"><input type="text" name="Value1" value="#Value1#" maxlength="50"></td>
			</tr>
		</cfoutput>
	<cfelseif DoAction Is "EMailDelay">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">From</td>
				<td bgcolor="#tdclr#"><input type="text" name="EMailFrom" value="#EMailFrom#" maxlength="150"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">To</td>
				<td bgcolor="#tdclr#"><input type="text" name="EMailTo" value="#EMailTo#" maxlength="150"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Copy To</td>
				<td bgcolor="#tdclr#"><input type="text" name="EMailCC" value="#EMailCC#" maxlength="150"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Subject</td>
				<td bgcolor="#tdclr#"><input type="text" name="EMailSubject" value="#EMailSubject#" maxlength="150"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Attachmnets</td>
				<td bgcolor="#tdclr#"><input type="text" name="FileAttach" value="#FileAttach#" maxlength="150"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Server</td>
				<td bgcolor="#tdclr#"><input type="text" name="Value1" value="#Value1#" maxlength="50"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Port</td>
				<td bgcolor="#tdclr#"><input type="text" name="Value2" value="#Value2#" maxlength="50"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Letter</td>
				<td bgcolor="#tdclr#"><textarea name="Memo1" rows="8" cols="60">#Memo1#</textarea></td>
			</tr>
		</cfoutput>
	<cfelseif DoAction Is "RunCustom">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">Custom CFM</td>
				<td bgcolor="#tdclr#"><input type="text" name="Value2" value="#Value2#" maxlength="50"></td>
			</tr>
		</cfoutput>
	</cfif>
	<cfoutput>
		<tr valign="top">
			<th colspan="2"><input type="image" name="UpdSchedule" src="images/update.gif" border="0"></th>
		</tr>
		<input type="Hidden" name="AutoRunID" value="#EditIt.AutoRunID#">
	</cfoutput>
</cfloop>
</table>
</form>
</center>
<cfinclude template ="footer.cfm">
</BODY>
</HTML>
    