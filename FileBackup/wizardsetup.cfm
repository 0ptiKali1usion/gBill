<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account/ Online Signup  Wizard Setup.  --->
<!---	4.0.0 07/09/99 --->
<!--- wizardsetup.cfm --->
<cfif (IsDefined("DeleteSelected.x")) AND (IsDefined("DelThese"))>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM WizardSetup 
		WHERE WizID In (#DelThese#)
	</cfquery>
</cfif>
<cfif IsDefined("Add.x")>
	<cfif Trim(InputSize) Is "">
		<cfset TheInputSize = 0>
	<cfelse>
		<cfset TheInputSize = InputSize>
	</cfif>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO WizardSetup 
		(BOBFieldName, BOBDesc, ScreenPrompt, PageNumber, SortOrder, ActiveYN, 
		 CFVarYN, InputRequired, OSUseYN, AWUseYN, RowOrder, IsDeletable, InputSize, 
		 DataType, InputMaxSize)
		VALUES 
		('#BOBFieldName#', <cfif Trim(BOBDesc) Is "">NULL<cfelse>'#BOBDesc#'</cfif>, 
		 <cfif Trim(ScreenPrompt) Is "">Null<cfelse>'#ScreenPrompt#'</cfif>, 
		 #PageNumber#, #SortOrder#, 1, 0, #InputRequired#, #OSUseYN#, #AWUseYN#, #RowOrder#, 1, 
		 #TheInputSize#, '#DataType#', <cfif InputMaxSize Is "">Null<cfelse>#InputMaxSize#</cfif>)
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Edited Add User Setup','#StaffMemberName.FirstName# #StaffMemberName.LastName# added #ScreenPrompt# to the add user setup.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdateData.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("WizID#B5#")>
		<cfset var2 = Evaluate("ScreenPrompt#B5#")>
		<cfif IsDefined("InputRequired#B5#")>
			<cfset var3 = 1>
		<cfelse>
			<cfset var3 = 0>
		</cfif>
		<cfif IsDefined("AWUseYN#B5#")>
			<cfset var4 = 1>
		<cfelse>
			<cfset var4 = 0>
		</cfif>
		<cfif IsDefined("OSUseYN#B5#")>
			<cfset var5 = 1>
		<cfelse>
			<cfset var5 = 0>
		</cfif>
		<cfset var6 = Evaluate("RowOrder#B5#")>
		<cfset var7 = Evaluate("SortOrder#B5#")>
		<cfif IsDefined("ActiveYN#B5#")>
			<cfset var8 = 1>
		<cfelse>
			<cfset var8 = 0>
		</cfif>
		<cfset var9 = Evaluate("InputSize#B5#")>
		<cfset var10 = Evaluate("DataType#B5#")>
		<cfset var11 = Evaluate("InputMaxSize#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE WizardSetup SET 
			ScreenPrompt = <cfif Trim(var2) Is "">Null<cfelse>'#var2#'</cfif>, 
			InputRequired = #var3#, 
			ActiveYN = #var8#, 
			InputSize = #var9#, 
			InputMaxSize = <cfif Var11 Is "">Null<cfelse>#var11#</cfif>, 
			AWUseYN = #var4#, 
			OSUseYN = #var5#, 
			RowOrder = #var6#, 
			SortOrder = #var7#, 
			DataType = '#var10#' 
			WHERE WizID = #var1#
		</cfquery>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Edited Add User Setup','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the add user setup.')
		</cfquery>
	</cfif>
</cfif>
<cfparam name="tab" default="1">
<cfif tab LTE 5>
	<cfset HowWide = 12>
	<cfquery name="Page1" datasource="#pds#">
		SELECT * 
		FROM WizardSetup 
		WHERE PageNumber = #tab# 
		ORDER BY RowOrder, SortOrder
	</cfquery>
<cfelseif tab Is 20>
	<cfset HowWide = 2>
	<cfquery name="GetData" datasource="#pds#">
		SELECT max(RowOrder) as MaxRows 
		FROM WizardSetup 
		WHERE PageNumber = #PageNumber# 
		AND RowOrder < 999 
	</cfquery>
	<cfset NewRow = GetData.MaxRows + 1>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Wizard Setup</title>
<cfif tab LTE 5>
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.CountDel.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Wizard Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="wizardsetup.cfm">
						<td bgcolor=<cfif tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input <cfif tab Is 1>checked</cfif> type="radio" name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Personal</label></td>
						<td bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input <cfif tab Is 2>checked</cfif> type="radio" name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Support</label></td>
						<td bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input <cfif tab Is 3>checked</cfif> type="radio" name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Service</label></td>
						<td bgcolor=<cfif tab Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input <cfif tab Is 4>checked</cfif> type="radio" name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Integration</label></td>
						<td bgcolor=<cfif tab Is 5>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input <cfif tab Is 5>checked</cfif> type="radio" name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">Financial</label></td>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif tab LTE 5>
	<cfoutput>
		<tr>
			<form method="post" name="AddNew" action="wizardsetup.cfm">
				<input type="hidden" name="tab" value="20">
				<input type="hidden" name="PageNumber" value="#tab#">
				<td align="right" colspan="12"><input type="image" src="images/addnew.gif" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Active</th>
			<th>Description</th>
			<th>Screen Prompt</th>
			<th>Type</th>
			<th>Size</th>
			<th>Max Size</th>
			<th>Req.</th>
			<th>AW</th>
			<th>OS</th>
			<th>Row</th>
			<th>Order</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<cfset counter1 = 0>
	<cfset countdel = 0>
	<form method="post" name="EditInfo" action="wizardsetup.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="#tab#">
		</cfoutput>
		<cfoutput query="Page1">
			<cfset counter1 = counter1 + 1>
			<tr valign="top">
				<input type="hidden" name="WizID#counter1#" value="#WizID#">
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 1>&nbsp;<input type="hidden" name="ActiveYN#counter1#" value="1"><cfelse><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#counter1#" value="1"></cfif></th>
				<td bgcolor="#tbclr#">#BOBDesc#</td>
				<td bgcolor="#tdclr#"><input type="text" name="ScreenPrompt#counter1#" value="#ScreenPrompt#" maxlength="100"></td>
				<td bgcolor="#tdclr#"><select name="DataType#counter1#">
					<option <cfif DataType Is "Date">selected</cfif> value="Date">Date Time
					<option <cfif DataType Is "Number">selected</cfif> value="Number">Number
					<option <cfif DataType Is "Text">selected</cfif> value="Text">Text
				</select></td>
				<td bgcolor="#tdclr#"><input type="text" name="InputSize#counter1#" value="#InputSize#" size="3"></td>
				<td bgcolor="#tdclr#"><input type="text" name="InputMaxSize#counter1#" value="#InputMaxSize#" size="3"></td>
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 1>#YesNoFormat(InputRequired)#<input type="hidden" name="InputRequired#counter1#" value="1"><cfelse><input type="checkbox" name="InputRequired#counter1#" <cfif InputRequired Is 1>checked</cfif> value="#InputRequired#"></cfif></th>
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 1>#YesNoFormat(AWUseYN)#<input type="hidden" name="AWUseYN#counter1#" value="1"><cfelse><input type="checkbox" name="AWUseYN#counter1#" <cfif AWUseYN Is 1>checked</cfif> value="#AWUseYN#"></cfif></th>
				<th bgcolor="#tdclr#"><cfif CFVarYN Is 1>#YesNoFormat(OSUseYN)#<input type="hidden" name="OSUseYN#counter1#" value="1"><cfelse><input type="checkbox" name="OSUseYN#counter1#" <cfif OSUseYN Is 1>checked</cfif> value="#OSUseYN#"></cfif></th>
				<td bgcolor="#tdclr#"><select name="RowOrder#counter1#">
					<cfloop index="B5" from="1" to="#RecordCount#">
						<option <cfif B5 Is RowOrder>selected</cfif> value="#B5#">#B5#
					</cfloop>
					<option <cfif RowOrder Is "999">selected</cfif> value="999">NA
				</select></td>
				<td bgcolor="#tdclr#"><select name="SortOrder#counter1#">
					<cfloop index="B5" from="1" to="#RecordCount#">
						<option <cfif B5 Is SortOrder>selected</cfif> value="#B5#">#B5#
					</cfloop>
					<option <cfif SortOrder Is "999">selected</cfif> value="999">NA
				</select></td>
				<th bgcolor="#tdclr#"><cfif IsDeletable Is 0>&nbsp;<cfelse><cfset countdel = countdel + 1><input type="checkbox" name="DelSelected" value="#WizID#" onClick="SetValues(#WizID#,this)"></cfif></th>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="12">
				<table border="0">
					<tr>
						<cfoutput>
							<input type="hidden" name="LoopCount" value="#Counter1#">
							<input type="hidden" name="CountDel" value="#CountDel#">
						</cfoutput>
						<td><input type="image" src="images/update.gif" name="UpdateData" border="0"></td>
	</form>
	<form method="post" name="PickDelete" action="wizardsetup.cfm" onsubmit="return confirm ('Click Ok to confirm deleting the selected form items.')">
						<input type="hidden" name="DelThese" value="0">
						<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
						<td><input type="image" src="images/delete.gif" name="DeleteSelected" border="0"></td>
					</tr>
				</table>
			</th>
		</tr>
	</form>
<cfelseif tab Is 20>
	<cfoutput>
		<tr>
			<th colspan="2" bgcolor="#thclr#">Add New Form Input</th>
		</tr>
		<form method="post" action="wizardsetup.cfm">
			<input type="hidden" name="PageNumber" value="#PageNumber#">
			<input type="hidden" name="tab" value="#PageNumber#">
			<tr>
				<td align="right" bgcolor="#tbclr#">Database Field Name</td>
				<td bgcolor="#tdclr#"><input type="text" name="BOBFieldName" maxlength="75" size="35"></td>
				<input type="hidden" name="BOBFieldName_Required" value="Please enter the name of the field in the AccntTemp Table.">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Screen Prompt</td>
				<td bgcolor="#tdclr#"><input type="text" name="ScreenPrompt" maxlength="100" size="35"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td bgcolor="#tdclr#"><input type="text" name="BOBDesc" maxlength="150" value="Custom Input for page #Pagenumber#" size="35"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Data Type</td>
				<td bgcolor="#tdclr#"><select name="DataType">
					<option value="Date">Date Time
					<option value="Number">Number
					<option value="Text">Text
				</select></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Text Input Display Size<br>
				<font size="1">(Enter 999 for a textarea<br>
				Enter 0 for Yes No Radio Buttons)</font></td>
				<td bgcolor="#tdclr#"><input type="text" name="InputSize" maxlength="4" size="3"></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Text Input Max Size<br>
				<font size="1">Leave blank for no max size.</font></td>
				<td bgcolor="#tdclr#"><input type="text" name="InputMaxSize" maxlength="4" size="3"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Required</td>
				<td bgcolor="#tdclr#"><input type="radio" name="InputRequired" value="1"> Yes <input type="radio" name="InputRequired" checked value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Use in Account Wizard</td>
				<td bgcolor="#tdclr#"><input type="radio" name="AWUseYN" value="1"> Yes <input type="radio" name="AWUseYN" checked value="0"> No</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Use in Online Signup</td>
				<td bgcolor="#tdclr#"><input type="radio" name="OSUseYN" value="1"> Yes <input type="radio" name="OSUseYN" checked value="0"> No</td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Row Order</td>
	</cfoutput>
				<td><select name="RowOrder">
					<cfloop index="B5" from="1" to="#NewRow#">
						<cfoutput><option <cfif B5 Is NewRow>selected</cfif> value="#B5#">#B5#</cfoutput>
					</cfloop>
				</select></td>
			</tr>
	<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Sort</td>
	</cfoutput>
				<td><select name="SortOrder">
					<cfloop index="B5" from="1" to="#NewRow#">
						<cfoutput><option value="#B5#">#B5#</cfoutput>
					</cfloop>
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="Add" border="0"></th>
			</tr>
		</form>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 