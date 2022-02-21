<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Integration page for PC Charge --->
<!--- 4.0.0 12/14/00 --->
<!--- pccharge.cfm --->

<cfif IntCode Is "CreditCardBatch">
	<cfset TheCode = "pccharge">
	<cfset TheDisp = "PC Charge">
	<cfset FieldCodes = "ccnum;2,ccmonccyear;3,Bal;4,accountid;5,AVSZip;6,AVSAddr;7,cardhold;8">
	<cfset CustomFields1 = "1;1;1">
	<cfset CustomFields2 = "3;3;1">
	<cfset FieldGeneral = "ccamountformat; ,ccamountperiod;1,ccdateformat;MM-DD-YYYY,ccdelimit;sp,ccenclose;1,ccenclosenull;0,cchrout;108,ccnumfield;8,ccoutputheadrow;1,cctimeformat;hh:mm:ss,ccyearformat;yyyy,MaxPerFile;500">
	<cfset ImportCodes = "accountid;5;1,amount;4;1,authcode;8;2,ccnum;2;1">
	<cfset ImportGeneral = "ccinputlines;1,ccinputheadrow;1,codewide;1">
	<cfset ShowButton = 1>
<cfelseif IntCode Is "CreditCardLive">
	<cfset TheCode = "pccharge">
	<cfset TheDisp = "PC Charge">
	<cfset ShowButton = 0>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="no">  
  