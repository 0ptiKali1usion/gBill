<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 10/13/00 --->
<!--- paymentview.cfm --->

<cfquery name="AllUnresolved" datasource="#pds#">
	SELECT T.CCCardHolder, T.CCProcessDate, T.PhoneNum, T.CreditAmount, A.LastName, A.FirstName, A.DayPhone 
	FROM AccntTransTemp T, AccntTemp A 
	WHERE T.TempAccountID *= A.AccountID 
	ORDER BY A.LastName, A.FirstName 
</cfquery>

<cfset HowWide = 5>

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
<title>Unresolved CC Payments</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Unresolved CC Payments</font></th>
	</tr>
</cfoutput>
	<cfif AllUnresolved.RecordCount Is 0>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#" colspan="#HowWide#">No payments currently unresolved.</td>
			</cfoutput>
		</tr>
	<cfelse>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Amount</th>
				<th>Processed</th>
				<th>Card Holder</th>
				<th>Phone</th>
			</tr>
		</cfoutput>
		<cfoutput query="AllUnresolved">
			<tr bgcolor="#tbclr#">
				<td>#LastName#<cfif LastName Is Not "" AND FirstName Is Not "">,<cfelse>&nbsp;</cfif> #FirstName#</td>
				<td>#LSCurrencyFormat(CreditAmount)#</td>
				<td>#LSDateFormat(CCProcessDate, '#DateMask1#')#</td>
				<td>#CCCardHolder#</td>
				<cfif DayPhone Is "">
					<td>#PhoneNum#</td>
				<cfelse>
					<td>#DayPhone#</td>
				</cfif>
			</tr>
		</cfoutput>
	</cfif>

</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 