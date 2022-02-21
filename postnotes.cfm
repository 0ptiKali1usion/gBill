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
	<cfset Date="#FromMon#/#FromDay#/#FromYear#">
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO Support 
		(Tech, Problem, Solution, AccountID, SupportDate, ActiveYN, NoteType, NotePriority, NoteStatus, <cfif Status Is 1>DateFinished<cfelseif Status Is 2>DatePending</cfif>)
		VALUES 
		('#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
		 '#Trim(Problem)#', '#Trim(Solution)#', #AccountID#, #Now()#, 1, '#Type#', '#Priority#', '#Status#', '#Date#')
	</cfquery>
</cfif>
	<cfquery name="GetHist" datasource="#pds#">
		SELECT * 
		FROM Support 
		<cfif IsDefined("SupportID")>
			WHERE SupportID = #SupportID# 
		<cfelse>
			WHERE SupportID = 0 
		</cfif>
		ORDER BY Supportdate desc 
	</cfquery>
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
	<tr bgcolor="#tbclr#">
	<td colspan="2" align="center">
<table border="0">
		<tr valign="top">
		<td align="center" bgcolor="#tbclr#" colspan="2">Priority:</td>
		<td align="center" bgcolor="#tbclr#" colspan="2">Status:</td>
		<td align="left" bgcolor="#tbclr#" colspan="2">Type:</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tdclr#" colspan="2"><input type="radio" <cfif Not IsDefined("SupportID")>checked<cfelse><cfif GetHist.NotePriority Is 1>checked</cfif></cfif> name="Priority" value="1">Standard</td>
			<td bgcolor="#tdclr#" colspan="2"><input type="radio" <cfif Not IsDefined("SupportID")>checked<cfelse><cfif GetHist.NoteStatus Is 1>checked</cfif></cfif> name="Status" value="1">Completed</td>
			<td bgcolor="#tdclr#" colspan="2"><input type="radio" <cfif Not IsDefined("SupportID")>checked<cfelse><cfif GetHist.NoteType Is 1>checked</cfif></cfif> name="Type" value="1">Tech: General</td>
		</tr>
		<tr valign="top">
			<td colspan="2"><input type="radio" <cfif GetHist.NotePriority Is 2>checked</cfif> name="Priority" value="2">Low</td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteStatus Is 2>checked</cfif> name="Status" value="2">Pending</td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 2>checked</cfif> name="Type" value="2">Tech: Lead</td>
		</tr>
		<tr valign="top">
			<td colspan="2"><input type="radio" <cfif GetHist.NotePriority Is 3>checked</cfif> name="Priority" value="3">High</td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteStatus Is 3>checked</cfif> name="Status" value="3">Escalated</td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 3>checked</cfif> name="Type" value="3">Tech: DSL</td>
		</tr>
		<tr valign="top">
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 4>checked</cfif> name="Type" value="4">Sales: General</td>
		</tr>
		<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 5>checked</cfif> name ="Type" value="5">Sales: Admin</td>
		</tr>
		<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 6>checked</cfif> name ="Type" value="6">Sales: DSL</td>
		</tr>
		<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 7>checked</cfif> name ="Type" value="7">Sales: Development</td>
		</tr>
				<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 8>checked</cfif> name ="Type" value="8">Operations</td>
		</tr>
		<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 9>checked</cfif> name ="Type" value="9">Billing</td>
		</tr>
		<tr>
			<td colspan="4"></td>
			<td colspan="2"><input type="radio" <cfif GetHist.NoteType Is 10>checked</cfif> name ="Type" value="10">QC</td>
		</tr>
	</table>
	<table border="0">
	<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Date:</td>
			<cfinclude template="jsdates.cfm">
			<cfset yy2 = "2000">
			<cfif GetHist.NoteStatus Is 1>
			<th>
				#LSDateFormat('#GetHist.DateFinished#', 'mmm-dd-yyyy')#
			</th>
			<td>
				Change Date?
				<input type="checkbox" name="updatedate" value="1">
				
			</td>
			<cfelseif GetHist.NoteStatus Is 2>
			<th>
				#LSDateFormat('#GetHist.DatePending#', 'mmm-dd-yyyy')#
			</th>
			<td>
				
				Change Date?
				<input type="checkbox" name="updatedate" value="1">
				
			</td>
			</cfif>
			<td>
			<Select name="FromMon">
				<cfloop index="B5" from="1" to="12">
					<cfif B5 lt 10><cfset B5 = "0#B5#"></cfif>
						<option <cfif B5 is mmm>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#
				</cfloop>
			</select>
			<SELECT name="FromDay">
				<cfloop index="B4" from="1" to="#NumDays#">
					<cfif B4 lt 10><cfset B4 = "0#B4#"></cfif>
						<option <cfif B4 is ddd>selected</cfif> value="#B4#">#B4#
				</cfloop>
			</select>
			<SELECT name="FromYear">
				<cfloop index="B3" from="#yy2#" to="#yyy#">
						<option <cfif B3 is yyy>selected</cfif> value="#B3#">#B3#
				</cfloop>
			</select>
			</td>
		</tr>
		<tr>
			<td>
			
			</td>
		</tr>
		</table>
		</tr>
		</td>
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
	S.SupportID, S.SupportDate, S.Problem, S.Solution, S.NoteType, S.NoteStatus 
	FROM Accounts A, Support S
	WHERE A.AccountID = S.AccountID 
	<!---AND S.ActiveYN = 1---> 
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
			<th>Note Type/Status</th>
			<th>Finished</th>
		</tr>	
	</cfoutput>
	<cfoutput query="GetNotes" startrow="#Srow#" maxrows="#Maxrows#">
		<form method="post" action="postnotes.cfm">
			<tr valign="top">
				<th rowspan="2" bgcolor="#tdclr#"><input type="radio" name="EditID" value="#SupportID#" onclick="submit()"></th>
				<td bgcolor="#tbclr#"><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
				<td bgcolor="#tbclr#">#Problem#</td>
				<td bgcolor="#tbclr#"><cfif NoteType Is 1>Tech: General<cfelseif NoteType Is 2>Tech: Lead
									  <cfelseif NoteType Is 3>Tech: DSL<cfelseif NoteType Is 4>Sales: General
									  <cfelseif NoteType Is 5>Sales: Admin<cfelseif NoteType Is 6>Sales: DSL
									  <cfelseif NoteType Is 7>Sales: Development<cfelseif NoteType Is 8>Operations
									  <cfelseif NoteType Is 9>Billing<cfelseif NoteType Is 10>QC</cfif></td>
				<th rowspan="2" bgcolor="#tdclr#"><input type="checkbox" name="SupportID" value="#SupportID#" onclick="submit()"></th>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#">#LSDateFormat(SupportDate, '#DateMask1#')#&nbsp;</td>
				<td bgcolor="#tbclr#">#Solution#</td>
				<td bgcolor="#tbclr#"><cfif NoteStatus Is 1>Completed<cfelseif NoteStatus Is 2>Pending<cfelseif NoteStatus Is 3>Escalated</cfif></td>
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
 