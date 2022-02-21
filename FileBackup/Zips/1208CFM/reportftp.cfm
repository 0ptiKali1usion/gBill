<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all the ftp accounts. --->
<!--- 4.0.0 10/23/99 --->
<!--- reportftp.cfm --->

<cfinclude template="security.cfm">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfparam name="page" default="1">
<cfquery name="AllFTPs" datasource="#pds#">
	SELECT A.*, C.FirstName, C.LastName 
	FROM AccountsFTP A, Accounts C 
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
	<cfset Maxrows = AllFTPs.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllFTPs.Recordcount/Mrow)>
<cfset HowWide = 7>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>FTP Accounts</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">FTP Accounts</font></th>
	</tr>
</cfoutput>
<cfif AllFTPs.Recordcount GT Mrow>
	<tr>
		<form method="post" action="reportftp.cfm">
			<cfoutput>
				<td colspan="#HowWide#"><select name="Page" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AllFTPs.LastName[ArrayPoint]>
					<cfelseif obid Is "UserName">
						<cfset DispStr = AllFTPs.UserName[ArrayPoint]>
					<cfelseif obid Is "DomainName">
						<cfset DispStr = AllFTPs.DomainName[ArrayPoint]>
					<cfelseif obid Is "Max_Idle1">
						<cfset DispStr = AllFTPs.Max_Idle1[ArrayPoint]>
					<cfelseif obid Is "Max_Connect1">
						<cfset DispStr = AllFTPs.Max_Connect1[ArrayPoint]>
					<cfelseif obid Is "Start_Dir">
						<cfset DispStr = AllFTPs.Start_Dir[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllFTPs.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="Hidden" name="obid" value="#obid#">
				<input type="Hidden" name="obdir" value="#obdir#">
			</cfoutput>
		</form>
	</tr>
</cfif>
<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Edit</th>
		<form method="post" action="reportftp.cfm">	
		<th><input type="Radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" onclick="submit()" id="tab1"><label for="tab1">Name</label></th>
			<cfif obid Is "Name" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportftp.cfm">
			<th><input type="Radio" <cfif obid Is "UserName">checked</cfif> name="obid" value="UserName" onclick="submit()" id="tab2"><label for="tab2">Login</label></th>
			<cfif obid Is "UserName" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportftp.cfm">		
		<th><input type="Radio" <cfif obid Is "DomainName">checked</cfif> name="obid" value="DomainName" onclick="submit()" id="tab3"><label for="tab3">Domain Name</label></th>
			<cfif obid Is "DomainName" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportftp.cfm">		
		<th><input type="Radio" <cfif obid Is "Max_Idle1">checked</cfif> name="obid" value="Max_Idle1" onclick="submit()" id="tab6"><label for="tab6">Idle</label></th>
			<cfif obid Is "Max_Idle1" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportftp.cfm">		
		<th><input type="Radio" <cfif obid Is "Max_Connect1">checked</cfif> name="obid" value="Max_Connect1" onclick="submit()" id="tab7"><label for="tab7">Connect</label></th>
			<cfif obid Is "Max_Connect1" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
		<form method="post" action="reportftp.cfm">		
		<th><input type="Radio" <cfif obid Is "Start_Dir">checked</cfif> name="obid" value="Start_Dir" onclick="submit()" id="tab8"><label for="tab8">Start Dir</label></th>
			<cfif obid Is "Start_Dir" AND obdir Is "asc">
				<input type="Hidden" name="obdir" value="desc">
			</cfif>
		</form>
	</tr>
</cfoutput>
<cfoutput query="AllFTPs" startrow="#Srow#" maxrows="#MaxRows#">
	<tr bgcolor="#tbclr#" valign="top">
		<form method="post" action="accntftp4.cfm" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >
			<th bgcolor="#tdclr#"><input type="Radio" name="AccountID" value="#AccountID#" onclick="submit()"></th>
			<input type="Hidden" name="FTPID" value="#FTPID#">
			<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
		</form>
		<td><a href="custinf1.cfm?accountid=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
		<td>#UserName#</td>
		<td>#DomainName#</td>
		<td>#Max_Idle1#</td>
		<td>#Max_Connect1#</td>
		<td>#Start_Dir#</td>
	</tr>
</cfoutput>
<cfif AllFTPs.Recordcount GT Mrow>
	<tr>
		<form method="post" action="reportftp.cfm">
			<cfoutput>
				<td colspan="#HowWide#"><select name="Page" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "Name">
						<cfset DispStr = AllFTPs.LastName[ArrayPoint]>
					<cfelseif obid Is "UserName">
						<cfset DispStr = AllFTPs.UserName[ArrayPoint]>
					<cfelseif obid Is "DomainName">
						<cfset DispStr = AllFTPs.DomainName[ArrayPoint]>
					<cfelseif obid Is "Max_Idle1">
						<cfset DispStr = AllFTPs.Max_Idle1[ArrayPoint]>
					<cfelseif obid Is "Max_Connect1">
						<cfset DispStr = AllFTPs.Max_Connect1[ArrayPoint]>
					<cfelseif obid Is "Start_Dir">
						<cfset DispStr = AllFTPs.Start_Dir[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllFTPs.Recordcount#</cfoutput>
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
 