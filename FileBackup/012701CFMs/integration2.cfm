<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that lists all of the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!--- integration2.cfm --->

<cfset securepage="integration.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("mvltlet") AND IsDefined("HaveLocs")>
	<cfquery name="MvLets" datasource="#pds#">
		DELETE FROM LetterAdm 
		WHERE IntID = #IntID# 
		AND AdminID In (#HaveLocs#) 
	</cfquery>
</cfif>
<cfif IsDefined("mvrtlet") AND (IsDefined("ChooseLetters"))>
	<cfloop index="B5" list="#ChooseLetters#">
		<cfif B5 GT 0>
			<cfquery name="MvLetters" datasource="#pds#">
				INSERT INTO LetterAdm 
				(IntID, AdminID)
				VALUES 
				(#IntID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("mvltloc") AND IsDefined("HaveLocs")>
	<cfquery name="MvLocs" datasource="#pds#">
		DELETE FROM IntScriptLoc 
		WHERE IntID = #IntID# 
		AND LocationID In (#HaveLocs#)
	</cfquery>
</cfif>
<cfif IsDefined("mvrtloc") AND IsDefined("ChooseLocs")>
	<cfloop index="B5" list="#ChooseLocs#">
		<cfif B5 GT 0>
			<cfquery name="MvLocations" datasource="#pds#">
				INSERT INTO IntScriptLoc 
				(IntID, LocationID) 
				VALUES 
				(#IntID#, #B5#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("ToggleDOS")>
	<cfquery name="ToggleTypeDOS" datasource="#pds#">
		UPDATE Integration SET 
		DOSActiveYN = <cfif IsDefined("DOSActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleTel")>
	<cfquery name="ToggleTypeTel" datasource="#pds#">
		UPDATE Integration SET 
		TelActiveYN = <cfif IsDefined("TelActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleSQL")>
	<cfquery name="ToggleTypeSQL" datasource="#pds#">
		UPDATE Integration SET 
		SQLActiveYN = <cfif IsDefined("SQLActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleURL")>
	<cfquery name="ToggleTypeURL" datasource="#pds#">
		UPDATE Integration SET 
		URLActiveYN = <cfif IsDefined("URLActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleCFM")>
	<cfquery name="ToggleTypeCFM" datasource="#pds#">
		UPDATE Integration SET 
		CFMActiveYN = <cfif IsDefined("CFMActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleFTP")>
	<cfquery name="ToggleTypeFTP" datasource="#pds#">
		UPDATE Integration SET 
		FTPActiveYN = <cfif IsDefined("FTPActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleEMl")>
	<cfquery name="ToggleTypeEMl" datasource="#pds#">
		UPDATE Integration SET 
		EMlActiveYN = <cfif IsDefined("EMlActiveYN")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("CurrentSort")>
	<cfset IntNum =7>
	<cfif IsDefined("DosUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","d")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","d")>
	<cfelseif IsDefined("TelUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","t")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","t")>
	<cfelseif IsDefined("SQLUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","s")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","s")>
	<cfelseif IsDefined("URLUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","u")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","u")>
	<cfelseif IsDefined("CFMUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","c")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","c")>	
	<cfelseif IsDefined("FTPUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","f")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","f")>
	<cfelseif IsDefined("EMlUp.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","e")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 - 1>
		<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","e")>
	<cfelseif IsDefined("DosDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","d")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","d")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","d")>
		</cfif>
	<cfelseif IsDefined("TelDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","t")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","t")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","t")>
		</cfif>
	<cfelseif IsDefined("SQLDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","s")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","s")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","s")>
		</cfif>
	<cfelseif IsDefined("URLDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","u")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","u")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","u")>
		</cfif>
	<cfelseif IsDefined("CFMDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","c")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","c")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","c")>
		</cfif>
	<cfelseif IsDefined("FTPDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","f")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","f")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","f")>
		</cfif>
	<cfelseif IsDefined("EMlDn.x")>
		<cfset Pos1 = ListFind("#CurrentSort#","e")>
		<cfset CurrentSort = ListDeleteAt("#CurrentSort#","#Pos1#")>
		<cfset Pos1 = Pos1 + 1>
		<cfif Pos1 Is IntNum>
			<cfset CurrentSort = ListAppend("#CurrentSort#","e")>
		<cfelse>
			<cfset CurrentSort = ListInsertAt("#CurrentSort#","#Pos1#","e")>
		</cfif>				
	</cfif>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		ScriptOrder = '#CurrentSort#' 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("mvlt") AND IsDefined("HavePlans")>
	<cfquery name="RemovePlan" datasource="#pds#">
		DELETE FROM IntPlans 
		WHERE IntID = #IntID# 
		AND PlanID In (#HavePlans#)
	</cfquery>
</cfif>
<cfif IsDefined("mvrt") AND IsDefined("ChoosePlans")>
	<cfloop index="B5" list="#ChoosePlans#">
		<cfif B5 gt 0>
			<cfquery name="AddPlan" datasource="#pds#">
				INSERT INTO IntPlans 
				(IntID, PlanID)
				VALUES 
				(#IntID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("ClearEMl")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		EmlActiveYN = 0, 
		EMailServer = Null, 
		EMailServerPort = Null, 
		EMailFrom = Null, 
		EMailTo = Null, 
		EMailCC = Null, 
		EMailSubject = Null, 
		EMailFile = Null, 
		EmlAttachWait = 0, 
		EMailMessage = Null, 
		EMailRepeatMsg = Null, 
		EMailRepeatQuery = 0, 
		EMailDelay = 0 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("EMlScriptEdit.x")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		EmlActiveYN = #EmlActiveYN#, 
		EMailServer = <cfif Trim(EMailServer) Is "">Null<cfelse>'#EMailServer#'</cfif>, 
		EMailServerPort = <cfif Trim(EMailServerPort) Is "">Null<cfelse>'#EMailServerPort#'</cfif>, 
		EMailFrom = <cfif Trim(EMailFrom) Is "">Null<cfelse>'#EMailFrom#'</cfif>, 
		EMailTo = <cfif Trim(EMailTo) Is "">Null<cfelse>'#EMailTo#'</cfif>, 
		EMailCC = <cfif Trim(EMailCC) Is "">Null<cfelse>'#EMailCC#'</cfif>, 
		EMailSubject = <cfif Trim(EMailSubject) Is "">Null<cfelse>'#EMailSubject#'</cfif>, 
		EMailFile = <cfif Trim(EMailFile) Is "">Null<cfelse>'#EMailFile#'</cfif>, 
		EmlAttachWait = #EmlAttachWait#, 
		EMailDelay = <cfif Trim(EMailDelay) Is "">Null<cfelse>#EMailDelay#</cfif>, 
		<cfif IsDefined("EMailRepeatMsg")>
			EMailRepeatMsg = <cfif Trim(EMailRepeatMsg) Is "">Null<cfelse>'#EMailRepeatMsg#'</cfif>, 
		<cfelse>
			EMailRepeatMsg = Null, 
		</cfif>
		EMailRepeatQuery = #EMailRepeatQuery#, 
		EMailMessage = <cfif Trim(EMailMessage) Is "">Null<cfelse>'#EMailMessage#'</cfif> 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("ClearFTP")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		FTPServer = Null, 
		FTPLogin = Null, 
		FTPPassword = Null, 
		FTPFilename = Null, 
		FTPAction = Null, 
		FTPPath = Null, 
		FTPServerPath = Null, 
		FTPActiveYN = 0  
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("FTPScriptEdit.x")>
	<cfset CheckChar = Right("#FTPServerPath#",1)>
	<cfif CheckChar Is "\" OR CheckChar Is "/">
		<cfset FTPSPath = FTPServerPath>
	<cfelse>
		<cfset FTPSPath = FTPServerPath & OSType>
	</cfif>
	<cfset CheckChar = Right("#FTPPath#",1)>
	<cfif CheckChar Is "\" OR CheckChar Is "/">
		<cfset LocFTPPath = FTPPath>
	<cfelse>
		<cfset LocFTPPath = FTPPath & OSType>
	</cfif>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		FTPServer = '#FTPServer#', 
		FTPLogin = '#FTPLogin#', 
		FTPPassword = '#FTPPassword#', 
		FTPFilename = '#FTPFilename#', 
		FTPAction = '#FTPAction#', 
		FTPPath = <cfif Trim(LocFTPPath) Is "">NULL<cfelse>'#LocFTPPath#'</cfif>, 
		FTPServerPath = <cfif Trim(FTPSPath) Is "">NULL<cfelse>'#FTPSPath#'</cfif>, 
		FTPActiveYN = #FTPActiveYN#
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ClearCFM")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		CustomCFM = Null, 
		CFMActiveYN = 0 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("CustomCFMPage.x")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		CustomCFM = <cfif Trim(CustomCFM) Is "">Null<cfelse>'#CustomCFM#'</cfif>, 
		CFMActiveYN = #CFMActiveYN# 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("ClearURL")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		URLInfo = Null, 
		URLMethod = Null, 
		URLOutputFile = Null, 
		URLOutputDir = Null, 
		URLActiveYN = 0 
		WHERE IntID = #IntID# 
	</cfquery>
	<cfquery name="EditFormField" datasource="#pds#">
		DELETE FROM IntFormFields 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("Delem.x") AND IsDefined("DeleteEmIds")>
	<cfquery name="RemoveFields" datasource="#pds#">
		DELETE FROM IntFormFields 
		WHERE FormFieldID In (#DeleteEmIds#)
	</cfquery>
</cfif>
<cfif IsDefined("AddFormField.x")>
	<cfquery name="AddField" datasource="#pds#">
		INSERT INTO IntFormFields 
		(IntID,FieldName,FieldType,FieldValue,FieldFile,ActiveYN)
		VALUES 
		(#IntID#,'#FieldName#','#FieldType#',
		 <cfif Trim(FieldValue) Is "">Null<cfelse>'#FieldValue#'</cfif>, 
		 <cfif Trim(FieldFile) Is "">Null<cfelse>'#FieldFile#'</cfif>, 
		 #ActiveYN#)
	</cfquery>
</cfif>
<cfif IsDefined("URLEdit.x")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		URLInfo = <cfif Trim(URLInfo) Is "">Null<cfelse>'#URLInfo#'</cfif>, 
		URLMethod = <cfif Trim(URLMethod Is "")>Null<cfelse>'#URLMethod#'</cfif>, 
		URLOutputFile = <cfif Trim(URLOutputFile) Is "">Null<cfelse>'#URLOutputFile#'</cfif>, 
		URLOutputDir = <cfif Trim(URLOutputDir) Is "">Null<cfelse>'#URLOutputDir#'</cfif>, 
		URLActiveYN = #URLActiveYN# 
		WHERE IntID = #IntID# 
	</cfquery>
	<cfif IsDefined("CountField")>
		<cfloop index="B5" from="1" to="#CountField#">
			<cfset var1 = Evaluate("FormFieldID#B5#")>
			<cfset var2 = Evaluate("ActiveYN#B5#")>
			<cfset var3 = Evaluate("FieldName#B5#")>
			<cfset var4 = Evaluate("FieldType#B5#")>
			<cfset var5 = Evaluate("FieldValue#B5#")>
			<cfif IsDefined("FieldFile#B5#")>
				<cfset var6 = Evaluate("FieldFile#B5#")>
			<cfelse>
				<cfset var6 = "">
			</cfif>
			<cfquery name="UpdateForm" datasource="#pds#">
				UPDATE IntFormFields SET 
				ActiveYN = #var2#, 
				FieldName = '#var3#', 
				FieldType = '#var4#', 
				FieldValue = <cfif Trim(var5) Is "">Null<cfelse>'#var5#'</cfif>, 
				FieldFile = <cfif Trim(var6) Is "">Null<cfelse>'#var6#'</cfif> 
				WHERE FormFieldID = #var1# 
			</cfquery>
		</cfloop>
	</cfif>
</cfif>
<cfif IsDefined("ClearSQL")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		ODBCDataSource = Null, 
		ODBCSQL = Null, 
		SQLCustomAuth = 0, 
		SQLActiveYN = 0 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("SQLEdit.x")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		ODBCDataSource = '#ODBCDataSource#', 
		ODBCSQL = <cfif Trim(ODBCSQL) Is "">Null<cfelse>'#ODBCSQL#'</cfif>, 
		SQLCustomAuth = #SQLCustomAuth#, 
		SQLActiveYN = #SQLActiveYN# 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("ClearTelnet")>
	<cfquery name="ClearScript" datasource="#pds#">
		UPDATE Integration SET 
		TelnetScript = Null,
		TelnetHost = Null, 
		TelnetLogin = Null, 
		TelnetPassword = Null, 
		TelnetSULogin = Null,
		TelnetSUPassword = Null, 
		TelnetPort = Null, 
		TelnetUseSecure = Null, 
		TelnetSecIdent = Null, 
		TelnetSecUser = Null, 
		TelnetSecCipher = Null, 
		TelnetSecAuthType = Null, 
		TelnetSecPassword = Null, 
		TelnetCSFFile = Null, 
		TelnetCFGFile = Null, 
		TelnetCMDFile = Null, 
		UseCmdProcYN = 0, 
		TelNetGTUseYN = 0, 
		TelNetGTFileName = Null, 
		TelNetGTPath = Null, 
		TelActiveYN = 0 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("TelnetScriptEdit.x")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		TelnetScript = <cfif Trim(TelnetScript) Is "">Null<cfelse>'#TelnetScript#'</cfif>,
		TelnetHost = '#TelnetHost#', 
		TelnetLogin = <cfif Trim(TelnetLogin) Is "">Null<cfelse>'#TelnetLogin#'</cfif>, 
		TelnetPassword = <cfif Trim(TelnetPassword) Is "">Null<cfelse>'#TelnetPassword#'</cfif>, 
		TelnetSULogin = <cfif Trim(TelnetSULogin) Is "">Null<cfelse>'#TelnetSULogin#'</cfif>,
		TelnetSUPassword = <cfif Trim(TelnetSUPassword) Is "">Null<cfelse>'#TelnetSUPassword#'</cfif>, 
		TelnetPort = <cfif Trim(TelnetPort) Is "">Null<cfelse>'#TelnetPort#'</cfif>, 
		TelnetUseSecure = #TelnetUseSecure#, 
		TelnetSecIdent = <cfif Trim(TelnetSecIdent) Is "">Null<cfelse>'#TelnetSecIdent#'</cfif>, 
		TelnetSecUser = <cfif Trim(TelnetSecUser) Is "">Null<cfelse>'#TelnetSecUser#'</cfif>, 
		TelnetSecCipher = <cfif Trim(TelnetSecCipher) Is "">Null<cfelse>'#TelnetSecCipher#'</cfif>, 
		TelnetSecAuthType = <cfif Trim(TelnetSecAuthType) Is "">Null<cfelse>'#TelnetSecAuthType#'</cfif>, 
		TelnetSecPassword = <cfif Trim(TelnetSecPassword) Is "">Null<cfelse>'#TelnetSecPassword#'</cfif>, 
		TelnetCSFFile = <cfif Trim(TelnetCSFFile) Is "">Null<cfelse>'#TelnetCSFFile#'</cfif>, 
		TelnetCFGFile = <cfif Trim(TelnetCFGFile) Is "">Null<cfelse>'#TelnetCFGFile#'</cfif>, 
		TelnetCMDFile = <cfif Trim(TelnetCMDFile) Is "">Null<cfelse>'#TelnetCMDFile#'</cfif>, 
		UseCmdProcYN = #UseCmdProcYN#, 
		TelNetGTUseYN = #TelNetGTUseYN#, 
		TelNetGTFileName = <cfif Trim(TelNetGTFileName) Is "">Null<cfelse>'#TelNetGTFileName#'</cfif>, 
		TelNetGTPath = <cfif Trim(TelNetGTPath) Is "">Null<cfelse>'#TelNetGTPath#'</cfif>, 
		TelActiveYN = #TelActiveYN# 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("ClearDOS")>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		DOSFileName = Null, 
		DOSAction = Null, 
		DOSScript = Null, 
		DOSFileDir = Null, 
		DosCopyFrom = Null,  
		DOSDelay = Null, 
		DOSActiveYN = 0 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("DOSScriptEdit.x")>
	<cfif Trim(DOSFileDir) Is "">
		<cfset LocFileDir = "Null">
	<cfelse>
		<cfset CheckChar = Right("#DOSFileDir#",1)>
		<cfif (CheckChar Is Not "\") AND (CheckChar Is Not "/")>
			<cfset LocFileDir = DOSFileDir & OSType>
		<cfelse>
			<cfset LocFileDir = DOSFileDir>
		</cfif>
	</cfif>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		DOSFileName = <cfif Trim(DOSFileName) Is "">Null<cfelse>'#DOSFileName#'</cfif>, 
		DOSAction = '#DOSAction#', 
		DOSActiveYN = #DosActiveYN#, 
		DOSDelay = <cfif Trim(DOSDelay) Is "">Null<cfelse>#DOSDelay#</cfif>, 
		DOSFileDir = <cfif LocFileDir Is "Null">Null<cfelse>'#LocFileDir#'</cfif>, 
		DosCopyFrom =<cfif DosCopyFrom Is "">Null<cfelse>'#DosCopyFrom#'</cfif>, 
		DOSScript = <cfif Trim(DOSScript) Is "">Null<cfelse>'#DOSScript#'</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("EditCustomVars.x")>
	<cfset CustomSQLScript = "SELECT ">
	<cfset CountVar = 100>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM IntVariables 
		WHERE CustomYN = #IntID#
	</cfquery>
	<cfloop index="B5" list="#CustomSQLSelect#">
		<cfset CustomSQLScript = CustomSQLScript & "#B5# as perAA#CountVar#, ">
		<cfif Trim(CustomDS) Is Not "">
			<cfquery name="InsertNew" datasource="#pds#">
				INSERT INTO IntVariables 
				(UseText,ForText,CustomYN)
				VALUES 
				('%AA#CountVar#','#B5#',#IntID#)
			</cfquery>
		</cfif>
		<cfset CountVar = CountVar + 1>
	</cfloop>
	<cfset Len1 = Len(CustomSQLScript) - 2>
	<cfset CustomSQLScript = Left(CustomSQLScript,Len1)>
	<cfset CustomSQLScript = CustomSQLScript & "
FROM #CustomSQLFrom#
WHERE #CustomSQLWhere#">
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		CustomDS = <cfif Trim(CustomDS) Is "">Null<cfelse>'#CustomDS#'</cfif>, 
		<cfif Action Is "Letter">
			SQLRecordCount = #SQLRecordCount#, 
		<cfelse>
			SQLRecordCount = 1, 
		</cfif>
		CustomSQL = <cfif Trim(CustomSQLScript) Is "">Null<cfelse>'#CustomSQLScript#'</cfif> 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("EditScript.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT Action 
		FROM Integration 
		WHERE IntID = #IntID#
	</cfquery>
	<cfif CheckFirst.Action Is Not "#Action#">
		<cfquery name="GetSort" datasource="#pds#">
			SELECT SortOrder 
			FROM Integration 
			WHERE Action = '#Action#' 
		</cfquery>
		<cfset NewSort = GetSort.RecordCount + 1>
		<cfquery name="GetAllOldSort" datasource="#pds#">
			SELECT IntID as OldID 
			FROM Integration 
			WHERE Action = '#CheckFirst.Action#' 
			AND IntID <> #IntID#
			ORDER BY SortOrder
		</cfquery>
		<cfset SortCounter = 1>
		<cfloop query="GetAllOldSort">
			<cfquery name="SetNewSort" datasource="#pds#">
				UPDATE Integration SET 
				SortOrder = #SortCounter# 
				WHERE IntID = #OldID#
			</cfquery>
			<cfset SortCounter = SortCounter + 1>
		</cfloop>
	</cfif>
	<cfquery name="EditScript" datasource="#pds#">
		UPDATE Integration SET 
		Action = '#Action#', 
		TypeID = #TypeID#, 
		IntDesc = '#IntDesc#', 
		<cfif IsDefined("NewSort")>
			SortOrder = #NewSort#, 
		</cfif>
		ActiveYN = #ActiveYN# 
		WHERE IntID = #IntID# 
	</cfquery>
</cfif>
<cfif IsDefined("AddNewScript.x")>
	<cftransaction>
		<cfquery name="GetSort" datasource="#pds#">
			SELECT SortOrder 
			FROM Integration 
			WHERE Action = '#Action#' 
		</cfquery>
		<cfset NewSort = GetSort.RecordCount + 1>
		<cfquery name="AddScript" datasource="#pds#">
			INSERT INTO Integration 
			(Action, TypeID, IntType, ActiveYN, SortOrder, IntDesc, DOSActiveYN, TelActiveYN, SQLActiveYN, URLActiveYN, CFMActiveYN, FTPActiveYN, EMlActiveYN, ScriptOrder) 
			VALUES 
			('#Action#',#TypeID#,'0',#ActiveYn#,#NewSort#, '#IntDesc#',0,0,0,0,0,0,0,'d,t,s,u,c,f,e')
		</cfquery>
		<cfquery name="GetID" datasource="#pds#">
			SELECT max(IntID) as MaxID 
			FROM Integration 
		</cfquery>
		<cfset IntID = GetID.MaxID>
	</cftransaction>
</cfif>
<cfparam name="IntID" default="0">
<cfparam name="Tab" default="1">
<cfif Tab Is 1>
	<cfquery name="AllTypes" datasource="#pds#">
		SELECT TypeStr, TypeID 
		FROM IntTypes 
		WHERE ActiveYN = 1 
		AND TypeStr <> 'EMail Letter'
	</cfquery>
</cfif>
<cfif Tab Is 11>
	<cfquery name="GetAvailPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In 
			(SELECT PlanID 
			 FROM IntPlans 
			 WHERE IntID = #IntID#) 
		ORDER BY PlanDesc 
	</cfquery>
	<cfquery name="GetSelectable" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID Not In 
			(SELECT PlanID 
			 FROM IntPlans 
			 WHERE IntID = #IntID#) 
		ORDER BY PlanDesc 
	</cfquery>
</cfif>
<cfparam name="IntTypeSetup" default="Auth">
<cfquery name="OneScript" datasource="#pds#">
	SELECT * 
	FROM Integration 
	WHERE IntID = #IntID# 
</cfquery>
<cfif OneScript.Recordcount GT 0>
	<cfset IntTypeSetup = OneScript.Action>
</cfif>
<cfif Tab Is 5>
	<cfif OneScript.URLMethod Is "post">
		<cfquery name="AllFormFields" datasource="#pds#">
			SELECT * 
			FROM IntFormFields 
			WHERE IntID = #IntID# 
			ORDER BY FieldName 
		</cfquery>
	</cfif>
</cfif>
<cfif Tab Is 6>
	<cfset cfmpath = GetDirectoryFromPath(CF_TEMPLATE_PATH)>
</cfif>
<cfif Tab lt 10>
	<cfquery name="GetVars" datasource="#pds#">
		SELECT * 
		FROM IntVariables V, IntVarTypes T 
		WHERE V.VariableID = T.VariableID 
		AND T.TypeID = 
			 	(SELECT TypeID 
				 FROM Integration 
				 WHERE IntID = #IntID#)
		AND V.CustomYN = 0 
		AND V.ShowListYN = 1 
		<cfif OneScript.Action Is "Create">
			AND UseCreateYN = 1
		<cfelseif OneScript.Action Is "Delete">
			AND UseDeleteYN = 1
		<cfelseif OneScript.Action Is "Change">
			AND UseChangeYN = 1
		</cfif>
		ORDER BY UseText
	</cfquery>
	<cfquery name="PerCustomValues" datasource="#pds#">
		SELECT * 
		FROM IntVariables 
		WHERE CustomYN = #IntID# 
		ORDER BY UseText 
	</cfquery>	
</cfif>
<cfif Tab Is 12>
	<cfquery name="GetAvailLocs" datasource="#pds#">
		SELECT L.LocationID, L.PageDesc, PageName 
		FROM IntLocations L, IntScriptLoc S
		WHERE L.LocationID = S.LocationID 
		AND S.IntID = #IntID# 
		ORDER BY L.PageDesc 
	</cfquery>
	<cfquery name="GetSelectable" datasource="#pds#">
		SELECT LocationID, PageDesc, PageName 
		FROM IntLocations 
		<cfif GetAvailLocs.RecordCount GT 0>
			WHERE LocationID Not In
				(SELECT L.LocationID 
				 FROM IntLocations L, IntScriptLoc S
				 WHERE L.LocationID = S.LocationID 
				 AND S.IntID = #IntID# )
		</cfif>
		ORDER BY PageDesc 
	</cfquery>
</cfif>
<cfif Tab Is 13>
	<cfquery name="GetAvailLetters" datasource="#pds#">
		SELECT A.FirstName, A.LastName, S.AdminID 
		FROM Accounts A, Admin S, LetterAdm L 
		WHERE A.AccountID = S.AccountID 
		AND S.AdminID = L.AdminID 
		AND L.IntID = #IntID# 
		ORDER BY A.LastName, A.FirstName 
	</cfquery>
	<cfquery name="GetSelectable" datasource="#pds#">
		SELECT A.FirstName, A.LastName, S.AdminID
		FROM Accounts A, Admin S 
		WHERE A.AccountID = S.AccountID 
		<cfif GetAvailLetters.RecordCount GT 0>
			AND S.AdminID Not In
				(SELECT S.AdminID 
				 FROM Accounts A, Admin S, LetterAdm L 
				 WHERE A.AccountID = S.AccountID 
				 AND S.AdminID = L.AdminID 
				 AND L.IntID = #IntID#)
		</cfif>
		ORDER BY A.LastName, A.FirstName  
	</cfquery>
</cfif>
<cfif Tab Is 9>
	<cfquery name="GetSQLQueries" datasource="#pds#">
		SELECT DescripTitle, QueryID 
		FROM IntQueries 
		WHERE ActiveYN = 1 
		ORDER BY SortOrder, DescripTitle 
	</cfquery>
</cfif>
<cfparam name="ScriptSortOrder" default="d,t,s,u,c,f,e">
<cfif OneScript.ScriptOrder Is Not "">
	<cfset ScriptSortOrder = OneScript.ScriptOrder>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif IntTypeSetup Is "Letter">
	<title>Edit Letter</TITLE>
<cfelse>
	<title>Edit Script</title>
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="integration.cfm">
	<cfif IntTypeSetup Is "Letter">
		<input type="hidden" name="tab" value="2">
	<cfelse>
		<input type="hidden" name="tab" value="1">
	</cfif>
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Script - #OneScript.IntDesc#</font></th>
	</tr>
	<tr>
		<th colspan="4">
			<table border="1">
			</cfoutput>
				<tr>
					<cfoutput>
						<cfif IntTypeSetup Is "Letter">
							<cfset Tab2Layout = "Letter">
							<form method="post" action="integration2.cfm">
								<input type="hidden" name="IntID" value="#IntID#">
								<td bgcolor=<cfif tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 1>checked</cfif> value="1" onclick="submit()" id="tab1"><label for="tab1">General</label><cfelse>General</cfif></td>
								<td bgcolor=<cfif tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 2>checked</cfif> value="2" onclick="submit()" id="tab2"><label for="tab2">Custom Variables</label><cfelse>Custom Variables</cfif></td>
								<td bgcolor=<cfif tab Is 9>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 9>checked</cfif> value="9" onclick="submit()" id="tab9"><label for="tab9">EMail</label><cfelse>EMail</cfif></td>
								<td bgcolor=<cfif tab Is 13>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 13>checked</cfif> value="13" onclick="submit()" id="tab13"><label for="tab13">Staff</label><cfelse>Staff</cfif></td>
							</form>
						<cfelse>
							<cfset Tab2Layout = "NonLetter">
							<form method="post" action="integration2.cfm">
								<input type="hidden" name="IntID" value="#IntID#">
								<td bgcolor=<cfif tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><input type="radio" name="tab" <cfif tab Is 1>checked</cfif> value="1" onclick="submit()" id="tab1"><label for="tab1"><font size="2">General</font></label></td>
								<td bgcolor=<cfif tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 2>checked</cfif> value="2" onclick="submit()" id="tab2"><label for="tab2"><font size="2">Custom</font></label><cfelse><font size="2">Custom</font></cfif></td>
								<td bgcolor=<cfif tab Is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 3>checked</cfif> value="3" onclick="submit()" id="tab3"><label for="tab3"><font size="2">Telnet</font></label><cfelse><font size="2">Telnet</font></cfif></td>
								<td bgcolor=<cfif tab Is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 4>checked</cfif> value="4" onclick="submit()" id="tab4"><label for="tab4"><font size="2">Batch</font></label><cfelse><font size="2">Batch</font></cfif></td>
								<td bgcolor=<cfif tab Is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 5>checked</cfif> value="5" onclick="submit()" id="tab5"><label for="tab5"><font size="2">URL</font></label><cfelse><font size="2">URL</font></cfif></td>
								<td bgcolor=<cfif tab Is 6>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 6>checked</cfif> value="6" onclick="submit()" id="tab6"><label for="tab6"><font size="2">CFM</font></label><cfelse><font size="2">CFM</font></cfif></td>
								<td bgcolor=<cfif tab Is 7>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 7>checked</cfif> value="7" onclick="submit()" id="tab7"><label for="tab7"><font size="2">FTP</font></label><cfelse><font size="2">FTP</font></cfif></td>
								<td bgcolor=<cfif tab Is 8>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 8>checked</cfif> value="8" onclick="submit()" id="tab8"><label for="tab8"><font size="2">SQL</font></label><cfelse><font size="2">SQL</font></cfif></td>
								<td bgcolor=<cfif tab Is 9>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 9>checked</cfif> value="9" onclick="submit()" id="tab9"><label for="tab9"><font size="2">EMail</font></label><cfelse><font size="2">EMail</font></cfif></td>
								<td bgcolor=<cfif tab Is 10>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 10>checked</cfif> value="10" onclick="submit()" id="tab10"><label for="tab10"><font size="2">Order</font></label><cfelse><font size="2">Order</font></cfif></td>
								<td bgcolor=<cfif tab Is 11>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 11>checked</cfif> value="11" onclick="submit()" id="tab11"><label for="tab11"><font size="2">Plans</font></label><cfelse><font size="2">Plans</font></cfif></td>
								<td bgcolor=<cfif tab Is 12>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> nowrap><cfif IntID gt 0><input type="radio" name="tab" <cfif tab Is 12>checked</cfif> value="12" onclick="submit()" id="tab12"><label for="tab12"><font size="2">Locations</font></label><cfelse><font size="2">Locations</font></cfif></td>
							</form>
						</cfif>
					</cfoutput>
				</tr>
			</table>
		</th>
	</tr>
	<tr>
		<th colspan="4">
<cfif tab Is 1>
	<cfinclude template="int1.cfm">
<cfelseif tab Is 2>
	<cfinclude template="int2.cfm">
<cfelseif tab Is 3>
	<cfinclude template="int3.cfm">
<cfelseif tab Is 4>
	<cfinclude template="int4.cfm">
<cfelseif tab Is 5>
	<cfinclude template="int5.cfm">
<cfelseif tab Is 6>
	<cfinclude template="int6.cfm">
<cfelseif tab Is 7>
	<cfinclude template="int7.cfm">
<cfelseif tab Is 8>
	<cfinclude template="int8.cfm">
<cfelseif tab Is 9>
	<cfinclude template="int9.cfm">
<cfelseif tab Is 10>
	<cfinclude template="int10.cfm">
<cfelseif tab Is 11>
	<cfinclude template="int11.cfm">
<cfelseif tab Is 12>
	<cfinclude template="int12.cfm">
<cfelseif tab Is 13>
	<cfinclude template="int13.cfm">
</cfif>
		</th>
	</tr>
<cfif (Tab lt 10) AND (Tab gt 1)>
	<cfoutput>
		<tr>
			<td align="center" bgcolor="#thclr#" colspan="4">Script Variables</td>
		</tr>
		</cfoutput>
		<cfset LoopCnt = 1>
		<cfoutput query="GetVars">
			<cfif LoopCnt Is 1><tr bgcolor="#tbclr#"></cfif>
				<td><font size="2">#UseText# = #ForText#</font></td>
				<cfset LoopCnt = LoopCnt + 1>
			<cfif LoopCnt Is 5></tr><cfset LoopCnt = 1></cfif>
		</cfoutput>
			<cfif LoopCnt Is 4>
				<td>&nbsp;</td></tr>
			<cfelseif LoopCnt Is 3>
				<td>&nbsp;</td><td>&nbsp;</td></tr>
			<cfelseif LoopCnt Is 2>
				<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
			</cfif>
		<cfset LoopCnt = 1>
		<cfif (PerCustomValues.RecordCount gte 1) AND (Tab GT 2)>
			<tr>
				<cfoutput>
					<td bgcolor="#thclr#" align="center" colspan="4">Custom Variables For Script - #OneScript.IntDesc# - <cfif OneScript.SQLRecordCount Is "1">Single Record<cfelseif OneScript.SQLRecordCount Is "0">Multiple Records</cfif></td>
				</cfoutput>
			</tr>		
			<cfoutput query="PerCustomValues">
				<cfif LoopCnt Is 1><tr bgcolor="#tbclr#"></cfif>
					<td><font size="2">#UseText# = #ForText#</font></td>
					<cfset LoopCnt = LoopCnt + 1>
				<cfif LoopCnt Is 5></tr><cfset LoopCnt = 1></cfif>
			</cfoutput>
			<cfif LoopCnt Is 4>
				<td>&nbsp;</td></tr>
			<cfelseif LoopCnt Is 3>
				<td>&nbsp;</td><td>&nbsp;</td></tr>
			<cfelseif LoopCnt Is 2>
				<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
			</cfif>
		</cfif>
</cfif>
</table>

</center>
<cfinclude template="footer.cfm">
</body>
</html>
  