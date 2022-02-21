<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Credit card declined --->
<!--- payment6.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Payment Problem</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="payment.cfm">
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
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Problem</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">#MessageStr#</td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">Click the button Return to select a different payment method.</td>
	</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 