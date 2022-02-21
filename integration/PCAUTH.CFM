<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Integration page for PC Auth --->
<!--- 4.0.0 12/14/00 --->
<!--- pcauth.cfm --->

<cfif IntCode Is "CreditCardBatch">
	<cfset TheCode = "pcauth">
	<cfset TheDisp = "PC Auth">
	<cfset FieldCodes = "ccnum;1,ccmonccyear;2,accountid;3,Bal;4,AVSAddr;6,AVSZip;7">
	<cfset CustomFields1 = "cc;cc;5">
	<cfset CustomFields2 = "cr;cr;5">
	<cfset FieldGeneral = "ccamountformat; ,ccamountperiod;1,ccdateformat;MM-DD-YYYY,ccdelimit;**@**,ccenclose;0,ccenclosenull;0,cchrout; ,ccnumfield;7,ccoutputheadrow;0,cctimeformat;hh:mm:ss,ccyearformat;yyyy,MaxPerFile;500">
	<cfset ImportCodes = "accountid;1;1,amount;4;1,authcode;3;2,ccnum;2;1">
	<cfset ImportGeneral = "ccinputlines;1,ccinputheadrow;0,codewide;1">
	<cfset ShowButton = 1>
<cfelseif IntCode Is "CreditCardLive">
	<cfset TheCode = "pcauth">
	<cfset TheDisp = "PC Auth">
	<cfset ShowButton = 0>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="no">  
 