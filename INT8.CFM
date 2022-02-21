<!-- Version 3.5.0 -->
<!--- This is the ODBS tab for the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int8.cfm -->

<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="2" bgcolor="#thclr#">ODBC SQL Statement <font size="2"><input type="submit" name="ClearSQL" value="Clear SQL Info"></font></td>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">SQL Active</td>
			<td bgcolor="#tdclr#"><input <cfif OneScript.SQLActiveYN Is 1>checked</cfif> type="radio" name="SQLActiveYN" value="1"> Yes <input <cfif OneScript.SQLActiveYN Is 0>checked</cfif> type="radio" name="SQLActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>Use Custom Auth</td>
			<td bgcolor="#tdclr#"><input <cfif OneScript.SQLCustomAuth Is 1>checked</cfif> type="radio" name="SQLCustomAuth" value="1"> Yes <input <cfif OneScript.SQLCustomAuth Is 0>checked</cfif><cfif OneScript.SQLCustomAuth Is "">checked</cfif> type="radio" name="SQLCustomAuth" value="0"> No <a href="customauthsetup.cfm?ptab=2" target="New">Setup Custom Authentication</a></td>
		</tr>
		<tr valign="top">
			<th bgcolor="#tbclr#" align="center" nowrap>OR</th>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>ODBC Datasource</td>
			<td bgcolor="#tdclr#"><input type="text" name="ODBCDatasource" size="40" value="#OneScript.ODBCDatasource#" maxlength="75"></td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" valign="TOP" nowrap>SQL Query</td>
			<td bgcolor="#tdclr#"><textarea cols="50" rows="6" name="ODBCSQL" wrap="off">#OneScript.ODBCSQL#</textarea></td>
		</tr>
		<tr valign="top">
			<td align="center" colspan="2"><input type="image" name="SQLEdit" src="images/update.gif" border="0"></td>
		</tr>
	</form>
</table>
</cfoutput>
<!-- /int8.cfm -->






