<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a list of all pops. --->
<!--- 4.0.0 07/22/99 
		3.1.1 07/23/98 Aligned the buttons to be consistent with other pages 
		3.1.0 07/15/98 --->
<!--- pops.cfm --->
<cfinclude template="security.cfm">
<cfif IsDefined("CopyFrom")>
	<cfquery name="GetFrom" datasource="#pds#">
		SELECT * 
		FROM POPs 
		WHERE POPID = #CopyFrom# 
	</cfquery>
	<cfset FieldList = GetFrom.ColumnList>
	<cfset Pos1 = ListFindNoCase(FieldList,"POPID")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos1)>
	<cfset Pos2 = ListFindNoCase(FieldList,"POPName")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos2)>
	<cfset Pos3 = ListFindNoCase(FieldList,"DefPOP")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos3)>
	<cftransaction>
		<cfquery name="MakeNew" datasource="#pds#">
			INSERT INTO POPs 
			(POPName, DefPOP, #FieldList#) 
			SELECT '#GetFrom.POPName# Copy', 0, #FieldList# 
			FROM POPs 
			WHERE POPID = #CopyFrom# 
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(POPID) As MaxID 
			FROM POPs 
		</cfquery>
	</cftransaction>
	<cfset NewPOPID = NewID.MaxID>
	<cfquery name="InsPOPAdm" datasource="#pds#">
		INSERT INTO POPAdm 
		(POPID, AdminID) 
		SELECT #NewPOPID#, AdminID
		FROM POPAdm 
		WHERE POPID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO POPPlans 
		(POPID, PlanID) 
		SELECT #NewPOPID#, PlanID 
		FROM POPPlans 
		WHERE POPID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO POPsStates 
		(POPID, StateID) 
		SELECT #NewPOPID#, StateID
		FROM POPsStates 
		WHERE POPID = #CopyFrom# 
	</cfquery>
</cfif>
<cfif IsDefined("deletelist")>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 3 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif (IsDefined("ListPOPs.x")) AND (IsDefined("POPID"))>
	<cfif POPID Is Not "0">
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT ReportID 
			FROM GrpLists 
			WHERE ReportID = 3 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfif CheckFirst.RecordCount GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE ReportID = 3 
				AND AdminID = #MyAdminID# 
			</cfquery>
		</cfif>
		<cfquery name="List" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, Login, City, AccountID, ReportHeader, 
			 ReportID, AdminID, ReportTitle, CreateDate) 
			SELECT Distinct A.LastName, A.FirstName, A.Login, A.City, A.AccountID, 
			P.POPName, 3, #MyAdminID#, 'List of customers by POP', #Now()# 
			FROM Accounts A, AccntPlans AP, POPs P 
			WHERE A.AccountID = AP.AccountID 
			AND AP.POPID = P.POPID 
			AND P.POPID In (#POPID#) 
		</cfquery>
		<cfquery name="GetEMails" datasource="#pds#">
			UPDATE GrpLists SET 
			EMail = E.Email 
			FROM AccountsEMail E, GrpLists G 
			WHERE G.AccountID = E.AccountID 
			AND E.PrEMail = 1 
			AND G.ReportID = 3  
			AND G.AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfset SendReportID = 3>
	<cfset SendLetterID = 3>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 3 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendHeader = "Name,Login,City,POP,E-Mail">
	<cfset SendFields = "Name,Login,City,ReportHeader,EMail">
	<cfset ReturnPage = "POPs.cfm">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfif (IsDefined("DeleteIt.x")) AND (IsDefined("Delem"))>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM POPAdm 
		WHERE POPID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM POPsStates 
		WHERE POPID In (#delem#)
	</cfquery>
	<cfquery name="CleanUP" datasource="#pds#">
		DELETE FROM FilterPOPs 
		WHERE POPID In (#delem#) 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPOPs" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID In (#delem#) 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted these POPs.  #ValueList(GetPOPs.POPName)#.')
		</cfquery>
	</cfif>
	<cfquery name="CleanUP" datasource="#pds#">
		DELETE FROM POPs 
		WHERE POPID In (#delem#)
	</cfquery>
</cfif>
<cfif IsDefined("defpop")>
	<cfquery name="upditall" datasource="#pds#">
		UPDATE POPs SET 
		DefPOP = 0
	</cfquery>
	<cfquery name="updit1" datasource="#pds#">
		UPDATE POPs SET 
		DefPOP = 1 
		WHERE POPID = #DefPOP#
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPOPs" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #DefPOP# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the default POP to #ValueList(GetPOPs.POPName)#.')
		</cfquery>
	</cfif>
</cfif>

<cfparam name="obid" default="POPName">
<cfparam name="obdir" default="asc">
<cfparam name="page" default="1">
<cfquery name="CheckReport" datasource="#pds#">
	SELECT AdminID 
	FROM GrpLists 
	WHERE ReportID = 3 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="AllPOPs" datasource="#pds#">
	SELECT P.POPID, P.POPName, P.Contact, P.Phone1, P.DefPOP, P.State, 
	Count(A.AccountID) As AID 
	FROM POPs P LEFT JOIN AccntPlans A ON P.POPID = A.POPID 
	GROUP BY P.POPID, P.POPName, P.Contact, P.Phone1, P.DefPOP, P.State 
	ORDER BY #obid# #obdir#
</cfquery>
<cfif Page Is 0>
	<cfset MaxRows = AllPOPs.RecordCount>
	<cfset Srow = 1>
<cfelse>
	<cfset MaxRows = mrow>
	<cfset Srow = (Page*mrow)-(mrow-1)>
</cfif>
<cfset PageNumber = Ceiling(AllPOPs.RecordCount/mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>POPs List</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<script language="javascript">
<!--  
function CopyPlan()
	{
    if (confirm ('Click Ok to confirm making a copy of this POP.'))
	 	document.EditInfo.submit()
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="10" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">POPs List</font></th>
	</tr>
</cfoutput>
	<cfif AllPOPs.RecordCount GT mrow>
		<tr>
			<form method="post" action="pops.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="10"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "POPName">
							<cfset dispstr = AllPOPs.POPName[Arraypoint]>
						<cfelseif obid Is "Contact">
							<cfset dispstr = AllPOPs.Contact[Arraypoint]>
						<cfelseif obid Is "Phone1">
							<cfset dispstr = AllPOPs.Phone1[Arraypoint]>
						<cfelseif obid Is "State">
							<cfset dispstr = AllPOPs.State[Arraypoint]>
						<cfelseif obid Is "Count(A.AccountID)">
							<cfset dispstr = AllPOPs.AID[Arraypoint]>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllPOPs.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfoutput>
	 	<form method="post" action="pops2.cfm">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="page" value="#page#">
			<tr>
				<td colspan="10" align="right"><input type="image" src="images/addnew.gif" border="0"></td>
			</tr>
		</form>			
		<tr bgcolor="#thclr#">
			<th>List</th>
			<th>Edit</th>
			<th>Default</th>
			<form method="post" action="pops.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "popname") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "popname">checked</cfif> name="obid" value="popname" onclick="submit()" id="col1"><label for="col1">POP</label></th>
			</form>
			<form method="post" action="pops.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "state") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "state">checked</cfif> name="obid" value="state" onclick="submit()" id="col2"><label for="col2">State</label></th>
			</form>
			<form method="post" action="pops.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "contact") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "contact">checked</cfif> name="obid" value="contact" onclick="submit()" id="col2"><label for="col2">Contact</label></th>
			</form>
			<form method="post" action="pops.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "Phone1") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "Phone1">checked</cfif> name="obid" value="Phone1" onclick="submit()" id="col2"><label for="col2">Phone</label></th>
			</form>
			<form method="post" action="pops.cfm">
				<th nowrap><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "Count(A.AccountID)") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "Count(A.AccountID)">checked</cfif> name="obid" value="Count(A.AccountID)" onclick="submit()" id="col2"><label for="col2">In POP</label></th>
			</form>
			<th>Copy</th>
			<th>Delete</th>
		</tr>
		<form method="post" name="EditInfo" action="pops.cfm" onsubmit="MsgWindow()">
			<input type="hidden" name="page" value="#Page#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
	</cfoutput>
		<cfoutput query="AllPOPs" startrow="#srow#" maxrows="#MaxRows#">
			<tr bgcolor="#tdclr#" valign="top">
				<td align="center"><input type="checkbox" name="POPID" value="#POPID#"></td>
				<td align="center"><input type="radio" name="EditID" value="#POPID#" onclick="document.EditInfo.action='pops2.cfm';submit()"></td>
				<td align="center"><input <cfif defpop is 1>checked</cfif> type="radio" name="defpop" value="#POPID#" onClick="submit()"></td>
				<td bgcolor="#tbclr#">#POPName#</td>
				<td bgcolor="#tbclr#">#State#</td>
				<td bgcolor="#tbclr#">#Contact#</td>
				<td align="right" bgcolor="#tbclr#">#Phone1#</td>
				<td align="right" bgcolor="#tbclr#">#AID#</td>
				<th><input type="radio" name="CopyFrom" value="#POPID#" onclick="CopyPlan()"></th>
				<th><cfif aid is 0><input type="checkbox" name="delem" value="#POPID#"><cfelse>&nbsp;</cfif></th>
			</tr>
		</cfoutput>
		<cfif CheckReport.RecordCount GT 0>
			<cfoutput>
				<tr bgcolor="#tdclr#">
					<th><input type="checkbox" name="popid" value="0"></th>
					<td bgcolor="#tbclr#" colspan="8">View Existing List</td>
					<th><input type="checkbox" name="deletelist" value="1" onclick="submit()"></th>
				</tr>
			</cfoutput>
		</cfif>
		<tr>
			<th colspan="10"><input type="image" name="ListPOPs" src="images/list.gif" border="0"> <input type="image" name="deleteit" src="images/delete.gif" border="0"></th>
		</tr>
		</form>
	<cfif AllPOPs.RecordCount GT mrow>
		<tr>
			<form method="post" action="pops.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="10"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "POPName">
							<cfset dispstr = AllPOPs.POPName[Arraypoint]>
						<cfelseif obid Is "Contact">
							<cfset dispstr = AllPOPs.Contact[Arraypoint]>
						<cfelseif obid Is "Phone1">
							<cfset dispstr = AllPOPs.Phone1[Arraypoint]>
						<cfelseif obid Is "State">
							<cfset dispstr = AllPOPs.State[Arraypoint]>
						<cfelseif obid Is "Count(AccountID)">
							<cfset dispstr = AllPOPs.AID[Arraypoint]>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllPOPs.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfoutput>
	
</table>
</cfoutput>

<cfinclude template="footer.cfm">
</body>
</html>
 
