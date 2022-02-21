<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 10/29/99 --->
<!--- accntmanage.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="AllAccounts" datasource="#pds#">
	SELECT A.AccntPlanID, P.PlanDesc, P.AuthNumber, P.FreeEMails, P.FTPNumber, 
	A.AuthAccounts, A.FTPAccounts, A.EMailAccounts, A.POPID, A.EMailDomainID, 
	A.LastDebitDate, A.NextDueDate, A.AccntStatus, A.PayBy, A.PostalRem, A.DeactDate, 
	A.DeactReason 
	FROM AccntPlans A, Plans P 
	WHERE A.PlanID = P.PlanID 
	AND A.AccountID = #AccountID# 
</cfquery>
<cfquery name="GetPrimaryEmail" datasource="#pds#">
	SELECT E.AccountID, E.PrEmail, E.EMailID, E.EMail, P.PlanDesc 
	FROM AccountsEMail E, AccntPlans A, Plans P 
	WHERE E.AccntPlanID = A.AccntPlanID 
	AND A.PlanID = P.PlanID 
	AND E.AccountID = #AccountID# 
	AND E.PrEMail = 1
</cfquery>
<cfif GetPrimaryEmail.RecordCount Is 0>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT EMailID 
		FROM AccountsEMail 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif CheckFirst.RecordCount Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE AccountsEMail SET 
			PrEMail = 1 
			WHERE AccountID = #AccountID# 
		</cfquery>
	<cfelse>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE AccountsEMail SET 
			PrEMail = 1 
			WHERE AccountID = #AccountID# 
			AND EMailID = 
				(SELECT Min(EMailID) 
				 FROM AccountsEMail 
				 WHERE AccountID = #AccountID#) 
		</cfquery>
	</cfif>
	<cfquery name="GetPrimaryEmail" datasource="#pds#">
		SELECT E.AccountID, E.PrEmail, E.EMailID, E.EMail, P.PlanDesc 
		FROM AccountsEMail E, AccntPlans A, Plans P 
		WHERE E.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND E.AccountID = #AccountID# 
		AND E.PrEMail = 1
	</cfquery>
</cfif>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Account Management</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="accountid" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="13"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName# Accounts</font></th>
	</tr>
	<form method="post" action="accntnew.cfm">
		<tr>
			<td colspan="13" align="right"><input type="image" name="AddNew" src="images/addnew.gif" border="0"></td>
		</tr>
		<input type="Hidden" name="AccountID" value="#AccountID#">
	</form>
	<tr valign="top" bgcolor="#thclr#">
		<th rowspan="2">Edit</th>
		<th rowspan="2">Plan</th>
		<th colspan="2">Auth</th>
		<th colspan="2">FTP</th>
		<th colspan="3">E-Mail</th>
		<th rowspan="2">Next Due</th>
		<th rowspan="2">Status</th>
		<th colspan="2">Action</th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Limit</th>
		<th>Actual</th>
		<th>Limit</th>
		<th>Actual</th>
		<th>Limit</th>
		<th>Actual</th>
		<th>Contact</th>
		<th>Change</th>
		<th>Cancel</th>
	</tr>
</cfoutput>
<cfloop query="AllAccounts">
	<cfsetting enablecfoutputonly="Yes">
		<cfquery name="AuthInfo" datasource="#pds#">
			SELECT * 
			FROM AccountsAuth 
			WHERE AccntPlanID = #AccntPlanID# 
			ORDER BY UserName 
		</cfquery>
		<cfquery name="FTPInfo" datasource="#pds#">
			SELECT * 
			FROM AccountsFTP 
			WHERE AccntPlanID = #AccntPlanID# 
			ORDER BY UserName 
		</cfquery>
		<cfquery name="EMailInfo" datasource="#pds#">
			SELECT * 
			FROM AccountsEMail 
			WHERE AccntPlanID = #AccntPlanID# 
			AND ContactYN = 0 
			ORDER BY EMail 
		</cfquery>
		<cfquery name="EMailContact" datasource="#pds#">
			SELECT * 
			FROM AccountsEMail 
			WHERE AccntPlanID = #AccntPlanID# 
			AND ContactYN = 1 
			ORDER BY EMail 
		</cfquery>
		<cfquery name="CheckScheduled" datasource="#pds#">
			SELECT * 
			FROM AutoRun 
			WHERE AccntPlanID = #AccntPlanID# 
			AND (DoAction = 'Rollback' 
			  	OR DoAction = 'Cancel' 
 				OR DoAction = 'Deactivate')
		</cfquery>
		<cfquery name="PlanToInfo" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = 
				(SELECT PlanID 
				 FROM AutoRun 
				 WHERE AccntPlanID = #AccntPlanID# 
				 AND (DoAction = 'Rollback' 
				  		OR DoAction = 'Cancel' 
	 					OR DoAction = 'Deactivate')
				)
		</cfquery>
	<cfsetting enablecfoutputonly="No">
	<cfoutput>
		<cfif (CheckScheduled.WhenRun LT Now()) AND (CheckScheduled.WhenRun Is Not "")>
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#">&nbsp;</th>
				<td colspan="10">#PlanDesc# scheduled to <cfif CheckScheduled.DoAction Is "Cancel">cancel<cfelseif CheckScheduled.DoAction Is "Deactivate">deactivate<cfelse>change to #PlanToInfo.PlanDesc#</cfif> on #LSDateFormat(CheckScheduled.WhenRun, '#DateMask1#')# #LSTimeFormat(CheckScheduled.WhenRun, 'HH:mm')#</td>
				<td bgcolor="#tdclr#">&nbsp;</td>
				<td bgcolor="#tdclr#">&nbsp;</td>
			</tr>
		<cfelse>
			<tr bgcolor="#tbclr#">
				<form method="post" action="accntmanage2.cfm">
					<th bgcolor="#tdclr#"><input type="radio" name="AccntPlanID" value="#AccntPlanID#" onclick="submit()"></th>
				</form>
				<td>#PlanDesc#</td>
				<cfif AuthAccounts Is "">
					<td align="right">#AuthNumber#</td>
				<cfelse>
					<td align="right">#AuthAccounts#</td>
				</cfif>
				<td align="right">#AuthInfo.Recordcount#</td>
				<cfif FTPAccounts Is "">
					<td align="right">#FTPNumber#</td>
				<cfelse>
					<td align="right">#FTPAccounts#</td>
				</cfif>
				<td align="right">#FTPInfo.Recordcount#</td>
				<cfif EMailAccounts Is "">
					<td align="right">#FreeEMails#</td>
				<cfelse>
					<td align="right">#EMailAccounts#</td>
				</cfif>
				<td align="right">#EMailInfo.Recordcount#</td>
				<td align="right">#EMailContact.Recordcount#</td>
				<td>#LSDateFormat(NextDueDate, '#DateMask1#')#</td>
				<cfif AccntStatus Is 0>
					<td>Active</td>
				<cfelse>
					<td>Deactivated</td>
				</cfif>
				<cfset TheStatus = AccntStatus>
				<cfquery name="CheckSched" datasource="#pds#">
					SELECT * 
					FROM AutoRun 
					WHERE DoAction IN ('Deactivate','Reactivate','Cancel') 
					AND AccntPlanID = #AccntPlanID# 
					ORDER BY DoAction
				</cfquery>
				<cfif CheckSched.recordcount GT 1>
					<cfset CheckList = ValueList(CheckSched.DoAction)>
					<cfset CheckDate = ValueList(CheckSched.WhenRun)>
					<cfif (ListFind(CheckList,"Deactivate")) OR (ListFind(CheckList,"Reactivate")) GT 0>
						<cfset WhenRun = ListGetAt(CheckDate,2)>
						<th bgcolor="#tdclr#"><font size="2">#LSDateFormat(WhenRun, '#DateMask1#')#</font></th>
						<cfset WhenRun = ListGetAt(CheckDate,1)>
						<th bgcolor="#tdclr#"><font size="2">#LSDateFormat(WhenRun, '#DateMask1#')#</font></th>
					</cfif>
				<cfelseif CheckSched.recordcount Is 1>
					<cfloop query="CheckSched">
						<cfif DoAction Is "Deactivate">
							<th bgcolor="#tdclr#"><font size="2">#LSDateFormat(WhenRun, '#DateMask1#')#</font></th>
							<form method="post" action="accntmanage7.cfm">
								<th bgcolor="#tdclr#"><input type="Radio" name="CancelAccnt" value="1" onclick="submit()"></th>
							</form>
						<cfelseif DoAction Is "Reactivate">
							<th bgcolor="#tdclr#"><font size="2">#LSDateFormat(WhenRun, '#DateMask1#')#</font></th>
							<form method="post" action="accntmanage7.cfm">
								<th bgcolor="#tdclr#"><input type="Radio" name="CancelAccnt" value="1" onclick="submit()"></th>
							</form>
						<cfelseif DoAction Is "Cancel">
							<form method="post" action="accntmanage7.cfm">
								<input type="Hidden" name="AccntStatus" value="#TheStatus#">
								<th bgcolor="#tdclr#"><input type="Radio" name="ActDeactChange" value="1" onclick="submit()"></th>
							</form>
							<th bgcolor="#tdclr#"><font size="2">#LSDateFormat(WhenRun, '#DateMask1#')#</font></th>
						</cfif>
					</cfloop>
				<cfelseif CheckSched.recordcount Is 0>
					<form method="post" action="accntmanage7.cfm">
						<input type="Hidden" name="AccntStatus" value="#TheStatus#">
						<th bgcolor="#tdclr#"><input type="Radio" name="ActDeactChange" value="1" onclick="submit()"></th>
						<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
					</form>
					<form method="post" action="accntmanage9.cfm">
						<th bgcolor="#tdclr#"><input type="Radio" name="CancelAccnt" value="1" onclick="submit()"></th>
						<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
					</form>
				</cfif>
			</tr>
		</cfif>
	</cfoutput>
</cfloop>
<cfif GetPrimaryEmail.RecordCount Gt 0>
	<tr>
		<cfoutput>
			<th bgcolor="#thclr#" colspan="13">Selected Email address to receive all correspondence for this account.</th>
		</cfoutput>
	</tr>
	<tr>
		<cfoutput>
			<th bgcolor="#tdclr#">P</th>
			<td bgcolor="#tbclr#">#GetPrimaryEmail.PlanDesc#</td>
			<td bgcolor="#tbclr#" colspan="9">#GetPrimaryEmail.EMail#</td>
			<form method="post" action="accntpremail.cfm">
				<th bgcolor="#tdclr#"><input type="Radio" name="AccountID" value="#GetPrimaryEmail.AccountID#" onclick="submit()"></th>
			</form>
			<th bgcolor="#tdclr#">&nbsp;</th>
		</cfoutput>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 