<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page runs as scheduled to import radius records from a database. --->
<!--- 4.0.0 04/24/00 
		3.5.0 06/18/99 
		3.2.0 09/08/98 --->
<!--- maintradiusimport.cfm --->
<!--- Auto runs to import radius records from a database. --->

<cfset DefaultStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
<cfset ImportStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Hour(Now()),0,0)>

<cfparam name="MessageOutput" default="">

<cfquery name="GetAuths" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	WHERE AuthType = 1 
	AND LastComplete < #CreateODBCDateTime(ImportStartDate)# 
	<cfif IsDefined("ID")>
		AND CAuthID = #ID#
	</cfif>
</cfquery>
<cfparam name="pds2" default="CustomRadius">
<cfparam name="HoursImport" default="1">

<cfquery name="GetRadType" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'DateMask1' 
	OR VarName = 'HoursImport' 
</cfquery>
<cfoutput query="getradtype">
	<cfset "#varname#" = GetRadType.Value1>
</cfoutput>
	
<cfloop query="GetAuths">
	<cfquery name="GetDS" datasource="#pds#">
		SELECT DBName 
		FROM CustomAuthSetup 
		WHERE BOBName = 'accntodbc' 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfset CAuthID = CAuthID>
	<cfset pds2 = GetDS.DBName>
	<cfif IsDate(LastImport)>
		<cfset TheImport1 = LastImport>
	<cfelse>
		<cfset TheImport1 = DefaultStartDate>
	</cfif>
	<cfif IsDate(LastComplete)>
		<cfset TheImport2 = LastComplete>
	<cfelse>	
		<cfset TheImport2 = DefaultStartDate>
	</cfif>
	<cfif TheImport1 Is Not TheImport2>
		<cfquery NAME="RemoveOld" DATASOURCE="#pds#">
			DELETE FROM Calls 
			WHERE BilledYN = 0 
			AND CallDate > #CreateODBCDateTime(TheImport2)# 
			AND CAuthID = #CAuthID# 
		</cfquery>
		<cfquery NAME="SetDate" DATASOURCE="#pds#">
			UPDATE CustomAuth SET 
			LastImport = #CreateODBCDateTime(TheImport2)#, 
			LastComplete = #CreateODBCDateTime(TheImport2)# 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfquery name="GetNewDates" datasource="#pds#">
			SELECT LastImport, LastComplete 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfset TheImport1 = GetNewDates.LastImport>
		<cfset TheImport2 = GetNewDates.LastComplete>
	</cfif>
	<cfset NextTime = DateAdd("h",HoursImport,TheImport1)>
	<cfset TimeNow = Now()>
	<cfif TimeNow GTE NextTime>
		<cfquery name="SetNewTime" datasource="#pds#">
			UPDATE CustomAuth SET 
			LastImport = #CreateODBCDateTime(NextTime)# 
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
			AND S.SpanPeriod = 1 
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
					SELECT 0 <cfloop query="AuthFields">, #DBName# As #BOBName#1</cfloop>
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
					<cfquery NAME="checkfirst" DATASOURCE="#pds#">
						SELECT * 
						FROM Calls 
						WHERE UserName = '#CallsLogin1#' 
						AND CallDate = #CreateODBCDateTime(CallDateTime1)# 
						<cfif ListFind(TimeRecords.ColumnList,"NasPort1")>
							AND NASPort = #NasPort1# 
						</cfif>
						<cfif ListFind(TimeRecords.ColumnList,"NasIdent1")>
							AND NASIdentifier = '#NasIdent1#'
						</cfif>
						AND CAuthID = #CAuthID#
					</cfquery>
					<cfif checkfirst.recordcount is 0>
						<cfquery NAME="InsertData" DATASOURCE="#pds#">
							INSERT INTO Calls 
							(NASIdentifier, NASPort, CallDate, UserName, BilledYN, AcctSessionTime, CAuthID) 
							VALUES 
							(<cfif NasIdent1 Is "">Null<cfelse>'#NasIdent1#'</cfif>, 
							 <cfif NasPort1 Is "">Null<cfelse>#NasPort1#</cfif>, 
							 #CreateODBCDateTime(CallDateTime1)#, '#CallsLogin1#', 0, #AcntSesTime1#, #CAuthID#)
						</cfquery>
						<cfset AuthImportCounter = AuthImportCounter + 1>
					</cfif>
				</cfloop>
			<cfelseif (tbcalls is not "") AND (callslogin is not "") AND (acntsestime is not "") AND (calldate is not "")>
				<cfset TheNewDate = DateAdd("h", "-#HoursImport#", DateCheck1)>
				<cfset TheNewDateMid = CreateDateTime(Year(TheNewDate),Month(TheNewDate),Day(TheNewDate),0,0,0)>
				<cfset TheNewDate2Md = CreateDateTime(Year(TheNewDate),Month(TheNewDate),Day(TheNewDate),23,59,59)>
				<cfset TheNewTimeS = CreateTime(Hour(TheNewDate),0,0)>
				<cfset TheNewTimeE = CreateTime(Hour(DateCheck1),0,0)>
				<cfquery NAME="TimeRecords" DATASOURCE="#accntodbc#">
					SELECT 0 <cfloop query="AuthFields">, #DBName# As #BOBName#1</cfloop> 
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
					<cfquery NAME="checkfirst" DATASOURCE="#pds#">
						SELECT * 
						FROM Calls 
						WHERE UserName = '#CallsLogin1#' 
						AND CallDate = #CreateODBCDateTime(CallDate1)# 
						<cfif ListFind(TimeRecords.ColumnList,"NASPORT1")>
							AND NASPort = #NasPort1# 
						</cfif>
						<cfif ListFind(TimeRecords.ColumnList,"NASIDENT1")>
							AND NASIdentifier = '#NasIdent1#'
						</cfif>
						AND CAuthID = #CAuthID#
					</cfquery>
					<cfif checkfirst.recordcount is 0>
						<cfset TheNewDateTime = CreateDateTime(Year(CallDate1),Month(CallDate1),Day(CallDate1),Hour(CallTime1),Minute(CallTime1),Second(CallTime1) )>
						<cfquery NAME="InsertData" DATASOURCE="#pds#">
							INSERT INTO Calls 
							(NASIdentifier, NASPort, CallDate, UserName, BilledYN, AcctSessionTime, CAuthID) 
							VALUES 
							(<cfif NasIdent1 Is "">'Null'<cfelse>'#NasIdent1#'</cfif>, 
							 <cfif NasPort1 Is "">Null<cfelse>#Int(NasPort1)#</cfif>, 
							 #CreateODBCDateTime(TheNewDateTime)#, '#CallsLogin1#', 0, #AcntSesTime1#, #CAuthID#)
						</cfquery>
						<cfset AuthImportCounter = AuthImportCounter + 1>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<cfset MessageOutput = MessageOutput & "Finished Importing #AuthImportCounter# records. Auth: #AuthDescription#, Date: #LSDateFormat(NextTime, '#DateMask1#')# #TimeFormat(NextTime, 'hh:ss tt')#.<br>">
	</cfif>
	<!--- Insert into Calls Table in Custom Radius Database --->
	<cfif TimeNow GTE NextTime>
		<cfquery name="SetNewTime" datasource="#pds#">
			UPDATE CustomAuth SET 
			LastComplete = #CreateODBCDateTime(NextTime)# 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
	</cfif>
</cfloop>

<cfquery name="newdate" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	WHERE AuthType = 1 
	AND LastComplete < #CreateODBCDateTime(ImportStartDate)# 
	<cfif IsDefined("ID")>
		AND CAuthID = #ID#
	</cfif>
</cfquery>
<cfif newdate.RecordCount Is 0>
	<cfset stopnow =1>
</cfif>

<cfsetting enablecfoutputonly="No" showdebugoutput="No">
<cfoutput>
<html>
<head>
<title>Importer</title>
<cfif IsDefined("catchup")>
	<cfif Not IsDefined("stopnow")>
		<META HTTP-EQUIV=REFRESH CONTENT="2; URL=maintradiusimport.cfm?Catchup=1<cfif IsDefined("ID")>&ID=#ID#</cfif>&RequestTimeout=500">
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