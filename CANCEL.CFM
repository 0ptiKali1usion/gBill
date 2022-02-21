<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page allows deleting a customer out of the database. --->
<!--- 4.0.1 02/06/01 Added cleanup of PlanSignAdm
		4.0.0 07/21/00 --->
<!--- cancel.cfm --->

<cfif GetOpts.CancelA Is "1">
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("ConfirmDelete.x")>
	<cfif confirm1 Is "YES">
		<cfif FileExists("#dirpathway#external/deleteusr.cfm")>
			<cfinclude template="external/deleteusr.cfm">
		</cfif>
		<cfquery name="CleanUpID" datasource="#pds#">
			SELECT AdminID 
			FROM Admin 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif CleanUpID.RecordCount Is 0>
			<cfset DelAdID = 0>
		<cfelse>
			<cfset DelAdID = CleanUpID.AdminID>
		</cfif>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AccountsAuth 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AccountsFTP 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AccountsEMail 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AccntPlans 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Accounts 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AdmSort 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM AutoRun 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Connect 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM DomAccnt 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM DomAdm 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM FilterDomains 
			WHERE FilterID In 
				(SELECT FilterID 
				 FROM Filters 
				 WHERE AdminID = #DelAdID#) 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM FilterPlans 
			WHERE FilterID In 
				(SELECT FilterID 
				 FROM Filters 
				 WHERE AdminID = #DelAdID#) 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM FilterPOPs 
			WHERE FilterID In 
				(SELECT FilterID 
				 FROM Filters 
				 WHERE AdminID = #DelAdID#) 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM FilterSalesp 
			WHERE FilterID In 
				(SELECT FilterID 
				 FROM Filters 
				 WHERE AdminID = #DelAdID#) 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Filters 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM LetterAdm 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Multi 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PayByCC 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PayByCD 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PayByCK 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PayByPO 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PlanAdm 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM PlanSignAdm 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM POPAdm 
			WHERE AdminID = #DelAdID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM StaffMessageResult 
			WHERE AdminID = #DelAdID# 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Support 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TempDebit 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TempValues 
			WHERE AdminID = #DelAdID# 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TimeStore 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TimeTemp 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TimeTrax 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM TransActions 
			WHERE AccountID = #AccountID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Admin 
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
				(Null,0,#MyAdminID#, #Now()#,'',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted all traces of #GetWhoName.FirstName# #GetWhoName.LastName#.')
			</cfquery>
		</cfif>		
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Accounts 
			WHERE AccountID = #AccountID#
		</cfquery>
	</cfif>
</cfif>

<cfquery name="GetWho" datasource="#pds#">
	SELECT * 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<cfoutput>
<title>Confirm Delete From The Database</title>
<cfinclude template="coolsheet.cfm">
</head>
<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
<cfif GetWho.RecordCount Is 0>
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Data Deleted</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">The account was deleted successfully.</td>
	</tr>
<cfelse>
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Confirm Delete</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#"><b>You have clicked to delete the account for #GetWho.FirstName# #GetWho.LastName#.<br>
			This will permanently delete all records (including financial history) for this account.<br>
		This will affect the money totals in all new reports.</b></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">If you wish to continue type 'YES' in the box below then click 'Continue'.</td>
	</tr>
	<form method="post" action="cancel.cfm">
		<input type="hidden" name="accountid" value="#AccountID#">
		<tr>
			<th bgcolor="#tdclr#"><input type="text" name="confirm1" size="3" maxlength="3"></th>
		</tr>
		<tr>
			<th><input type="image" src="images/continue.gif" name="ConfirmDelete" border="0"></th>
		</tr>
	</form>
</cfif>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 