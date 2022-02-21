<!-- Version 4.0.0 -->
<!--- This page is for selecting which pops have access to a plan.
--->
<!---	4.0.0 07/17/99
		3.2.0 09/08/98
		3.1.0 08/10/98 --->
<!-- plantab6.cfm -->
<cfoutput>
<form method="post" action="listplan2.cfm">
<input type="hidden" name="tab" value="#tab#">
<input type="hidden" name="page" value="#page#">
<input type="hidden" name="obid" value="#obid#">
<input type="hidden" name="obdir" value="#obdir#">
<input type="hidden" name="planid" value="#planid#">
<tr bgcolor="#thclr#">
	<th>POPs List</th>
	<th>Action</th>
	<th>Selected POPs</th>
</tr>
<tr bgcolor="#tdclr#">
</cfoutput>
	<td><select multiple size="10" name="WantIt">
		<cfoutput query="getwhowants">
			<option value="#POPID#">#POPName#
		</cfoutput>
		<option value="0">_____________________________
	</select></td>
	<td align="center" valign="middle">
		<input type="submit" name="MvRt6" value="---->"><br>
		<input type="submit" name="MvLt6" value="<----"><br>
	</td>
	<td><select multiple size="10" name="HaveIt">
		<cfoutput query="getwhohas">
			<option value="#POPID#">#POPName#
		</cfoutput>
		<option value="0">_____________________________
	</select></th>
</tr>
</form>




