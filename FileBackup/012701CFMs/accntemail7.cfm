<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Add contact email address. --->
<!---	4.0.0 04/06/00 --->
<!--- accntemail7.cfm --->

<cfparam name="IsError" default="0">

<cfif IsDefined("EditEMail.x")>
	<cfparam name="NewPlanID" default="0">
	<cfset EMailCheck = EMail>
	<cfset Pos1 = Find("@",Email)>
	<cfif Pos1 GT 0>
		<cfset Str1 = Pos1>
	<cfelse>
		<cfset Str1 = 1>
	</cfif>
	<cfset Pos2 = Find(".",Email,Str1)>
	<cfif (Pos1 GT 0) AND (Pos2 GT 0)>
		<cfquery name="AcntInfo" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT EMailID 
			FROM AccountsEMail 
			WHERE AccountID = #AcntInfo.AccountID# 
			AND PrEmail = 1 
		</cfquery>
		<cfif CheckFirst.RecordCount Is 0>
			<cfset PrEMail = 1>
		<cfelse>
			<cfset PrEMail = 0>
		</cfif>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="OldContact" datasource="#pds#">
				SELECT EMail 
				FROM AccountsEMail 
				WHERE EMailID = #EMailID#
			</cfquery>
			<cfset BOBHistMess = "#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the contact email address from #OldContact.EMail# to #EMail# for #AcntInfo.FirstName# #AcntInfo.LastName#.">
			<cfif NewPlanID GT 0>
				<cfquery name="NewPlan" datasource="#pds#">
					SELECT PlanDesc 
					FROM Plans 
					WHERE PlanID = 
						(SELECT PlanID 
						 FROM AccntPlans 
						 WHERE AccntPlanID = #NewPlanID#) 
				</cfquery>
				<cfset BOBHistMess = BOBHistMess & "  The EMail address was moved to the plan: #NewPlanID# #NewPlan.PlanDesc#">
			</cfif>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist 
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#AcntInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#BOBHistMess#')
			</cfquery>
		</cfif>
		<cfquery name="AddContact" datasource="#pds#">
			UPDATE AccountsEMail SET 
			EMail = '#EMail#', 
			FName = '#AcntInfo.FirstName#', 
			LName = '#AcntInfo.LastName#', 
			PrEMail = #PrEMail#, 
			<cfif NewPlanID GT 0>
				AccntPlanID = #NewPlanID#, 
			</cfif>
			FullName = '#AcntInfo.FirstName# #AcntInfo.LastName#' 
			WHERE EMailID = #EMailID#
		</cfquery>
		<cfset Tab = 4>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="accntmanage2.cfm">
		<cfabort>	
	<cfelse>
		<cfset IsError = 1>
		<cfset ErrorMessage = "#EMail# is not a valid EMail address.">
	</cfif>
</cfif>
<cfif IsDefined("AddEMail.x")>
	<cfset EMailCheck = EMail>
	<cfset Pos1 = Find("@",Email)>
	<cfif Pos1 GT 0>
		<cfset Str1 = Pos1>
	<cfelse>
		<cfset Str1 = 1>
	</cfif>
	<cfset Pos2 = Find(".",Email,Str1)>
	<cfif (Pos1 GT 0) AND (Pos2 GT 0)>
		<cfquery name="AcntInfo" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = #AccntPlanID#)
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT EMailID 
			FROM AccountsEMail 
			WHERE AccountID = #AcntInfo.AccountID# 
			AND PrEmail = 1 
		</cfquery>
		<cfif CheckFirst.RecordCount Is 0>
			<cfset PrEMail = 1>
		<cfelse>
			<cfset PrEMail = 0>
		</cfif>
		<cfset EMailToCheck = Trim(EMail)>
		<cfset Pos1 = FindNoCase("@",EMailToCheck)>
		<cfif Pos1 GT 0>
			<cfset EMFirst = Left(EMailToCheck,Pos1)>
			<cfset Len1 = Len(EMailToCheck) - Pos1>
			<cfset EMSecond = Right(EMailToCheck,Len1)>
			<cfset EMFirst = ReplaceList(EMFirst,"@","")>
			<cfset EMSecond = ReplaceList(EMSecond,"@","")>
		<cfelse>
			<cfset EMFirst = "">
			<cfset EMSecond = "">
		</cfif>
		<cfquery name="AddContact" datasource="#pds#">
			INSERT INTO AccountsEMail
			(AccountID, EMail, FName, LName, Alias, PrEMail, ContactYN, FullName, AccntPlanID, 
			 DomainName, SMTPUserName, Login, CEMailID)
			VALUES
			(#AcntInfo.AccountID#, '#EMail#', '#AcntInfo.FirstName#', '#AcntInfo.LastName#', 
			 0, #PrEMail#, 1, '#AcntInfo.FirstName# #AcntInfo.LastName#', #AccntPlanID#, 
			 <cfif Trim(EMSecond) Is "">Null<cfelse>'#EMSecond#'</cfif>,
			 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
			 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 0)
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist 
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#AcntInfo.AccountID#,#MyAdminID#, #Now()#,'Edited Customer Info',
				 '#StaffMemberName.FirstName# #StaffMemberName.LastName# entered the contact email address: #EMail# for #AcntInfo.FirstName# #AcntInfo.LastName#.')
			</cfquery>
		</cfif>
		<cfset Tab = 4>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="accntmanage2.cfm">
		<cfabort>	
	<cfelse>
		<cfset IsError = 1>
		<cfset ErrorMessage = "#EMail# is not a valid EMail address.">
	</cfif>
</cfif>
<cfif IsDefined("EmailID")>
	<cfquery name="AuthInfo" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<cfquery name="SelectedPlan" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = 
			 	(SELECT AccntPlanID 
				 FROM AccountsEMail 
				 WHERE EMailID = #EMailID#)
			)
	</cfquery>
	<cfquery name="OtherPlans" datasource="#pds#">
		SELECT AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails, Count(E.EMailID) as IntNumber 
		FROM Plans P, AccntPlans AP, AccountsEMail E 
		WHERE P.PlanID = AP.PlanID 
		AND E.AccntPlanID = AP.AccntPlanID 
		AND AP.AccountID = #AuthInfo.AccountID# 
		AND AP.AccntPlanID <> #AccntPlanID# 
		GROUP BY AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails 
		HAVING Count(E.EMailID) < P.FreeEmails 
		OR Count(E.EMailID) < AP.EMailAccounts 
		UNION 
		SELECT AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails, 0 as IntNumber  
		FROM Plans P, AccntPlans AP 
		WHERE P.PlanID = AP.PlanID 
		AND AP.AccntPlanID <> #AccntPlanID# 
		AND AP.AccountID = #AuthInfo.AccountID# 
		AND (P.FreeEmails > 0 OR AP.EMailAccounts > 0) 
		AND AP.AccntPlanID NOT IN 
			(SELECT AccntPlanID 
			 FROM AccountsEMail)
	</cfquery>
	<cfquery name="ContactEMail" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE EMailID = #EMailID# 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Contact EMail address</title>
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
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Contact EMail address</font></th>
	</tr>
	<form method="post" action="accntemail7.cfm">
		<cfif IsError>
			<tr>
				<td colspan="2" bgcolor="#tbclr#">#ErrorMessage#</td>
			</tr>
		</cfif>
		<cfif IsDefined("SelectedPlan")>
			<tr>
				<th bgcolor="#thclr#" colspan="2">#SelectedPlan.PlanDesc#</th>
			</tr>
		</cfif>
</cfoutput>
		<cfif (IsDefined("OtherPlans")) AND (OtherPlans.Recordcount GT 0)>
			<cfoutput>
				<tr bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align="right">Change To</td>
			</cfoutput>
					<td><select name="NewPlanID">
						<cfoutput><option value="0">Leave on #SelectedPlan.PlanDesc#</cfoutput>
						<cfoutput query="OtherPlans">
							<option <cfif PlanID Is SelectedPlan.PlanID>selected</cfif> value="#AccntPlanID#">#PlanDesc#
						</cfoutput>
					</select></td>
				</tr>
		</cfif>
<cfoutput>
		<tr>
			<td align="right" bgcolor="#tbclr#">EMail Address</td>
			<td bgcolor="#tdclr#"><input type="Text" size="40" name="EMail" <cfif IsDefined("EmailID")>value="#ContactEMail.EMail#"</cfif><cfif IsDefined("Email")> value="#EMail#"</cfif> maxlength="150"></td>
			<input type="Hidden" name="EMail_Required" value="Please enter the contact EMail address.">
		</tr>
		<tr>
			<cfif IsDefined("EMailID")>
				<th colspan="2"><input type="Image" src="images/edit.gif" border="0" name="EditEMail"></th>
				<input type="Hidden" name="EMailID" value="#EMailID#">
			<cfelse>
				<th colspan="2"><input type="Image" src="images/enter.gif" border="0" name="AddEMail"></th>
			</cfif>
		</tr>
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
	</form>
	<tr>
		<td bgcolor="#tbclr#" colspan="2">A contact email address is one that is not on your system.<br>
		The address is strictly to have a way to contact the customer via EMail.</td>
	</tr>
</cfoutput>
<form method="post" action="accntemail4.cfm">
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 