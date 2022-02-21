<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that makes the deposit. --->
<!---	4.0.0 09/07/99 --->
<!--- deposithist.cfm --->

<cfset securepage = "deposithist.cfm">
<cfinclude template="security.cfm">

<cfquery name="OneDeposit" datasource="#pds#">
	SELECT DepositNumber, DepositDate 
	FROM DepositHist 
	WHERE DepositNumID = #DepositNumID# 
	GROUP BY DepositNumber, DepositDate 
</cfquery>
<cfquery name="TheCash" datasource="#pds#">
	SELECT Sum(PayAmount) as Total 
	FROM DepositHist 
	WHERE DepositNumID = #DepositNumID# 
	AND PayType = 'Cash' 
</cfquery>
<cfif TheCash.Total Is "">
	<cfset CashTotal = 0>
<cfelse>
	<cfset CashTotal = TheCash.Total>
</cfif>
<cfquery name="TheChecks" datasource="#pds#">
	SELECT FirstName, LastName, AccountID, TransID, PayType, 
	DepositDate, ChkNumber, PayAmount 
	FROM DepositHist 
	WHERE PayType = 'Check' 
	AND DepositNumID = #DepositNumID# 
	ORDER BY LastName, FirstName 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Deposit</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="deposithist.cfm">
<input type="image" name="Return" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="3"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Deposit information</font></th>
	</tr>
	<tr>
		<td bgcolor="#thclr#" colspan="3">#LSDateFormat(OneDeposit.DepositDate, '#DateMask1#')#</td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="3">#OneDeposit.DepositNumber#</td>
	</tr>
</cfoutput>
<cfoutput query="TheCash">
	<tr bgcolor="#tbclr#">
		<td colspan="2">Cash</td>
		<td align="right">#LSCurrencyFormat(Total)#</td>
	</tr>
</cfoutput>
<cfset CheckTotal = 0>
<cfoutput query="TheChecks">
	<tr bgcolor="#tbclr#">
		<td>#LastName#, #FirstName#</td>
		<td>#ChkNumber#&nbsp;</td>
		<td align="right">#LSCurrencyFormat(PayAmount)#</td>
		<cfset CheckTotal = CheckTotal + PayAmount>
	</tr>
</cfoutput>
<cfset GTotal = CashTotal + CheckTotal>
<cfoutput>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Cash Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(CashTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Check Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(CheckTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Deposit Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(GTotal)#</td>
</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

