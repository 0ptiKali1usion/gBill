<!-- Version 3.2.0 -->
<!--- This is the States tab for pops setup. --->
<!--- 3.2.0 09/08/98 --->
<!-- popstab5.cfm -->

<cfoutput>
<form method="post" action="pops2.cfm">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="POPID" value="#POPID#">
	<input type="hidden" name="tab" value="#tab#">
	<tr bgcolor="#thclr#">
		<th>States/Provs List</th>
		<th>Action</th>
		<th>Selected States/Provs</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select multiple size="10" name="WantIt">
			<cfoutput query="GetWhoWants">
				<option value="#StateID#">#StateName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle"><input type="submit" name="MvRt5" value="---->"><br>
		<input type="submit" name="MvLt5" value="<----"></td>
		<td><select multiple size="10" name="HaveIt">
			<cfoutput query="GetWhoHas">
				<option value="#StateID#">#StateName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
       