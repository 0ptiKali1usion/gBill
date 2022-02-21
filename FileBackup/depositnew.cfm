<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that makes the deposit. --->
<!---	4.0.0 09/07/99 --->
<!--- depositnew.cfm --->

<cfinclude template="security.cfm">
<cfparam name="Deposit" default="">
<cfparam name="DepositDate" default="#Now()#">
<cfparam name="DepositNumber" default="D#DateFormat(Now(),'yyyymmdd')#">
<cfquery name="NeedsDeposited" datasource="#pds#">
	SELECT A.FirstName, A.LastName, A.AccountID, T.TransID, 
	T.Credit, T.PayType, T.DateTime1, T.ChkNumber 
	FROM Transactions T, Accounts A 
	WHERE T.AccountID = A.AccountID 
	AND T.DepositedYN = 0 
	AND T.Credit > 0 
	AND (T.PayType = 'check' 
		  OR T.PayType = 'cash')
	ORDER BY A.LastName, A.FirstName, T.DateTime1 
</cfquery>

<cfsetting enablecfoutputonly="no">

<html>
<head>
<title>Check/Cash Deposit</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="5" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Check/Cash Deposit</font></th>
	</tr>
	<tr>
		<th colspan="5" bgcolor="#thclr#">Select the payments to include in this deposit.</th>
	</tr>
</cfoutput>
<form method="post" action="depositnew2.cfm">
	<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right" colspan="2">Deposit Date</td>
			<td colspan="3"><input type="text" name="DepositDate" size="15" value="#LSDateFormat(DepositDate,'#DateMask1#')#"></td>
		</tr>
		<tr bgcolor="#tdclr#">
			<td align="right" bgcolor="#tbclr#" colspan="2">Deposit Number</td>
			<td colspan="3"><input type="text" name="DepositNumber" size="15" value="#DepositNumber#"></td>
		</tr>
	</cfoutput>
	<cfif NeedsDeposited.RecordCount Is 0>
		<cfoutput>
			<tr>
				<td colspan="5" bgcolor="#tbclr#">Nothing to deposit at this time.</td>
			</tr>
		</cfoutput>
	<cfelse>
		<cfoutput query="NeedsDeposited">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" checked <cfif ListFind(Deposit,TransID)>checked</cfif> name="Deposit" value="#TransID#"></th>
				<td><a href="custinf1.cfm?accountid=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
				<td>#LSDateFormat(DateTime1, '#datemask1#')#</td>
				<td align="right">#LSCurrencyFormat(credit)#</td>
				<td>#PayType#<cfif Trim(ChkNumber) Is Not ""> #ChkNumber#</cfif></td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="5"><input type="image" name="VerifyDeposit" src="images/continue.gif" border="0"></th>
		</tr>
	</cfif>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   