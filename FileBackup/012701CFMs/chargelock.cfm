<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 03/03/00 --->
<!--- chargelock.cfm --->
<!--- if the setup value is 0, then it is OK to lock it and proceed... --->
<cfset GoBack = 0>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfif meth eq "lock">
	<cfquery name="FirstCheck" datasource="#pds#">
   	SELECT UseYN 
		FROM CustomCCOutput 
		WHERE UseTab = 6 
		AND FieldName1 = 'CCAutoLock'
	</cfquery> 
   <cfif FirstCheck.RecordCount eq 0>
   	<cfquery datasource="#pds#">
      	INSERT INTO CustomCCOutput
			(FieldName1, UseYN, UseTab, CFVarYN) 
			VALUES 
			('CCAutoLock', 0, 6, 1)
		</cfquery>
      <cfquery name="FirstCheck" datasource="#pds#">
			SELECT UseYN 
			FROM CustomCCOutput 
			WHERE UseTab = 6 
			AND FieldName1 = 'CCAutoLock'
      </cfquery> 
	</cfif>
	<cfset StartTime = Now()>
	<cfif FirstCheck.UseYN Is "1">
		<cfloop condition="FirstCheck.UseYN eq 1">
			<cfx_wait SPAN="1">
			<cfquery name="FirstCheck" datasource="#pds#">
				SELECT UseYN 
				FROM CustomCCOutput 
				WHERE UseTab = 6 
				AND FieldName1 = 'CCAutoLock'
			</cfquery> 
			<cfset EndTime = Now()>
			<cfif DateDiff("s",StartTime,EndTime) gt 5>
				<cfquery name="FlagLock" datasource="#pds#">
					UPDATE CustomCCOutput SET 
					UseYN = 1 
					WHERE UseTab = 6 
					AND FieldName1 = 'CCAutoLock'
				</cfquery>
				<cfset GoBack = 1>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfif GoBack Is 0>
		<!--- You shouldnt get here until the tag is available... --->
		<cfset GoBack = 0>
		<cftransaction>
			<cfquery name="FirstCheck" datasource="#pds#">
				SELECT UseYN 
				FROM CustomCCOutput 
				WHERE UseTab = 6 
				AND FieldName1 = 'CCAutoLock'
			</cfquery> 
			<cfif FirstCheck.UseYN eq "0">
				<cfquery name="UpdLock" datasource="#pds#">
					UPDATE CustomCCOutput SET 
					UseYN = 1,
					FieldValue = '#LSDateFormat(now(),'mmm/dd/yyyy')#' 
					WHERE UseTab = 6 
					AND FieldName1 = 'CCAutoLock'
				</cfquery>
			</cfif>
		</cftransaction>
	<cfelse>
		<cfset GoBack = 1>
	</cfif>
<cfelse>
	<cfquery datasource="#pds#">
		UPDATE CustomCCOutput SET 
		UseYN = 0,
		FieldValue = '#LSDateFormat(now(),'mmm/dd/yyyy')#' 
		WHERE UseTab = 6 
		AND FieldName1 = 'CCAutoLock'
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
 