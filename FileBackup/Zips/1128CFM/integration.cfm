<cfsetting enablecfoutputonly="yes">
<!-- Version 3.5.0 -->
<!--- This is the page that lists the scripts. --->
<!--- 3.5.0 07/07/99 --->
<!-- integration.cfm -->

<cfset securepage="integration.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SetVariables.x")>
	<cftransaction>
		<cfquery name="TurnAllOff" datasource="#pds#">
			UPDATE IntVariables SET 
			ShowListYN = 0 
			WHERE ForTable = '#ForTable#'
		</cfquery>
		<cfquery name="TurnSelOn" datasource="#pds#">
			UPDATE IntVariables SET 
			ShowListYN = 1 
			WHERE VariableID In (#ShowListYN#)
		</cfquery>
	</cftransaction>
</cfif>
<cfif IsDefined("EditExtLoc.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE IntLocations SET 
		PageName = '#PageName#', 
		PageDesc = '#PageDesc#', 
		LocationAction = '#LocationAction#', 
		ActiveYN = #ActiveYN# 
		WHERE LocationID = #LocationID# 
	</cfquery>
	<cfset Tab = 3>
</cfif>
<cfif IsDefined("AddNewLoc.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO IntLocations 
		(PageName, PageDesc, ActiveYN, LocationAction, CFVarYN) 
		VALUES 
		('#PageName#','#PageDesc#',#ActiveYN#,'#LocationAction#',0)
	</cfquery>
	<cfset Tab = 3>
</cfif>
<cfif IsDefined("Toggle")>
	<cfquery name="ToggleActive" datasource="#pds#">
		UPDATE IntLocations SET 
		ActiveYN = <cfif ToggleStatus Is 0>1<cfelse>0</cfif> 
		WHERE LocationID = #ID#
	</cfquery>
</cfif>
<cfif IsDefined("DeleteLocations.x") AND IsDefined("DelSelectLocations")>
	<cfquery name="DelData" datasource="#pds#">
		Delete FROM IntLocations 
		WHERE LocationID In (#DelSelectLocations#) 
	</cfquery>
</cfif>
<cfif IsDefined("ToggleActive")>
	<cfquery name="ToggleAScript" datasource="#pds#">
		UPDATE Integration SET 
		ActiveYN = <cfif IsDefined("ToggleScript")>1<cfelse>0</cfif> 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("DelOneScript")>
	<cftransaction>
		<cfquery name="DelAScript" datasource="#pds#">
			DELETE FROM IntPlans 
			WHERE IntID = #IntID#
		</cfquery>
		<cfquery name="DelBScript" datasource="#pds#">
			DELETE FROM IntVariables 
			WHERE CustomYN = #IntID#
		</cfquery>
		<cfquery name="DelCScript" datasource="#pds#">
			DELETE FROM Integration 
			WHERE IntID = #IntID#
		</cfquery>
	</cftransaction>
	<cfquery name="Renumber" datasource="#pds#">
		SELECT * 
		FROM Integration 
		WHERE Action = '#Action#'
		ORDER BY SortOrder
	</cfquery>
	<cfset counter1 = 1>
	<cfloop query="Renumber">
		<cfquery name="ResetOrder" datasource="#pds#">
			UPDATE Integration SET 
			SortOrder = #counter1# 
			WHERE IntID = #IntID#
		</cfquery>
		<cfset counter1 = counter1 + 1>
	</cfloop>
</cfif>
<cfif IsDefined("MvUp.x")>
	<cfset TheCurSort = CurSortOrder>
	<cfset TheNewSort = CurSortOrder - 1>
	<cfquery name="ChangeSort" datasource="#pds#">
		UPDATE Integration SET 
		SortOrder = #TheCurSort# 
		WHERE SortOrder = #TheNewSort# 
		AND Action = '#Action#' 
	</cfquery>
	<cfquery name="ChangeSort" datasource="#pds#">
		UPDATE Integration SET 
		SortOrder = #TheNewSort# 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfif IsDefined("MvDn.x")>
	<cfset TheCurSort = CurSortOrder>
	<cfset TheNewSort = CurSortOrder + 1>
	<cfquery name="ChangeSort" datasource="#pds#">
		UPDATE Integration SET 
		SortOrder = #TheCurSort# 
		WHERE SortOrder = #TheNewSort# 
		AND Action = '#Action#' 
	</cfquery>
	<cfquery name="ChangeSort" datasource="#pds#">
		UPDATE Integration SET 
		SortOrder = #TheNewSort# 
		WHERE IntID = #IntID#
	</cfquery>
</cfif>
<cfparam name="Tab" default="1">
<cfparam name="CreateTopCT" default="0">
<cfparam name="ChangeTopPT" default="0">
<cfparam name="DeleteTopDT" default="0">
<cfparam name="LetterTopLT" default="0">
<cfparam name="HowWide" default="1">
<cfif Tab Is 1>
	<cfset HowWide = 7>
	<cfquery name="allscripts" datasource="#pds#">
		SELECT I.*, T.TypeStr 
		FROM Integration I, IntTypes T 
		WHERE I.TypeID = T.TypeID 
		AND Action <> 'Letter' 
		ORDER BY I.Action, I.SortOrder
	</cfquery>
	<cfquery name="CreateTop" datasource="#pds#">
		SELECT max(SortOrder) as CT
		FROM Integration 
		WHERE Action = 'Create'
	</cfquery>
	<cfset CreateTopCT = CreateTop.CT>
	<cfquery name="ChangeTop" datasource="#pds#">
		SELECT max(SortOrder) as PT
		FROM Integration 
		WHERE Action = 'Change'
	</cfquery>
	<cfset ChangeTopPT = ChangeTop.PT>
	<cfquery name="DeleteTop" datasource="#pds#">
		SELECT max(SortOrder) as DT
		FROM Integration 
		WHERE Action = 'Delete'
	</cfquery>
	<cfset DeleteTopDT = DeleteTop.DT>
<cfelseif Tab Is 2>
	<cfset HowWide = 7>
	<cfquery name="allscripts" datasource="#pds#">
		SELECT I.*, T.TypeStr 
		FROM Integration I, IntTypes T 
		WHERE I.TypeID = T.TypeID 
		AND Action = 'Letter' 
		ORDER BY I.Action, I.SortOrder
	</cfquery>
	<cfquery name="LetterTop" datasource="#pds#">
		SELECT max(SortOrder) as LT 
		FROM Integration 
		WHERE Action = 'Letter'
	</cfquery>
	<cfset LetterTopLT = LetterTop.LT>
<cfelseif Tab Is 3>
	<cfset HowWide = 6>
	<cfparam name="Obid" default="PageDesc">
	<cfparam name="Obdir" default="asc">
	<cfquery name="AllLocations" datasource="#pds#">
		SELECT * 
		FROM IntLocations 
		ORDER BY #Obid# #Obdir# 
	</cfquery>
<cfelseif Tab Is 4>
	<cfset HowWide = 3>
	<cfparam name="ForTable" default="Accounts">
	<cfquery name="GetVariables" datasource="#pds#">
		SELECT * 
		FROM IntVariables 
		WHERE ForTable = '#ForTable#' 
		ORDER BY UseText 
	</cfquery>
	<cfquery name="TableNames" datasource="#pds#">
		SELECT ForTable 
		FROM IntVariables 
		WHERE ForTable IS NOT NULL 
		GROUP BY ForTable 
		ORDER BY ForTable 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif Tab Is 1>
	<title>Script List</TITLE>
<cfelseif Tab Is 2>
	<title>Letters List</title>
<cfelseif Tab Is 3>
	<title>Locations List</title>
<cfelseif Tab Is 4>
	<title>Variables List</title>
<cfelse>
	<title>Read John 3:16</title>
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<center>

<cfoutput>
	
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Integration Scripts</font></th>
		</tr>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="integration.cfm">
							<td bgcolor=<cfif Tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">E-Mail Letters</label></td>							
							<td bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Scripts</label></td>
							<td bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Locations</label></td>
							<td bgcolor=<cfif Tab Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Variables</label></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
</cfoutput>
<cfif Tab Is 1>
	<cfoutput>
			<tr>
				<td align="right" colspan="7"><a href="integration2.cfm"><img src="images/addnew.gif" border="0"></a></td>
			</tr>
	</cfoutput>
	<cfoutput query="allscripts" group="Action">
		<cfif Action Is "Letter">
			<tr>
				<th bgcolor="#thclr#" colspan="7">EMail Letters</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Test</th>
				<th>Edit</th>
				<th>Active</th>
				<th>Type</th>
				<th>Letter List Order</th>
				<th>Move</th>
				<th>Delete</th>
			</tr>
		<cfelse>
			<tr>
				<th bgcolor="#thclr#" colspan="7"><b>#Action#</b></th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Test</th>
				<th>Edit</th>
				<th>Active</th>
				<th>Type</th>
				<th>Script Run Order</th>
				<th>Move</th>
				<th>Delete</th>
			</tr>
		</cfif>
		<cfoutput>
			<form method="post" name="TestIt" action="inttest.cfm">
				<tr>
					<td align="center" bgcolor="#tdclr#"><a name="##Message#IntID#"></a><input type="radio" name="IntID" value="#IntID#" onClick="submit()"></td>
			</form>
			<form method="post" name="EditIt" action="integration2.cfm"">
					<td bgcolor="#tdclr#" align="center"><input type="radio" name="IntID" value="#IntID#" onClick="submit()"></td>
			</form>
			<form method="post" name="ToggleIt" action="integration.cfm">
				<input type="hidden" name="IntID" value="#IntID#">
				<input type="hidden" name="ToggleActive" value="1">
					<td bgcolor="#tdclr#" align="center"><input <cfif ActiveYN>checked</cfif> type="checkbox" name="ToggleScript" value="#IntID#" onclick="submit()"></td>
			</form>
			<form method="post" name="MoveIt" action="integration.cfm##Message#IntID#">
					<input type="hidden" name="IntID" value="#IntID#">
					<input type="hidden" name="Action" value="#Action#">
					<input type="hidden" name="CurSortOrder" value="#SortOrder#">
					<td bgcolor="#tbclr#">#TypeStr#</td>
					<td bgcolor="#tbclr#">#IntDesc#</td>
					<cfif SortOrder GT 1>
						<td bgcolor="#tdclr#"><input type="image" border="0" name="mvUp" src="images/buttonf.gif">
					<cfelse>
						<td bgcolor="#tdclr#" align="right">
					</cfif>
					<cfif Action Is "Create" AND CreateTop.CT Is SortOrder></td>
					<cfelseif Action Is "Change" AND ChangeTop.PT Is SortOrder></td>
					<cfelseif Action Is "Delete" AND DeleteTop.DT Is SortOrder></td>
					<cfelseif Action Is "Letter" AND LetterTop.LT Is SortOrder></td>
					<cfelse><input type="image" border="0" name="mvDn" src="images/buttong.gif"></td>
					</cfif>
			</form>
			<form method="post" name="DelIt" action="integration.cfm" onSubmit="return confirm ('Click Ok to confirm deleting this script.')">
					<input type="hidden" name="IntID" value="#IntID#">
					<input type="hidden" name="Action" value="#Action#">
					<input type="hidden" name="CurSortOrder" value="#SortOrder#">		
					<td bgcolor="#tdclr#"><font size="2"><input type="submit" name="DelOneScript" value="Delete"></font></td>
				</tr>
			</form>
		</cfoutput>
	</cfoutput>
<cfelseif Tab Is 2>
	<cfoutput>
		<tr>
			<form method="post" action="integration2.cfm"">
				<input type="hidden" name="IntTypeSetup" value="Letter">
				<td align="right" colspan="7"><input type="image" src="images/addnew.gif" border="0"></a></td>
			</form>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="7">EMail Letters</th>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Test</th>
			<th>Edit</th>
			<th>Active</th>
			<th>Type</th>
			<th>Letter List Order</th>
			<th>Move</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfoutput query="allscripts">
		<form method="post" name="TestIt" action="inttest.cfm">
			<tr>
				<td align="center" bgcolor="#tdclr#"><a name="##Message#IntID#"></a><input type="radio" name="IntID" value="#IntID#" onClick="submit()"><a name="##Message#IntID#"></td>
		</form>
		<form method="post" name="EditIt" action="integration2.cfm"">
				<td bgcolor="#tdclr#" align="center"><input type="radio" name="IntID" value="#IntID#" onClick="submit()"></td>
		</form>
		<form method="post" name="ToggleIt" action="integration.cfm">
			<input type="hidden" name="IntID" value="#IntID#">
			<input type="Hidden" name="Tab" value="#Tab#">
			<input type="hidden" name="ToggleActive" value="1">
				<td bgcolor="#tdclr#" align="center"><input <cfif ActiveYN>checked</cfif> type="checkbox" name="ToggleScript" value="#IntID#" onclick="submit()"></td>
		</form>
		<form method="post" name="MoveIt" action="integration.cfm##Message#IntID#">
				<input type="hidden" name="IntID" value="#IntID#">
				<input type="Hidden" name="Tab" value="#Tab#">
				<input type="hidden" name="Action" value="#Action#">
				<input type="hidden" name="CurSortOrder" value="#SortOrder#">
				<td bgcolor="#tbclr#">#TypeStr#</td>
				<td bgcolor="#tbclr#">#IntDesc#</td>
				<cfif SortOrder GT 1>
					<td bgcolor="#tdclr#"><input type="image" border="0" name="mvUp" src="images/buttonf.gif">
				<cfelse>
					<td bgcolor="#tdclr#" align="right">
				</cfif>
				<cfif CreateTopCT Is SortOrder AND Action Is "Create"></td>
				<cfelseif ChangeTopPT Is SortOrder AND Action Is "Change"></td>
				<cfelseif DeleteTopDT Is SortOrder AND Action Is "Delete"></td>
				<cfelseif LetterTopLT Is SortOrder AND Action Is "Letter"></td>
				<cfelse><input type="image" border="0" name="mvDn" src="images/buttong.gif"></td>
				</cfif>
		</form>
		<form method="post" name="DelIt" action="integration.cfm" onSubmit="return confirm ('Click Ok to confirm deleting this script.')">
				<input type="hidden" name="IntID" value="#IntID#">
				<input type="Hidden" name="Tab" value="#Tab#>
				<input type="hidden" name="Action" value="#Action#">
				<input type="hidden" name="CurSortOrder" value="#SortOrder#">		
				<td bgcolor="#tdclr#"><font size="2"><input type="submit" name="DelOneScript" value="Delete"></font></td>
			</tr>
		</form>
	</cfoutput>
<cfelseif Tab Is 3>
	<cfoutput>
		<form method="post" action="intlocations.cfm">
			<tr>
				<td align="right" colspan="#HowWide#"><input type="image" src="images/addnew.gif" name="NewLocation" border="0"></a></td>
			</tr>
		</form>
		<tr>
			<th bgcolor="#thclr#" colspan="#HowWide#">Script Run Locations</th>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Edit</th>
			<th>Active</th>
			<form method="post" action="integration.cfm">
				<cfif (Obid Is "PageDesc") AND (obdir Is "asc")>
					<input type="Hidden" name="obdir" value="desc">
				<cfelse>
					<input type="Hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="Tab" value="#Tab#">
				<th><input <cfif Obid Is "PageDesc">checked</cfif> type="radio" name="Obid" value="PageDesc" onclick="submit()" id="col1"><label for="col1">Description</label></th>
			</form>
			<form method="post" action="integration.cfm">
				<cfif (Obid Is "PageName") AND (obdir Is "asc")>
					<input type="Hidden" name="obdir" value="desc">
				<cfelse>
					<input type="Hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="Tab" value="#Tab#">
				<th><input <cfif Obid Is "PageName">checked</cfif> type="radio" name="Obid" value="PageName" onclick="submit()" id="col2"><label for="col2">Location</label></th>
			</form>
			<form method="post" action="integration.cfm">
				<cfif (Obid Is "LocationAction") AND (obdir Is "asc")>
					<input type="Hidden" name="obdir" value="desc">
				<cfelse>
					<input type="Hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="Tab" value="#Tab#">
				<th><input <cfif Obid Is "LocationAction">checked</cfif> type="radio" name="Obid" value="LocationAction" onclick="submit()" id="col3"><label for="col3">Action</label></th>
			</form>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" name="EditInfo" action="integration.cfm">
		<cfoutput>
			<input type="hidden" name="Tab" value="#tab#">
			<input type="hidden" name="Toggle" value="0">
			<input type="hidden" name="ToggleStatus" value="0">
			<input type="hidden" name="ID" value="0">
		</cfoutput>
		<cfoutput query="AllLocations">
			<tr>
				<td align="center" bgcolor="#tdclr#"><input type="radio" name="LocationID" value="#LocationID#" onclick="document.EditInfo.action='intlocations.cfm';document.EditInfo.Tab.value=1;submit()"></td>
				<td align="center" bgcolor="#tdclr#"><input <cfif ActiveYN Is 1>checked</cfif> type="checkbox" name="ActiveYN" value="1" onClick="document.EditInfo.Toggle.value=1;document.EditInfo.ID.value=#LocationID#;document.EditInfo.ToggleStatus.value=#ActiveYN#;submit()"></td>
				<td bgcolor="#tbclr#">#PageDesc#</td>
				<td bgcolor="#tbclr#">#PageName#</td>
				<td bgcolor="#tbclr#">#LocationAction#</td>
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 0><input type="checkbox" name="DelSelectLocations" value="#LocationID#"><cfelse>&nbsp;</cfif></th>
			</tr>
		</cfoutput>
		<tr>
			<cfoutput>
				<th colspan="#HowWide#"><input type="image" src="images/delete.gif" name="DeleteLocations" border="0"></th>
			</cfoutput>
		</tr>
	</form>
<cfelseif Tab Is 4>
	<cfoutput>
		<tr>
			<form method="post" action="integration.cfm">
				<td bgcolor="#tdclr#" colspan="#HowWide#"><select name="ForTable" onchange="submit()">
	</cfoutput>
					<cfset SelTable = ForTable>
					<cfoutput query="TableNames">
						<option <cfif ForTable Is SelTable>selected</cfif> value="#ForTable#">#ForTable#
					</cfoutput>
				</select></td>
				<input type="hidden" name="tab" value="4">
			</form>
		</tr>
	<cfoutput>
		<tr>
			<th bgcolor="#thclr#" colspan="#HowWide#">Variables From #ForTable#</th>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Show</th>
			<th>Use</th>
			<th>For</th>
		</tr>
	</cfoutput>
	<form method="post" action="integration.cfm">
		<cfoutput query="GetVariables">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" <cfif ShowListYN Is 1>checked</cfif> name="ShowListYN" value="#VariableID#"></th>
				<td>#UseText#</td>
				<td>#ForText#</td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="3"><input type="image" name="SetVariables" src="images/update.gif" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="tab" value="4">
			<input type="hidden" name="ForTable" value="#ForTable#">
		</cfoutput>
	</form>
</cfif>	

</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>


 