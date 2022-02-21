<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Integration page for IC Verify --->
<!--- 4.0.0 12/14/00 --->
<!--- icverify.cfm --->

<cfif IntCode Is "CreditCardBatch">
	<cfset TheCode = "icverify">
	<cfset TheDisp = "IC Verify">
	<cfset FieldCodes = "compname;2,accountid;3,ccnum;4,ccmonccyear;5,bal;6">
	<cfset CustomFields1 = "C1;C1;1">
	<cfset CustomFields2 = "C3;C3;1">
	<cfset FieldGeneral = "ccamountformat; ,ccamountperiod;1,ccdateformat;MM-DD-YYYY,ccdelimit;**@**,ccenclose;0,ccenclosenull;0,cchrout; ,ccnumfield;6,ccoutputheadrow;0,cctimeformat;hh:mm:ss,ccyearformat;yyyy,MaxPerFile;500">
	<cfset ImportCodes = "accountid;3;1,amount;6;1,authcode;3;2,ccnum;4;1">
	<cfset ImportGeneral = "ccinputlines;2,ccinputheadrow;0,codewide;1">
	<cfset ShowButton = 1>
<cfelseif IntCode Is "CreditCardLive">
	<cfset TheCode = "icverify">
	<cfset TheDisp = "IC Verify">
	<cfset ShowButton = 0>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="no">    
 