<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page collects the payment method info. --->
<!--- 4.0.1 02/21/01 Fixed the error when the radio for which card was not selected.
		4.0.0 --->
<!--- payment2.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfparam name="ReturnPage" default="payment.cfm">
<cfif (OtherAmount Is "SI") AND (AmountIDs Is "0")>
	<cfsetting enablecfoutputonly="no">
	<cfset MessageStr = "Please select at least one item to pay before clicking continue.">
	<cfinclude template="payment.cfm">
	<cfabort>
</cfif>
<cfif (OtherAmount Is "OA") AND (PayAmount Is "")>
	<cfsetting enablecfoutputonly="no">
	<cfset MessageStr = "Please enter the amount to pay before clicking continue.">
	<cfinclude template="payment.cfm">
	<cfabort>
</cfif>

<cfif PayBy Is "CA">
	<cfset ReturnPage = "custinf1.cfm">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="payment4.cfm">
	<cfabort>
<cfelseif PayBy Is "CC">
	<cfquery name="CurCC" datasource="#pds#">
		SELECT * 
		FROM PayByCC 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfset HowWide = 4>
	<cfif CurCC.RecordCount Is "0">
		<cfset ReturnPage = "payment.cfm">
		<cfset Card = "0">
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="payment3.cfm">
		<cfabort>
	</cfif>
<cfelseif PayBy Is "CK">
	<cfset ReturnPage = "payment.cfm">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="payment3.cfm">
	<cfabort>
<cfelseif PayBy Is "CD">
	<cfquery name="CurCD" datasource="#pds#">
		SELECT * 
		FROM PayByCD 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfset HowWide = 3>
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Payment Method</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="#ReturnPage#">
	<input type="Image" src="images/return.gif" border="0">
	<input type="Hidden" name="AccountID" value="#AccountID#">
	<input type="Hidden" name="AmountIDs" value="#AmountIDs#">
	<input type="Hidden" name="PayBy" value="#PayBy#">
	<input type="Hidden" name="OtherAmount" value="#OtherAmount#">
	<input type="Hidden" name="PayAmount" value="#PayAmount#">
</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Method</font></th>
	</tr>
</cfoutput>
<form method="post" action="payment3.cfm">
	<cfif PayBy Is "CC">
		<cfoutput>
			<tr>
				<th colspan="#HowWide#" bgcolor="#thclr#">Pay With</th>
			</tr>
		</cfoutput>
		<cfoutput query="CurCC">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="Radio" <cfif CurrentRow Is 1>checked</cfif> name="Card" value="#AccntPlanID#"></th>
				<td>#CCType#</td>
				<cfset DispStr1 = Right(CCNumber,4)>
				<cfset DispStr2 = Len(CCNumber) - 4>
				<cfif DispStr2 LT 1>
					<cfset DispStr2 = 1>
				</cfif>
				<cfset DispStr = RepeatString("*",DispStr2) & DispStr1>
				<td>#DispStr#</td>
				<td>#CCMonth#/#CCYear#</td>
			</tr>
		</cfoutput>
		<cfoutput>
			<tr>
				<th bgcolor="#tdclr#"><input type="Radio" name="Card" value="0"></th>
				<td bgcolor="#tbclr#" colspan="3">Different card</td>
			</tr>
		</cfoutput>
	<cfelseif PayBy Is "CD">
		<cfoutput>
			<tr>
				<th colspan="#HowWide#" bgcolor="#thclr#">Pay With</th>
			</tr>
		</cfoutput>
		<cfoutput query="CurCD">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="Radio" <cfif CurrentRow Is 1>checked</cfif> name="Card" value="#AccntPlanID#"></th>
				<td>#BankName#</td>
				<td>#NameOnAccnt#</td>
			</tr>
		</cfoutput>
		<cfoutput>
			<tr>
				<th bgcolor="#tdclr#"><input type="Radio" name="Card" value="0"></th>
				<td bgcolor="#tbclr#" colspan="2">Different account</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfoutput>
		<tr>
			<th colspan="#HowWide#"><input type="Image" name="Step3" src="images/continue.gif" border="0"></th>
		</tr>
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="AmountIDs" value="#AmountIDs#">
		<input type="Hidden" name="PayBy" value="#PayBy#">
		<input type="Hidden" name="OtherAmount" value="#OtherAmount#">
		<input type="Hidden" name="PayAmount" value="#PayAmount#">
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
