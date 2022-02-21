<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page starts the check debit output file process. --->
<!--- 4.0.0 04/27/00 
		3.4.0 06/16/99 Fixed error when the header has no output.
		3.2.0 09/08/98 --->
<!--- cdoutput.cfm --->

<cfquery name="CDValues" datasource="#pds#">
	SELECT * 
	FROM CustomCDOutput 
	WHERE UseTab = 6 
</cfquery>
<cfloop query="CDValues">
	<cfset "#FieldName1#" = Description1>
</cfloop>
<cfparam name="thecdfile" default="cdebit.txt">
<cfparam name="cdoutpath" default="c:\">
<cfparam name="cddateformat" default="YYYYMMDD">
<cfparam name="cdtimeformat" default="hhmm">
<cfparam name="cdseqid" default="Z">
<cfparam name="cdminbaldue" default="0.01">

<cffile action="WRITE" file="#cdoutpath##TheCDFile#" output="1">
<cffile action="DELETE" file="#cdoutpath##TheCDFile#">
<cfset myoutput = "">

<cfloop index="B5" from="1" to="2">
	<cfquery name="thefields" datasource="#pds#">
		SELECT * FROM CustomCDOutput 
		WHERE usetab = #B5#  
		AND useyn = 1 
		ORDER BY startorder
	</cfquery>
	<cfloop query="thefields">
		<cfset len1 = endorder - startorder + 1>
		<cfset thestring = "#fieldname1#">
	   <cfif thestring contains "date">
		   <cfset thestring = LSDateFormat(Now(), '#cddateformat#')>
	   <cfelseif thestring contains "time">
		   <cfset thestring = TimeFormat(Now(), '#cdtimeformat#')>
	   <cfelseif thestring contains "cdsequenceid">
		   <cfset thestring = cdseqid>
		<cfelseif thestring contains "day">
			<cfset thestring = DayOfYear(Now())>
	   </cfif>
		<cfset charlen = endorder - startorder + 1>
		<cfset thestring = Left("#thestring#",#charlen#)>
		<cfif pjustify is "N">
			<cfset thejustify = "R">
		<cfelse>
			<cfset thejustify = pjustify>
		</cfif>
		<cf_gspadchar pvalue="#thestring#" padchar="#padchar#"
		justify="#thejustify#" pwidth="#len1#">
		<cfset myoutput = myoutput & newvalue>
	</cfloop>
	<cfif (B5 is 1) AND (thefields.recordcount gt 0)>
		<cfset myoutput = myoutput & "
">
	</cfif>
</cfloop>
<cfif thefields.recordcount is 0>
	<cfset numchars = Len(myoutput) - 1>
	<cfif numchars gt 0>
		<cfset myoutput = Left("#myoutput#","#numchars#")>
	</cfif>
</cfif>

<cffile action="WRITE" file="#cdoutpath##TheCDFile#"
output="#myoutput#">

<cfquery name="checkdebiters" datasource="#pds#">
	SELECT AP.AccountID, P.BankName as CheckD1, P.BankAddress as CheckD2, 
	P.RouteNumber as CheckD3, P.AccntNumber as CheckD4, P.NameOnAccnt as CheckD5, 
	P.CheckDigit, A.FirstName, A.LastName, Sum([Debit]-[Credit]) AS Total, 
	Convert(decimal(8,2),(Sum(debit-credit))) as bal 
	FROM Accounts A, AccntPlans AP, PayByCD P, Transactions T 
	WHERE A.AccountID = AP.AccountID 
	AND AP.AccntPlanID = P.AccntPlanID 
	AND AP.AccntPlanID = T.AccntPlanID 
	AND AP.PayBy = 'CD' 
	GROUP BY AP.AccountID, P.BankName, P.BankAddress, P.RouteNumber, P.AccntNumber, 
	P.NameOnAccnt, P.CheckDigit, A.FirstName, A.LastName 
	HAVING Sum(Debit-Credit) > #CDMinBalDue# 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Check Debit Customers</TITLE>
<cfinclude template="coolsheet.cfm"></head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<center>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Check Debit Output</font></th>
	</tr>
	<form method=post action="cdoutput2.cfm?srow=1">
		<tr>
			<td bgcolor="#tbclr#">There are #CheckDebiters.RecordCount# records to process.</td>
		</tr>
		<tr>
			<th><input type="image" name="output" src="images/beginoutput.gif" border="0"></th>
		</tr>
	</form>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 