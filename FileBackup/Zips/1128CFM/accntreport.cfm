<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Limit Report. --->
<!---	4.0.0 11/02/99 --->
<!--- accntreport.cfm --->

<cfinclude template="security.cfm">

<cfparam name="Tab" default="1">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfparam name="page" default="1">

<cfif Tab is 1>
	<cfquery name="AccountLimits" datasource="#pds#">
		SELECT A.FirstName, A.LastName, A.AccountID, P.AuthNumber As IntNumber, P.PlanDesc, Count(AA.AuthID) As AuID 
		FROM Accounts A, AccntPlans AP, AccountsAuth AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND AP.PlanID <> #DelAccount# 
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.AuthNumber, P.PlanDesc 
		HAVING Count(AA.AuthID) > P.AuthNumber
		ORDER BY 
		<cfif obid Is "Name">
			A.LastName #obdir#, A.FirstName #obdir# 
		<cfelseif obid Is "Limit">
			P.AuthNumber #obdir# 
		<cfelseif obid Is "OverID">
			Count(AA.AuthID) #obdir# 
		<cfelse>
			#obid# #obdir# 
		</cfif>
	</cfquery>
<cfelseif Tab Is 2>
	<cfquery name="AccountLimits" datasource="#pds#">
		SELECT A.FirstName, A.LastName, A.AccountID, P.FTPNumber As IntNumber, P.PlanDesc, Count(AA.FTPID) As AuID 
		FROM Accounts A, AccntPlans AP, AccountsFTP AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND AP.PlanID <> #DelAccount# 
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.FTPNumber, P.PlanDesc 
		HAVING Count(AA.FTPID) > P.FTPNumber
		ORDER BY 
		<cfif obid Is "Name">
			A.LastName #obdir#, A.FirstName #obdir# 
		<cfelseif obid Is "Limit">
			P.FTPNumber #obdir# 
		<cfelseif obid Is "OverID">
			Count(AA.FTPID) #obdir# 
		<cfelse>
			#obid# #obdir# 
		</cfif>
	</cfquery>
<cfelseif Tab Is 3>
	<cfquery name="AccountLimits" datasource="#pds#">
		SELECT A.FirstName, A.LastName, A.AccountID, P.FreeEMails As IntNumber, P.PlanDesc, Count(AA.EMailID) As AuID 
		FROM Accounts A, AccntPlans AP, AccountsEMail AA, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.AccntPlanID = AA.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND AP.PlanID <> #DeactAccount# 
		AND AP.PlanID <> #DelAccount# 
		GROUP BY A.FirstName, A.LastName, A.AccountID, P.FreeEMails, P.PlanDesc 
		HAVING Count(AA.EMailID) > P.FreeEMails 
		ORDER BY 
		<cfif obid Is "Name">
			A.LastName #obdir#, A.FirstName #obdir# 
		<cfelseif obid Is "Limit">
			P.FreeEMails #obdir# 
		<cfelseif obid Is "OverID">
			Count(AA.EMailID) #obdir# 
		<cfelse>
			#obid# #obdir# 
		</cfif>
	</cfquery>
</cfif>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AccountLimits.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AccountLimits.Recordcount/Mrow)>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Account Limit Report</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Accounts Over Limit</font></th>
	</tr>
	<tr>
		<th colspan="4">
			<table border="1">
				<tr>
					<form method="post" action="accntreport.cfm">
						<th bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif Tab Is "1">checked</cfif> name="Tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Authentication</label></th>
						<th bgcolor=<cfif Tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif Tab Is "2">checked</cfif> name="Tab" value="2" onclick="submit()" id="tab2"><label for="tab3">FTP</label></th>
						<th bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif Tab Is "3">checked</cfif> name="Tab" value="3" onclick="submit()" id="tab3"><label for="tab2">E-Mail</label></th>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif AccountLimits.Recordcount GT Mrow>
	<tr>
		<form method="post" action="accntreport.cfm">
			<td colspan="4"><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AccountLimits.LastName[ArrayPoint]>
					<cfelseif obid Is "PlanDesc">
						<cfset DispStr = AccountLimits.PlanDesc[ArrayPoint]>
					<cfelseif obid Is "Limit">
						<cfset DispStr = AccountLimits.IntNumber[ArrayPoint]>
					<cfelseif obid Is "OverID">
						<cfset DispStr = AccountLimits.AuID[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AccountLimits.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="Hidden" name="Tab" value="#Tab#">
				<input type="Hidden" name="obid" value="#obid#">
				<input type="Hidden" name="obdir" value="#obdir#">
			</cfoutput>
		</form>
	</tr>
</cfif>
<cfoutput>
	<tr bgcolor="#thclr#">
		<form method="post" action="accntreport.cfm">
			<th><input type="Radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" onclick="submit()" id="col1"><label for="col1">Name</label></th>
			<cfif (obid Is "Name") AND (obdir Is "asc")>
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
			<input type="Hidden" name="Tab" value="#Tab#">
		</form>
		<form method="post" action="accntreport.cfm">
			<th><input type="Radio" <cfif obid Is "PlanDesc">checked</cfif> name="obid" value="PlanDesc" onclick="submit()" id="col2"><label for="col2">Plan</label></th>
			<cfif (obid Is "PlanDesc") AND (obdir Is "asc")>
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
			<input type="Hidden" name="Tab" value="#Tab#">
		</form>
		<form method="post" action="accntreport.cfm">
			<th><input type="Radio" <cfif obid Is "Limit">checked</cfif> name="obid" value="Limit" onclick="submit()" id="col3"><label for="col3">Limit</label></th>
			<cfif (obid Is "Limit") AND (obdir Is "asc")>
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
			<input type="Hidden" name="Tab" value="#Tab#">
		</form>
		<form method="post" action="accntreport.cfm">
			<th><input type="Radio" <cfif obid Is "OverID">checked</cfif> name="obid" value="OverID" onclick="submit()" id="col4"><label for="col4">Actual</label></th>
			<cfif (obid Is "OverID") AND (obdir Is "asc")>
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
			<input type="Hidden" name="Tab" value="#Tab#">
		</form>
	</tr>
</cfoutput>
<cfoutput query="AccountLimits" startrow="#Srow#" maxrows="#Maxrows#">
	<tr bgcolor="#tbclr#">
		<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
		<td>#PlanDesc#</td>
		<td align="right">#IntNumber#</td>
		<td align="right">#AuID#</td>
	</tr>
</cfoutput>
<cfif AccountLimits.Recordcount GT Mrow>
	<tr>
		<form method="post" action="accntreport.cfm">
			<td colspan="4"><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AccountLimits.LastName[ArrayPoint]>
					<cfelseif obid Is "PlanDesc">
						<cfset DispStr = AccountLimits.PlanDesc[ArrayPoint]>
					<cfelseif obid Is "Limit">
						<cfset DispStr = AccountLimits.IntNumber[ArrayPoint]>
					<cfelseif obid Is "OverID">
						<cfset DispStr = AccountLimits.AuID[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AccountLimits.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="Hidden" name="Tab" value="#Tab#">
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
 