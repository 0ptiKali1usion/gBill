<!-- Version 3.2.0 -->
<!--- This is the Admin tab for pops setup. --->
<!--- 3.2.0 09/08/98 --->
<!-- popstab3.cfm -->
<cfoutput>
<form method="post" action="pops2.cfm">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="POPID" value="#POPID#">
	<input type="hidden" name="tab" value="#tab#">
	<tr bgcolor="#thclr#">
		<th>Staff List</th>
		<th>Action</th>
		<th>Selected Staff</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select multiple size="10" name="WantIt">
			<cfoutput query="GetWhoWants">
				<option value="#AdminID#">#LastName#, #FirstName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>	
		<td align="center" valign="middle"><input type="submit" name="MvRt3" value="---->"><br>
		<input type="submit" name="MvLt3" value="<----"><br></td>
		<td><select multiple size="10" name="HaveIt">
			<cfoutput query="GetWhoHas">
				<option value="#AdminID#">#LastName#, #FirstName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
</form>
	        