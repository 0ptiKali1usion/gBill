<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is called at the bottom of every page. --->
<!--- 4.0.0 05/04/00 
		3.2.0 09/08/98 --->
<!--- footer.cfm --->

<cfif IsDefined("noheader") is "No">
	<cfoutput>
	<br>
	<center>
	<font size="1" face="Arial"><a href="admin.cfm">Main Menu</a> | <a HREF="account.cfm">Add User</a> | <a href="lookup1.cfm">Search</a> | <a href="killc.cfm">Logout</a> | <a href="http://www.greensoft.com/billing/help/" target="newwin">Help</a></font>
	</center>
	</cfoutput>
<cfelse>
	<cfoutput>
	<div align="right">
		<font size="1" face="Arial"><a href="http://www.greensoft.com/billing/help/" target="newwin">Help</a></font>
	</div>
	</cfoutput>
</cfif>
<cfoutput>
<div align="left">
<br clear=left>
<BR><BR>
<font size="1" face="Arial"><A HREF="http://www.greensoft.com/"><IMG SRC="images/poweredby.gif" border=0 alt="Powered by GreenSoft Solutions, Inc."></A><br>
Copyright GreenSoft Solutions, Inc. 1996, 1997, 1998, 1999, 2000.<br>All rights reserved.</font>
</cfoutput>

<cfsetting enablecfoutputonly="no">     