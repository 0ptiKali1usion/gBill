<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!-- int13.cfm -->

<cfsetting enablecfoutputonly="no">
<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr bgcolor="#thclr#">
			<th>Staff Available</th>
			<th>Action</th>
			<th>Selected Staff</th>
		</tr>
		<tr bgcolor="#tdclr#">
</cfoutput>
			<td><select name="ChooseLetters" multiple size="10">
				<cfoutput query="GetSelectable">
					<option value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="0">__________________________________
			</select></td>
			<td align="center" valign="middle">
			<input type="submit" name="mvrtlet" value="---->"><br>
			<input type="submit" name="mvltlet" value="<----"><br>
			</td>
			<td><select name="HaveLocs" multiple size="10">
				<cfoutput query="GetAvailLetters">
					<option value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="0">__________________________________
			</select></td>
		</tr>
	</form>
</table>
  
