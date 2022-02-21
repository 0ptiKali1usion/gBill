<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all the authentication accounts. --->
<!--- 4.0.0 10/23/99 --->
<!--- reportauth.cfm --->

<cfinclude template="security.cfm">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfparam name="page" default="1">
<cfquery name="AllAuths" datasource="#pds#">
	SELECT A.*, C.FirstName, C.LastName 
	FROM AccountsAuth A, Accounts C 
	WHERE A.AccountID = C.AccountID 
	ORDER BY 
	<cfif obid Is "Name">
		C.LastName #obdir#, C.FirstName #obdir# 
	<cfelse>
		#obid# #obdir#
	</cfif>
</cfquery>
<cfif page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllAuths.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllAuths.Recordcount/Mrow)>
<cfset HowWide = 4>
<cfquery name="GetDSValue" datasource="#pds#">
	SELECT * 
	FROM CustomAuthSetup 
	WHERE BOBName = 'AuthODBC' 
	AND CAuthID = 
		(SELECT CAuthID 
		 FROM CustomAuth 
		 WHERE DefaultYN = 1)
</cfquery>
<cfquery name="GetFdValues" datasource="#pds#">
	SELECT *
	FROM CustomAuthSetup 
	WHERE DBType = 'Fd' 
	AND BOBName <> 'acntpassword'
	AND ForTable = 
		(SELECT ForTable 
		 FROM CustomAuthSetup 
		 WHERE BOBName = 'Accounts' 
		 AND CAuthID = 
		 	(SELECT CAuthID 
		 	 FROM CustomAuth 
		 	 WHERE DefaultYN = 1)
		 ) 
	AND CAuthID = 
		(SELECT CAuthID 
		 FROM CustomAuth 
		 WHERE DefaultYN = 1)
	ORDER BY SortOrder
</cfquery>
<cfloop query="GetFdValues">
	<cfset "#BobName#" = DBName>
</cfloop>
<cfif MaxConnectTime Is "">
	<cfset ShowMaxConnect = 0>
<cfelse>
	<cfset ShowMaxConnect = 1>
	<cfset HowWide = HowWide + 1>
</cfif>
<cfif MaxIdleTime Is "">
	<cfset ShowMaxIdle = 0>
<cfelse>
	<cfset ShowMaxIdle = 1>
	<cfset HowWide = HowWide + 1>
</cfif>
<cfif LoginLimit Is "">
	<cfset ShowLoginLimit = 0>
<cfelse>
	<cfset ShowLoginLimit = 1>
	<cfset HowWide = HowWide + 1>
</cfif>
<cfif AcntType Is "">
	<cfset ShowAccntType = 0>
<cfelse>
	<cfset ShowAccntType = 1>
	<cfset HowWide = HowWide + 1>
</cfif>
<cfif CustIPAddress Is "">
	<cfset ShowIPAddress = 0>
<cfelse>
	<cfset ShowIPAddress = 1>
	<cfset HowWide = HowWide + 1>
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Authentication Accounts</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Authentication Accounts</font></th>
	</tr>
</cfoutput>
<cfif AllAuths.Recordcount GT Mrow>
	<tr>
		<form method="post" action="reportauth.cfm">
			<cfoutput>
				<td colspan="#HowWide#"><select name="Page" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AllAuths.LastName[ArrayPoint]>
					<cfelseif obid Is "UserName">
						<cfset DispStr = AllAuths.UserName[ArrayPoint]>
					<cfelseif obid Is "DomainName">
						<cfset DispStr = AllAuths.DomainName[ArrayPoint]>
					<cfelseif obid Is "Filter1">
						<cfset DispStr = AllAuths.Filter1[ArrayPoint]>
					<cfelseif obid Is "IP_Address">
						<cfset DispStr = AllAuths.IP_Address[ArrayPoint]>
					<cfelseif obid Is "Max_Idle">
						<cfset DispStr = AllAuths.Max_Idle[ArrayPoint]>
					<cfelseif obid Is "Max_Connect">
						<cfset DispStr = AllAuths.Max_Connect[ArrayPoint]>
					<cfelseif obid Is "Max_Logins">
						<cfset DispStr = AllAuths.Max_Logins[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllAuths.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="Hidden" name="obid" value="#obid#">
				<input type="Hidden" name="obdir" value="#obdir#">
			</cfoutput>
		</form>
	</tr>
</cfif>
<cfoutput>
	<tr bgcolor="#thclr#" valign="top">
		<th>Edit</th>
		<form method="post" action="reportauth.cfm">	
		<th><input type="Radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" onclick="submit()" id="tab1"><label for="tab1">Name</label></th>
			<cfif obid Is "Name" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportauth.cfm">
			<th><input type="Radio" <cfif obid Is "UserName">checked</cfif> name="obid" value="UserName" onclick="submit()" id="tab2"><label for="tab2">Login</label></th>
			<cfif obid Is "UserName" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportauth.cfm">		
		<th><input type="Radio" <cfif obid Is "DomainName">checked</cfif> name="obid" value="DomainName" onclick="submit()" id="tab3"><label for="tab3">Domain Name</label></th>
			<cfif obid Is "DomainName" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<cfif ShowAccntType Is 1>
			<form method="post" action="reportauth.cfm">		
			<th><input type="Radio" <cfif obid Is "Filter1">checked</cfif> name="obid" value="Filter1" onclick="submit()" id="tab4"><label for="tab4">Type</label></th>
				<cfif obid Is "Filter1" AND obdir Is "asc">
					<input type="Hidden" name="obdir" value="desc">
				</cfif>
			</form>
		</cfif>
		<cfif ShowIPAddress Is 1>
			<form method="post" action="reportauth.cfm">		
			<th><input type="Radio" <cfif obid Is "IP_Address">checked</cfif> name="obid" value="IP_Address" onclick="submit()" id="tab5"><label for="tab5">IP</label></th>
				<cfif obid Is "IP_Address" AND obdir Is "asc">
					<input type="Hidden" name="obdir" value="desc">
				</cfif>
			</form>
		</cfif>
		<cfif ShowMaxIdle Is 1>
			<form method="post" action="reportauth.cfm">		
			<th><input type="Radio" <cfif obid Is "Max_Idle">checked</cfif> name="obid" value="Max_Idle" onclick="submit()" id="tab6"><label for="tab6">Idle</label></th>
				<cfif obid Is "Max_Idle" AND obdir Is "asc">
					<input type="Hidden" name="obdir" value="desc">
				</cfif>
			</form>
		</cfif>
		<cfif ShowMaxConnect Is 1>
			<form method="post" action="reportauth.cfm">		
			<th><input type="Radio" <cfif obid Is "Max_Connect">checked</cfif> name="obid" value="Max_Connect" onclick="submit()" id="tab7"><label for="tab7">Connect</label></th>
				<cfif obid Is "Max_Connect" AND obdir Is "asc">
					<input type="Hidden" name="obdir" value="desc">
				</cfif>
			</form>
		</cfif>
		<cfif ShowLoginLimit Is 1>
			<form method="post" action="reportauth.cfm">		
			<th><input type="Radio" <cfif obid Is "Max_Logins">checked</cfif> name="obid" value="Max_Logins" onclick="submit()" id="tab8"><label for="tab8">Logins</label></th>
				<cfif obid Is "Max_Logins" AND obdir Is "asc">
					<input type="Hidden" name="obdir" value="desc">
				</cfif>
			</form>
		</cfif>
	</tr>
</cfoutput>
<cfoutput query="AllAuths" startrow="#Srow#" maxrows="#MaxRows#">
	<tr bgcolor="#tbclr#" valign="top">
		<form method="post" action="accntmanage4.cfm">
			<th bgcolor="#tdclr#"><input type="Radio" name="AuthID" value="#AuthID#" onclick="submit()"></th>
			<input type="hidden" name="ReturnTo" value="reportauth.cfm">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="page" value="#page#">
			<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
		</form>
		<td><a href="custinf1.cfm?accountid=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
		<td>#UserName#</td>
		<td>#DomainName#</td>
		<cfif ShowAccntType Is 1>
			<td>#Filter1#</td>
		</cfif>
		<cfif ShowIPAddress Is 1>
			<td>#IP_Address#</td>
		</cfif>
		<cfif ShowMaxIdle Is 1>
			<td align="right">#Max_Idle#</td>
		</cfif>
		<cfif ShowMaxConnect Is 1>
			<td align="right">#Max_Connect#</td>
		</cfif>
		<cfif ShowLoginLimit Is 1>
			<td align="right">#Max_Logins#</td>
		</cfif>
	</tr>
</cfoutput>
<cfif AllAuths.Recordcount GT Mrow>
	<tr>
		<form method="post" action="reportauth.cfm">
			<cfoutput>
				<td colspan="#HowWide#"><select name="Page" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AllAuths.LastName[ArrayPoint]>
					<cfelseif obid Is "UserName">
						<cfset DispStr = AllAuths.UserName[ArrayPoint]>
					<cfelseif obid Is "DomainName">
						<cfset DispStr = AllAuths.DomainName[ArrayPoint]>
					<cfelseif obid Is "Filter1">
						<cfset DispStr = AllAuths.Filter1[ArrayPoint]>
					<cfelseif obid Is "IP_Address">
						<cfset DispStr = AllAuths.IP_Address[ArrayPoint]>
					<cfelseif obid Is "Max_Idle">
						<cfset DispStr = AllAuths.Max_Idle[ArrayPoint]>
					<cfelseif obid Is "Max_Connect">
						<cfset DispStr = AllAuths.Max_Connect[ArrayPoint]>
					<cfelseif obid Is "Max_Logins">
						<cfset DispStr = AllAuths.Max_Logins[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllAuths.Recordcount#</cfoutput>
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
 