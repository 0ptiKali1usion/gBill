<!-- Version 3.5.0 -->
<!--- This is URL tab for the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int5.cfm -->
<cfoutput>
	<table border="0">
	<form method="post" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="5" bgcolor="#thclr#">URL Integration <font size="2"><input type="submit" name="ClearURL" value="Clear URL Info"></font></td>
		</tr>
	</form>
	<cfif IsDefined("NewField.x")>
			<tr bgcolor="#thclr#">
				<td align="center" bgcolor="#thclr#" colspan="4">Add A Form Field</td>
			</tr>
			<tr bgcolor="#thclr#">
				<td>Active</td>
				<td>Field Name</td>
				<td>Field Type</td>
				<td>Value</td>
			</tr>
			<tr bgcolor="#tdclr#">
				<form method="post" action="integration2.cfm">
					<input type="hidden" name="IntID" value="#IntID#">
					<input type="hidden" name="Tab" value="#tab#">
					<td><input type="radio" name="ActiveYN" checked value="1"> Yes <input type="radio" name="ActiveYN" value="0"> No</td>
					<td><input type="text" name="FieldName" size="15" maxlength="50"></td>
					<input type="hidden" name="FieldName_Required" value="Please enter the name of the Field">
					<td><select name="FieldType">
						<option value="CGI">CGI
						<option value="Cookie">Cookie
						<option value="File">File
						<option value="FormField">FormField
						<option value="URL">URL
					</select></td>
					<input type="hidden" name="FieldType_Required" value="Please enter the field type.">
					<td><input type="text" name="FieldValue" size="25" maxlength="150"></td>
			</tr>
				<td bgcolor="#tbclr#">File Name</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="text" name="FieldFile" size="55" maxlength="250"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">Add another</td>
				<td bgcolor="#tdclr#" colspan="3"><input type="checkbox" name="NewField.x" value="1"></td>
			</tr>
			<tr>
				<th colspan="4"><input type="image" name="AddFormField" src="images/enter.gif" border="0"></th>
			<tr>
				</form>			
	<cfelseif OneScript.URLMethod Is "Post">
			<tr>
				<form method="post" name="NewField" action="integration2.cfm">
					<input type="hidden" name="IntID" value="#IntID#">
					<input type="hidden" name="Tab" value="#tab#">
					<th colspan="5" align="right"><input type="image" src="images/addnew.gif" name="NewField" border="0"></th>
				</form>
			</tr>
	</cfif>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">URL Active</td>
			<td bgcolor="#tdclr#" colspan="3"><input <cfif OneScript.URLActiveYN Is 1>checked</cfif> type="radio" name="URLActiveYN" value="1"> Yes <input <cfif OneScript.URLActiveYN Is 0>checked</cfif> type="radio" name="URLActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>URL</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="URLInfo" size="60" value="#OneScript.URLInfo#"></td>
			<input type=hidden name="URLInfo_Required" value="You must supply a URL to connect to.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Method</td>
			<td bgcolor="#tdclr#"><select name="URLMethod">
				<option <cfif OneScript.URLMethod Is "Get">selected</cfif> value="Get">Get
				<option <cfif OneScript.URLMethod Is "Post">selected</cfif> value="Post">Post
			</select></td>
			<input type="hidden" name="URLMethod_Required" value="Please select the URL Method">
			<td bgcolor="#tbclr#" align="right">Output as file</td>
			<td bgcolor="#tdclr#"><input type="text" name="URLOutputFile" value="#OneScript.URLOutputFile#" maxlength="50"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Output Directory</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="URLOutputDir" value="#OneScript.URLOutputDir#" maxlength="150" size="50"></td>
		</tr>
</cfoutput>
		<cfif OneScript.URLMethod Is "Post">
			<cfoutput>
				<tr>
					<th colspan="5" bgcolor="#thclr#">Form Fields</th>
				</tr>
				<tr bgcolor="#thclr#">
					<td>Active</td>
					<td>Field Name</td>
					<td>Field Type</td>
					<td>Value</td>
					<td>Del</td>
				</tr>
			</cfoutput>
			<cfset CountField = 0>
			<cfoutput query="AllFormFields">
				<cfset CountField = CountField + 1>
				<tr>
					<cfif FieldFile Is "">
						<cfset HowHigh = 1>
					<cfelse>
						<cfset HowHigh = 2>
					</cfif>
					<input type="hidden" name="FormFieldID#CountField#" value="#FormFieldID#">
					<td bgcolor="#tdclr#" valign="top" rowspan="#HowHigh#"><input type="radio" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#CountField#" value="1"> Yes <input type="radio" <cfif ActiveYN Is 0>checked</cfif> name="ActiveYN#CountField#" value="0"> No</td>
					<td bgcolor="#tdclr#"><input type="text" name="FieldName#CountField#" value="#FieldName#" maxlength="50" size="15"></td>
					<td bgcolor="#tdclr#"><select name="FieldType#CountField#">
						<option <cfif FieldType Is "CGI">selected</cfif> value="CGI">CGI
						<option <cfif FieldType Is "Cookie">selected</cfif> value="Cookie">Cookie
						<option <cfif FieldType Is "File">selected</cfif> value="File">File
						<option <cfif FieldType Is "FormField">selected</cfif> value="FormField">FormField
						<option <cfif FieldType Is "URL">selected</cfif> value="URL">URL
					</select></td>
					<td bgcolor="#tdclr#"><input type="text" name="FieldValue#CountField#" value="#FieldValue#" size="25" maxlength="150"></td>
					<td bgcolor="#tdclr#"><input type="checkbox" name="DeleteEmIds" value="#FormFieldID#"></td>
				</tr>
				<cfif FieldFile Is Not "">
					<tr>
						<td bgcolor="#tdclr#" colspan="3">File Name <input type="text" name="FieldFile#CountField#" value="#FieldFile#" size="50" maxlength="250"></td>
					</tr>
				</cfif>
			</cfoutput>
			<cfoutput>
				<input type="hidden" name="CountField" value="#CountField#">
			</cfoutput>
		</cfif>
		<tr valign="top">
			<td align="center" colspan="5"><input type="image" name="URLEdit" src="images/update.gif" border="0">	<input type="image" name="Delem" src="images/delete.gif" border="0"></td>
		</tr>
	</form>
</table>

<!-- /int5.cfm -->





