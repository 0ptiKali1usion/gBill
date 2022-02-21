<!-- Version 4.0.0 -->
<!--- This is the Tax Information tab for pops setup. --->
<!--- 4.0.0 07/23/99
		3.2.0 09/08/98 --->
<!-- popstab2.cfm -->

<cfoutput>
<form method="post" action="pops2.cfm">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="POPID" value="#POPID#">
	<input type="hidden" name="tab" value="#tab#">
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Tax %</td>
		<td><input type="text" value="#Trim(LSNumberFormat(OnePOP.Tax1, '999999999999.9999'))#" size="5" name="tax1"></td>
		<td><input type="radio" <cfif OnePOP.Tax1Type Is 0>checked</cfif> name="Tax1Type" value="0"> Service <input type="radio" <cfif OnePOP.Tax1Type Is 1>checked</cfif> name="Tax1Type" value="1"> Goods</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right" bgcolor="#tbclr#">Desc</td>
		<td colspan="2"><input type="text" value="#OnePOP.TaxDesc1#" maxlength="35" size="35" name="TaxDesc1"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Tax %</td>
		<td><input type="text" value="#Trim(LSNumberFormat(OnePOP.Tax2, '999999999999.9999'))#" size="5" name="tax2"></td>
		<td><input type="radio" <cfif OnePOP.Tax2Type Is 0>checked</cfif> name="Tax2Type" value="0"> Service <input type="radio" <cfif OnePOP.Tax2Type Is 1>checked</cfif> name="Tax2Type" value="1"> Goods</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right" bgcolor="#tbclr#">Desc</td>
		<td colspan="2"><input type="text" value="#OnePOP.TaxDesc2#" maxlength="35" size="35" name="TaxDesc2"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Tax %</td>
		<td><input type="text" value="#Trim(LSNumberFormat(OnePOP.Tax3, '999999999999.9999'))#" size="5" name="tax3"></td>
		<td><input type="radio" <cfif OnePOP.Tax3Type Is 0>checked</cfif> name="Tax3Type" value="0"> Service <input type="radio" <cfif OnePOP.Tax3Type Is 1>checked</cfif> name="Tax3Type" value="1"> Goods</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right" bgcolor="#tbclr#">Desc</td>
		<td colspan="2"><input type="text" value="#OnePOP.TaxDesc3#" maxlength="35" size="35" name="TaxDesc3"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Tax %</td>
		<td><input type="text" value="#Trim(LSNumberFormat(OnePOP.Tax4, '999999999999.9999'))#" size="5" name="tax4"></td>
		<td><input type="radio" <cfif OnePOP.Tax4Type Is 0>checked</cfif> name="Tax4Type" value="0"> Service <input type="radio" <cfif OnePOP.Tax4Type Is 1>checked</cfif> name="Tax4Type" value="1"> Goods</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td align="right" bgcolor="#tbclr#">Desc</td>
		<td colspan="2"><input type="text" value="#OnePOP.TaxDesc4#" maxlength="35" size="35" name="TaxDesc4"></td>
	</tr>
	<tr>
		<th colspan="3"><input type="image" name="UpdTax" src="images/edit.gif" border="0"></th>
	</tr>

</form>
</cfoutput>
  
