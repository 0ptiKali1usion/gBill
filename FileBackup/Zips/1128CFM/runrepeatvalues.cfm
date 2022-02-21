<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the page that sets the variables for the scripts. 
		Optional Parameters
			LocAccountID
			LocScriptId			
--->
<!--- 4.0.0 08/28/99 --->
<!--- RunRepeatValues.cfm --->

<cfquery name="GetScript" datasource="#pds#">
	SELECT CustomSQL, CustomDS, EMailRepeatMsg
	FROM Integration 
	WHERE IntID = #LocScriptID# 
</cfquery>
<cfset LocRepeatMsg = "">
<cfset LocMessag = "">
<cfset TheRepeatStr = GetScript.EMailRepeatMsg>
<cfset LocCusODBC = ReplaceList("#GetScript.CustomDS#","#FindList#","#ReplList#")>
<cfset LocCustSQL = ReplaceList("#GetScript.CustomSQL#","#FindList#","#ReplList#")>
<cfif Trim(LocCusODBC) Is Not "" AND Trim(LocCustSQL) Is Not "">
	<cfquery name="CustomVariables" datasource="#LocCusODBC#">
		#LocCustSQL#
	</cfquery>
	<cfquery name="PerRepeatValues" datasource="#pds#">
		SELECT UseText 
		FROM IntVariables 
		WHERE CustomYN = #LocScriptID# 
		ORDER BY UseText 
	</cfquery>
	<cfset LoopCount = 0>
	<cfloop query="CustomVariables">
		<cfset TheNewFindList = TheFindList>
		<cfset TheNewReplList = TheReplList>
		<cfset LoopCount = LoopCount + 1>
		<cfloop query="PerRepeatValues">
			<cfset TheNewFindList = ListAppend(TheNewFindList,UseText)>
			<cfset LkVl = Replace("#UseText#","%","per")>
			<cfset NwVl = Evaluate("CustomVariables.#LkVl#[LoopCount]")>
			<cfif Trim(NwVl) Is "">
				<cfset NwVl = ")*N/A*(">
			</cfif>
			<cfset TheNewReplList = ListAppend(TheNewReplList,NwVl)>
		</cfloop>					
		<cfset LocRepeatMsg = LocRepeatMsg & ReplaceList("#TheRepeatStr#","#TheNewFindList#","#TheNewReplList#")>
		<cfset LocRepeatMsg = Replace(LocRepeatMsg,")*N/A*(","","All")>
	</cfloop>
	<cfset LocMessag = LocMessag & "
#LocRepeatMsg#">
</cfif>

<cfset RepeatMessage = LocMessag>

<cfsetting enablecfoutputonly="no">
    
