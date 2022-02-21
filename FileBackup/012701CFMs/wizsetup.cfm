<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the setup page for the wizard drop downs. --->
<!---	4.0.0 07/13/99 --->
<!--- wizsetup.cfm --->
<cfif IsDefined("AddCheckDebit.x")>
	<cfquery name="GetSort" datasource="#pds#">
		SELECT Max(SortOrder) as MaxSort 
		FROM PayTypes 
		WHERE UseTab = #tab2#  
		AND ActiveYN = 1
	</cfquery>
	<cfif GetSort.MaxSort Is "">
		<cfset NextSort = 1>
	<cfelse>
		<cfset NextSort = GetSort.MaxSort + 1>
	</cfif>
	<cfset TheFieldName = Replace(FieldName," ","_","All")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT FieldName 
		FROM PayTypes 
		WHERE FieldName = '#TheFieldName#'
	</cfquery>
	<cfquery name="AddData"	 datasource="#pds#">
		INSERT INTO PayTypes 
		(FieldName,PromptStr,CFVarYN,UseTab,SortOrder,ActiveYN,DataType,RequiredYN,FieldSize,InputMaxSize) 
		VALUES 
		('#TheFieldName#','#PromptStr#',0,#Tab2#,#NextSort#,#ActiveYN#,'#DataType#',#RequiredYN#,#FieldSize#,#InputMaxSize#)
	</cfquery>
</cfif>
<cfif IsDefined("UpdCheckDebit.x")>
	<cfloop index="B5" from="1" to="#RecCount#">
		<cfset var1 = Evaluate("PayTypeID#B5#")>
		<cfset var2 = Evaluate("PromptStr#B5#")>
		<cfset var3 = Evaluate("SortOrder#B5#")>
		<cfset var6 = Evaluate("DataType#B5#")>
		<cfset var7 = Evaluate("FieldSize#B5#")>
		<cfif IsDefined("RequiredYN#B5#")>
			<cfset var8 = 1>
		<cfelse>
			<cfset var8 = 0>
		</cfif>
		<cfif IsDefined("ActiveYN#B5#")>
			<cfset var4 = 1>
		<cfelse>
			<cfset var4 = 0>
		</cfif>
		<cfif IsDefined("FieldName#B5#")>
			<cfset var5 = Evaluate("FieldName#B5#")>
		<cfelse>
			<cfset var5 = "">
		</cfif>
		<cfset var9 = Evaluate("InputMaxSize#B5#")>
		<cfset TheFieldName = Replace(var5," ","_","All")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE PayTypes SET 
			PromptStr = <cfif Trim(var2) Is "">Null<cfelse>'#var2#'</cfif>, 
			<cfif var4 Is 0>
				SortOrder = 0, 
			<cfelse>
				SortOrder = #var3#, 
			</cfif>
			<cfif Trim(var5) Is Not "">
				FieldName = '#TheFieldName#', 
			</cfif>
			DataType = '#var6#', 
			FieldSize = '#var7#', 
			RequiredYN = #var8#, 
			InputMaxSize = <cfif var9 Is "">Null<cfelse>#var9#</cfif>, 
			ActiveYN = #var4# 
			WHERE PayTypeID = #var1#
		</cfquery>
	</cfloop>
	<cfquery name="AllActive" datasource="#pds#">
		SELECT * 
		FROM PayTypes 
		WHERE UseTab = #tab2# 
		AND ActiveYN = 1 
		ORDER BY SortOrder
	</cfquery>
	<cfset counter1 = 0>
	<cfloop query="AllActive">
		<cfset counter1 = counter1 + 1>
		<cfquery name="ReSort" datasource="#pds#">
			UPDATE PayTypes SET 
			SortOrder = #counter1# 
			WHERE PayTypeID = #PayTypeID#
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("AddNewCountry.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO Countries 
		(Country,CountryAbbr,ActiveYN)
		VALUES 
		('#Country#','#CountryAbbr#',#ActiveYN#)
	</cfquery>
</cfif>
<cfif IsDefined("AddNewState.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO States 
		(Statename, Abbr, ActiveYN, StateYN) 
		VALUES 
		('#Statename#', '#Abbr#', #ActiveYN#, #StateYN#)
	</cfquery>
</cfif>
<cfif IsDefined("AddNewOSV.x")>
	<cfquery name="getnextsort" datasource="#pds#">
		SELECT max(SortOrder) as mxsort 
		FROM OSVersion
	</cfquery>
	<cfif getnextsort.mxsort Is "">
		<cfset NextSort = 1>
	<cfelse>
		<cfset NextSort = getnextsort.mxsort + 1>
	</cfif>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO OSVersion 
		(OSV, AccountYN, OnlineYN) 
		VALUES 
		('#OSV#',#AccountYN#,#OnlineYN#) 
	</cfquery>
</cfif>
<cfif IsDefined("AddNewSpeed.x")>
	<cfquery name="getnextsort" datasource="#pds#">
		SELECT max(SortOrder) as mxsort 
		FROM ModemSpeeds 
	</cfquery>
	<cfif getnextsort.mxsort Is "">
		<cfset NextSort = 1>
	<cfelse>
		<cfset NextSort = getnextsort.mxsort + 1>
	</cfif>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO ModemSpeeds 
		(ModemSpeed, AccountYN, OnlineYN, SortOrder) 
		VALUES 
		('#ModemSpeed#',#AccountYN#,#OnlineYN#,#NextSort#) 
	</cfquery>
</cfif>
<cfif IsDefined("DefCountry")>
	<cfif ToggleDef Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Countries SET 
			DefCountry = 0
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Countries SET 
			DefCountry = 1 
			WHERE CountryID = #DefCountry# 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("DefState")>
	<cfif ToggleDef Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE States SET 
			DefState = 0
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE States SET 
			DefState = 1 
			WHERE StateID = #DefState# 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("OSVersionID")>
	<cfif ToggleDef Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE OSVersion SET 
			DefOS = 0
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE OSVersion SET 
			DefOS = 1 
			WHERE OSVersionID = #OSVersionID# 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MSpeedID")>
	<cfif ToggleDef Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE ModemSpeeds SET 
			DefSpeed = 0
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE ModemSpeeds SET 
			DefSpeed = 1 
			WHERE MSpeedID = #MspeedID# 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("DelSelected.x") AND IsDefined("DelThese")>
	<cfif tab Is 1>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM ModemSpeeds 
			WHERE MSpeedID In (#DelThese#) 
		</cfquery>
	<cfelseif tab Is 2>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM OSVersion 
			WHERE OSVersionID In (#DelThese#)
		</cfquery>
	<cfelseif tab Is 3>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM States 
			WHERE StateID In (#DelThese#)
		</cfquery>
	<cfelseif tab Is 4>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM PayTypes 
			WHERE UseTab = #tab2# 
			AND PayTypeID In (#DelThese#)
		</cfquery>
	<cfelseif tab Is 5>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM Countries 
			WHERE CountryID In (#DelThese#) 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdStates.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("StateID#B5#")>
		<cfset var2 = Evaluate("StateName#B5#")>
		<cfset var3 = Evaluate("Abbr#B5#")>
		<cfset var4 = Evaluate("StateYN#B5#")>
		<cfif IsDefined("ActiveYN#B5#")>
			<cfset var5 = 1>
		<cfelse>
			<cfset var5 = 0>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE States SET 
			StateName = '#var2#', 
			Abbr = '#var3#', 
			StateYN = #var4#, 
			ActiveYN = #var5# 
			WHERE StateID = #var1#
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdOSV.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("OSVersionID#B5#")>
		<cfset var2 = Evaluate("OSV#B5#")>
		<cfif IsDefined("AccountYN#B5#")>
			<cfset var3 = 1>
		<cfelse>
			<cfset var3 = 0>
		</cfif>
		<cfif IsDefined("OnlineYN#B5#")>
			<cfset var4 = 1>
		<cfelse>
			<cfset var4 = 0>
		</cfif>
		<cfset var5 = Evaluate("SortOrder#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE OSVersion SET 
			OSV = '#var2#', 
			AccountYN = #var3#, 
			OnlineYN = #var4#, 
			SortOrder = #var5# 
			WHERE OSVersionID = #var1# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdData.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("MSpeedid#B5#")>
		<cfset var2 = Evaluate("ModemSpeed#B5#")>
		<cfif IsDefined("AccountYN#B5#")>
			<cfset var3 = 1>
		<cfelse>
			<cfset var3 = 0>
		</cfif>
		<cfif IsDefined("OnlineYN#B5#")>
			<cfset var4 = 1>
		<cfelse>
			<cfset var4 = 0>
		</cfif>
		<cfset var5 = Evaluate("SortOrder#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE ModemSpeeds SET 
			ModemSpeed = '#var2#', 
			AccountYN = #var3#, 
			OnlineYN = #var4#, 
			SortOrder = #var5# 
			WHERE MSpeedID = #var1# 
		</cfquery>
	</cfloop>
</cfif>
<cfparam name="tab" default="1">
<cfif tab Is 1>
	<cfset HowWide = 6>
	<cfquery name="AllModemSpeeds" datasource="#pds#">
		SELECT * 
		FROM modemspeeds
		ORDER BY SortOrder
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 6>
	<cfquery name="AllOS" datasource="#pds#">
		SELECT * 
		FROM OSVersion
		ORDER BY SortOrder 
	</cfquery>
<cfelseif tab Is 3>
	<cfset HowWide = 6>
	<cfparam name="Page" default="1">
	<cfquery name="AllStateProvs" datasource="#pds#">
		SELECT * 
		FROM States 
		ORDER BY StateName
	</cfquery>
	<cfif Page Is 0>
		<cfset mrow = AllStateProvs.RecordCount>
		<cfset page = 1>
	</cfif>
	<cfset PageNumber = Ceiling(AllStateProvs.RecordCount/mrow)>
	<cfset Srow = (Page*mrow) - (mrow-1)>
<cfelseif tab Is 4>
	<cfset HowWide = 9>
	<cfparam name="tab2" default="4">
		<cfquery name="GetData" datasource="#pds#">
			SELECT * 
			FROM PayTypes 
			WHERE UseTab = #tab2# 
			ORDER BY ActiveYN desc, SortOrder
		</cfquery>
<cfelseif tab Is 5>
	<cfset HowWide = 5>
	<cfparam name="Page" default="1">
	<cfquery name="AllCountries" datasource="#pds#">
		SELECT * 
		FROM Countries 
		WHERE ActiveYN = 1 
		ORDER BY Country
	</cfquery>
	<cfif Page Is 0>
		<cfset mrow = AllCountries.RecordCount>
		<cfset page = 1>
	</cfif>
	<cfset PageNumber = Ceiling(AllCountries.RecordCount/mrow)>
	<cfset Srow = (Page*mrow) - (mrow-1)>
<cfelseif tab Is 20>
	<cfset HowWide = 2>
<cfelseif tab Is 21>
	<cfset HowWide = 2>
<cfelseif tab Is 22>
	<cfset HowWide = 2>
<cfelseif tab Is 23>
	<cfset HowWide = 2>
<cfelseif tab Is 24>
	<cfset HowWide = 2>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Wizard Info Setup</title>
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab gte 20>
	<form method="post" action="wizsetup.cfm">
		<cfset returntab = tab - 19>
		<cfoutput>
		<input type="hidden" name="tab" value="#returntab#">
		<cfif IsDefined("tab2")>
			<input type="hidden" name="tab2" value="#tab2#">
		</cfif>
		</cfoutput>
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#" size="#ttsize#">Wizard Info Setup</font></th>
	</tr>
	<cfif tab lt 20>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="wizsetup.cfm">
							<td bgcolor=<cfif tab is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab Is 1>checked</cfif> type="radio" name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Modem Speeds</label></td>
							<td bgcolor=<cfif tab is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab Is 2>checked</cfif> type="radio" name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Op Sys Version</label></td>
							<td bgcolor=<cfif tab is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab Is 3>checked</cfif> type="radio" name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">State/Provs</label></td>
							<td bgcolor=<cfif tab is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab Is 5>checked</cfif> type="radio" name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">Countries</label></td>
							<td bgcolor=<cfif tab is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab Is 4>checked</cfif> type="radio" name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Pay Types</label></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
		<cfif tab Is 4>
			<tr>
				<th colspan="#HowWide#">
					<table border="1">
						<tr>
							<form method="post" action="wizsetup.cfm">
								<input type="hidden" name="tab" value="#tab#">
								<td bgcolor=<cfif tab2 Is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab2 Is 4>checked</cfif> type="radio" name="tab2" value="4" onclick="submit()" id="tabA1"><label for="tabA1">Check/ Cash</label></td>
								<td bgcolor=<cfif tab2 Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab2 Is 1>checked</cfif> type="radio" name="tab2" value="1" onclick="submit()" id="tabA2"><label for="tabA2">Check Debit</label></td>
								<td bgcolor=<cfif tab2 Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab2 Is 2>checked</cfif> type="radio" name="tab2" value="2" onclick="submit()" id="tabA3"><label for="tabA3">Credit Card</td>
								<td bgcolor=<cfif tab2 Is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input <cfif tab2 Is 3>checked</cfif> type="radio" name="tab2" value="3" onclick="submit()" id="tabA4"><label for="tabA4">PO</td>
							</form>
						</tr>
					</table>
				</th>
			</tr>
		</cfif>
	</cfif>
</cfoutput>
<cfif tab Is 1>
	<cfoutput>
		<tr>
			<form method="post" action="wizsetup.cfm">
				<input type="hidden" name="tab" value="20">
				<td align="right" colspan="6"><input type="image" src="images/addnew.gif" name="addnew" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Default</th>
			<th>Speed</th>
			<th>AW</th>
			<th>OS</th>
			<th>Sort</th>
			<th>Delete</th>
		</tr>
		<form method="post" name="EditInfo" action="wizsetup.cfm">
			<input type="hidden" name="ToggleDef" value="0">
			<input type="hidden" name="tab" value="#tab#">
			<cfset counter1 = 0>
	</cfoutput>	
			<cfloop query="AllModemSpeeds">
				<cfoutput>
					<cfset counter1 = counter1 + 1>
					<tr bgcolor="#tdclr#">
						<th><input type="radio" <cfif DefSpeed Is 1>checked</cfif> name="MSpeedID" value="#MSpeedID#" onClick="document.EditInfo.ToggleDef.value=1;submit()"><input type="hidden" name="MSpeedID#counter1#" value="#MSpeedID#"></th>
						<td><input type="text" name="ModemSpeed#counter1#" value="#ModemSpeed#" size="20" maxlength="20"></td>
						<th><input type="checkbox" <cfif AccountYN Is 1>checked</cfif> name="AccountYN#counter1#" value="1"></th>
						<th><input type="checkbox" <cfif OnlineYN Is 1>checked</cfif> name="OnlineYN#counter1#" value="1"></th>
						<td><select name="SortOrder#counter1#">
				</cfoutput>
							<cfloop index="B5" from="1" to="#AllModemSpeeds.RecordCount#">
								<cfoutput><option <cfif SortOrder Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
							</cfloop>
						</select></td>
				<cfoutput>
						<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#MSpeedID#" onClick="SetValues(#MSpeedID#,this)"></th>
				</cfoutput>
					</tr>
			</cfloop>
			<cfoutput>
				<input type="hidden" name="LoopCount" value="#counter1#">
			</cfoutput>
			<tr>
				<th colspan="6">
					<table border="0">
						<tr>
							<td><input type="image" src="images/update.gif" border="0" name="UpdData"></td>
		</form>
		<form method="post" name="PickDelete" action="wizsetup.cfm">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
							<td><input type="image" src="images/delete.gif" border="0" name="DelSelected"></td>
						</tr>
					</table>
				</th>
			</tr>
		</form>
<cfelseif tab Is 2>
	<cfoutput>
		<tr>
			<form method="post" action="wizsetup.cfm">
				<input type="hidden" name="tab" value="21">
				<td align="right" colspan="6"><input type="image" src="images/addnew.gif" name="addnew" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Default</th>
			<th>Operating System</th>
			<th>AW</th>
			<th>OS</th>
			<th>Sort</th>
			<th>Delete</th>
		</tr>
		<form method="post" name="EditInfo" action="wizsetup.cfm">
			<input type="hidden" name="ToggleDef" value="0">
			<input type="hidden" name="tab" value="#tab#">
	</cfoutput>
			<cfset counter1 = 0>
			<cfloop query="AllOS">
				<cfoutput>
					<cfset counter1 = counter1 + 1>
					<tr bgcolor="#tdclr#">
						<th><input type="radio" <cfif DefOS Is 1>checked</cfif> name="OSVersionID" value="#OSVersionID#" onClick="document.EditInfo.ToggleDef.value=1;submit()"><input type="hidden" name="OSVersionID#counter1#" value="#OSVersionID#"></th>
						<td><input type="text" name="OSV#counter1#" value="#OSV#" size="20" maxlength="20"></td>
						<th><input type="checkbox" <cfif AccountYN Is 1>checked</cfif> name="AccountYN#counter1#" value="1"></th>
						<th><input type="checkbox" <cfif OnlineYN Is 1>checked</cfif> name="OnlineYN#counter1#" value="1"></th>
						<td><select name="SortOrder#counter1#">
				</cfoutput>
							<cfloop index="B5" from="1" to="#AllOS.RecordCount#">
								<cfoutput><option <cfif SortOrder Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
							</cfloop>
						</select></td>
				<cfoutput>
						<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#OSVersionID#" onClick="SetValues(#OSVersionID#,this)"></th>
				</cfoutput>
					</tr>
			</cfloop>
			<cfoutput>
				<input type="hidden" name="LoopCount" value="#counter1#">
			</cfoutput>
			<tr>
				<th colspan="6">
					<table border="0">
						<tr>
							<td><input type="image" src="images/update.gif" border="0" name="UpdOSV"></td>
		</form>
		<form method="post" name="PickDelete" action="wizsetup.cfm">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
							<td><input type="image" src="images/delete.gif" border="0" name="DelSelected"></td>
						</tr>
					</table>
				</th>
			</tr>
		</form>	
<cfelseif tab Is 3>
	<cfif AllStateProvs.RecordCount GT mrow>
		<cfoutput>
			<tr>
				<form name="PageSelect" method="post" action="wizsetup.cfm">
					<input type="hidden" name="tab" value="3">
		</cfoutput>
				<td colspan="6"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * mrow)-(mrow -1)>
						<cfset DispStr = AllStateProvs.Statename[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option value="0">View All
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfoutput>
		<tr>
			<form name="AddNew" method="post" action="wizsetup.cfm">
				<input type="hidden" name="tab" value="22">
				<td align="right" colspan="6"><input type="image" src="images/addnew.gif" name="addnew" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Active</th>
			<th>Default</th>
			<th>State/Prov</th>
			<th>Abbr</th>
			<th>Type</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfset counter1 = 0>
	<form method="post" name="EditInfo" action="wizsetup.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="#tab#">
		</cfoutput>
		<input type="hidden" name="ToggleDef" value="0">
		<cfoutput query="AllStateProvs" startrow="#srow#" maxrows="#mrow#">
			<cfset counter1 = counter1 + 1>
			<tr bgcolor="#tdclr#">
				<th><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#counter1#" value="1"><input type="hidden" name="StateID#counter1#" value="#StateID#"></th>
				<th><input type="radio" <cfif DefState Is 1>checked</cfif> name="DefState" value="#StateID#" onClick="document.EditInfo.ToggleDef.value=1;submit()"></th>
				<td><input type="text" name="StateName#counter1#" value="#StateName#" maxlength="50"><input type="hidden" name="StateName#counter1#_required" value="Please enter all of the names for the State/Provs."></tD>
				<td><input type="text" name="Abbr#counter1#" value="#Abbr#" maxlength="2" size="3"><input type="hidden" name="Abbr#counter1#_Required" value="Please enter a two letter abbreviation for every State/Provs."></td>
				<td><select name="StateYN#counter1#">
					<option <cfif StateYN Is 1>selected</cfif> value="1">State
					<option <cfif StateYN Is 0>selected</cfif> value="0">Other
				</select></td>
				<th><input type="checkbox" name="DelSelected" value="#StateID#" onClick="SetValues(#StateID#,this)"></th>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#counter1#">
		</cfoutput>
		<tr>
			<th colspan="6">
				<table border="0">
					<tr>
						<td><input type="image" src="images/update.gif" border="0" name="UpdStates"></td>
	</form>
	<form method="post" name="PickDelete" action="wizsetup.cfm">
						<input type="hidden" name="DelThese" value="0">
						<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
						<td><input type="image" src="images/delete.gif" border="0" name="DelSelected"></td>
					</tr>
				</table>
			</th>
		</tr>
	</form>	
	<cfif AllStateProvs.RecordCount GT mrow>
		<cfoutput>
			<tr>
				<form name="PageSelect2" method="post" action="wizsetup.cfm">
					<input type="hidden" name="tab" value="3">
		</cfoutput>
				<td colspan="6"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * mrow)-(mrow -1)>
						<cfset DispStr = AllStateProvs.Statename[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option value="0">View All
				</select></td>
			</form>
		</tr>
	</cfif>
<cfelseif tab Is 4>
		<form method="post" name="AddNew" action="wizsetup.cfm">
			<tr>
				<input type="hidden" name="tab" value="23">
				<cfoutput>
				<input type="hidden" name="tab2" value="#tab2#">
				<td align="right" colspan="#HowWide#"><input type="image" name="New" src="images/addnew.gif" border="0"></td>
				</cfoutput>
			</tr>
		</form>
		<form method="post" name="EditInfo" action="wizsetup.cfm">
			<cfoutput>
				<input type="hidden" name="tab" value="#tab#">
				<input type="hidden" name="tab2" value="#tab2#">
				<tr bgcolor="#thclr#">
					<th>Active</th>
					<th>FieldName</th>
					<th>Prompt</th>
					<th>Data Type</th>
					<th>Size</th>
					<th>Max Size</th>
					<th>Required</th>
					<th>Sort</th>
					<th>Delete</th>
				</tr>
			</cfoutput>
			<cfset counter1 = 0>
			<cfset delcount = 0>
			<cfloop query="GetData">
				<cfset counter1 = counter1 + 1>
				<cfoutput>
					<tr bgcolor="#tdclr#">
						<th><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#counter1#" value="#PayTypeID#"><input type="hidden" name="PayTypeID#counter1#" value="#PayTypeID#"></th>
						<cfif CFVarYN Is 1>
							<td align="right" bgcolor="#tbclr#">#FieldName#</td>
						<cfelse>
							<td align="right" bgcolor="#tbclr#"><input type="text" name="FieldName#counter1#" value="#FieldName#" maxlength="45" size="15"></td>
						</cfif>
						<td bgcolor="#tdclr#"><input type="text" name="PromptStr#counter1#" value="#PromptStr#" size="20" maxlength="100"></td>
				</cfoutput>
						<td><cfoutput><select name="DataType#counter1#"></cfoutput>
							<cfloop index="B4" list="Date,Number,Text">
								<cfoutput><option <cfif DataType Is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
							</cfloop>
						</select></td>
						<cfoutput>
							<td><input type="text" name="FieldSize#counter1#" value="#FieldSize#" size="3"></td>
							<td><input type="text" name="InputMaxSize#counter1#" value="#InputMaxSize#" size="3"></td>
						</cfoutput>
						<cfoutput><th><input type="checkbox" <cfif RequiredYN Is 1>checked</cfif> name="RequiredYN#counter1#" value="#PayTypeID#"></th></cfoutput>
						<td><cfoutput><select name="SortOrder#counter1#"></cfoutput>
							<cfloop index="B5" from="1" to="#GetData.RecordCOunt#">
								<cfoutput><option <cfif SortOrder Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
							</cfloop>
							<cfif ActiveYN Is 0>
								<option <cfif SortOrder Is 0>selected</cfif> value="0">NA
							</cfif>
						</select></td>
						<cfoutput>
							<td><cfif CFVarYN Is 0><cfset delcount = delcount + 1><input type="checkbox" name="DelSelected" value="#PayTypeID#" onClick="SetValues(#PayTypeID#,this)"><cfelse>&nbsp;</cfif></td>
						</cfoutput>
					</tr>
			</cfloop>
			<tr>
				<cfoutput>
				<input type="hidden" name="LoopCount" value="#delcount#">
				<input type="hidden" name="RecCount" value="#counter1#">
				<th colspan="#HowWide#">
				</cfoutput>
					<table border="0">
						<tr>
							<td><input type="image" src="images/update.gif" border="0" name="UpdCheckDebit"></td>
		</form>
		<form method="post" name="PickDelete" action="wizsetup.cfm">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput>
							<input type="hidden" name="tab" value="#tab#">
							<input type="hidden" name="tab2" value="#tab2#">
							</cfoutput>
							<td><input type="image" src="images/delete.gif" border="0" name="DelSelected"></td>
						</tr>
					</table>
				</th>
			</tr>
		</form>
<cfelseif tab Is 5>
	<cfif AllCountries.RecordCount GT mrow>
		<cfoutput>
			<tr>
				<form name="PageSelect" method="post" action="wizsetup.cfm">
					<input type="hidden" name="tab" value="5">
		</cfoutput>
				<td colspan="6"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * mrow)-(mrow -1)>
						<cfset DispStr = AllCountries.Country[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option value="0">View All
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfoutput>
		<tr>
			<form name="AddNew" method="post" action="wizsetup.cfm">
				<input type="hidden" name="tab" value="24">
				<td align="right" colspan="6"><input type="image" src="images/addnew.gif" name="addnew" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Active</th>
			<th>Default</th>
			<th>Country</th>
			<th>Abbr</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfset counter1 = 0>
	<form method="post" name="EditInfo" action="wizsetup.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="#tab#">
		</cfoutput>
		<input type="hidden" name="ToggleDef" value="0">
		<cfoutput query="AllCountries" startrow="#srow#" maxrows="#mrow#">
			<cfset counter1 = counter1 + 1>
			<tr bgcolor="#tdclr#">
				<th><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#counter1#" value="1"><input type="hidden" name="CountryID#counter1#" value="#CountryID#"></th>
				<th><input type="radio" <cfif DefCountry Is 1>checked</cfif> name="DefCountry" value="#CountryID#" onClick="document.EditInfo.ToggleDef.value=1;submit()"></th>
				<td><input type="text" name="Country#counter1#" value="#Country#" maxlength="50" size="35"><input type="hidden" name="Country#counter1#_required" value="Please enter all of the names for the Countries."></tD>
				<td><input type="text" name="CountryAbbr#counter1#" value="#CountryAbbr#" maxlength="5" size="5"><input type="hidden" name="CountryAbbr#counter1#_Required" value="Please enter an abbreviation for each Country."></td>
				<th><input type="checkbox" name="DelSelected" value="#CountryID#" onClick="SetValues(#CountryID#,this)"></th>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#counter1#">
		</cfoutput>
		<tr>
			<th colspan="6">
				<table border="0">
					<tr>
						<td><input type="image" src="images/update.gif" border="0" name="UpdStates"></td>
	</form>
	<form method="post" name="PickDelete" action="wizsetup.cfm">
						<input type="hidden" name="DelThese" value="0">
						<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
						<td><input type="image" src="images/delete.gif" border="0" name="DelSelected"></td>
					</tr>
				</table>
			</th>
		</tr>
	</form>	
	<cfif AllCountries.RecordCount GT mrow>
		<cfoutput>
			<tr>
				<form name="PageSelect2" method="post" action="wizsetup.cfm">
					<input type="hidden" name="tab" value="5">
		</cfoutput>
				<td colspan="6"><select name="Page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * mrow)-(mrow -1)>
						<cfset DispStr = AllCountries.Country[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<option value="0">View All
				</select></td>
			</form>
		</tr>
	</cfif>
<cfelseif tab Is 20>
	<cfoutput>
		<form method="post" action="wizsetup.cfm">
			<tr>
				<td align="right" bgcolor="#tbclr#">Modem Speed</td>
				<td bgcolor="#tdclr#"><input type="text" name="ModemSpeed" size="10" maxlength="20"></td>
				<input type="hidden" name="ModemSpeed_required" value="Please enter the display for the modem speed dropdown.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Account Wizard Use</td>
				<td bgcolor="#tdclr#"><input type="radio" name="AccountYN" value="1" checked> Yes <input type="radio" name="AccountYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Online Signup Use</td>
				<td bgcolor="#tdclr#"><input type="radio" name="OnlineYN" value="1" checked> Yes <input type="radio" name="OnlineYN" value="0"> No</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewSpeed" border="0"></th>
			</tr>
		</form>
	</cfoutput>
<cfelseif tab Is 21>
	<cfoutput>
		<form method="post" action="wizsetup.cfm">
			<input type="hidden" name="tab" value="2">
			<tr>
				<td align="right" bgcolor="#tbclr#">Operating System</td>
				<td bgcolor="#tdclr#"><input type="text" name="OSV" size="20" maxlength="20"></td>
				<input type="hidden" name="OSV_required" value="Please enter the display for the os version dropdown.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Account Wizard Use</td>
				<td bgcolor="#tdclr#"><input type="radio" name="AccountYN" value="1" checked> Yes <input type="radio" name="AccountYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Online Signup Use</td>
				<td bgcolor="#tdclr#"><input type="radio" name="OnlineYN" value="1" checked> Yes <input type="radio" name="OnlineYN" value="0"> No</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewOSV" border="0"></th>
			</tr>
		</form>
	</cfoutput>
<cfelseif tab Is 22>
	<cfoutput>
		<form method="post" action="wizsetup.cfm">
			<input type="hidden" name="tab" value="3">
			<tr>
				<td align="right" bgcolor="#tbclr#">State/Prov</td>
				<td bgcolor="#tdclr#"><input type="text" name="Statename" size="20" maxlength="50"></td>
				<input type="hidden" name="Statename_required" value="Please enter the State or prov name.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">2 letter abbreviation</td>
				<td bgcolor="#tdclr#"><input type="text" name="Abbr" maxlength="2" size="3"></td>
				<input type="hidden" name="Abbr_Required" value="Please enter a two letter abbreviation.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">State</td>
				<td bgcolor="#tdclr#"><input type="radio" name="StateYN" value="1" checked> Yes <input type="radio" name="StateYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Active</td>
				<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN" value="1" checked> Yes <input type="radio" name="ActiveYN" value="0"> No</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewState" border="0"></th>
			</tr>
		</form>
	</cfoutput>
<cfelseif tab Is 23>
	<cfoutput>
		<form method="post" action="wizsetup.cfm">
			<input type="hidden" name="tab" value="4">
			<input type="hidden" name="tab2" value="#tab2#">
			<tr>
				<td align="right" bgcolor="#tbclr#">Active</td>
				<td bgcolor="#tdclr#"><input checked type="radio" name="ActiveYN" value="1"> Yes <input type="radio" name="ActiveYN" value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Database Field Name</td>
				<td bgcolor="#tdclr#"><input type="text" name="FieldName" size="25" maxlength="45"></td>
				<input type="hidden" name="FieldName_Required" value="Please enter the database field name">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Prompt</td>
				<td bgcolor="#tdclr#"><input type="text" name="PromptStr" size="25" maxlength="100"></td>
				<input type="hidden" name="PromptStr_Required" value="Please enter the Prompt for this data input">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Data Type</td>
				<td bgcolor="#tdclr#"><select name="DataType">
					<option value="Date">Date
					<option value="Number">Number
					<option selected value="Text">Text
				</select></td>
				<input type="hidden" name="DataType_Required" value="Please enter the type for this data input">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Data Length</td>
				<td bgcolor="#tdclr#"><input type="text" name="FieldSize" size="5" maxlength="3"></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Max Length<br>
				<font size="1">Leave blank for no maximum.</font></td>
				<td bgcolor="#tdclr#"><input type="text" name="InputMaxSize" size="5" maxlength="3"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Required</td>
				<td bgcolor="#tdclr#"><input checked type="radio" name="RequiredYN" value="1"> Yes <input type="radio" name="RequiredYN" value="0"> No</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" name="AddCheckDebit" src="images/edit.gif" border="0"></th>
			</tr>
	</cfoutput>
<cfelseif tab Is 24>
	<cfoutput>
		<form method="post" action="wizsetup.cfm">
			<input type="hidden" name="tab" value="5">
			<tr>
				<td align="right" bgcolor="#tbclr#">Country</td>
				<td bgcolor="#tdclr#"><input type="text" name="Country" size="20" maxlength="50"></td>
				<input type="hidden" name="Country_required" value="Please enter the Country name.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Abbreviation</td>
				<td bgcolor="#tdclr#"><input type="text" name="CountryAbbr" maxlength="5" size="5"></td>
				<input type="hidden" name="CountryAbbr_Required" value="Please enter an abbreviation.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Active</td>
				<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN" value="1" checked> Yes <input type="radio" name="ActiveYN" value="0"> No</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewCountry" border="0"></th>
			</tr>
		</form>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>







