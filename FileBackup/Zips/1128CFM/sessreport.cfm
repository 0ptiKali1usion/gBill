<cfsetting enablecfoutputonly="Yes">

<cfparam name="page" default="1">
<cfquery name="GetReportInfo" datasource="#pds#">
	SELECT * 
	FROM CustomAuthSetup 
	WHERE CAuthID = #CAuthID# 
	AND ForTable = 13
	AND ReportUse = 1 
	AND UseYN = 1 
	AND DBType = 'FD' 
	AND DBName Is Not Null 
	ORDER BY SortOrder
</cfquery>
<cfset TheFieldStr = ValueList(GetReportInfo.BOBName)>
<cfset Obiddef = ListGetAt( (ValueList(GetReportInfo.DBName)),1)>
<cfparam name="obid" default="#Obiddef#">
<cfparam name="obdir" default="asc">

<cfquery name="AllSessions" datasource="#AuthODBC#">
	#Replace(TheQueryStr, "''","'","All")# 
	ORDER BY #obid# #obdir#
</cfquery>
<cfif Page Is 0>
	<cfset srow = 1>
	<cfset maxrows = AllSessions.Recordcount>
<cfelse>
	<cfset srow = (Page * Mrow) - (Mrow - 1)>
	<cfset maxrows = mrow>
</cfif>
<cfset PageNumber = Ceiling(AllSessions.Recordcount/mrow)>
<cfloop query="GetReportInfo">
	<cfset "Total#BOBName#" = 0>
</cfloop>
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
<title>Session Report</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="sesselect.cfm">
	<input type="Image" src="images/return.gif" border="0">
	<cfoutput><input type="Hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#GetReportInfo.Recordcount#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Session Report for #LSDateFormat(Date1, '#DateMask1#')# to #LSDateFormat(Date2, '#DateMask1#')#</font></th>
	</tr>
</cfoutput>
	<cfif AllSessions.Recordcount GT mrow>
		<tr>
			<form method="post" action="sessreport.cfm">			
				<cfoutput>
				<td colspan="#GetReportInfo.Recordcount#"></cfoutput><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllSessions.Recordcount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="Hidden" name="TheQueryStr" value="#TheQueryStr#">
					<input type="Hidden" name="obid" value="#obid#">
					<input type="Hidden" name="obdir" value="#obdir#">
					<input type="Hidden" name="AuthODBC" value="#AuthODBC#">
					<input type="Hidden" name="AccountID" value="#AccountID#">
					<input type="Hidden" name="Date1" value="#Date1#">
					<input type="Hidden" name="Date2" value="#Date2#">
					<input type="Hidden" name="CAuthID" value="#CAuthID#">
					<input type="Hidden" name="ForTable" value="#ForTable#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
	<cfoutput><tr bgcolor="#thclr#" valign="top"></cfoutput>
		<cfloop query="GetReportInfo">
			<form method="post" action="sessreport.cfm">
				<cfoutput><th><input type="Radio" <cfif obid Is DBName>checked</cfif> name="obid" value="#DBName#" onclick="submit()" id="tab#CurrentRow#"><label for="tab#CurrentRow#">#Descrip1#</label></th></cfoutput>
				<cfif (obid Is DBName) AND (obdir Is "asc")>
					<input type="Hidden" name="obdir" value="desc">
				<cfelse>
					<input type="Hidden" name="obdir" value="asc">
				</cfif>
				<cfoutput>
					<input type="Hidden" name="TheQueryStr" value="#TheQueryStr#">
					<input type="Hidden" name="AuthODBC" value="#AuthODBC#">
					<input type="Hidden" name="AccountID" value="#AccountID#">
					<input type="Hidden" name="Date1" value="#Date1#">
					<input type="Hidden" name="Date2" value="#Date2#">
					<input type="Hidden" name="CAuthID" value="#CAuthID#">
					<input type="Hidden" name="ForTable" value="#ForTable#">
				</cfoutput>
			</form>
		</cfloop>
	</tr>
	<cfoutput>
		<tr>
			<td bgcolor="#tbclr#" colspan="#GetReportInfo.Recordcount#">Total sessions: #AllSessions.RecordCount#</td>
		</tr>
	</cfoutput>
	<cfset SessTimeTotal = 0>
	<cfset ArrayPoint = srow>
	<cfoutput query="AllSessions" startrow="#srow#" maxrows="#maxrows#">
		<tr bgcolor="#tbclr#" valign="top">
			<cfloop query="GetReportInfo">
				<cfset DispStr = Evaluate("AllSessions.#BOBName#[ArrayPoint]")>
					<cfif DataType Is "Date">
						<cfif BOBName Is "calldatetime">
							<td nowrap>#LSDateFormat(DispStr, '#DateMask1#')# #TimeFormat(DispStr, 'hh:mm:ss tt')#</td>
						<cfelseif BOBName Is "calldate">
							<td nowrap>#LSDateFormat(DispStr, '#DateMask1#')#</td>
						<cfelseif BOBName Is "calltime">
							<td>#TimeFormat(DispStr, 'hh:mm:ss tt')#</td>
						</cfif>
					<cfelse>
						<cfif ReportTotal Is 1>
							<cfset TotalTime = DispStr>
							<cfset CarryTotal = Evaluate("Total#BOBName#")>
							<cfset "Total#BOBName#" = CarryTotal + DispStr>
							<cfset SessTimeTotal = SessTimeTotal + TotalTime>
							<cfset Hours = Int(TotalTime/3600)>
								<cfset HourSecs = Hours * 3600>
								<cfset CurTime2 = TotalTime - HourSecs>
							<cfset Minutes = Int(CurTime2/60)>
								<cfset MinSecs = Minutes * 60>
								<cfset CurTime3 = TotalTime - HourSecs - MinSecs>
							<cfset Seconds = CurTime3>
							<td align="right">#Hours#:<cfif Minutes LT 10>0</cfif>#Minutes#:<cfif seconds LT 10>0</cfif>#seconds#</td>
						<cfelseif ReportTotal Is 2>
							<cfset TotalAmount = DispStr>
							<cfset CarryATotal = Evaluate("Total#BOBName#")>
							<cfset "Total#BOBName#" = CarryATotal + DispStr>
							<cfset SessTimeTotal = SessTimeTotal + TotalTime>
							<td align="right">#DispStr#</td>
						<cfelse>
							<td>#DispStr#<cfif DispStr Is "">&nbsp;</cfif></td>
						</cfif>
					</cfif>
			</cfloop>
		</tr>
		<cfset ArrayPoint = ArrayPoint + 1>
	</cfoutput>
	<cfset ShowTotals = ListFind((ValueList(GetReportInfo.ReportTotal)),1)>
	<cfif ShowTotals GT 0>
		<cfoutput>
		<tr bgcolor="#thclr#">
		</cfoutput>
			<cfloop query="GetReportInfo">
				<cfif ReportTotal Is 1>
					<cfset DispTotal = Evaluate("Total#BOBName#")>
					<cfif BOBName Is "acntsestime">
						<cfset TotalTime = DispTotal>
						<cfset Hours = Int(TotalTime/3600)>
							<cfset HourSecs = Hours * 3600>
							<cfset CurTime2 = TotalTime - HourSecs>
						<cfset Minutes = Int(CurTime2/60)>
							<cfset MinSecs = Minutes * 60>
							<cfset CurTime3 = TotalTime - HourSecs - MinSecs>
						<cfset Seconds = CurTime3>
						<cfoutput><td align="right">#Hours#:<cfif Minutes LT 10>0</cfif>#Minutes#:<cfif seconds LT 10>0</cfif>#seconds#</td></cfoutput>
					<cfelse>
						<cfoutput><td align="right">#DispTotal#</td></cfoutput>
					</cfif>
				<cfelseif ReportTotal Is 2>
					<cfset DispTotal = Evaluate("Total#BOBName#")>
					<cfoutput><td align="right">#DispTotal#</td></cfoutput>
				<cfelse>
					<td>&nbsp;</td>
				</cfif>
			</cfloop>
		</tr>
	</cfif>
	<cfif AllSessions.Recordcount GT mrow>
		<tr>
			<form method="post" action="sessreport.cfm">			
				<cfoutput>
				<td colspan="#GetReportInfo.Recordcount#"></cfoutput><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllSessions.Recordcount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="Hidden" name="TheQueryStr" value="#TheQueryStr#">
					<input type="Hidden" name="obid" value="#obid#">
					<input type="Hidden" name="obdir" value="#obdir#">
					<input type="Hidden" name="AuthODBC" value="#AuthODBC#">
					<input type="Hidden" name="AccountID" value="#AccountID#">
					<input type="Hidden" name="Date1" value="#Date1#">
					<input type="Hidden" name="Date2" value="#Date2#">
					<input type="Hidden" name="CAuthID" value="#CAuthID#">
					<input type="Hidden" name="ForTable" value="#ForTable#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
