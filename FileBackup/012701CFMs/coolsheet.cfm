<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page runs during the header of every page to set personal appearance of BOB.
--->
<!--- 4.0.0 07/27/99 
		3.2.0 09/08/98 --->
<!--- coolsheet.cfm --->

<cfparam name="perfontname" default="arial">
<cfparam name="perfontsize" default="Medium">
<cfif IsDefined("MyAdminID")>
	<cfif Trim(GetOpts.PerFontName) neq "">
		<cfset perfontname=GetOpts.PerFontName>
	</cfif>
	<cfif Trim(GetOpts.PerFontSize) neq "">
		<cfset perfontsize=GetOpts.PerFontSize>
	</cfif>
</cfif>
<cfif PerFontName Is Not "NA" OR PerFontSize Is Not "NA">
	<cfoutput>
<style type="text/css">    
   td  
	{
	<cfif PerFontName Is Not "NA">font-family : #perfontname#;</cfif>
   <cfif PerFontSize Is Not "NA">font-size : #perfontsize#;</cfif>
   }
</style>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">
 
