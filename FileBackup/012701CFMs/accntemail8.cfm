<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Delete contact email address. --->
<!---	4.0.1 01/25/01 Fixed an error with the gBill History.
		4.0.0 04/06/00 --->
<!--- accntemail8.cfm --->

<cfif IsDefined("DelContact.x")>
	<cfquery name="ContactInfo" datasource="#pds#">
		SELECT EMail, AccountID, FName, LName 
		FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<cfquery name="DelAddr" datasource="#pds#">
		DELETE FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#ContactInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the contact email address: #ContactInfo.EMail# for #ContactInfo.FName# #ContactInfo.LName#.')
		</cfquery>
	</cfif>
	<cfset Tab = 4>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="accntmanage2.cfm">
	<cfabort>	
</cfif>

<cfquery name="EMailAddr" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Delete Contact EMail address</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="tab" value="4">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Delete Contact EMail address</font></th>
	</tr>
	<cfif EMailAddr.PrEMail Is 1>
		<tr>
			<td bgcolor="#tbclr#">You have selected to delete the primary EMail address.<br>
			Please select another email to be the primary first.</td>
		</tr>
		<tr>
			<form method="post" action="accntpremail.cfm">
				<th><input type="Image" name="GoTo" src="images/select.gif" border="0"></th>
				<input type="Hidden" name="AccountId" value="#EMailAddr.AccountID#">
			</form>
		</tr>
	<cfelse>
		<form method="post" action="accntemail8.cfm">
			<tr>
				<td bgcolor="#tbclr#">You have selected to delete #EMailAddr.EMail#<br>
				Click Continue to confirm.</td>
			</tr>
			<tr>
				<th><input type="Image" name="DelContact" src="images/continue.gif" border="0"></th>
			</tr>
			<input type="Hidden" name="EMailID" value="#EMailID#">
			<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
		</form>
	</cfif>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 