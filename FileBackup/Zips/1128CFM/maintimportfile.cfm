<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 04/26/00
		3.5.0 06/28/99
		3.2.0 10/01/98 --->
<!--- maintimportfile.cfm --->

<cfquery name="getfileinfo" datasource="#pds#">
	SELECT * 
	FROM CustomImport 
	WHERE UseTab = 1 
	AND ActiveYN = 1 
</cfquery>
<cfparam name="cpds" default="CustomRadius">

<cfquery name="getsetupinfo" datasource="#pds#">
	SELECT * 
	FROM CustomImport 
	WHERE FileName1 = 'pathimport' 
	OR FileName1 = 'cpds' 
</cfquery>
<cfoutput query="getsetupinfo">
	<cfset "#FileName1#" = Path1>
</cfoutput>
<cfset filelist1 = "">

<cfquery name="BeforeCount" datasource="#cPDS#">
	SELECT Count(*) as BCount
	FROM Calls
</cfquery>
<cfset BeforeImport = BeforeCount.BCount>
<cfif BeforeImport Is "">
	<cfset BeforeImport = 0>
</cfif>

<cfloop query="getfileinfo">
	<cfset CAuthID = CAuthID>
	<cfif  ftpyn is 1>
			<cfset thefilename = "#ciid#-#LSDateFormat(now(), 'mmm-dd-yy')#.rad">
		<cfftp action="open" connection="thisfile" password="#ftppassword#"
		 username="#ftplogin#" server="#server1#">
				<cfset len1 = len(path1) - 1>
		<cfset thedir = Mid(path1,2,len1)>	 
		<cfif thedir is not "">
			<cfftp action="changedir" connection="thisfile"
			 directory="#thedir#">
		</cfif>
		<cfftp action="RENAME" existing="#filename1#" new="#thefilename#" connection="thisfile">
		<cfftp action="getfile" transfermode="ASCII" connection="thisfile" remotefile="#thefilename#" localfile="#pathimport##thefilename#">
		<cfftp action="close" connection="thisfile">

		<cfset thefilename = "#pathimport##thefilename#">
		<cfinclude template="cfaccntimport.cfm">
	<cfelse>
		<cfset thefilename = "#ciid#-#LSDateFormat(now(), 'mmm-dd-yy')#.rad">
		<cfif FileExists("#server1##path1##filename1#")>
			<cfset filelist1 = filelist1 & "#thefilename#,">
			<cffile action="RENAME"
			 source="#server1##path1##filename1#"
			 destination="#server1##path1##thefilename#">
			<cffile action="copy"
			 source="#server1##path1##thefilename#"
			 destination="#pathimport##thefilename#">
	
			<cfset thefilename = "#pathimport##thefilename#">
			<cfinclude template="cfaccntimport.cfm">
		</cfif>
	</cfif>
</cfloop>

<cfquery name="AfterCount" datasource="#cPDS#">
	SELECT Count(*) as ACount
	FROM Calls
</cfquery>
<cfset AfterImport = AfterCount.ACount>
<cfif AfterImport Is "">
	<cfset AfterImport = 0>
</cfif>

<cfset TotalImport = AfterImport - BeforeImport>

<cfsetting enablecfoutputonly="No">
<HTML>
<HEAD>
<TITLE>Files Imported</TITLE>
</HEAD>
<BODY>

<font size="5">Files Imported</font><br>
<cfoutput>
#TotalImport# records imported.<br>
<cfset filelistout = Replace(filelist1,",","<BR>","ALL")>
#filelistout#
</cfoutput>

</BODY>
</HTML>
 