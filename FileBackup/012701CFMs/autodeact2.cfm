<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page add/removes customers that do not auto deactivate. --->
<!--- 4.0.0 08/18/00 --->
<!--- autodeact2.cfm --->

<cfset securepage="autodeact.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("AddListMember")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Accounts SET 
		NoAuto = 1 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = #AccountID#
		</cfquery>	
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added #GetWhoName.FirstName# #GetWhoName.LastName# to the auto deactivate exemption list.')
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AccountID 
		FROM GrpLists 
		WHERE AccountID = #AccountID# 
		AND ReportID = 30 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="EMailAddr" datasource="#pds#">
			SELECT EMail 
			FROM AccountsEMail 
			WHERE AccountID = #AccountID# 
			AND PrEMail = 1
		</cfquery>
		<cfquery name="PayByType" datasource="#pds#">
			SELECT PayBy 
			FROM AccntPlans 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif PayByType.PayBy Is "CC">
			<cfset ThePayType = "Credit Card">
		<cfelseif PayByType.PayBy Is "CK">
			<cfset ThePayType = "Check">
		<cfelseif PayByType.PayBy Is "CD">
			<cfset ThePayType = "Check Debit">
		<cfelseif PayByType.PayBy Is "PO">
			<cfset ThePayType = "Purchase Order">
		<cfelse>
			<cfset ThePayType = "Check">
		</cfif>
		<cfquery name="InsData" datasource="#PDS#">
			INSERT INTO GrpLists 
			(AccountID, FirstName, LastName, City, Address, Phone, 
			 Company, AdminID, ReportID, ReportTitle, CreateDate, EMail, ReportTab)
			SELECT A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
			A.Company, #MyAdminID#, 30, 'Auto Deactivate Exempt List', #Now()#, 
			<cfif EMailAddr.EMail Is "">Null<cfelse>'#EMailAddr.EMail#'</cfif>, 
			'#ThePayType#' 
			FROM Accounts A 
			WHERE A.AccountID = #AccountID# 
		</cfquery>	
	</cfif>
	<cfset SendReportID = 30>
	<cfset SendLetterID = 30>
	<cfset ReturnPage = "autodeact.cfm">
	<cfset SendHeader = "Name,Company,Pay By,Phone,E-Mail">
	<cfset SendFields = "Name,Company,ReportTab,Phone,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfparam name="ordby" default="Name">
<cfparam name="orddir" default="asc">
<cfif IsDefined("SearchStaff.x")>
	<cfquery name="FindStaff" datasource="#pds#">
		SELECT * 
		FROM Accounts 
		WHERE CancelYN = 0 
		AND NoAuto = 0 
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

<cfsetting enablecfoutputonly="No">
<cfif IsDefined("FindStaff")>
	<html>
	<head>
	<title>Search</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
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
					<form method="post" action="autodeact2.cfm">
						<th><input type="image" src="images/search.gif" name="Process" border="0"></th>
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
		<form method="post" action="autodeact2.cfm">
			<input type="image" src="images/return.gif" name="continue" border="0">
		</form>
		<center>
		<cfoutput query="FindStaff">
			<table border="#tblwidth#">			
				<tr>
					<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
				</tr>
				<tr>
					<th bgcolor="#thclr#" colspan="2">Click 'Add To List' to add to the<br>Auto Deactivation List.</th>
				</tr>
				<tr>
					<form method="post" action="autodeact2.cfm">
						<input type="hidden" name="AccountID" value="#AccountID#">
						<td align="right" colspan="2"><input type="submit" name="AddListMember" value="Add To List"></td>
					</form>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">name</td>
					<td bgcolor="#tbclr#"><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_#FirstName##LastName#"</cfif> >#Lastname#, #FirstName#</a></td>
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
		<form method="post" action="autodeact2.cfm">
			<input type="image" src="images/return.gif" name="continue" border="0">
		</form>
		<center>
		<table border="#tblwidth#">			
			<cfoutput>
				<tr>
					<th bgcolor="#ttclr#" colspan="5"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
				</tr>
				<tr bgcolor="#thclr#">
					<th>Select</th>
					<Th>Name</th>
					<th>gBill Login</th>
					<th>Phone</th>
					<th>City</th>
				</tr>
			</cfoutput>
			<form method="post" action="autodeact2.cfm">
				<cfoutput Query="FindStaff">
					<tr valign="top">
						<th bgcolor="#tdclr#"><input type="Radio" name="AccountID" value="#AccountID#" onclick="submit()"></th>
						<td bgcolor="#tbclr#"><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_#FirstName##LastName#"</cfif> >#LastName#, #FirstName#</a></td>
						<td bgcolor="#tbclr#">#Login#</td>
						<td bgcolor="#tbclr#">#DayPhone#<cfif DayPhone Is "">&nbsp;</cfif></td>
						<td bgcolor="#tbclr#"><cfif Trim(City) Is "">&nbsp;<cfelse>#City#</cfif></td>
					</tr>
				</cfoutput>
			</form>
		</table>
	</cfif>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
	<cfabort>
</cfif>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Search</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="grplist.cfm">
	<input type="hidden" name="SendReportID" value="30">
	<input type="hidden" name="SendLetterID" value="30">
	<input type="hidden" name="ReturnPage" value="autodeact.cfm">
	<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Phone,E-Mail">
	<input type="hidden" name="SendFields" value="Name,Company,ReportTab,Phone,EMail">
	<input type="image" src="images/viewlist.gif" name="continue" border="0">
</form>
<center>
<cfoutput>
<form method="post" action="autodeact2.cfm">
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
 