<cfsetting enablecfoutputonly="yes">
<!--- Version 3.2.0 --->
<!--- This page runs as scheduled to import radius records. --->
<!--- 3.5.0 06/18/99 
		3.4.0 04/16/99 --->
<!--- maintmeterbill.cfm --->

<!--- Auto runs to import radius records --->

<cfquery NAME="checkfirst" DATASOURCE="#pds#">
	SELECT UserName 
	FROM TimeTrax
</cfquery>
<cfset DefaultStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
<cfset ImportStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Hour(Now()),0,0)>
<cfparam name="MessageOutput" default="">
<cfparam name="AuthImportCounter" default="0">

<cfif CheckFirst.RecordCount IS 0>
	<cfquery name="GetAuths" datasource="#pds#">
		SELECT * 
		FROM CustomAuth 
		WHERE AuthType = 1 
		AND LastCompleteSpan < #CreateODBCDateTime(ImportStartDate)# 
		<cfif IsDefined("ID")>
			AND CAuthID = #ID#
		</cfif>
	</cfquery>
	<cfparam NAME="pds2" DEFAULT="CustomRadius">
	<cfparam name="HoursImport" default="1">
	<cfquery name="GetRadType" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName In ('DateMask1','HoursImport','Locale')
	</cfquery>
	<cfoutput query="getradtype">
		<cfset "#varname#" = GetRadType.Value1>
	</cfoutput>
	
	<cfloop query="GetAuths">
		<cfset AuthImportCounter = 0>
		<cfquery name="GetDS" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'accntodbc' 
			AND CAuthID = #CAuthID# 
		</cfquery>
		<cfset CAuthID = CAuthID>
		<cfset pds2 = GetDS.DBName>
		<cfif IsDate(LastImportSpan)>
			<cfset TheImport1 = LastImportSpan>
		<cfelse>
			<cfset TheImport1 = DefaultStartDate>
		</cfif>
		<cfif IsDate(LastCompleteSpan)>
			<cfset TheImport2 = LastCompleteSpan>
		<cfelse>	
			<cfset TheImport2 = DefaultStartDate>
		</cfif>
		<cfif TheImport1 Is Not TheImport2>
			<cfquery NAME="RemoveOld" DATASOURCE="#pds#">
				DELETE FROM TimeStore 
				WHERE FinishedYN = 0 
				AND LastBillDate > #CreateODBCDateTime(TheImport2)# 
				AND CAuthID = #CAuthID#
			</cfquery>
			<cfquery NAME="SetDate" DATASOURCE="#pds#">
				UPDATE CustomAuth SET 
				LastImportSpan = #CreateODBCDateTime(TheImport2)#, 
				LastCompleteSpan = #CreateODBCDateTime(TheImport2)# 
				WHERE CAuthID = #CAuthID# 
			</cfquery>
			<cfquery name="GetNewDates" datasource="#pds#">
				SELECT LastImportSpan, LastCompleteSpan 
				FROM CustomAuth 
				WHERE CAuthID = #CAuthID# 
			</cfquery>
			<cfset TheImport1 = GetNewDates.LastImportSpan>
			<cfset TheImport2 = GetNewDates.LastCompleteSpan>
		</cfif>
		<cfset NextTime = DateAdd("h",HoursImport,TheImport1)>
		<cfset TimeNow = Now()>
		<cfif TimeNow GTE NextTime>
			<cfquery name="SetNewTime" datasource="#pds#">
				UPDATE CustomAuth SET 
				LastImportSpan = #CreateODBCDateTime(NextTime)# 
				WHERE CAuthID = #CAuthID# 
			</cfquery>
		</cfif>
		<cfset DateCheck1 = CreateDateTime(Year(NextTime),Month(NextTime),Day(NextTime),Hour(NextTime),0,0)>
		<cfset DateCheck2 = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Hour(Now()),0,0)>
		<cfif DateCheck1 LTE DateCheck2>
			<!--- Select Monthly Metered --->
			<cfquery name="WhoToGet" datasource="#pds#">
				SELECT A.UserName 
				FROM Spans S, AccntPlans P, AccountsAuth A, Domains D 
				WHERE A.DomainID = D.DomainID 
				AND A.AccntPlanID = P.AccntPlanID 
				AND P.PlanID = S.PlanID 
				AND D.CAuthID = #CAuthID# 
				AND (S.SpanPeriod = 0 OR S.SpanPeriod = 3) 
				AND S.SpanUnit = 'Hours' 
				GROUP BY UserName 
			</cfquery>
			<cfif WhoToGet.RecordCount GT 0>
				<cfset SendCAuthID = CAuthID>
				<cfsetting enablecfoutputonly="No">
				<cfinclude template="cfauthvalues.cfm">
				<cfsetting enablecfoutputonly="Yes">
				<!--- Select The Calls Records --->
				<cfquery name="AuthFields"	datasource="#pds#">
					SELECT C.BOBName, C.DBName 
					FROM CustomAuthSetup C 
					WHERE C.CAuthID = #CAuthID# 
					AND C.DBName Is Not Null 
					AND C.DBType = 'FD' 
					AND C.ForTable = 
						(SELECT ForTable 
						 FROM CustomAuthSetup 
						 WHERE CAuthID = #CAuthID# 
						 AND BOBName = 'tbcalls' 
						)
				</cfquery>	
				<cfif (tbcalls is not "") AND (callslogin is not "") AND (acntsestime is not "") AND (calldatetime is not "")>
					<cfquery name="TimeRecords" datasource="#accntodbc#">
						SELECT 0 = 0<cfloop query="AuthFields">, #DBName# As #BOBName#1</cfloop>
						FROM #tbcalls# 
						WHERE #calldatetime# > #dateadd("h", "-#HoursImport#", DateCheck1)# 
						AND #calldatetime# <= #CreateODBCDateTime(DateCheck1)# 
						AND #callslogin# In (#QuotedValueList(WhoToGet.UserName)#) 
						AND #acntsestime# Is Not NULL 
						AND #acntsestime# < 2678400 
			         AND #acntsestime# > 0 
						ORDER BY #callslogin#, #calldatetime# 
					</cfquery>
					<cfset AuthImportCounter = 0>
					<cfloop QUERY="TimeRecords">
						<cfset CallBegin = DateAdd("s","-#AcntSesTime1#",CallDateTime1)>
						<cfset DateDay1 = DatePart("d",CallDateTime1)>
						<cfset DateDay2 = DatePart("d",CallBegin)>
						<cfif DateDay1 Is DateDay2>
							<cfquery name="CheckFirst" datasource="#pds#">
								SELECT * 
								FROM TimeTrax 
								WHERE UserName = '#CallsLogin1#' 
								AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
								<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
									AND NASPort = #NasPort1# 
								<cfelse>
									<cfset NasPort1 = "">
								</cfif>
								<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
									AND NASIdentifier = '#NasIdent1#' 
								<cfelse>
									<cfset NasIdent1 = "">
								</cfif>
								AND CAuthID = #CAuthID# 
							</cfquery>
							<cfif CheckFirst.RecordCount Is 0>
								<cfquery NAME="insert" DATASOURCE="#pds#">
									INSERT INTO timetrax 
									(NASPort, NASIdentifier, UserName, CallDate, TotTime, BilledYN, 
									 CallDateB, DayOfWeek, CAuthID) 
									VALUES 
									(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
									 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
									 '#CallsLogin1#', #CreateODBCDateTime(CallDateTime1)#, 
									 #AcntSesTime1#, 0, #CreateODBCDateTime(CallBegin)#, #DayOfWeek(CallDateTime1)#, #CAuthID#)
								</cfquery>
								<cfset AuthImportCounter = AuthImportCounter + 1>
							</cfif>
						<cfelse>
							<cfset Midnight = CreateDateTime(Year(CallDateTime1),Month(CallDateTime1),Day(CallDateTime1),0,0,0)>
							<cfset Midnight2 = DateAdd("s",-1,Midnight)>
							<cfset SessionTime1 = DateDiff("s",Midnight,CallDateTime1)>
							<cfset SessionTime2 = DateDiff("s",CallBegin,Midnight2)>
							<cftransaction>
								<cfif SessionTime1 GT 0>
									<cfquery name="CheckFirst" datasource="#pds#">
										SELECT * 
										FROM TimeTrax 
										WHERE UserName = '#CallsLogin1#' 
										AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
										<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
											AND NASPort = #NasPort1# 
										<cfelse>
											<cfset NasPort1 = "">
										</cfif>
										<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
											AND NASIdentifier = '#NasIdent1#' 
										<cfelse>
											<cfset NasIdent1 = "">
										</cfif>
										AND CAuthID = #CAuthID# 
									</cfquery>
									<cfif CheckFirst.RecordCount Is 0>
										<cfquery NAME="insert" DATASOURCE="#pds#">
											INSERT INTO TimeTrax 
											(NASPort, NASIdentifier, UserName, CallDate, TotTime, BilledYN, 
											 CallDateB, DayOfWeek, CAuthID) 
											VALUES 
											(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
											 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
											 '#CallsLogin1#', #CreateODBCDateTime(CallDateTime1)#, 
											 #SessionTime1#, 0, #CreateODBCDateTime(Midnight)#, #DayOfWeek(CallDateTime1)#, #CAuthID#)
										</cfquery>
										<cfset AuthImportCounter = AuthImportCounter + 1>
									</cfif>
								</cfif>
								<cfif SessionTime2 GT 0>
									<cfquery name="CheckFirst" datasource="#pds#">
										SELECT * 
										FROM TimeTrax 
										WHERE UserName = '#CallsLogin1#' 
										AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
										<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
											AND NASPort = #NasPort1# 
										<cfelse>
											<cfset NasPort1 = "">
										</cfif>
										<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
											AND NASIdentifier = '#NasIdent1#' 
										<cfelse>
											<cfset NasIdent1 = "">
										</cfif>
										AND CAuthID = #CAuthID# 
									</cfquery>
									<cfif CheckFirst.RecordCount Is 0>
										<cfquery name="Insert2" datasource="#pds#">
											INSERT INTO TimeTrax 
											(NASPort, NASIdentifier, UserName, CallDate, 
											 TotTime, BilledYN, CallDateb, DayOfWeek, CAuthID) 
											VALUES 
											(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
											 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
											 '#username1#', #CreateODBCDateTime(Midnight2)#, 
											 #SessionTime2#, 0, #CreateODBCDateTime(CallBegin)#, #DayOfWeek(CallBegin)#, #CAuthID#)
										</cfquery>
										<cfset AuthImportCounter = AuthImportCounter + 1>										
									</cfif>
								</cfif>
							</cftransaction>
						</cfif>
					</cfloop>
				<cfelseif (tbcalls is not "") AND (callslogin is not "") AND (acntsestime is not "") AND (calldate is not "")>
					<cfset TheNewDate = DateAdd("h", "-#HoursImport#", DateCheck1)>
					<cfset TheNewDateMid = CreateDateTime(Year(TheNewDate),Month(TheNewDate),Day(TheNewDate),0,0,0)>
					<cfset TheNewDate2Md = CreateDateTime(Year(TheNewDate),Month(TheNewDate),Day(TheNewDate),23,59,59)>
					<cfset TheNewTimeS = CreateTime(Hour(TheNewDate),0,0)>
					<cfset TheNewTimeE = CreateTime(Hour(DateCheck1),0,0)>
					<cfquery NAME="TimeRecords" DATASOURCE="#accntodbc#">
						SELECT 0 = 0<cfloop query="AuthFields">, #DBName# As #BOBName#1</cfloop> 
						FROM #tbcalls# 
						WHERE #calldate# >= #CreateODBCDateTime(TheNewDateMid)# 
						AND #calldate# <= #CreateODBCDateTime(TheNewDate2Md)# 
						AND #calltime# < #CreateODBCTime(TheNewTimeE)# 
						AND #calltime# >= #CreateODBCTime(TheNewTimeS)# 
						AND #callslogin# In (#QuotedValueList(WhoToGet.UserName)#) 
						AND #acntsestime# Is Not NULL 
						AND #acntsestime# < 2678400 
						AND #acntsestime# > 0 
						ORDER BY #callslogin#, #calldate#
					</cfquery>
					<cfset AuthImportCounter = 0>
					<cfloop QUERY="TimeRecords">
						<cfset CallBegin = DateAdd("s","-#TotTime#",CallDateTime1)>
						<cfset DateDay1 = DatePart("d",Date1)>
						<cfset DateDay2 = DatePart("d",CallBegin)>
						<cfif DateDay1 Is DateDay2>
							<cfquery name="CheckFirst" datasource="#pds#">
								SELECT * 
								FROM TimeTrax 
								WHERE UserName = '#CallsLogin1#' 
								AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
								<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
									AND NASPort = #NasPort1# 
								<cfelse>
									<cfset NasPort1 = "">
								</cfif>
								<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
									AND NASIdentifier = '#NasIdent1#' 
								<cfelse>
									<cfset NasIdent1 = "">
								</cfif>
								AND CAuthID = #CAuthID# 
							</cfquery>
							<cfif CheckFirst.RecordCount Is 0>
								<cfquery NAME="insert" DATASOURCE="#pds#">
									INSERT INTO timetrax 
									(NASPort, NASIdentifier, UserName, CallDate, TotTime, BilledYN, 
									 CallDateB, DayOfWeek, CAuthID) 
									VALUES 
									(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
									 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
									 '#CallsLogin1#', #CreateODBCDateTime(CallDateTime1)#, 
									 #AcntSesTime1#, 0, #CreateODBCDateTime(CallBegin)#, #DayOfWeek(CallDateTime1)#, #CAuthID#)
								</cfquery>
								<cfset AuthImportCounter = AuthImportCounter + 1>
							</cfif>
						<cfelse>
							<cfset Midnight = CreateDateTime(Year(CallDateTime1),Month(CallDateTime1),Day(CallDateTime1),0,0,0)>
							<cfset Midnight2 = DateAdd("s",-1,Midnight)>
							<cfset SessionTime1 = DateDiff("s",Midnight,CallDateTime1)>
							<cfset SessionTime2 = DateDiff("s",CallBegin,Midnight2)>
							<cftransaction>
								<cfif SessionTime1 GT 0>
									<cfquery name="CheckFirst" datasource="#pds#">
										SELECT * 
										FROM TimeTrax 
										WHERE UserName = '#CallsLogin1#' 
										AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
										<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
											AND NASPort = #NasPort1# 
										<cfelse>
											<cfset NasPort1 = "">
										</cfif>
										<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
											AND NASIdentifier = '#NasIdent1#' 
										<cfelse>
											<cfset NasIdent1 = "">
										</cfif>
										AND CAuthID = #CAuthID# 
									</cfquery>
									<cfif CheckFirst.RecordCount Is 0>
										<cfquery NAME="insert" DATASOURCE="#pds#">
											INSERT INTO TimeTrax 
											(NASPort, NASIdentifier, UserName, CallDate, TotTime, BilledYN, 
											 CallDateB, DayOfWeek, CAuthID) 
											VALUES 
											(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
											 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
											 '#CallsLogin1#', #CreateODBCDateTime(CallDateTime1)#, 
											 #SessionTime1#, 0, #CreateODBCDateTime(Midnight)#, #DayOfWeek(CallDateTime1)#, #CAuthID#)
										</cfquery>
										<cfset AuthImportCounter = AuthImportCounter + 1>
									</cfif>
								</cfif>
								<cfif SessionTime2 GT 0>
									<cfquery name="CheckFirst" datasource="#pds#">
										SELECT * 
										FROM TimeTrax 
										WHERE UserName = '#CallsLogin1#' 
										AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
										<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
											AND NASPort = #NasPort1# 
										<cfelse>
											<cfset NasPort1 = "">
										</cfif>
										<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
											AND NASIdentifier = '#NasIdent1#' 
										<cfelse>
											<cfset NasIdent1 = "">
										</cfif>
										AND CAuthID = #CAuthID# 
									</cfquery>
									<cfif CheckFirst.RecordCount Is 0>
										<cfquery name="Insert2" datasource="#pds#">
											INSERT INTO TimeTrax 
											(NASPort, NASIdentifier, UserName, CallDate, 
											 TotTime, BilledYN, CallDateb, DayOfWeek, CAuthID) 
											VALUES 
											(<cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
											 <cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
											 '#username1#', #CreateODBCDateTime(Midnight2)#, 
											 #SessionTime2#, 0, #CreateODBCDateTime(CallBegin)#, #DayOfWeek(CallBegin)#, #CAuthID#)
										</cfquery>
										<cfset AuthImportCounter = AuthImportCounter + 1>
									</cfif>
								</cfif>
							</cftransaction>
						</cfif>
					</cfloop>
				</cfif>	
			</cfif>
		</cfif>
		<cfquery name="GetMask" datasource="#pds#">
			SELECT Value1 
			FROM Setup 
			WHERE VarName = 'DateMask1' 
		</cfquery>
		<cfset DateMask1 = GetMask.Value1>
		<cfset MessageOutput = MessageOutput & "Finished Importing #AuthImportCounter# records. Auth: #AuthDescription#, Date: #LSDateFormat(NextTime, '#DateMask1#')# #TimeFormat(NextTime, 'hh:ss tt')#.<br>">
		<cfif TimeNow GTE NextTime>
			<cfquery name="SetNewTime" datasource="#pds#">
				UPDATE CustomAuth SET 
				LastCompleteSpan = #CreateODBCDateTime(NextTime)# 
				WHERE CAuthID = #CAuthID# 
			</cfquery>
		</cfif>
	</cfloop>
<cfelse>
	<cfset LoopCounter= 0>
	<cfquery name="GetAuths" datasource="#pds#">
		SELECT CAuthID 
		FROM TimeTemp 
		GROUP BY CAuthID 
	</cfquery>
	<cfloop query="GetAuths">
		<cfquery name="GetAuthInfo" datasource="#pds#">
			SELECT * 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfset LoopCounter = 0>
		<cfset CAuthID = CAuthID>
		<cfquery name="ProcessWho" datasource="#pds#" MAXROWS="10">
			SELECT A.UserName, P.AccountID, P.AccntPlanID, P.PlanID 
			FROM Spans S, AccntPlans P, AccountsAuth A, Domains D 
			WHERE A.DomainID = D.DomainID 
			AND A.AccntPlanID = P.AccntPlanID 
			AND P.PlanID = S.PlanID 
			AND D.CAuthID = #CAuthID# 
			AND (S.SpanPeriod = 0 OR S.SpanPeriod = 3) 
			AND S.SpanUnit = 'Hours' 
			AND A.UserName In 
				(SELECT UserName 
				 FROM TimeTrax 
				 WHERE CAuthID = #CAuthID#
				 GROUP BY UserName) 		
			GROUP BY A.UserName, P.AccountID, P.AccntPlanID, P.PlanID  
		</cfquery>
		<cfloop QUERY="ProcessWho">
			<cfset theAccountID = AccountID>
			<cfset thePlanID = PlanID>
			<cfset theUserName = UserName>
			<cfquery NAME="alldata" DATASOURCE="#pds#">
				SELECT * 
				FROM TimeTrax 
				WHERE UserName = '#theUserName#' 
				AND CAuthID = #CAuthID# 
			</cfquery>
			<cfquery NAME="allspans" DATASOURCE="#pds#">
				SELECT Spans.SpanID, Spans.BaseAmount, Spans.OverCharge, Spans.SpanStart, 
				Spans.SpanEnd, Spans.PlanID, Spans.SpanUnit, Spans.SpanPeriod, Plans2Spans.DofWk 
				FROM Spans, Plans2Spans 
				WHERE Spans.SpanID = Plans2Spans.SpanID 
				AND Plans2Spans.PlanID = #thePlanID# 
				AND SpanUnit = 'Hours' 
				AND (SpanPeriod = 0 OR SpanPeriod = 3) 
			</cfquery>
			<cfloop QUERY="alldata">
				<cfset locCallS = TimeFormat(calldateb, 'hh:mm:ss tt')>
				<cfset locCallE = TimeFormat(calldate, 'hh:mm:ss tt')>
				<cfset CallDOW = DayOfWeek(calldate)>
				<cfset DelID = TimeID>
				<cfset locNASIdent = NASIdentifier>
				<cfset locPort = NASPort>
				<cfset locCallDate = CallDate>
				<cfloop QUERY="allspans">
					<cfset locSpanS = TimeFormat(spanstart, 'hh:mm:ss tt')>
					<cfset locSpanE = TimeFormat(spanend, 'hh:mm:ss tt')>
					<cfset locSpanP = SpanPeriod>
					<cfset theSID = spanid>
					<cfset theDOW = DofWk>
					<cfset theTAllow = BaseAmount>
					<cfset theOvrAmnt = OverCharge>
					<cfset locAllow = 1>
					<cfif theDOW Is CallDOW>
						<cfset ChargeStart = Max(locCallS,locSpanS)>
						<cfset ChargeEnd = Min(locCallE,locSpanE)>
						<cfif (locCallE lt locSpanS) OR (locCallS gt locSpanE)>
							<cfset donothing = 1>
						<cfelse>
							<cfset ChargeTime = DateDiff("s",ChargeStart, ChargeEnd)>
							<cfquery NAME="checkfirst" DATASOURCE="#pds#">
								SELECT Login 
								FROM TimeStore 
								WHERE NASIdentifier <cfif locNASIdent Is "">Is Null<cfelse>= '#locNASIdent#'</cfif> 
								AND NASPort <cfif locPort Is "">Is Null<cfelse>= #locPort#</cfif>
								AND Login = '#theUserName#' 
								AND SpanID = #theSID# 
								AND LastBillDate = #CreateODBCDateTime(locCallDate)# 
								AND CAuthID = #CAuthID#
							</cfquery>
							<cfif checkfirst.recordcount is 0>
								<cfquery NAME="InsertOne" DATASOURCE="#pds#">
									INSERT INTO TimeStore 
									(Login, AccountID, SpanID, CallDateB, CallDateE, SpanPeriod, 
									 FinishedYN, TotTimeAcc, ImportDate, NASPort, NASIdentifier, 
									 LastBillDate, TotTimeAllow, TotTimeBilled, CAuthID)
									VALUES
									('#theUserName#',#theAccountID#, #theSID#, #CreateODBCDateTime(ChargeStart)#, 
									 #CreateODBCDateTime(ChargeEnd)#, #locSpanP#, 0, #ChargeTime#, #Now()#, 
									 <cfif locPort Is "">Null<cfelse>#locPort#</cfif>, 
									 <cfif locNASIdent Is "">Null<cfelse>'#locNASIdent#'</cfif>, 
									 #CreateODBCDateTime(locCallDate)#, #theTAllow#, #theOvrAmnt#, #CAuthID#)
								</cfquery>	
								<cfset LoopCounter = LoopCounter + 1>				
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
				<cfquery NAME="finishedit" DATASOURCE="#pds#">
					DELETE FROM TimeTrax 
					WHERE TimeID = #DelID#
				</cfquery>
				<cfset MessageOutput = MessageOutput & "Finished Importing #LoopCounter# records for #theUserName#. Auth: #GetAuthInfo.AuthDescription#.<br>">
				<cfset LoopCounter = 0>
			</cfloop>
		</cfloop>
	</cfloop>
</cfif>


<cfquery NAME="checknow" DATASOURCE="#pds#">
	SELECT UserName 
	FROM TimeTrax
</cfquery>
<cfquery name="newdate" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	WHERE AuthType = 1 
	AND LastComplete < #CreateODBCDateTime(ImportStartDate)# 
	<cfif IsDefined("ID")>
		AND CAuthID = #ID#
	</cfif>
</cfquery>
<cfif (newdate.RecordCount Is 0) AND (checknow.RecordCount Is 0)>
	<cfset stopnow =1>
</cfif>

<cfsetting enablecfoutputonly="No" showdebugoutput="Yes">
<cfoutput>
<html>
<head>
<title>Importer</title>
<cfif IsDefined("catchup")>
	<cfif Not IsDefined("stopnow")>
		<META HTTP-EQUIV=REFRESH CONTENT="5; URL=maintmeterbill.cfm?Catchup=1<cfif IsDefined("ID")>&ID=#ID#</cfif>&RequestTimeout=500">
	</cfif>
</cfif>
</head>
<body>
<cfif IsDefined("MessageOutput")>
	#MessageOutput#
<cfelse>
	No new imports.
</cfif>
</body>
</html>
</cfoutput>
 