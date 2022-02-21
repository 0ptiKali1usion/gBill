<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 03/14/00 --->
<!--- maintamounts.cfm --->
<!--- Synchronize the amount fields in the table Transaction --->

<cfif UserID Is Not "">
	<cfset LocAccountID = UserID>
</cfif>
<cfif UpdateAmounts Is "0">
	<cfset UpdateTheAmounts = "Yes">
</cfif>

<cfquery name="CheckFor" datasource="#pds#" maxrows="50">
	SELECT AccountID, SUM(Debit-Credit) as Bal1, SUM(DebitLeft-CreditLeft) as Bal2
	FROM TransActions 
	<cfif IsDefined("LocAccountID")>
		WHERE AccountID = #LocAccountID# 
	</cfif>
	GROUP BY AccountID 
	<cfif Not IsDefined("RunAnyWay")>
		HAVING SUM(Debit-Credit) - SUM(DebitLeft-CreditLeft) < -0.01 
		OR SUM(Debit-Credit) - SUM(DebitLeft-CreditLeft) > 0.01 
	</cfif>
	ORDER BY AccountID 
</cfquery>
<cfif IsDefined("UpdateTheAmounts")>
	<cfloop query="CheckFor">
		<cfset TheAccountID = AccountID>
		<cfquery name="ResetUser" datasource="#pds#">
			UPDATE TransActions SET 
			DebitLeft = Debit, 
			CreditLeft = Credit 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfinclude template="cfpayment.cfm">
	</cfloop>
	<cfquery name="CheckFor2" datasource="#pds#" maxrows="12">
		SELECT AccountID, SUM(Debit-Credit) as Bal1, SUM(DebitLeft-CreditLeft) as Bal2
		FROM TransActions 
		WHERE AccountID IN 
		<cfif CheckFor.RecordCount GT 0>
			(#ValueList(CheckFor.AccountID)#)
		<cfelse>
			(0)
		</cfif>
		GROUP BY AccountID 
		ORDER BY AccountID
	</cfquery>
</cfif>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'Locale'
</cfquery>
<cfset Locale = GetLocale.Value1>

<cfsetting enablecfoutputonly="No" showdebugoutput="No">
<html>
<head>
<title>Transaction Report</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="reportamounts.cfm">
	<input type="Image" name="Return" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="3"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Report</font></th>
	</tr>
	<cfif IsDefined("CheckFor2")>
		<tr>
			<th bgcolor="#thclr#" colspan="3">Before</th>
		</tr>
	</cfif>
	<cfif CheckFor.RecordCount GT 0>
		<tr bgcolor="#thclr#">
			<th>AccountID</th>
			<th>Amount Total</th>
			<th>Left Total</th>
		</tr>
		<cfloop query="CheckFor">
			<tr bgcolor="#tbclr#">
				<td>#AccountID#</td>
				<td>#LSCurrencyFormat(Bal1)#</td>
				<td>#LSCurrencyFormat(Bal2)#</td>
			</tr>
		</cfloop>
	<cfelse>
		<tr>
			<td bgcolor="#tbclr#" colspan="3">No users need synched at this time.</td>
		</tr>
	</cfif>
	<cfif IsDefined("CheckFor2")>
		<tr>
			<th bgcolor="#thclr#" colspan="3">After</th>
		</tr>
		<cfloop query="CheckFor2">
			<tr bgcolor="#tbclr#">
				<td>#AccountID#</td>
				<td>#LSCurrencyFormat(Bal1)#</td>
				<td>#LSCurrencyFormat(Bal2)#</td>
			</tr>
		</cfloop>
	</cfif>
	<tr>
		<td bgcolor="#tbclr#" colspan="3">This report will only show 50 max at a time.</td>
	</tr>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  