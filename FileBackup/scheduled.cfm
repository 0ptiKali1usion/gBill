<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Select date range for the scheduled events to view. --->
<!--- 4.0.0 08/29/99 --->
<!-- scheduled.cfm -->

<cfinclude template="security.cfm">

<cfquery name="Events" datasource="#pds#">
	SELECT * 
	FROM AutoRun 
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(WhenRun) as MinDate, 
	Max(WhenRun) As MaxDate 
	FROM AutoRun 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDates = LowDate.MinDate>
<cfelse>
	<cfset StartDates = Now()>
</cfif>
<cfif LowDate.MaxDate Is Not "">
	<cfset EndDates = LowDate.MaxDate>
<cfelse>
	<cfset EndDates = Now()>
</cfif>
<cfset mm2 = Month(StartDates)>
<cfset yy2 = Year(StartDates)>
<cfset dd2 = Day(StartDates)>
<cfset mm4 = Month(EndDates)>
<cfset yy4 = Year(EndDates)>
<cfset dd4 = Day(EndDates)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Scheduled Events</TITLE>
<cfinclude template="coolsheet.cfm">
<cfinclude template="jsdates.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfif Events.Recordcount Is 0>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Scheduled Events</font></th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">There are currently no scheduled events.</td>
		</tr>
	</table>
	</cfoutput>
<cfelse>
	<cfoutput>
	<form name="getdate" method=post action="scheduled2.cfm" onsubmit="return checkdates()">
	<table border="#tblwidth#">
		<tr>
			<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Scheduled Events</font></th>
		</tr>
		<tr>
			<td bgcolor="#tdclr#" align=center colspan=2>Select Date Range for scheduled events.</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>From:</td>
	</cfoutput>
			<td><Select name="FromMon" onChange="getdays()">
				<cfloop index="B5" From="01" To="12">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B5" From="01" To="#NumDays#">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option <cfif B5 Is 1>selected</cfif> value="#B5#">#b5#</cfoutput>
				</cfloop>
			</select><SELECT name="FromYear" onChange="getdays()">
				<cfloop index="B4" from="#yy2#" to="#yy4#">
					<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
	<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>To:</td>
	</cfoutput>
			<td><Select name="ToMon" onChange="getdays2()">
				<cfloop index="B5" From="01" To="12">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="ToDay">
				<cfloop index="B5" From="01" To="#NumDays#">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option <cfif ddd is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B4" from="#yy2#" to="#yy4#">
					<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<tr>
			<th colspan=2><input type="image" name="report" src="images/lookup.gif" border="0"></td>
			<input type="hidden" name="report" value="1">
		</tr>
	</form>
	</table>
</cfif>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
    