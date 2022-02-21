<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This page handles the Credit Card batch processes. --->
<!---	4.0.0 09/21/99 --->
<!--- ccimport.cfm Report No. 21 LetterID No. 21 --->

<cfinclude template="security.cfm">

<cfquery name="NeedsImported" datasource="#pds#">
	SELECT * 
	FROM CCBatchHist 
	WHERE TransImportDate Is Null 
	<cfif GetOpts.CCViewAll Is 0>
		AND AdminIDExport = #MyAdminID#
	</cfif>
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
<title>Credit Card Batch Import</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Credit Card Batch Import</font></th>
	</tr>
</cfoutput>
<cfif NeedsImported.Recordcount GT 0>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Import</th>
			<th>File Name</th>
			<th>Export Date</th>
			<th>Exported By</th>
		</tr>
	</cfoutput>
	<cfoutput query="NeedsImported">
		<cfif ExportedBy Is "">
			<form method="post" action="ccoutput.cfm">
		<cfelse>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT CCTempID 
				FROM CCAutoTemp 
				WHERE BatchID = #BatchID# 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<form method="post" action="ccimport2.cfm">
			<cfelse>
				<form method="post" action="ccimport4.cfm">
			</cfif>
		</cfif>
			<tr bgcolor="#tbclr#">
				<cfif ExportedBy Is "">
					<td bgcolor="#tdclr#">&nbsp;</td>
					<td bgcolor="#tdclr#"><input type="radio" name="Goto" onclick="submit()">Export</td>
					<td bgcolor="#tdclr#">#OutputFileAs#</td>
					<td bgcolor="#tdclr#">NEEDS EXPORTED</td>
				<cfelse>
					<th bgcolor="#tdclr#"><input type="radio" name="BatchID" value="#BatchID#" onclick="submit()"></th>
					<td>#LSDateFormat(ExportDate, '#DateMask1#')#</td>
					<td>#OutputFileAs#</td>
					<td>#ExportedBy#</td>
				</cfif>
			</tr>
		</form>
	</cfoutput>
<cfelse>
	<tr>	
		<cfoutput>
			<td colspan="4" bgcolor="#tbclr#">There are no pending credit card imports.</td>
		</cfoutput>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  