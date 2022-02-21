<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Ascend --->
<!--- 4.0.0 11/01/00 --->
<!--- ascendodbc.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "ascendodbc">
	<cfset TheDisp = "AscendODBC">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,custipaddress,dst1,dst2">
	<cfset GenericFieldValues = "user_name,ascend,authentication,password,Acct_Session_Time, ,Framed_Protocol, , ,Ascend,Stop_Time,User_Name, , , ,Acct_Input_Octets,Ascend_maximum_channels, ,Ascend_Idle_Limit,NAS_IP_Address,NAS_Port,Acct_Output_Octets, , , , ,Accounting, , , , , ,Access,Access">
	<cfset CreateFieldCodes = "Ascend_Assign_IP_Pool,Ascend_Idle_Limit,Framed_Protocol,Framed_Routing,User_Name,Password,Service_Type,Ascend_maximum_Channels">
	<cfset CreateFieldValues = "1,%P06,%P03,None,%R04,%R05,2,%P04">
	<cfset CreateFieldValues2 = "Number,Text,Number,Text,Text,Text,Text,Number">
	<cfset CreateFieldValues3 = "1,1,1,1,1,1,1,1">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
 