<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- List of customers not connected to a plan. --->
<!---	4.0.0 12/05/00 --->
<!--- unassignplan.cfm --->

<cfinclude template="security.cfm">
<cfquery name="CleanUp" datasource="#pds#">
	DELETE FROM GrpLists 
	WHERE ReportID = 32 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 32 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="CreateReport" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, AdminID, ReportID, ReportTitle, CreateDate)
		SELECT AccountID, FirstName, LastName, City, Address1, DayPhone, 
		Company, #MyAdminID#, 32, 'Unassinged To A Plan', #Now()# 
		FROM Accounts 
		WHERE AccountID NOT In 
			(SELECT AccountID 
			 FROM AccntPlans) 
	</cfquery>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 32 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG) 
			VALUES 
			(32, #MyAdminID#, 'unassignplan2.cfm', 'edit.gif')
		</cfquery>
	</cfif>
	<cfset SendReportID = 32>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 32 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone">
	<cfset SendFields = "Name,Address,Company,Phone">
	<cfset NoMatchMess = "There are currently no unassigned customers">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
<cfelse>
	<cfset SendReportID = 32>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone">
	<cfset SendFields = "Name,Address,Company,Phone">
	<cfset NoMatchMess = "There are currently no unassigned customers">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
 