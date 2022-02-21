<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a printable page for deposits. --->
<!---	4.0.0 09/07/99 --->
<!--- depositslip.cfm --->

<cfset securepage = "depositnew.cfm">
<cfinclude template="security.cfm">

<cfquery name="TheChecks" datasource="#pds#">
	SELECT A.FirstName, A.LastName, A.AccountID, T.TransID, 
	T.PayType, T.DateTime1, T.ChkNumber, T.Credit 
	FROM Transactions T, Accounts A 
	WHERE T.AccountID = A.AccountID 
	AND T.PayType = 'Check' 
	AND T.TransID In (#Deposit#) 
</cfquery>
<cfquery name="TheCash" datasource="#pds#">
	SELECT Sum(T.Credit) as Total 
	FROM Transactions T 
	WHERE T.PayType = 'Cash' 
	AND T.TransID In (#Deposit#) 
</cfquery>
<cfif TheCash.Total Is "">
	<cfset CashTotal = 0>
<cfelse>
	<cfset CashTotal = TheCash.Total>
</cfif>
<cfsetting enablecfoutputonly="no" showdebugoutput="No">
<html>
<head>
<title>Deposit Slip</title>
<cfinclude template="coolsheet.cfm">
</head>
<body bgcolor="white">
<cfoutput>
<table border="1">
	<tr>
		<th colspan="3">#LSDateFormat(DepositDate,'#DateMask1#')#</th>
	</tr>
	<tr>
		<td colspan="3">#DepositNumber#</td>
	</tr>
</cfoutput>
<cfoutput query="TheCash">
	<tr>
		<td colspan="2">Cash</td>
		<td align="right">#LSCurrencyFormat(Total)#</td>
	</tr>
</cfoutput>
<cfset CheckTotal = 0>
<cfoutput query="TheChecks">
	<tr>
		<td>#LastName#, #FirstName#</td>
		<td>#ChkNumber#</td>
		<td align="right">#LSCurrencyFormat(Credit)#</td>
		<cfset CheckTotal = CheckTotal + Credit>
	</tr>
</cfoutput>
<cfset GTotal = CashTotal + CheckTotal>
<cfoutput>
<tr>
	<td align="right" colspan="2">Cash Total</td>
	<td align="right">#LSCurrencyFormat(CashTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2">Check Total</td>
	<td align="right">#LSCurrencyFormat(CheckTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2">Deposit Total</td>
	<td align="right">#LSCurrencyFormat(GTotal)#</td>
</tr>
</cfoutput>
</table>
</body>
</html>
  