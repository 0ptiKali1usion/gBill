<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/22/99 --->
<!--- group4.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfparam name="Tab" default="1">
<cfif Tab Is 1>
	<cfset HowWide = 2>
<cfelseif Tab Is 2>
	<cfset HowWide = 3>
	<cfquery name="GetResults" datasource="#pds#">
		SELECT LastName, FirstName, AccountID, Company 
		FROM Accounts 
		WHERE #FirstParam# Like 
			<cfif LogicParam Is "Starts">'#SecondParam#%' 
			<cfelseif LogicParam Is "Contains">'%#SecondParam#%' 
			</cfif>
		AND AccountID Not In 
			(SELECT AccountID 
			 FROM Multi) 
		AND CancelYN = 0 
		ORDER BY LastName, FirstName 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Search</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="group2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Group Account Setup</font></th>
	</tr>
</cfoutput>
<cfif Tab Is 2>
	<cfoutput>
		<tr>
			<th bgcolor="#thclr#" colspan="3">Search Results</th>
		</tr>
	</cfoutput>
	<cfif GetResults.Recordcount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Select</th>
				<th>Name</th>
				<th>Company</th>
			</tr>
		</cfoutput>
		<form method="post" action="group2.cfm">
			<cfoutput query="GetResults">
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#"><input type="Radio" name="SelectID" value="#AccountID#" onclick="submit()"></th>
					<td>#LastName#, #FirstName#</td>
					<td>#Company#<cfif Trim(Company) Is "">&nbsp;</cfif></td>
				</tr>
			</cfoutput>
			<cfoutput>
				<input type="Hidden" name="PrimaryID" value="#PrimaryID#">
				<input type="Hidden" name="AccountID" value="#AccountID#">
				<cfif IsDefined("AddOne")>
					<input type="Hidden" name="AddOne" value="1">
				<cfelse>
					<input type="Hidden" name="NewGroup" value="1">
				</cfif>		
			</cfoutput>
		</form>
	<cfelse>
		<cfoutput>
		<form method="post" action="group4.cfm">
				<tr>
					<td colspan="3" bgcolor="#tbclr#">No results matched your search.  Click Try Again to change your search criteria.</td>
				</tr>
				<tr>
					<th colspan="3"><input type="image" name="TryAgain" src="images/tryagain.gif" border="0"></th>
				</tr>
				<input type="Hidden" name="AccountID" value="#AccountID#">
				<cfif IsDefined("AddOne")>
					<input type="Hidden" name="AddOne" value="1">
				</cfif>		
			</form>
		</cfoutput>
	</cfif>
<cfelseif Tab Is 1>
	<cfoutput>
	<form method="post" action="group4.cfm">
		<tr>
			<th bgcolor="#thclr#" colspan="2">Search criteria</th>
		</tr>
		<tr>
			<td bgcolor="#tdclr#"><select name="FirstParam">
				<option value="LastName">Last Name
				<option value="FirstName">First Name
				<option value="Company">Company
				<option value="Login">gBill Login
			</select></td>
			<td bgcolor="#tdclr#"><select name="LogicParam">
				<option value="Starts">Starts With
				<option value="Contains">Contains
			</select></td>
		</tr>
		<tr>
			<td colspan="2" bgcolor="#tdclr#"><input type="text" name="SecondParam" size="25"></td>
		</tr>
		<tr>
			<th colspan="2"><input type="image" src="images/search.gif" name="SearchFor" border="0"></th>
		</tr>
		<input type="Hidden" name="PrimaryID" value="#AccountID#">
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="Tab" value="2">
		<cfif IsDefined("AddOne.x")>
			<input type="Hidden" name="AddOne" value="1">
		</cfif>
		<cfif IsDefined("AddOne")>
			<input type="Hidden" name="AddOne" value="1">
		</cfif>		
	</form>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 