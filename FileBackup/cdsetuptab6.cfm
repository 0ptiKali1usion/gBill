<cfsetting enablecfoutputonly="yes">

<!-- Version 3.2.0 -->
<!--- This page is tab1 of the check debit exporter.
--->
<!--- 3.2.0 01/12/99 --->
<!-- cdsetuptab6.cfm -->

<cfsetting enablecfoutputonly="No">
<cfoutput>
	<form method="post" action="cdsetup.cfm">
		<input type="hidden" name="tab" value="#tab#">
		<tr>
			<td bgcolor="#tbclr#" align="right">Date Format</td>
			<td bgcolor="#tdclr#"><select name="CDDateFormat">
				<option <cfif cddateformat is "YYYYMMDD">selected</cfif> value="YYYYMMDD">YYYYMMDD
				<option <cfif cddateformat is "YYMMDD">selected</cfif> value="YYMMDD">YYMMDD
				<option <cfif cddateformat is "MMDDYYYY">selected</cfif> value="MMDDYYYY">MMDDYYYY
				<option <cfif cddateformat is "MMDDYY">selected</cfif> value="MMDDYY">MMDDYY
				<option <cfif cddateformat is "DDMMYYYY">selected</cfif> value="DDMMYYYY">DDMMYYYY
				<option <cfif cddateformat is "DDMMYY">selected</cfif> value="DDMMYY">DDMMYY
			</select></td>
			<td bgcolor="#tbclr#" align="right">Time Format</td>
			<td bgcolor="#tdclr#"><select name="CDTimeFormat">
				<option <cfif Compare("#cdtimeformat#","hhmm") is 0>selected</cfif> value="hhmm">hhmm
				<option <cfif Compare("#cdtimeformat#","HHmm") is 0>selected</cfif> value="HHmm">HHmm
			</select></td>
		</tr>
		<tr>
			<cfset moneysign = LSCurrencyFormat(0)>
			<cfset moneysign = Left(moneysign,1)>
			<td bgcolor="#tbclr#" align="right">Use <b>#moneysign#</b> in Amounts</td>
			<td bgcolor="#tdclr#"><input <cfif IsDefined("cdUseDS")><cfif cdUseDS is 1>checked</cfif><cfelse>checked</cfif> TYPE="Radio" NAME="CDUseDS" VALUE="1"> Yes <input <cfif IsDefined("cdUseDS")><cfif cdUseDS is 0>checked</cfif></cfif> TYPE="Radio" NAME="CDUseDS" VALUE="0"> No</td>
			<td bgcolor="#tbclr#" align="right">Use <b>.</b> in Amounts</td>
			<td bgcolor="#tdclr#"><input <cfif IsDefined("cdUseP")><cfif cdUseP is 1>checked</cfif><cfelse>checked</cfif> TYPE="Radio" NAME="CDUseP" VALUE="1"> Yes <input <cfif IsDefined("cdUseP")><cfif cdUseP is 0>checked</cfif></cfif> TYPE="Radio" NAME="CDUseP" VALUE="0"> No</td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Check Debit Output Path</td>
			<td bgcolor="#tdclr#" colspan="3"><INPUT type="text" size="45" <cfif IsDefined("cdoutpath")>value="#cdoutPath#"</cfif> Name="CDOutPath"></td>
		</tr>	
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Check Debit Output File</td>
			<td bgcolor="#tdclr#""><INPUT type="text" size="15" <cfif IsDefined("thecdfile")>value="#thecdfile#"</cfif> Name="TheCDFile"></td>
			<td bgcolor="#tbclr#" align="right">Rows Characters wide</td>
			<td bgcolor="#tdclr#"><INPUT type="text" size="5" <cfif IsDefined("setcdrecwidth")>value="#setcdrecwidth#"</cfif> Name="setcdrecwidth"></td>
		</tr>	
		<tr>
			<th colspan="4"><input type="image" src="images/update.gif" border="0" name="upd1"></th>
		</tr>
	</form>
</cfoutput>

