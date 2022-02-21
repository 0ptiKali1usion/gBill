<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of all the notes fields that need action. --->
<!---	4.0.0 08/31/99
		3.5.0 07/14/99
		3.2.2 09/21/98 Fixed error with SQL server.
		3.2.1 09/09/98 Added code to order the output.
		3.2.0 09/08/98 --->
<!--- postnotes.cfm --->
<cfsetting enablecfoutputonly="no">
<cfif IsDefined("AddNote.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO Support 
		(Tech, Problem, Solution, AccountID, SupportDate, ActiveYN)
		VALUES 
		('#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
		 '#Trim(Problem)#', '#Trim(Solution)#', #AccountID#, #Now()#, 1)
	</cfquery>
</cfif>
<cfif IsDefined("EditID")>
	<cfquery name="OneNote" datasource="#pds#">
		SELECT * 
		FROM Support 
		WHERE SupportID = #EditID# 
	</cfquery>
	<HTML>
	<HEAD>
	<title>Notes</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttfont Is Not "NA">face="#perfontname#"</cfif> color="#ttfont#">Follow Up Note</font></th>
		</tr>
		<form method="post" action="postnotes.cfm">
			<tr valign="top">
				<td rowspan="2" align="right" bgcolor="#tbclr#">Problem</td>
				<td bgcolor="#tbclr#">#OneNote.Problem#</td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tdclr#"><textarea wrap="virtual" name="Problem" rows="6" cols="50"></textarea></td>
			</tr>
			<tr valign="top">
				<td rowspan="2" align="right" bgcolor="#tbclr#">Solution</td>
				<td bgcolor="#tbclr#">#OneNote.Solution#</td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tdclr#"><textarea wrap="virtual" name="Solution" rows="6" cols="50"></textarea></td>
			</tr>
			<tr valign="top">
				<th colspan="2"><input type="image" name="AddNote" src="images/enter.gif" border="0"></th>
			</tr>
			<input type="hidden" name="AccountID" value="#OneNote.AccountID#">
			<input type="hidden" name="Page" value="#Page#">
		</form>
	</cfoutput>
	</table>
	
	</center>
	<cfinclude template="footer.cfm">
	</BODY>
	</HTML>
	<cfabort>
</cfif>
<cfsetting enablecfoutputonly="yes">
<cfif IsDefined("SupportID")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Support SET 
		ActiveYN = 0 
		WHERE SupportID = #SupportID# 
	</cfquery>
</cfif>
<cfparam name="Page" default="1">
<cfparam name="ordby" default="Name">
<cfparam name="orddir" default="asc">
<cfquery name="GetNotes" datasource="#pds#">
	SELECT A.AccountID, A.FirstName, A.LastName, 
	S.SupportID, S.SupportDate, S.Problem, S.Solution 
	FROM Accounts A, Support S
	WHERE A.AccountID = S.AccountID 
	AND S.ActiveYN = 1 
	ORDER BY A.LastName #orddir#, A.FirstName #orddir#, SupportDate Asc
</cfquery>
<cfif Page GT 0>
	<cfset MaxRows = mrow>
	<cfset Srow = (page * mrow) - (mrow - 1)>
<cfelse>
	<cfset Srow = 1>
	<cfset MaxRows = GetNotes.RecordCount>
</cfif>
<cfset PageNumber = Ceiling(GetNotes.RecordCount/mrow)>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<title>Notes</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttfont Is Not "NA">face="#perfontname#"</cfif> color="#ttfont#">Customer Notes</font></th>
	</tr>
</cfoutput>
	<cfif GetNotes.RecordCount GT mrow>
		<form method="post" action="postnotes.cfm">
			<tr>
				<td colspan="4"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5 * mrow) - (mrow - 1)>
						<cfset DispStr = GetNotes.LastName[arraypoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option <cfif Page Is 0>selected</cfif> value="0">View All
				</select></td>
			</tr>
		</form>
	</cfif>
<cfif GetNotes.Recordcount GT 0>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Follow Up</th>
			<th>Name/Date</th>
			<th>Notes</th>
			<th>Finished</th>
		</tr>	
	</cfoutput>
	<cfoutput query="GetNotes" startrow="#Srow#" maxrows="#Maxrows#">
		<form method="post" action="postnotes.cfm">
			<tr valign="top">
				<th rowspan="2" bgcolor="#tdclr#"><input type="radio" name="EditID" value="#SupportID#" onclick="submit()"></th>
				<td bgcolor="#tbclr#"><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
				<td bgcolor="#tbclr#">#Problem#</td>
				<th rowspan="2" bgcolor="#tdclr#"><input type="checkbox" name="SupportID" value="#SupportID#" onclick="submit()"></th>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#">#LSDateFormat(SupportDate, '#DateMask1#')#&nbsp;</td>
				<td bgcolor="#tbclr#">#Solution#</td>
			</tr>
			<input type="hidden" name="page" value="#Page#">
		</form>
	</cfoutput>
<cfelse>
	<tr>
		<cfoutput>
			<td bgcolor="#tbclr#" colspan="4">No active notes currently.</td>
		</cfoutput>
	</tr>
</cfif>
	<cfif GetNotes.RecordCount GT mrow>
		<form method="post" action="postnotes.cfm">
			<tr>
				<td colspan="4"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5 * mrow) - (mrow - 1)>
						<cfset DispStr = GetNotes.LastName[arraypoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option <cfif Page Is 0>selected</cfif> value="0">View All
				</select></td>
			</tr>
		</form>
	</cfif>
</table>

</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
 