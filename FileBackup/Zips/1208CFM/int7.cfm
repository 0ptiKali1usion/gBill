<!-- Version 3.5.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int7.cfm -->

<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="4" bgcolor="#thclr#">FTP <font size="2"><input type="submit" name="ClearFTP" value="Clear FTP Info"></font></td>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">FTP Active</td>
			<td bgcolor="#tdclr#" colspan="3"><input <cfif OneScript.FTPActiveYN Is 1>checked</cfif> type="radio" name="FTPActiveYN" value="1"> Yes <input <cfif OneScript.FTPActiveYN Is 0>checked</cfif> type="radio" name="FTPActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#">Server</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="FTPServer" value="#OneScript.FTPServer#" maxlength="100" size="54"></td>
			<input type="hidden" name="FTPServer_Required" value="Please enter the Server address.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#">FTP Login</td>
			<td bgcolor="#tdclr#"><input type="text" name="FTPLogin" value="#OneScript.FTPLogin#" maxlength="50"></td>
			<input type="hidden" name="FTPLogin_Required" value="Please enter the FTP Login.">
			<td bgcolor="#tbclr#">FTP Password</td>
			<td bgcolor="#tdclr#"><input type="password" name="FTPPassword" value="#OneScript.FTPPassword#" maxlength="50"></td>
			<input type="hidden" name="FTPPassword_Required" value="Please enter the FTP Password.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#">FTP Server Path</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="FTPServerPath" value="#OneScript.FTPServerPath#" maxlength="150" size="54"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#">FTP Action</td>
			<td bgcolor="#tdclr#"><select name="FTPAction">
				<option <cfif OneScript.FTPAction Is "GetFile">selected</cfif> value="GetFile">Get A File
				<option <cfif OneScript.FTPAction Is "PutFile">selected</cfif> value="PutFile">Put A File
			</select></td>
			<input type="hidden" name="FTPAction_Required" value="Please select the FTP Action.">
			<td bgcolor="#tbclr#">FTP Filename</td>
			<td bgcolor="#tdclr#"><input type="text" name="FTPFilename" value="#OneScript.FTPFilename#" maxlength="50"></td>
			<input type="hidden" name="FTPFilename_Required" value="Please enter the filename.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#">FTP Path</td>
			<td bgcolor="#tdclr#" colspan="3"><input type="text" name="FTPPath" value="#OneScript.FTPPath#" maxlength="150" size="54"></td>
		</tr>
		<tr valign="top">
			<td align="center" colspan="4"><input type="image" name="FTPScriptEdit" src="images/update.gif" border="0"></td>
		</tr>		
	</form>
</table>
</cfoutput>
<!-- /int7.cfm -->






