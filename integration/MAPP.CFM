<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Mapp --->
<!--- 4.0.0 12/14/00 --->
<!--- mapp.cfm --->

<cfif IntCode Is "CreditCardBatch">
	<cfset TheCode = "mapp">
	<cfset TheDisp = "Mapp">
	<cfset FieldCodes = "cctype;3,ccnum;4,ccmonccyear;5,cardhold;6,Bal;9,accountid;16">
	<cfset CustomFields1 = "10$00000000##date####time##;10$00000000##date####time##;1">
	<cfset CustomFields2 = "30$00000000##date####time##;30$00000000##date####time##;1">
	<cfset FieldGeneral = "ccamountformat;$,ccamountperiod;1,ccdateformat;MM-DD-YYYY,ccdelimit;pipe,ccenclose;0,ccenclosenull;0,cchrout; ,ccnumfield;17,ccoutputheadrow;0,cctimeformat;HH:mm:ss,ccyearformat;yyyy,MaxPerFile;500">
	<cfset ImportCodes = "accountid;16;1,amount;9;1,authcode;17;2,ccnum;4;1">
	<cfset ImportGeneral = "ccinputlines;1,ccinputheadrow;0,codewide;1">
	<cfset ShowButton = 1>
<cfelseif IntCode Is "CreditCardLive">
	<cfset TheCode = "mapp">
	<cfset TheDisp = "Mapp">
	<cfset ShowButton = 0>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="no">    
 