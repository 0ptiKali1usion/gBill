<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 03/14/00 --->
<!--- maintauthrun.cfm --->
<!--- Reset first of month --->
<cfif DatePart("h",Now()) Is "0">
	<cfquery name="Reset" datasource="#pds#">
		UPDATE AccountsAuth SET 
		EMailedYN = 0, 
		TimeCheckedYN = 1, 
		EMailDate = Null, 
		DeactSchedYN = 0 
		WHERE TimeCheckedYN = 0 
		AND AuthID IN 
			(SELECT AuthID 
			 FROM AccountsAuth A, AccntPlans P 
			 WHERE A.AccntPlanID = P.AccntPlanID 
			 AND DatePart(dd,P.NextDueDate) = #DatePart("d",Now())# 
	</cfquery>
	<cfquery name="Reset" datasource="#pds#">
		UPDATE AccountsAuth SET 
		TimeCheckedYN = 0 
		WHERE AuthID IN 
			(SELECT AuthID 
			 FROM AccountsAuth A, AccntPlans P 
			 WHERE A.AccntPlanID = P.AccntPlanID 
			 AND DatePart(dd,P.NextDueDate) <> #DatePart("d",Now())# 
	</cfquery>
</cfif>

<cfparam name="ForwardMins" default="60">
<cfquery name="SetTotals" datasource="#pds#">
	UPDATE AccountsAuth SET 
	MonthTotalTime = P.BaseHours * 3600, 
	EMailSecsLeft = P.EMailWarn * 3600, 
	WarningAction = P.HoursUp 
	FROM Plans P, AccntPlans AP, AccountsAuth A 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID = A.AccntPlanID 
</cfquery>

<cfquery name="CheckCustom" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'ForwardMins' 
</cfquery>
<cfif CheckCustom.Recordcount GT 0>
	<cfset ForwardMins = CheckCustom.Value1>
</cfif>
<cfquery name="TheAuthTypes" datasource="#pds#">
	SELECT CAuthID, DomainID 
	FROM Domains 
	WHERE CAuthID In 
		(SELECT CAuthID 
		 FROM CustomAuthSetup 
		 WHERE BOBName = 'accntodbc' 
		 AND DBName Is Not Null) 
</cfquery>
<cfquery name="GetSetupValues" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'warnemail'
</cfquery>
<cfset WarnEMail = GetSetupValues.Value1>
<!--- FInd last time this page ran --->
<cfquery name="GetStartTime" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'MaintAuthRunStart' 
</cfquery>
<cfset Date1 = DateAdd("m","-1",Now())>
<cfset DateStart = CreateDateTime(Year(Date1),Month(Date1),Day(Date1),0,0,0)>
<cfif GetStartTime.Recordcount Is 0>
	<cfquery name="AddValue" datasource="#pds#">
		INSERT INTO Setup
		(VarName,DateValue1,AutoLoadYN,Description) 
		VALUES 
		('MaintAuthRunStart',#DateStart#,0,'Last time MaintAuthRun started')
	</cfquery>
	<cfquery name="GetStartTime" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName = 'MaintAuthRunStart' 
	</cfquery>
</cfif>
<cfquery name="GetStopTime" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'MaintAuthRunStop'  
</cfquery>
<cfif GetStopTime.Recordcount Is 0>
	<cfquery name="AddValue" datasource="#pds#">
		INSERT INTO Setup
		(VarName,DateValue1,AutoLoadYN,Description) 
		VALUES 
		('MaintAuthRunStop',#DateStart#,0,'Last time MaintAuthRun finished')
	</cfquery>
	<cfquery name="GetStopTime" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName = 'MaintAuthRunStop' 
	</cfquery>
</cfif>
<cfif GetStartTime.DateValue1 Is GetStopTime.DateValue1>
	<cfset PageStartTime = GetStartTime.DateValue1>
<cfelseif GetStartTime.DateValue1 GT GetStopTime.DateValue1>
	<cfset PageStartTime = GetStopTime.DateValue1>
<cfelseif GetStartTime.DateValue1 LT GetStopTime.DateValue1>
	<cfset PageStartTime = GetStartTime.DateValue1>
</cfif>
<cfif DateAdd("n",ForwardMins,PageStartTime) GT Now()>
	<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Importer</title>
	Importer is caught up.
	</body>
	</html>
	<cfabort>
</cfif>
<!--- Grab all new auth recods --->
<cfloop query="TheAuthTypes">
	<cfset TheAuthID = CAuthID>
	<cfset TheDomainID = DomainID>
	<cfquery name="AuthInfo" datasource="#pds#">
		SELECT S.BOBName, S.DBName, A.AuthDescription 
		FROM CustomAuthSetup S, CustomAuth A 
		WHERE S.CAuthID = A.CAuthID 
		AND S.CAuthID = #TheAuthID# 
		AND ForTable = 13 
		AND S.BOBName IN ('tbcalls','callslogin','calldatetime','calldate','calltime','acntsestime') 
	</cfquery>
	<cfquery name="DSInfo" datasource="#pds#">
		SELECT S.BOBName, S.DBName, A.AuthDescription 
		FROM CustomAuthSetup S, CustomAuth A 
		WHERE S.CAuthID = A.CAuthID 
		AND S.CAuthID = #TheAuthID# 
		AND S.BOBName = 'accntodbc' 
	</cfquery>
	<cfloop query="AuthInfo">
		<cfset "#BOBName#" = DBName>
	</cfloop>
	<cfloop query="DSInfo">
		<cfset "#BOBName#" = DBName>
	</cfloop>
	<cfif (tbcalls Is Not "") 
	 AND (callslogin Is Not "") 
	 AND (accntodbc Is Not "") 
	 AND (acntsestime Is Not "") 
	 AND ( (calldatetime Is Not "") OR ((calldate Is Not "") AND (calltime Is Not "")) )>
		<cfset PageStopTime = DateAdd("n",ForwardMins,PageStartTime)>
		<cfquery name="SessionInfo" datasource="#accntodbc#">
			SELECT #callslogin# as TheUserName 
			FROM #tbcalls# 
			WHERE #acntsestime# Is Not Null 
			AND #acntsestime# > 0 
			<cfif calldatetime Is Not "">
				AND #calldatetime# < #CreateODBCDateTime(PageStopTime)#
				AND #calldatetime# >= #CreateODBCDateTime(PageStartTime)#
			<cfelse>
				AND #calldate# < #CreateODBCDate(PageStopTime)#
				AND #calldate# >= #CreateODBCDate(PageStartTime)#
			</cfif>
			GROUP BY #callslogin# 
		</cfquery>
		<cfloop query="SessionInfo">
			<!--- Get Info for each username --->
			<cfquery name="UserAuthInfo" datasource="#pds#">
				SELECT P.NextDueDate, A.AuthID 
				FROM AccountsAuth A, AccntPlans P 
				WHERE A.AccntPlanID = P.AccntPlanID 
				AND A.UserName = '#TheUserName#' 
				AND A.DomainID = #TheDomainID# 
			</cfquery>
			<cfif UserAuthInfo.Recordcount GT 0>
				<cfset DueDate1 = UserAuthInfo.NextDueDate>
				<cfset Date1 = CreateDateTime(Year(PageStartTime), Month(PageStartTime), Day(DueDate1), 0,0,0)>
				<cfif Date1 LT PageStartTime>
					<cfset Date1 = DateAdd("m",1,Date1)>
				</cfif>
				<cfset Date2 = DateAdd("m",-1,Date1)>
				<cfquery name="UserInfo" datasource="#accntodbc#">
					SELECT Sum(#acntsestime#) As TotTime1 
					FROM #tbcalls# 
					WHERE #acntsestime# > 0 
					<cfif calldatetime Is Not "">
						AND #calldatetime# <= #CreateODBCDateTime(Date1)#
						AND #calldatetime# > #CreateODBCDateTime(Date2)#
					<cfelse>
						AND #calldate# <= #CreateODBCDate(Date1)#
						AND #calldate# > #CreateODBCDate(Date2)#
					</cfif>
					AND #callslogin# = '#TheUserName#' 
				</cfquery>
				<!--- Update AccountsAuth --->
				<cfquery name="SetTime" datasource="#pds#">
					UPDATE AccountsAuth Set 
					SecondsLeft = MonthTotalTime 
					<cfif UserInfo.TotTime1 Is Not "">
						- #UserInfo.TotTime1# 
					</cfif>
					WHERE UserName = '#TheUserName#' 
					AND DomainID = #TheDomainID# 
				</cfquery>
			</cfif>
		</cfloop>
	<cfelse>
		<cfmail from="#warnemail#" to="#warnemail#" subject="Metered Time Actions">
There is a problem with the setup of the Custom Auth - #AuthInfo.AuthDescription#.
#warnemail#
<cfif accntodbc Is "">Accounting Datasource is missing.</cfif>
<cfif tbcalls Is "">Session History Table Name is missing.</cfif>
<cfif callslogin Is "">Calls Username Field is missing.</cfif>
<cfif acntsestime Is "">Session Time Field is missing.</cfif>
<cfif calldatetime Is "">Date Time Field is missing.</cfif>
<cfif calldate Is "">Date Field is missing.</cfif>
<cfif calltime Is "">Time Field Is Missing.</cfif>
Please correct the problem at: #SERVER_NAME##ReplaceNoCase(SCRIPT_NAME,"maintauthrun.cfm","")#customauthsetup.cfm
</cfmail>
	</cfif>
</cfloop>
<cftransaction>
	<cfquery name="UpdMarker" datasource="#pds#">
		UPDATE Setup SET 
		DateValue1 = #CreateODBCDateTime(PageStopTime)# 
		WHERE VarName = 'MaintAuthRunStart' 
	</cfquery>
	<cfquery name="UpdMarker2" datasource="#pds#">
		UPDATE Setup SET 
		DateValue1 = #CreateODBCDateTime(PageStopTime)# 
		WHERE VarName = 'MaintAuthRunStop' 	
	</cfquery>
</cftransaction>
<cfif PageStopTime GT Now()>
	<cfset stopnow = 1>
</cfif>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Importer</title>
<cfif IsDefined("catchup")>
	<cfif Not IsDefined("stopnow")>
		<META HTTP-EQUIV=REFRESH CONTENT="2; URL=maintauthrun.cfm?Catchup=1&RequestTimeout=500">
	</cfif>
</cfif>
</head>
<body>
<cfif IsDefined("PageStopTime")>
	<cfoutput>Finished Importing for #LSDateFormat(PageStopTime, '#DateMask1#')# #TimeFormat(PageStopTime, 'hh:mm tt')#.</cfoutput>
<cfelse>
	<cfif IsDefined("stopnow")>
		<cfoutput>Finished Processing.</cfoutput>
	<cfelse>
		<cfoutput>Processing.</cfoutput>
	</cfif>
</cfif>
</body>
</html>
 