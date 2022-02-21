<!-- Version 4.0.0 -->
<!--- This is the Admin tab for the plans setup.--->
<!--- 4.0.0
		3.2.0 09/08/98 --->
<!-- plantab5.cfm -->

<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
	<tr bgcolor="#thclr#">
		<th>Staff List</th>
		<th>Action</th>
		<th>Selected Staff</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select multiple size="10" name="wantit">
			<cfoutput query="GetWhoWants">
				<option value="#AdminID#">#LastName#, #FirstName#
			</cfoutput>
			<option value="0">_____________________________
		</select></td>
		<td align="center" valign="middle">
			<input type="submit" name="MvRt5" value="---->"><br>
			<input type="submit" name="MvLt5" value="<----"><br>
		</td>
		<td><select multiple size="10" name="haveit">
			<cfoutput query="GetWhoHas">
				<option value="#AdminID#">#LastName#, #FirstName#
			</cfoutput>
			<option value="0">_____________________________
		</select></td>
	</tr>
</form>


