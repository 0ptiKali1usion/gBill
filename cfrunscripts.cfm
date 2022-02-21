<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 06/21/99 --->
<!--- cfrunscripts.cfm --->
<!--- Required: 
			Action
			Location
			Type
			ID
			FindList
			ReplList
		Optional:
			AccountID
			AccntPlanID
--->
<cfset pds = caller.pds>
<cfset Action = Attributes.Action>
<cfset Location = Attributes.Location>
<cfset Type = Attributes.Type>
<cfset ID = Attributes.ID>
<cfset FindList = Attributes.FindList>
<cfset ReplList = Attributes.ReplList>

<cfif IsDefined("Attributes.AccntPlanID")>
	<cfset AccntPlanID = Attributes.AccntPlanID>
<cfelse>
	<cfset AccntPlanID = 0>
</cfif>
<cfif IsDefined("Attributes.AccountID")>
	<cfset AccountID = Attributes.AccountID>
<cfelse>
	<cfset AccountID = 0>
</cfif>

<cfquery name="AllScripts" datasource="#pds#">
	SELECT * 
	FROM Integration I, IntScriptLoc S, IntLocations L 
	WHERE I.IntID = S.IntID 
	AND S.LocationID = L.LocationID 
	AND L.ActiveYN = 1 
	AND I.ActiveYN = 1 
	AND L.PageName = '#Location#' 
	AND L.LocationAction = '#Action#' 
	AND I.TypeID = 
		(SELECT TypeID 
		 FROM IntTypes 
 		 WHERE TypeStr = '#Type#' 
		 ) 
	<cfif AccntPlanID Is Not 0>
		AND I.IntID IN 
			(SELECT IntID 
			 FROM IntPlans 
			 WHERE PlanID = 
			 	(SELECT PlanID 
				 FROM AccntPlans 
				 WHERE AccntPlanID = #AccntPlanID#)
			)
	</cfif>
</cfquery>

<cfloop query="AllScripts">
	<cfset LocCusODBC = ReplaceList("#CustomDS#","#FindList#","#ReplList#")>
	<cfset LocCustSQL = ReplaceList("#CustomSQL#","#FindList#","#ReplList#")>
	<cfif Trim(LocCusODBC) Is Not "" AND Trim(LocCustSQL) Is Not "">
		<cfquery name="CustomVariables" datasource="#LocCusODBC#">
			#LocCustSQL#
		</cfquery>
		<cfquery name="PerCustomValues" datasource="#pds#">
			SELECT UseText 
			FROM IntVariables 
			WHERE CustomYN = #IntID# 
			ORDER BY UseText 
		</cfquery>
		<cfloop query="PerCustomValues">
			<cfset FindList = ListAppend(FindList,UseText)>
			<cfset LkVl = Replace("#UseText#","%","per")>
			<cfset NwVl = Evaluate("CustomVariables.#LkVl#")>
			<cfif Trim(NwVl) Is "">
				<cfset NwVl = ")*N/A*(">
			</cfif>
			<cfset ReplList = ListAppend(ReplList,NwVl)>
		</cfloop>
	</cfif>
	<cfset FindList = ListAppend(FindList,'%S03')>
	<cfset ReplList = ListAppend(ReplList,IntDesc)>
	<cfset TypeLoop = ScriptOrder>
	<cfloop index="B5" list="#TypeLoop#">
		<cfif B5 Is "d">
			<cfif DOSActiveYN Is 1>
				<cfset LocScript = ReplaceList("#DOSScript#","#FindList#","#ReplList#")>
				<cfset LocFileNm = ReplaceList("#DOSFileName#","#FindList#","#ReplList#")>
				<cfset LocAction = DOSAction>
				<cfset LocFileDr = ReplaceList("#DOSFileDir#","#FindList#","#ReplList#")>
				<cfset LocFileCp = ReplaceList("#DosCopyFrom#","#FindList#","#ReplList#")>
				<cfset LocScript = ReplaceList("#LocScript#",")*N/A*(","")>
				<cfif LocAction Is "Exec">
					<cfif Trim(LocFileDr) Is "">
						<cfset LocFileDr = BillPath>
					</cfif>
					<cffile action="WRITE" file="#LocFileDr##LocFileNm#" output="#LocScript#">
					<cfexecute name="#LocFileDr##LocFileNm#">
					</cfexecute>  
					<cfif DOSDelay Is Not "">
						<cfset LocDelayTo = DateAdd("n",DOSDelay,Now())>
						<cfquery name="SetDelete" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, FileAttach) 
							VALUES 
							(#LocDelayTo#,'DeleteFile','#LocFileDr##LocFileNm#')
						</cfquery>
					</cfif>
				<cfelseif LocAction Is "IPAD">
					<cfif TypeID Is "1">
						<cfquery name="GetAuth" datasource="#pds#">
							SELECT * 
							FROM AccountsAuth 
							WHERE AccountID In 
								(SELECT AccountID 
								 FROM AccntPlans 
								 WHERE AccntStatus = 0) 
							<cfif Trim(LocScript) Is Not "">
							AND DomainID In 
								(SELECT DomainID 
								 FROM Domains 
								 WHERE CAuthID In #LocScript# 
								)
							</cfif>
							ORDER BY UserName
						</cfquery>
						<cfset IPADOut = "">
						<cfloop query="GetAuth">
							<cfset IPADOut = IPADOut & "#UserName# #Password# #Filter1# #IP_Address# #Max_Idle# #Max_Connect# #Max_Logins#
">
						</cfloop>
					<cfelseif TypeID Is "3">
						<cfquery name="GetFTP" datasource="#pds#">
							SELECT * 
							FROM AccountsFTP 
							WHERE AccountID In 
								(SELECT AccountID 
								 FROM AccntPlans 
								 WHERE AccntStatus = 0) 
							<cfif Trim(LocScript) Is Not "">
							AND DomainID In 
								(SELECT DomainID 
								 FROM Domains 
								 WHERE CFTPID In #LocScript# 
								)
							</cfif>
							ORDER BY UserName 
						</cfquery>
						<cfset IPADOut = "">
						<cfloop query="GetFTP">
							<cfset FTPAttributes = "">
							<cfif Read1 is "1"><cfset FTPAttributes = FTPAttributes & "RD "></cfif>
							<cfif Write1 is "1"><cfset FTPAttributes = FTPAttributes & "WR "></cfif>
							<cfif Create1 is "1"><cfset FTPAttributes = FTPAttributes & "CF "></cfif>
							<cfif Delete1 is "1"><cfset FTPAttributes = FTPAttributes & "DF "></cfif>
							<cfif MKDir1 is "1"><cfset FTPAttributes = FTPAttributes & "MD "></cfif>
							<cfif RMDir1 is "1"><cfset FTPAttributes = FTPAttributes & "RM "></cfif>
							<cfif NOReDir1 is "1"><cfset FTPAttributes = FTPAttributes & "NR "></cfif>
							<cfif AnyDir1 is "1"><cfset FTPAttributes = FTPAttributes & "AN "></cfif>
							<cfif AnyDrive1 is "1"><cfset FTPAttributes = FTPAttributes & "AD "></cfif>
							<cfif NoDrive1 is "1"><cfset FTPAttributes = FTPAttributes & "ND "></cfif>
							<cfif PutAny1 is "1"><cfset FTPAttributes = FTPAttributes & "PA "></cfif>
							<cfif Super1 is "1"><cfset FTPAttributes = FTPAttributes & "SU "></cfif>
							<cfset IPADOut = IPADOut & "#UserName# #Password# #Start_Dir# #FTPAttributes# MAX_IDLE=#Max_Idle1# MAX_CONNECT=#Max_Connect1#
">
						</cfloop>
					<cfelseif TypeID Is "4">
						<cfquery name="GetOther" datasource="#pds#">
							SELECT * 
							FROM IPADMail 
							ORDER BY CMD1
						</cfquery>
						<cfset IPADOut = "">
						<cfloop query="GetOther">
							<cfset IPADOut = IPADOut & "#CMD1# #Alias_Mask# #DNS_Mask# #UserName# #PSWD# #Mailbox# #Limit1#
">
						</cfloop>
						<cfquery name="GetAddresses" datasource="#pds#">
							SELECT * 
							FROM AccountsEMail 
							WHERE Alias = 0 
							AND ContactYN = 0 
							AND AccountID In 
								(SELECT AccountID 
								 FROM AccntPlans 
								 WHERE AccntStatus = 0) 
							<cfif Trim(LocScript) Is Not "">
							AND DomainID In 
								(SELECT DomainID 
								 FROM Domains 
								 WHERE CEMailID In #LocScript# 
								)
							</cfif>
							ORDER BY EMail
						</cfquery>
						<cfloop query="GetAddresses">
							<cfset IPADOut = IPADOut & "#MailCMD# #EMail# #Login# #EPass# #MailBoxPath# #MailBoxLimit#
">
						</cfloop>
						<cfquery name="GetAlias" datasource="#pds#">
							SELECT A.MailCMD, A.EMail AS EMailAlias, E.EMail 
							FROM AccountsEMail A, AccountsEMail E 
							WHERE A.AliasTo = E.EMailID 
							AND A.Alias = 1 
							AND A.AccountID In 
								(SELECT AccountID 
								 FROM AccntPlans 
								 WHERE AccntStatus = 0) 
							AND A.DomainID In 
								(SELECT DomainID 
								 FROM Domains 
								 WHERE CEMailID In #LocScript# 
								)
							ORDER BY A.EMail 
						</cfquery>
						<cfloop query="GetAlias">
							<cfset IPADOut = IPADOut & "#MailCMD# #EMailAlias# #EMail#
">
						</cfloop>
					</cfif>
					<cffile action="WRITE" file="#LocFileDr##LocFileNm#" output="#IPADOut#">
				<cfelseif LocAction Is "Write">
					<cfif Trim(LocFileDr) Is "">
						<cfset LocFileDr = BillPath>
					</cfif>
					<cffile action="WRITE" file="#LocFileDr##LocFileNm#" output="#LocScript#">
					<cfif DOSDelay Is Not "">
						<cfset LocDelayTo = DateAdd("n",DOSDelay,Now())>
						<cfquery name="SetDelete" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, FileAttach) 
							VALUES 
							(#LocDelayTo#,'DeleteFile','#LocFileDr##LocFileNm#')
						</cfquery>
					</cfif>
				<cfelseif LocAction Is "Copy">
					<cffile action="COPY" source="#LocFileCp#" destination="#LocFileDr##LocFileNm#"> 
					<cfif DOSDelay Is Not "">
						<cfset LocDelayTo = DateAdd("n",DOSDelay,Now())>
						<cfquery name="SetDelete" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, FileAttach) 
							VALUES 
							(#LocDelayTo#,'DeleteFile','#LocFileDr##LocFileNm#')
						</cfquery>
					</cfif>
				<cfelseif LocAction Is "Append">
					<cffile action="APPEND" file="#LocFileDr##LocFileNm#" addnewline="Yes" output="#LocScript#"> 
					<cfif DOSDelay Is Not "">
						<cfset LocDelayTo = DateAdd("n",DOSDelay,Now())>
						<cfquery name="SetDelete" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, FileAttach) 
							VALUES 
							(#LocDelayTo#,'DeleteFile','#LocFileDr##LocFileNm#')
						</cfquery>
					</cfif>
				<cfelseif LocAction Is "Delete">
					<cfif DOSDelay Is "">
						<cffile action="delete" file="#LocFileDr##LocFileNm#">
					<cfelse>
						<cfset LocDelayTo = DateAdd("n",DOSDelay,Now())>
						<cfquery name="SetDelete" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, FileAttach) 
							VALUES 
							(#LocDelayTo#,'DeleteFile','#LocFileDr##LocFileNm#')
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
		<cfelseif B5 Is "T">
			<cfif TelActiveYN Is 1>
				<cfif TelNetGTUseYN Is 1>
					<!--- If using the GreenSoft telnet script --->
					<cfset LocTLogin = ReplaceList("#TelnetLogin#","#FindList#","#ReplList#")>
					<cfset LocPasswd = ReplaceList("#TelnetPassword#","#FindList#","#ReplList#")>
					<cfset LocSLogin = ReplaceList("#TelnetSULogin#","#FindList#","#ReplList#")>
					<cfset LocSPassw = ReplaceList("#TelnetSUPassword#","#FindList#","#ReplList#")>
					<cfset LocTlHost = ReplaceList("#TelnetHost#","#FindList#","#ReplList#")>
					<cfset LocScript = ReplaceList("#TelnetScript#","#FindList#","#ReplList#")>
					<cfset LocFileName = ReplaceList("#TelnetGTFileName#","#FindList#","#ReplList#")>
					<cfset LocPathWay = ReplaceList("#TelnetGTPath#","#FindList#","#ReplList#")>

					<cfset pathway = LocPathWay>
					<cfif (Right(Pathway,1) Is NOT "/") AND (Right(Pathway,1) Is NOT "\")>
						<cfset pathway = pathway & OsType>
					</cfif>

					<cfset pathway = pathway & "gbill_tnet.pl">
					
					<cfset execfile = LocFileName>	
					<cffile action="Write" file="#execfile#" output="#LocScript#" mode="777">

					<cfset locArguments = "-h #LocTlHost# -u #LocTLogin# -p #LocPasswd# -s #LocSLogin# -k #LocSPassw# -f #Replace(execfile,"\","\\","All")# -d">
					<cfquery name="CheckFor" datasource="#pds#">
						SELECT Value1 
						FROM Setup 
						WHERE Varname = 'DebugGSTelnet' 
					</cfquery>
					<cfif (CheckFor.RecordCount GT 0) AND (CheckFor.Value1 Is 1)>
						<cfset locArguments = locArguments & " -d #pathway#integration/logger.log">
					</cfif>
					<cfexecute name="#Pathway#" arguments="#locArguments#" timeout="65">
					</cfexecute>

					<!--- <cffile action="DELETE" file="#execfile#"> --->
				<cfelse>
					<!--- Use Secure CRT --->
					<cfset LocSessName = "Default">
					<cfset LocProtocol = "SSH1">
					<cfquery name="GetPathInfo" datasource="#pds#">
						SELECT Value1 
						FROM Setup 
						WHERE VarName = 'crtpath' 
					</cfquery>
					<cfset CRTPath = GetPathInfo.Value1>
					<cfif IsDefined("StaffMember")>
						<cfset TheWhoSched = StaffMemberName.FirstName & " " & StaffMemberName.LastName>
					<cfelse>
						<cfset TheWhoSched = "Online EMail Management">
					</cfif>
					<cfset LocTLogin = ReplaceList("#TelnetLogin#","#FindList#","#ReplList#")>
					<cfset LocPasswd = ReplaceList("#TelnetPassword#","#FindList#","#ReplList#")>
					<cfset LocSLogin = ReplaceList("#TelnetSULogin#","#FindList#","#ReplList#")>
					<cfset LocSPassw = ReplaceList("#TelnetSUPassword#","#FindList#","#ReplList#")>
					<cfset LocTlHost = ReplaceList("#TelnetHost#","#FindList#","#ReplList#")>
					<cfset LocScript = ReplaceList("#TelnetScript#","#FindList#","#ReplList#")>
					<cfset LocScript = ReplaceList("#LocScript#",")*N/A*(","")>
					<cfset LocPort = ReplaceList("#TelnetPort#","#FindList#","#ReplList#")>
					<cfset LocUseSecure = ReplaceList("#TelnetUseSecure#","#FindList#","#ReplList#")>
					<cfset LocIdentity = ReplaceList("#TelnetSecIdent#","#FindList#","#ReplList#")>
					<cfset LocCipher = ReplaceList("#TelnetSecCipher#","#FindList#","#ReplList#")>
					<cfset LocSecUser = ReplaceList("#TelnetSecUser#","#FindList#","#ReplList#")>
					<cfset LocCRTAuth = ReplaceList("#TelnetSecAuthType#","#FindList#","#ReplList#")>
					<cfset LocCRTPassw = ReplaceList("#TelnetSecPassword#","#FindList#","#ReplList#")>
					<cfset LocFileName1 = ReplaceList("#TelnetCSFFile#","#FindList#","#ReplList#")>
					<cfset LocFileName2 = ReplaceList("#TelnetCFGFile#","#FindList#","#ReplList#")>
					<cfset LocFileName3 = ReplaceList("#TelnetCMDFile#","#FindList#","#ReplList#")>
					<cfset LocSessName = ReplaceList("#TelSessName#","#FindList#","#ReplList#")>
					<cfset UseGSCMDProc = UseCmdProcYN>
				
					<cfset File1 = LocFileName1 & ".csf"> <!--- Actual Script --->
					<cfset File2 = LocFileName2 & ".cfg"> <!--- Configuration --->
					<cfset File3 = LocFileName3 & ".tmp">
					<cfset File4 = LocFileName3 & ".cmd"> <!--- Our executeable --->

					<cfparam name="usesecure" default="#YesNoFormat(LocUseSecure)#">
					<cfparam name="SecureUser" default="#Trim(LocSecUser)#">
					<cfparam name="SecureCipher" default="#Trim(LocCipher)#">
					<cfparam name="SecureIdent" default="#Trim(LocIdentity)#">
					<cfparam name="SecurePort" default="#LocPort#"> 
					<cfset cmdstr = "/SCRIPT #File1# ">
					<cfif LocSessName Is Not "">
						<cfset cmdstr = cmdstr & "/S #LocSessName# ">
					</cfif>

					<cffile action="Write" file="#File1#" output="#LocScript#">
				
					<cfif usesecure Is "YES">
						<cfif LocCRTAuth Is Not "">
							<cfset cmdstr = cmdstr & "/#LocCRTAuth# ">
						</cfif>
						<cfif SecureUser Is Not "">
							<cfset cmdstr = cmdstr & "/L #SecureUser# ">
						</cfif>
						<cfif SecureIdent Is Not "">
							<cfset cmdstr = cmdstr & "/I #SecureIdent# ">
						</cfif>
						<cfif SecureCipher Is Not "">
							<cfset cmdstr = cmdstr & "/C #securecipher# ">
						</cfif>
						<cfif SecurePort Is Not "">
							<cfset cmdstr = cmdstr & "/P #secureport# ">
						</cfif>
						<cfset TheOutput = "[#LocSessName#]
Protocol Name=#LocProtocol#
Hostname=#LocTlHost#
Port=00000016
Username=#SecureUser#
">
						<cfif LocCRTAuth Is "Password">
							<cfset TheOutput = TheOutput & "PasswordV2=#LocCRTPassw#
">
						</cfif>
						<cfset TheOutput = TheOutput & "Cipher=#SecureCipher#
Auth=#LocCRTAuth#
Use Identity File=00000000
Identity Filename=
Forward X11=00000000
Use Compression=00000000
Compression Level=00000005
Use Single SSH Connection=00000001
Number Port Redirects=00000000
Rows=0000001e
Cols=0000004f
Color Scheme=Monochrome
Normal Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
Narrow Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
Use Script File=00000001
Script File=#file1#

">
						<cffile action="Write" file="#File2#" output="#TheOutput#">
					<cfelse>
						<cffile action="Write" file="#File2#" output="[#LocSessName#]
Protocol Name=telnet
Color Scheme=Monochrome
Normal Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
Narrow Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
	
[#LocSessName#]
Protocol Name=telnet
Hostname=#LocTlHost#
Use Script File=00000001
Script File=#file1#
	
">
					</cfif>

				   <cffile action="Write" file="#File3#" output="@echo off
#CRTPath# #cmdstr#
exit
">
					<cfset deltime = DateAdd("n","5",Now())>
					<cfquery name="SchedDelFile1" datasource="#pds#">
						INSERT INTO AutoRun 
						(DoAction, WhenRun, FileAttach, ScheduledBy, Memo1)
						VALUES 
						('DeleteFile', #CreateODBCDateTime(DelTime)#, '#File1#', '#TheWhoSched#', 'Scheduled to delete after the Telnet session during the running of the script.')
					</cfquery>
					<cfquery name="SchedDelFile1" datasource="#pds#">
						INSERT INTO AutoRun 
						(DoAction, WhenRun, FileAttach, ScheduledBy, Memo1)
						VALUES 
						('DeleteFile', #CreateODBCDateTime(DelTime)#, '#File2#', '#TheWhoSched#', 'Scheduled to delete after the Telnet session during the running of the script.')
					</cfquery>
					<cfquery name="SchedDelFile1" datasource="#pds#">
						INSERT INTO AutoRun 
						(DoAction, WhenRun, FileAttach, ScheduledBy, Memo1)
						VALUES 
						('DeleteFile', #CreateODBCDateTime(DelTime)#, '#File4#', '#TheWhoSched#', 'Scheduled to delete after the Telnet session during the running of the script.')
					</cfquery>

					<cffile action="Rename" source="#File3#" destination="#File4#" >
				
					<cfif UseGSCMDProc Is 1>
						<cfexecute name="#File4#" arguments="#cmdstr#">
						</cfexecute>
					</cfif>
				</cfif>
			</cfif>				
		<cfelseif B5 Is "S">
			<cfif SQLActiveYN Is 1>
				<cfset LocUseCus = SQLCustomAuth>
				<cfset LocScrType = Action>
				<cfif LocUseCus Is 0>
					<cfset LocDataSr = ReplaceList("#ODBCDataSource#","#FindList#","#ReplList#")>
					<cfset LocScript = ReplaceList("#ODBCSQL#","#FindList#","#ReplList#")>
					<cfset LocScript = ReplaceList("#LocScript#",")*N/A*(","NULL")>
					<cfset LocScript = ReplaceList("#LocScript#","'NULL'","NULL")>
					<cfset LocScript = Replace("#LocScript#","''","'","All")>
					<cfquery name="IntegrationSQL" datasource="#LocDataSr#">
						#Replace("#LocScript#","''","'","All")#
					</cfquery>
				<cfelse>
					<!--- Use the Custom Authentication --->
					<cfset SendCAuthID = LocSendCAuthID>
					<cfif LocScrType Is "Create">
						<cfquery name="LocDS" datasource="#pds#">
							SELECT DBName 
							FROM CustomAuthSetup 
							WHERE BOBName = 'AccntODBC' 
							AND ActiveYN = 1 
							AND CAuthID = #SendCAuthID# 
							AND DBType = 'Ds' 
						</cfquery>
						<cfif LocDS.DBName Is Not "">
							<cfquery name="LocTB" datasource="#pds#">
								SELECT DBName 
								FROM CustomAuthSetup 
								WHERE BOBName = 'Accounts' 
								AND ActiveYN = 1 
								AND CAuthID = #SendCAuthID# 
								AND DBType = 'Tb' 
							</cfquery>
							<cfif LocTB.DBName Is Not "">
								<cfquery name="allauthcreate" datasource="#pds#">
									SELECT * 
									FROM CustomAuthAccount 
									WHERE CAuthID = #SendCAuthID# 
									ORDER BY CAAID 
								</cfquery>
								<cfset LocAuthSQLStr = "INSERT INTO #LocTB.DBName# (">
								<cfloop query="AllAuthCreate">
									<cfset LocAuthSQLStr = LocAuthSQLStr  & "#DBFieldName#">
									<cfif AllAuthCreate.CurrentRow Is Not AllAuthCreate.RecordCount>
										<cfset LocAuthSQLStr = LocAuthSQLStr  & ", ">
									</cfif>
								</cfloop>
								<cfset LocAuthSQLStr = LocAuthSQLStr  & ") VALUES (">
								<cfloop query="AllAuthCreate">
										<cfif DataType is "text">
											<cfset LocAuthSQLStr = LocAuthSQLStr  & "*+*#Trim(DataNeed)#*+*">
										<cfelseif DataType is "number">
											<cfset LocAuthSQLStr = LocAuthSQLStr  & "#Trim(DataNeed)#">
										<cfelseif DataType is "date">
											<cfset LocDateValue = CreateODBCDateTime(DataNeed)>
											<cfset LocDateValue = Replace(LocDateValue,"'","*+*","All")>
											<cfset LocAuthSQLStr = LocAuthSQLStr  & "#LocDateValue#">
										</cfif>
										<cfif AllAuthCreate.CurrentRow Is Not AllAuthCreate.RecordCount>
											<cfset LocAuthSQLStr = LocAuthSQLStr  & ", ">
										</cfif>
								</cfloop>
								<cfset LocAuthSQLStr = LocAuthSQLStr  & ")">
								<cfset LocScript = ReplaceList("#LocAuthSQLStr#","#FindList#","#ReplList#")>
								<cftry>
									<cfquery name="IntegrationSQL" datasource="#authodbc#">
										#Replace(LocScript,"*+*","'","All")#
									</cfquery>
									<cfcatch type="Any">
										<cfset Message = "Problem with the integration.">
									</cfcatch>
								</cftry>
							</cfif>
						</cfif>
						<cfinclude template="cfauthvalues.cfm">
						<cfif authodbc is not "">
							<cfquery name="checkfirst" datasource="#authodbc#">
								SELECT #accntlogin# 
								FROM #accounts# 
								WHERE #accntlogin# = '#perA01#'
							</cfquery>
							<cfif checkfirst.recordcount is 0>
								<cfset createaccount = perA00>
								<cfinclude template="cfauthcreate.cfm">
							</cfif>
						</cfif>
					<cfelseif LocScrType Is "Delete">
						<cfquery name="LocDS" datasource="#pds#">
							SELECT DBName 
							FROM CustomAuthSetup 
							WHERE BOBName = 'AccntODBC' 
							AND ActiveYN = 1 
							AND CAuthID = #SendCAuthID# 
							AND DBType = 'Ds' 
						</cfquery>
						<cfif LocDS.DBName Is Not "">
							<cfquery name="LocTB" datasource="#pds#">
								SELECT DBName 
								FROM CustomAuthSetup 
								WHERE BOBName = 'Accounts' 
								AND ActiveYN = 1 
								AND CAuthID = #SendCAuthID# 
								AND DBType = 'Tb' 
							</cfquery>
							<cfif LocTB.DBName Is Not "">
								<cfquery name="LocUN" datasource="#pds#">
									SELECT DBName 
									FROM CustomAuthSetup 
									WHERE BOBName = 'accntlogin' 
									AND ActiveYN = 1 
									AND CAuthID = #SendCAuthID# 
									AND DBType = 'Fd' 
								</cfquery>
								<cfif LocUN.DBName Is Not "">
									<cfquery name="GetUserName" datasource="#pds#">
										SELECT UserName 
										FROM AccountsAuth 
										WHERE AuthID = #LocAuthID#
									</cfquery>
									<cfquery name="DelUser" datasource="#LocDS.DBName#">
										DELETE FROM #LocTB.DBName# 
										WHERE #LocUN.DBName# = #GetUserName.UserName#' 
									</cfquery>
								</cfif>
							</cfif>
						</cfif>
					<cfelseif LocScrType Is "Change">
						<cfquery name="LocDS" datasource="#pds#">
							SELECT DBName 
							FROM CustomAuthSetup 
							WHERE BOBName = 'AccntODBC' 
							AND ActiveYN = 1 
							AND CAuthID = #SendCAuthID# 
							AND DBType = 'Ds' 
						</cfquery>
						<cfif LocDS.DBName Is Not "">
							<cfquery name="LocTB" datasource="#pds#">
								SELECT DBName 
								FROM CustomAuthSetup 
								WHERE BOBName = 'Accounts' 
								AND ActiveYN = 1 
								AND CAuthID = #SendCAuthID# 
								AND DBType = 'Tb' 
							</cfquery>
							<cfif LocTB.DBName Is Not "">
								<cfquery name="LocUN" datasource="#pds#">
									SELECT DBName 
									FROM CustomAuthSetup 
									WHERE BOBName = 'accntlogin' 
									AND ActiveYN = 1 
									AND CAuthID = #SendCAuthID# 
									AND DBType = 'Fd' 
								</cfquery>
								<cfif LocUN.DBName Is Not "">
									<cfquery name="LocPW" datasource="#pds#">
										SELECT DBName 
										FROM CustomAuthSetup 
										WHERE BOBName = 'accntlogin' 
										AND ActiveYN = 1 
										AND CAuthID = #SendCAuthID# 
										AND DBType = 'Fd'
									</cfquery>
									<cfif LocPW.DBName Is Not "">
										<cfquery name="GetUserName" datasource="#pds#">
											SELECT UserName, Password 
											FROM AccountsAuth 
											WHERE AuthID = #LocAuthID#
										</cfquery>
										<cfquery name="DelUser" datasource="#LocDS.DBName#">
											UPDATE #LocTB.DBName# SET 
											#LocPW.DBName# = '#GetUserName.Password#' 
											WHERE #LocUN.DBName# = #GetUserName.UserName#' 
										</cfquery>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		<cfelseif B5 Is "U">
			<cfif URLActiveYN Is 1>
				<cfset LocURLInf = ReplaceList("#URLInfo#","#FindList#","#ReplList#")>
				<cfset LocUrlMhd = ReplaceList("#URLMethod#","#FindList#","#ReplList#")>
				<cfset LocOutpFl = ReplaceList("#URLOutputFile#","#FindList#","#ReplList#")>
				<cfset LocOutDir = ReplaceList("#URLOutputDir#","#FindList#","#ReplList#")>
				<cfhttp url="#LocURLInf#" method="#LocUrlMhd#">
					<cfif LocURLMhd Is "Post">
						<cfquery name="AllFormFields" datasource="#pds#">
							SELECT * 
							FROM IntFormFields 
							WHERE IntID = #IntID# 
							AND ActiveYN = 1 
						</cfquery>
						<cfloop query="AllFormFields">
							<cfif FieldType Is "File">
								<cfhttpparam type="#FieldType#" name="#FieldName#" value="#FieldValue#" file="#FieldFile#">
							<cfelse>
								<cfhttpparam type="#FieldType#" name="#FieldName#" value="#FieldValue#">
							</cfif>
						</cfloop>
						<cfif AllFormFields.RecordCount Is 0>
							<cfhttpparam type="FormField" name="FName" value="1">
						</cfif>
					</cfif>
				</cfhttp>
				<cfset LocOutput = CFHTTP.FileContent>
				<cfif Trim(LocOutpFl) Is Not "" AND Trim(LocOutDir) Is Not "">
					<cffile action="write" file="#LocOutDir##LocOutpFl#" output="#LocOutput#">
				</cfif>
			</cfif>
		<cfelseif B5 Is "C">
			<cfif CFMActiveYN Is 1>
				<cfset LocFileNm = ReplaceList("#CustomCFM#","#FindList#","#ReplList#")>
				<cfif FileExists("#cfmpath##OSType#external#OSType##LocFileNm#")>
					<cfinclude template="external#OSType##LocFileNm#">
				</cfif>				
			</cfif>
		<cfelseif B5 Is "F">
			<cfif FTPActiveYN Is 1>
				<cfset LocServer = ReplaceList("#FTPServer#","#FindList#","#ReplList#")>
				<cfset LocFTPLog = ReplaceList("#FTPLogin#","#FindList#","#ReplList#")>
				<cfset LocFTPPwd = ReplaceList("#FTPPassword#","#FindList#","#ReplList#")>
				<cfset LocFTPPth = ReplaceList("#FTPPath#","#FindList#","#ReplList#")>
				<cfset LocFTPFln = ReplaceList("#FTPFilename#","#FindList#","#ReplList#")>
				<cfset LocFTPAtn = FTPAction>
				<cfset LocFTPSPh = ReplaceList("#FTPServerPath#","#FindList#","#ReplList#")>
				<cfftp action="#LocFTPAtn#" localfile="#LocFTPPth##LocFTPFln#" 
				 server="#LocServer#" username="#LocFTPLog#" password="#LocFTPPwd#" 
				 remotefile="#LocFTPSPh##LocFTPFln#" transfermode="AUTO"> 
			</cfif>
		<cfelseif B5 Is "E">
			<cfif EMlActiveYN Is 1>
				<cfset LocServer = ReplaceList("#EMailServer#","#FindList#","#ReplList#")>
				<cfset LocSvPort = ReplaceList("#EMailServerPort#","#FindList#","#ReplList#")>
				<cfif Trim(LocSvPort) Is "">
					<cfset LocSvPort = 25>
				</cfif>
				<cfset LocEMFrom = ReplaceList("#EMailFrom#","#FindList#","#ReplList#")>
				<cfset LocEMalTo = ReplaceList("#EMailTo#","#FindList#","#ReplList#")>
				<cfset LocEmalCC = ReplaceList("#EMailCC#","#FindList#","#ReplList#")>
				<cfset LocSubjct = ReplaceList("#EMailSubject#","#FindList#","#ReplList#")>
				<cfset LocFileNm = ReplaceList("#EMailFile#","#FindList#","#ReplList#")>
				<cfset LocMessag = ReplaceList("#EMailMessage#","#FindList#","#ReplList#")>
				<cfset LocMessag = Replace(LocMessag,")*N/A*(","","All")>
				<cfif SQLRecordCount Is 0>
					<cfset LocRepeatMsg = "">
					<cfset TheRepeatStr = EMailRepeatMsg>
					<cfquery name="RepeatingData" datasource="#pds#">
						#LocCustSQL#						
					</cfquery>
					<cfquery name="PerRepeatValues" datasource="#pds#">
						SELECT UseText 
						FROM IntVariables 
						WHERE CustomYN = #IntID# 
						ORDER BY UseText 
					</cfquery>
					<cfset LoopCount = 0>
					<cfloop query="RepeatingData">
						<cfset TheNewFindList = TheFindList>
						<cfset TheNewReplList = TheReplList>
						<cfset LoopCount = LoopCount + 1>
						<cfloop query="PerRepeatValues">
							<cfset TheNewFindList = ListAppend(TheNewFindList,UseText)>
							<cfset LkVl = Replace("#UseText#","%","per")>
							<cfset NwVl = Evaluate("RepeatingData.#LkVl#[LoopCount]")>
							<cfif Trim(NwVl) Is "">
								<cfset NwVl = ")*N/A*(">
							</cfif>
							<cfset TheNewReplList = ListAppend(TheNewReplList,NwVl)>
						</cfloop>					
						<cfset LocRepeatMsg = LocRepeatMsg & ReplaceList("#TheRepeatStr#","#TheNewFindList#","#TheNewReplList#")>
						<cfset LocRepeatMsg = Replace(LocRepeatMsg,")*N/A*(","","All")>
					</cfloop>
					<cfset LocMessag = LocMessag & "
#LocRepeatMsg#">
				</cfif>
				<cfif (Trim(LocServer) Is Not "")>
					<cfloop index="B3" list="#LocEMalTo#">
						<cfif EMailDelay Is "">
							<cfif NonDemoSendEMail Is "1">
								<cfmail server="#LocServer#" port="#LocSvPort#" from="#Trim(LocEMFrom)#" 
to="#Trim(B3)#" cc="#Trim(LocEmalCC)#" subject="#LocSubjct#" mimeattach="#LocFileNm#">
#LocMessag#
</cfmail>
							</cfif>
						<cfelse>
							<cfset LocRunWhen = DateAdd("n",EMailDelay,Now() )>
							<cfquery name="SendLater" datasource="#pds#">
								INSERT INTO AutoRun 
								(Memo1, WhenRun, DoAction, AccountID, EMailID, EMailFrom, 
								 EMailSubject, EMailTo, FileAttach, EMailCC, Value1, Value2)
								VALUES 
								('#LocMessag#', #LocRunWhen#, 'EMailDelay', perA00, perE00, '#Trim(LocEMFrom)#', 
								 '#LocSubjct#', '#B3#', '#LocFileNm#','#Trim(LocEmalCC)#','#LocServer#', 
								 '#LocSvPort#')
							</cfquery>
						</cfif>
					</cfloop>	
				<cfelse>
					<cfloop index="B3" list="#LocEMalTo#">	
						<cfif EMailDelay Is "">
							<cfif NonDemoSendEMail Is "1">
								<cfmail from="#Trim(LocEMFrom)#" to="#Trim(B3)#" cc="#Trim(LocEmalCC)#" 
								 subject="#LocSubjct#" mimeattach="#LocFileNm#">
#LocMessag#
</cfmail>
							</cfif>
						<cfelse>
							<cfset LocRunWhen = DateAdd("n",EMailDelay,Now() )>
							<cfquery name="SendLater" datasource="#pds#">
								INSERT INTO AutoRun 
								(Memo1, WhenRun, DoAction, AccountID, EMailID, EMailFrom, 
								 EMailSubject, EMailTo, FileAttach, EMailCC, Value1, Value2)
								VALUES 
								('#LocMessag#', #LocRunWhen#, 'EMailDelay', perA00, perE00, '#Trim(LocEMFrom)#', 
								 '#LocSubjct#', '#B3#', '#LocFileNm#','#Trim(LocEmalCC)#','#LocServer#', 
								 '#LocSvPort#')
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<cfif EmlAttachWait gt 0>
					<cfx_wait SPAN="#EmlAttachWait#">
				</cfif>
			</cfif>
		</cfif><br>
	</cfloop>
</cfloop>
<cfsetting enablecfoutputonly="No">