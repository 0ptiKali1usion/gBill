<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/26/99 --->
<!--- group6.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="CheckSession" datasource="#pds#">
	SELECT A.FirstName, A.LastName 
	FROM Accounts A 
	WHERE AccountID =
		(SELECT AccountID 
		 FROM Admin 
		 WHERE AdminID IN 
		 	(SELECT AdminID 
			 FROM MassActions 
			 WHERE BillingID = #BillingID# 
			 AND AdminID <> #MyAdminID# 
			)
		)
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Mass Deactivate/ Cancel</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="group2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Mass Deactivate/ Cancel</font></th>
	</tr>
	<tr>
		<th bgcolor="#tbclr#">This group account is currently locked for use by #CheckSession.FirstName# #CheckSession.LastName#.</th>
	</tr>
	<cfif GetOpts.SUserYN Is 1>
		<tr>
			<th bgcolor="#tbclr#">Click Continue to take control of the Mass Deact/Cancel session.</th>
		</tr>
		<form method="post" action="group5.cfm">
			<tr>
				<th><input type="Image" src="images/continue.gif" name="TakeOver" border="0"></th>
			</tr>
			<input type="Hidden" name="AccountID" value="#AccountID#">
			<input type="Hidden" name="BillingID" value="#BillingID#">
		</form>
	</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 