<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is called from index.cfm to check for a license file during login.
It also checks to make sure that gBill has not expired and is not on a different server.
--->
<!--- 4.0.0 11/02/99 
		3.5.0 07/02/99
		3.2.0 09/08/98 --->
<!--- login.cfm --->

<cfset tfosneerg = "1">
<cfinclude template="index.cfm">
<cfif IsDefined("remraf") is "No">
	<cflocation url="index.cfm">
	<cfabort>
</cfif>
<cfset TheFileName = Left(GetFileFromPath(HTTP_REFERER),9)>
<cfif TheFileName Is Not "index.cfm">
	<cfsetting enablecfoutputonly="no">
	<cflocation url="index.cfm">
	<cfabort>
</cfif>
<cfif IsDefined("form.login") is "No">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="index.cfm">
	<cfabort>
</cfif>
<cfset thefile = Expandpath("license.cfm")>
<cfsetting enablecfoutputonly="no">
<cfsetting enablecfoutputonly="no">
<cfif FileExists("#thefile#")>
	<cfinclude template="license.cfm">
<cfelse>
	
	<HTML>
	<HEAD>
	<TITLE>License</TITLE>
	<cfinclude template="coolsheet.cfm"></HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" color="#ttfont#">Your license file is missing!</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">You are missing your license file.<br>
			Please contact GreenSoft Solutions, Inc. to obtain your license.<br>
			<a href="http://ibob.greensoft.com/">GreenSoft Customer Login</a><br>
			1-785-843-8683</td>
		</tr>
	</table>
	</cfoutput>
	</center>
	<br><br>
	<font size="1" face="Arial"><A HREF="http://www.greensoft.com/"><IMG SRC="images/poweredby.gif" border=0 alt="Powered by GreenSoft Solutions, Inc."></A><br>
	Copyright GreenSoft Solutions, Inc. 1996, 1997, 1998.<br>All rights reserved.</font></body>
	</BODY>
	</HTML>
	<cfabort>
</cfif>
<cfif IsDefined("expdate")>
   <cfset dateval = DateCompare("#expdate#", "#Now()#")>
   <cfset diff1 = datediff("d", "#Now()#", "#expdate#")>
<cfelse>
   <cfset diff1 = 0>
</cfif>
<cfif IsDefined("greensoft") is "No">
   <cfset wrongs = "Yes">
</cfif>
<cfif wrongs is "Yes">
	<cfsetting enablecfoutputonly="no">
	<HTML>
	<HEAD>
	<TITLE>License</TITLE><cfinclude template="coolsheet.cfm"></HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" color="#ttfont#">Incorrect Server</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">This copy of gBill is not licensed to run on this server.<br>
			Please contact GreenSoft Solutions, Inc. to obtain a correct license.<br>
			<a href="http://ibob.greensoft.com/">GreenSoft Customer Login</a><br>
			1-785-843-8683</td>
		</tr>
	</table>
	</cfoutput>
	</center>
	<br><br>
	<font size="1" face="Arial"><A HREF="http://www.greensoft.com/"><IMG SRC="images/poweredby.gif" border=0 alt="Powered by GreenSoft Solutions, Inc."></A><br>
	Copyright GreenSoft Solutions, Inc. 1996, 1997, 1998.<br>All rights reserved.</font></body>
	</BODY>
	</HTML>
<cfelseif #dateval# lt 0>
	<cfsetting enablecfoutputonly="no">
	<HTML>
	<HEAD>
	<TITLE>License</TITLE>
	<cfinclude template="coolsheet.cfm"></HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" color="#ttfont#">Expired Copy</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">This copy of gBill has expired.<br>
			Please contact GreenSoft Solutions, Inc. to obtain a licensed copy.<br>
			<a href="http://ibob.greensoft.com/">GreenSoft Customer Login</a><br></td>
		</tr>
	</table>
	</cfoutput>
	</center>
	<br><br>
	<font size="1" face="Arial"><A HREF="http://www.greensoft.com/"><IMG SRC="images/poweredby.gif" border=0 alt="Powered by GreenSoft Solutions, Inc."></A><br>
	Copyright GreenSoft Solutions, Inc. 1996, 1997, 1998.<br>All rights reserved.</font></body>
	</BODY>
	</HTML>	
<cfelse>
	<cfsetting enablecfoutputonly="no">
	<CFINCLUDE TEMPLATE="admin.cfm">
</cfif>
 