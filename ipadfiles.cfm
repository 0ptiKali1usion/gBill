<!--- Version 4.0.0 --->
<!--- This page writes the IPAD text files and moves via FTP to the server. --->
<!--- 4.0.0 03/29/00 --->
<!--- ipadfiles.cfm --->

<cfsetting enablecfoutputonly="Yes">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfquery name="GetCustomAuth" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName ='IPADCAuthID'
</cfquery>
<cfset IPADCAuthID = GetCustomAuth.Value1>

<cfif IPADType Is "Auth">
	<cfquery name="getIPADAuth" datasource="#pds#">
		SELECT * 
		FROM AccountsAuth 
		WHERE DomainID IN 
			(SELECT DomainID 
			 FROM Domains 
			 WHERE CAuthID = #IPADCAuthID#)
		ORDER BY UserName
	</cfquery>
	<cfset IPADfile1 = "">
	<cfloop query="getIPADAuth">
		<cfset IPADfile1 = IPADfile1 & "#UserName# #password# #filter1# #IP_Address# #max_idle# #max_connect# #max_logins#
">
	</cfloop>
	<cffile action="write" file="#IPADslipfile#" output="#IPADfile1#">
	<cfquery name="GetValues" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName In 
			('IPADslipfile','IPADslipfileftp','IPADslipserver', 
		  	 'IPADsliplogin','IPADslippassw','WarnEMail','DateMask1') 
	</cfquery>
	<cfloop query="GetValues">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfx_wait SPAN="5">
	<cfset ServerName = IPADslipserver>
	<cfset UserName = IPADsliplogin>
	<cfset PassWord = IPADslippassw>
	<cfset FilePath = IPADslipfile>
	<cfset FileName = GetFileFromPath("#IPADslipfile#")>
	<cfset DoFTPYN = IPADslipfileftp>
	<cfif DoFTPYN is 1>
		<cfftp action="OPEN" server="#ServerName#" username="#UserName#" 
		 password="#PassWord#" stoponerror="No" connection="IPAD"> 
		
		<cfftp action="PUTFILE" stoponerror="No" localfile="#FilePath#" 
		 transfermode="ASCII" remotefile="#FileName#" connection="IPAD">
		
		<cfif Not CFFTP.Succeeded>
			<cfset NewDate = DateAdd("n",10,Now())>
			<cfquery name="Reschedule" datasource="#pds#">
				INSERT INTO AutoRun 
				(WhenRun, DoAction, Value1, Value2, ScheduledBy) 
				VALUES 
				(#NewDate#,'IPAD','Auth', 'Reschedule', '#StaffMemberName.FirstName#, #StaffMemberName.Lastname#')
			</cfquery>
			<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD Auth file FTP failure">
The attempt to FTP file: #FilePath# 
to the server: #ServerName# failed.
It was rescheduled for #LSDateFormat(NewDate, '#DateMask1#')# #TimeFormat(NewDate, 'hh:mm tt')#.
</cfmail>
		<cfelse>
			<cfif Rescheduled Is "Reschedule">
				<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD Auth file FTP failure">
The last attempt to FTP file: #FilePath# 
to the server:  #ServerName# was successful.
This was the rescheduled attempt from earlier.
</cfmail>
			</cfif>
		</cfif>
		
		<cfftp action="close" connection="IPAD">
	</cfif>
	<cfquery name="finishnow" datasource="#pds#">
		DELETE FROM AutoRun 
		WHERE AutoRunID = #AutoRunID#
	</cfquery>
<cfelseif IPADType Is "EMail">
	<cfquery name="getEMailAccounts" datasource="#pds#">
		SELECT * 
		FROM AccountsEMail 
		WHERE PREMail = 1 
		AND ContactYN = 0 
		AND DomainID IN 
			(SELECT DomainID 
			 FROM Domains 
			 WHERE CAuthID = #IPADCAuthID#)
		ORDER BY Login
	</cfquery>
	<cfquery name="getEMailAlias" datasource="#pds#">
		SELECT A.*, E.EMail AS PrimEMail 
		FROM AccountsEMail A, AccountsEMail E 
		WHERE A.AliasTo = E.EMailID 
		AND A.Alias = 1 
		AND A.DomainID IN 
			(SELECT DomainID 
			 FROM Domains 
			 WHERE CAuthID = #IPADCAuthID#)
		ORDER BY A.Login
	</cfquery>
	<cfquery name="getIPADmail" datasource="#pds#">
		SELECT * 
		FROM IPADMail 
		ORDER BY UserName
	</cfquery>
	<cfset IPADfile2 = "">
	<cfloop query="getIPADmail">
		<cfset IPADfile2 = IPADfile2 & "#cmd1# #Alias_Mask# #DNS_Mask# #UserName# #pswd# #mailbox# #MailBoxLimit#
">
	</cfloop>
	<cfloop query="getEMailAccounts">
		<cfset IPADfile2 = IPADfile2 & "POP3 #EMail# #Login# #EPass# #MailBoxPath# #MailBoxLimit#
">
	</cfloop>
	<cfloop query="getEMailAlias">
		<cfset IPADfile2 = IPADfile2 & "Redir #EMail# #PrimEMail# #Login# #EPass# #MailBoxPath# #MailBoxLimit#
">
	</cfloop>

	<cffile action="write" file="#IPADmailfile#" output="#IPADfile2#">
	<cfquery name="GetValues" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName In 
			('IPADMailserver','IPADMaillogin','IPADMailpassw', 
		  	 'IPADMailfile','IPADMailfileftp','WarnEMail','DateMask1') 
	</cfquery>
	<cfloop query="GetValues">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfx_wait SPAN="5">
	<cfset Servername = IPADMailserver>
	<cfset Username = IPADMaillogin>
	<cfset Password = IPADMailpassw>
	<cfset Filepath = IPADMailfile>
	<cfset Filename = GetFileFromPath("#IPADmailfile#")>
	<cfset DoFTPYN = IPADMailfileftp>
	<cfif DoFTPYN is 1>
		<cfftp action="OPEN" server="#ServerName#" username="#UserName#" 
		 password="#PassWord#" stoponerror="No" connection="IPAD"> 
		
		<cfftp action="PUTFILE" stoponerror="No" localfile="#FilePath#" 
		 transfermode="ASCII" remotefile="#FileName#" connection="IPAD">
		
		<cfif Not CFFTP.Succeeded>
			<cfset NewDate = DateAdd("n",10,Now())>
			<cfquery name="Reschedule" datasource="#pds#">
				INSERT INTO AutoRun 
				(WhenRun, DoAction, Value1, Value2, ScheduledBy) 
				VALUES 
				(#NewDate#,'IPAD','EMail', 'Reschedule', '#StaffMemberName.FirstName#, #StaffMemberName.Lastname#')
			</cfquery>
			<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD EMail file FTP failure">
The attempt to FTP file: #FilePath# 
to the server: #ServerName# failed.
It was rescheduled for #LSDateFormat(NewDate, '#DateMask1#')# #TimeFormat(NewDate, 'hh:mm tt')#.
</cfmail>
		<cfelse>
			<cfif Rescheduled Is "Reschedule">
				<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD EMail file FTP failure">
The last attempt to FTP file: #FilePath# 
to the server:  #ServerName# was successful.
This was the rescheduled attempt from earlier.
</cfmail>
			</cfif>
		</cfif>
		
		<cfftp action="close" connection="IPAD">
	</cfif>
	<cfquery name="finishnow" datasource="#pds#">
		DELETE FROM AutoRun WHERE AutoRunID = #AutoRunID#
	</cfquery>
<cfelseif IPADType Is "FTP">
	<cfquery name="getIPADftp" datasource="#pds#">
		SELECT * 
		FROM AccountsFTP 
		WHERE DomainID IN 
			(SELECT DomainID 
			 FROM Domains 
			 WHERE CAuthID = #IPADCAuthID#)
		ORDER BY UserName
	</cfquery>
	<cfset IPADfile3 = "">
	<cfloop query="getIPADftp">
		<cfset attribute1 = "">
		<cfif Read1 is "1"><cfset attribute1 = attribute1 & "RD "></cfif>
		<cfif Write1 is "1"><cfset attribute1 = attribute1 & "WR "></cfif>
		<cfif Create1 is "1"><cfset attribute1 = attribute1 & "CF "></cfif>
		<cfif Delete1 is "1"><cfset attribute1 = attribute1 & "DF "></cfif>
		<cfif MKDir1 is "1"><cfset attribute1 = attribute1 & "MD "></cfif>
		<cfif RMDir1 is "1"><cfset attribute1 = attribute1 & "RM "></cfif>
		<cfif NOReDir1 is "1"><cfset attribute1 = attribute1 & "NR "></cfif>
		<cfif AnyDir1 is "1"><cfset attribute1 = attribute1 & "AN "></cfif>
		<cfif AnyDrive1 is "1"><cfset attribute1 = attribute1 & "AD "></cfif>
		<cfif NoDrive1 is "1"><cfset attribute1 = attribute1 & "ND "></cfif>
		<cfif PutAny1 is "1"><cfset attribute1 = attribute1 & "PA "></cfif>
		<cfif Super1 is "1"><cfset attribute1 = attribute1 & "SU "></cfif>
		<cfset IPADfile3 = IPADfile3 & "#UserName# #password# #start_dir# " & "#attribute1#" & "  MAX_IDLE=#Max_Idle1#  MAX_CONNECT=#Max_Connect1#" & "
">
	</cfloop>
	<cffile action="write" file="#IPADftpfile#" output="#IPADfile3#">
	<cfquery name="GetValues" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName In 
			('IPADftpserver','IPADftplogin','IPADftppassw', 
		  	 'IPADftpfile','IPADftpfileftp','WarnEMail','DateMask1') 
	</cfquery>
	<cfloop query="GetValues">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfx_wait SPAN="5">
	<cfset ServerName = IPADftpserver>
	<cfset UserName = IPADftplogin>
	<cfset PassWord = IPADftppassw>
	<cfset FilePath = IPADftpfile>
	<cfset FileName = GetFileFromPath("#IPADftpfile#")>
	<cfset DoFTPYN = IPADftpfileftp>
	<cfif DoFTPYN is 1>
		<cfftp action="OPEN" server="#ServerName#" username="#UserName#" 
		 password="#PassWord#" stoponerror="No" connection="IPAD"> 
		
		<cfftp action="PUTFILE" stoponerror="No" localfile="#FilePath#" 
		 transfermode="ASCII" remotefile="#FileName#" connection="IPAD">
		
		<cfif Not CFFTP.Succeeded>
			<cfset NewDate = DateAdd("n",10,Now())>
			<cfquery name="Reschedule" datasource="#pds#">
				INSERT INTO AutoRun 
				(WhenRun, DoAction, Value1, Value2, ScheduledBy) 
				VALUES 
				(#NewDate#,'IPAD','FTP', 'Reschedule', '#StaffMemberName.FirstName#, #StaffMemberName.Lastname#')
			</cfquery>
			<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD FTP file FTP failure">
The attempt to FTP file: #FilePath# 
to the server: #ServerName# failed.
It was rescheduled for #LSDateFormat(NewDate, '#DateMask1#')# #TimeFormat(NewDate, 'hh:mm tt')#.
</cfmail>
		<cfelse>
			<cfif Rescheduled Is "Reschedule">
				<cfmail to="#WarnEMail#" from="#WarnEMail#" subject="IPAD FTP file FTP failure">
The last attempt to FTP file: #FilePath# 
to the server:  #ServerName# was successful.
This was the rescheduled attempt from earlier.
</cfmail>
			</cfif>
		</cfif>
		
		<cfftp action="close" connection="IPAD">
	</cfif>
	<cfquery name="FinishNow" datasource="#pds#">
		DELETE FROM AutoRun 
		WHERE AutoRunID = #AutoRunID#
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
 