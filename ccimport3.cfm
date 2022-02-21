<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 3 of the credit card auth importer. --->
<!--- 4.0.0 10/08/99 --->
<!--- ccimport3.cfm --->

<cfset securepage = "ccimport.cfm">
<cfinclude template="security.cfm">
<cfif FileExists("#ImportFilePath##ImportFileName#")>
	<cfset FileExist = 1>
	<cfquery name="ImportInfo" datasource="#pds#">
		SELECT Description1, FieldName1 
		FROM CustomCCOutput 
		WHERE (FieldName1 = 'CCInputLines' 
				 OR FieldName1 = 'ccinputheadrow')
		AND UseTab = 4 
	</cfquery>
	<cfloop query="ImportInfo">
		<cfset "#FieldName1#" = Description1>
	</cfloop>
	<cffile action="read" File="#ImportFilePath##ImportFileName#" Variable="message">
	<cfset ImportCount = 0>
	<cfloop index="B5" list="#message#" delimiters="
">
		<cfif Trim(B5) Is Not "">
			<cfset ImportCount = ImportCount + 1>
		</cfif>
	</cfloop>
	<cfset ImportCount = ImportCount/CCInputLines>
<cfelse>
	<cfset FileExist = 0>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Import CC Batch</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Import CC Batch</font></th>
	</tr>
</cfoutput>
<cfif FileExist Is 0>
	<tr>
		<cfoutput>
			<td bgcolor="#tbclr#">The file #ImportFileName# does not exist in #ImportFilePath#.<br>
			Click Return to change the file name or path.</td>
		</cfoutput>
	</tr>
	<form method="post" action="ccimport2.cfm">
		<tr>
			<cfoutput>
				<input type="hidden" name="batchid" value="#BatchID#">
				<input type="hidden" name="ImportFilePath" value="#ImportFilePath#">
				<input type="hidden" name="ImportFileName" value="#ImportFileName#">
				<th><input type="image" src="images/return.gif" name="SelectNew" border="0"></th>
			</cfoutput>
		</tr>
	</form>
<cfelse>
	<form method="post" action="ccimport4.cfm?RequestTimeout=300">
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">There are #ImportCount# records to import.<br>
				Click Continue to Import from the batch file.</td>
			</cfoutput>
		</tr>
		<tr>
			<th><input type="image" name="ContinueImport" src="images/continue.gif" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="batchid" value="#BatchID#">
			<input type="hidden" name="ImportFilePath" value="#ImportFilePath#">
			<input type="hidden" name="ImportFileName" value="#ImportFileName#">
		</cfoutput>
	</form>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  