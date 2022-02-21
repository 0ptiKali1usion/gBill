<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Livingston --->
<!--- 4.0.0 11/01/00 --->
<!--- livingston.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "livingstonnt">
	<cfset TheDisp = "Livingston NT">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,custipaddress,dst1,dst2">
	<cfset GenericFieldValues = "name,livingstonrad,usercache,content,Acct_Session_Time,Acct_Status_Type, , , ,livingstonrad,Datestamp,User_Name, , , ,Acct_Input_Octets, , , ,NAS_IP_Address,NAS_Port,Acct_Output_Octets, , , , ,AccountingLog, , , , , ,Access,Access">
	<cfset CreateFieldCodes = "name,content">
	<cfset CreateFieldValues = "%R04;Password =
	%R05
		
	Auth-Type = System,Service-Type = %P03,Framed-Protocol = PPP,Framed-Address = 255.255.255.254,Framed-Netmask = 255.255.255.255,Framed-Routing = Broadcast-Listen,Framed-Compression = Van-Jacobsen-TCP-IP,Framed-MTU = 1500">
	<cfset CreateFieldValues2 = "Text,Text">
	<cfset CreateFieldValues3 = "1,0">
	<cfset CreateFVDelim = ";">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
 