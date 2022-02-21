<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page calls the tag to import from a text radius file.
		This page needs cads, theimportfile, catype
		and if the database is SQL Server then it needs
		the admin login and password for SQL Server. --->
<!--- 4.0.0 04/26/00 
		3.2.0 10/01/98 --->
<!--- cfaccntimport.cfm --->

<cfparam name="thetokenlist" default="calldate,user-name,nas-ip-address,nas-port,nas-port-type,acct-status-type,acct-delay-time,acct-session-id,acct-session-time,acct-input-octets,acct-output-octets,acct-input-packets,acct-output-packets,framed-protocol,framed-ip-address,acct-authentic">
<cfparam name="thedbflist" default="calldate,username,nasidentifier,nasport,nasporttype,acctstatustype,acctdelaytime,acctsessionid,acctsessiontime,acctinputoctets,acctoutputoctets,acctinputpackets,acctoutputpackets,framedprotocol,framedaddress,acctauthentic">
<cfparam name="thedbtypes" default="d,c,c,n,c,c,n,c,n,n,n,n,n,c,c,c">

<cfquery name="getsetupinfo" datasource="#pds#">
	SELECT * 
	FROM CustomImport 
	WHERE FileName1 = 'cpds' 
	OR FileName1 = 'cTable' 
	OR FileName1 = 'cLogin' 
	OR FileName1 = 'cPasswd' 
</cfquery>
<cfloop query="getsetupinfo">
	<cfset "#FileName1#" = Path1>
</cfloop>
<cfquery name="FieldData" datasource="#pds#">
	SELECT * 
	FROM CustomImport 
	WHERE UseTab = 2 
	AND Path1 Is Not Null 
	ORDER BY FileName1 
</cfquery>
<cfif FieldData GT 0>
	<cfset thetokenlist = ValueList(FieldData.Path1)>
	<cfset thedbflist = ValueList(FieldData.FileName1)>
	<cfset thedbtypes = ValueList(FieldData.FieldType)>
</cfif>

<cfx_ascendimport DataSource="#cpds#" Table="#cTable#" ImportFile="#thefilename#" 
 TokenList="#thetokenlist#" DBFList="#thedbflist#" DBTypes="#thedbtypes#" 
 CAuthID="#CAuthID#" Login = "#cLogin#" Password="#cPasswd#">
 
<cfquery name="UpdAuth" datasource="#cpds#">
	UPDATE #cTable# SET 
	CAuthID = #CAuthID# 
	WHERE CAuthID = 0 
	OR CAuthID Is Null 
</cfquery>
 
<cfsetting enablecfoutputonly="No"> 
  