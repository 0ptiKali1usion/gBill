<!-- Version 3.5.0 -->
<!--- This is the Custom tab for the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int6.cfm -->

<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm" onSubmit="return confirm('Click Ok to confirm clearing the script information.')">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td colspan="2" bgcolor="#thclr#">Custom CFM <font size="2"><input type="submit" name="ClearCFM" value="Clear CFM Info"></font></td>
		</tr>
	</form>
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right">Custom Active</td>
			<td bgcolor="#tdclr#"><input <cfif OneScript.CFMActiveYN Is 1>checked</cfif> type="radio" name="CFMActiveYN" value="1"> Yes <input <cfif OneScript.CFMActiveYN Is 0>checked</cfif> type="radio" name="CFMActiveYN" value="0"> No</td>
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="RIGHT" nowrap>CFM Name</td>
			<td bgcolor="#tdclr#"><input type="text" name="CustomCFM" size="20" value="#OneScript.CustomCFM#"></td>
			<input type=hidden name="CustomCFM_Required" value="You must enter the name of your custom CFM.">
		</tr>
		<tr valign="top">
			<td bgcolor="#tbclr#" align="right" colspan="2">Custom CFM's must be placed in following directory:<br>#CFMPath#external#OSType#</td>
		</tr>
		<tr valign="top">
			<td align="center" colspan="2"><input type="image" name="CustomCFMPage" src="images/update.gif" border="0"></td>
		</tr>
	</form>
</table>
</cfoutput>

<!-- /int6.cfm -->






