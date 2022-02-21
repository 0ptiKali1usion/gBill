<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page starts the debit all credit card process. --->
<!--- 4.0.0 10/23/00 --->
<!--- debitcc.cfm --->

<cfif IsDefined("TakeControl.x")>
	<cfquery name="TakeOver" datasource="#pds#">
		UPDATE CCDebitAll SET 
		AdminID = #MyAdminID# 
		WHERE CCAuthCode = 'Waiting' 
	</cfquery>
	<cfquery name="CheckEm" datasource="#pds#">
		SELECT AdminID 
		FROM CCDebitAll 
		WHERE AdminID <> #MyAdminID# 
	</cfquery>
	<cfif CheckEm.RecordCount GT 0>
		<cfx_wait SPAN="3">
	</cfif>
	<cfquery name="CheckEm" datasource="#pds#">
		SELECT AdminID 
		FROM CCDebitAll 
		WHERE AdminID <> #MyAdminID# 
	</cfquery>
	<cfif CheckEm.RecordCount GT 0>
		<cfx_wait SPAN="3">
	</cfif>
</cfif>

<cfquery name="CheckFirst" datasource="#pds#">
	SELECT * 
	FROM CCDebitAll 
	WHERE AdminID <> #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount GT 0>
	<cfquery name="WhoHas" datasource="#pds#">
		SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = 
			(SELECT AccountID 
			 FROM Admin 
			 WHERE AdminID = #CheckFirst.AdminID#)
	</cfquery>
	<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Debit All In Use</title>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<cfoutput>
	<form method="post" action="grplist.cfm">
		<input type="hidden" name="SendReportID" value="8">
		<input type="hidden" name="SendLetterID" value="8">
		<input type="hidden" name="ReturnPage" value="baldue.cfm">
		<input type="Hidden" name="SelectedTab" value="Credit Card">
		<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Amount,Phone,E-Mail">
		<input type="hidden" name="SendFields" value="Name,Company,ReportTab,CurBal,Phone,EMail">
		<td><input type="image" src="images/viewlist.gif" name="continue" border="0"></td>
	</form>
	<center>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Credit Card Debit All</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">There is a Debit All session currently underway by #WhoHas.FirstName# #WhoHas.LastName#.</td>
		</tr>
		<cfif GetOpts.SUserYN IS 1>
			<tr>
				<td bgcolor="#tbclr#">Click 'Enter' to take over the current session.</td>
			</tr>
			<form method="post" action="debitcc.cfm">
				<tr>
					<th><input type="Image" name="TakeControl" border="0" src="images/enter.gif"></th>
				</tr>
			</form>
		</cfif>
	</table>
	</cfoutput>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AccountID 
		FROM CCDebitAll
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="FillTable" datasource="#pds#">
			INSERT INTO CCDebitAll 
			(AccountID, AdminID, CCExpMonth, CCExpYear, CCNumber, CCCardHolder, AVSAddress, AVSZip, 
			 CCAmount, CCProcessDate, CCAuthCode) 
			SELECT AccountID, #MyAdminID#, '13', '0000', '123456789', 'AVS', 'AVS', 'AVS', 
			CurBal, #Now()#, 'Waiting' 
			FROM GrpLists 
			WHERE ReportID = 8 
			AND AdminID = #MyAdminID# 
			AND ReportTab = 'Credit Card' 
			ORDER BY LastName, FirstName
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CCDebitAll SET 
			CCExpMonth = P.CCMonth, 
			CCExpYear = P.CCYear, 
			CCCardHolder = P.CCCardHolder, 
			CCNumber = P.CCNumber, 
			AVSAddress = P.AVSAddress, 
			AVSZip = P.AVSZip 
			FROM PayByCC P, CCDebitAll C 
			WHERE C.AccountID = P.AccountID 
			AND P.ActiveYN = 1 
		</cfquery>
	</cfif>
	<cfquery name="CheckCCInfo" datasource="#pds#">
		SELECT AccountID 
		FROM CCDebitAll 
		WHERE CCNumber = '123456789' 
	</cfquery>
	<cfif CheckCCInfo.RecordCount GT 0>
		<cfquery name="ProblemInfo" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID IN 
				(SELECT AccountID 
				 FROM CCDebitAll 
				 WHERE CCNumber = '123456789') 
			ORDER BY LastName, FirstName 
		</cfquery>
	</cfif>
	<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Credit Card Customers To Debit</title>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<cfoutput>
	<center>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Credit Card Debit All</font></th>
		</tr>
	</cfoutput>
		<cfif CheckCCInfo.RecordCount GT 0>
			<tr>
				<cfoutput>
					<td bgcolor="#tbclr#">The following users have problems with their credit card info.</td>
				</cfoutput>
			</tr>
			<tr>
				<cfoutput>
					<td bgcolor="#tbclr#">Click 'Continue' to remove the problem customers from this debit session.</td>
				</cfoutput>
			</tr>
			<tr>
				<form method="post" action="debitcc2.cfm">
				<th><input type="Image" name="RemoveProbs" src="images/continue.gif" border="0"></th>
				</form>
			</tr>
			<cfoutput query="ProblemInfo">
				<tr>
					<td bgcolor="#tbclr#">#LastName#, #FirstName#</td>
				</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<cfoutput>
					<td bgcolor="#tbclr#">Click 'Continue' to begin the debit all session.</td>
				</cfoutput>
			</tr>		
			<tr>
				<form method="post" action="debitcc2.cfm">
				<th><input type="Image" name="ContinueOn" src="images/continue.gif" border="0"></th>
				</form>
			</tr>
		</cfif>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>
 
