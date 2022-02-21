<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 2 that makes the deposit. --->
<!---	4.0.0 09/07/99 --->
<!--- depositnew2.cfm --->

<cfset securepage = "depositnew.cfm">
<cfinclude template="security.cfm">
<cfquery name="GetNextID" datasource="#pds#">
	SELECT Max(DepositNumID) as MaxID 
	FROM DepositHist 
</cfquery>
<cfif GetNextID.MaxID Is "">
	<cfset NextID = 1>
<cfelse>
	<cfset NextID = GetNextID.MaxID + 1>
</cfif>
<cfquery name="TheChecks" datasource="#pds#">
	SELECT A.FirstName, A.LastName, A.AccountID, T.TransID, 
	T.PayType, T.DateTime1, T.ChkNumber, T.Credit 
	FROM Transactions T, Accounts A 
	WHERE T.AccountID = A.AccountID 
	AND T.PayType = 'Check' 
	AND T.TransID In (#Deposit#) 
	ORDER BY A.LastName, A.FirstName 
</cfquery>
<cfquery name="TheCash" datasource="#pds#">
	SELECT Sum(T.Credit) as Total 
	FROM Transactions T 
	WHERE T.PayType = 'Cash' 
	AND T.TransID In (#Deposit#) 
</cfquery>
<cfif TheCash.Total Is "">
	<cfset TheCashTotal =0>
<cfelse>
	<cfset TheCashTotal = TheCash.Total>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Finalize Deposit</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="depositnew.cfm">
	<cfoutput>
		<input type="hidden" name="Deposit" value="#Deposit#">
		<input type="hidden" name="DepositDate" value="#DepositDate#">
		<input type="hidden" name="DepositNumber" value="#DepositNumber#">
		<input type="image" src="images/changecriteria.gif" name="ChangeDep" border="0">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#thclr#">#LSDateFormat(DepositDate,'#DateMask1#')#</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="3">#DepositNumber#</td>
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
		<td align="right">#LSCurrencyFormat(Credit)#</td>
		<cfset CheckTotal = CheckTotal + Credit>
	</tr>
</cfoutput>
<cfset GTotal = TheCashTotal + CheckTotal>
<cfoutput>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Cash Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(TheCashTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Check Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(CheckTotal)#</td>
</tr>
<tr>
	<td align="right" colspan="2" bgcolor="#tbclr#">Deposit Total</td>
	<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(GTotal)#</td>
</tr>
<tr>
	<form method="post" action="depositnew3.cfm">
		<input type="hidden" name="NextID" value="#NextID#">
		<input type="hidden" name="Deposit" value="#Deposit#">
		<input type="hidden" name="DepositDate" value="#DepositDate#">
		<input type="hidden" name="DepositNumber" value="#DepositNumber#">
		<th colspan="3"><input type="image" src="images/makedeposit.gif" name="MakeDeposit" border="0"></th>
	</form>
</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
    