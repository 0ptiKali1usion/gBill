<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is the page that lists all of the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!--- int4.cfm --->

<cfsetting enablecfoutputonly="No">
<cfoutput>
<table border="0">
	<form method="post" name="clear" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="IntID" value="#IntID#">
		<input type="hidden" name="Tab" value="#Tab#">
		<tr valign="top">
			<td colspan="4" bgcolor="#thclr#">Batch Script <font size="2"><input type="submit" name="ClearDOS" value="Clear Batch Info"></font></th>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="IntID" value="#IntID#">
		<input type="hidden" name="Tab" value="#Tab#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Batch Active</td>
			<td bgcolor="#tdclr#" colspan="3"><input <cfif OneScript.DOSActiveYN Is 1>checked</cfif> type="radio" name="DOSActiveYN" value="1"> Yes <input <cfif OneScript.DOSActiveYN Is 0>checked</cfif> type="radio" name="DOSActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right" rowspan="2">Action</td>
			<td bgcolor="#tdclr#" colspan="3"><select name="DOSAction">
				<option <cfif OneScript.DOSAction Is "Append">selected</cfif> value="Append">Append
				<option <cfif OneScript.DOSAction Is "Copy">selected</cfif> value="Copy">Copy
				<option <cfif OneScript.DOSAction Is "Delete">selected</cfif> value="Delete">Delete
				<option <cfif OneScript.DOSAction Is "Exec">selected</cfif> value="Exec">Execute
				<option <cfif OneScript.DOSAction Is "IPAD">selected</cfif> value="IPAD">IPAD Output
				<option <cfif OneScript.DOSAction Is "Write">selected</cfif> value="Write">Write
			</select></td>
			<input type="hidden" name="DOSAction_Required" value="Please select the file action.">
		</tr>
		<tr>
			<td bgcolor="#tbclr#" colspan="3"><font size="2">If you select 'Execute' the file must have a cmd extension.</font></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">Copy From</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="DosCopyFrom" value="#OneScript.DosCopyFrom#" maxlength="250" size="50"></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#">Output Directory</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="DOSFileDir" value="#OneScript.DOSFileDir#" maxlength="200" size="50"></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">Filename</td>
			<td bgcolor="#tdclr#"><input type="text" name="DOSFileName" value="#onescript.DOSFileName#" maxlength="50"></td>
			<td bgcolor="#tbclr#">Wait</td>
			<td bgcolor="#tdclr#"><input type="text" value="#Onescript.DOSDelay#" name="DOSDelay" maxlength="3" size="4"> minutes before deleting file.</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Script</td>
			<td bgcolor="#tdclr#" colspan="3"><textarea wrap="off" name="DOSScript" rows="6" cols="50">#onescript.DOSScript#</textarea></td>
		</tr>
		<tr valign="top">
			<th colspan="4"><input type="image" name="DOSScriptEdit" src="images/update.gif" border="0"></th>
		</tr>
	</form>
</table>
</cfoutput>
 