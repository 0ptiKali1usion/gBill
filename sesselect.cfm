<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page selects the date range for session history reports. --->
<!--- 4.0.1 02/12/01 Added RadValues lookup for Radius NT. 
		4.0.0 --->
<!--- sesselect.cfm --->
<cfif GetOpts.SessHist Is "1">
	<cfset securepage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfif IsDefined("ReturnID")>
	<cfset AccountID = ReturnID>
</cfif>
<cfif Not IsDefined("AccountID")>
	<cflocation addtoken="No" url="admin.cfm">
</cfif>

<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 25 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("ReturnID")>
	<cfset AccountID = ReturnID>
</cfif>
<cfquery name="CheckReportFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 25 
</cfquery>
<cfsetting enablecfoutputonly="No">
<cfif CheckReportFirst.Recordcount GT 0>
	<cfsetting enablecfoutputonly="Yes">
		<cfquery name="GetValues" datasource="#pds#">
			SELECT MemoField 
			FROM GrpLists 
			WHERE ReportID = 25 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset TheSendValues = GetValues.MemoField>
		<cfset SendHeader = ListGetAt(TheSendValues,1,":")>
		<cfset SendFields = ListGetAt(TheSendValues,2,":")>
	<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Session Totals</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td colspan="4" bgcolor="#tbclr#">This is already a Session total report in progress.</td>
		</tr>	
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="25">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="Hidden" name="ReturnID" value="#AccountID#">
				<input type="hidden" name="ReturnPage" value="sesselect.cfm">
				<input type="hidden" name="SendHeader" value="#SendHeader#">
				<input type="hidden" name="SendFields" value="#SendFields#">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="sesselect.cfm">
				<th colspan="2" width="50%"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
				<input type="Hidden" name="AccountID" value="#AccountID#">
			</form>
		</tr>
	</table>
	</cfoutput>
	</center>	
	<cfinclude template="footer.cfm">
	</body>
	</html>
	<cfabort>
</cfif>
<cfsetting enablecfoutputonly="Yes">
<cfif IsDefined("SessReport.x")>
	<cfif TheSpan Is 1>
		<cfquery name="GetCAuthID" datasource="#pds#">
			SELECT CAuthID, UserName, DomainName 
			FROM AccountsAuth 
			WHERE AuthID = #AuthID#
		</cfquery>
		<cfset CAuthID = GetCAuthID.CAuthID>
		<cfset UserName = GetCAuthID.UserName>
		<cfset DomainName = GetCAuthID.DomainName>
		<cfset Pos1 = ListFindNoCase(TheCAuIDs,CAuthID)>
		
		<cfset DataSource = ListGetAt(TheDataSs,Pos1)>
		<cfset TableName = ListGetAt(TheTables,Pos1)>
		<cfset LoginField = ListGetAt(TheUnames,Pos1)>
		<cfset SessField = ListGetAt(TheSessTm,Pos1)>
		<cfset DateField = ListGetAt(TheDateFd,Pos1)>
		
		<cfset Date1 = CreateDateTime(FromYear,FromMon,FromDay,0,0,0)>
		<cfset Date2 = CreateDateTime(ToYear,ToMon,Today,23,59,59)>
		
		<cfquery name="GetHowToLookUp" datasource="#pds#">
			SELECT SessLookup 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfif GetHowToLookUp.SessLookup Is 1>
			<cfset UserName = UserName & "@" & DomainName>
		</cfif>
		<cfquery name="GetTheFields" datasource="#pds#" maxrows="15">
			SELECT DBName, BOBName, ReportTotal, CFVarYN, DataType, Descrip1, 
			CASE CHARINDEX('AccntTerminateCause', DBName, 1) WHEN 1 THEN 1 ELSE 0 END AS AccntFlag 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ForTable = 13 
			AND ActiveYN = 1 
			AND ReportUse = 1 
			AND DBType = 'FD' 
			ORDER BY SortOrder
		</cfquery>
		<cfquery name="AllTheSessions" datasource="#DataSource#">
			SELECT 
			<cfloop query="GetTheFields">#DBName#<cfif BOBName Is NOT DBName><cfif CFVarYN Is 1> As #BOBName#<cfelse> As Custom#CurrentRow#</cfif></cfif><cfif CurrentRow Is Not RecordCount>, </cfif></cfloop>
			FROM #TableName# 
			WHERE #DateField# < #CreateODBCDateTime(Date2)# 
			AND #DateField# > #CreateODBCDateTime(Date1)# 
			AND #LoginField# = '#UserName#'
		</cfquery>
		<cfset TextFields = "Address,City,Company,Phone,PhoneWk,ReportHeader,ResultsCol,TextField,FirstName,LastName,EMail,ReportURL,ReportStr">

		<cfset TheInsertFields = "">
		<cfset TheHeaderFields = "">
		<cfset TheBOBNameFields = "">
		<cfloop query="GetTheFields">
			<cfif BOBName Is "acntsestime">
				<cfset TheInsertFields = ListAppend(TheInsertFields,"CurTime")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelseif (BOBName Is "calldatetime") OR (BOBName Is "calldate")>
				<cfset TheInsertFields = ListAppend(TheInsertFields,"EndTime")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelseif BOBName Is "calltime">
				<cfset TheInsertFields = ListAppend(TheInsertFields,"ReportDate")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelseif BOBName Is "callslogin">
				<cfset TheInsertFields = ListAppend(TheInsertFields,"Login")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelseif BOBName Is "inputoct">
				<cfset TheInsertFields = ListAppend(TheInsertFields,"ReportURLID")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelseif BOBName Is "outputoct">
				<cfset TheInsertFields = ListAppend(TheInsertFields,"ReportURLID2")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
			<cfelse>
				<cfset ThisTime = ListGetAt(TextFields,1)>
				<cfset TheInsertFields = ListAppend(TheInsertFields,"#ThisTime#")>
				<cfset TheHeaderFields = ListAppend(TheHeaderFields,Descrip1)>
				<cfset TheBOBNameFields =ListAppend(TheBOBNameFields,"#BOBName#")>
				<cfset TextFields = ListDeleteAt(TextFields,1)>
			</cfif>
			<cfif AccntFlag Is 1>
				<cfset TheTermField = ThisTime>
			</cfif>
		</cfloop>

		<cfloop query="AllTheSessions">
			<cfset TheRowCount = CurrentRow>
			<cfquery name="InsInto" datasource="#pds#">
				INSERT INTO GrpLists 
				(ReportID, AdminID, ReportTitle, CreateDate, AccountID, 
				 #TheInsertFields#, StartTime)
				VALUES
				(25, #MyAdminID#, 'Session History - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')# for #GetCAuthID.UserName#', #Now()#, #AccountID#, 
				 <cfloop query="GetTheFields">
				 	<cfif DataType Is "Text">
						<cfif CFVarYN Is 1>
							<cfset DispStr = Evaluate("AllTheSessions.#BOBName#[#TheRowCount#]")>
							<cfif DispStr Is "">Null<cfelse>'#Trim(DispStr)#'</cfif>, 
						<cfelse>
							<cfset DispStr = Evaluate("AllTheSessions.#BOBName##CurrentRow#[#TheRowCount#]")>
							<cfif DispStr Is "">Null<cfelse>'#Trim(DispStr)#'</cfif>, 
						</cfif>
					<cfelseif DataType Is "number">
						<cfif CFVarYN Is 1>
							<cfset DispStr = Evaluate("AllTheSessions.#BOBName#[#TheRowCount#]")>
							<cfif DispStr Is "">Null<cfelse>#DispStr#</cfif>, 
						<cfelse>
							<cfset DispStr = Evaluate("AllTheSessions.#BOBName##CurrentRow#[#TheRowCount#]")>
							<cfif DispStr Is "">Null<cfelse>#DispStr#</cfif>,
						</cfif>
					<cfelseif DataType Is "Date">
						<cfset BOBDate = Evaluate("AllTheSessions.#BOBName#[#TheRowCount#]")>
						<cfif BOBDate Is "">Null<cfelse>#CreateODBCDateTime(BOBDate)#</cfif>, 
					</cfif>
				</cfloop>
				 0)
			</cfquery>
		</cfloop>
		<cfquery name="CheckFor" datasource="#pds#">
			SELECT CRSID 
			FROM CustomAuthSetup 
			WHERE DBName = 'AccntTerminateCause' 
			AND CAuthID = #CAuthID# 
			AND ReportUse = 1 
		</cfquery>
		<cfif CheckFor.RecordCount GT 0>
			<cfquery name="GetRadValues" datasource="#DataSource#">
				SELECT Value, Name 
				FROM RadValues 
				WHERE RadAttributeID = 49 
			</cfquery>
			<cfloop query="GetRadValues">
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE GrpLists SET 
					#TheTermField# = '#Name#' 
					WHERE #TheTermField# = '#Value#'
				</cfquery>
			</cfloop>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			StartTime = DateAdd(ss,-CurTime,EndTime), 
			ReportDate = DateAdd(ss,-CurTime,EndTime) 
			WHERE ReportID = 25 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset Pos1 = ListFindNoCase(TheBOBNameFields,"acntsestime")>
		<cfif Pos1 GT 0>
			<cfset TheHeaderFields = ListInsertAt(TheHeaderFields,Pos1,"Time")>
			<cfset TheInsertFields = ListInsertAt(TheInsertFields,Pos1,"SessTime")>
			<cfset TheBOBNameFields = ListInsertAt(TheBOBNameFields,Pos1,"SessTime")>
			<cfset Pos2 = ListFindNoCase(TheBOBNameFields,"acntsestime")>
			<cfset TheHeaderFields = ListDeleteAt(TheHeaderFields,Pos2)>
			<cfset TheInsertFields = ListDeleteAt(TheInsertFields,Pos2)>
		</cfif>
		<cfset Pos1 = ListFindNoCase(TheBOBNameFields,"calldatetime")>
		<cfif Pos1 GT 0>
			<cfset TheHeaderFields = ListInsertAt(TheHeaderFields,Pos1,"Date,Start,End")>
			<cfset TheInsertFields = ListInsertAt(TheInsertFields,Pos1,"ReportDate,StartTime,EndTime")>
			<cfset TheBOBNameFields = ListInsertAt(TheBOBNameFields,Pos1,"ST,ET")>
			<cfset Pos2 = ListFindNoCase(TheBOBNameFields,"calldatetime")>
			<cfset TheHeaderFields = ListDeleteAt(TheHeaderFields,Pos2)>
			<cfset TheInsertFields = ListDeleteAt(TheInsertFields,Pos2)>
		</cfif>
		<cfset Pos1 = ListFindNoCase(TheBOBNameFields,"calldate")>
		<cfif Pos1 GT 0>
			<cfset TheHeaderFields = ListInsertAt(TheHeaderFields,Pos1,"Date,Start,End")>
			<cfset TheInsertFields = ListInsertAt(TheInsertFields,Pos1,"ReportDate,StartTime,EndTime")>
			<cfset TheBOBNameFields = ListInsertAt(TheBOBNameFields,Pos1,"ST,ET")>
			<cfset Pos2 = ListFindNoCase(TheBOBNameFields,"calldate")>
			<cfset TheHeaderFields = ListDeleteAt(TheHeaderFields,Pos2)>
			<cfset TheInsertFields = ListDeleteAt(TheInsertFields,Pos2)>
		</cfif>
		<cfset Pos1 = ListFindNoCase(TheBOBNameFields,"calltime")>
		<cfif Pos1 GT 0>
			<cfset TheHeaderFields = ListDeleteAt(TheHeaderFields,Pos1)>
			<cfset TheInsertFields = ListDeleteAt(TheInsertFields,Pos1)>
		</cfif>

		<cfset SendHeader = "#TheHeaderFields#">
		<cfset SendFields = "#TheInsertFields#">
		<cfquery name="SetSendValues" datasource="#pds#">
			UPDATE GrpLists SET 
			MemoField = '#TheHeaderFields#:#TheInsertFields#' 
			WHERE ReportID = 25 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			UPDATE GrpLists SET 
			CurTime = 0 
			WHERE ReportID = 25 
			AND AdminID = #MyAdminID# 
			AND CurTime Is Null
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE ReportID = 25 
			AND AdminID = #MyAdminID# 
			AND CurTime = 0 
		</cfquery>
		<cfset SendReportID = 25>
		<cfset SendLetterID = 0>
		<cfquery name="ClearEmailTable" datasource="#pds#">
			DELETE FROM EMailOutGoing 
			WHERE LetterID = 25 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset ReturnPage = "sesselect.cfm">
		<cfset ReturnID = AccountID>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="grplist.cfm">
		<cfabort>
	<cfelse>
		<cfquery name="GetAuthInfo" datasource="#pds#">
			SELECT UserName 
			FROM AccountsAuth 
			WHERE AuthID = #AuthID# 
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT GrpListID 
			FROM GrpLists 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 25
		</cfquery>
		<cfset Date1 = CreateDateTime(fromyear,frommon,fromday,0,0,0)>
		<cfset Date2 = CreateDateTime(toyear,tomon,today,23,59,59)>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="SessionHistory" datasource="#pds#">
				INSERT INTO GrpLists 
				(Login, AdminID, AccountID, ReportDate, StartTime, EndTime, CurTime, ReportURLID2, Address, 
				ReportTitle, ReportID, CreateDate) 
				SELECT Login, #MyAdminID#, AccountID, LastBillDate, CallDateB, CallDateE, TotTimeAcc, NASPort, 
				NASIdentifier, 'Metered History - #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#', 25, #Now()# 
				FROM TimeStore 
				WHERE AccountID = #AccountID# 
				AND LastBillDate <= #CreateODBCDateTime(Date2)# 
				AND LastBillDate >= #CreateODBCDateTime(Date1)# 
				AND Login IN 
					(SELECT UserName 
					 FROM AccountsAuth 
					 WHERE AuthID IN (#AuthID#)
					 )
			</cfquery>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE GrpLists SET 
			FirstName = A.FirstName, 
			LastName = A.LastName 
			FROM Accounts A, GrpLists G 
			WHERE A.AccountID = G.AccountID 
			AND G.ReportID = 25 
			AND G.AccountID = #AccountID# 
			AND G.AdminID = #MyAdminID# 	
		</cfquery>
		<cfset SendReportID = 25>
		<cfset SendLetterID = 0>
		<cfquery name="ClearEmailTable" datasource="#pds#">
			DELETE FROM EMailOutGoing 
			WHERE LetterID = 25 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset ReturnPage = "sesselect.cfm">
		<cfset SendHeader = "Login,Date,Start,End,Time,NAS Identifier,NAS Port">
		<cfset SendFields = "Login,ReportDate,StartTime,EndTime,SessTime,Address,ReportURLID2">
		<cfset ReturnID = AccountID>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="grplist.cfm">
		<cfabort>
	</cfif>	
</cfif>
<!--- Check the Auth Setups --->
<cfquery name="AllTheAuths" datasource="#pds#">
	SELECT CAuthID, SessLookup 
	FROM CustomAuth 
	WHERE CAuthID In 
		(SELECT CAuthID 
		 FROM AccountsAuth 
		 WHERE AccountID = #AccountID#)
</cfquery>
<cfset TheDataSs = "">
<cfset TheTables = "">
<cfset TheUnames = "">
<cfset TheSessTm = "">
<cfset TheDateFd = "">
<cfset TheCAuIDs = "">
<cfset TheAddDom = "">
<cfloop query="AllTheAuths">
	<cfquery name="CheckDS" datasource="#pds#">
		SELECT DBName 
		FROM CustomAuthSetup 
		WHERE BOBName = 'AccntODBC' 
		AND ActiveYN = 1 
		AND CAuthID = #CAuthID# 
		AND DBType = 'Ds' 
	</cfquery>
	<cfif CheckDS.DBName Is NOT "">
		<cfquery name="CheckTb" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'TbCalls' 
			AND ActiveYN = 1 
			AND CAuthID = #CAuthID# 
			AND DBType = 'Tb' 
		</cfquery>
		<cfif CheckTb.DBName Is NOT "">
			<cfquery name="CheckFd" datasource="#pds#">
				SELECT DBName 
				FROM CustomAuthSetup 
				WHERE BOBName = 'CallsLogin' 
				AND ActiveYN = 1 
				AND CAuthID = #CAuthID# 
				AND DBType = 'Fd' 
			</cfquery>
			<cfif CheckFd.DBName Is NOT "">
				<cfquery name="CheckST" datasource="#pds#">
					SELECT DBName 
					FROM CustomAuthSetup 
					WHERE BOBName = 'AcntSesTime' 
					AND ActiveYN = 1 
					AND CAuthID = #CAuthID# 
					AND DBType = 'Fd' 
				</cfquery>
				<cfif CheckST.DBName Is NOT "">
					<cfquery name="CheckDT" datasource="#pds#">
						SELECT DBName 
						FROM CustomAuthSetup 
						WHERE BOBName = 'CallDateTime' 
						AND ActiveYN = 1 
						AND CAuthID = #CAuthID# 
						AND DBType = 'Fd' 					
					</cfquery>
					<cfif CheckDT.DBName Is "">
						<cfquery name="CheckDT" datasource="#pds#">
							SELECT DBName 
							FROM CustomAuthSetup 
							WHERE BOBName = 'CallDate' 
							AND ActiveYN = 1 
							AND CAuthID = #CAuthID# 
							AND DBType = 'Fd' 
						</cfquery>
					</cfif>
					<cfif CheckDT.DBName Is NOT "">
						<cfset TheDataSs = ListAppend(TheDataSs,CheckDS.DBName)>
						<cfset TheTables = ListAppend(TheTables,CheckTb.DBName)>
						<cfset TheUnames = ListAppend(TheUnames,CheckFd.DBName)>
						<cfset TheSessTm = ListAppend(TheSessTm,CheckST.DBName)>
						<cfset TheDateFd = ListAppend(TheDateFd,CheckDT.DBName)>
						<cfset TheCAuIDs = ListAppend(TheCAuIDs,CAuthID)>
						<cfset TheAddDom = ListAppend(TheAddDom,SessLookup)>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cfloop>

<cfif ListLen(TheDataSs) Is 0>
	<cfquery name="AuthInfo" datasource="#pds#">
		SELECT AuthDescription 
		FROM CustomAuth 
		WHERE CAuthID In 
			(SELECT CAuthID 
		 	 FROM AccountsAuth 
			 WHERE AccountID = #AccountID#) 
	</cfquery>
<cfelse>
	<cfset TheMinimumDate = Now()>
	<cfset TheMaximumDate = Now()>
	<cfquery name="SpanTime" datasource="#pds#">
		SELECT Login 
		FROM TimeStore 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif SpanTime.RecordCount GT 0>
		<cfquery name="GetSpanDates" datasource="#pds#">
			SELECT Min(LastBillDate) MinDate, Max(LastBillDate) MaxDate 
			FROM TimeStore 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif GetSpanDates.MinDate Is NOT "">
			<cfif GetSpanDates.MinDate LT TheMinimumDate>
				<cfset TheMinimumDate = GetSpanDates.MinDate>
			</cfif>
			<cfif GetSpanDates.MaxDate GT TheMaximumDate>
				<cfset TheMaximumDate = GetSpanDates.MaxDate>
			</cfif>
		</cfif>
	</cfif>
	<cfquery name="AllUserNames" datasource="#pds#">
		SELECT A.UserName, A.DomainName, A.AuthID, C.CAuthID, C.AuthDescription, C.SessLookup 
		FROM AccountsAuth A, CustomAuth C 
		WHERE A.CAuthID = C.CAuthID 
		AND A.AccountID = #AccountID# 
		AND C.CAuthID In (#TheCAuIDs#) 
		ORDER BY A.UserName, C.AuthDescription 
	</cfquery>
	<cfloop query="AllUserNames">
		<cfset Pos1 = ListFind(TheCAuIDs,CAuthID)>
		<cfset DataSource = ListGetAt(TheDataSs,Pos1)>
		<cfset TableName = ListGetAt(TheTables,Pos1)>
		<cfset LoginField = ListGetAt(TheUnames,Pos1)>
		<cfset SessField = ListGetAt(TheSessTm,Pos1)>
		<cfset DateField = ListGetAt(TheDateFd,Pos1)>
		<cfquery name="GetSpanDates" datasource="#DataSource#">
			SELECT Min(#DateField#) As MinDate, Max(#DateField#) As MaxDate 
			FROM #TableName# 
			WHERE #LoginField# = '#UserName#' 
		</cfquery>
		<cfif GetSpanDates.MinDate Is NOT "">
			<cfif GetSpanDates.MinDate LT TheMinimumDate>
				<cfset TheMinimumDate = GetSpanDates.MinDate>
			</cfif>
			<cfif GetSpanDates.MaxDate GT TheMaximumDate>
				<cfset TheMaximumDate = GetSpanDates.MaxDate>
			</cfif>
		</cfif>
	</cfloop>

	<cfset StartDateSelect = Now()>
	<cfset StartDateDropDnS = TheMinimumDate>
	<cfset StartDateDropDnE = TheMaximumDate>
	<cfset EndDateSelect = Now()>
	<cfset EndDateDropDnS = TheMinimumDate>
	<cfset EndDateDropDnE = TheMaximumDate>
	
	<cfparam name="timespan" default="0">
</cfif>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Session History</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<cfoutput>
		<input type="hidden" name="accountid" value="#accountid#">
		<input border="0" type="image" name="return" src="images/returncust.gif">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
</cfoutput>
	<tr>
		<cfoutput>
			<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Session History</font></th>
		</cfoutput>
	</tr>
	<cfif ListLen(TheDataSs) Is 0>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">The following Custom Authentications are not setup to look at session history.<br>
					#ValueList(AuthInfo.AuthDescription)#<br>
					This report needs the following information to work:<br>
					Datasource<br>
					Session History Table Name<br>
					Calls Username<br>
					Date Time<br>
					Session Time
				</td>
			</cfoutput>
		</tr>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">The needed information can be entered on the <a href="customauthsetup.cfm">Custom Authentication</a> setup page.</td>
			</cfoutput>
		</tr>
	<cfelse>
		<cfoutput>
		<form method=post name="getdate" action="sesselect.cfm?RequestTimeout=500" onsubmit="return checkdates()">
			<cfif SpanTime.Recordcount GT 0>
				<tr>
					<th bgcolor="#thclr#" colspan="4"><input type="Radio" name="TheSpan" value="1" checked>All Time <input type="Radio" name="TheSpan" value="0" >Metered Time</th>
				</tr>
			<cfelse>
				<input type="Hidden" name="TheSpan" value="1">
			</cfif>
		</cfoutput>
			<cfset StartDateSelect = CreateDateTime(Year(Now()),Month(Now()),1,0,0,0)>
			<cfinclude template="dateselect.cfm">
			
			<cfif AllUserNames.Recordcount GT 1>
				<cfset HowHigh = AllUserNames.Recordcount>
				<cfif HowHigh GT 4>
					<cfset HowHigh = 4>
				</cfif>
				<cfoutput>
				<tr bgcolor="#tdclr#" valign="top">
					<td bgcolor="#tbclr#" align=right>Login:</td>
					<td colspan="3"><select name="AuthID" size="#HowHigh#">
				</cfoutput>
						<cfoutput query="AllUserNames">
							<option value="#AuthID#">#UserName#<cfif SessLookup Is 1>@#DomainName#</cfif> - #AuthDescription#
						</cfoutput>
					</select></td>
				</tr>
			<cfelse>
				<cfoutput>
					<input type="Hidden" name="AuthID" value="#AllUserNames.AuthID#">
				</cfoutput>
			</cfif>
			<tr>
				<th colspan=4><input type="image" name="SessReport" src="images/lookup.gif" border="0"></th>
			</tr>
			<cfoutput>
				<input type="hidden" name="accountid" value="#accountid#">
				<input type="Hidden" name="TheDataSs" value="#TheDataSs#">
				<input type="Hidden" name="TheTables" value="#TheTables#">
				<input type="Hidden" name="TheUnames" value="#TheUnames#">
				<input type="Hidden" name="TheSessTm" value="#TheSessTm#">
				<input type="Hidden" name="TheDateFd" value="#TheDateFd#">
				<input type="Hidden" name="TheCAuIDs" value="#TheCAuIDs#">
				<input type="Hidden" name="TheAddDom" value="#TheAddDom#">
			</cfoutput>
		</form>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 