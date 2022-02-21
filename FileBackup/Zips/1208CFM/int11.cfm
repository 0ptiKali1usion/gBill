<!-- Version 3.5.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int11.cfm -->

<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="3" bgcolor="#thclr#">Plan Selection</td>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Available</th>
			<th>Action</th>
			<th>Run Script With These Plans</th>
		</tr>
		<tr bgcolor="#tdclr#">
</cfoutput>
			<td><select name="ChoosePlans" multiple size="10">
				<cfoutput query="GetSelectable">
					<option value="#PlanID#">#PlanDesc#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
			<td align="center" valign="middle">
			<input type="submit" name="mvrt" value="---->"><br>
			<input type="submit" name="mvlt" value="<----"><br>
			</td>
			<td><select name="HavePlans" multiple size="10">
				<cfoutput query="GetAvailPlans">
					<option value="#PlanID#">#PlanDesc#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
		</tr>
	</form>
</table>

<!-- /int11.cfm -->








