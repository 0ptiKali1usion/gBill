<!-- Version 3.5.0 -->
<!--- This is the page that lists all of the scripts. --->
<!--- 3.5.0 06/19/99 --->
<!-- int10.cfm -->
<cfset TypeNum = 7>
<cfoutput>
<table border="0">
	<form method="post" action="integration2.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="IntID" value="#IntID#">
		<input type="hidden" name="CurrentSort" value="#ScriptSortOrder#">
		<tr valign="top">
			<td bgcolor="#thclr#" colspan="3">Script Run Order</td>
		</tr>
			<th bgcolor="#thclr#">Active</th>
			<th bgcolor="#thclr#">Type</th>
			<th bgcolor="#thclr#">Move</th>
		<tr>
		</tr>
		<cfset Count1 = 1>
</cfoutput>
		<cfloop index="B5" list="#ScriptSortOrder#">
		<cfoutput>
			<cfif B5 Is "d">
				<tr>
					<input type="hidden" name="ToggleDOS" value="1">
					<th bgcolor="#tdclr#" align="center"><input type="checkbox" name="DOSActiveYN" <cfif OneScript.DOSActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">Batch</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="DosUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="DosDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "t">
				<tr>
					<input type="hidden" name="ToggleTel" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="TelActiveYN" <cfif OneScript.TelActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">Telnet</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="TelUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="TelDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "s">
				<tr>
					<input type="hidden" name="ToggleSQL" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="SQLActiveYN" <cfif OneScript.SQLActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">SQL</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="SQLUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="SQLDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "u">
				<tr>
					<input type="hidden" name="ToggleURL" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="URLActiveYN" <cfif OneScript.URLActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">URL</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="URLUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="URLDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "c">
				<tr>
					<input type="hidden" name="ToggleCFM" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="CFMActiveYN" <cfif OneScript.CFMActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">CFM</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="CFMUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="CFMDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "f">
				<tr>
					<input type="hidden" name="ToggleFTP" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="FTPActiveYN" <cfif OneScript.FTPActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">FTP</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="FTPUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="FTPDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			<cfelseif B5 Is "e">
				<tr>
					<input type="hidden" name="ToggleEMl" value="1">
					<th bgcolor="#tdclr#"><input type="checkbox" name="EMlActiveYN" <cfif OneScript.EMlActiveYN Is "1">checked</cfif> value="1" onClick="submit()"></th>
					<td bgcolor="#tbclr#">EMail</td>
					<cfif Count1 gt 1><td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="EMlUp" border="0"><cfelse><td bgcolor="#tdclr#" align="right"></cfif><cfif Count1 lt TypeNum><input type="image" src="images/buttong.gif" name="EMlDn" border="0"><cfelse>&nbsp;</cfif></td>
				</tr>
				<cfset Count1 = Count1 + 1>
			</cfif>
		</cfoutput>			
		</cfloop>
	</form>
</table>		

<!-- /int10.cfm -->





