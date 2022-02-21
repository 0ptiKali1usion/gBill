<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is where support history is entered. --->
<!--- 4.0.1 01/26/01 Fixed an error where the entry time was always midnight.
		4.0.0
		3.2.0 09/08/98 --->
<!--- support.cfm --->

<cfif GetOpts.SuppHist Is 1>
	<cfset securepage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("EditHist.x")>
	<cfquery name="updone" datasource="#pds#">
		UPDATE Support SET 
		Problem = '#Problem#', 
		Solution = '#Solution#', 
		ActiveYN = #ActiveYN# 
		WHERE SupportID = #SupportID# 
	</cfquery>
</cfif>
<cfif IsDefined("NewHist.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT SupportID 
		FROM Support 
		WHERE Tech = '#Tech#' 
		AND Problem Like '#Problem#' 
		AND Solution Like '#Solution#' 
		AND AccountID = #AccountID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="insone" datasource="#pds#">
  			INSERT INTO Support 
			(SupportDate, Tech, Problem, Solution, AccountID, ActiveYN) 
  			VALUES 
			(#CreateODBCDateTime(Now())#, '#Tech#', 
			<cfif Trim(Problem) Is "">Null<cfelse>'#Problem#'</cfif>, 
			<cfif Trim(Solution) Is "">Null<cfelse>'#Solution#'</cfif>, #AccountID#, 1)
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdInfo.x")>
	<cfquery name="CustomFields" datasource="#pds#">
		SELECT BOBFieldName, DataType 
	   FROM WizardSetup 
		WHERE PageNumber = 2 
		AND IsDeletable = 1 
		AND ActiveYN = 1 
	</cfquery>
	<cfquery name="UpdCustom" datasource="#pds#">
		UPDATE Accounts SET 
		<cfloop query="CustomFields">
			<cfset UpdValue = Evaluate("#BOBFieldName#")>
			#BOBFieldName# = 
			<cfif DataType Is "text">'#Trim(UpdValue)#',
			<cfelseif DataType Is "number">#UpdValue#,
			<cfelseif DataType Is "date">
				<cfif IsDate(UpdValue)>'#CreateODBCDateTime(UpdValue)#'<cfelse>Null</cfif>,
			</cfif>
		</cfloop>
		PCType = '#PCType#', 
		Modem = '#Modem#', 
		ModemSpeed = '#ModemSpeed#', 
		OSVersion = '#OSVersion#'
		WHERE AccountID = #AccountID#
	</cfquery>
</cfif>
<cfquery name="User" datasource="#pds#">
	SELECT * 
	FROM Accounts 
	Where AccountID = #AccountID#
</cfquery>
<cfquery name="GetHist" datasource="#pds#">
	SELECT * 
	FROM Support 
	WHERE AccountID = #Accountid# 
	ORDER BY ActiveYN desc, Supportdate desc 
</cfquery>
<cfquery name="CustomSupport" datasource="#pds#">
	SELECT ScreenPrompt, BOBFieldName 
   FROM WizardSetup 
	WHERE PageNumber = 2 
	AND IsDeletable = 1 
	AND ActiveYN = 1 
</cfquery>
<cfquery name="CustomAnswers" datasource="#pds#">
	SELECT <cfloop query="CustomSupport">#BOBFieldName#,</cfloop> AccountID 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfparam name="Tab" default="1">
<cfif Tab Is 1>
	<cfset HowWide = 6>
<cfelseif Tab Is 2>
	<cfset HowWide = 2>
	<cfquery name="allmodemspeeds" datasource="#pds#">
		SELECT * 
		FROM ModemSpeeds 
		WHERE AccountYN = 1 
		ORDER BY SortOrder 
	</cfquery>
	<cfquery name="allosoptions" datasource="#pds#">
		SELECT * 
		FROM OSVersion 
		WHERE AccountYN = 1 
		ORDER BY SortOrder 
	</cfquery>
<cfelseif Tab Is 3>
	<cfset HowWide = 2>
	<cfquery name="GetHist" datasource="#pds#">
		SELECT * 
		FROM Support 
		<cfif IsDefined("SupportID")>
			WHERE SupportID = #SupportID# 
		<cfelse>
			WHERE SupportID = 0 
		</cfif>
		ORDER BY Supportdate desc 
	</cfquery>
</cfif>
<cfset CellNumber = 0>

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
<title>Support History</TITLE>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!--
function confirmcd()
   {
    return confirm ('Click OK to confirm entering the support note.')
   }
// -->   
</script>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<cfif Tab Is 1>
	<form method="post" action="custinf1.cfm">
		<input type="image" src="images/returncust.gif" name="return" border="0">
		<input type="hidden" name="AccountID" value="#AccountID#">
	</form>
<cfelseif (Tab Is 2) OR (Tab Is 3)>
	<form method="post" action="support.cfm">
		<input type="image" src="images/return.gif" name="return" border="0">
		<input type="hidden" name="AccountID" value="#AccountID#">
	</form>
</cfif>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Support history for #User.FirstName# #User.LastName#</font></th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
	<cfoutput>
		<FORM METHOD="POST" Name="info" ACTION="support.cfm">
			<tr bgcolor="#tbclr#" valign="top">
				<td>Computer</td>
				<td>#User.PCType#</td>
				<td>Modem</td>
				<td>#User.Modem# #User.ModemSpeed#</td>
				<td>Operating System</td>
				<td>#User.OSVersion#</td>
			</tr>
		</cfoutput>
			<cfoutput query="CustomSupport">
				<cfset CellNumber = CellNumber + 1>
				<cfif CellNumber Is 1><tr bgcolor="#tbclr#" valign="top"></cfif>
					<cfset ScreenDisp = Evaluate("CustomAnswers.#BOBFieldName#")>
					<td>#ScreenPrompt#<cfif ScreenPrompt Is "">&nbsp;</cfif></td>
					<td>#ScreenDisp#<cfif ScreenDisp Is "">&nbsp;</cfif></td>
				<cfif CellNumber Is 3></tr><cfset CellNumber = 0></cfif>
			</cfoutput>
			<cfif CellNumber GT 0 AND CellNumber LT 3>
				<cfset FinishRow = 3 - CellNumber>
				<cfloop index="B4" from="1" to="#FinishRow#">
					<td>&nbsp;</td><td>&nbsp;</td>
				</cfloop>
			</cfif>
			<tr>
				<th colspan="6"><INPUT TYPE="image" Name="EditInfo" src="images/edit.gif" border="0"></th>
			</tr>
		<cfoutput>
			<Input type="hidden" name="Accountid" value="#AccountID#">
			<Input type="hidden" name="Tab" value="2">
		</form>
		<form name="info2" method="post" action="suppsrch.cfm">
			<tr>
				<td colspan=2 align=right><input type="image" src="images/search.gif" border="0"></td>
				<td bgcolor="#tdclr#" colspan="4"><INPUT type="text" name="search1" size="15"> <INPUT type="text" name="search2" size="15"> <INPUT type="text" name="search3" size="15"></td>
			</tr>
			<input type="hidden" name="AccountID" value="#AccountID#">
		</form>
		<form method="post" action="support.cfm">
			<tr>
				<td align="right" colspan="6"><input type="image" name="AddNote" src="images/addnew.gif" border="0"></td>
			</tr>
			<Input type="hidden" name="Accountid" value="#AccountID#">
			<input type="hidden" name="Tab" value="3">
		</form>
	</cfoutput>
	<cfif GetHist.Recordcount Is 0>
		<cfoutput>
			<tr>
				<th bgcolor="#tdclr#" colspan=6>No support history available</th>
			</tr>
		</cfoutput>
	<cfelse>
		<cfoutput query="GetHist">
			<form name="info3" method="post" action="support.cfm">
				<tr bgcolor="#tbclr#">
					<cfif ActiveYN Is 1><td valign="top" align="center" bgcolor="#tdclr#"><cfelse><td valign="top" align="center"></cfif><input type="radio" name="SupportID" value="#SupportID#" onclick="submit()"></td>
					<td>#tech#</td>
					<td align="right">Problem</td>
					<td colspan="3">#Problem#</td>
				</tr>
				<tr bgcolor="#tbclr#">
					<cfif ActiveYN Is 1><td bgcolor="#tdclr#">Active<cfelse><td>&nbsp;</cfif></td>
					<td>#LSDateFormat(SupportDate, '#datemask1#')# #LSTimeFormat(SupportDate, 'hh:mm tt')#</td>
					<td align="right">Solution</td>
					<td colspan="3">#Solution#</td>
				</tr>
				<input type="hidden" name="AccountID" value="#AccountID#">
				<input type="hidden" name="Tab" value="3">
			</form>
		</cfoutput>
	</cfif>
<cfelseif Tab Is 2>
	<cfoutput>
	<FORM METHOD="POST" Name="info" ACTION="support.cfm">
		<tr>
			<td align="right" bgcolor="#tbclr#">Computer</td>
			<td bgcolor="#tdclr#"><input type="text" name="pctype" value="#User.PCType#" size="10"></td>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Modem</td>
			<td bgcolor="#tdclr#"><input type="text" name="modem" value="#User.Modem#" size="10"> <select name="ModemSpeed">
	</cfoutput>
				<cfoutput query="AllModemSpeeds">
					<option <cfif User.ModemSpeed Is ModemSpeed>selected</cfif> value="#ModemSpeed#">#ModemSpeed#
				</cfoutput>
			</select></td>
		</tr>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Operating System</td>
		</cfoutput>
			<td><select name="osversion">
				<cfoutput query="AllOSOptions">
					<option <cfif User.OSVersion Is OSV>selected</cfif> value="#osv#">#osv#
				</cfoutput>
			</select></td>
		</tr>
		<cfoutput query="CustomSupport">
			<tr bgcolor="#tbclr#">
				<cfset ScreenDisp = Evaluate("CustomAnswers.#BOBFieldName#")>
				<td align="right">#ScreenPrompt#<cfif ScreenPrompt Is "">&nbsp;</cfif></td>
				<td bgcolor="#tdclr#"><input type="text" name="#BOBFieldName#" value="#ScreenDisp#" size="10"></td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="2"><input type="image" name="UpdInfo" src="images/update.gif" border="0"></th>
		</tr>
		<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
	</form>
<cfelseif Tab Is 3>
	<cfoutput>
	<cfif Not IsDefined("SupportID")>
	<form name="enternew" method="post" action="support.cfm" onSubmit="return confirmcd()">
	<cfelse>
	<form name="enternew" method="post" action="support.cfm">
	</cfif>
		<tr bgcolor="#tbclr#">
			<td align="right">Tech</td>
			<cfif Not IsDefined("SupportID")>
				<td>#StaffMemberName.FirstName# #StaffMemberName.LastName#</td>
			<cfelse>
				<td>#GetHist.Tech#</td>
			</cfif>
		</tr>
		<cfif IsDefined("SupportID")>
			<tr>
				<td align="right" bgcolor="#tbclr#">Active</td>
				<td bgcolor="#tdclr#"><input type="radio" <cfif GetHist.ActiveYN Is 1>checked</cfif> name="ActiveYN" value="1"> Yes <input type="radio" <cfif GetHist.ActiveYN Is 0>checked</cfif> name="ActiveYN" value="0"> No</td>
			</tr>
		</cfif>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Type</td>
			<td bgcolor="#tdclr#"><input type="radio" checked name="Type" value="1">Tech
			<input type="radio" name="Type" value="2">Billing
			<input type="radio" name="Type" value="3">General
			<input type="radio" name="Type" value="4">DSL</td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Priority</td>
			<td bgcolor="#tdclr#"><input type="radio" checked name="Priority" value="1">Standard
			<input type="radio" name="Priority" value="2">Low
			<input type="radio" name="Priority" value="3">High</td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Status</td>
			<td bgcolor="#tdclr#"><input type="radio" checked name="Status" value="1">Completed
			<input type="radio" name="Status" value="2">Pending
			<input type="radio" name="Status" value="3">Escalated</td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Pending For</td>
			<td bgcolor="#tdclr#"><input type="radio" checked name="PendingFor" value="1">Tech
			<input type="radio" name="PendingFor" value="2">Lead Tech
			<input type="radio" name="PendingFor" value="3">Billing
			<input type="radio" name="PendingFor" value="4">Ops
			<input type="radio" name="PendingFor" value="5">Sales</td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Problem</td>
			<td bgcolor="#tdclr#"><textarea name="problem" rows="4" cols="50" wrap="virtual">#GetHist.Problem#</textarea></td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Solution</td>
			<td bgcolor="#tdclr#"><textarea name="solution" rows="4" cols="50" wrap="virtual">#GetHist.Solution#</textarea></td>
		</tr>
		<tr valign="top">
			<cfif Not IsDefined("SupportID")>
				<th colspan="2"><INPUT type="image" name="NewHist" src="images/enter.gif" border="0"></td>
			<cfelse>
				<th colspan="2"><INPUT type="image" name="EditHist" src="images/update.gif" border="0"></td>
			</cfif>
		</tr>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="hidden" name="Tech" value="#StaffMemberName.FirstName# #StaffMemberName.LastName#">
		<input type="hidden" name="problem_required" value="Please enter the problem.">
		<cfif IsDefined("SupportID")>
			<input type="hidden" name="SupportID" value="#SupportID#">
		</cfif>
	</form>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 