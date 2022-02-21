<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- When searching for a person to make an admin this page loads the search results. --->
<!--- 4.0.0 06/30/99
		3.2.0 09/08/98 --->
<!--- admined2.cfm --->
<cfset securepage="adminedt.cfm">
<cfinclude template="security.cfm">
<cfparam name="ordby" default="Name">
<cfparam name="orddir" default="asc">
<cfif IsDefined("SearchStaff.x")>
	<cfquery name="FindStaff" datasource="#pds#">
		SELECT * 
		FROM Accounts 
		WHERE CancelYN = 0 
		<cfif Trim(firstfld) Is Not "" OR Trim(secondfld) Is Not "">
			AND (
			<cfif Trim(firstfld) Is Not "">
				#firstparam# Like <cfif Action Is "starts">'#firstfld#%'<cfelse>'%#firstfld#%'</cfif>
			</cfif>
			<cfif Trim(firstfld) Is Not "" AND Trim(secondfld) Is Not "">
			#AndOr#
			</cfif>
			<cfif Trim(secondfld) Is Not "">
				#Secondparam# Like <cfif Action2 Is "starts">'#secondfld#%'<cfelse>'%#secondfld#%'</cfif>
			</cfif>		
			)	
		</cfif>
		AND AccountID Not In 
			(SELECT AccountID 
			 FROM Admin)
		ORDER BY 
			<cfif ordby Is "Name">
				LastName #orddir#,FirstName #orddir#
			<cfelse>
				#ordby# #orddir#
			</cfif>
	</cfquery>
</cfif>
<cfif IsDefined("AccountID")>
	<cfquery name="FindStaff" datasource="#pds#">
		SELECT * 
		FROM Accounts 
		WHERE AccountID = #AccountID#
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">

<cfif IsDefined("FindStaff")>
	<html>
	<head>
	<title>Add Admin</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<form method="post" action="adminedt.cfm">
		<input type="image" src="images/return.gif" name="Return" border="0">
	</form>
	<center>
	<cfif FindStaff.RecordCount LT 1>
		<cfoutput>
			<table border="#tblwidth#">			
				<tr>
					<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">No records were found matching 
						<cfif Trim(firstfld) Is Not "">
							#FORM.FIRSTPARAM# #action# #FORM.FIRSTFLD#
						</cfif>
						<cfif Trim(firstfld) Is Not "" AND Trim(secondfld) Is Not "">
							#AndOr#
						</cfif>
						<cfif Trim(secondfld) Is Not "">
							#Secondparam# #Action2# #SECONDFLD#
						</cfif>		
					</td>
				</tr> 
				<tr>
					<form method="post" action="admined2.cfm">
						<th><input type="image" src="images/search.gif" name="LookUp" border="0"></th>
					</form>
				</tr>  
			</table>
		</cfoutput>
	<cfelseif FindStaff.RecordCount Is 1>
		<cfsetting enablecfoutputonly="yes">
			<cfquery name="GetEMail" datasource="#pds#">
				SELECT EMail 
				FROM AccountsEMail 
				WHERE AccountID = #FindStaff.AccountID#
			</cfquery>
		<cfsetting enablecfoutputonly="no">
		<cfoutput query="FindStaff">
			<table border="#tblwidth#">			
				<tr>
					<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
				</tr>
				<tr>
					<form method="post" action="admined3.cfm">
						<input type="hidden" name="AccountID" value="#AccountID#">
						<td align="right" colspan="2"><input type="submit" name="AddStaffMember" value="Add To Staff"></td>
					</form>
				</tr>
				<tr>
					<th bgcolor="#thclr#" colspan="2">#firstname# #lastname#<br>
					Click 'Add To Staff' to add to your staff list.</th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">Login</td>
					<td bgcolor="#tbclr#">#Login#</td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">E-Mail</td>
					<cfif trim(GetEMail.EMail) Is "">
						<td bgcolor="#tbclr#">&nbsp;</td>
					<cfelse>
						<td bgcolor="#tbclr#">#GetEMail.EMail#</td>
					</cfif>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">Phone</td>
					<cfif Trim(dayphone) Is "">
						<td bgcolor="#tbclr#">&nbsp;</td>
					<cfelse>
						<td bgcolor="#tbclr#">#dayphone#</td>
					</cfif>
				</tr>
				<cfif Trim(evephone) Is Not "">
					<tr>
						<td bgcolor="#tbclr#" align="right">Phone</td>
						<td bgcolor="#tbclr#">#evephone#</td>
					</tr>
				</cfif>
				<tr>
					<td bgcolor="#tbclr#" align="right">Address</td>
					<cfif Trim(Address1) Is "">
						<td bgcolor="#tbclr#">&nbsp;</td>
					<cfelse>
						<td bgcolor="#tbclr#">#Address1#</td>
					</cfif>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">City</td>
					<cfif Trim(City) Is "">
						<td bgcolor="#tbclr#">&nbsp;</td>
					<cfelse>
						<td bgcolor="#tbclr#">#City#</td>
					</cfif>
				</tr>
			</cfoutput>
		</table>
	<cfelseif FindStaff.RecordCount GT 1>
		<table border="#tblwidth#">			
			<cfoutput>
				<tr>
					<th bgcolor="#ttclr#" colspan="5"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
				</tr>
				<tr bgcolor="#thclr#">
					<th>View</th>
					<th>Name</th>
					<th>gBill Login</th>
					<th>Phone</th>
					<th>City</th>
				</tr>
			</cfoutput>
			<form method="post" action="admined2.cfm">
				<cfoutput Query="FindStaff">
					<tr valign="top">
						<th bgcolor="#tdclr#"><input type="Radio" name="AccountID" value="#AccountID#" onclick="submit()"></th>
						<td bgcolor="#tbclr#">#LastName#, #FirstName#</td>
						<td bgcolor="#tbclr#">#Login#</td>
						<td bgcolor="#tbclr#">#DayPhone#</td>
						<td bgcolor="#tbclr#"><cfif Trim(City) Is "">&nbsp;<cfelse>#City#</cfif></td>
					</tr>
				</cfoutput>
			</form>
		</TABLE>
	</cfif>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelseif IsDefined("LookUp.x")>	
	<html>
	<head>
	<title>Search</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<form method="post" action="adminedt.cfm">
		<input type="image" src="images/return.gif" name="Return" border="0">
	</form>
	<center>
	<cfoutput>
	<form method="post" action="admined2.cfm">
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#" colspan="3"><FONT color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Search Criteria</FONT></th>
		</tr>
		<tr>
			<td bgcolor="#tdclr#"><SELECT name="firstparam">
				<OPTION value="lastname">Last Name
				<OPTION value="firstname">First Name
				<OPTION value="login">gBill Login
			</SELECT></td>
			<td bgcolor="#tdclr#"><INPUT type="radio" checked name="action" value="starts"> starts with <INPUT type="radio" name="action" value="contains"> contains</td>
			<td bgcolor="#tdclr#"><INPUT NAME="firstfld" TYPE="TEXT" SIZE="25"></td>
		</tr>
		<tr>
			<td bgcolor="#tdclr#">&nbsp;</td>
			<th bgcolor="#tdclr#"><INPUT TYPE=RADIO CHECKED NAME="AndOr" VALUE="AND">AND <INPUT TYPE=RADIO NAME="AndOr" VALUE="OR">OR</th>
			<td bgcolor="#tdclr#">&nbsp;</td>
		</tr>
		<tr>
			<td bgcolor="#tdclr#"><SELECT name="secondparam">
				<OPTION value="firstname">First Name
				<OPTION value="lastname">Last Name
				<OPTION value="login">gBill Login
			</SELECT></td>
			<td bgcolor="#tdclr#"><INPUT type="radio" name="action2" value="starts"> starts with <INPUT type="radio" checked name="action2" value="contains"> contains</td>
			<td bgcolor="#tdclr#"><INPUT NAME="secondfld" TYPE="TEXT" SIZE="25"></td>
		</tr>
		<tr>
			<th colspan="3"><INPUT TYPE="image" src="images/search.gif" border="0" name="SearchStaff"></th>
		</tr>
	</table>
	</form>
	</cfoutput>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>


