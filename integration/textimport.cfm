<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Text Import --->
<!--- 4.0.0 12/14/00 --->
<!--- TextImport.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "textimport">
	<cfset TheDisp = "Text Import">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,dst1,dst2">
	<cfset GenericFieldValues = " ,customradius, , ,AcctSessionTime,AcctStatusType, , , , ,CallDate,UserName, , , ,AcctInputOctets, , , ,NASIdentifier,NASPort,AcctOutputOctets, , , , ,Calls, , , , , , ">
	<cfset CreateFieldCodes = "">
	<cfset CreateFieldValues = "">
	<cfset CreateFieldValues2 = "">
	<cfset CreateFieldValues3 = "">
	<cfset AuthType = "Text">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
 