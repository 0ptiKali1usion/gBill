<cfinclude template="security.cfm">
<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is a report of session totals for each user during a selected date range. --->
<!--- sestot.cfm --->

<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 27 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfquery name="CheckReportFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 27 
</cfquery>
<cfsetting enablecfoutputonly="No">
<cfif CheckReportFirst.Recordcount GT 0>
	<html>
	<head>
	<title>Session Totals</TITLE>
	<cfinclude template="coolsheet.cfm">
	<cfinclude template="jsdates.cfm">
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
				<input type="hidden" name="SendReportID" value="27">
				<input type="hidden" name="SendLetterID" value="0">
				<input type="hidden" name="ReturnPage" value="sestot.cfm">
				<input type="hidden" name="SendHeader" value="Name,Login,Phone,E-Mail,Session Total">
				<input type="hidden" name="SendFields" value="Name,Login,Phone,EMail,SessTime">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="sestot.cfm">
				<th colspan="2" width="50%"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
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

<cfif IsDefined("report") is "No">
	<cfquery name="GetAuthDates" datasource="#pds#">
		SELECT C.DBName, C.CAuthID, A.AuthDescription 
		FROM CustomAuthSetup C, CustomAuth A 
		WHERE C.CAuthID = A.CAuthID 
		AND C.BOBName = 'accntodbc' 
		AND C.DBName Is Not Null 
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
		<cfif GetTBName.DBName Is Not "">
			<cfquery name="GetDates" datasource="#DBName#">
				SELECT Min(#GetDateName.DBName#) as MinDate 
				FROM #GetTBName.DBName# 
			</cfquery>
			<cfif DateCompare(ReportDate,GetDates.MinDate)>
				<cfset ReportDate = GetDates.MinDate>
			</cfif>
		</cfif>
	</cfloop>
	<cfset mm2 = Month(ReportDate)>
	<cfset yy2 = Year(ReportDate)>
	<cfset dd2 = Day(ReportDate)>
<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Session Totals</TITLE>
	<cfinclude template="coolsheet.cfm">
	<cfinclude template="jsdates.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Session Totals</font></th>
		</tr>	
		<form name="getdate" method=post action="sestot.cfm?RequestTimeout=500" onsubmit="return checkdates()">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align=right>Datasource:</td>
	</cfoutput>
				<td><select name="Datasource">
					<cfoutput query="GetAuthDates">
						<option value="#CAuthID#">#AuthDescription#
					</cfoutput>
				</select></td>
	<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align=right>From:</td>
	</cfoutput>
				<td><Select name="FromMon" onChange="getdays()">
					<cfloop index="B5" from="1" to="12">
						<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
						<cfoutput><option <cfif B5 is mmm>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
					</cfloop>
				</select><SELECT name="FromDay">
					<cfloop index="B4" from="1" to="#NumDays#">
						<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
						<cfoutput><option <cfif B4 Is 1>selected</cfif> value="#B4#">#B4#</cfoutput>
					</cfloop>
				</select><SELECT name="FromYear" onChange="getdays()">
					<cfloop index="B3" from="#yy2#" to="#yyy#">
						<cfoutput><option <cfif B3 is yyy>selected</cfif> value="#B3#">#B3#</cfoutput>
					</cfloop>
				</select></td>
			</tr>
			<cfoutput>
				<tr bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align=right>To:</td>
			</cfoutput>
					<td><Select name="ToMon" onChange="getdays2()">
						<cfloop index="B5" from="1" to="12">
							<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
							<cfoutput><option <cfif B5 is mmm>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
						</cfloop>
					</select><SELECT name="ToDay">
						<cfloop index="B4" from="1" to="#NumDays#">
							<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
							<cfoutput><option <cfif B4 is ddd>selected</cfif> value="#B4#">#B4#</cfoutput>
						</cfloop>
					</select><SELECT name="ToYear" onChange="getdays2()">
						<cfloop index="B3" from="#yy2#" to="#yyy#">
							<cfoutput><option <cfif B3 is yyy>selected</cfif> value="#B3#">#B3#</cfoutput>
						</cfloop>
					</select></td>
				</tr>
				<cfoutput>
					<tr bgcolor="#tdclr#">
						<td bgcolor="#tbclr#" align=right>Time:</td>
				</cfoutput>
					<td><input type="Text" name="MinTime" value="0" size="5">Minimum Hours</td>				
				</tr>
				<cfoutput>
					<tr bgcolor="#tdclr#" valign="top">
						<td bgcolor="#tbclr#" align=right>Time:</td>
				</cfoutput>
					<td><input type="Text" name="MaxTime" value="0" size="5">Maximum Hours<br><font size="1">Enter 0 for no limit</font></td>				
				</tr>
				<tr>
					<th colspan=2><input type="hidden" name="report" value="1"><input type="image" name="report" src="images/lookup.gif" border="0"></th>
				</tr>
		</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>

<cfelse>
	<cfset SendCAuthID = Datasource>
	<cfinclude template="cfauthvalues.cfm">
	<cfif (tbcalls is not "") AND (callslogin is not "")
    AND (acntsestime is not "")
	 AND ( (calldatetime is not "") OR (calldate is not "") )>

		<cfparam name="obid" default="username">
		<cfparam name="obdir" default="asc">
		<cfparam name="page" default="1">
		<cfset Date1 = CreateDateTime(fromyear,frommon,fromday,0,0,0)>
		<cfset Date2 = CreateDateTime(toyear,tomon,today,23,59,59)>
		<cfif IsNumeric(MinTime)>
			<cfset MinTimeHrs = MinTime * 3600>
		<cfelse>
			<cfset MinTimeHrs = 0>
		</cfif>
		<cfif IsNumeric(MaxTime)>
			<cfset MaxTimeHrs = MaxTime * 3600>
		<cfelse>
			<cfset MaxTimeHrs = 0>
		</cfif>
		<cfquery name="totaltime" datasource="#accntodbc#">
			SELECT #callslogin# as Username1, Sum(#acntsestime#) AS MINSTot
			FROM #tbcalls# 
			WHERE <cfif calldatetime is not "">#calldatetime#<cfelse>#calldate#</cfif> 
			<= #CreateODBCDateTime(Date2)# 
			AND <cfif calldatetime is not "">#calldatetime#<cfelse>#calldate#</cfif> 
			>= #CreateODBCDateTime(Date1)# 
			AND #acntsestime# > 0 
			GROUP BY #callslogin#
			HAVING Sum(#acntsestime#) >= #MinTimeHrs# 
			<cfif MaxTimeHrs GT 0>
				AND Sum(#acntsestime#) <= #MaxTimeHrs# 
			</cfif>
			ORDER BY 
			<cfif obid is "username">
				#callslogin#
			<cfelse>
				Sum(#acntsestime#)
			</cfif>
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT GrpListID 
			FROM GrpLists 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 27 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfloop query="TotalTime">
				<cfquery name="" datasource="#pds#">
					INSERT INTO GrpLists 
					(Login, CurTime, ReportID, AdminID, ReportTitle, CreateDate) 
					VALUES 
					('#Username1#', #MINSTot#, 27, #MyAdminID#, 'Session Totals for #DateFormat(Date1, '#DateMask1#')# to #DateFormat(Date2, '#DateMask1#')#', #Now()#)
				</cfquery>
			</cfloop>
			<cfquery name="GetPrivInfo" datasource="#pds#">
				UPDATE GrpLists SET 
				FirstName = A.FirstName, 
				LastName = A.LastName, 
				Phone = A.DayPhone, 
				AccountID = A.AccountID 
				FROM Accounts A, GrpLists G 
				WHERE G.Login = A.Login 
				AND G.ReportID = 27 
				AND G.AdminID = #MyAdminID# 
			</cfquery>			
			<cfquery name="GetEMails" datasource="#pds#">
				UPDATE GrpLists SET 
				EMail = E.Email 
				FROM AccountsEMail E, GrpLists G 
				WHERE G.AccountID = E.AccountID 
				AND E.PrEMail = 1 
				AND G.ReportID = 27 
				AND G.AdminID = #MyAdminID# 
			</cfquery>
		</cfif>
		<cfset SendReportID = 27>
		<cfset SendLetterID = 0>
		<cfquery name="ClearEmailTable" datasource="#pds#">
			DELETE FROM EMailOutGoing 
			WHERE LetterID = 27 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfset ReturnPage = "sestot.cfm">
		<cfset SendHeader = "Name,Login,Phone,E-Mail,Session Total">
		<cfset SendFields = "Name,Login,Phone,EMail,SessTime">
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="grplist.cfm">
		<cfabort>
	<cfelse>
	
		<cfquery name="AuthInfo" datasource="#pds#">
			SELECT * 
			FROM CustomAuth 
			WHERE CAuthID = #DataSource#
		</cfquery>
		
		<cfsetting enablecfoutputonly="No">
		<html>
		<head>
		<cfoutput>		
			<title>Incorrect Configuration For #AuthInfo.AuthDescription#</TITLE>
		</cfoutput>
		<cfinclude template="coolsheet.cfm">
		</head>
		<cfoutput><body #colorset#></cfoutput>
		<cfinclude template="header.cfm">
		<center>
		<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Incorrect Configuration For #AuthInfo.AuthDescription#.</font></th>
			</tr>	
			<tr>
				<td bgcolor="#tbclr#">Please enter the Table and field names.<br>
			This report needs the following information to work:</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">Session History Table Name<br>
					Calls Username<br>
					Date Time<br>
					Session Time</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">The needed information can be entered on the <a href="customauthsetup.cfm">Authentication Setup</a> page.<br>
				OR Select a different <a href="sestot.cfm">datasource</a>.</td>
			</tr>
		</table>
		</cfoutput>
		</center>
		<cfinclude template="footer.cfm">
		</body>
		</html>
	</cfif>
</cfif>
 