<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the creation of radius accounts. --->
<!--- 4.0.0 09/16/99 
		3.2.0 09/08/98 --->
<!--- cfauthcreate.cfm --->

<cfparam name="CreateAccount" default="0">
<cfquery name="DefaultAuth" datasource="#pds#">
	SELECT CAuthID 
	FROM CustomAuth 
	WHERE DefaultYN = 1 
</cfquery>
<cfparam name="LocCAuthID" default="#DefaultAuth.CAuthID#">
<cfset LocAccountID = CreateAccount>
<cfinclude template="runvarvalues.cfm">
<cfquery name="allauthcreate" datasource="#pds#">
	SELECT * 
	FROM CustomAuthAccount 
	WHERE CAuthID = #LocCAuthID# 
	ORDER BY CAAID 
</cfquery>
<cfquery name="getauthneeded" datasource="#pds#">
	SELECT * 
	FROM CustomAuthSetup 
	WHERE (bobname = 'accounts' 
	OR bobname = 'authodbc' )
	AND CAuthID = #LocCAuthID# 
</cfquery>
<cfloop query="getauthneeded">
	<cfset "#BobName#" = #DBName#>
</cfloop>


<cfset LocAuthSQLStr = "INSERT INTO #accounts# (">
	<cfloop query="AllAuthCreate">
		<cfset LocAuthSQLStr = LocAuthSQLStr  & "#DBFieldName#">
		<cfif AllAuthCreate.CurrentRow Is Not AllAuthCreate.RecordCount>
			<cfset LocAuthSQLStr = LocAuthSQLStr  & " , ">
		</cfif>
	</cfloop>
	<cfset LocAuthSQLStr = LocAuthSQLStr  & ") VALUES (">
	<cfloop query="AllAuthCreate">
			<cfif DataType is "text">
				<cfset LocAuthSQLStr = LocAuthSQLStr  & "*+*#Trim(DataNeed)#*+*">
			<cfelseif DataType is "number">
				<cfset LocAuthSQLStr = LocAuthSQLStr  & "#Trim(DataNeed)#">
			<cfelseif DataType is "date">
				<cfset LocDateValue = CreateODBCDateTime(DataNeed)>
				<cfset LocDateValue = Replace(LocDateValue,"'","*+*","All")>
				<cfset LocAuthSQLStr = LocAuthSQLStr  & "#LocDateValue#">
			</cfif>
			<cfif AllAuthCreate.CurrentRow Is Not AllAuthCreate.RecordCount>
				<cfset LocAuthSQLStr = LocAuthSQLStr  & " , ">
			</cfif>
	</cfloop>
	<cfset LocAuthSQLStr = LocAuthSQLStr  & ")">
	<cfset LocScript = ReplaceList("#LocAuthSQLStr#","#FindList#","#ReplList#")>
	<cftry>
		<cfquery name="IntegrationSQL" datasource="#authodbc#">
			#Replace(LocScript,"*+*","'","All")#
		</cfquery>
		<cfcatch type="Any">
			<cfset Message = "Problem with the integration.">
		</cfcatch>
	</cftry>
<cfsetting enablecfoutputonly="no">
 