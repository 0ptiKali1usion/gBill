<cfsetting enablecfoutputonly="yes">
<!-- Version 5.0.0 -->
<!--- Filter maintenance --->
<!--- 5.0.0 07/29/99 --->
<!-- filters.cfm -->
<cfif IsDefined("DelSelected.x") AND IsDefined("FilterID")>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterDomains 
			WHERE FilterID In (#FilterID#)
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPlans 
			WHERE FilterID In (#FilterID#)
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPOPs 
			WHERE FilterID In (#FilterID#)
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterSalesp 
			WHERE FilterID In (#FilterID#)
		</cfquery>
		<cfquery name="ChangeFilter" datasource="#pds#">
			DELETE FROM Filters 
			WHERE FilterID In (#FilterID#)
		</cfquery>
</cfif>
<cfif IsDefined("ReportID")>
	<cfquery name="AllFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID#
	</cfquery>
<cfelseif IsDefined("LetterID")>
	<cfquery name="AllFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE LetterID = #LetterID# 
		AND AdminID = #MyAdminID#
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no" showdebugoutput="no">
<html>
<head>
<title>Filters</title>
</head>
<cfoutput><body #colorset#>
<form method="post" action="filter.cfm" onSubmit="window.close()">
	<cfif IsDefined("ReportID")>
		<input type="hidden" name="ReportID" value="#ReportID#">
	<cfelseif IsDefined("LetterID")>
		<input type="hidden" name="LetterID" value="#LetterID#">
	</cfif>
	<input type="image" src="images/close.gif" name="CloseWindow" border="0">
</form>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Filters</font></th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Filter Name</th>
		<th>Delete</th>
	</tr>
	<form method="post" action="filter.cfm" onSubmit="return confirm('Click Ok to confirm deleting the selected filters.')">
	<cfif IsDefined("ReportID")>
		<input type="hidden" name="ReportID" value="#ReportID#">
	<cfelseif IsDefined("LetterID")>
		<input type="hidden" name="LetterID" value="#LetterID#">
	</cfif>
</cfoutput>
		<cfoutput query="AllFilters">
			<tr>
				<td bgcolor="#tbclr#">#FilterName#</td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="FilterID" value="#FilterID#"></th>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="2"><input type="image" src="images/delete.gif" border="0" name="DelSelected"></th>
		</tr>
	</form>
</table>
</center>
</body>
</html>    