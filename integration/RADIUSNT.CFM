<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Radius NT --->
<!--- 4.0.0 12/14/00 --->
<!--- radiusnt.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "radiusnt">
	<cfset TheDisp = "RadiusNT">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,custipaddress,dst1,dst2">
	<cfset GenericFieldValues = "Login,radius,SubAccounts,Password,AcctSessionTime,AcctStatusType,AccountType,AccountType,Active,radius,CallDate,UserName, ,CustomerID,saExpireDate,AcctInputOctets,LoginLimit, , ,NASIdentifier,NASPort,AcctOutputOctets,Port,Server,IPAddress,AccountTypes,calls,ServerPorts,Servers, , , ,Access,Access">
	<cfset CreateFieldCodes = "CustomerID,Login,FirstName,LastName,AccountType,Password,Active,saExpireDate,TimeLeft,LoginLimit">
	<cfset CreateFieldValues = "1,%R04,%A03,%A04,%P03,%R05,1,%P07,%P02,%P04">
	<cfset CreateFieldValues2 = "Number,Text,Text,Text,Text,Text,Number,Date,Number,Number">
	<cfset CreateFieldValues3 = "1,1,1,1,1,1,1,1,1,1">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
  