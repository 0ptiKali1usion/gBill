<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 2 of the credit card auth importer. --->
<!--- 4.0.0 10/08/99 
		3.2.0 09/08/98 --->
<!--- ccimport2.cfm --->

<cfset securepage = "ccimport.cfm">
<cfinclude template="security.cfm">

<cfquery name="GetFileInfo" datasource="#pds#">
	SELECT OutPutFilePath, OutputFileAs
	FROM CCBatchHist 
	WHERE BatchID = #BatchID#
</cfquery>
<cfif IsDefined("SelectNew.x")>
	<cfset ImportFilePath = ImportFilePath>
	<cfset ImportFileName = ImportFileName>
<cfelse>
	<cfset ImportFilePath = GetFileInfo.OutPutFilePath>
	<cfset ImportFileName = GetFileInfo.OutputFileAs>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Import CC Batch File</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Import CC Batch</font></th>
	</tr>
	<form method="post" action="ccimport3.cfm">
		<tr>
			<td align="right" bgcolor="#tbclr#">Import Path</td>
			<td bgcolor="#tdclr#"><input type="text" name="ImportFilePath" size="45" value="#ImportFilePath#"></td>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Import File</td>
			<td bgcolor="#tdclr#"><input type="text" name="ImportFileName" size="20" value="#ImportFileName#"></td>
		</tr>
		<tr>
			<th colspan="2"><input type="image" src="images/startimp.gif" name="StartImport" border="0"></th>
		</tr>
		<input type="hidden" name="batchid" value="#BatchID#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  