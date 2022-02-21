<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 09/21/99 --->
<!--- domainrep.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 21 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfquery name="PrivDomains" datasource="#pds#">
		INSERT INTO GrpLists 
		(Address, AccountID, AccntPlanID, ReportID, AdminID, ReportTitle, CreateDate)
		SELECT D.DomainName, D.AccntLimit, D.DomainID, 21, #MyAdminID#, 'Private Domains Limit vs Used', #Now()# 
		FROM Domains D 
		WHERE D.PrivateYN = 1 
		<cfif DomainID Is Not 0>
			AND D.DomainID In (#DomainID#) 
		</cfif>
		ORDER BY D.DomainName 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT GrpListID, AccntPlanID 
		FROM GrpLists 
		WHERE ReportID = 21 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfloop query="UpdData">
		<cfquery name="CountAccnts" datasource="#pds#">
			SELECT count(AccntPlanID) as cnt 
			FROM AccntPlans 
			WHERE AuthDomainID = #AccntPlanID# 
			OR FTPDomainID = #AccntPlanID# 
			OR EMailDomainID = #AccntPlanID# 
		</cfquery>
		<cfquery name="UpdCount" datasource="#pds#">
			UPDATE GrpLists SET 
			CurBal = #CountAccnts.cnt#, 
			ReportURLID2 = #CountAccnts.cnt# 
			WHERE GrpListID = #GrpListID#
		</cfquery>
	</cfloop>
	<cfquery name="SetResults" datasource="#pds#">
		UPDATE GrpLists SET 
		CurPercent = (CurBal/AccountID)*100
		WHERE ReportID = 21 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReportID = 21>
	<cfset LetterID = 0>
	<cfset ReturnPage = "domainrep.cfm">
	<cfset SendHeader = "Domain Name,Limit,Total,Used">
	<cfset SendFields = "Address,AccountID,ReportURLID2,CurPercent">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfquery name="CheckPriv" datasource="#pds#">
	SELECT DomainID, DomainName 
	FROM Domains 
	WHERE PrivateYN = 1
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 21 
	AND AdminID = #MyAdminID#
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Private Domains Report</TITLE>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Private Domains Report</font></th>
	</tr>
</cfoutput>
<cfif CheckPriv.Recordcount Is 0>
	<tr>
		<cfoutput>
			<td bgcolor="#tbclr#" colspan="2">There are no private domains.</td>
		</cfoutput>
	</tr>
<cfelseif CheckFirst.Recordcount GT 0>
	<tr>
		<form method="post" action="grplist.cfm">
			<input type="hidden" name="ReportID" value="21">
			<input type="hidden" name="LetterID" value="0">
			<input type="hidden" name="ReturnPage" value="domainrep.cfm">
			<input type="hidden" name="SendHeader" value="Domain Name,Limit,Total,Used">
			<input type="hidden" name="SendFields" value="Address,AccountID,ReportURLID2,CurPercent">
			<th><input type="image" src="images/viewlist.gif" border="0"></th>
		</form>
		<form method="post" action="domainrep.cfm">
			<th><input type="image" name="StartOver" src="images/changecriteria.gif" border="0"></th>
		</form>
	</tr>
<cfelse>
	<cfoutput>
		<tr>
			<th bgcolor="#thclr#" colspan="2">Select the domains for the report.</th>
		</tr>
		<tr bgcolor="#tdclr#">
	</cfoutput>
	<form method="post" action="domainrep.cfm?RequestTimeout=500">
		<td colspan="2"><select name="DomainID" size="10" multiple>
			<option selected value="0">All Domains
			<cfloop query="CheckPriv">
				<cfoutput><option value="#DomainID#">#DomainName#</cfoutput>
			</cfloop>
			<option value="">______________________________
		</select></td>
	</tr>
	<tr>
		<th colspan="2"><input type="image" src="images/viewlist.gif" name="CreateReport" border="0"></th>
	</tr>
	</form>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
        