<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is a list of customers with a credit. --->
<!---	4.0.0 09/03/99 --->
<!-- balcredit.cfm -->

<cfinclude template="security.cfm">

<cfif IsDefined("StartOver.x")>
	<cfquery name="StartReportOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 5 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfset TheNumber = IsNumeric(LookAmount)>
	<cfif TheNumber>
		<cfquery name="getit" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, Login, City, AccountID, Company, Phone, ReportHeader, 
			 ReportID, AdminID, ReportTitle, CurBal, CreateDate) 
			SELECT A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Company, 
			A.DayPhone, '#LookAmount#', 5, #MyAdminID#, 'Credit greater than #LSCurrencyFormat(LookAmount)#', SUM (T.Credit - T.Debit ), #Now()# 
			FROM Accounts A, Transactions T 
			WHERE A.AccountID = T.AccountID 
			GROUP BY A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.Company, 
			A.DayPhone 
			Having SUM(T.Credit - T.Debit) > (#LookAmount#) 
		</cfquery>
		<cfquery name="GetEMails" datasource="#pds#">
			UPDATE GrpLists SET 
			EMail = E.Email 
			FROM AccountsEMail E, GrpLists G 
			WHERE G.AccountID = E.AccountID 
			AND E.PrEMail = 1 
			AND G.ReportID = 5 
			AND G.AdminID = #MyAdminID# 
		</cfquery>
		<cfset SendReportID = 5>
		<cfset SendLetterID = 5>
		<cfquery name="ClearEmailTable" datasource="#pds#">
			DELETE FROM EMailOutGoing 
			WHERE LetterID = 5 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset ReturnPage = "balcredit.cfm">
		<cfset SendHeader = "Name,Company,Amount,Phone,E-Mail">
		<cfset SendFields = "Name,Company,CurBal,Phone,EMail">
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="grplist.cfm">
		<cfabort>	
	<cfelse>
		<cfset TheMessage = "The minimum amount must be a number.<br>Click Return to enter a different amount.">
	</cfif>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 5
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Customers With Credit</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif IsDefined("TheMessage")>
	<form method="post" action="balcredit.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>

<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Customers With Credit</font></th>
	</tr>
	<cfif IsDefined("TheMessage")>
		<tr>
			<td bgcolor="#tbclr#">#TheMessage#</td>
		</tr>
	<cfelseif CheckFirst.Recordcount Is 0>
		<form name="getmoney" method=post action="balcredit.cfm" onsubmit="MsgWindow()">
			<tr>
				<th bgcolor="#thclr#" colspan="2">Minumum Credit for this report.</th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right" valign="top">Amount</td>
				<td bgcolor="#tdclr#"><input size="5" type="Text" name="LookAmount" value="1"></td>
				<input type="hidden" name="LookAmount_Required" value="Please enter the minimum credit amount for this report.">
			</tr>
			<tr>
				<th colspan=2><input type="image" name="CreateReport" src="images/lookup.gif" border="0"></td>
			</tr>
		</form>
	<cfelse>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">There is currently a report in progress.<br>
			Click Change Criteria to start over with a new report.<br>
			Click View List to continue with the current report.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="5">
				<input type="hidden" name="SendLetterID" value="5">
				<input type="hidden" name="ReturnPage" value="balcredit.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Amount,Phone,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,CurBal,Phone,EMail">
				<th><input type="image" name="ViewList" src="images/viewlist.gif" border="0"></th>
			</form>
			<form method="post" action="balcredit.cfm">
				<th><input type="image" name="StartOver" src="images/changecriteria.gif" border="0"></th>
			</form>
		</tr>
	</cfif>
</table> 
</cfoutput>
</center>
<cfinclude template ="footer.cfm">
</BODY>
</HTML>
       