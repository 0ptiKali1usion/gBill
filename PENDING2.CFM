<cfsetting enablecfoutputonly="yes">
<cfset LogicConnect = 0>
<!--- <cfquery name="DoSearch" datasource="#pds#">
SELECT *
FROM Support
WHERE NoteStatus = 2
AND DatePending < {ts'#ToYear#/#ToMon#/#ToDay# 23:59:59'}
AND DatePending > {ts'#FromYear#/#FromMon#/#FromDay# 00:00:00'}
</cfquery> --->
<cfquery name="SearchResults" datasource="#pds#">
SELECT *
FROM Support
WHERE NoteStatus = 2
</cfquery>
<cfparam name="Tab" default="1">
<!--- <cfset ReturnID = AccountID> --->
<cfif Tab Is 1>
	<cfset HowWide = 2>
<cfelseif Tab Is 2>
	<cfset HowWide = 1>
</cfif>
<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Search Results</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<cfinclude template="jsdates.cfm">
<cfset yy2 ="2000">
<form method=post action="pending.cfm">
<Select name="FromMon" onChange="getdays()">
	<cfloop index="B5" from="1" to="12">
		<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
		<option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#
	</cfloop>
</select>
<SELECT name="FromDay">
	<cfloop index="B4" from="1" to="#Numdays#">
		<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
		<option value="#B4#">#B4#
	</cfloop>
</select>
<SELECT name="FromYear" onChange="getdays()">
	<cfloop index="B3" from="#yy2#" to="#yyy#">
		<option <cfif yyy is B3>Selected</cfif> value="#B3#">#B3#
	</cfloop>
</select>
<Select name="ToMon" onChange="getdays2()">
	<cfloop index="B5" from="1" to="12">
		<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
		<option <cfif mmm is B5>Selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#
	</cfloop>
</select>
<SELECT name="ToDay">
	<cfloop index="B4" from="1" to="#Numdays#">
		<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
		<option <cfif ddd is B4>Selected</cfif> value="#B4#">#B4#
	</cfloop>
</select>
<SELECT name="ToYear" onChange="getdays2()">
	<cfloop index="B3" from="#yy2#" to="#yyy#">
		<option <cfif yyy is "#B3#">Selected</cfif> value="#B3#">#B3#
	</cfloop>
</select>
<input type="image" src="images/return.gif" border="0">
</form>
<form method=post action="support.cfm">
<input type="image" src="images/return.gif" border="0">
<!--- <input type="hidden" name="AccountID" value="#AccountID#"> --->
</form>
<CENTER>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
	</tr>
</cfoutput>
<cfoutput query="SearchResults">
<cfquery name="GetName" datasource="#pds#">
SELECT Login
FROM Accounts
WHERE AccountID = '#AccountID#'
</cfquery>
<cfif FromMon greater than 0>
<cfquery name="DoSearch" datasource="#pds#">
	SELECT *
	FROM Support
	WHERE NoteStatus = 2
	AND DatePending < {ts'#ToYear#/#ToMon#/#ToDay# 23:59:59'}
	AND DatePending > {ts'#FromYear#/#FromMon#/#FromDay# 00:00:00'}
</cfquery>
</cfif>
<tr valign=top>
	<td bgcolor="#tbclr#">#GetName.Login#</td>
	<td bgcolor="#tbclr#">#problem#</td>
<cfif Tab Is 1>
		<form method=post action="support.cfm">
			<input type="hidden" name="SupportID" value="#SupportID#">
			<input type="hidden" name="AccountID" value="#AccountID#">
			<input type="hidden" name="Tab" value="3">
			<td><input type="image" src="images/view.gif" border="0"></td>
		</form>
	</tr>	
<cfelse>
	</tr>
	<tr>
		<td bgcolor="#tbclr#"><font color=red>#solution#</font></td>
	</tr>
</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
 