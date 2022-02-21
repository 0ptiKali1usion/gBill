<!-- Version 3.5.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int2.cfm -->

<table border="0">
	<form method="post" action="integration2.cfm">
		<cfoutput>
			<input type="hidden" name="Tab" value="#Tab#">
			<input type="hidden" name="Action" value="#OneScript.Action#">
			<tr valign="top">
				<td bgcolor="#thclr#" colspan="4">Custom Variables Query</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">Record Count</td>
				<td bgcolor="#tbclr#" colspan="3"><input <cfif OneScript.SQLRecordCount Is Not "0">checked</cfif> type="radio" name="SQLRecordCount" value="1"> One Record <input <cfif OneScript.SQLRecordCount Is "0">checked</cfif> type="radio" name="SQLRecordCount" value="0"> Multiple Records</td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Datasource</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="text" name="CustomDS" value="#OneScript.CustomDS#" maxlength="75" size="50"></td>
			</tr>
		</cfoutput>
			<cfset LocCustomSQL = OneScript.CustomSQL>
			<cfif Trim(LocCustomSQL) Is "">
				<cfset LocFieldList = "">
			<cfelse>
				<cfset Pos1 = FindNoCase("SELECT",LocCustomSQL)>
				<cfset Pos2 = FindNoCase("FROM",LocCustomSQL)> 
				<cfset Pos3 = FindNoCase("WHERE",LocCustomSQL)>
				<cfset Pos4 = Len(LocCustomSQL)>		
				<cfset Mid1 = Pos2 - Pos1>
				<cfif (Mid1 Is 0) OR (Pos1 Is 0)>
					<cfset LocFieldList = "">
				<cfelse>
					<cfset LocSelect = Mid(LocCustomSQL,Pos1,Mid1)>
					<cfset LocSelect = Trim(ReplaceNoCase(LocSelect,"Select",""))>
					<cfset LocFieldList = "">
					<cfloop index="B5" list="#LocSelect#">
						<cfset LocFieldName = ListGetAt("#B5#","1"," ")>
						<cfset LocFieldList = ListAppend(LocFieldList,LocFieldName)>
					</cfloop>
				</cfif>
			</cfif>
		<cfoutput>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">SELECT</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="text" name="CustomSQLSelect" value="#LocFieldList#" size="50"></td>
			</tr>
			<cfif Trim(LocCustomSQL) Is "">
				<cfset LocFrom = "">
			<cfelse>
				<cfset Mid1 = Pos3 - Pos2>
				<cfset LocFrom = Mid(LocCustomSQL,Pos2,Mid1)>
				<cfset LocFrom = Trim(ReplaceNoCase(LocFrom,"From",""))>
			</cfif>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">FROM</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="text" name="CustomSQLFrom" value="#LocFrom#" size="50"></td>
			</tr>
			<cfif Trim(LocCustomSQL) Is "">
				<cfset LocWhere = "">
			<cfelse>
				<cfset Mid1 = Pos4 - pos3 + 1>
				<cfset LocWhere = Mid(LocCustomSQL,Pos3,Mid1)>
				<cfset LocWhere = Trim(ReplaceNoCase(LocWhere,"Where",""))>
			</cfif>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">WHERE</td>
				<td bgcolor="#tdclr#" colspan="3"><textarea name="CustomSQLWhere" rows="5" cols="50" wrap="virtual">#LocWhere#</textarea></td>
			</tr>
			<tr valign="top">
				<input type="hidden" name="IntID" value="#IntID#">
				<th colspan="4"><input type="image" name="EditCustomVars" src="images/update.gif" border="0"></th>
			</tr>
		</cfoutput>
	</form>
</table>
<!-- /int2.cfm -->












