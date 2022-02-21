<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is the fonancial tab for the plans setup.--->
<!--- 4.0.0 07/16/99 --->
<!--- plantab2.cfm --->

<cfset RCycleMax = 36>

<cfsetting enablecfoutputonly="No">
<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="Page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="PlanID" value="#PlanID#">
	<input type="hidden" name="tab" value="#tab#">
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Recurring Amount</td>
		<input type="hidden" name="recurringamount_Required" Value="Please enter the recurring amount">
		<td><input value="#Trim(LSNumberFormat(OnePlan.recurringamount, '999999999999.99'))#" type="text" name="RecurringAmount" size="8"></td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="Taxable" value="0" <cfif OnePlan.taxable is 0>Checked</cfif> >Taxfree <input type="radio" name="Taxable" value="1" <cfif OnePlan.taxable is 1>Checked</cfif> >Service <input type="radio" name="Taxable" value="2" <cfif OnePlan.taxable is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="RAMemo" value="#OnePlan.RAMemo#" maxlength="150" size="50"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Recurring Discount</td>
		<input type="hidden" name="RecurDiscount_Required" Value="Please enter the recurring discount amount">
		<td><input value="#Trim(LSNumberFormat(OnePlan.RecurDiscount, '999999999999.99'))#" type="text" name="RecurDiscount" size="8"></td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="Taxable2" value="0" <cfif OnePlan.taxable2 is 0>Checked</cfif> >Taxfree <input type="radio" name="Taxable2" value="1" <cfif OnePlan.taxable2 is 1>Checked</cfif> >Service <input type="radio" name="Taxable2" value="2" <cfif OnePlan.taxable2 is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="RDMemo" value="#OnePlan.RDMemo#" maxlength="150" size="50"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>One Time Fee</td>
		<input type="hidden" name="FixedAmount_Required" Value="Please enter the one time fee amount">
		<td bgcolor="#tdclr#"><input required="yes" value="#Trim(LSNumberFormat(OnePlan.FixedAmount, '999999999999.99'))#" type="text" name="FixedAmount" size="8"></td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="Taxable3" value="0" <cfif OnePlan.taxable3 is 0>Checked</cfif> >Taxfree <input type="radio" name="Taxable3" value="1" <cfif OnePlan.taxable3 is 1>Checked</cfif> >Service <input type="radio" name="Taxable3" value="2" <cfif OnePlan.taxable3 is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="FAMemo" value="#OnePlan.FAMemo#" maxlength="150" size="50"></td>
	</tr>	
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>One Time Discount</td>
		<input type="hidden" name="FixedDiscount_Required" Value="Please enter the one time fee amount">
		<td bgcolor="#tdclr#"><input required="yes" value="#Trim(LSNumberFormat(OnePlan.FixedDiscount, '999999999999.99'))#" type="text" name="FixedDiscount" size="8"></td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="Taxable4" value="0" <cfif OnePlan.taxable4 is 0>Checked</cfif> >Taxfree <input type="radio" name="Taxable4" value="1" <cfif OnePlan.taxable4 is 1>Checked</cfif> >Service <input type="radio" name="Taxable4" value="2" <cfif OnePlan.taxable4 is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="FDMemo" value="#OnePlan.FDMemo#" maxlength="150" size="50"></td>
	</tr>	
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Synchronize</td>
		<td><input type="radio" name="SynchBillingYN" value="1" <cfif OnePlan.SynchBillingYN is 1>Checked</cfif> >Yes <input type="radio" name="SynchBillingYN" value="0" <cfif OnePlan.SynchBillingYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Period</td>
</cfoutput>
		<td><select name="RecurringCycle">
			<option value=1 <cfif OnePlan.RecurringCycle is 1>Selected</cfif> >1 Month
			<cfloop index="B5" from="2" to="#RCycleMax#">
				<cfoutput>
					<option <cfif OnePlan.RecurringCycle is B5>Selected</cfif> value="#B5#">#B5# Months
				</cfoutput>
			</cfloop>
			<option value=20 <cfif OnePlan.RecurringCycle is 0>Selected</cfif> >N/A
		</select></td>
<cfoutput>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>To What Days</td>
		<td colspan="3"><input type="text" name="SynchDays" value="#OnePlan.SynchDays#" maxlength="100" size="50"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Past Due after</td>
		<td><input type="text" name="PayDueDays" value="#OnePlan.PayDueDays#" maxlength="2" size="3"> days</td>
		<td bgcolor="#tbclr#" align=right>Deactivate after</td>
		<td><input type="text" name="DeactDays" value="#OnePlan.DeactDays#" maxlength="2" size="3"> days</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Prorate</td>
		<td><input type="radio" name="ProratePYN" value="1" <cfif OnePlan.ProratePYN is 1>Checked</cfif> >Yes <input type="radio" name="ProratePYN" value="0" <cfif OnePlan.ProratePYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Prorate Cutoff Days</td>
		<td><input type="text" name="ProrateCutDays" value="#OnePlan.ProrateCutDays#" maxlength="3" size="3"></td>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>EMail Payment letter</td>
</cfoutput>
		<td colspan="3"><select name="ReminderLetterID">
		<option value="0">None
		<cfoutput query="EMailLetters">
			<option <cfif OnePlan.ReminderLetterID Is IntID>selected</cfif> value="#IntID#">#IntDesc#
		</cfoutput></select></td>
	</tr>
<cfoutput>
	<tr bgcolor="#thclr#">
		<th colspan="4">Account Wizard</th>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Postal Option</td>
		<td><input type="radio" name="AWPostOptYN" value="1" <cfif OnePlan.AWPostOptYN is 1>Checked</cfif> >Yes <input type="radio" name="AWPostOptYN" value="0" <cfif OnePlan.AWPostOptYN is 0>Checked</cfif> >No</td>		
		<td bgcolor="#tbclr#" align=right>Postal Option Default</td>
		<td><input type="radio" name="AWPostOptDef" value="1" <cfif OnePlan.AWPostOptDef is 1>Checked</cfif> >Yes <input type="radio" name="AWPostOptDef" value="0" <cfif OnePlan.AWPostOptDef is 0>Checked</cfif> >No</td>		
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Charge for Postal</td>
		<td><input type="radio" name="AWChrgPostYN" value="1" <cfif OnePlan.AWChrgPostYN is 1>Checked</cfif> >Yes <input type="radio" name="AWChrgPostYN" value="0" <cfif OnePlan.AWChrgPostYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Amount</td>
		<td><input type="text" name="AWChrgAmount" value="#Trim(LSNumberFormat(OnePlan.AWChrgAmount, '999999999999.99'))#" size="5"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Postal Charge Recurring</td>
		<td><input type="radio" name="AWChrgPostRecYN" value="1" <cfif OnePlan.AWChrgPostRecYN is 1>Checked</cfif> >Yes <input type="radio" name="AWChrgPostRecYN" value="0" <cfif OnePlan.AWChrgPostRecYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="AWChrgPostTax" value="0" <cfif OnePlan.AWChrgPostTax is 0>Checked</cfif> >Taxfree <input type="radio" name="AWChrgPostTax" value="1" <cfif OnePlan.AWChrgPostTax is 1>Checked</cfif> >Service <input type="radio" name="AWChrgPostTax" value="2" <cfif OnePlan.AWChrgPostTax is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="AWChrgPostMemo" value="#OnePlan.AWChrgPostMemo#" size="50" maxlength="150"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Notes To Staff.</td>
		<cfif HTTP_USER_AGENT Contains "MSIE">
			<cfset TextAreaWide = 45>
		<cfelse>
			<cfset TextAreaWide = 50>
		</cfif>
		<td colspan="3">(This will display to gBill staff only.)<br><textarea name="AWPlanDisplay" rows="5" cols="#TextAreaWide#">#OnePlan.AWPlanDisplay#</textarea></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Payment Options</td>
		<td colspan="3"><input type="checkbox" name="AWPayCK" <cfif OnePlan.AWPayCK Is "1">checked</cfif> value="1">Check/Cash <input type="checkbox" name="AWPayCD" <cfif OnePlan.AWPayCD Is "1">checked</cfif> value="1">Check Debit <input type="checkbox" name="AWPayCC" <cfif OnePlan.AWPayCC Is "1">checked</cfif> value="1">Credit Card <input type="checkbox" name="AWPayPO" <cfif OnePlan.AWPayPO Is "1">checked</cfif> value="1">PO</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<cfif AWTypes.RecordCount GT 0>
			<cfset thisrowspan = 2>
		<cfelse>
			<cfset thisrowspan = 1>			
		</cfif>
		<td rowspan="#thisrowspan#" bgcolor="#tbclr#" align="right">Credit Cards</td>
</cfoutput>
		<cfif AWTypes.RecordCount GT 0>
			<cfset countrow = 0>
			<td colspan="3"><cfoutput query="AWTypes"><cfset countrow = countrow + 1><input type="checkbox" <cfif Sel Is 1>checked</cfif> name="AWCardType" value="#CardTypeID#">#CardType#<cfif countrow Is 4><br><cfset countrow = 0></cfif> </cfoutput>
	</tr>
		</cfif>
<cfoutput>
	<cfif AWTypes.RecordCount GT 0>
	<tr valign="top">
	</cfif>
		<td colspan="3" bgcolor="#tdclr#"><input type="checkbox" <cfif OnePlan.AWUseADebit Is 1>checked</cfif> name="AWUseADebit" value="1">Auto Debit <input type="checkbox" <cfif OnePlan.AWUseAVS Is 1>checked</cfif> name="AWUseAVS" value="1">Use AVS <input type="checkbox" <cfif OnePlan.AWChkMod Is 1>checked</cfif> name="AWChkMod" value="1">Enforce Mod10</td>
	</tr>
	<tr bgcolor="#thclr#">
		<th colspan="4">Signup Wizard</th>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Postal Option</td>
		<td><input type="radio" name="OSPostOptYN" value="1" <cfif OnePlan.OSPostOptYN is 1>Checked</cfif> >Yes <input type="radio" name="OSPostOptYN" value="0" <cfif OnePlan.OSPostOptYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Default</td>
		<td><input type="radio" name="OSPostOptDef" value="1" <cfif OnePlan.OSPostOptDef is 1>Checked</cfif> >Yes <input type="radio" name="OSPostOptDef" value="0" <cfif OnePlan.OSPostOptDef is 0>Checked</cfif> >No</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Charge for Postal</td>
		<td><input type="radio" name="OSChrgPostYN" value="1" <cfif OnePlan.OSChrgPostYN is 1>Checked</cfif> >Yes <input type="radio" name="OSChrgPostYN" value="0" <cfif OnePlan.OSChrgPostYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Amount</td>
		<td><input type="text" name="OSChrgAmount" value="#Trim(LSNumberFormat(OnePlan.OSChrgAmount, '999999999999.99'))#" size="5"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Postal Charge Recurring</td>
		<td><input type="radio" name="OSChrgPostRecYN" value="1" <cfif OnePlan.OSChrgPostRecYN is 1>Checked</cfif> >Yes <input type="radio" name="OSChrgPostRecYN" value="0" <cfif OnePlan.OSChrgPostRecYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align="right">Tax Type</td>
		<td><input type="radio" name="OSChrgPostTax" value="0" <cfif OnePlan.OSChrgPostTax is 0>Checked</cfif> >Taxfree <input type="radio" name="OSChrgPostTax" value="1" <cfif OnePlan.OSChrgPostTax is 1>Checked</cfif> >Service <input type="radio" name="OSChrgPostTax" value="2" <cfif OnePlan.OSChrgPostTax is 2>Checked</cfif> >Good</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Transaction Memo</td>
		<td colspan="3"><input type="text" name="OSChrgPostMemo" value="#OnePlan.OSChrgPostMemo#" size="50" maxlength="150"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Payment Options</td>
		<td colspan="3"><input type="checkbox" <cfif OnePlan.OSPayCK Is "1">checked</cfif> name="OSPayCK" value="1">Check/Cash <input type="checkbox" <cfif OnePlan.OSPayCD Is "1">checked</cfif> name="OSPayCD" value="1">Check Debit <input type="checkbox" <cfif OnePlan.OSPayCC Is "1">checked</cfif> name="OSPayCC" value="1">Credit Card <input type="checkbox" <cfif OnePlan.OSPayPO Is "1">checked</cfif> name="OSPayPO" value="1">PO</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Auto Activate</td>	
		<td colspan="3" bgcolor="#tdclr#"><input type="checkbox" name="AutoActCK" <cfif OnePlan.AutoActCK Is "1">checked</cfif> value="1">Check/Cash <input type="checkbox" name="AutoActCD" <cfif OnePlan.AutoActCD Is "1">checked</cfif> value="1">Check Debit <input type="checkbox" name="AutoActCC" <cfif OnePlan.AutoActCC Is "1">checked</cfif> value="1">Credit Card <input type="checkbox" <cfif OnePlan.AutoActPO Is "1">checked</cfif> name="AutoActPO" value="1">PO</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<cfif OSTypes.RecordCount GT 0>
			<cfset thisrowspan = 2>
		<cfelse>
			<cfset thisrowspan = 1>			
		</cfif>
		<td rowspan="#thisrowspan#" bgcolor="#tbclr#" align="right">Credit Cards</td>
</cfoutput>
		<cfif AWTypes.RecordCount GT 0>
			<cfset countrow = 0>
			<td colspan="3"><cfoutput query="OSTypes"><cfset countrow = countrow + 1><input type="checkbox" <cfif Sel Is 1>checked</cfif> name="OSCardType" value="#CardTypeID#">#CardType#<cfif countrow Is 4><br><cfset countrow = 0></cfif> </cfoutput>
	</tr>
		</cfif>
<cfoutput>
	<cfif OSTypes.RecordCount GT 0>
	<tr valign="top">
	</cfif>
		<td colspan="3" bgcolor="#tdclr#"><input type="checkbox" <cfif OnePlan.OSUseADebit Is 1>checked</cfif> name="OSUseADebit" value="1">Auto Debit <input type="checkbox" <cfif OnePlan.OSUseAVS Is 1>checked</cfif> name="OSUseAVS" value="1">Use AVS <input type="checkbox" <cfif OnePlan.OSChkMod Is 1>checked</cfif> name="OSChkMod" value="1">Enforce Mod10</td>
	</tr>
	<tr>
		<th colspan="4"><input type="image" src="images/update.gif" border="0" name="updtab2"></th>
	</tr>
</cfoutput>
</form>





