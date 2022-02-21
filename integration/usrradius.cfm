<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- Integration page for USR Radius --->
<!--- 4.0.0 12/14/00 --->
<!--- usrradius.cfm --->

<cfif IntCode Is "Authentication">
	<cfset TheCode = "usrradius">
	<cfset TheDisp = "USR Radius">
	<cfset GenericFieldCodes = "accntlogin,accntodbc,accounts,acntpassword,acntsestime,acntstattype,acnttype,acnttypesfd,activeyn,authodbc,calldatetime,callslogin,currentyn,custid,expiredate,inputoct,loginlimit,maxconnecttime,maxidletime,nasident,nasport,outputoct,port,server,serveripaddr,tbacnttypes,tbcalls,tbserverport,tbservers,calldate,calltime,custipaddress,dst1,dst2">
	<cfset GenericFieldValues = "user_name,usradius,users,password,Acct_Session_Time, , , , ,usradius,Event_Date_Time,User_Name, , ,password_expire,Acct_Input_Octets,total_logins, ,idle_timeout, , ,Acct_Output_Octets, , , , ,calls, , , , , ,Access,Access">
	<cfset CreateFieldCodes = "User_Name,Password,PASSWORD_EXPIRE,MAX_CONCURRENT_SESSIONS,TOTAL_SESSION_TIME,IDLE_TIMEOUT">
	<cfset CreateFieldValues = "%R04,%R05,%P07,%P04,%P05,%P06">
	<cfset CreateFieldValues2 = "Text,Text,Date,Number,Number,Number">
	<cfset CreateFieldValues3 = "1,1,1,1,1,1">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
 