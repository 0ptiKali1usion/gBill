<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that runs all of the scripts. 
		Needed Parameters
			Action = Change/Create/Delete
			IntType = Comma seperated list of Types to run
			LocScriptID = The IntID of the script to run
		Optional Parameters
			LocAccountID
			LocAccntPlanID
			LocAliasID
			LocAuthID
			LocEMailID
			LocFTPID
			LocDomainID
			LocDomainType
			LocOldPassword
			LocPlanID
			LocPOPId			
--->
<!--- 4.0.0 06/21/99 --->
<!--- runintegration.cfm --->

<cfinclude template="runvarvalues.cfm">
<cfquery name="DefAuthSetup" datasource="#pds#">
	SELECT CAuthID 
	FROM CustomAuth 
	WHERE DefaultYN = 1 
</cfquery>
<cfparam name="LocSendCAuthID" default="#DefAuthSetup.CAuthID#">
<cfquery name="AllScripts" datasource="#pds#">
	SELECT I.* 
	FROM Integration I 
	WHERE I.IntID In (#LocScriptID#) 
	ORDER BY SortOrder 
</cfquery>
<cfset TheFindList = FindList>
<cfset TheReplList = ReplList>
<!--- Start running the actual scripts --->
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
				<cfif LocAction Is "Exec">
					<cfif Trim(LocFileDr) Is "">
						<cfset LocFileDr = BillPath>
					</cfif>
					<cffile action="WRITE" file="#LocFileDr##LocFileNm#" output="#LocScript#">
					<cfexecute name="#LocFileDr##LocFileNm#" timeout="30">
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
				<cfset MyOutput = "Default">
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
				
				<cfset File1 = LocFileName1 & ".csf">
				<cfset File2 = LocFileName2 & ".cfg">
				<cfset File3 = LocFileName3 & ".tmp">
				<cfset File4 = LocFileName3 & ".cmd">

				<cfparam name="usesecure" default="#YesNoFormat(LocUseSecure)#">
				<cfparam name="secureuser" default="#Trim(LocSecUser)#">
				<cfparam name="securecipher" default="#Trim(LocCipher)#">
				<cfparam name="secureident" default="#Trim(LocIdentity)#">
				<cfparam name="secureport" default="#LocPort#"> 
				<cfset cmdstr = "/f #file2# /s #MyOutput#">

				<cffile action="Write" file="#File1#" output="#LocScript#">
				
				<cfif usesecure Is "YES">
					<cfset cmdstr = cmdstr & " /SSH /L #secureuser#">
					<cfif SecureIdent Is Not "">
						<cfset cmdstr = cmdstr & " /I #secureident#">
					</cfif>
					<cfset cmdstr = cmdstr & " /C #securecipher# /P #secureport#">
					<cfset TheOutput = "[Default]
Protocol Name=ssh
Hostname=#LocTlHost#
Port=00000016
Username=#secureuser#
">
					<cfif LocCRTAuth Is "Password">
						<cfset TheOutput = TheOutput & "PasswordV2=#LocCRTPassw#
">
					</cfif>
					<cfset TheOutput = TheOutput & "Cipher=#securecipher#
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
					<cffile action="Write" file="#File2#" output="[Default]
Protocol Name=telnet
Color Scheme=Monochrome
Normal Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
Narrow Font=97,-13,0,0,0,400,0,0,0,1,0,0,0,1,vt100
	
[#MyOutput#]
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

				<cfexecute name="#File4#" arguments="#cmdstr#" timeout="35">
				</cfexecute>

			</cfif>				
		<cfelseif B5 Is "S">
			<cfif SQLActiveYN Is 1>
				<cfset LocUseCus = SQLCustomAuth>
				<cfset LocDataSr = ReplaceList("#ODBCDataSource#","#FindList#","#ReplList#")>
				<cfset LocScript = ReplaceList("#ODBCSQL#","#FindList#","#ReplList#")>
				<cfset LocScript = Replace("#LocScript#","''","'","All")>
				<cfif LocUseCus Is 0>
					<cfquery name="IntegrationSQL" datasource="#LocDataSr#">
						#Replace("#LocScript#","''","'","All")#
					</cfquery>
				<cfelse>
					<!--- Use the Custom Authentication --->
					<cfset SendCAuthID = LocSendCAuthID>
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
				 remotefile="#LocFTPSPh##LocFTPFln#"> 
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
								('#LocMessage#', #LocRunWhen#, 'EMailDelay', perA00, perE00, '#Trim(LocEMFrom)#', 
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
								('#LocMessage#', #LocRunWhen#, 'EMailDelay', perA00, perE00, '#Trim(LocEMFrom)#', 
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

<cfsetting enablecfoutputonly="no">
 