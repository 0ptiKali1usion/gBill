<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is final confirmation for credit card or check debit. --->
<!--- payment3.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfif PayBy Is "CA">
	<cfset ReturnPage = "custinf1.cfm">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="payment4.cfm">
	<cfabort>
<cfelseif PayBy Is "CC">
	<cfif Card GT 0>
		<cfset ReturnPage = "custinf1.cfm">
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="payment4.cfm">
		<cfabort>
	<cfelse>
		<cfset ReturnPage = "payment2.cfm">
	</cfif>
	<cfquery name="GetYears" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'AddYear' 
	</cfquery>
	<cfif GetYears.Recordcount GT 0>
		<cfset ToYear = DateAdd("yyyy",GetYears.Value1,Now())>
	<cfelse>
		<cfset ToYear = DateAdd("yyyy",6,Now())>
	</cfif>
<cfelseif PayBy Is "CK">
<cfelseif PayBy Is "CD">
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Payment Confirmation</title>
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
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Confirmation</font></th>
	</tr>
	<form method="post" action="payment4.cfm">
		<cfif PayBy Is "Ck">
			<tr>
				<td align="right" bgcolor="#tbclr#">Check Number</td>
				<td bgcolor="#tdclr#"><input type="Text" name="CkNumber" size="6"></td>
				<input type="Hidden" name="CkNumber_Require" value="Please enter the check number.">
			</tr>
		<cfelseif PayBy Is "CC">
			<tr>
				<td align="right" bgcolor="#tbclr#">Card Type</td>
				<td bgcolor="#tdclr#"><select name="CCType">
					<option value="Am Express">American Express
					<option value="Discover">Discover
					<option value="MasterCard">Mastercard
					<option value="Visa">Visa
				</select></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Number</td>
				<td bgcolor="#tdclr#"><input type="Text" name="CardNum" value="" size="16"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Expires</td>
				<td bgcolor="#tdclr#"><select name="ExpMonth">
					<cfloop index="B5" from="1" to="12">
						<option value="#B5#">#MonthAsString(B5)#
					</cfloop>
				</select><select name="ExpYear">
					<cfloop index="B4" from="#Year(Now())#" to="#Year(ToYear)#">
						<option value="#B4#">#B4#
					</cfloop>
				</select></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Name on card</td>
				<td bgcolor="#tdclr#"><input type="Text" name="CCCardHolder" value="" size="25"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Cardholder Address</td>
				<td bgcolor="#tdclr#"><input type="Text" name="AVSAddress" value="" size="25"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Cardholder Zip</td>
				<td bgcolor="#tdclr#"><input type="Text" name="AVSZip" value="" size="10"></td>
			</tr>
			<input type="Hidden" name="Card" value="#Card#">
		</cfif>
		<tr>
			<th colspan="2"><input type="Image" src="images/continue.gif" border="0" name="Step4"></th>
		</tr>
		<input type="Hidden" name="AmountIDs" value="#AmountIDs#">
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="PayBy" value="#PayBy#">
		<input type="Hidden" name="OtherAmount" value="#OtherAmount#">
		<input type="Hidden" name="PayAmount" value="#PayAmount#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 

