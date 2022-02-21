<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- unassigned.cfm --->
<cfinclude template="security.cfm">

<cfquery name="CleanUp" datasource="#pds#">
	DELETE FROM GrpLists 
	WHERE ReportID = 31 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 31 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="CreateReport" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, AdminID, ReportID, ReportTitle, CreateDate)
		SELECT AccountID, FirstName, LastName, City, Address1, DayPhone, 
		Company, #MyAdminID#, 31, 'Unassinged Signups', #Now()# 
		FROM Accounts 
		WHERE SalesPersonID Is Null 
		OR SalesPersonID NOT In 
			(SELECT AdminID 
			 FROM Admin)		
	</cfquery>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 31 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG) 
			VALUES 
			(31, #MyAdminID#, 'unassigned2.cfm', 'edit.gif')
		</cfquery>
	</cfif>
	<cfset SendReportID = 31>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 31 
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
	<cfset SendReportID = 31>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone">
	<cfset SendFields = "Name,Address,Company,Phone">
	<cfset NoMatchMess = "There are currently no unassigned customers">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
  