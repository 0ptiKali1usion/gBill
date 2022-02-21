<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 01/02/01 --->
<!--- opttab5.cfm --->

<cfsetting enablecfoutputonly="No">
<cfoutput>
	<tr>
		<form method="post" action="options.cfm">
			<input type="hidden" name="tab" value="25">
			<th colspan="#HowWide#" align="right"><input type="image" src="images/addnew.gif" name="addrow" border="0"></td>
		</form>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Customer Support IP Addresses</th>
		<th>Delete</th>
	</tr>
</cfoutput>
<cfset counter1 = 0>
<cfset DelCount = 0>
<form method="post" name="EditInfo" action="options.cfm">
	<input type="hidden" name="tab" value="5">
	<cfloop query="GetCMSetup">
		<cfoutput>
			<cfset counter1 = counter1 + 1>
			<tr bgcolor="#tdclr#">
				<td><input type="text" name="VarName#Counter1#" value="#Value1#"></td>
				<input type="Hidden" name="SetupID#Counter1#" value="#SetupID#">
				<th><cfset DelCount = DelCount + 1><input type="checkbox" name="DelSelected" value="#SetupID#" onClick="SetValues(#SetupID#,this)"></th>
			</tr>
		</cfoutput>	
	</cfloop>
	<cfoutput>
		<input type="hidden" name="LoopCount" value="#counter1#">
		<input type="hidden" name="DelCount" value="#DelCount#">
	<tr>
		<th colspan="#howWide#">
	</cfoutput>
			<table border="0">
				<tr>
					<td><input type="image" src="images/update.gif" name="UpdateIPAddress" border="0"></td>
</form>
<form method="post" name="PickDelete" action="options.cfm" onSubmit="return confirm('Click Ok to confirm deleting the selected IPs.')">
					<input type="hidden" name="DelThese" value="0">
					<input type="hidden" name="tab" value="5">
					<td><input type="image" src="images/delete.gif" name="DelIPs" border="0"></td>
				</tr>
			</table>
		</th>
	</tr>
</form>
</table>
 