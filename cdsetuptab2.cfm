<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is tab2 of the check debit exporter.
--->
<!--- 4.0.0 06/26/99 Multi save rather than one line at a time.
		3.2.0 01/12/99 --->
<!-- cdsetuptab2.cfm -->

<cfset count1 = 0>
<cfsetting enablecfoutputonly="No">

<cfif IsDefined("AddRow.x")>
	<cfsetting enablecfoutputonly="Yes">
	<cfquery name="GetMaxStart" datasource="#pds#">
		SELECT max(EndOrder) as LastVal 
		FROM CustomCDOutput 
		WHERE UseTab = #tab# 
		AND UseYN = 1
	</cfquery>
	<cfif Trim(GetMaxStart.LastVal) Is "">
		<cfset NextVal = 1>
	<cfelse>
		<cfset NextVal = GetMaxStart.LastVal + 1>
	</cfif>
	<cfsetting enablecfoutputonly="No">
	<cfoutput>
		<tr>
			<th bgcolor="#thclr#">Start</th>
			<th bgcolor="#thclr#">End</th>
			<th bgcolor="#thclr#">Justify</th>
			<th bgcolor="#thclr#">Pad</th>
			<th bgcolor="#thclr#">Use</th>
			<th bgcolor="#thclr#">Data</th>
		</tr>
		<tr>
			<td bgcolor="#tdclr#"><form method="post" action="cdsetup.cfm"><input type="hidden" name="tab" value="#tab#"><input type="hidden" name="UseTab" value="2"><input type="text" value="#NextVal#" name="StartOrder" size="3" maxlength="3"></td>
			<td bgcolor="#tdclr#"><input type="text" name="EndOrder" size="3" maxlength="3"><input type="hidden" name="startorder_required" value="Please enter the start position."><input type="hidden" name="endorder_required" value="Please enter the end position."><input type="hidden" name="sortorder_integer" value="Please enter a number for the start position."><input type="hidden" name="endorder_integer" value="Please enter a number for the end position."></td>
			<td bgcolor="#tdclr#"><select name="pjustify"><option <cfif pjustify is "N">selected</cfif> value="N">N/A<option <cfif pjustify is "L">selected</cfif> value="L">Left<option <cfif pjustify is "R">selected</cfif> value="R">Right<option <cfif pjustify is "C">selected</cfif> value="C">Center</select></td>
			<td bgcolor="#tdclr#"><input type="text" name="padchar" size="1" maxlength="1"></td>
			<td bgcolor="#tdclr#"><input type="checkbox" checked name="useyn" value="1"></td>
			<td bgcolor="#tdclr#"><input type="text" maxlength="35" name="description1"></td>
		</tr>
		<tr>
			<th colspan="6"><input type="image" src="images/enter.gif" border="0" name="enter1"></form></th>
		</tr>
	</cfoutput>
<cfelse>
<cfsetting enablecfoutputonly="No">
	<cfoutput>
		<tr>
			<form method="post" action="cdsetup.cfm">
				<input type="hidden" name="tab" value="2">
				<td colspan="7" align="right"><input type="image" name="AddRow" src="images/addnew.gif" border="0"></td>
			</form>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="7">Batch Header</th>
		</tr>
		<tr>
			<th bgcolor="#thclr#">Start</th>
			<th bgcolor="#thclr#">End</th>
			<th bgcolor="#thclr#">Justify</th>
			<th bgcolor="#thclr#">Pad</th>
			<th bgcolor="#thclr#">Use</th>
			<th bgcolor="#thclr#">Data</th>
			<th bgcolor="#thclr#">Delete</th>
		</tr>
	</cfoutput>
	<form method="post" action="cdsetup.cfm">
		<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
		<cfoutput query="alloptions">
			<cfset count1 = count1 + 1>
			<tr>
				<cfif useyn is 1><td bgcolor="#tdclr#"><input type="Text" name="startorder#count1#" value="#startorder#" size="3" maxlength="3"></td><cfelse><td bgcolor="#tdclr#"><input type="text" name="startorder#count1#" size="3" maxlength="3"></td></cfif>
				<cfif useyn is 1><td bgcolor="#tdclr#"><input type="text" name="endorder#count1#" value="#endorder#" size="5" maxlength="3"></td><cfelse><td bgcolor="#tdclr#"><input type="text" name="endorder#count1#" size="5" maxlength="3"></td></cfif>
				<cfif useyn is 1><td bgcolor="#tdclr#"><select name="pjustify#count1#"><option <cfif pjustify is "N">selected</cfif> value="N">N/A <option <cfif pjustify is "L">selected</cfif> value="L">Left <option <cfif pjustify is "R">selected</cfif> value="R">Right <option <cfif pjustify is "C">selected</cfif> value="C">Center </select></td> <cfelse> <td bgcolor="#tdclr#"><select name="pjustify#count1#"><option selected value="N">N/A <option value="L">Left <option value="R">Right <option value="C">Center </select></td> </cfif>
				<td bgcolor="#tdclr#"><input type="text" value="#padchar#" name="padchar#count1#" size="1" maxlength="1"></td>
				<td bgcolor="#tdclr#"><input type="checkbox" <cfif useyn is 1>checked</cfif> name="useyn#count1#" value="1"></td>
				<td bgcolor="#tbclr#"><cfif CFVarYN Is 0><input type="text" name="Description1#count1#" value="#description1#" size="15" maxlength="75"><cfelse>#description1#</cfif></td>
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 0><input type="checkbox" name="DeleteEm" value="#cdoutputid#"><cfelse>&nbsp;</cfif><input type="hidden" name="CDOutputID#count1#" value="#CDOutputID#"><input type="hidden" name="CFVarYN#count1#" value="#CFVarYN#"></th>
			</tr>
		</cfoutput>
		<tr>
			<cfoutput>
				<input type="hidden" name="LoopCount" value="#count1#">
				<th colspan="7"><input type="image" src="images/update.gif" border="0" name="edit1"><input type="image" src="images/delete.gif" border="0" name="delone"></th>
			</cfoutput>
		</tr>
	</form>
</cfif>
 