<!--- Version 4.0.0 --->
<!--- This is the Telnet tab for the scripts. --->
<!--- 4.0.0 06/19/99 --->
<!--- int3.cfm --->

<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="4" bgcolor="#thclr#">Telnet Script <font size="2"><input type="submit" name="ClearTelnet" value="Clear Telnet Info"></font></td>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Telnet Active</td>
			<td bgcolor="#tdclr#" colspan="3"><input <cfif OneScript.TelActiveYN Is 1>checked</cfif> type="radio" name="TelActiveYN" value="1"> Yes <input <cfif OneScript.TelActiveYN Is 0>checked</cfif> type="radio" name="TelActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>Host Name</td>
			<td bgcolor="#tdclr#" colspan="3"><input type=text name="TelnetHost" size="40" value="#OneScript.TelnetHost#" maxlength="100"></td>
			<input type=hidden name="TelnetHost_Required" value="You must supply a Host Name">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right" nowrap>Use SecureCRT</td>
			<td bgcolor="#tdclr#"><input <cfif OneScript.TelnetUseSecure Is 1>checked</cfif> type="radio" name="TelnetUseSecure" value="1"> Yes <input <cfif OneScript.TelnetUseSecure Is Not 1>checked</cfif> type="radio" name="TelnetUseSecure" value="0"> No</td>
			<td bgcolor="#tbclr#" align="right" nowrap>SecureCRT Port</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetPort" size="5" value="#OneScript.TelnetPort#" maxlength="10"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right" nowrap>SecureCRT User</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetSecUser" size="15" value="#OneScript.TelnetSecUser#" maxlength="50"></td>
			<td bgcolor="#tbclr#" align="right" nowrap>SecureCRT Cipher</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetSecCipher" size="15" value="#OneScript.TelnetSecCipher#" maxlength="50"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right" nowrap>SecureCRT Auth Type</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetSecAuthType" size="15" value="#OneScript.TelnetSecAuthType#" maxlength="20"></td>
			<td bgcolor="#tbclr#" align="right" nowrap>SecureCRT Password</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetSecPassword" size="15" value="#OneScript.TelnetSecPassword#" maxlength="30"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>SecureCRT Identity</td>
			<td bgcolor="#tdclr#" colspan="3"><input type=text name="TelnetSecIdent" size="40" value="#OneScript.TelnetSecIdent#" maxlength="200"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>Telnet Login</td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetLogin" value="#OneScript.TelnetLogin#" maxlength="50"></td>
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>Telnet Password</td>
			<td bgcolor="#tdclr#"><input type="password" name="TelnetPassword" value="#OneScript.TelnetPassword#" maxlength="50"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>SU Login<br><font size="1">optional</font></td>
			<td bgcolor="#tdclr#"><input type=text name="TelnetSULogin" value="#OneScript.TelnetSULogin#" maxlength="50"></td>
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>SU Password<br><font size="1">optional</font></td>
			<td bgcolor="#tdclr#"><input type="password" name="TelnetSUPassword" value="#OneScript.TelnetSUPassword#" maxlength="50"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>CSF File Path#OSType#Name</td>
			<td bgcolor="#tdclr#" colspan="3"><input type=text name="TelnetCSFFile" size="40" value="#OneScript.TelnetCSFFile#" maxlength="200">.csf</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>CFG File Path#OSType#Name</td>
			<td bgcolor="#tdclr#" colspan="3"><input type=text name="TelnetCFGFile" size="40" value="#OneScript.TelnetCFGFile#" maxlength="200">.cfg</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>CMD File Path#OSType#Name</td>
			<td bgcolor="#tdclr#" colspan="3"><input type=text name="TelnetCMDFile" size="40" value="#OneScript.TelnetCMDFile#" maxlength="200">.cmd</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" valign="TOP" nowrap>Script</td>
			<td bgcolor="#tdclr#" colspan="3"><textarea cols="50" rows="6" name="TelnetScript" wrap="off">#OneScript.TelnetScript#</textarea></td>
		</tr>
		<tr valign="top">
			<td align="center" colspan="4"><input type="image" name="TelnetScriptEdit" src="images/update.gif" border="0"></td>
		</tr>
	</form>
</table>
</cfoutput>
 