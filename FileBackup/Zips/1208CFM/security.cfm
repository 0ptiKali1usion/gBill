<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that performs the security check. --->
<!--- 4.0.0 08/01/99
		3.5.0 06/24/99 --->
<!--- security.cfm --->
<cfset filepath1= ExpandPath(GetFileFromPath("#SCRIPT_NAME#"))>
<cfset dirname1 = GetDirectoryFromPath("#filepath1#")>
<cfset cfmpos = FindNoCase("cfm","#dirname1#") + 3>
<cfset cfmdir = Mid("#dirname1#",1,"#cfmpos#")>
<cfset pagename1 = ReplaceNoCase("#filepath1#","#cfmdir#","")>
<cfset pagename1 = Replace("#pagename1#","\","/")>
<cfparam name="securepage" default="#pagename1#">

<cfquery name="CheckPage2" datasource="#pds#">
	SELECT Menuitems.Menu, Menuitems.dbmname FROM Menuitems
	WHERE Menuitems.dbmname = '#securepage#'
	AND Menuitems.dbmname In 
   	(SELECT Menuitems.dbmname FROM Menuitems, Connect, Admin, Accounts 
	    WHERE Admin.AdminID=Connect.AdminID AND Menuitems.MenuID=Connect.menuid
   	 AND Admin.AccountID = Accounts.AccountID AND Admin.AdminID=#MyAdminID#) 
</cfquery>

<cfsetting enablecfoutputonly="no">

<cfif CheckPage2.recordcount is 0>
	<cfsetting enablecfoutputonly="yes">
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID, ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Unauthorized Access','#StaffMemberName.FirstName# #StaffMemberName.LastName# attempted to access #pagename1#.')
			</cfquery>
		</cfif>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Security Check</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput>
		<body #colorset#>
	</cfoutput>
	<cfinclude template="header.cfm">
	<cfoutput>
	<center>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Security Check</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">You are trying to access #pagename1#</td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">You do not have access to this page.</td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">If this is incorrect please contact the site administrator.</td>
		</tr>
	</table>
	</center>
	</cfoutput>
		<cfinclude template="footer.cfm">
	<cfoutput>
	</body>
	</html>
	</cfoutput>
	<cfabort>
</cfif>
    