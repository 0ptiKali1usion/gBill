<!--- Version 4.0.0 --->
<!--- This is the General Tab for pops setup. --->
<!--- 4.0.0 
		3.2.0 09/08/98 --->
<!--- popstab1.cfm --->

<form method="post" action="pops2.cfm" name="info">
<cfoutput>
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="POPID" value="#POPID#">
	<tr>
		<td align="right" bgcolor="#tbclr#">POP Name</td>
		<td bgcolor="#tdclr#"><input type="text" name="POPName" value="#OnePOP.POPName#" size="50" maxlength="50"></td>
		<input type="hidden" name="POPName_Required" value="Please enter the name for this POP.">
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Online Signup Show</td>
		<td bgcolor="#tdclr#"><input <cfif OnePOP.ShowYN Is Not 0>checked</cfif> type="radio" name="ShowYN" value="1"> Yes <input <cfif OnePOP.ShowYN Is 0>checked</cfif> type="radio" name="ShowYN" value="0"> No</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Contact</td>
		<td bgcolor="#tdclr#"><input type="text" name="Contact" value="#OnePOP.Contact#" size="40" maxlength="50"></td>
		<input type="hidden" name="contact_required" value="Please enter the Contact person for this pop">
	</tr>
	<tr valign="top">
		<td align="right" bgcolor="#tbclr#">Address</td>
		<td bgcolor="#tdclr#"><input type="text" name="Address" value="#OnePOP.Address#" size="40" maxlength="50"></td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Address</td>
		<td bgcolor="#tdclr#"><input type="text" name="Address2" value="#OnePOP.Address2#" size="40" maxlength="50"></td>
	</tr>
	<cfif International Is 1>
		<tr>
			<td align="right" bgcolor="#tbclr#">Address</td>
			<td bgcolor="#tdclr#"><input type="text" name="Address3" value="#OnePOP.Address3#" size="40" maxlength="50"></td>
		</tr>
	</cfif>
	<tr>
		<td align="right" bgcolor="#tbclr#">City</td>
		<input type="hidden" name="City_required" value="Please enter the city this POP is in.">
		<td bgcolor="#tdclr#"><input type="text" name="City" value="#OnePOP.City#" size="40" maxlength="50"></td>
	</tr>
</cfoutput>
	<cfif International Is 1>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Province</td>
		</cfoutput>
				<td><select name="State">
					<cfoutput query="AllStates">
						<option <cfif POPID GT 0><cfif Abbr Is OnePOP.State>selected</cfif><cfelse><cfif DefState Is 1>selected</cfif></cfif> value="#Abbr#">#StateName#
					</cfoutput>
				</select></td>
			</tr>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Country</td>
		</cfoutput>
				<td><select name="Country">
					<cfoutput query="AllCountries">
						<option <cfif POPID GT 0><cfif CountryAbbr Is OnePOP.Country>selected</cfif><cfelse><cfif DefCountry Is 1>selected</cfif></cfif> value="#CountryAbbr#">#Country#
					</cfoutput>
				</select></td>
			</tr>
			<tr>
		<cfoutput>
				<td align="right" bgcolor="#tbclr#">Post Code</td>
				<td bgcolor="#tdclr#"><input type="text" name="Zip" value="#OnePOP.Zip#" size="10" maxlength="20"></td>
				<input type="hidden" name="Zip_required" value="Please enter the Post code for the POP.">
		</cfoutput>
			</tr>
	<cfelse>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">State/Zip</td>
		</cfoutput>
				<td><select name="State">
					<cfoutput query="AllStates">
						<option <cfif POPID GT 0><cfif Abbr Is OnePOP.State>selected</cfif><cfelse><cfif DefState Is 1>selected</cfif></cfif> value="#Abbr#">#StateName#
					</cfoutput>
				</select> <cfoutput><input type="text" name="Zip" value="#OnePOP.Zip#" size="10" maxlength="20"></cfoutput></td>
				<input type="hidden" name="Zip_required" value="Please enter the zip code for the POP.">
			</tr>
	</cfif>
<cfoutput>
	<tr>
		<td align="right" bgcolor="#tbclr#">Phone</td>
		<td bgcolor="#tdclr#"><input type="text" name="phone1" value="#OnePOP.Phone1#" size="20" maxlength="20"></td>
	</tr>
	<input type="hidden" name="phone1_required" value="Please enter the contacts phone number.">
	<tr>
		<td align="right" bgcolor="#tbclr#">Phone 2</td>
		<td bgcolor="#tdclr#"><input type="text" name="phone2" value="#OnePOP.Phone2#" size="20" maxlength="20"></td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Data Area Code</td>
		<td bgcolor="#tdclr#"><input type="text" name="DataAreaCode" value="#OnePOP.DataAreaCode#" size="5" maxlength="5"></td>
		<input type="hidden" name="DataAreaCode_Required" value="Pleae enter the area code for the POPs dial up phone number.">
	</tr>
	<tr>	
		<td align="right" bgcolor="#tbclr#">Data Phone</td>
		<td bgcolor="#tdclr#"><input type="text" name="PhoneData" value="#OnePOP.PhoneData#" size="20"></td>
	</tr>
	<input type="hidden" name="PhoneData_required" value="Please enter the dial up phone number for the POP.">
</cfoutput>
	<tr>
		<cfif POPID GT 0>
			<th colspan="2"><input type="image" name="UpdatePOP" src="images/edit.gif" border="0"></th>
		<cfelse>
			<th colspan="2"><input type="image" name="EnterPOP" src="images/enter.gif" border="0"></th>
		</cfif>
	</tr>
</form>
  
