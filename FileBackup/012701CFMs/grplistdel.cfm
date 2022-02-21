<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 08/18/00 --->
<!--- grplistdel.cfm --->

<cfset securepage = "listplan.cfm">
<cfinclude template="security.cfm">

<cfif ReportID Is 30>
	<cfquery name="GetWho" datasource="#pds#">
		UPDATE Accounts SET 
		NoAuto = 0 
		WHERE AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE GrpListID In (#DelGrpListID#)
			)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName + ' ' + LastName As FullName 
			FROM Accounts 
			WHERE AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE GrpListID In (#DelGrpListID#)
			)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Edited Customer Info',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following from the auto deactivate list: #ValueList(GetWhoName.FullName)#.')
		</cfquery>
	</cfif>	
</cfif>

<cfsetting enablecfoutputonly="No">
 