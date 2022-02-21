<!--- Version 4.0.0 --->
<!--- 4.0.0 08/28/99 --->
<!--- opttab4.cfm --->

<cfoutput>
	<tr>
		<form method="post" action="options.cfm">
			<input type="hidden" name="tab" value="24">
			<th colspan="#HowWide#" align="right"><input type="image" src="images/addnew.gif" name="addrow" border="0"></td>
		</form>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Active</th>
		<th>Type</th>
		<th>AW Use</th>
		<th>OS Use</th>
		<th>Sort Order</th>
		<th>Delete</th>
	</tr>
</cfoutput>
<cfset counter1 = 0>
<cfset DelCount = 0>
<form method="post" name="EditInfo" action="options.cfm">
	<input type="hidden" name="tab" value="4">
	<cfloop query="AllCCTypes">
		<cfoutput>
		<cfset counter1 = counter1 + 1>
		<tr bgcolor="#tdclr#">
			<th><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#counter1#" value="1"></th>
			<input type="hidden" name="CardTypeID#counter1#" value="#CardTypeID#">
			<cfif CFVaryN Is 0>
				<td><input type="text" value="#CardType#" name="CardType#Counter1#" maxlength="25"></td>
			<cfelse>
				<td bgcolor="#tbclr#">#CardType#</td>
			</cfif>
			<th><input type="checkbox" <cfif UseAW Is 1>checked</cfif> name="UseAW#counter1#" value="1"></th>
			<th><input type="checkbox" <cfif UseOS Is 1>checked</cfif> name="UseOS#counter1#" value="1"></th>
		</cfoutput>
		<cfif ActiveYN Is 1>
			<cfoutput><th><select name="SortOrder#Counter1#"></cfoutput>
				<cfloop index="B5" from="1" to="#AllActive.RecordCount#">
					<cfoutput><option <cfif SortOrder Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select></th>
		<cfelse>
			<th>&nbsp;</th>
		</cfif>
		<cfoutput>
			<cfif CFVarYN Is 0>
				<th><cfset DelCount = DelCount + 1><input type="checkbox" name="DelSelected" value="#CardTypeID#" onClick="SetValues(#CardTypeID#,this)"></th>
			<cfelse>
				<th>&nbsp;</th>
			</cfif>
		</cfoutput>	
		</tr>
	</cfloop>
	<cfoutput>
		<input type="hidden" name="LoopCount" value="#counter1#">
		<input type="hidden" name="DelCount" value="#DelCount#">
	<tr>
		<th colspan="#howWide#">
	</cfoutput>
			<table border="0">
				<tr>
					<td><input type="image" src="images/update.gif" name="UpdateCreditCards" border="0"></td>
</form>
<form method="post" name="PickDelete" action="options.cfm" onSubmit="return confirm('Click Ok to confirm deleting the selected Types.')">
					<input type="hidden" name="DelThese" value="0">
					<input type="hidden" name="tab" value="4">
					<td><input type="image" src="images/delete.gif" name="DelTypes" border="0"></td>
				</tr>
			</table>
		</th>
	</tr>
</form>
</table>
     