<!--- Version 4.0.0 --->
<!--- This is the folders tab of the customization options.
--->
<!--- 4.0.0 07/20/99
		3.2.0 09/08/98 --->
<!--- opttab1.cfm --->

<cfoutput>
<form method="post" name="Theform" action="options.cfm">
	<INPUT type="hidden" name="tab" value="#tab#">
	<tr valign="top">
		<td align="right" bgcolor="#tbclr#">gBill Install Folder</td>
		<td bgcolor="#tdclr#" colspan="2"><INPUT type="text" size="45" <cfif IsDefined("billpath")>value="#BillPath#"</cfif> Name="BillPath"></td>
	</tr>
	<tr valign="top">
		<td align="right" bgcolor="#tbclr#">gBill Install O.S.</td>
		<td bgcolor="#tdclr#" colspan="2"><select name="OSType">
			<cfif CheckOSType.RecordCount Is 0><option value="">Select the Operating System gBill is installed on</cfif>
			<option <cfif CheckOSType.RecordCount GT 0><cfif OSType Is "\">selected</cfif></cfif> value="\">NT
			<option <cfif CheckOSType.RecordCount GT 0><cfif OSType Is "/">selected</cfif></cfif> value="/">Linux
		</select></td>
	</tr>
	<tr valign="top">
		<td align="right" bgcolor="#tbclr#">Telnet Crt.exe Pathway</td>
		<td bgcolor="#tdclr#" colspan="2"><INPUT type="text" size="45" <cfif IsDefined("crtpath")>value="#crtPath#"</cfif> Name="crtPath"></td>
	</tr>
	<input type="hidden" name="BODBCType" value="SQL">
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Deactivated Account</td>
</cfoutput>
		<td colspan="2"><select name="deactaccount">
			<cfoutput query="getplans">
				<option <cfif IsDefined("deactaccount")><cfif #planid# is "#deactaccount#">selected</cfif></cfif> value="#planid#">#plandesc#
			</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Cancelled Account</td>
</cfoutput>
		<td colspan="2"><select name="delaccount">
			<cfoutput query="getplans">
				<option <cfif IsDefined("delaccount")><cfif #planid# is "#delaccount#">selected</cfif></cfif> value="#planid#">#plandesc#
			</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Password Request Letter</td>
</cfoutput>	
		<td colspan="2"><select name="prletter">
			<option value="0">None
			<cfoutput query="getletters">
				<option <cfif IsDefined("prletter")><cfif IntID Is PRLetter>selected</cfif></cfif> value="#IntID#">#IntDesc#
			</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Locale</td>
</cfoutput>
		<td colspan="2"><select name="Locale">
			<cfloop index="B5" List="#country1#">
				<option <cfif IsDefined("locale")><cfif locale Is B5>Selected</cfif></cfif> ><cfoutput>#B5#</cfoutput>
			</cfloop>
		</select> <cfoutput>#LSCurrencyFormat(1999.99)#</cfoutput></td>
<cfoutput>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Date Format:</td>
		<td colspan="2"><select name="f1" onchange="toggleit()">
			<option <cfif IsDefined("datemask1")><cfif #f1# is "MMM">Selected</cfif></cfif> value="MMM">Month
			<option <cfif IsDefined("datemask1")><cfif #f1# is "DD">Selected</cfif></cfif> value="DD">Day
		</select><select name="f2" onchange="toggleit2()">
			<option <cfif IsDefined("datemask1")><cfif #f2# is "DD">Selected</cfif></cfif> value="DD">Day
			<option <cfif IsDefined("datemask1")><cfif #f2# is "MMM">Selected</cfif></cfif> value="MMM">Month
		</select><select name="f3">
			<option <cfif IsDefined("datemask1")><cfif #f3# is "YY">Selected</cfif></cfif> value="YY">Year YY
			<option <cfif IsDefined("datemask1")><cfif #f3# is "YYYY">Selected</cfif></cfif> value="YYYY">Year YYYY
		</select> Oct. 9, 1999 as #LSDateFormat("October 9, 1999", '#datemask1#')#</td>
	</tr>
	<tr valign="top">
		<th colspan="3"><INPUT type="image" src="images/update.gif" border="0" name="UpdateTab1"></th>
	</tr>
</cfoutput>
       