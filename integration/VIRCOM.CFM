<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Vircom --->
<!--- 4.0.0 12/14/00 --->
<!--- vircom.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "vircom">
	<cfset TheDisp = "Vircom">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,custipaddress,dst1,dst2">
	<cfset GenericFieldValues = "UserName,VOP Accounting,Authentication,Password,AcctSessionTime,AcctStatusType,ServiceType, , ,VOP Database, ,UserName, , ,ExpirationDate,AcctInputOctets,PortLimit,SessionLimit,IdleLimit,NasIdentifier,NasPortID,AcctOutputOctets, , , , ,Accounting, , ,LogDate,LogTime,StaticIP,Access,Access">
	<cfset CreateFieldCodes = "UserName,Password,ServiceType,ExpirationDate,PortLimit,SessionLimit,IdleLimit">
	<cfset CreateFieldValues = "%R04,%R05,%P03,%P07,%P04,%P05,%P06">
	<cfset CreateFieldValues2 = "Text,Text,Text,Date,Number,Number,Number">
	<cfset CreateFieldValues3 = "1,1,1,1,1,1,1">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
   