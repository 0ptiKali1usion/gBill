<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Save a report. --->
<!--- commsave.cfm --->

<cfset securepage="commreport.cfm">
<cfinclude template="security.cfm">

<cfquery name="ReportInfo" datasource="#pds#">
	SELECT * 
	FROM CommReport 
	WHERE ReportID = #ReportID# 
</cfquery>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Commission Report</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Save Commission Report</font></th>
	</tr>
</cfoutput>
	<form method="post" action="commreport.cfm">
		<cfoutput query="ReportInfo">
			<tr>
				<td align="right" bgcolor="#tbclr#">ReportTitle</td>
				<td bgcolor="#tdclr#"><input type="Text" name="ReportTitle" value="#ReportTitle#" size="35" maxlength="150"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Date Paid</td>
				<cfif PaidDate Is "">
					<cfset TheDate = Now()>
				<cfelse>
					<cfset TheDate = PaidDate>
				</cfif>
				<td bgcolor="#tdclr#"><input type="Text" name="PaidDate" value="#LSDateFormat(TheDate, '#DateMask1#')#" size="15"></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Memo</td>
				<td bgcolor="#tdclr#"><textarea cols="35" rows="6" name="ReportMemo">#ReportMemo#</textarea></td>
			</tr>
			<tr>
				<th colspan="2"><input type="Image" border="0" src="images/saverep.gif" name="SaveMe"></th>
			</tr>
			<input type="Hidden" name="ReportID" value="#ReportID#">
		</cfoutput>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
