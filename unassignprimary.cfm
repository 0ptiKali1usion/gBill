<cfsetting enablecfoutputonly="yes">

<!--- Version 4.0.0 --->
<!---	4.0.0 12/28/00 --->
<!--- unassignprimary.cfm --->
<cfinclude template="security.cfm">

<cfquery name="CleanUp" datasource="#pds#">
	DELETE FROM GrpLists 
	WHERE ReportID = 36 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CleanUp2" datasource="#pds#">
	DELETE FROM GrpListInfo 
	WHERE ReportID = 36 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 36 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="CreateReport" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, AdminID, ReportID, ReportTitle, ReportTab, TabType, CreateDate)
		SELECT AccountID, FirstName, LastName, City, Address1, DayPhone, 
		Company, #MyAdminID#, 36, 'Problem EMail', 'No Primary', 2, #Now()# 
		FROM Accounts 
		WHERE AccountID NOT In 
			(SELECT AccountID 
			 FROM AccountsEMail 
			 WHERE PrEMail = 1) 
		AND AccountID In 
			(SELECT AccountID 
			 FROM AccountsEMail)
	</cfquery>
	<cfquery name="CreateReport2" datasource="#pds#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, AdminID, ReportID, ReportTitle, ReportTab, TabType, CreateDate)
		SELECT AccountID, FirstName, LastName, City, Address1, DayPhone, 
		Company, #MyAdminID#, 36, 'Problem EMail', 'Multiple Primary', 2, #Now()# 
		FROM Accounts 
		WHERE AccountID In 
			(SELECT AccountID 
			 FROM AccountsEMail 
			 WHERE PrEMail = 1 
			 GROUP BY AccountID 
			 HAVING Count(EMailID) > 1 ) 
		AND AccountID In 
			(SELECT AccountID 
			 FROM AccountsEMail)
	</cfquery>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 36 
		AND AdminID = #MyAdminID# 
		AND ReportTab = 'No Primary' 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG,ReportTab) 
			VALUES 
			(36, #MyAdminID#, 'unassignprimary2.cfm', 'edit.gif','No Primary')
		</cfquery>
	</cfif>
	<cfquery name="CheckInfoFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 36 
		AND AdminID = #MyAdminID# 
		AND ReportTab = 'Multiple Primary' 
	</cfquery>
	<cfif CheckInfoFirst.RecordCount Is 0>
		<cfquery name="SetExtraInfo" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG,ReportTab) 
			VALUES 
			(36, #MyAdminID#, 'unassignprimary3.cfm', 'edit.gif','Multiple Primary')
		</cfquery>
	</cfif>
	<cfset SendReportID = 36>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 36 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone">
	<cfset SendFields = "Name,Address,Company,Phone">
	<cfset NoMatchMess = "There are currently no customers without a primary email address.">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
<cfelse>
	<cfset SendReportID = 36>
	<cfset SendLetterID = 0>
	<cfset SendHeader = "Name,Address,Company,Phone">
	<cfset SendFields = "Name,Address,Company,Phone">
	<cfset NoMatchMess = "There are currently no customers without a primary email address.">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
  