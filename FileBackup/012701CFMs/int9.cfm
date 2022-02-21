<cfsetting enablecfoutputonly="Yes">
<!-- Version 4.0.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!-- int9.cfm -->

<cfsetting enablecfoutputonly="No">
<cfoutput>
<table border="0">
	<form method="post" name="clear" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="IntID" value="#IntID#">
		<input type="hidden" name="Tab" value="#Tab#">
		<tr valign="top">
			<td colspan="4" bgcolor="#thclr#">EMail <font size="2"><input type="submit" name="ClearEml" value="Clear EMail Info"></font></th>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="IntID" value="#IntID#">
		<input type="hidden" name="Tab" value="#Tab#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail Active</td>
			<td bgcolor="#tdclr#" colspan="3"><input <cfif OneScript.EmlActiveYN Is 1>checked</cfif> type="radio" name="EmlActiveYN" value="1"> Yes <input <cfif OneScript.EmlActiveYN Is 0>checked</cfif> type="radio" name="EmlActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail Server</td>
			<td bgcolor="#tdclr#"><input type="text" name="EMailServer" value="#OneScript.EMailServer#" maxlength="30"></td>
			<td bgcolor="#tbclr#" align="right">Server Port</td>
			<td bgcolor="#tdclr#"><input type="text" name="EMailServerPort" value="#OneScript.EMailServerPort#" maxlength="4" size="4"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail From</td>
			<td bgcolor="#tdclr#"><input type="text" name="EMailFrom" value="#OneScript.EMailFrom#" maxlength="150"></td>
			<input type="hidden" name="EMailFrom_Required" value="Please enter the from address for this e-mail message.">
			<td bgcolor="#tbclr#" align="right">EMail To</td>
			<td bgcolor="#tdclr#"><input type="text" name="EMailTo" value="#OneScript.EMailTo#" maxlength="150"></td>
			<input type="hidden" name="EMailTo_Required" value="Please enter the to address for this email message.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail CC</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="EMailCC" value="#OneScript.EMailCC#" maxlength="150"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Attach File</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="EMailFile" value="#OneScript.EMailFile#" maxlength="150" size="50"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Wait</td>
			<td bgcolor="#tdclr#" colspan="3"><select name="EmlAttachWait">
				<option <cfif OneScript.EmlAttachWait Is "0">selected</cfif> value="0">0 seconds
				<option <cfif OneScript.EmlAttachWait Is "3">selected</cfif> value="3">3 seconds
				<option <cfif OneScript.EmlAttachWait Is "5">selected</cfif> value="5">5 seconds
				<option <cfif OneScript.EmlAttachWait Is "10">selected</cfif> value="10">10 seconds
				<option <cfif OneScript.EmlAttachWait Is "30">selected</cfif> value="30">30 seconds
				<option <cfif OneScript.EmlAttachWait Is "45">selected</cfif> value="45">45 seconds
			</select> for file attachment</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Wait</td>
			<td bgcolor="#tdclr#" colspan="3"><input value="#OneScript.EMailDelay#" type="text" name="EMailDelay" size="3" maxlength="3"> minutes before sending EMail</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail Subject</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="EMailSubject" value="#OneScript.EMailSubject#" maxlength="150" size="50"></td>
			<input type="hidden" name="EMailSubject_Required" value="Please enter the subject for this email message.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail Message</td>
			<td bgcolor="#tdclr#" colspan="3"><textarea name="EMailMessage" rows="6" cols="50">#OneScript.EMailMessage#</textarea></td>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="4">Repeating Section For Multiple Record Custom Variables</th>
		</tr>
		<input type="Hidden" name="EMailRepeatQuery" value="0">
		<!--- <tr bgcolor="#tdclr#" >
			<td bgcolor="#tbclr#" align="right">Pre Defined Query</td> --->
</cfoutput>
			<!--- <td colspan="3"><select name="EMailRepeatQuery">
				<option <cfif OneScript.EMailRepeatQuery Is 0>selected</cfif> value="0">Use Custom Variable Query
				<cfoutput query="GetSQLQueries">
					<option <cfif OneScript.EMailRepeatQuery Is QueryID>selected</cfif> value="#QueryID#">#DescripTitle#
				</cfoutput>
			</select></td>
		</tr> --->
<cfoutput>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">EMail Message</td>
			<td bgcolor="#tdclr#" colspan="3"><textarea name="EMailRepeatMsg" rows="6" cols="50">#OneScript.EMailRepeatMsg#</textarea></td>				
		</tr>
		<tr valign="top">
			<th colspan="4"><input type="image" name="EMlScriptEdit" src="images/update.gif" border="0"></th>
		</tr>
	</form>
</table>
</cfoutput>
 