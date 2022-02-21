<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.1 --->
<!--- This page is a list of all plans. --->
<!---	4.0.2 11/01/00 Added ability to copy plans
		4.0.1 10/10/00 Fixed error when deleting a plan with a ' in the name
		4.0.0 07/03/99
		3.2.0 09/08/98
		3.1.1 07/23/98 Aligned the buttons to be consistent with other pages
		3.1.0 07/15/98 --->
<!--- listplan.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("CopyFrom")>
	<cfquery name="GetFrom" datasource="#pds#">
		SELECT * 
		FROM Plans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfset FieldList = GetFrom.ColumnList>
	<cfset Pos1 = ListFindNoCase(FieldList,"PlanID")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos1)>
	<cfset Pos2 = ListFindNoCase(FieldList,"PlanDesc")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos2)>
	<cfset Pos3 = ListFindNoCase(FieldList,"DefPlan")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos3)>
	<cftransaction>
		<cfquery name="MakeNew" datasource="#pds#">
			INSERT INTO Plans 
			(PlanDesc, DefPlan, #FieldList#) 
			SELECT '#GetFrom.PlanDesc# Copy', 0, #FieldList# 
			FROM Plans 
			WHERE PlanID = #CopyFrom# 
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(PlanID) As MaxID 
			FROM Plans 
		</cfquery>
	</cftransaction>
	<cfset NewPlanID = NewID.MaxID>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomPlans 
		(DomainID, PlanID) 
		SELECT DomainID, #NewPlanID# 
		FROM DomPlans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomAPlans 
		(DomainID, PlanID) 
		SELECT DomainID, #NewPlanID# 
		FROM DomAPlans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomFPlans 
		(DomainID, PlanID) 
		SELECT DomainID, #NewPlanID# 
		FROM DomFPlans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsSpans" datasource="#pds#">
		INSERT INTO Spans 
		(PlanID, BaseAmount, OverCharge, SpanStart, SpanEnd, SpanUnit, SpanPeriod, SpanDescrip) 
		SELECT #NewPlanID#, BaseAmount, OverCharge, SpanStart, SpanEnd, SpanUnit, SpanPeriod, SpanDescrip 
		FROM Spans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsAdmin" datasource="#pds#">
		INSERT INTO PlanAdm 
		(PlanID, AdminID) 
		SELECT #NewPlanID#, AdminID 
		FROM PlanAdm 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsPOPs" datasource="#pds#">
		INSERT INTO POPPlans 
		(PlanID, POPID) 
		SELECT #NewPlanID#, POPID 
		FROM POPPlans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsScripts" datasource="#pds#">
		INSERT INTO IntPlans 
		(IntID, PlanID) 
		SELECT IntID, #NewPlanID# 
		FROM IntPlans 
		WHERE PlanID = #CopyFrom# 
	</cfquery>
</cfif>
<cfif IsDefined("deletelist")>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 1 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("defplan")>
	<cfquery name="PlanName" datasource="#pds#">
		SELECT PlanDesc, PlanID 
		FROM Plans 
		WHERE PlanID = #DefPlan# 
	</cfquery>
	<cfquery name="CurDefault" datasource="#pds#">
		SELECT PlanDesc, PlanID 
		FROM Plans 
		WHERE DefPlan = 1 
	</cfquery>
	<cfif PlanName.PlanID Is Not CurDefault.PlanID>
		<cfquery name="ClearDef" datasource="#pds#">
			UPDATE Plans Set 
			DefPlan = 0 
		</cfquery>
		<cfquery name="SetDef" datasource="#pds#">
			UPDATE Plans Set 
			DefPlan = 1 
			WHERE PlanID = #DefPlan#
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="PlanName" datasource="#pds#">
				SELECT PlanDesc 
				FROM Plans 
				WHERE PlanID = #DefPlan# 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the default plan to #PlanName.PlanDesc#.')
			</cfquery>
		</cfif>	
	</cfif>
</cfif>
<cfif (IsDefined("ListPlans.x")) AND (IsDefined("PlanID"))>
	<cfsetting enablecfoutputonly="no">
	<cfif PlanID Is Not "0">
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT ReportID 
			FROM GrpLists 
			WHERE ReportID = 1 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfif CheckFirst.RecordCount GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE ReportID = 1 
				AND AdminID = #MyAdminID# 
			</cfquery>
		</cfif>
		<cfquery name="EnterData" datasource="#PDS#">
			INSERT INTO GrpLists 
			(LastName, FirstName, Login, City, AccountID, Phone, Company, AccntPlanID, 
			 ReportHeader, ReportID, AdminID, ReportTitle, CreateDate) 
			SELECT A.LastName, A.FirstName, A.Login, A.City, A.AccountID, A.dayphone, 
			A.Company, AP.AccntPlanID, P.PlanDesc, 1, #MyAdminID#, 'List Of Customers by Plan', #Now()# 
			FROM Accounts A, AccntPlans AP, Plans P 
			WHERE A.AccountID = AP.AccountID 
			AND AP.PlanID = P.PlanID 
			AND P.PlanID In (#PlanID#)
		</cfquery>
		<cfquery name="GetEMails" datasource="#pds#">
			UPDATE GrpLists SET 
			EMail = E.Email 
			FROM AccountsEMail E, GrpLists G 
			WHERE G.AccountID = E.AccountID 
			AND E.PrEMail = 1 
			AND G.ReportID = 1 
			AND G.AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfset SendReportID = 1>
	<cfset SendLetterID = 1>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 1 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "listplan.cfm">
	<cfset SendHeader = "Name,Login,City,Plan,E-Mail">
	<cfset SendFields = "Name,Login,City,ReportHeader,EMail">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfif (IsDefined("deleteit.x")) AND (IsDefined("delem"))>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM DomPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM DomAPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM DomFPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM IntPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM FilterPlans 
		WHERE PlanID In (#delem#) 
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM IntPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE PlanID In (#delem#) 
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM Plans2Spans  
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM Spans 
		WHERE PlanID In (#delem#) 
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM POPPlans 
		WHERE PlanID In (#delem#)
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="PlanNames" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID In (#delem#) 			
		</cfquery>
		<cfset DelPlanList = ValueList(PlanNames.PlanDesc)>
		<cfset DelPlanList = Replace(DelPlanList,"'","","All")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Plans','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following plans: #DelPlanList#')
		</cfquery>
	</cfif>		
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM Plans 
		WHERE PlanID In (#delem#)
	</cfquery>
</cfif>
<cfparam name="obid" default="PlanDesc">
<cfparam name="obdir" default="asc">
<cfparam name="page" default="1">
<cfquery name="CheckReport" datasource="#pds#">
	SELECT AdminID 
	FROM GrpLists 
	WHERE ReportID = 1 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="AllPlans" datasource="#PDS#">
	SELECT P.PlanDesc, P.PlanID, P.RecurringAmount,
	P.FixedAmount, P.RecurringCycle, P.Meteredyn, P.DefPlan, 
	Count(A.AccountID) AS CAID
	FROM Plans P LEFT JOIN AccntPlans A ON P.PlanID = A.PlanID
	GROUP BY P.PlanDesc, P.PlanID, P.RecurringAmount,
	P.FixedAmount, P.RecurringCycle, P.basehours, P.Meteredyn, P.DefPlan
	ORDER BY #obid# #obdir#
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset MaxRows = AllPlans.RecordCount>
<cfelse>
	<cfset Srow = (Page*mrow) - (mrow-1)>
	<cfset MaxRows =mrow>
</cfif>
<cfset PageNumber = Ceiling(AllPlans.RecordCount/mrow)>
<cfhtmlhead text="<script language=""javascript"">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<script language=""javascript"">
<!--  
function CopyPlan()
	{
    if (confirm ('Click Ok to confirm making a copy of this plan.'))
	 	document.EditInfo.submit()
	}
// -->
</script>
">
<cfset HowWide = 10>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Plans</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Plans</font></th>
	</tr>
</cfoutput>
	<cfif AllPlans.RecordCount GT mrow>
		<tr>
			<form method="post" action="listplan.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
					<td colspan="#HowWide#"><select name="Page" onChange="submit()">
				</cfoutput>
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "plandesc">
							<cfset dispstr = AllPlans.PlanDesc[Arraypoint]>
						<cfelseif obid Is "recurringamount">
							<cfset dispstr = AllPlans.recurringamount[Arraypoint]>
						<cfelseif obid Is "fixedamount">
							<cfset dispstr = AllPlans.fixedamount[Arraypoint]>
						<cfelseif obid Is "recurringcycle">
							<cfset dispstr = AllPlans.recurringcycle[Arraypoint]>
						<cfelseif obid Is "Count(A.AccountID)">
							<cfset dispstr = AllPlans.CAID[Arraypoint]>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllPlans.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfoutput>
 	<form method="post" action="listplan2.cfm">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">
		<input type="hidden" name="page" value="#page#">
		<tr>
			<td colspan="#HowWide#" align="right"><input type="image" src="images/addnew.gif" border="0"></td>
		</tr>
	</form>			
		<tr bgcolor="#thclr#">
			<th>List</th>
			<th>Edit</th>
			<th>Default</th>
			<form method="post" action="listplan.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "plandesc") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "plandesc">checked</cfif> name="obid" value="plandesc" onclick="submit()" id="col1"><label for="col1">Name</label></th>
			</form>
			<form method="post" action="listplan.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "recurringamount") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "recurringamount">checked</cfif> name="obid" value="recurringamount" onclick="submit()" id="col2"><label for="col2">Recurring</label></th>
			</form>
			<form method="post" action="listplan.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "fixedamount") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "fixedamount">checked</cfif> name="obid" value="fixedamount" onclick="submit()" id="col3"><label for="col3">Setup</label></th>
			</form>
			<form method="post" action="listplan.cfm">
				<th><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "recurringcycle") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "recurringcycle">checked</cfif> name="obid" value="recurringcycle" onclick="submit()" id="col4"><label for="col4">Months</label></th>
			</form>
			<form method="post" action="listplan.cfm">
				<th nowrap><input type="hidden" name="page" value="#Page#">
				<cfif (obid Is "Count(A.AccountID)") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="radio" <cfif obid Is "Count(A.AccountID)">checked</cfif> name="obid" value="Count(A.AccountID)" onclick="submit()" id="col5"><label for="col5">On Plan</label></th>
			</form>
			<th>Copy</th>
			<th>Delete</th>
		</tr>
		<form method="post" name="EditInfo" action="listplan.cfm" onsubmit="MsgWindow()">
		<input type="hidden" name="page" value="#Page#">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">
</cfoutput>
		<cfoutput query="allplans" startrow="#srow#" maxrows="#maxrows#">
			<tr bgcolor="#tdclr#" valign="top">
				<td align="center"><input type="checkbox" name="planid" value="#planid#"></td>
				<td align="center"><input type="radio" name="EditID" value="#PlanID#" onclick="document.EditInfo.action='listplan2.cfm';submit()"></td>
				<td align="center"><input <cfif defplan is 1>checked</cfif> type="radio" name="defplan" value="#planid#" onClick="submit()"></td>
				<td bgcolor="#tbclr#">#PlanDesc#</td>
				<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(recurringamount)#</td>
				<td align="right" bgcolor="#tbclr#">#LSCurrencyFormat(fixedamount)#</td>
				<td bgcolor="#tbclr#" align="right">#Int(recurringcycle)#</td>
				<td align="right" bgcolor="#tbclr#">#CAID#</td>
				<th><input type="Radio" name="CopyFrom" value="#PlanID#" onclick="CopyPlan()"></th>
				<th><cfif caid is 0><input type="checkbox" name="delem" value="#planid#"><cfelse>&nbsp;</cfif></th>
			</tr>
		</cfoutput>
		<cfif CheckReport.RecordCount GT 0>
			<cfoutput>
				<tr bgcolor="#tdclr#">
					<th><input type="checkbox" name="planid" value="0"></th>
					<td bgcolor="#tbclr#" colspan="8">View Existing List</td>
					<th><input type="checkbox" name="deletelist" value="1" onclick="submit()"></th>
				</tr>
			</cfoutput>
		</cfif>
		<tr>
			<cfoutput>
				<th colspan="#HowWide#"><input type="image" name="ListPlans" src="images/list.gif" border="0"><input type="image" name="deleteit" src="images/delete.gif" border="0"></th>
			</cfoutput>
		</tr>
		</form>
	<cfif AllPlans.RecordCount GT mrow>
		<tr>
			<form method="post" action="listplan.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
					<td colspan="#HowWide#"><select name="Page" onChange="submit()">
				</cfoutput>
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "plandesc">
							<cfset dispstr = AllPlans.PlanDesc[Arraypoint]>
						<cfelseif obid Is "recurringamount">
							<cfset dispstr = AllPlans.recurringamount[Arraypoint]>
						<cfelseif obid Is "fixedamount">
							<cfset dispstr = AllPlans.fixedamount[Arraypoint]>
						<cfelseif obid Is "recurringcycle">
							<cfset dispstr = AllPlans.recurringcycle[Arraypoint]>
						<cfelseif obid Is "Count(Accounts.AccountID)">
							<cfset dispstr = AllPlans.CAID[Arraypoint]>
						</cfif>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllPlans.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 