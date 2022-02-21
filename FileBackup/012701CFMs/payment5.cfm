<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Customer Payment Receipt Page --->
<!--- payment5.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="GetTrans" datasource="#pds#">
	SELECT * 
	FROM TransActions 
	WHERE TransID = #TransID# 
</cfquery>
<cfif PayBy Is "Ca">
	<cfset PaymentType = "Cash">
<cfelseif PayBy Is "Ck">
	<cfset PaymentType = "Check">
<cfelseif PayBy Is "CD">
	<cfset PaymentType = "Credit Debit">
<cfelseif PayBy Is "CC">
	<cfset PaymentType = "Credit Card">
</cfif>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Payment Receipt</title>
<body bgcolor="White">
<center>
<cfoutput>
<table border="0">
	<tr>
		<th><font size="5">Payment Receipt</font></th>
	</tr>
	<tr>
		<td>Payment: #LSCurrencyFormat(GetTrans.Credit)#<br>
		Paid By: #PaymentType#<br>
		Date: #LSDateFormat(GetTrans.DateTime1, '#DateMask1#')#</td>
	</tr>
	<tr>
		<td>Insert cute saying or information text here.  :)</td>
	</tr>
</cfoutput>
</table>
</center>
</body>
</html>
 