<cfsetting enablecfoutputonly="Yes">
<!--- Version 3.2.0 --->
<!--- This page selects the date range for session history reports. --->
<!--- sesselect.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 25 
		AND AccountID = #AccountID# 
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
	AND AccountID = #AccountID# 
	AND ReportID = 25 
</cfquery>
<cfsetting enablecfoutputonly="No">
<cfif CheckReportFirst.Recordcount GT 0>
	<html>
	<head>
	<title>Session Totals</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
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
				<input type="hidden" name="SendHeader" value="Login,Date,Start,End,Time,NAS Identifier,NAS Port">
				<input type="hidden" name="SendFields" value="Login,ReportDate,StartTime,EndTime,SessTime,Address,ReportURLID2">
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

<cfif IsDefined("report.x")>
	<!--- All or Metered? --->
	<cfif thespan Is 1>
		<!--- Get The AuthInfo --->
		<cfquery name="GetAuthDates" datasource="#pds#">
			SELECT C.DBName, C.CAuthID, A.AuthDescription, A.AuthType 
			FROM CustomAuthSetup C, CustomAuth A 
			WHERE C.CAuthID = A.CAuthID 
			AND C.BOBName = 'accntodbc' 
			AND A.CAuthID = 
				(SELECT CAuthID 
				 FROM Domains 
				 WHERE DomainID = 
				 	(SELECT DomainID 
					 FROM AccountsAuth 
					 WHERE AuthID = #AuthID#)
				)
		</cfquery>
		<cfset CAuthID = GetAuthDates.CAuthID>
		<cfset AuthODBC = GetAuthDates.DBName>
		<cfquery name="GetTBName" datasource="#pds#">
			SELECT DBName, CRSID 
			FROM CustomAuthSetup 
			WHERE BOBName = 'tbcalls' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetUserName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'callslogin' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetSessName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'acntsestime' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetDateName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'calldatetime' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfif GetDateName.DBName Is "">
			<cfquery name="GetDateName" datasource="#pds#">
				SELECT DBName 
				FROM CustomAuthSetup 
				WHERE BOBName = 'calldate' 
				AND CAuthID = #CAuthID#
			</cfquery>			
		</cfif>
		<cfif (GetTBName.DBName Is not "") AND (GetUserName.DBName Is not "")
   	 AND (GetSessName.DBName Is not "") AND (GetDateName.DBName Is not "")>
		<!--- Lookup the Calls records --->
			<cfset Date1 = CreateDateTime(fromyear,frommon,fromday,0,0,0)>
			<cfset Date2 = CreateDateTime(toyear,tomon,today,23,59,59)>
			<cfquery name="GetReportInfo" datasource="#pds#">
				SELECT DBName, BOBName 
				FROM CustomAuthSetup 
				WHERE CAuthID = #CAuthID# 
				AND ForTable = 13 
				AND UseYN = 1 
				AND DBType = 'FD' 
			</cfquery>
			<cfquery name="LoginNameInfo" datasource="#pds#">
				SELECT UserName 
				FROM AccountsAuth 
				WHERE AuthID = #AuthID#
			</cfquery>
			<cfquery name="AllAuthInfo" datasource="#AuthODBC#">
				SELECT 
					<cfloop query="GetReportInfo">
						<cfif (DBName Is Not "") AND (BOBName Is Not "")>
							<cfif CurrentRow GT 1>,</cfif> #DBName# <cfif BOBName Is Not DBName>As #BOBName#</cfif>
						</cfif>
					</cfloop>
				FROM #GetTBName.DBName# 
				WHERE #GetUserName.DBName# = '#LoginNameInfo.UserName#' 
				AND #GetDateName.DBName# < #Date2# 
				AND #GetDateName.DBName# > #Date1# 
				ORDER BY #GetDateName.DBName#
			</cfquery>
			<cfset TheFieldStr = ValueList(GetReportInfo.BOBName)>
			<cfset ForTable = GetTBName.CRSID>
			<cfset TheQueryStr = "SELECT "> 
					<cfloop query="GetReportInfo">
						<cfif (DBName Is Not "") AND (BOBName Is Not "")>
							<cfif CurrentRow GT 1>
								<cfset TheQueryStr = TheQueryStr & ", #DBName# ">
							<cfelse>
								<cfset TheQueryStr = TheQueryStr & "#DBName# ">
							</cfif>
							<cfif BOBName Is Not DBName>
								<cfset TheQueryStr = TheQueryStr & " As #BOBName# ">
							</cfif>
						</cfif>
					</cfloop>
				<cfset TheQueryStr = TheQueryStr &"FROM #GetTBName.DBName# 
				WHERE #GetDateName.DBName# < #Date2# 
				AND #GetDateName.DBName# > #Date1#
				AND #GetUserName.DBName# = '#LoginNameInfo.UserName#' ">
				<!--- Insert into GrpLists --->
				<cfinclude template="sessreport.cfm">
				<cfabort>
		<cfelse>
			<cfquery name="AuthInfo" datasource="#pds#">
				SELECT * 
				FROM CustomAuth 
				WHERE CAuthID = #CAuthID#
			</cfquery>
			
			<cfsetting enablecfoutputonly="No">
			<html>
			<head>
			<cfoutput>	
				<cfif GetAuthDates.AuthType Is "1">
					<title>Incorrect Configuration For #AuthInfo.AuthDescription#</TITLE>
				<cfelse>
					<title>#AuthInfo.AuthDescription# is a text based database</title>
				</cfif>
			</cfoutput>
			<cfinclude template="coolsheet.cfm">
			</head>
			<cfoutput><body #colorset#></cfoutput>
			<cfinclude template="header.cfm">
			<center>
			<cfoutput>
			<table border="#tblwidth#">
				<tr>
					<cfif GetAuthDates.AuthType Is "1">
						<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Incorrect Configuration For #AuthInfo.AuthDescription#.</font></th>
					<cfelse>
						<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#AuthInfo.AuthDescription# is a text based database</font></th>
					</cfif>
				</tr>
				<cfif GetAuthDates.AuthType Is "1">	
					<tr>
						<td bgcolor="#tbclr#">Please enter the Table and field names.<br>
						This report needs the following information to work:</td>
					</tr>
					<tr>
						<td bgcolor="#tbclr#">Datasource<br>
							Session History Table Name<br>
							Calls Username<br>
							Date Time<br>
							Session Time</td>
					</tr>
					<tr>
						<td bgcolor="#tbclr#">The needed information can be entered on the <a href="customauthsetup.cfm">Authentication Setup</a> page.</td>
					</tr>
				<cfelse>
					<tr>
						<td bgcolor="#tbclr#">Session history is not supported from text data.</td>
					</tr>
				</cfif>
			</table>
			</cfoutput>
			</center>
			<cfinclude template="footer.cfm">
			</body>
			</html>
			<cfabort>
		</cfif>
	<cfelse>
		<!--- Insert into GrpLists --->
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
				NASIdentifier, 'Metered History - #DateFormat(Date1, '#DateMask1#')# to #DateFormat(Date2, '#DateMask1#')#', 25, #Now()# 
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
	</cfif>
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

<cfif IsDefined("accountid")>
	<cfquery name="GetAuthDates" datasource="#pds#">
		SELECT C.DBName, C.CAuthID, A.AuthDescription 
		FROM CustomAuthSetup C, CustomAuth A 
		WHERE C.CAuthID = A.CAuthID 
		AND C.BOBName = 'accntodbc' 
		AND C.DBName Is Not Null 
		AND A.CAuthID In 
			(SELECT CAuthID 
			 FROM Domains 
			 WHERE DomainID In
			 	(SELECT DomainID
				 FROM AccountsAuth 
				 WHERE AccountID = #AccountID#) 
			)
		ORDER BY A.AuthDescription 
	</cfquery>
	<cfset ReportDate = CreateDate(Year(Now()),Month(Now()),1)>
	<cfloop query="GetAuthDates">
		<cfquery name="GetTBName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'tbcalls' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetLGName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'callslogin' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetDateName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'calldatetime' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfif GetDateName.DBName Is "">
			<cfquery name="GetDateName" datasource="#pds#">
				SELECT DBName 
				FROM CustomAuthSetup 
				WHERE BOBName = 'calldate' 
				AND CAuthID = #CAuthID#
			</cfquery>			
		</cfif>
		<cfquery name="AllUserNames" datasource="#pds#">
			SELECT UserName 
			FROM AccountsAuth 
			WHERE AccountID = #AccountID# 
			AND DomainID In 
				(SELECT DomainID 
				 FROM Domains 
				 WHERE CAuthID = #CAuthID#) 
		</cfquery>
		<cfif (GetDateName.DBName is not "") AND (GetTBName.DBName is not "")
		 AND (GetLGName.DBName is not "") AND (AllUserNames.Recordcount GT 0)>
			<cfquery name="GetDates" datasource="#DBName#">
				SELECT Min(#GetDateName.DBName#) as MinDate 
				FROM #GetTBName.DBName# 
				WHERE #GetLGName.DBName# In (#QuotedValueList(AllUserNames.UserName)#)
			</cfquery>
			<cfif IsDate(GetDates.MinDate)>
				<cfset TheCheckDate = GetDates.MinDate>
			<cfelse>
				<cfset TheCheckDate = Now()>
			</cfif>
			<cfset CompareTheDate = DateCompare(ReportDate,TheCheckDate)>
			<cfif CompareTheDate Is 1>
				<cfset ReportDate = TheCheckDate>
			</cfif>
		<cfelse>
			<cfsetting enablecfoutputonly="No">
			<html>
			<head>
			<title>The Authentication setup is not configured correctly.</TITLE>
			<cfinclude template="coolsheet.cfm">
			</head>
			<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
			<cfinclude template="header.cfm">
			<center>
			<cfoutput>
			<table border="#tblwidth#">
				<tr>
					<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Authentication setup is not configured correctly.</font></th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Please enter the information for #AuthDescription#.<br>
						The needed information can be entered on the <a href="customauthsetup.cfm">Authentication Setup</a> page.<br>
						This Report needs the following:<br>
						Accounting DataSource<br>
						Session History Table Name<br>
						Calls Username<br>
						Date Time OR Date
					</td>
				</tr>
			</table>
			</cfoutput>
			</center>
			<cfinclude template="footer.cfm">
			</body>
			</html>
			<cfabort>
		</cfif>
	</cfloop>
	<cfquery name="GetSpanDates" datasource="#pds#">
		SELECT Min(LastBillDate) MinDate 
		FROM TimeStore 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif GetSpanDates.MinDate Is "">
		<cfset TheCheckDate = Now()>
	<cfelse>
		<cfset TheCheckDate = GetSpanDates.MinDate>
	</cfif>
	<cfset CompareTheDate = DateCompare(ReportDate,TheCheckDate)>
	<cfif CompareTheDate Is 1>
		<cfset ReportDate = TheCheckDate>
	</cfif>
	<cfset mm2 = Month(ReportDate)>
	<cfset yy2 = Year(ReportDate)>
	<cfset dd2 = Day(ReportDate)>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT Login 
		FROM TimeStore 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="AllUserNames" datasource="#pds#">
		SELECT UserName, AuthID 
		FROM AccountsAuth 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfparam name="timespan" default="0">

	<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Select Report Dates</TITLE>
	<cfinclude template="coolsheet.cfm">
	<cfinclude template="jsdates.cfm">
	</head>
	<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
	<cfinclude template="header.cfm">
	<table>
		<form method="post" action="custinf1.cfm">
			<cfoutput>
				<input type="hidden" name="accountid" value="#accountid#">
			</cfoutput>
			<tr>
				<td>
					<INPUT border="0" type="image" name="return" src="images/returncust.gif">
				</td>
			</tr>
		</form>
	</table>
	<center>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select Report Criteria</font></th>
			</tr>
			<form method=post name="getdate" action="sesselect.cfm?RequestTimeout=500" onsubmit="return checkdates()">
				<tr>
					<th bgcolor="#thclr#" colspan="2"><input type="Radio" name="thespan" value="1" checked>All Time <cfif CheckFirst.Recordcount GT 0> <input type="Radio" name="thespan" value="0" >Metered Time</cfif></th>
				</tr>
				<tr bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align=right>From:</td>
	</cfoutput>
					<td><Select name="FromMon" onChange="getdays()">
						<cfloop index="B5" From="1" To="12">
							<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
							<cfoutput><option value="#B5#" <cfif mmm is B5>Selected</cfif> >#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
						</cfloop>
					</select><SELECT name="FromDay">
						<cfloop index="B4" From="1" To="#NumDays#">
							<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
							<cfoutput><option <cfif B4 Is 1>selected</cfif> value="#B4#">#B4#</cfoutput>
						</cfloop>
					</select><SELECT name="FromYear" onChange="getdays()">
						<cfloop index="B3" From="#yy2#" To="#yyy#">
							<cfoutput><option <cfif yyy is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
						</cfloop>
					</select></td>
				</tr>
				<cfoutput>
				<tr bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align=right>To:</td>
				</cfoutput>
					<td><Select name="ToMon" onChange="getdays2()">
						<cfloop index="B5" From="1" To="12">
							<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
							<cfoutput><option <cfif mmm is B5>Selected</cfif> value="#B5#" >#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
						</cfloop>
					</select><SELECT name="ToDay">
						<cfloop index="B4" From="1" To="#NumDays#">
							<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
							<cfoutput><option <cfif ddd is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
						</cfloop>
					</select><SELECT name="ToYear" onChange="getdays2()">
						<cfloop index="B3" From="#yy2#" To="#yyy#">
							<cfoutput><option <cfif yyy is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
						</cfloop>
					</select></td>
				</tr>
				<cfif AllUserNames.Recordcount GT 1>
					<cfset HowHigh = AllUserNames.Recordcount>
					<cfif HowHigh GT 4>
						<cfset HowHigh = 4>
					</cfif>
					<cfoutput>
					<tr bgcolor="#tdclr#" valign="top">
						<td bgcolor="#tbclr#" align=right>Login:</td>
					</cfoutput>
						<td><select name="AuthID" size="#HowHigh#">
							<cfoutput query="AllUserNames">
								<option value="#AuthID#">#UserName#
							</cfoutput>
						</select></td>
					</tr>
				<cfelse>
					<cfoutput><input type="Hidden" name="AuthID" value="#AllUserNames.AuthID#"></cfoutput>
				</cfif>
				<cfoutput><INPUT type="hidden" name="accountid" value="#accountid#"> </cfoutput>
				<tr>
					<th colspan=2><input type="image" name="report" src="images/lookup.gif" border="0"></th>
				</tr>
			</form>
		</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cflocation addtoken="No" url="admin.cfm">
</cfif>
 