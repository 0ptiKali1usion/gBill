<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is run at the top of every page. --->
<!--- 4.0.1 11/21/00 Removed the Add User and Search button if admin does not have permission to those pages.
		4.0.0 10/22/99 
		3.2.0 09/08/98 --->
<!--- header.cfm --->

<cfquery name="GetAdmStyle" datasource="#pds#">
	SELECT Frames 
	FROM Admin 
	WHERE AdminID = #MyAdminID#
</cfquery>
<cfif getadmstyle.frames is "1">
	<cfset noheader = "1">
</cfif>
<cfif Not IsDefined("noheader")>
	<cfquery name="CheckAddUser" datasource="#pds#">
		SELECT Menuitems.Menu, Menuitems.dbmname FROM Menuitems 
		WHERE Menuitems.dbmname = 'account.cfm' 
		AND Menuitems.dbmname In 
   		(SELECT Menuitems.dbmname FROM Menuitems, Connect, Admin, Accounts 
	   	 WHERE Admin.AdminID=Connect.AdminID AND Menuitems.MenuID=Connect.menuid 
	   	 AND Admin.AccountID = Accounts.AccountID AND Admin.AdminID=#MyAdminID#) 
	</cfquery>
	<cfquery name="CheckSearch" datasource="#pds#">
		SELECT Menuitems.Menu, Menuitems.dbmname FROM Menuitems 
		WHERE Menuitems.dbmname = 'lookup1.cfm' 
		AND Menuitems.dbmname In 
   		(SELECT Menuitems.dbmname FROM Menuitems, Connect, Admin, Accounts 
	   	 WHERE Admin.AdminID=Connect.AdminID AND Menuitems.MenuID=Connect.menuid 
	   	 AND Admin.AccountID = Accounts.AccountID AND Admin.AdminID=#MyAdminID#) 
	</cfquery>
	<cfoutput>
	<center>
	<a href="admin.cfm"><IMG SRC="images/buttona.gif" border=0></a><cfif CheckAddUser.RecordCount GT 0><a HREF="account.cfm"><IMG SRC="images/buttonb.gif" border=0></a></cfif><cfif CheckSearch.RecordCount GT 0><a href="lookup1.cfm"><IMG SRC="images/buttonc.gif" border=0></a></cfif><a href="killc.cfm"><IMG SRC="images/buttond.gif" border=0></a><a href="http://www.greensoft.com/billing/help/" target="newwin"><IMG SRC="images/buttone.gif" border=0></a>
	</center>
	</cfoutput>
<cfelse>
   <cfoutput>
	<a href="http://www.greensoft.com/billing/help/" target="newwin"><IMG SRC="images/buttonh.gif" border=0 align="right"></a><br clear="right"><br>
	</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="no">
 