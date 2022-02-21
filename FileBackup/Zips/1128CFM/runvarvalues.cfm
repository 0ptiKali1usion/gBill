<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that sets the variables for the scripts. 
		Needed Parameters
			Action = Change/Create/Delete
			IntType = Comma seperated list of Types to run
			LocScriptID = The IntID of the script to run
		Optional Parameters
			LocAccountID
			LocAccntPlanID
			LocAliasID
			LocAuthID
			LocDomainID
			LocDomainType
			LocEMailID
			LocFTPID
			LocOldPassword
			LocPlanID
			LocPOPId			
			LocSendCAuthID
--->
<!--- 4.0.0 06/21/99 --->
<!--- RunVarValues.cfm --->

<cfparam name="LocScriptID" default="0">
<cfparam name="LocAccountID" default="0">
<cfparam name="LocAccntPlanID" default="0">
<cfparam name="LocAliasID" default="0">
<cfparam name="LocAuthID" default="0">
<cfparam name="LocDomainID" default="0">
<cfparam name="LocDomainType" default="EMail">
<cfparam name="LocEMailID" default="0">
<cfparam name="LocFTPID" default="0">
<cfparam name="LocOldPassword" default=")*N/A*(">
<cfparam name="LocPlanID" default="0">
<cfparam name="LocPOPID" default="0">

<cfif LocAccntPlanID GT 0>
	<cfquery name="GetTheID" datasource="#pds#">
		SELECT AccountID 
		FROM AccntPlans 
		WHERE AccntPlanID = #LocAccntPlanID#
	</cfquery>
	<cfset LocAccountID = GetTheID.AccountID>
</cfif>

<cfquery name="GetCustomerInfo" datasource="#pds#">
	SELECT AccountID, EMailDomainID, AuthDomainID, FTPDomainID, PlanID, POPID, 
	AccntPlanID as perB00, AccountID as perB01, PlanID as perB02, POPID as perB03, 
	EMailDomainID as perB04, FTPDomainID as perB05, AuthDomainID as perB06, 
	EMailServer as perB07, FTPServer as perB08, AuthServer as perB09, NextDueDate as perB10, 
	AccntStatus as perB11, PayBY as perB12 
	FROM AccntPlans 
	WHERE AccntPlanID = 
		<cfif LocAccntPlanID GT 0>
			#LocAccntPlanID#
		<cfelse>
			(SELECT Top 1 AccntPlanID 
			 FROM AccntPlans 
			 WHERE AccountID = #LocAccountID#) 
		</cfif>
</cfquery>
<cfloop index="B5" from="00" to="12">
<cfif B5 LT 10>
	<cfset B5 = "0" & B5>
</cfif>
<cfset "perB#B5#" = Evaluate("GetCustomerInfo.perB#B5#")>
	<cfif Trim(Evaluate("perB#B5#")) Is "">
		<cfset "perB#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfset perA25 = LocOldPassword>

<cfquery name="LocAccountInfo" datasource="#pds#">
	SELECT AccountID as perA00, Login as perA01, PassWord as perA02, 
	FirstName as perA03, LastName as perA04, Address1 as perA05, Address2 as perA06, 
	Address3 as perA07, DayPhone as perA08, EvePhone as perA09, Fax as perA10, 
	City as perA11, State as perA12, Zip as perA13, Country as perA14, Company as perA15, 
	PCType as perA16, ModemSpeed as perA17, OSVersion as perA18, Modem as perA19, 
	SalespersonID as perA20, CancelYN as perA21, CancelDate as perA22, 
	DeactivatedYN as perA23, DeactDate as perA24, ExtraField1 as PerA26, ExtraField2 as PerA27, 
	ExtraField3 as PerA28
	FROM Accounts 
	WHERE AccountID = #LocAccountID#
</cfquery>
<cfloop index="B5" from="00" to="24">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset TempValueNow = Evaluate("LocAccountInfo.perA#B5#")>
	<cfset TempValueNow = ReplaceNoCase("#TempValueNow#",",","","All")>
	<cfset "perA#B5#" = TempValueNow>
	<cfif Trim(Evaluate("perA#B5#")) Is "">
		<cfset "perA#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfloop index="B5" from="26" to="28">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset "perA#B5#" = Evaluate("LocAccountInfo.perA#B5#")>
	<cfif Trim(Evaluate("perA#B5#")) Is "">
		<cfset "perA#B5#" = ")*N/A*(">
	</cfif>
</cfloop>

<cfif (LocPOPID Is 0) AND (GetCustomerInfo.POPID Is Not "")>
	<cfset LocPOPID = GetCustomerInfo.POPID>
</cfif>
<cfif (LocPlanID Is 0) AND (GetCustomerInfo.PlanID Is Not "")>
	<cfset LocPlanID = GetCustomerInfo.PlanID>
</cfif>
<cfif LocDomainType Is "EMail">
	<cfif (LocDomainID Is 0) AND (GetCustomerInfo.EMailDomainID Is Not "")>
		<cfset LocDomainID = GetCustomerInfo.EMailDomainID>
	</cfif>
<cfelseif LocDomainType Is "Auth">
	<cfif (LocDomainID Is 0) AND (GetCustomerInfo.AuthDomainID Is Not "")>
		<cfset LocDomainID = GetCustomerInfo.AuthDomainID>
	</cfif>
<cfelseif LocDomainType Is "FTP">
	<cfif (LocDomainID Is 0) AND (GetCustomerInfo.FTPDomainID Is Not "")>
		<cfset LocDomainID = GetCustomerInfo.FTPDomainID>
	</cfif>
</cfif>

<cfquery name="LocDomainInfo" datasource="#pds#">
	SELECT DomainID as perD00, DomainName as perD01, EMailServer as perD02, 
	POP3Server as perD03, AuthServer as perD04, FTPServer as perD05, 
	NewsServer as perD06, EMailServerIP as perD07, POP3ServerIP as perD08, 
	FTPServerIP as perD09, AuthServerIP as perD10, NewsServerIP as perD11, 
	WebsiteIP as perD12, DNS1 as perD13, DNS2 as perD14, AccntLimit as perD15, 
	PrivateYN as perD16, CAuthID as perD17 
	FROM Domains 
	WHERE DomainID = #LocDomainID#
</cfquery>
<cfif (LocDomainInfo.perD17 Is Not "") AND (LocDomainInfo.perD17 Is Not 0)>
	<cfparam name="LocSendCAuthID" default="#LocDomainInfo.perD17#">
</cfif>
<cfloop index="B5" from="00" to="16">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset "perD#B5#" = Evaluate("LocDomainInfo.perD#B5#")>
	<cfif Trim(Evaluate("perD#B5#")) Is "">
		<cfset "perD#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfquery name="LocPrimEmail" datasource="#pds#">
	SELECT EMailID as perE00, Email as perE01, Login as perE02, EPass as perE03, 
	SMTPUserName as perE04, DomainName as perE05, EMailServer as perE10, 
	AccountID as perE11, AccntPlanID as perE12, DomainID as perE13, FName as perE14, 
	LName as perE15, FullName as perE16, MailCMD as perE17, MailBoxPath as perE18, 
	MailBoxLimit as perE19, Alias as perE20, PrEMail as perE21, ContactYN as perE22, 
	ForwardTo as perE23, EMailID  
	FROM AccountsEMail 
	WHERE 
		<cfif LocEmailID GT 0>
			EMailID = #LocEMailID#
		<cfelse>
			AccountID = 
			<cfif LocAccntPlanID GT 0>
				(SELECT Top 1 AccountID 
			 	 FROM AccntPlans 
			 	 WHERE AccntPlanID = #LocAccntPlanID#)
			<cfelse>
				#LocAccountID# 
			</cfif>
			<cfif LocAccntPlanID GT 0>
				AND AccntPlanID = #LocAccntPlanID# 
			</cfif>
			AND PrEMail = 1			
		</cfif>
</cfquery>
<cfif LocPrimEmail.RecordCount gt 0>
	<cfloop index="B5" from="00" to="5">
		<cfif B5 LT 10>
			<cfset B5 = "0" & B5>
		</cfif>
		<cfset "perE#B5#" = Evaluate("LocPrimEmail.perE#B5#")>
		<cfif Trim(Evaluate("perE#B5#")) Is "">
			<cfset "perE#B5#" = ")*N/A*(">
		</cfif>
	</cfloop>
	<cfloop index="B5" from="10" to="23">
		<cfif B5 LT 10>
			<cfset B5 = "0" & B5>
		</cfif>
		<cfset "perE#B5#" = Evaluate("LocPrimEmail.perE#B5#")>
		<cfif Trim(Evaluate("perE#B5#")) Is "">
			<cfset "perE#B5#" = ")*N/A*(">
		</cfif>
	</cfloop>
<cfelse>
	<cfset perE00 = ")*N/A*(">
	<cfset perE01 = ")*N/A*(">
	<cfset perE02 = ")*N/A*(">
	<cfset perE03 = ")*N/A*(">
	<cfset perE04 = ")*N/A*(">
	<cfset perE05 = ")*N/A*(">
	<cfset perE10 = ")*N/A*(">
	<cfset perE11 = ")*N/A*(">
	<cfset perE12 = ")*N/A*(">
	<cfset perE13 = ")*N/A*(">
	<cfset perE14 = ")*N/A*(">
	<cfset perE15 = ")*N/A*(">
	<cfset perE16 = ")*N/A*(">
	<cfset perE17 = ")*N/A*(">
	<cfset perE18 = ")*N/A*(">
	<cfset perE19 = ")*N/A*(">
	<cfset perE20 = ")*N/A*(">
	<cfset perE21 = ")*N/A*(">
	<cfset perE22 = ")*N/A*(">
	<cfset perE23 = ")*N/A*(">
</cfif>

<cfquery name="LocAliasEMail" datasource="#pds#">
		SELECT EMail as perE06, SMTPUserName as perE07, 
		DomainName as perE08, AliasTo 
		FROM AccountsEMail 
		<cfif IsDefined("LocAliasID")>
			WHERE EMailID = #LocAliasID#
		<cfelse>
			WHERE AccountID = 
			<cfif LocAccntPlanID GT 0>
				(SELECT Top 1 AccountID 
			 	 FROM AccntPlans 
			 	 WHERE AccntPlanID = #LocAccntPlanID#)
			<cfelse>
				#LocAccountID# 
			</cfif>
			AND Alias = 1 
			AND AliasTo = 
			<cfif LocPrimEmail.RecordCount GT 0>
				#LocPrimEmail.EMailID# 
			<cfelse>
				0
			</cfif>
		</cfif>
</cfquery>
<cfquery name="LocAliasToAddr" datasource="#pds#">
	SELECT EMail as perE09
	FROM AccountsEMail 
	WHERE EMailID IN 
		(SELECT AliasTo 
		 FROM AccountsEMail 
		 <cfif IsDefined("LocAliasID")>
			 WHERE EMailID = #LocAliasID#
		 <cfelse>
			 WHERE AccountID = 
			<cfif LocAccntPlanID GT 0>
				(SELECT Top 1 AccountID 
			 	 FROM AccntPlans 
			 	 WHERE AccntPlanID = #LocAccntPlanID#)
			<cfelse>
				#LocAccountID# 
			</cfif>
			 AND Alias = 1 
			 AND AliasTo = 
				<cfif LocPrimEmail.RecordCount GT 0>
					#LocPrimEmail.EMailID# 
				<cfelse>
					0
				</cfif>
		 </cfif>)
</cfquery>
<cfif LocAliasEMail.RecordCount gt 0>
	<cfset perE06 = LocAliasEMail.perE06>
		<cfif Trim(perE06) Is "">
			<cfset perE06 = ")*N/A*(">
		</cfif>
	<cfset perE07 = LocAliasEMail.perE07>
		<cfif Trim(perE07) Is "">
			<cfset perE07 = ")*N/A*(">
		</cfif>
	<cfset perE08 = LocAliasEMail.perE08>
		<cfif Trim(perE08) Is "">
			<cfset perE08 = ")*N/A*(">
		</cfif>
	<cfset perE09 = LocAliasToAddr.perE09>
		<cfif Trim(perE09) Is "">
			<cfset perE09 = ")*N/A*(">
		</cfif>
<cfelse>
	<cfset perE06 = ")*N/A*(">
	<cfset perE07 = ")*N/A*(">
	<cfset perE08 = ")*N/A*(">
	<cfset perE09 = ")*N/A*(">
</cfif>

<cfquery name="LocFTP" datasource="#pds#">
	SELECT FTPID as perF00, AccountID as perF01, AccntPlanID as perF02, DomainID as perF03, 
	DomainName as perF04, UserName as perF05, Password as perF06, Start_Dir as perF07, 
	Read1 as perF08, Write1 as perF09, Create1 as perF10, Delete1 as perF11, MKDir1 as perF12, 
	RMDir1 as perF13, NOReDir1 as perF14, AnyDir1 as perF15, AnyDrive1 as perF16, NoDrive1 as perF17, 
	Max_Idle1 as perF18, Max_Connect1 as perF19, PutAny1 as perF20, Super1 as perF21 
	FROM AccountsFTP 
	WHERE FTPID In 
		<cfif LocFTPID GT 0>
			(#LocFTPID#)
		<cfelseif IsDefined("LocAccountPlanID")>
			(SELECT FTPID 
			 FROM AccountsFTP 
			 WHERE AccntPlanID = #LocAccountPlanID#)
		<cfelse>
			(SELECT FTPID 
			 FROM AccountsFTP 
			 WHERE AccountID = 
			<cfif LocAccntPlanID GT 0>
				(SELECT Top 1 AccountID 
			 	 FROM AccntPlans 
			 	 WHERE AccntPlanID = #LocAccntPlanID#)
			<cfelse>
				#LocAccountID# 
			 </cfif>
			)
		</cfif>
</cfquery>
<cfif LocFTP.Recordcount GT 0>
	<cfloop index="B5" from="0" to="21">
		<cfif B5 LT 10>
			<cfset B5 = "0" & B5>
		</cfif>
		<cfset "perF#B5#" = Evaluate("LocFTP.perF#B5#")>
		<cfif Trim(Evaluate("perF#B5#")) Is "">
			<cfset "perF#B5#" = ")*N/A*(">
		</cfif>
	</cfloop>
<cfelse>
	<cfset perF00 = ")*N/A*(">
	<cfset perF01 = ")*N/A*(">
	<cfset perF02 = ")*N/A*(">
	<cfset perF03 = ")*N/A*(">
	<cfset perF04 = ")*N/A*(">
	<cfset perF05 = ")*N/A*(">
	<cfset perF06 = ")*N/A*(">
	<cfset perF07 = ")*N/A*(">
	<cfset perF08 = ")*N/A*(">
	<cfset perF09 = ")*N/A*(">
	<cfset perF10 = ")*N/A*(">
	<cfset perF11 = ")*N/A*(">
	<cfset perF12 = ")*N/A*(">
	<cfset perF13 = ")*N/A*(">
	<cfset perF14 = ")*N/A*(">
	<cfset perF15 = ")*N/A*(">
	<cfset perF16 = ")*N/A*(">
	<cfset perF17 = ")*N/A*(">
	<cfset perF18 = ")*N/A*(">
	<cfset perF19 = ")*N/A*(">
	<cfset perF20 = ")*N/A*(">
	<cfset perF21 = ")*N/A*(">
</cfif>

<cfquery name="LocPOPInfo" datasource="#pds#">
	SELECT POPID as perL00, POPName as perL01, PhoneData as perL02, 
	DataAreaCode as perL03, DNSPrimary as perL04, DNSSecondary as perL05, 
	Phone1 as perL06, Phone2 as perL07, City as perL08, State as perL09, 
	Zip as perL10, Contact as perL11, Address as perL12, Address2 as perL13, 
	Address3 as perL14, Country as perL15 
	FROM POPs 
	WHERE POPID = 
	<cfif LocPOPID Is Not "">
		#LocPOPID# 
	<cfelse>
		0
	</cfif>
</cfquery>
<cfloop index="B5" from="0" to="15">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset "perL#B5#" = Evaluate("LocPOPInfo.perL#B5#")>
	<cfif Trim(Evaluate("perL#B5#")) Is "">
		<cfset "perL#B5#" = ")*N/A*(">
	</cfif>
</cfloop>

<cfquery name="LocPlanInfo" datasource="#pds#">
	SELECT PlanID as perP00, PlanDesc as perP01, BaseHours as perP02, PlanType as perP03, 
	LoginLimit as perP04, Max_Connect as perP05, Max_Idle as perP06, ExpireDays as perP07, 
	TotalInternetCode as perP08, FixedAmount as perP09, RecurringAmount as perP10, 
	Recurringcycle as perP11, UseWelcome as perP12, HrAmount as perP13, RecurDiscount as perP14, 
	FixedDiscount as perP15, RAMemo as perP16, RDMemo as perP17, FAMemo as perP18, FDMemo as perP19,
	DefMailServer as perP20, DefAuthServer as perP21, DefFTPServer as perP22, Limit1 as perP23, 
	MailBox as perP24, AuthAddChars as perP25, FTPAddChars as perP26, PlanType as perP27, 
	Start_Dir as perP28, Read1 as perP29, Write1 as perP30, Create1 as perP31, Delete1 as perP32, 
	MkDir1 as perP33, RmDir1 as perP34, NoRedir1 as perP35, AnyDir1 as perP36, AnyDrive1 as perP37, 
	NoDrive1 as perP38, PutAny1 as perP39, Super1 as perP40 
	FROM Plans 
	WHERE PlanID = 
	<cfif LocPlanID Is Not "">
		#LocPlanID# 
	<cfelse>
		0
	</cfif>	
</cfquery>
<cfloop index="B5" from="00" to="40">
<cfif B5 LT 10>
	<cfset B5 = "0" & B5>
</cfif>
<cfset "perP#B5#" = Evaluate("LocPlanInfo.perP#B5#")>
	<cfif Trim(Evaluate("perP#B5#")) Is "">
		<cfset "perP#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfquery name="GetExpDate" datasource="#pds#">
	SELECT DateValue1 
	FROM Setup 
	WHERE VarName = 'SetAuthExpireDate' 
</cfquery>
<cfif GetExpDate.RecordCount GT 0>
	<cfset TheExpireDate = GetExpDate.DateValue1>
<cfelse>
	<cfset TheExpireDate = "12/31/2020">
</cfif>
<cfset PerP07 = TheExpireDate>

<cfquery name="LocAuth" datasource="#pds#">
	SELECT AuthID as perR00, AccountID as perR01, DomainID as perR02, DomainName as perR03, 
	UserName as perR04, Password as perR05, Filter1 as perR06, IP_Address as perR07, 
	Max_Idle as perR08, Max_Connect as perR09, Max_Logins as perR10, SecondsLeft as perR11, 
	AccntPlanID as perR12 
	FROM AccountsAuth 
	WHERE AuthID IN 
		<cfif LocAuthID GT 0>
			(#LocAuthID#) 
		<cfelse>
			(SELECT AuthID 
			 FROM AccountsAuth 
			 WHERE AccountID = #LocAccountID#)
		</cfif>
</cfquery>
<cfif LocAuth.Recordcount GT 0>
	<cfloop index="B5" from="0" to="12">
		<cfif B5 LT 10>
			<cfset B5 = "0" & B5>
		</cfif>
		<cfset "perR#B5#" = Evaluate("LocAuth.perR#B5#")>
		<cfif Trim(Evaluate("perR#B5#")) Is "">
			<cfset "perR#B5#" = ")*N/A*(">
		</cfif>
	</cfloop>
<cfelse>
	<cfset perR00 = ")*N/A*(">
	<cfset perR01 = ")*N/A*(">
	<cfset perR02 = ")*N/A*(">
	<cfset perR03 = ")*N/A*(">
	<cfset perR04 = ")*N/A*(">
	<cfset perR05 = ")*N/A*(">
	<cfset perR06 = ")*N/A*(">
	<cfset perR07 = ")*N/A*(">
	<cfset perR08 = ")*N/A*(">
	<cfset perR09 = ")*N/A*(">
	<cfset perR10 = ")*N/A*(">
	<cfset perR11 = ")*N/A*(">
	<cfset perR12 = ")*N/A*(">
</cfif>
<cfquery name="CheckGroup" datasource="#pds#">
	SELECT PrimaryID 
	FROM Multi 
	WHERE AccountID = 
	<cfif LocAccntPlanID GT 0>
		(SELECT Top 1 AccountID 
	 	 FROM AccntPlans 
	 	 WHERE AccntPlanID = #LocAccntPlanID#)
	<cfelse>
		#LocAccountID# 
	</cfif>
</cfquery>
<cfif CheckGroup.Recordcount GT 0>
	<cfset PrimaryAccountID = CheckGroup.PrimaryID>
<cfelse>
	<cfset PrimaryAccountID = LocAccountID>
</cfif>
<!--- Add Check for Group Account --->
<cfquery name="LocLastPayment" datasource="#pds#" maxrows="1">
	SELECT Credit as perT14, AuthDomainID as perT15, ChkNumber as perT16, CCAuthCode as perT17, 
	CCPayType as perT18, DateTime1 as perT19, PrintedDate as perT20, EMailDomainID as perT21, 
	EnteredBY as perT22, FTPDomainID as perT23, MemoField as perT24, PayType as perT25, 
	PlanID as perT26, POPID as perT27 
	FROM Transactions 
	WHERE AdjustmentYN = 0 
	AND Credit > 0 
	AND AccountID = 
	<cfif PrimaryAccountID Is Not "">
		#PrimaryAccountID# 
	<cfelse>
		0
	</cfif>	
	ORDER BY DateTime1 desc 
</cfquery>
<cfloop index="B5" from="14" to="27">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset "perT#B5#" = Evaluate("LocLastPayment.perT#B5#")>
	<cfif Trim(Evaluate("perT#B5#")) Is "">
		<cfset "perT#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfquery name="LocLastDebit" datasource="#pds#" maxrows="1">
	SELECT Sum(Debit) as perT03, AuthDomainID as perT04, DateTime1 as perT05, 
	DebitFromDate as perT06, DebitToDate as perT07, EMailDomainID as perT08, 
	EnteredBY as perT09, FTPDomainID as perT10, PlanID as perT11, POPID as perT12 
	FROM Transactions 
	WHERE AdjustmentYN = 0 
	AND Debit > 0 
	AND AccountID = 
	<cfif PrimaryAccountID Is Not "">
		#PrimaryAccountID# 
	<cfelse>
		0
	</cfif>		
	GROUP BY AuthDomainID, DateTime1, DebitFromDate, DebitToDate, EMailDomainID, 
	EnteredBY, FTPDomainID, PlanID, POPID 
	ORDER BY DateTime1 desc
</cfquery>
<cfloop index="B5" from="3" to="12">
	<cfif B5 LT 10>
		<cfset B5 = "0" & B5>
	</cfif>
	<cfset "perT#B5#" = Evaluate("LocLastDebit.perT#B5#")>
	<cfif Trim(Evaluate("perT#B5#")) Is "">
		<cfset "perT#B5#" = ")*N/A*(">
	</cfif>
</cfloop>
<cfquery name="LocCurrentBalance" datasource="#pds#">
	SELECT Sum(Debit-Credit) as perT02 
	FROM Transactions 
	WHERE AccountID = 
	<cfif PrimaryAccountID Is Not "">
		#PrimaryAccountID# 
	<cfelse>
		0
	</cfif>		
</cfquery>
<cfset perT02 = LSCurrencyFormat(LocCurrentBalance.perT02)>
	<cfif Trim(perT02) Is "">
		<cfset perT02 = ")*N/A*(">
	</cfif>
<cfif IsDefined("LocAccountPlanID")>
	<cfset perT00 = LocAccountPlanID>
<cfelse>
	<cfset perT00 = 0>
</cfif>
<cfset perT01 = PrimaryAccountID>
	
<cfset perS01 = CreateODBCDate(Now())>
<cfset perS02 = CreateODBCTime(Now())>
<cfquery name="PerValues" datasource="#pds#">
	SELECT UseText 
	FROM IntVariables 
	WHERE CustomYN = 0 
	AND Usetext <> '%S03'
	ORDER BY UseText
</cfquery>

<cfif GetCustomerInfo.perB12 Is "CC">
	<cfset PayByTable = "PayByCC">
<cfelseif GetCustomerInfo.perB12 Is "CD">
	<cfset PayByTable = "PayByCD">
<cfelseif GetCustomerInfo.perB12 Is "CK">
	<cfset PayByTable = "PayByCK">
<cfelseif GetCustomerInfo.perB12 Is "PO">
	<cfset PayByTable = "PayByPO">
<cfelse>
	<cfset PayByTable = "PayByCK">
</cfif>

<cfquery name="LocPayMethod" datasource="#pds#">
	SELECT * 
	FROM #PayByTable# 
	WHERE AccntPlanID = 
	<cfif LocAccntPlanID GT 0>
		#LocAccntPlanID#
	<cfelse>
		(SELECT Top 1 AccntPlanID 
		 FROM AccntPlans 
		 WHERE AccountID = #LocAccountID#) 
	</cfif>
</cfquery>

<cfif GetCustomerInfo.perB12 Is "CC">
	<cfset perM01 = "Credit Card">
<cfelseif GetCustomerInfo.perB12 Is "CD">
	<cfset perM01 = "Check Debit">
<cfelseif GetCustomerInfo.perB12 Is "CK">
	<cfset perM01 = "Check">
<cfelseif GetCustomerInfo.perB12 Is "PO">
	<cfset perM01 = "Purchase Order">
<cfelse>
	<cfset perM01 = "Cash">
</cfif>

<cfset counter1 = 0>
<cfset FindList = ValueList(PerValues.UseText)>
<cfset ReplList = "">
<cfloop index="B4" list="#FindList#">
	<cfset LkVl = Replace("#B4#","%","per")>
	<cfset NwVl = Evaluate("#LkVl#")>
	<cfset ReplList = ListAppend(ReplList,NwVl)>
</cfloop>

<cfsetting enablecfoutputonly="no">
 