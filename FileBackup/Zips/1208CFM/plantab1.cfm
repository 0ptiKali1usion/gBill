<!-- Version 4.0.0 -->
<!--- This is the general tab for the plans setup.--->
<!--- 4.0.0 07/18/99
		3.2.0 09/08/98 --->
<!-- plantab1.cfm -->
<cfoutput>
<form method="post" action="listplan2.cfm">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="PlanID" value="#PlanID#">
	<tr>
		<td bgcolor="#tbclr#" align=right>Plan Name</td>
		<Input type="hidden" name="PlanDesc_Required" Value="You must enter a plan description.">
		<td bgcolor="#tdclr#" colspan="3"><Input type="text" name="PlanDesc" Value="#OnePlan.PlanDesc#" size="35" maxlength="100"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Plan Description</td>
		<cfif HTTP_USER_AGENT Contains "MSIE">
			<cfset TextAreaWide = 45>
		<cfelse>
			<cfset TextAreaWide = 50>
		</cfif>
		<td colspan="3">(This will display in the Wizards.)<br><textarea name="OSPlanDisplay" rows="5" cols="#TextAreaWide#">#OnePlan.OSPlanDisplay#</textarea></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Promo/ Signup Code</td>
		<td colspan="3"><input type="text" name="TotalInternetCode" value="#OnePlan.TotalInternetCode#" maxlength="20"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Select EMail Welcome letter</td>
</cfoutput>
		<td colspan="3"><select name="EMailLetterID">
		<option value="0">None
		<cfoutput query="EMailLetters">
			<option <cfif OnePlan.EMailLetterID Is IntID>selected</cfif> value="#IntID#">#IntDesc#
		</cfoutput></select></td>
	</tr>
<cfoutput>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Delay EMail Letter by</td>
		<td colspan="3"><input type="text" value="#OnePlan.EMailDelayMins#" name="EMailDelayMins" size="3" maxlength="3"> minutes</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Account Wizard List</td>
		<td><input type="radio" name="ShowAWYN" value="1" <cfif OnePlan.ShowAWYN is Not 0>Checked</cfif> >Yes <input type="radio" name="ShowAWYN" value="0" <cfif OnePlan.ShowAWYN is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>Online Signup List</td>
		<td><input type="radio" name="ShowYN" value="1" <cfif OnePlan.ShowYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="ShowYN" value="0" <cfif OnePlan.ShowYN is 0>Checked</cfif> >No</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
		<td align=right bgcolor="#tbclr#">Expires</td>
		<Input type="hidden" name="expiredays_float" Value="You must enter an amount.">
		<td bgcolor="#tdclr#"><INPUT type="text" name="expiredays" Value="#OnePlan.expiredays#" size="4"> Days</td>
		<td bgcolor="#tbclr#" colspan="2">Enter 0 For No expiration.</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
		<td align=right bgcolor="#tbclr#">Expire To</td>
</cfoutput>
		<td colspan="3"><select name="expireto">
			<option value="0">N/A
			<cfoutput query="AllPlans">
				<option <cfif OnePlan.ExpireTo Is PlanID>selected</cfif> value="#PlanID#">#PlanDesc#
			</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr>
		<th colspan="4" bgcolor="#thclr#">Public Access Customer Privileges</th>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
		<td align=right bgcolor="#tbclr#">Address Info Editable</td>
		<td><input type="radio" name="CustInfoYN" value="1" <cfif OnePlan.CustInfoYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustInfoYN" value="0" <cfif OnePlan.CustInfoYN Is 0>Checked</cfif> >No</td>		
		<td align=right bgcolor="#tbclr#">Payment Info Editable</td>
		<td><input type="radio" name="CustPayYN" value="1" <cfif OnePlan.CustPayYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustPayYN" value="0" <cfif OnePlan.CustPayYN Is 0>Checked</cfif> >No</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
		<td align=right bgcolor="#tbclr#">POP Editable</td>
		<td><input type="radio" name="CustPOPYN" value="1" <cfif OnePlan.CustPOPYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustPOPYN" value="0" <cfif OnePlan.CustPOPYN Is 0>Checked</cfif> >No</td>
		<td align=right bgcolor="#tbclr#">Password Editable</td>
		<td><input type="radio" name="CustPassYN" value="1" <cfif OnePlan.CustPassYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustPassYN" value="0" <cfif OnePlan.CustPassYN Is 0>Checked</cfif> >No</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
		<td align=right bgcolor="#tbclr#">Allow Customer E-Mail Setup</td>
		<td><input type="radio" name="CustEMailYN" value="1" <cfif OnePlan.CustEMailYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustEMailYN" value="0" <cfif OnePlan.CustEMailYN Is 0>Checked</cfif> >No</td>
		<td align=right bgcolor="#tbclr#">Show Scheduled Events</td>
		<td><input type="radio" name="CustEventYN" value="1" <cfif OnePlan.CustEventYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="CustEventYN" value="0" <cfif OnePlan.CustEventYN Is 0>Checked</cfif> >No</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>View Session History</td>
		<td><input type="radio" name="SessYN" value="1" <cfif OnePlan.SessYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="SessYN" value="0" <cfif #OnePlan.SessYN# Is 0>Checked</cfif> >No</td>
		<td bgcolor="#tbclr#" align=right>View Payment History</td>
		<td><input type="radio" name="PayHistYN" value="1" <cfif OnePlan.PayHistYN Is Not 0>Checked</cfif> >Yes <input type="radio" name="PayHistYN" value="0" <cfif OnePlan.PayHistYN Is 0>Checked</cfif> >No</td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Custom Link URL</td>
		<td colspan="3"><input type="text" name="CustLinkURL" value="#OnePlan.CustLinkURL#" maxlength="150" size="35"></td>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Custom Link Graphic</td>
		<td colspan="3"><input type="text" name="CustLinkGraphic" value="#OnePlan.CustLinkGraphic#" maxlength="35" size="35"></td>
	</tr>
	<tr>
		<cfif PlanID GT 0>
			<th colspan="4"><input type="image" src="images/update.gif" border="0" name="UpdTab1"></th>
		<cfelse>
			<th colspan="4"><input type="image" src="images/enter.gif" border="0" name="AddNewPlan"></th>
		</cfif>
	</tr>
</cfoutput>
</form>




