<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page allows viewing the customer email sent. --->
<!---	4.0.0 10/01/99 --->
<!--- viewmail.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="GetHist" datasource="#pds#">
	SELECT H.* 
	FROM BOBHist H 
	WHERE BOBHistID = #BOBHistID# 
</cfquery>

<cfif IsDefined("Resend.x")>
	<cfif Trim(EMailAddr) Is Not "">
		<cfif SendEMail Is 1>
			<cfmail to="#EMailAddr#" from="#EMailFrom#" subject="EMail originally sent on #LSDateFormat(GetHist.ActionDate, '#DateMask1#')#">
#GetHist.ActionEMail#
</cfmail>
		</cfif>
	</cfif>
</cfif>
<cfquery name="EMailToAddr" datasource="#pds#">
	SELECT EMail 
	FROM AccountsEMail E 
	WHERE E.AccountID = #GetHist.AccountID# 
	AND E.PrEMail = 1 
</cfquery>
<cfquery name="GetWho" datasource="#pds#">
	SELECT EMail 
	FROM AccountsEMail 
	WHERE PrEMail = 1 
	AND AccountID = 
		(SELECT AccountID 
		 FROM Admin 
		 WHERE AdminID = #MyAdminID#)
</cfquery>
<cfparam name="EMailFrom" default="#GetWho.EMail#">
<cfparam name="EMailAddr" default="#EMailToAddr.EMail#">

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>View E-Mail</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<cfoutput><input type="hidden" name="accountid" value="#GetHist.AccountID#"></cfoutput>
	<input type="image" src="images/returncust.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#" cellpadding=1>
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">View gBill History E-Mail</font></th>
	</tr>
	<cfif (GetOpts.SendEMail Is 1) AND (GetWho.EMail Is Not "")>
		<tr bgcolor="#tdclr#" valign="top">
			<form method="post" action="viewmail.cfm">
				<input type="hidden" name="EMailFrom" value="#EMailFrom#">
				<input type="hidden" name="BOBHistID" value="#BOBHistID#">
				<td colspan="2"><input type="text" name="EMailAddr" value="#EMailAddr#"> <input type="image" src="images/sendemail.gif" name="Resend" border="0"></td>
			</form>
		</tr>
	</cfif>
</cfoutput>
<cfoutput query="GetHist">
	<tr bgcolor="#tbclr#">
		<td colspan="2">#ActionDesc#</td>
	</tr>
	<tr bgcolor="#tbclr#">
		<td align="right">Date sent</td>
		<td>#LSDateFormat(ActionDate, '#DateMask1#')#</td>
	</tr>
	<tr bgcolor="#tbclr#">
		<td colspan="2"><pre>#ActionEmail#</pre></td>
	</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 