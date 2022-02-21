<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- unassignplan2.cfm --->
<cfset SecurePage = "unassigndom.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("UpdatePlans.x")>
	<cfquery name="UpdDoms" datasource="#pds#">
		UPDATE AccntPlans SET 
		AuthDomainID = #DomainID#, 
		FTPDomainID = #DomainID#, 
		EMailDomainID = #DomainID# 
		WHERE AccountID In 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 33 
			 AND AdminID = #MyAdminID# )
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 33 
		AND AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 33 
			 AND AdminID = #MyAdminID#) 		
	</cfquery>
</cfif>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1','DeactAccount','DelAccount') 
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfquery name="GetDomain" datasource="#pds#">
	SELECT D.DomainName, D.DomainID, Primary1 
	FROM Domains D 
	WHERE D.DomainID In 
		(SELECT DomainID 
		 FROM DomAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY D.DomainName 
</cfquery>
<cfquery name="CheckNow" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 33 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckForMore" datasource="#pds#">
		SELECT A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
		A.Company, P.PlanDesc, #MyAdminID#, 33, 'Unassinged To A Domain', #Now()# 
		FROM Accounts A, AccntPlans AP, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.PlanID = P.PlanID 
		AND A.AccountID In 
			(SELECT AccountID 
			 FROM AccntPlans 
			 WHERE AuthDomainID NOT In 
				(SELECT DomainID 
				 FROM Domains) 
			 OR FTPDomainID NOT In 
				(SELECT DomainID 
				 FROM Domains) 
			 OR EMailDomainID NOT In 
				(SELECT DomainID 
				 FROM Domains)
			)
		UNION 
		SELECT A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
		A.Company, P.PlanDesc, #MyAdminID#, 33, 'Unassinged To A Domain', #Now()# 
		FROM Accounts A, AccntPlans AP, Plans P 
		WHERE A.AccountID = AP.AccountID 
		AND AP.PlanID = P.PlanID 
		AND A.AccountID In 
			(SELECT AccountID 
			 FROM AccntPlans 
			 WHERE AuthDomainID Is NULL 
			 AND FTPDomainID Is NULL 
			 AND EMailDomainID Is NULL) 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Assign Domain</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif CheckNow.RecordCount GT 0>
	<form method="post" action="grplist.cfm">
		<input type="Image" src="images/viewlist.gif" name="GoBack" border="0">
		<input type="Hidden" name="SendReportID" value="33">
		<input type="Hidden" name="SendLetterID" value="0">
		<input type="Hidden" name="SendHeader" value="Name,Address,Company,Phone,Plan">
		<input type="Hidden" name="SendFields" value="Name,Address,Company,Phone,TextField">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Assign Plan</font></th>
	</tr>
</cfoutput>
	<cfif CheckNow.RecordCount GT 0>
		<cfoutput>
			<tr>
				<td colspan="2" bgcolor="#tbclr#">Everyone listed on the report will be assigned the selected domain.</td>
			</tr>
		</cfoutput>
		<form method="post" action="unassigndom2.cfm">
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Domain</td>
			</cfoutput>
				<td><select name="DomainID">
					<cfoutput query="GetDomain">
						<option <cfif Primary1 Is 1>selected</cfif> value="#DomainID#">#DomainName#
					</cfoutput>
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="Image" name="UpdatePlans" src="images/update.gif" border="0"></th>
			</tr>
		</form>
	<cfelse>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">You have assigned all the selected customers.
				<cfif CheckForMore.RecordCount GT 0><br><a href="unassigndom.cfm">Create New List</a></cfif></td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
