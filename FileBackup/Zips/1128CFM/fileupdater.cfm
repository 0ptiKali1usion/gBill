<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that lists the areas to check for new files. --->
<!--- fileupdater.cfm --->

<cfinclude template="security.cfm">

<cfset theURL = "http://updates.greensoft.com/ibob/4x/dirlist.cfm">

<cfhttp url="#theURL#?Unencrypt=4" method="GET">
<cfset strpos = Find("STARTDIRLIST",cfhttp.filecontent) + 13>
<cfset endpos = Find("ENDDIRLIST",cfhttp.filecontent)  -1>
<cfset endpos = endpos - strpos>
<cfset thedirlist = Mid(cfhttp.filecontent,strpos,endpos)>

<cfloop index="B4" list="#thedirlist#">
	<cfset themaindir = ListGetAt(B4,2,";")>
	<cfset theinddir = ListGetAt(B4,3,";")>	
	<cfif themaindir is "billpath">
		<cfif Not DirectoryExists("#billpath##theinddir##OSType#filebackup")>
			<cfdirectory action="create" directory="#billpath##theinddir##OSType#filebackup" mode="777">
		</cfif>
	<cfelseif themaindir is "customtag">
 		<cfset remotedir = ListGetAt(B4,1,";")>
		<cfset dirinfo = ListGetAt(B4,3,";")>
		<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\CustomTags">
		<CFSET TagName="CFMLTagSearchPath">
		<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
			<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="CTAGPATH">
		<cfelse>
			<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="CTAGPATH">
		</cfif>
		<CFSET thetagdir = CTAGPATH & "/">
		<cfif Not DirectoryExists("#billpath##theinddir##OSType#filebackup")>
			<cfdirectory action="create" directory="#thetagdir##OSType#filebackup" mode="777">
		</cfif>
	<cfelse>
		<cfset temp1 = 1>
	</cfif>
</cfloop>
<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<title>File Updater</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>	   
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perfontname#"</cfif> color="#ttfont#">File Updater</font></th>
	</tr>
	<form method="post" action="fileupdater2.cfm?ListFiles=1">
		<tr>
			<td bgcolor="#thclr#"><b>Select a File Group to Check</b></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tdclr#">
</cfoutput>				
				<select name="ThePath" size="10">
					<cfloop index="B5" list="#thedirlist#">
						<cfset thedisplay=ListGetAt(B5,1,";")>
						<cfoutput>
							<option value="#B5#">#thedisplay#
						</cfoutput>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<th><input type="image" src="images/viewlist.gif" name="List" border="0"></th>
		</tr>
	</FORM>
</table>
</center>
<br>
<cfinclude template="footer.cfm">
</body>
</html>
 