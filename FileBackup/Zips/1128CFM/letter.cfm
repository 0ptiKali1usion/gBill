<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Displays the letter to be sent. --->
<!--- letter.cfm --->

<cfquery name="GetInfo" datasource="#pds#">
	SELECT EMailMessage, EMailSubject 
	FROM Integration 
	WHERE IntID = #LetterID# 
</cfquery>
<cfset LocAccountID = ID>
<cfinclude template="runvarvalues.cfm">
<cfset LocSubject = ReplaceList("#GetInfo.EMailSubject#","#FindList#","#ReplList#")>
<cfset LocMessage = ReplaceList("#GetInfo.EMailMessage#","#FindList#","#ReplList#")>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Preview Letter</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset# onblur="self.close()"></cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">E-Mail Preview</font></th>
	</tr>
	<tr bgcolor="#tbclr#" valign="top">
		<td align="right">Subject</td>
		<td>#LocSubject#</td>
	</tr>
	<tr bgcolor="#tbclr#" valign="top">
		<td align="right">Message</td>
		<td><pre>#LocMessage#</pre></td>
	</tr>
</cfoutput>
</table>
</center>
</body>
</html>
 