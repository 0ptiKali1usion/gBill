<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the where admins login to change their password.
--->
<!--- 4.0.0 09/01/99
		3.2.0 09/08/98 --->
<!-- passa.cfm -->

<cfinclude template="security.cfm">
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Change gBill Password</title> 
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset# onLoad="document.info.log.focus()"></cfoutput>
<cfinclude template="header.cfm">
<center>
<form name="info" method=post action="passa2.cfm">
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Change gBill Password</font></th>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">gBill Login</td>
		<td bgcolor="#tdclr#"><input type="text" name="log" size="20"></td>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">Old Password</td>
		<td bgcolor="#tdclr#"><input type="password" name="oldpasswd" size="20"></td>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">New Password</td>
		<td bgcolor="#tdclr#"><input type="password" name="newpasswd" size="20"></td>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">Confirm New Password</td>
		<td bgcolor="#tdclr#"><input type="password" name="compasswd" size="20"></td>
	</tr>
	<tr>
		<th colspan=2><input type="image" src="images/enter.gif" border="0" name="Continue"></th>
	</tr>
</cfoutput>
</table>
</form>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   