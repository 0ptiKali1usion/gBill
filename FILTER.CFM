<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Filter maintenance --->
<!--- 4.0.1 02/08/01 Added new feature for On Load.
		4.0.0 07/29/99 --->
<!-- filters.cfm -->
<cfif IsDefined("OnLoadFilterID")>
	<cfquery name="Reset" datasource="#pds#">
		UPDATE Filters SET 
		OnLoadPage = 0 
		WHERE AdminID = #MyAdminID# 
		<cfif IsDefined("ReportID")>
			AND ReportID = #ReportID# 
		<cfelseif IsDefined("LetterID")>
			AND LetterID = #LetterID#
		</cfif>
	</cfquery>
	<cfquery name="Update" datasource="#pds#">
		UPDATE Filters SET 
		OnLoadPage = 1 
		WHERE FilterID = #OnLoadFilterID#
	</cfquery>
</cfif>
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
<cfquery name="CheckForOnLoad" datasource="#pds#">
	SELECT RepID 
	FROM Reports 
	<cfif IsDefined("ReportID")>
		WHERE ReportID = #ReportID# 
	<cfelseif IsDefined("LetterID")>
		WHERE LetterID = #LetterID# 
	</cfif>
</cfquery>
<cfif CheckForOnLoad.RecordCount GT 0>
	<cfset HowWide = 3>
<cfelse>
	<cfset HowWide = 2>
</cfif>
<cfsetting enablecfoutputonly="no" showdebugoutput="no">
<html>
<head>
<title>Filters</title>
</head>
<cfif AllFilters.RecordCount Is 0>
	<cfoutput><body #colorset# onload="window.opener.location.reload(true);self.close()"></cfoutput>
<cfelseif IsDefined("DelSelected.x") AND IsDefined("FilterID")>
	<cfoutput><body #colorset# onload="window.opener.location.reload(true)"></cfoutput>
<cfelse>
	<cfoutput><body #colorset#></cfoutput>
</cfif>
<cfoutput>
<form method="post" name="closewindow" action="filter.cfm" onSubmit="window.close()">
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
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Filters</font></th>
	</tr>
	<tr bgcolor="#thclr#">
		<cfif CheckForOnLoad.RecordCount GT 0>
			<th>On Load</th>
		</cfif>
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
				<cfif CheckForOnLoad.RecordCount GT 0>
					<th bgcolor="#tdclr#"><input type="radio" <cfif OnLoadPage Is 1>checked</cfif> name="OnLoadFilterID" value="#FilterID#" onClick="submit()"></th>
				</cfif>
				<td bgcolor="#tbclr#">#FilterName#</td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="FilterID" value="#FilterID#"></th>
			</tr>
		</cfoutput>
		<tr>
			<cfoutput>
				<th colspan="#HowWide#"><input type="image" src="images/delete.gif" border="0" name="DelSelected"></th>
			</cfoutput>
		</tr>
	</form>
</table>
</center>
</body>
</html>    