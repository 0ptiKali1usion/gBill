<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- List of customers not connected to a plan. --->
<!---	4.0.0 12/05/00 --->
<!--- unassignplan.cfm --->

<cfinclude template="security.cfm">
<cfquery name="CleanUp" datasource="#pds#">
	DELETE FROM GrpLists 
	WHERE ReportID = 33 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 33 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="CreateReport" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, TextField, AdminID, ReportID, ReportTitle, CreateDate)
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
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 33 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG) 
			VALUES 
			(33, #MyAdminID#, 'unassigndom2.cfm', 'edit.gif')
		</cfquery>
	</cfif>
	<cfset SendReportID = 33>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 33 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone,Plan">
	<cfset SendFields = "Name,Address,Company,Phone,TextField">
	<cfset NoMatchMess = "There are currently no unassigned customers">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
<cfelse>
	<cfset SendReportID = 33>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone,Plan">
	<cfset SendFields = "Name,Address,Company,Phone,TextField">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
 