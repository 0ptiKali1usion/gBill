<!-- Version 3.5.0 -->
<!--- 3.5.0 06/26/99 Modifed for the new look
		3.2.0 02/10/99 --->
<!-- customedit.cfm -->

<cfset securepage="customedit.cfm">
<cfinclude template="security.cfm">

<cfquery name="editpages" datasource="#pds#">
	SELECT * FROM CustomPages 
	ORDER BY DirPath, PageName 
</cfquery>

<html>
<head>
<title>Custom Pages Editor</title>
<cfinclude template="coolsheet.cfm"></HEAD>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Custom Page Editor</font></th>
		</tr>
		<tr>
			<form method="post" action="customeditor.cfm">
				<cfif IsDefined("greensoft")>
					<input type="hidden" name="greensoft" value="1">
				</cfif>				
				<td align="right"><input type="image" name="addnew" src="images/addnew.gif" border="0"></td>
			</form>
		</tr>
		<tr>
			<th bgcolor="#thclr#">Customizable Page List</th>
		</tr>
		<form method="post" action="customeditor.cfm">
			<input type="hidden" name="CustomPagesID_Required" value="Please select the Page you want to edit.">
			<cfif IsDefined("greensoft")>
				<input type="hidden" name="greensoft" value="1">
			</cfif>				
			<tr valign="top">
				<td bgcolor="#tdclr#">
	</cfoutput>
					<select name="CustomPagesID" size="10">
						<cfoutput query="editpages">
							<cfif DirLocation is "billpath">
								<option value="#CustomPagesID#">#DirPath##PageName#
							<cfelseif DirLocation is "customtags">
								<option value="#CustomPagesID#">CustomTags#DirPath##PageName#
							<cfelseif DirLocation is "userpage">
								<option value="#CustomPagesID#">#DirPath##PageName#
							</cfif>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<th><input type="image" src="images/edit.gif" name="editone" border="0"></th>
			</tr>
		</form>
	</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

<!-- /customedit.cfm -->


