<!-- Version 4.0.0 -->
<!--- This is the metered tab for the plans setup.--->
<!--- 4.0.0 07/17/99
		3.2.0 09/08/98 --->
<!-- plantab4.cfm -->

<cfoutput>
<cfif Not IsDefined("addnew.x")>
	<tr>
		<form method="post" name="AddNew" action="listplan2.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="page" value="#page#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="planid" value="#planid#">
			<td align="right" colspan="#HowWide#"><input type="image" src="images/addnew.gif" name="AddNew" border="0"></td>
		</form>
	</tr>
</cfif>
<tr bgcolor="#thclr#">
	<cfif (Not IsDefined("EditOne")) AND (Not IsDefined("AddNew.x"))>
		<th>Edit</th>
	</cfif>
	<th>Over Chrg</th>
	<th>Over Unit</th>
	<th>Base Hours</th>
	<th colspan="2">Period/ Days</th>
	<th>Begin Time</th>
	<th>End Time</th>
	<cfif (Not IsDefined("EditOne")) AND (Not IsDefined("AddNew.x"))>
		<th>Delete</th>
	</cfif>
</tr>
</cfoutput>
<cfif IsDefined("addnew.x")>
<!--- Section for adding a new span --->
	<cfoutput>
	<form method="post" action="listplan2.cfm" name="spanchk">
		<input type="hidden" name="tab" value="#tab#">
		<input type="hidden" name="spanunit_required" value="UNIT - Please enter the unit being measured">
		<input type="hidden" name="baseamount_required" value="BASE - Please enter the amount that is free">
		<input type="hidden" name="overcharge_required" value="OVER CHRG - Please enter the amount charged per unit over the base">
		<input type="hidden" name="page" value="#page#">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">
		<input type="hidden" name="planid" value="#planid#">
		<tr>
			<td colspan="2" bgcolor="#tbclr#" align="right">Description</td>
			<td colspan="5" bgcolor="#tdclr#"><input type="Text" name="SpanDescrip" size="45"></td>
		</tr>
		<tr valign="top" bgcolor="#tdclr#">
			<td><input type="text" name="overcharge" size="6" maxlength="8"></td>			
			<td><select name="spanunit">
				<option value="Hours">Hours
				<option value="SetFee">Set Fee
			</select></td>
			<td><input type="text" name="baseamount" size="3" maxlength="8"></td>
			<td><input checked TYPE="Radio" NAME="spanperiod" VALUE="1"> Monthly</td>
			<td><input TYPE="Radio" NAME="spanperiod" VALUE="0"> Daily<br>
				<select name="dofwk1" multiple size="7">
					<option value="1">Sunday
					<option value="2">Monday
					<option value="3">Tuesday
					<option value="4">Wednesday
					<option value="5">Thursday
					<option value="6">Friday
					<option value="7">Saturday
			</select></td>
	</cfoutput>
			<td><select name="ss1">
				<cfloop index="B5" from="0" to="23">
					<cfif #B5# lt 10><cfset #B5# = "0#B5#"></cfif>
				   <cfloop index="B4" from="0" to="45" step="15">
						<cfif #B4# lt 10><cfset #B4# = "0#B4#"></cfif>
						<cfoutput><option value="#B5##B4#">#B5#:#B4#</cfoutput>
	   			</cfloop>
				</cfloop>
			</select></td>
			<td><select name="se1" onChange="checkit()">
				<cfloop index="B5" from="0" to="23">
					<cfif #B5# lt 10><cfset #B5# = "0#B5#"></cfif>
				   <cfloop index="B4" from="0" to="45" step="15">
						<cfif #B4# lt 10><cfset #B4# = "0#B4#"></cfif>
						<cfoutput><option value="#B5##B4#">#B5#:#B4#</cfoutput>
					</cfloop>
				</cfloop>
				<option selected value="2359">23:59
			</select></td>
		</tr>
		<tr>
			<cfoutput>
				<th colspan="#HowWide#"><input type="image" src="images/enter.gif" name="EnterNewSpan" border="0"></th>
			</cfoutput>
		</tr>
	</form>
<cfelseif IsDefined("EditOne")>
	<cfoutput>
	<form method="post" action="listplan2.cfm" name="spanchk3">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="page" value="#page#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="planid" value="#planid#">
	</cfoutput>
	<cfloop query="OneSpan">
		<cfoutput>
		<input type="hidden" name="spanid" value="#spanid#">
		<tr valign="top" bgcolor="#tdclr#">
			<td colspan="2" align="right">Description:</td>
			<td colspan="5"><input type="text" name="SpanDescrip" value="#SpanDescrip#" size="55"></td>
		</tr>
		<tr valign="top" bgcolor="#tdclr#">
			<td><input type="text" value="#overcharge#" name="overcharge" size="6" maxlength="8"></td>
			<td><select name="spanunit">
				<option <cfif #SpanUnit# is "Hours">selected</cfif> value="Hours">Hours
			</select></td>
			<td><input type="text" value="#baseamount#" name="baseamount" size="3" maxlength="8"></td>
		</cfoutput>
			<td><input <cfif spanperiod is 1>checked</cfif> TYPE="Radio" NAME="spanperiod" VALUE="1"> Monthly</td>
			<cfquery name="getdays" datasource="#pds#">
				SELECT * FROM plans2spans WHERE spanid = #spanid#
			</cfquery>
			<cfset #thedays1# = #Valuelist(getdays.dofwk)#>
			<td><input <cfif spanperiod is 0>checked</cfif> TYPE="Radio" NAME="spanperiod" VALUE="0"> Daily<br>
			<select name="dofwk1" multiple size="7">
				<option <cfif #thedays1# contains 1>selected</cfif> value="1">Sunday
				<option <cfif #thedays1# contains 2>selected</cfif> value="2">Monday
				<option <cfif #thedays1# contains 3>selected</cfif> value="3">Tuesday
				<option <cfif #thedays1# contains 4>selected</cfif> value="4">Wednesday
				<option <cfif #thedays1# contains 5>selected</cfif> value="5">Thursday
				<option <cfif #thedays1# contains 6>selected</cfif> value="6">Friday
				<option <cfif #thedays1# contains 7>selected</cfif> value="7">Saturday
			</select></td>
			<td><select name="ss1">
				<cfloop index="B5" from="0" to="23">
					<cfif #B5# lt 10><cfset #B5# = "0#B5#"></cfif>
					<cfloop index="B4" from="0" to="45" step="15">
						<cfif #B4# lt 10><cfset #B4# = "0#B4#"></cfif>
						<cfoutput><option <cfif #TimeFormat(spanstart, 'HHmm')# is "#B5##B4#">selected</cfif> value="#B5##B4#">#B5#:#B4#</cfoutput>
	   			</cfloop>
				</cfloop>
			</select></td>
			<cfset #spanend1# = DateAdd("s","1","#spanend#")>
		   <cfif #TimeFormat(spanend, 'HHmm')# is "2359">
			   <cfset #spanend1# = DateAdd("s","-59","#spanend#")>
		   </cfif>
			<td><select name="se1" onChange="checkit2()">
				<cfloop index="B5" from="0" to="23">
					<cfif #B5# lt 10><cfset #B5# = "0#B5#"></cfif>
				   <cfloop index="B4" from="0" to="45" step="15">
						<cfif #B4# lt 10><cfset #B4# = "0#B4#"></cfif>
						<cfoutput><option <cfif #TimeFormat(spanend1, 'HHmm')# is "#B5##B4#">selected</cfif> value="#B5##B4#">#B5#:#B4#</cfoutput>
				   </cfloop>
				</cfloop>
				<option <cfif #TimeFormat(spanend1, 'HHmm')# is "2359">selected</cfif> value="2359">23:59
			</select></td>
		</tr>
	</cfloop>
	<tr>
		<cfoutput>
			<th colspan="#HowWide#"><input type="image" src="images/edit.gif" name="EditMe" border="0"></th>
		</cfoutput>
	</tr>
	</form>
</cfif>
<!--- List all spans section --->
<cfoutput>
<form method="post" action="listplan2.cfm" name="EditInfo">
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
</cfoutput>
<cfset counter1 = 0>
<cfloop query="getinfo">
	<cfset counter1 = counter1 + 1>
	<cfoutput>
		<tr valign="top" bgcolor="#tbclr#">
			<cfif (Not IsDefined("EditOne")) AND (Not IsDefined("AddNew.x"))>
				<th rowspan="2" bgcolor="#tdclr#"><input type="radio" name="EditOne" value="#SpanID#" onClick="submit()"></th>
			</cfif>
			<td colspan="7">#SpanDescrip#<cfif SpanDescrip Is "">&nbsp;</cfif></td>
			<cfif (Not IsDefined("EditOne")) AND (Not IsDefined("AddNew.x"))>
				<th rowspan="2" bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#SpanID#" onClick="SetValues(#SpanID#,this)"></th>
			</cfif>
		</tr>
		<tr valign="top" bgcolor="#tbclr#">
			<td align="right">#LsCurrencyFormat(OverCharge)#</td>			
			<td>#SpanUnit#</td>
			<td align="right">#BaseAmount#</td>
			<td><cfif SpanPeriod is "0">Daily<cfelse>Monthly</cfif></td>
	</cfoutput>
			<cfquery name="getdays" datasource="#pds#">
				SELECT * FROM plans2spans WHERE spanid = #spanid#
			</cfquery>
			<cfset thedays1 = #Valuelist(getdays.dofwk)#>
			<td><cfloop query="getdays">
				<cfoutput>#Mid(DayOfWeekAsString(dofwk),1,2)#</cfoutput>
			</cfloop>&nbsp;</td>
	<cfoutput>
			<td>#TimeFormat(SpanStart, 'HH:MM:SS')#</td>
			<td>#TimeFormat(SpanEnd, 'HH:MM:SS')#</td>
		</tr>
	</cfoutput>
</cfloop>
<cfoutput>
	<input type="hidden" name="LoopCount" value="#counter1#">
</cfoutput>
</form>

<cfif (Not IsDefined("EditOne")) AND (Not IsDefined("AddNew.x"))>
<tr>
<form method="post" name="PickDelete" action="listplan2.cfm" onSubmit="return confirm('Click OK to confirm deleting the selected spans.')">
	<cfoutput>
		<input type="hidden" name="tab" value="#tab#">
		<input type="hidden" name="page" value="#page#">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">
		<input type="hidden" name="planid" value="#planid#">
		<input type="hidden" name="DelThese" value="0">
		<th colspan="#HowWide#"><input type="image" src="images/delete.gif" name="DelSpan" border="0"></th>
	</cfoutput>
</form>
</tr>
</cfif>
    