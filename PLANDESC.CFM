<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Plan Description page for Account Wizard. --->
<!--- 4.0.0 10/06/99 --->
<!--- plandesc.cfm --->

<cfquery name="PlanInfo" datasource="#pds#">
	SELECT OSPlanDisplay, AWPlanDisplay, PlanDesc 
	FROM Plans 
	WHERE PlanID = #PlanID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Plan Description</title>
</head>
<cfoutput>
<body #colorset# OnBlur="self.close()">
<center>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#PlanInfo.PlanDesc#</font></th>
	</tr>
	<cfif (IsDefined("MyAdminID")) AND (Trim(PlanInfo.AWPlanDisplay) Is Not "")>
		<tr>
			<td bgcolor="#tbclr#">#PlanInfo.AWPlanDisplay#</td>
		</tr>
	</cfif>
	<cfif Trim(PlanInfo.OSPlanDisplay) Is Not "">
		<tr>
			<td bgcolor="#tbclr#">#PlanInfo.OSPlanDisplay#</td>
		</tr>
	</cfif>
</cfoutput>
</table>
</center>
</body>
</html>
 