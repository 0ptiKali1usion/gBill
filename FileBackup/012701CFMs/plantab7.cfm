<!-- Version 4.0.0 -->
<!--- This page is for selecting which pops have access to a plan.
--->
<!---	4.0.0 07/17/99 --->
<!-- plantab7.cfm -->

<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
	<tr bgcolor="#thclr#">
		<th>Scripts</th>
		<th>Action</th>
		<th>Selected Scripts</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select name="WantIn" multiple size="10">
			<cfoutput query="AllScripts">
				<option value="#IntID#">#IntDesc#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle">
			<input type="submit" name="MvRt7" value="---->"><br>
			<input type="submit" name="MvLt7" value="<----"><br>
		</td>
		<td><select name="HaveIt" multiple size="10">
			<cfoutput query="GetSelScripts">
				<option value="#IntID#">#IntDesc#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
</form>




