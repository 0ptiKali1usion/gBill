<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page does the database updates when called by one of the plan tabs.
--->
<!---	4.0.0 07/16/99 Seperated General From Financial 
		3.2.1 09/10/98 Moved IPAD Auth to the Integration Tab 
		3.2.0 09/08/98 --->
<!--- listplan3.cfm --->
<!--- tab 1 --->
<cfif IsDefined("AddNewPlan.x")>
	<cfquery name="MailPathinfo" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'IPADmailpath' 
	</cfquery>
	<cftransaction>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO Plans 
			(PlanDesc,RecurringAmount,FixedAmount,RecurringCycle,ProratePYN,
			 Taxable,ShowYN,SessYN,PayHistYN,ExpireDays,ExpireTo,EMailLetterID,
			 ShowAWYN,CustInfoYN,CustPayYN,CustPOPYN,CustPassYN,CustEMailYN,
			 CustEventYN,FreeEmails,CustLinkURL,RecurDiscount,FixedDiscount,
			 SynchBillingYN,SynchDays,ProrateCutDays,ReminderLetterID,AWPostOptYN,OSPostOptYN,
			 OSPostOptDef,PayDueDays,DeactDays,AWPostOptDef,AutoActCC,AutoActCD,AutoActCK,
			 AWPayCK,AWPayCD,AWPayCC,OSPayCK,OSPayCD,OSPayCC,AutoActPO,AWPayPO,OSPayPO,
			 AWChrgPostYN,AWChrgAmount,OSChrgPostYN,OSChrgAmount,MeteredYN,Radius,EMailYN,FTPYN,
			 TotalInternetCode,OSUseADebit,AWUseADebit,OSUseAVS,AWUseAVS,OSChkMod,AWChkMod,AuthNumber,
			 FTPNumber,AuthMinLogin,AuthMaxLogin,AuthMinPassw,AuthMaxPassw,AuthMixPassw,
			 LowerAWYN,LowerOSYN,AWStaticIPYN,OSStaticIPYN,SessHistKeep,HoursUp,EMailWarn,
			 WebHostYN,EMailMatchYN,EMailLogDiffYN,MailMinLogin,MailMaxLogin,MailMinPassw,
			 MailMaxPassw,MailMixPassw,MailBoxLimit,EMailAliasYN,MailBox,AWMailLower,OSMailLower,
			 FTPMatchYN,Read1,Write1,Create1,Delete1,Mkdir1,Rmdir1,Noredir1,Anydir1,Anydrive1,Nodrive1,
			 Putany1,Super1,FTPMinLogin,FTPMaxLogin,FTPMinPassw,FTPMaxPassw,FTPMixPassw,AWFTPLower,
			 OSFTPLower,Max_Idle,Max_Connect,EMailDelayMins,Taxable2,Taxable3,Taxable4,CustLinkGraphic,
			 AWChrgPostRecYN,AWChrgPostTax,AWChrgPostMemo,AWPlanDisplay,OSChrgPostRecYN,OSChrgPostTax,
			 OSChrgPostMemo,OSPlanDisplay,WarningLetterID,Max_Logins)
			VALUES 
			('#PlanDesc#',0,0,1,0,
			 1,#ShowYN#,#SessYN#,#PayHistYN#,<cfif Trim(ExpireDays) Is "">0<cfelse>#ExpireDays#</cfif>,#ExpireTo#,#EMailLetterID#,
			 #ShowAWYN#,#CustInfoYN#,#CustPayYN#,#CustPOPYN#,#CustPassYN#,#CustEMailYN#,
			 #CustEventYN#,1,<cfif Trim(CustLinkURL) Is "">Null<cfelse>'#CustLinkURL#'</cfif>,0,0,
			 1,'1',5,#EMailLetterID#,1,1,
			 0,10,20,0,1,0,0,
			 1,1,1,0,0,1,0,0,0,
			 0,0,0,0,0,1,1,1,
			 <cfif Trim(TotalInternetCode) Is "">Null<cfelse>'#TotalInternetCode#'</cfif>,0,0,0,0,0,0,1,
			 1,3,8,5,8,1,
			 0,0,0,0,90,1,0,
			 0,1,0,3,8,5,8,1,1000,0,
			 <cfif MailPathInfo.RecordCount Is "">Null<cfelse>'#MailPathInfo.Value1#'</cfif>, 
			 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,3,8,5,8,1,0,0,0,0,
			 <cfif Trim(EMailDelayMins) Is "">0<cfelse>#EMailDelayMins#</cfif>,0,0,0,
			 <cfif Trim(CustLinkGraphic) Is "">Null<cfelse>'#CustLinkGraphic#'</cfif>,
			 0,0,Null,Null,0,0,Null,<cfif Trim("OSPlanDisplay") Is "">Null<cfelse>'#OSPlanDisplay#'</cfif>,
			 #EMailLetterID#,1)
		</cfquery>
		<cfquery name="GetID" datasource="#pds#">
			SELECT max(PlanID) as maxid 
			FROM Plans
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the plan - #PlanDesc#.')
			</cfquery>
		</cfif>		
		<cfset PlanID = GetID.MaxID>
	</cftransaction>
	<cfquery name="AddDomains" datasource="#pds#">
		INSERT INTO DomPlans 
		(PlanID, DomainID) 
		SELECT #PlanID#, DomainID 
		FROM Domains 
		WHERE Primary1 = 1
	</cfquery>
</cfif>
<cfif IsDefined("UpdTab1.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Plans SET 
		PlanDesc = '#PlanDesc#', 
		OSPlanDisplay = <cfif Trim("OSPlanDisplay") Is "">Null<cfelse>'#OSPlanDisplay#'</cfif>, 
		ExpireDays = #ExpireDays#, 
		ExpireTo = #ExpireTo#, 
		Showyn = #Showyn#, 
		SessYN = #SessYN#, 
		PayHistYN = #PayHistYN#, 
		EMailLetterID = #EMailLetterID#, 
		EMailDelayMins = <cfif Trim(EMailDelayMins) Is "">0<cfelse>#EMailDelayMins#</cfif>, 
		ShowAWYN = #ShowAWYN#, 
		CustInfoYN = #CustInfoYN#, 
		CustPayYN = #CustPayYN#, 
		CustPOPYN = #CustPOPYN#, 
		CustPassYN = #CustPassYN#, 
		CustEMailYN = #CustEMailYN#, 
		CustEventYN = #CustEventYN#, 
		TotalInternetCode = <cfif Trim(TotalInternetCode) Is "">Null<cfelse>'#TotalInternetCode#'</cfif>, 
		CustLinkURL = <cfif Trim(CustLinkURL) Is "">Null<cfelse>'#CustLinkURL#'</cfif>, 
		CustLinkGraphic = <cfif Trim(CustLinkGraphic) Is "">Null<cfelse>'#CustLinkGraphic#'</cfif> 
		WHERE PlanID = #PlanID#
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the general tab of the plan - #PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 2 --->
<cfif IsDefined("updtab2.x")>
	<cfset TheRAmount = LSParseNumber(#RecurringAmount#)>
	<cfset TheFAmount = LSParseNumber(#FixedAmount#)>
	<cfset TheRDisc = LSParseNumber(#RecurDiscount#)>
	<cfset TheFDisc = LSParseNumber(#FixedDiscount#)>
	<cfset TheAWChrg = LSParseNumber(#AWChrgAmount#)>
	<cfset TheOSChrg = LSParseNumber(#OSChrgAmount#)>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE PLANS SET
		RECURRINGAMOUNT = #TheRAmount#, 
		RAMEMO = <cfif Trim(RAMEMO) Is "">Null<cfelse>'#RAMEMO#'</cfif>,
		FIXEDAMOUNT = #TheFAmount#,
		FAMEMO = <cfif Trim(FAMEMO) Is "">Null<cfelse>'#FAMEMO#'</cfif>,
		RECURDISCOUNT = #TheRDisc#,
		RDMEMO = <cfif Trim(RDMEMO) Is "">Null<cfelse>'#RDMEMO#'</cfif>,
		FIXEDDISCOUNT = #TheFDisc#,
		FDMEMO = <cfif Trim(FDMEMO) Is "">Null<cfelse>'#FDMEMO#'</cfif>,
		RECURRINGCYCLE = #RECURRINGCYCLE#,
		TAXABLE = <cfif Not IsDefined("TAXABLE")>0<cfelse>#TAXABLE#</cfif>, 
		TAXABLE2 = <cfif Not IsDefined("TAXABLE2")>0<cfelse>#TAXABLE2#</cfif>, 
		TAXABLE3 = <cfif Not IsDefined("TAXABLE3")>0<cfelse>#TAXABLE3#</cfif>, 
		TAXABLE4 = <cfif Not IsDefined("TAXABLE4")>0<cfelse>#TAXABLE4#</cfif>, 
		PAYDUEDAYS = <cfif Trim(PayDueDays) Is "">10<cfelse>#PAYDUEDAYS#</cfif>,
		DEACTDAYS = <cfif Trim(DeactDays) Is "">20<cfelse>#DEACTDAYS#</cfif>,
		SYNCHBILLINGYN = #SYNCHBILLINGYN#,
		SYNCHDAYS = <cfif Trim(SYNCHDAYS) Is "">'1'<cfelse>'#SYNCHDAYS#'</cfif>, 
		PRORATEPYN = #PRORATEPYN#, 
		PRORATECUTDAYS = <cfif Trim(PRORATECUTDAYS) Is "">5<cfelse>#PRORATECUTDAYS#</cfif>, 
		REMINDERLETTERID = #REMINDERLETTERID#, 
		AWPOSTOPTYN = #AWPOSTOPTYN#, 
		AWPOSTOPTDEF = #AWPOSTOPTDEF#, 
		AWCHRGPOSTYN = #AWCHRGPOSTYN#, 
		AWCHRGAMOUNT = #TheAWChrg#, 
		AWChrgPostRecYN = #AWChrgPostRecYN#, 
		AWChrgPostTax = #AWChrgPostTax#, 
		AWChrgPostMemo = <cfif Trim("AWChrgPostMemo") Is "">Null<cfelse>'#AWChrgPostMemo#'</cfif>, 
		AWPlanDisplay = <cfif Trim("AWPlanDisplay") Is "">Null<cfelse>'#AWPlanDisplay#'</cfif>, 
		AWPAYCK = <cfif IsDefined("AWPAYCK")>1<cfelse>0</cfif>, 
		AWPAYCD = <cfif IsDefined("AWPAYCD")>1<cfelse>0</cfif>, 
		AWPAYCC = <cfif IsDefined("AWPAYCC")>1<cfelse>0</cfif>, 
		AWPAYPO = <cfif IsDefined("AWPAYPO")>1<cfelse>0</cfif>, 
		OSPOSTOPTYN = #OSPOSTOPTYN#, 
		OSPOSTOPTDEF = #OSPOSTOPTDEF#, 
		OSCHRGPOSTYN = #OSCHRGPOSTYN#, 
		OSCHRGAMOUNT = #TheOSChrg#, 
		OSChrgPostRecYN = #OSChrgPostRecYN#, 
		OSChrgPostTax = #OSChrgPostTax#, 
		OSChrgPostMemo = <cfif Trim("OSChrgPostMemo") Is "">Null<cfelse>'#OSChrgPostMemo#'</cfif>, 
		OSPAYCK = <cfif IsDefined("OSPAYCK")>1<cfelse>0</cfif>,
		OSPAYCD = <cfif IsDefined("OSPAYCD")>1<cfelse>0</cfif>,
		OSPAYCC = <cfif IsDefined("OSPAYCC")>1<cfelse>0</cfif>,
		OSPAYPO = <cfif IsDefined("OSPAYPO")>1<cfelse>0</cfif>,
		AUTOACTCK = <cfif IsDefined("AUTOACTCK")>1<cfelse>0</cfif>,
		AUTOACTCD = <cfif IsDefined("AUTOACTCD")>1<cfelse>0</cfif>,
		AUTOACTCC = <cfif IsDefined("AUTOACTCC")>1<cfelse>0</cfif>,
		AUTOACTPO = <cfif IsDefined("AUTOACTPO")>1<cfelse>0</cfif>, 
		OSUseADebit = <cfif IsDefined("OSUseADebit")>1<cfelse>0</cfif>, 
		AWUseADebit = <cfif IsDefined("AWUseADebit")>1<cfelse>0</cfif>, 
		OSUseAVS = <cfif IsDefined("OSUseAVS")>1<cfelse>0</cfif>, 
		AWUseAVS = <cfif IsDefined("AWUseAVS")>1<cfelse>0</cfif>, 
		OSChkMod = <cfif IsDefined("OSChkMod")>1<cfelse>0</cfif>, 
		AWChkMod = <cfif IsDefined("AWChkMod")>1<cfelse>0</cfif> 
		WHERE PlanID = #PlanID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the financial tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
	<cfquery name="Reset" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE PlanID = #PlanID# 
	</cfquery>
	<cfif IsDefined("AWCardType")>
		<cfloop index="B5" list="#AWCardType#">
			<cfquery name="CheckFirst" datasource="#pds#">
				INSERT INTO PlanCCTypes 
				(PlanID,CardTypeID,WizardType) 
				VALUES
				(#PlanID#,#B5#,'AW')
			</cfquery>
		</cfloop>
	</cfif>
	<cfif IsDefined("OSCardType")>
		<cfloop index="B5" list="#OSCardType#">
			<cfquery name="CheckFirst" datasource="#pds#">
				INSERT INTO PlanCCTypes 
				(PlanID,CardTypeID,WizardType) 
				VALUES
				(#PlanID#,#B5#,'OS')
			</cfquery>
		</cfloop>
	</cfif>
</cfif>
<!--- tab 3 --->
<cfif IsDefined("UpdateTab3.x")>
	<cfif IsDefined("Start_Dir")>
		<cfset CheckChar = Right(Start_Dir,1)>
		<cfif (CheckChar Is Not "/") AND (CheckChar Is Not "\")>
			<cfset TheStartDir = Start_Dir & OSType>
		<cfelse>
			<cfset TheStartDir = Start_Dir>
		</cfif>
	</cfif>
	<cfif IsDefined("MailBox")>
		<cfset CheckChar2 = Right(MailBox,1)>
		<cfif (CheckChar2 Is Not "/") AND (CheckChar2 Is Not "\")>
			<cfset TheMailBox = MailBox & OSType>
		<cfelse>
			<cfset TheMailBox = MailBox>
		</cfif>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Plans SET 
		EditedYN = 1, 
		Radius = #Radius#, 
		<cfif Radius Is 1>
			<cfif AuthNumber Is 0>
				<cfset AuthNumber = 1>
			<cfelseif AuthNumber Is "">
				<cfset AuthNumber = 1>
			</cfif>
			AuthNumber = #AuthNumber#,
		<cfelse>
			AuthNumber = 0,
		</cfif>
		<cfif IsDefined("AuthMinLogin")>
			AuthMinLogin = <cfif Trim(AuthMinLogin) Is "">1<cfelseif AuthMinLogin Is 0>1<cfelse>#AuthMinLogin#</cfif>, 
			AuthMaxLogin = <cfif Trim(AuthMaxLogin) Is "">8<cfelseif AuthMaxLogin Is 0>8<cfelse>#AuthMaxLogin#</cfif>, 
			AuthMinPassw = <cfif Trim(AuthMinPassw) Is "">1<cfelseif AuthMinPassw Is 0>1<cfelse>#AuthMinPassw#</cfif>, 
			AuthMaxPassw = <cfif Trim(AuthMaxPassw) Is "">8<cfelseif AuthMaxPassw Is 0>8<cfelse>#AuthMaxPassw#</cfif>, 
			AuthMixPassw = <cfif Not IsDefined("AuthMixPassw")>Null<cfelse>#AuthMixPassw#</cfif>, 
			PlanType = <cfif Trim(PlanType) Is "">Null<cfelse>'#Trim(PlanType)#'</cfif>, 
			LoginLimit = <cfif Trim(LoginLimit) Is "">1<cfelse>#LoginLimit#</cfif>, 
			DefAuthServer = <cfif Not IsDefined("DefAuthServer")>Null<cfelse>'#DefAuthServer#'</cfif>, 
			Max_Idle1 = <cfif Trim(Max_Idle1) Is "">0<cfelse>#Max_Idle1#</cfif>, 
			Max_Connect1 = <cfif Trim(Max_Connect1) Is "">0<cfelse>#Max_Connect1#</cfif>, 
			LowerAWYN = <cfif Not IsDefined("LowerAWYN")>0<cfelse>#LowerAWYN#</cfif>, 
			LowerOSYN = <cfif Not IsDefined("LowerOSYN")>0<cfelse>#LowerOSYN#</cfif>, 
			AWStaticIPYN = <cfif Not IsDefined("AWStaticIPYN")>0<cfelse>#AWStaticIPYN#</cfif>, 
			OSStaticIPYN = <cfif Not IsDefined("OSStaticIPYN")>0<cfelse>#OSStaticIPYN#</cfif>, 
			SessHistKeep = <cfif Trim(SessHistKeep) Is "">0<cfelse>#SessHistKeep#</cfif>, 
			AuthAddChars = <cfif Trim(AuthAddChars) Is "">Null<cfelse>'#AuthAddChars#'</cfif>, 
			AuthSufChars = <cfif Trim(AuthSufChars) Is "">Null<cfelse>'#AuthSufChars#'</cfif>, 
			BaseHours = <cfif Trim(BaseHours) Is "">0<cfelse>#BaseHours#</cfif>, 
			EMailWarn = <cfif Trim(EMailWarn) Is "">0<cfelse>#EMailWarn#</cfif>, 
			WarningLetterID = <cfif Not IsDefined("WarningLetterID")>0<cfelse>#WarningLetterID#</cfif>, 
			<cfif Not IsDefined("HoursUp")>
				HoursUp = 1, RollBackTo = Null, 
			<cfelse>
				<cfif HoursUp Is 1>
					HoursUp = #HoursUp#, 
					RollBackTo = Null, 
				<cfelseif HoursUp Is 2>
					<cfif RollBackTo1 Is 0>
						HoursUp = 1, 
						RollBackTo = Null,
					<cfelse>
						HoursUp = #HoursUp#, 
						RollBackTo = '#RollBackTo1#', 
					</cfif>
				<cfelseif HoursUp Is 3>
					HoursUp = #HoursUp#, 
					RollBackTo = '#RollBackTo2#', 
				</cfif>
			</cfif>
		</cfif>
		EMailYN = #EMailYN#, 
		<cfif EMailYN Is 1>
			<cfif FreeEMails Is 0>
				<cfset FreeEMails = 1>
			</cfif>
			FreeEMails = #FreeEMails#, 
		<cfelse>
			FreeEMails = 0, 
		</cfif>
		<cfif IsDefined("EMailMatchYN")>
			EMailMatchYN = <cfif Not IsDefined("EMailMatchYN")>0<cfelse>#EMailMatchYN#</cfif>, 
			EMailLogDiffYN = <cfif Not IsDefined("EMailLogDiffYN")>0<cfelse>#EMailLogDiffYN#</cfif>, 
			MailMinLogin = <cfif Not IsDefined("MailMinLogin")>3<cfelse><cfif Trim(MailMinLogin) Is "">3<cfelse>#MailMinLogin#</cfif></cfif>, 
			MailMaxLogin = <cfif Not IsDefined("MailMaxLogin")>8<cfelse><cfif Trim(MailMaxLogin) Is "">8<cfelse>#MailMaxLogin#</cfif></cfif>, 
			MailMinPassw = <cfif Not IsDefined("MailMinPassw")>5<cfelse><cfif Trim(MailMinPassw) Is "">5<cfelse>#MailMinPassw#</cfif></cfif>, 
			MailMaxPassw = <cfif Not IsDefined("MailMaxPassw")>8<cfelse><cfif Trim(MailMaxPassw) Is "">8<cfelse>#MailMaxPassw#</cfif></cfif>, 
			MailMixPassw = <cfif Not IsDefined("MailMixPassw")>0<cfelse>#MailMixPassw#</cfif>, 
			MailBoxLimit = <cfif Not IsDefined("MailBoxLimit")>0<cfelse><cfif Trim(MailBoxLimit) Is "">0<cfelse>#MailBoxLimit#</cfif></cfif>, 
			EMailAliasYN = <cfif Not IsDefined("EMailAliasYN")>0<cfelse>#EMailAliasYN#</cfif>, 
			DefMailServer = <cfif Not IsDefined("DefMailServer")>Null<cfelse>'#DefMailServer#'</cfif>, 
			MailBox = <cfif Not IsDefined("TheMailBox")>Null<cfelse><cfif Trim(TheMailBox) Is OSType>Null<cfelse>'#TheMailBox#'</cfif></cfif>, 
			AWMailLower = <cfif Not IsDefined("AWMailLower")>0<cfelse>#AWMailLower#</cfif>, 
			OSMailLower = <cfif Not IsDefined("OSMailLower")>0<cfelse>#OSMailLower#</cfif>, 
		</cfif>
		FTPYN = #FTPYN#, 
		<cfif FTPYN Is 1>
			<cfif FTPNumber Is 0>
				<cfset FTPNumber = 1>
			<cfelseif FTPNumber Is "">
				<cfset FTPNumber = 1>
			</cfif>		
			FTPNumber = #FTPNumber#, 
		<cfelse>
			FTPNumber = 0, 
		</cfif>
		<cfif IsDefined("FTPMatchYN")>
			FTPMatchYN = <cfif Not IsDefined("FTPMatchYN")>0<cfelse>#FTPMatchYN#</cfif>, 
			Read1 = <cfif IsDefined("Read1")>1<cfelse>0</cfif>, 
			Write1 = <cfif IsDefined("Write1")>1<cfelse>0</cfif>, 
			Create1 = <cfif IsDefined("Create1")>1<cfelse>0</cfif>, 
			Delete1 = <cfif IsDefined("Delete1")>1<cfelse>0</cfif>, 
			Mkdir1 = <cfif IsDefined("Mkdir1")>1<cfelse>0</cfif>, 
			Rmdir1 = <cfif IsDefined("Rmdir1")>1<cfelse>0</cfif>, 
			Noredir1 = <cfif IsDefined("Noredir1")>1<cfelse>0</cfif>, 
			Anydir1 = <cfif IsDefined("Anydir1")>1<cfelse>0</cfif>, 
			Anydrive1 = <cfif IsDefined("Anydrive1")>1<cfelse>0</cfif>, 
			Nodrive1 = <cfif IsDefined("Nodrive1")>1<cfelse>0</cfif>, 
			Putany1 = <cfif IsDefined("Putany1")>1<cfelse>0</cfif>, 
			Super1 = <cfif IsDefined("Super1")>1<cfelse>0</cfif>, 
			FTPMinLogin = <cfif Not IsDefined("FTPMinLogin")>3<cfelse><cfif Trim(FTPMinLogin) Is "">3<cfelse>#FTPMinLogin#</cfif></cfif>, 
			FTPMaxLogin = <cfif Not IsDefined("FTPMaxLogin")>8<cfelse><cfif Trim(FTPMaxLogin) Is "">8<cfelse>#FTPMaxLogin#</cfif></cfif>, 
			FTPMinPassw = <cfif Not IsDefined("FTPMinPassw")>5<cfelse><cfif Trim(FTPMinPassw) Is "">5<cfelse>#FTPMinPassw#</cfif></cfif>, 
			FTPMaxPassw = <cfif Not IsDefined("FTPMaxPassw")>8<cfelse><cfif Trim(FTPMaxPassw) Is "">8<cfelse>#FTPMaxPassw#</cfif></cfif>, 
			FTPMixPassw = <cfif Not IsDefined("FTPMixPassw")>0<cfelse>#FTPMixPassw#</cfif>, 
			DefFTPServer = <cfif Not IsDefined("DefFTPServer")>Null<cfelse>'#DefFTPServer#'</cfif>, 
			FTPAddChars = <cfif Not IsDefined("FTPAddChars")>Null<cfelse><cfif Trim(FTPAddChars) Is "">Null<cfelse>'#FTPAddChars#'</cfif></cfif>, 
			FTPSufChars = <cfif Not IsDefined("FTPSufChars")>Null<cfelse><cfif Trim(FTPSufChars) Is "">Null<cfelse>'#FTPSufChars#'</cfif></cfif>, 
			AWFTPLower = <cfif Not IsDefined("AWFTPLower")>0<cfelse>#AWFTPLower#</cfif>, 
			OSFTPLower = <cfif Not IsDefined("OSFTPLower")>0<cfelse>#OSFTPLower#</cfif>, 
			Max_Idle = <cfif Not IsDefined("Max_Idle")>0<cfelse><cfif Trim(Max_Idle) Is "">0<cfelse>#Max_Idle#</cfif></cfif>, 
			Max_Connect = <cfif Not IsDefined("Max_Connect")>0<cfelse><cfif Trim(Max_Connect) Is "">0<cfelse>#Max_Connect#</cfif></cfif>, 
			Start_Dir = <cfif Not IsDefined("TheStartDir")>Null<cfelse><cfif Trim(TheStartDir) Is OSType>Null<cfelse>'#TheStartDir#'</cfif></cfif>, 
		</cfif>
		WebHostYN = #WebHostYN#, 
		DeactPassWord = <cfif Trim(DeactPassWord) Is "">Null<cfelse>'#Trim(DeactPassWord)#'</cfif>, 
		ExtSysFile = <cfif Trim(ExtSysFile) Is "">Null<cfelse>'#ExtSysFile#'</cfif> 
		WHERE PlanID = #PlanID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the integration tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 4 --->
<cfif IsDefined("EditMe.x")>
	<cfset spans1 = Mid("#ss1#","1","2")>
	<cfset spans2 = Mid("#ss1#","3","2")>
	<cfset spane1 = Mid("#se1#","1","2")>
	<cfset spane2 = Mid("#se1#","3","2")>
	<cfset ramnt = LSParseNumber(#form.overcharge#)>
	<cfif se1 is "2359">
		<cfset seconds1 = "59">
	<cfelse>
		<cfset seconds1 = "0">
	</cfif>
	<cfset spanstart = CreateDateTime("98","10","9","#spans1#","#spans2#","0")>
	<cfset spanend = CreateDateTime("98","10","9","#spane1#","#spane2#","#seconds1#")>
	<cfif se1 is not "2359">
		<cfset spanend = DateAdd("s","-1","#spanend#")>
	</cfif>
	<cfquery name="update1" datasource="#pds#">
		UPDATE Spans SET 
		BaseAmount = #baseamount#,
		OverCharge = #ramnt#, 
		SpanStart = #spanstart#, 
		SpanEnd = #spanend#, 
		PlanID = #planid#, 
		SpanUnit = '#spanunit#', 
		SpanDescrip = <cfif Trim(SpanDescrip) Is "">Null<cfelse>'#SpanDescrip#'</cfif>, 
		SpanPeriod = #spanperiod# 
		WHERE SpanID = #spanid#
	</cfquery>
	<cfquery name="updatedays" datasource="#pds#">
		DELETE FROM Plans2Spans 
		WHERE spanid = #spanid#
	</cfquery>
	<cfif spanperiod is 0>
		<cfloop index="B5" list="#dofwk1#">
			<cfquery name="spans2plans" datasource="#pds#">
				INSERT INTO plans2spans 
				(PlanID, SpanID, DofWK) 
				VALUES 
				(#planid#, #spanid#, #B5#)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the metered tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("DelSpan.x")) AND (IsDefined("DelThese"))>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="delme" datasource="#pds#">
				DELETE FROM Spans 
				WHERE SpanID = #B5# 
			</cfquery>
			<cfquery name="delme2" datasource="#pds#">
				DELETE FROM Plans2Spans 
				WHERE SpanID = #B5# 
			</cfquery>
			<cfquery name="checkiflast" datasource="#pds#">
				SELECT SpanID 
				FROM Spans WHERE PlanID = #PlanID#
			</cfquery>
		   <cfif checkiflast.recordcount is 0>
				<cfquery name="setmetered" datasource="#pds#">
					UPDATE plans SET meteredyn = 0 
					WHERE planid = #planid#
				</cfquery>
		   </cfif>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the metered tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif IsDefined("EnterNewSpan.x")>
	<cfset spans1 = Mid("#ss1#","1","2")>
	<cfset spans2 = Mid("#ss1#","3","2")>
	<cfset spane1 = Mid("#se1#","1","2")>
	<cfset spane2 = Mid("#se1#","3","2")>
	<cfset ramnt = LSParseNumber(#form.overcharge#)>
	<cfif se1 is "2359">
		<cfset seconds1 = "59">
	<cfelse>
		<cfset seconds1 = "0">
	</cfif>
	<cfset spanstart = CreateDateTime("98","10","9","#spans1#","#spans2#","0")>
	<cfset spanend = CreateDateTime("98","10","9","#spane1#","#spane2#","#seconds1#")>
	<cfif se1 is not "2359">
		<cfset spanend = DateAdd("s","-1","#spanend#")>
	</cfif>
	<cftransaction>
		<cfquery name="enterspan" datasource="#pds#">
			INSERT INTO Spans 
			(BaseAmount, OverCharge, SpanStart, 
			 SpanEnd, PlanID, SpanUnit, SpanPeriod, SpanDescrip) 
			VALUES 
			(#baseamount#, #ramnt#, #spanstart#, #spanend#, 
			 #planid#, '#spanunit#', #spanperiod#, 
			 <cfif Trim(SpanDescrip) Is "">Null<cfelse>'#SpanDescrip#'</cfif>)
		</cfquery>
		<cfquery name="setmetered" datasource="#pds#">
			UPDATE plans SET 
			MeteredYN = 1 
			WHERE PlanID = #PlanID#
		</cfquery>
		<cfquery name="getid" datasource="#pds#">
			SELECT max(SpanID) AS msid 
			FROM Spans
		</cfquery>
		<cfset maxspid = getid.msid>
	</cftransaction>
	<cfif spanperiod is 0>
		<cfloop index="B5" list="#dofwk1#">
			<cfquery name="spans2plans" datasource="#pds#">
				INSERT INTO plans2spans 
				(PlanID, SpanID, DofWK) 
				VALUES 
				(#planid#, #maxspid#, #B5#)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the metered tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 5 --->
<cfif (IsDefined("MvLt5")) AND (IsDefined("haveit"))>
	<cfloop index="B5" list="#haveit#">
		<cfif B5 GT 0>
	   	<cfquery name="removeem" datasource="#pds#">
				DELETE FROM PlanAdm 
				WHERE PlanID = #PlanID# 
				AND AdminID = #B5#
		   </cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the staff tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt5")) AND (IsDefined("wantit"))>
   <cfloop index="B5" list="#wantit#">
		<cfif B5 GT 0>
		   <cfquery name="addem" datasource="#pds#">
				INSERT INTO PlanAdm 
				(PlanId, AdminID)
				VALUES 
				(#PlanID#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the staff tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 6 --->
<cfif (IsDefined("MvLt6")) AND (IsDefined("haveit"))>
	<cfloop index="B5" list="#haveit#">
		<cfif B5 GT 0>
			<cfquery name="removeem" datasource="#pds#">
				DELETE FROM POPPlans 
				WHERE POPID = #B5# 
				AND PlanID = #PlanID# 
			</cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the POPs tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt6")) AND (IsDefined("wantit"))>
	<cfloop index="B5" list="#wantit#">
		<cfif B5 GT 0>
			<cfquery name="addem" datasource="#pds#">
				INSERT INTO POPPlans 
				(PlanId, POPID)
				VALUES 
				(#PlanID#, #B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the POPs tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 7 --->
<cfif (IsDefined("MvLt7")) AND (IsDefined("HaveIt"))>
	<cfloop index="B5" list="#HaveIt#">
		<cfif B5 GT 0>
	   	<cfquery name="removeem" datasource="#pds#">
				DELETE FROM IntPlans 
				WHERE PlanID = #PlanId# 
				AND IntID = #B5#
		   </cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the scripts tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt7")) AND (IsDefined("WantIn"))>
   <cfloop index="B5" list="#WantIn#">
		<cfif B5 GT 0>
		   <cfquery name="addem" datasource="#pds#">
				INSERT INTO IntPlans 
				(PlanId, IntID)
				VALUES 
				(#PlanId#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the scripts tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<!--- tab 8 --->
<cfif (IsDefined("MvLt8")) AND (IsDefined("HaveIt"))>
	<cfloop index="B5" list="#HaveIt#">
		<cfif B5 GT 0>
	   	<cfquery name="removeem" datasource="#pds#">
				DELETE FROM DomPlans 
				WHERE PlanID = #PlanId# 
				AND DomainID = #B5#
		   </cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt8")) AND (IsDefined("WantIn"))>
   <cfloop index="B5" list="#WantIn#">
		<cfif B5 GT 0>
		   <cfquery name="addem" datasource="#pds#">
				INSERT INTO DomPlans 
				(PlanId, DomainID)
				VALUES 
				(#PlanId#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvLt8a")) AND (IsDefined("HaveIt"))>
	<cfloop index="B5" list="#HaveIt#">
		<cfif B5 GT 0>
	   	<cfquery name="removeem" datasource="#pds#">
				DELETE FROM DomAPlans 
				WHERE PlanID = #PlanId# 
				AND DomainID = #B5#
		   </cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt8a")) AND (IsDefined("WantIn"))>
   <cfloop index="B5" list="#WantIn#">
		<cfif B5 GT 0>
		   <cfquery name="addem" datasource="#pds#">
				INSERT INTO DomAPlans 
				(PlanId, DomainID)
				VALUES 
				(#PlanId#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvLt8f")) AND (IsDefined("HaveIt"))>
	<cfloop index="B5" list="#HaveIt#">
		<cfif B5 GT 0>
	   	<cfquery name="removeem" datasource="#pds#">
				DELETE FROM DomFPlans 
				WHERE PlanID = #PlanId# 
				AND DomainID = #B5#
		   </cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>
<cfif (IsDefined("MvRt8f")) AND (IsDefined("WantIn"))>
   <cfloop index="B5" list="#WantIn#">
		<cfif B5 GT 0>
		   <cfquery name="addem" datasource="#pds#">
				INSERT INTO DomFPlans 
				(PlanId, DomainID)
				VALUES 
				(#PlanId#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanName" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the domains tab of the plan - #PlanName.PlanDesc#.')
		</cfquery>
	</cfif>		
</cfif>

<cfsetting enablecfoutputonly="no">
 
