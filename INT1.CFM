<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the General Tab for the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!--- int1.cfm --->
<cfparam name="IntTypeSetup" default="Auth">
<cfsetting enablecfoutputonly="no">
<table border="0">
	<form method="post" action="integration2.cfm">
		<cfoutput>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Active</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="radio" <cfif OneScript.ActiveYN Is "1">checked<cfelseif IntID Is "0">checked</cfif> name="ActiveYN" value="1"> Yes <input type="radio" <cfif OneScript.ActiveYN Is "0">checked</cfif> name="ActiveYN" value="0"> No</td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">Descripton</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="text" name="IntDesc" maxlength="100" size="35" value="#OneScript.IntDesc#"></td>
				<input type="hidden" name="IntDesc_required" value="Please enter a short description for this script.">
			</tr>
		</cfoutput>
		<cfif IntTypeSetup Is "Letter">
			<input type="hidden" name="Action" value="Letter">
			<input type="hidden" name="TypeID" value="7">
		<cfelse>
			<cfoutput>
			<tr valign="top" bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Action</td>
			</cfoutput>
					<td><select name="Action">
					<option <cfif OneScript.Action Is "Create">Selected</cfif> value="Create">Create
					<option <cfif OneScript.Action Is "Delete">Selected</cfif> value="Delete">Delete
					<option <cfif OneScript.Action Is "Change">Selected</cfif> value="Change">Change
				</select></td>
				<cfoutput>
				<td bgcolor="#tbclr#" align="right">Type</td>
				</cfoutput>
				<td><select name="TypeID">
					<cfoutput query="AllTypes">
						<option <cfif OneScript.TypeID Is "#TypeID#">Selected</cfif> value="#TypeID#">#TypeStr#
					</cfoutput>
				</select></td>
			</tr>
		</cfif>
		<cfoutput>
			<tr valign="top">
				<cfif IntID Is "0">
					<th colspan="4"><input type="image" name="AddNewScript" src="images/addnew.gif" border="0"></th>
				<cfelse>
					<input type="hidden" name="IntID" value="#IntID#">
					<th colspan="4"><input type="image" name="EditScript" src="images/update.gif" border="0"></th>
				</cfif>
			</tr>
		</cfoutput>
	</form>
</table>
 