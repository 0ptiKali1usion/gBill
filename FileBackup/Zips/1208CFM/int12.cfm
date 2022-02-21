<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that lists all of the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!--- int12.cfm --->

<cfsetting enablecfoutputonly="no">
<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="3" bgcolor="#thclr#">Location Selection</td>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Available</th>
			<th>Action</th>
			<th>Run Script At These Locations</th>
		</tr>
		<tr bgcolor="#tdclr#">
</cfoutput>
			<td><select name="ChooseLocs" multiple size="10">
				<cfoutput query="GetSelectable">
					<option value="#LocationID#">#PageDesc# - #PageName#
				</cfoutput>
				<option value="0">__________________________________
			</select></td>
			<td align="center" valign="middle">
			<input type="submit" name="mvrtloc" value="---->"><br>
			<input type="submit" name="mvltloc" value="<----"><br>
			</td>
			<td><select name="HaveLocs" multiple size="10">
				<cfoutput query="GetAvailLocs">
					<option value="#LocationID#">#PageDesc# - #PageName#
				</cfoutput>
				<option value="0">__________________________________
			</select></td>
		</tr>
	</form>
</table>
  