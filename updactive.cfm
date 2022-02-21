<cfif GetHist.NoteStatus GT 1>
	<cfset ActiveYN = 1>
<cfelse>
	<cfset ActiveYN = 0>
</cfif>
<cfquery name="UpDActive" datasource="#pds#">
	UPDATE Support SET
	ActiveYN = #ActiveYN#
	WHERE SupportID = #SupportID#
</cfquery>	