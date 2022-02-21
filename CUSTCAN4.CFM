<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Cancels entire account. --->
<!---	4.0.0 04/19/00 --->
<!--- custcan4.cfm --->

<cfif GetOpts.CancelC Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="GetName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfparam name="AmntStatus" default="">
<cfparam name="AmntAmount" default="0">
<cfparam name="DeactWhen" default="">
<cfparam name="SubStatus" default="">
<cfparam name="RefundMethod" default="CK">

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
<title>Final Verification</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="#ReturnTo#">
		<input type="image" src="images/return.gif" name="GoBack" border="0">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="Hidden" name="AmntStatus" value="#AmntStatus#">
		<input type="Hidden" name="AmntAmount" value="#AmntAmount#">
		<input type="hidden" name="RefundMethod" value="#RefundMethod#">
		<input type="hidden" name="SkipTwo" value="#SkipTwo#">
		<input type="hidden" name="SkipThree" value="#SkipThree#">
	</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Final Verification</font></th>
	</tr>
	<tr>
		<cfif DeactWhen Is "Now">
			<td bgcolor="#tbclr#">You have selected to cancel #GetName.FirstName# #GetName.LastName#.</td>
		<cfelseif DeactWhen Is "Later">
			<td bgcolor="#tbclr#">You are scheduling #GetName.FirstName# #GetName.LastName# to be cancelled #LSDateFormat(WhenRun, '#DateMask1#')#.</td>
		</cfif>
	</tr>
	<cfif SubStatus Is "All">
		<tr>
			<td bgcolor="#tbclr#">You have selected to cancel all the subaccounts.</td>
		</tr>
	</cfif>
	<cfif BillMethod Is 2>
		<tr>
			<td bgcolor="#tbclr#">You have selected to prorate the amount on the next billing.</td>
		</tr>
	<cfelseif BillMethod Is 3>
		<tr>
			<td bgcolor="#tbclr#">You have selected to charge the full amount on the next billing.</td>
		</tr>
	</cfif>
	<cfif AmntStatus Is "Refund">
		<cfif RefundMethod Is "CC">
			<cfset RefundType = "credit card">
		<cfelseif RefundMethod Is "CA">
			<cfset RefundType = "cash">
		<cfelseif RefundMethod Is "CK">
			<cfset RefundType = "check">
		</cfif>
		<tr>
			<td bgcolor="#tbclr#">You have selected to refund #LSCurrencyFormat(AmntAmount)# by #RefundType# for the prorated time.</td>
		</tr>
	<cfelseif AmntStatus Is "None">
		<tr>
				<td bgcolor="#tbclr#">You have selected to keep a credit balance of #LSCurrencyFormat(CreditAmount)#.</td>
		</tr>
	</cfif>
	<tr>
		<td bgcolor="#tbclr#">Click Cancel Account to confirm.</td>
	</tr>
	<form method="post" action="custcan5.cfm?RequestTimeout=300">
		<tr>
			<th><input type="image" src="images/custinf12.gif" name="Confirm" border="0"></th>
		</tr>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="Hidden" name="AmntStatus" value="#AmntStatus#">
		<input type="Hidden" name="AmntAmount" value="#AmntAmount#">
		<input type="hidden" name="RefundMethod" value="#RefundMethod#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
