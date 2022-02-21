<!--- Version 4.0.0 --->
<!--- This is the Plans tab for pops setup. --->
<!---	4.0.0 07/24/99
		3.2.1 09/09/98 Removed Deactivate and Cancel From The Select Plans Tab
		3.2.0 09/08/98 --->
<!--- popstab4.cfm --->

<cfoutput>
<form method="post" action="pops2.cfm">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="POPID" value="#POPID#">
	<input type="hidden" name="tab" value="#tab#">
	<tr bgcolor="#thclr#">
		<th>Plans List</th>
		<th>Action</th>
		<th>Selected Plans</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select multiple size="10" name="WantIt">
			<cfoutput query="GetWhoWants">
				<option value="#PlanID#">#PlanDesc#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle"><input type="submit" name="MvRt4" value="---->"><br>
		<input type="submit" name="MvLt4" value="<----"></td>
		<td><select multiple size="10" name="HaveIt">
			<cfoutput query="GetWhoHas">
				<option value="#PlanID#">#PlanDesc#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
       