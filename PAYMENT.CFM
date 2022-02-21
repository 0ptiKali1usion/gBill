<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page starts the payment wizard. --->
<!--- 4.0.1 01/25/01 Added feature if staff does not have permission to enter payments this page goes instead to the Customer Info page.
		4.0.0 --->
<!--- payment.cfm --->

<cfif GetOpts.MenuLev Is 1>
	<cfset securepage="lookup1.cfm">
<cfelse>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="custinf1.cfm">
	<cfabort>
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("ReSet.x")>
	<cfquery name="ReSynch" datasource="#pds#">
		UPDATE TransActions 
		SET CreditLeft = Credit, 
		DebitLeft = Debit 
		WHERE AccountID = #AccountID#
	</cfquery>
</cfif>
<cfquery name="GroupCheck" datasource="#pds#">
	SELECT BillTo, MultiID, PrimaryID 
	FROM Multi 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="TotalBal" datasource="#pds#">
	SELECT Sum(Debit-Credit) as TBal
	FROM TransActions 
	WHERE AccountID = 
	<cfif GroupCheck.RecordCount GT 0>
		#GroupCheck.PrimaryID#
	<cfelse>
		#AccountID#
	</cfif>
</cfquery>
<cfquery name="TotalChk" datasource="#pds#">
	SELECT Sum(DebitLeft) as TBal
	FROM TransActions 
	WHERE AccountID = 
	<cfif GroupCheck.RecordCount GT 0>
		#GroupCheck.PrimaryID#
	<cfelse>
		#AccountID#
	</cfif>
</cfquery>
<cfif NumberFormat(TotalChk.TBal, '9999999999.99') NEQ NumberFormat(TotalBal.TBal, '9999999999.99')>
	<cfquery name="GetTopID" datasource="#pds#">
		SELECT Max(TransID) as TopID 
		FROM TransActions 
		WHERE AccountID = 
		<cfif GroupCheck.RecordCount GT 0>
			#GroupCheck.PrimaryID#
		<cfelse>
			#AccountID#
		</cfif>
		AND DebitLeft > 0 
	</cfquery>
	<cfset TopTransID = GetTopID.TopID>
	<cfif TopTransID Is Not "">
		<cfset TheAccountID = AccountID>
		<cfset TransType = "Debit">
		<cfinclude template="cfpayment.cfm">	
	</cfif>
</cfif>
<cfquery name="PayOn" datasource="#pds#">
	SELECT * 
	FROM TransActions 
	WHERE AccountID = 
	<cfif GroupCheck.RecordCount GT 0>
		#GroupCheck.PrimaryID#
	<cfelse>
		#AccountID#
	</cfif>
	AND DebitLeft > 0 
	ORDER BY DateTime1 
</cfquery>
<cfparam name="AmountIDs" default="#ValueList(PayOn.TransID)#">

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
<title>Make Payment</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="Image" src="images/return.gif" border="0">
	<cfoutput><input type="Hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="6" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment</font></th>
	</tr>
	<cfif PayOn.Recordcount GT 0>
		<tr bgcolor="#thclr#">
			<th colspan="2">Pay</th>
			<th>Debit Date</th>
			<th>Description</th>
			<th>Amount</th>
			<th>Still Owe</th>
		</tr>
	</cfif>
<form method="post" action="payment2.cfm">
	<cfif IsDefined("MessageStr")>
		<tr>
			<th bgcolor="#tbclr#" colspan="6">#MessageStr#</th>
		</tr>
	</cfif>
	<cfif PayOn.Recordcount GT 0>
		<tr bgcolor="#tbclr#">
			<th bgcolor="#tdclr#"><input type="radio" <cfif IsDefined("OtherAmount")><cfif OtherAmount Is "SI">checked</cfif><cfelse>checked</cfif> name="OtherAmount" value="SI"></th>
			<th colspan="5">Select items to pay</th>
		</tr>
	</cfif>
</cfoutput>
	<cfset TB = 0>
	<cfoutput query="PayOn">
		<tr bgcolor="#tbclr#">
			<td bgcolor="#tdclr#">&nbsp;</td>
			<th bgcolor="#tdclr#"><input type="Checkbox" <cfif ListFind(AmountIDs,TransID)>checked</cfif> name="AmountIDs" value="#TransID#"></th>
			<td>#LSDateFormat(DateTime1, '#DateMask1#')#</td>
			<td>#MemoField#</td>
			<td align="right">#LSCurrencyFormat(Debit)#</td>
			<td align="right">#LSCurrencyFormat(DebitLeft)#</td>
			<cfset TB=TB+DebitLeft>
		</tr>
	</cfoutput>
	<cfoutput>
		<cfif PayOn.Recordcount GT 0>
			<tr bgcolor="#tdclr#">
				<th align="right" colspan="5">Total</th>
				<td align="right">#LSCurrencyFormat(TB)#</td>
			</tr>
			<cfif NumberFormat(TB, '9999999999.99') NEQ NumberFormat(TotalBal.TBal, '9999999999.99')>
			</form>
				<form method="post" action="payment.cfm">
					<tr>
						<th colspan="6" bgcolor="#tbclr#">CAUTION! This accounts amount owed is out of synch with the debits still owed!<br>
						Click RESET to resynch the amounts.</th>
					</tr>
					<tr>
						<th colspan="6"><input type="Image" src="images/reset.gif" name="Reset" border="0"></th>
						<input type="Hidden" name="AccountID" value="#AccountID#">
					</tr>
				</form>
			</cfif>
			<tr>
				<th bgcolor="#thclr#" colspan="6">OR</th>
			</tr>
		</cfif>
		<tr>
			<th bgcolor="#tdclr#"><input type="radio" <cfif PayOn.Recordcount Is 0>checked<cfelseif IsDefined("OtherAmount")><cfif OtherAmount Is "OA">checked</cfif></cfif> name="OtherAmount" value="OA"></th>
			<th colspan="4" bgcolor="#tbclr#" align="right">Other Amount</th>
			<td bgcolor="#tdclr#"><input type="Text" <cfif IsDefined("PayAmount")>value="#PayAmount#"</cfif> name="PayAmount" size="6"></td>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="6">Payment Method</th>
		</tr>
		<tr>
			<td colspan="6" bgcolor="#tdclr#"><input type="Radio" <cfif IsDefined("PayBy")><cfif PayBy Is "CA">checked</cfif></cfif> name="PayBy" value="CA">Cash  <input type="Radio" <cfif IsDefined("PayBy")><cfif PayBy Is "CK">checked</cfif></cfif> name="PayBy" value="CK">Check  <input type="Radio" <cfif IsDefined("PayBy")><cfif PayBy Is "CC">checked</cfif></cfif> name="PayBy" value="CC">Credit Card</td>
			<input type="Hidden" name="PayBy_Required" value="Please select the payment method.">
			<input type="Hidden" name="AccountID" value="#AccountID#">
			<input type="Hidden" name="AmountIDs" value="0">
		</tr>
		<tr>
			<th colspan="6"><input type="Image" src="images/continue.gif" name="PayStep" border="0"></th>
		</tr>
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

