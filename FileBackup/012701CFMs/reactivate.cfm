<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Reactivates entire account. --->
<!---	4.0.0 04/19/00 --->
<!-- reactivate.cfm -->

<cfif GetOpts.ReactAcnt Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfparam name="MemoReason" default="Account was scheduled to be reactivated.">
<cfif Isdefined("SubStatus")>
	<cfset TheStatus = SubStatus>
<cfelse>
	<cfset TheStatus = "">
</cfif>
<cfif IsDefined("WhenRun")>
	<cfset NextDay = WhenRun>
<cfelse>
	<cfset NextDay = CreateDateTime(Year(Now()),Month(Now()),1,0,0,0)>
	<cfset NextDay = DateAdd("m",1,NextDay)>
</cfif>
<cfif IsDefined("DeactWhen")>
	<cfset TheWhen = DeactWhen>
<cfelse>
	<cfset TheWhen = "">
</cfif>

<cfquery name="CheckGroup" datasource="#pds#">
	SELECT BillTo 
	FROM Multi 
	WHERE AccountID = #AccountID# 
</cfquery>
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
<title>Reactivate</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Reactivate Settings</font></th>
	</tr>
	<tr>
		<th colspan="2" bgcolor="#thclr#">All integration for this account will be reactivated.</th>
	</tr>
	<form method="post" action="reactivate2.cfm">
		<tr bgcolor="#tdclr#" valign="top">
			<td align="right" bgcolor="#tbclr#" rowspan="2">Reactivate</td>
			<td><input type="radio" <cfif TheWhen Is "Now">checked</cfif> name="DeactWhen" value="Now"> Now</td>
		</tr>
		<tr bgcolor="#tdclr#">
			<td><input type="radio" <cfif TheWhen Is "later">checked</cfif> name="DeactWhen" value="Later"> <input type="text" name="WhenRun" value="#LSDateFormat(NextDay, '#DateMask1#')# 00:00 AM"></td>
		</tr>
		<tr bgcolor="#tdclr#" valign="top">
			<td align="right" bgcolor="#tbclr#">Reason</td>
			<td><input type="text" name="MemoReason" value="#MemoReason#" size="40" maxlength="150"></td>
		</tr>
</cfoutput>
		<cfif (CheckGroup.Recordcount GT 0) AND (CheckGroup.BillTo Is 1)>
			<cfoutput>
				<tr>
					<th colspan="2" bgcolor="#thclr#">This account is the primary for a group account.</th>
				</tr>
				<tr valign="top" bgcolor="#tdclr#">
					<td align="right" rowspan="2" bgcolor="#tbclr#">Subaccounts</td>
					<td><input type="radio" <cfif TheStatus Is "Ignore">checked</cfif> name="SubStatus" value="Ignore">Ignore All Subaccounts</td>
				</tr>
				<tr bgcolor="#tdclr#">
					<td><input type="radio" <cfif TheStatus Is "All">checked</cfif> name="SubStatus" value="All">Reactivate All Subaccounts</td>
				</tr>
			</cfoutput>
			<input type="hidden" name="SubStatus_Required" value="Please select how subaccounts are to be handled.">
		</cfif>
		<tr>
			<th colspan="2"><input type="image" src="images/continue.gif" name="Step1" border="0"></th>
		</tr>
		<input type="hidden" name="DeactWhen_Required" value="Please select when to reactivate this account.">
		<input type="hidden" name="WhenRun_Date" value="Please enter a valid date for reactivation.">
		<input type="hidden" name="ReturnTo" value="reactivate.cfm">
		<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 