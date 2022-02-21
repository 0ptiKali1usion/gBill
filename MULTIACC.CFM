<cfsetting enablecfoutputonly="Yes">
<!-- Version 5.0.0 -->
<!--- This page is a list of all the group accounts. --->
<!--- 5.0.0 08/26/99
		3.2.0 09/08/98 --->
<!-- multiacc.cfm -->

<cfinclude template="security.cfm">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfquery name="GroupAccounts" datasource="#pds#">
	SELECT A.LastName, A.FirstName, A.Company, A.AccountID, 
	M.AccountID, Sum(T.Debit - T.Credit) AS Bal, 
	(SELECT Count(AccountID) As GroupM 
	 FROM Multi 
	 WHERE PrimaryID = A.AccountID) As GroupMem 
	FROM Accounts A, Multi M, Transactions T 
	WHERE A.AccountID = T.AccountID 
	And A.AccountID = M.PrimaryID 
	AND M.BillTo = 1 
	GROUP BY A.Login, A.LastName, A.FirstName, A.Company, A.AccountID, M.AccountID 
	ORDER BY <cfif Obid Is "Name">A.LastName #obdir#, A.FirstName #obdir#<cfelse>#obid# #obdir#</cfif>
</cfquery>
<cfparam name="Page" default="1">
<cfif page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = GroupAccounts.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(GroupAccounts.Recordcount/Mrow)>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'Locale'
</cfquery>
<cfset Locale = GetLocale.Value1>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Multiple Accounts</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="6" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Group Accounts</font></th>
	</tr>
</cfoutput>
	<cfif GroupAccounts.Recordcount GT Mrow>
		<tr>
			<form method="post" action="multiacc.cfm">
				<td colspan="6"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * Mrow) - (Mrow -1)>
						<cfif obid Is "Name">
							<cfset DispStr = GroupAccounts.LastName[ArrayPoint]>
						<cfelseif obid Is"Company">
							<cfset DispStr = GroupAccounts.Company[ArrayPoint]>
						<cfelseif obid Is"Bal">
							<cfset DispStr = LSCurrencyFormat(GroupAccounts.Bal[ArrayPoint])>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GroupAccounts.RecordCount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="Hidden" name="obid" value="#obid#">
					<input type="Hidden" name="obdir" value="#obdir#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
<cfoutput>
	<tr>
		<form method="post" action="multiacc.cfm">
			<cfif (obid Is "Name") AND (obdir Is "asc")>
				<input type="hidden" name="obdir" value="desc">
			</cfif>
			<th bgcolor="#thclr#"><input type="radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" id="col1" onclick="submit()"><label for="col1">Name</label></th>
		</form>
		<form method="post" action="multiacc.cfm">
			<cfif (obid Is "Company") AND (obdir Is "asc")>
				<input type="hidden" name="obdir" value="desc">
			</cfif>
			<th bgcolor="#thclr#"><input type="radio" <cfif obid Is "Company">checked</cfif> name="obid" value="Company" id="col2" onclick="submit()"><label for="col2">Company</label></th>
		</form>
		<form method="post" action="multiacc.cfm">
			<cfif (obid Is "bal") AND (obdir Is "asc")>
				<input type="hidden" name="obdir" value="desc">
			</cfif>
			<th bgcolor="#thclr#"><input type="radio" <cfif obid Is "bal">checked</cfif> name="obid" value="bal" id="col3" onclick="submit()"><label for="col3">Balance</label></th>
		</form>
		<th bgcolor="#thclr#">Members</th>
		<th bgcolor="#thclr#">View Members</th>
		<th bgcolor="#thclr#">Payment History</th>
	</tr>
</cfoutput>
<cfoutput query="GroupAccounts" startrow="#Srow#" maxrows="#MaxRows#">
	<tr>
		<td bgcolor="#tbclr#"><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#lastname#, #firstname#</a></td>
		<td bgcolor="#tbclr#">#company#&nbsp;</td>
		<td bgcolor="#tbclr#" align=right><cfif bal LT 0>Credit: </cfif>#LSCurrencyFormat(bal)#</td>
		<td bgcolor="#tbclr#" align="right">#GroupMem#</td>
		<form method=post action="group2.cfm" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >
			<th bgcolor="#tdclr#"><INPUT type="radio" name="AccountID" value="#AccountID#" onclick="submit()"></th>
		</form>
		<form method=post action="pmthist.cfm" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >
			<th bgcolor="#tdclr#"><INPUT type="radio" name="accountid" value="#AccountID#" onclick="submit()"></th>
		</form>
	</tr>
</cfoutput>
	<cfif GroupAccounts.Recordcount GT Mrow>
		<tr>
			<form method="post" action="multiacc.cfm">
				<td colspan="6"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * Mrow) - (Mrow -1)>
						<cfif obid Is "Name">
							<cfset DispStr = GroupAccounts.LastName[ArrayPoint]>
						<cfelseif obid Is"Company">
							<cfset DispStr = GroupAccounts.Company[ArrayPoint]>
						<cfelseif obid Is"Bal">
							<cfset DispStr = LSCurrencyFormat(GroupAccounts.Bal[ArrayPoint])>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GroupAccounts.RecordCount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="Hidden" name="obid" value="#obid#">
					<input type="Hidden" name="obdir" value="#obdir#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
      