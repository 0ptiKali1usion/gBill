<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page loads the values for Authentication. --->
<!---	4.0.0 09/16/99 
		3.5.0 06/29/99 
		3.2.0 09/08/98
		3.1.0 08/12/98 --->
<!--- CfAuthValues.cfm --->

<cfquery name="getvalues" datasource="#pds#">
	SELECT * 
	FROM CustomAuthSetup 
	WHERE CAuthID 
		<cfif IsDefined("SendCAuthID")>
			= #SendCAuthID# 
		<cfelse>
			= (SELECT CAuthID 
			 	FROM CustomAuth 
				WHERE DefaultYN = 1)
		</cfif>
</cfquery>

<cfloop query="getvalues">
<cfset "#BobName#" = #DBName#>
</cfloop>

<cfsetting enablecfoutputonly="no">
 