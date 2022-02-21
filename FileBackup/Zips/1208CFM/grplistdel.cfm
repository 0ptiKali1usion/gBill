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
</cfif>

<cfsetting enablecfoutputonly="No">
 