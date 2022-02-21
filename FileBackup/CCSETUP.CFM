<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page sets up the credit card export format. --->
<!---	4.0.0 07/26/99  --->
<!--- ccsetup.cfm --->

<cfinclude template="security.cfm">
<cfparam name="tab2" default="1">
<cfinclude template="ccsetup2.cfm">
<cfif tab2 Is 1>
	<cfparam name="tab" default="1">
<cfelseif tab2 Is 2>
	<cfparam name="tab" default="4">
<cfelseif tab2 Is "4">
	<cfparam name="tab" default="7">
</cfif>
<cfif tab Is 1>
	<cfset HowWide = 5>
	<cfquery name="getaddto" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput
		WHERE UseTab = 0 
	</cfquery>
	<cfloop query="getaddto">
		<cfset "#FieldName1#" = "#Description1#">
	</cfloop>
	<cfparam name="ccdelimit" default=",">
	<cfparam name="ccnumfield" default="15">
	<cfparam name="ccenclose" default="0">
	<cfparam name="ccenclosenull" default="1">
	<cfparam name="ccoutputheadrow" default="0">
	<cfparam name="cchrout" default="">
	<cfparam name="ccdateformat" default="MM-DD-YYYY">
	<cfparam name="cctimeformat" default="hh:mm:ss">
	<cfparam name="ccamountformat" default="">
	<cfparam name="ccamountperiod" default="1">
	<cfparam name="ccyearformat" default="YYYY">
	<cfparam name="ccoutpath" default="#BillPath#">
	<cfparam name="ccoutfile" default="ccard.txt">
	<cfparam name="MaxPerFile" default="5000">
<cfelseif tab Is 2>
	<cfset HowWide = 4>
	<cfquery name="alloptions" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 1 
		ORDER BY useyn desc, sortorder
	</cfquery>
	<cfset counter1 = 0>
<cfelseif tab Is 3>
	<cfset HowWide = 4>
	<cfquery name="AllOptions" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 2 
		ORDER BY useyn desc, sortorder
	</cfquery>
	<cfif AllOptions.Recordcount Is 0>
		<cfquery name="CopyOver" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(fieldname1, description1, useyn, sortorder, cfvaryn, UseTab)
			SELECT fieldname1, description1, useyn, sortorder, cfvaryn, 2 
			FROM CustomCCOutput 
			WHERE UseTab = 1 
			AND cfvaryn = 1
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			Description1 = 'Amount Credited' 
			WHERE FieldName1 = 'Bal' 
			AND UseTab = 2 
			AND CFVarYN = 1
		</cfquery>
		<cfquery name="AllOptions" datasource="#pds#">
			SELECT * 
			FROM CustomCCOutput 
			WHERE UseTab = 2 
			ORDER BY useyn desc, sortorder
		</cfquery>
	</cfif>
	<cfset counter1 = 0>
<cfelseif tab Is 4>
	<cfset HowWide = 4>
	<cfparam name="ccinputlines" default="1">
	<cfparam name="ccinputheadrow" default="0">
	<cfquery name="GetHeadRow" datasource="#pds#">
		SELECT FieldName1, Description1 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccinputheadrow' 
		AND UseTab = 4 
	</cfquery>
	<cfif GetHeadRow.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab)
			VALUES 
			('ccinputheadrow', '0', 1, 1, 1, 4)
		</cfquery>
		<cfquery name="GetHeadRow" datasource="#pds#">
			SELECT FieldName1, Description1 
			FROM CustomCCOutput 
			WHERE FieldName1 = 'ccinputheadrow' 
			AND UseTab = 4 
		</cfquery>
	</cfif>		
	<cfquery name="GetInputLines" datasource="#pds#">
		SELECT FieldName1, Description1 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccinputlines' 
		AND UseTab = 4
	</cfquery>
	<cfif GetInputLines.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab)
			VALUES 
			('ccinputlines', '1', 1, 1, 1, 4)
		</cfquery>
		<cfquery name="GetInputLines" datasource="#pds#">
			SELECT FieldName1, Description1 
			FROM CustomCCOutput 
			WHERE FieldName1 = 'ccinputlines' 
			AND UseTab = 4
		</cfquery>
	</cfif>		
	<cfquery name="GetCodeWide" datasource="#pds#">
		SELECT FieldName1, Description1 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'CodeWide' 
		AND UseTab = 4
	</cfquery>
	<cfif GetCodeWide.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab)
			VALUES 
			('CodeWide', '1', 1, 1, 1, 4)
		</cfquery>
		<cfquery name="GetCodeWide" datasource="#pds#">
			SELECT FieldName1, Description1 
			FROM CustomCCOutput 
			WHERE FieldName1 = 'CodeWide' 
			AND UseTab = 4
		</cfquery>
	</cfif>		
	<cfloop query="GetHeadRow">
		<cfset "#FieldName1#" = Description1>
	</cfloop>
	<cfloop query="GetInputLines">
		<cfset "#FieldName1#" = Description1>
	</cfloop>
	<cfloop query="GetCodeWide">
		<cfset "#FieldName1#" = Description1>
	</cfloop>
	<cfquery name="allinput" datasource="#pds#">
		SELECT * 
		FROM CustomCCInput 
		ORDER BY UseYN desc, LineOrder, SortOrder
	</cfquery>
	<cfset counter1 = 0>
<cfelseif tab Is 7>
	<cfset HowWide = 3>
	<cfquery name="GetValues" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 3 
		AND UseYN = 0 
		ORDER BY SortOrder, FieldName1 
	</cfquery>
	<cfloop query="GetValues">
		<cfif FieldValue Is 1><cfset CCCompSel = Description1></cfif>
	</cfloop>
	<cfquery name="GetSetups" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 5 
		AND fieldname1 <> 'Mode' 
		ORDER BY UseYN desc, SortOrder, Description1 
	</cfquery>
	<cfquery name="TestMode" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 5 
		AND fieldname1 = 'Mode' 
	</cfquery>
	<cfquery name="CheckLock" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 6 
		AND CFVarYN = 1 
		AND FieldName1 = 'CCAutoLock' 
	</cfquery>
	<cfparam name="FormTab" default="1">
	<cfparam name="CCCompSel" default="N/A">
	<cfif FormTab Is 2>
		<cfset HowWide = 4>
		<cfquery name="AllFormFields" datasource="#pds#">
			SELECT * 
			FROM CustomCCOutput 
			WHERE UseTab = 7 
			ORDER BY SortOrder, FieldName1 
		</cfquery>
		<cfset JSScript = "<script language=""javascript"">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
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
">	
		<cfhtmlhead text="#JSScript#">
	<cfelseif FormTab Is 3>
		<cfset HowWide = 2>
		<cfquery name="GetCCInfoTab8" datasource="#pds#">
			SELECT * 
			FROM CustomCCOutput 
			WHERE UseTab = 8 
			ORDER BY SortOrder, Description1 
		</cfquery>
	</cfif>
<cfelseif tab Is 21>
	<cfset HowWide = 3>
<cfelseif tab Is 22>
	<cfset HowWide = 3>
<cfelseif tab Is 23>
	<cfset HowWide = 3>
<cfelseif tab Is 24>
	<cfset HowWide = 4>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<TITLE>Credit Card Setup</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif Tab Is 24>
	<form method="post" action="ccsetup.cfm">
		<input type="Image" src="images/return.gif" border="0">
		<input type="Hidden" name="tab2" value="4">
		<input type="Hidden" name="tab" value="7">
		<input type="Hidden" name="Formtab" value="2">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Credit Card Setup</font></th>
	</tr>
	<cfif tab LTE 8>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<form method="post" action="ccsetup.cfm">
						<td bgcolor=<cfif tab2 Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab2 Is 1>checked</cfif> type="radio" name="tab2" value="1" onclick="submit()" id="tab1"><label for="tab1">Batch Export</label></td>
						<td bgcolor=<cfif tab2 Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab2 Is 2>checked</cfif> type="radio" name="tab2" value="2" onclick="submit()" id="tab2"><label for="tab2">Batch Import</label></td>
						<td bgcolor=<cfif tab2 Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab2 Is 4>checked</cfif> type="radio" name="tab2" value="4" onclick="submit()" id="tab4"><label for="tab4">Live Debit</label></td>
					</form>
				</table>		
			</th>
		</tr>
		<cfif Tab2 Is 1>
			<tr>
				<th colspan="#HowWide#">
					<table border="1">
						<form method="post" action="ccsetup.cfm">
							<input type="hidden" name="tab2" value="#tab2#">
							<td bgcolor=<cfif tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab Is 1>checked</cfif> type="radio" name="tab" value="1" onclick="submit()" id="tab1-1"><label for="tab1-1">General</label></td>
							<td bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab Is 2>checked</cfif> type="radio" name="tab" value="2" onclick="submit()" id="tab1-2"><label for="tab1-2">Sale</label></td>
							<td bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif>><input <cfif tab Is 3>checked</cfif> type="radio" name="tab" value="3" onclick="submit()" id="tab1-3"><label for="tab1-3">Refund</label></td>
						</form>
					</table>
				</th>
			</tr>
		</cfif>
	</cfif>
</cfoutput>
<cfif tab Is 1>
	<cfoutput>
		<form method="post" action="ccsetup.cfm">
			<tr>
				<td bgcolor="#tbclr#" align="right">Number Of Output Fields</td>
				<td bgcolor="#tdclr#"><input type="text" name="ccnumfield" value="#ccnumfield#" maxlength="2" size="2"></td>
				<td bgcolor="#tbclr#" align="right">Delimiter</td>
				<td bgcolor="#tdclr#">
				<cfif ccdelimit is "pipe">
					<input type="text" name="ccdelimit" value="|" maxlength="2" size="2">
				<cfelseif ccdelimit is " ">
					<input type="text" name="ccdelimit" value="sp" maxlength="2" size="2">
				<cfelseif ccdelimit is "	">
					<input type="text" name="ccdelimit" value="tb" maxlength="2" size="2">
				<cfelse>
					<input type="text" name="ccdelimit" value="#ccdelimit#" maxlength="2" size="2">
				</cfif>
				</td><td bgcolor="#tdclr#"><font size="1">sp for space<br>tb for tab</font></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Use Header Row</td>
				<td bgcolor="#tdclr#"><input <cfif ccoutputheadrow is 1>checked</cfif> type="radio" name="ccoutputheadrow" value="1"> Yes <input <cfif ccoutputheadrow is 0>checked</cfif> type="radio" name="ccoutputheadrow" value="0"> No</td>
				<td bgcolor="#tbclr#" align="right">Header Row Output</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="cchrout" value="#cchrout#" size="10"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Date Format</td>
				<td bgcolor="#tdclr#"><select name="ccdateformat">
					<option <cfif ccdateformat is "YYYY-MM-DD">selected</cfif> value="YYYY-MM-DD">YYYY-MM-DD
					<option <cfif ccdateformat is "MM-DD-YYYY">selected</cfif> value="MM-DD-YYYY">MM-DD-YYYY
					<option <cfif ccdateformat is "MM-DD-YY">selected</cfif> value="MM-DD-YY">MM-DD-YY
					<option <cfif ccdateformat is "DD-MM-YYYY">selected</cfif> value="DD-MM-YYYY">DD-MM-YYYY
					<option <cfif ccdateformat is "DD-MM-YY">selected</cfif> value="DD-MM-YY">DD-MM-YY
				</select></td>
				<td bgcolor="#tbclr#" align="right">Time Format</td>
				<td bgcolor="#tdclr#" colspan="2"><select name="cctimeformat">
					<cfset select1 = compare("#cctimeformat#","hh:mm:ss")>
					<option <cfif select1 is 0>selected</cfif> value="hh:mm:ss">hh:mm:ss
					<cfset select1 = compare("#cctimeformat#","HH:mm:ss")>
					<option <cfif select1 is 0>selected</cfif> value="HH:mm:ss">HH:mm:ss
					<cfset select1 = compare("#cctimeformat#","hh:mm")>
					<option <cfif select1 is 0>selected</cfif> value="hh:mm">hh:mm
					<cfset select1 = compare("#cctimeformat#","HH:mm")>
					<option <cfif select1 is 0>selected</cfif> value="HH:mm">HH:mm
					</select></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Enclose In Quotes</td>
				<td bgcolor="#tdclr#"><input type="radio" <cfif ccenclose is 1>Checked</cfif> name="ccenclose" value="1"> Yes <input <cfif ccenclose is 0>Checked</cfif> type="radio" name="ccenclose" value="0"> No</td>
				<td bgcolor="#tbclr#" align="right">Enclose Null Data</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="radio" name="ccenclosenull" value="1" <cfif ccenclosenull is "1">checked</cfif> > Yes <input type="radio" name="ccenclosenull" value="0" <cfif ccenclosenull is"0">checked</cfif> > No</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Amount Owed Format</td>
				<td bgcolor="#tdclr#"><select name="ccamountformat">
					<option <cfif ccamountformat is "$">selected</cfif> value="$">$xx.xx
					<option <cfif ccamountformat is "">selected</cfif> value="">xx.xx
				</select></td>
				<td bgcolor="#tbclr#" align="right">Use . In Amounts</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="radio" name="ccamountperiod" value="1" <cfif ccamountperiod is "1">checked</cfif> > Yes <input type="radio" name="ccamountperiod" value="0" <cfif ccamountperiod is"0">checked</cfif> > No</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Max Customers Per File</td>
				<td bgcolor="#tdclr#"><input type="text" name="MaxPerFile" value="#MaxPerFile#" size="6" maxlength="35"></td>
				<td align="right" bgcolor="#tbclr#">Batch Output File</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="ccoutfile" value="#ccoutfile#" size="15" maxlength="35"></td>
			</tr>						
			<tr valign="top">
				<td align="right" bgcolor="#tbclr#">Batch Output Path</td>
				<td bgcolor="#tdclr#" colspan="4"><INPUT type="text" size="45" <cfif IsDefined("ccoutpath")>value="#ccoutPath#"</cfif> Name="ccoutPath"></td>
			</tr>	
			<tr>
				<td align="right" colspan="3" bgcolor="#tbclr#">Use 4 digit year for card expiration date.</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="radio" name="ccyearformat" value="yyyy" <cfif ccyearformat is "yyyy">checked</cfif> > Yes <input type="radio" name="ccyearformat" value="yy" <cfif ccyearformat is"yy">checked</cfif> > No</td>
			</tr>
			<tr>
				<th colspan="#HowWide#"><input type="image" src="images/enter.gif" name="EnterGen" border="0"></th>
			</tr>
		</form>
	</cfoutput>
</table>
</center>
<cfdirectory action="list" directory="#billpath#/cfm/integration" filter="*.cfm" name="getint">
	<cfif getint.recordcount gt 0>
		<cfset intcode = "exportcreditcard">
		<cfset intcount = 1>
		<table>
			<tr>
				<cfloop query="getint">
					<cfinclude template="integration/#name#">
				</cfloop>
			</tr>
		</table>
		<cfif intcount Is 0>
			<table>
				<tr>
					<td>Click on your credit card software for a generic setup.</td>
				</tr>
			</table>
		</cfif>
	</cfif>
<cfelseif tab Is 2>
	<cfoutput>
		<tr>
			<form method="post" action="ccsetup.cfm">
				<input type="hidden" name="tab" value="21">
				<th colspan="4" align="right"><input type="image" src="images/addnew.gif" name="addrow" border="0"></td>
			</form>
		</tr>
		<tr>
			<th bgcolor="#thclr#">Output Field</th>
			<th bgcolor="#thclr#">Use</th>
			<th bgcolor="#thclr#">Output</th>
			<th bgcolor="#thclr#">Delete</th>
		</tr>
		<tr>
			<th bgcolor="#thclr#" colspan="4">NOTE: To be able to import you must have the AccountID included.</th>
		</tr>
	</cfoutput>
	<form method="post" action="ccsetup.cfm">	
		<cfoutput query="alloptions">
			<cfset counter1 = counter1 + 1>
			<tr>
				<input type="hidden" name="ccoutputid#counter1#" value="#ccoutputid#">
				<cfif UseYN Is 1>
					<td bgcolor="#tdclr#" align="center"><input type="text" name="sortorder#counter1#" value="#sortorder#" size="2" maxlength="2"></td>
				<cfelse>
					<td bgcolor="#tdclr#" align="center"><input type="text" name="sortorder#counter1#" value="" size="2" maxlength="2"></td>	
				</cfif>
				<td bgcolor="#tdclr#"><input type="checkbox" <cfif useyn is 1>checked</cfif> name="useyn#counter1#" value="1"></td>
				<cfif CFVarYN is 0>
					<td bgcolor="#tbclr#"><input type="text" name="description1#counter1#" value="#description1#" maxlength="75" size="30"></td>
				<cfelse>
					<td bgcolor="#tbclr#">#description1#</td>
				</cfif>
				<cfif CFVarYN is 0>
					<th bgcolor="#tdclr#"><input type="checkbox" name="DeleteEm" value="#ccoutputid#"></th>
				<cfelse>
					<th bgcolor="#tdclr#">&nbsp;</th>
				</cfif>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#counter1#">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="tab2" value="#tab2#">
		</cfoutput>
			<tr>
				<th colspan="4"><input type="image" src="images/update.gif" border="0" name="EnterIt"> <input type="image" src="images/delete.gif" name="DelOne" border="0"></th>
			</tr>
	</form>
</table>
<cfelseif tab Is 3>
	<cfoutput>
		<tr>
			<form method="post" action="ccsetup.cfm">
				<input type="hidden" name="tab" value="23">
				<th colspan="4" align="right"><input type="image" src="images/addnew.gif" name="addrow" border="0"></td>
			</form>
		</tr>
		<form method="post" action="ccsetup.cfm">
			<tr>
				<th bgcolor="#thclr#">Output Field</th>
				<th bgcolor="#thclr#">Use</th>
				<th bgcolor="#thclr#">Output</th>
				<th bgcolor="#thclr#">Delete</th>
			</tr>
			<tr>
				<th bgcolor="#thclr#" colspan="4">NOTE: To be able to import you must have the AccountID included.</th>
			</tr>
	</cfoutput>
		<cfoutput query="alloptions">
			<cfset counter1 = counter1 + 1>
			<tr>
				<input type="hidden" name="ccoutputid#counter1#" value="#ccoutputid#">
				<cfif UseYN Is 1>
					<td bgcolor="#tdclr#" align="center"><input type="text" name="sortorder#counter1#" value="#sortorder#" size="2" maxlength="2"></td>
				<cfelse>
					<td bgcolor="#tdclr#" align="center"><input type="text" name="sortorder#counter1#" value="" size="2" maxlength="2"></td>	
				</cfif>
				<td bgcolor="#tdclr#"><input type="checkbox" <cfif useyn is 1>checked</cfif> name="useyn#counter1#" value="1"></td>
				<td bgcolor="#tbclr#"><cfif CFVarYN is 0><input type="text" name="description1#counter1#" value="#description1#" maxlength="75" size="35"><cfelse>#description1#</cfif></td>
				<th bgcolor="#tdclr#"><cfif CFVarYN is 0><input type="checkbox" name="DeleteEm" value="#ccoutputid#"><cfelse>&nbsp;</cfif></th>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#counter1#">
			<input type="hidden" name="tab" value="#tab#">
		</cfoutput>
			<tr>
				<th colspan="4"><input type="image" src="images/update.gif" border="0" name="EnterIt3"> <input type="image" src="images/delete.gif" name="DelThree" border="0"></th>
			</tr>
	</form>
</table>
<cfelseif tab Is 4>
	<cfoutput>
	<form method="post" action="ccsetup.cfm">
		<input type="hidden" name="tab" value="#tab#">
		<input type="hidden" name="tab2" value="#tab2#">
		<tr>
			<td colspan="4">
				<table width="100%" border="0">
					<tr>
						<td bgcolor="#tbclr#" colspan="2" align="right">Number Of Input Lines</td>
						<td bgcolor="#tdclr#"><select name="ccinputlines">
							<option <cfif ccinputlines is 1>selected</cfif> value="1">1
							<option <cfif ccinputlines is 2>selected</cfif> value="2">2
						</select></td>
						<td bgcolor="#tbclr#" colspan="1" align="right">Use Header Row</td>
						<td bgcolor="#tdclr#"><input <cfif ccinputheadrow is 1>checked</cfif> type="radio" name="ccinputheadrow" value="1"> Yes <input <cfif ccinputheadrow is 0>checked</cfif> type="radio" name="ccinputheadrow" value="0"> No</td>
					</tr>
					<tr>
						<th colspan="4">NOTE: To be able to import you must have the AccountID included.</th>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<th bgcolor="#thclr#">Input Line</th>
			<th bgcolor="#thclr#">Input Field</th>
			<th bgcolor="#thclr#">Use</th>
			<th bgcolor="#thclr#">Input</th>
		</tr>
	</cfoutput>
	<cfoutput query="allinput">
		<cfset counter1 = counter1 + 1>
		<tr>
			<input type="hidden" name="ccinputid#counter1#" value="#ccinputid#">
			<th bgcolor="#tdclr#"><select name="LineOrder#counter1#">
				<option <cfif LineOrder Is 1>selected</cfif> value="1">1st Line
				<option <cfif LineOrder Is 2>selected</cfif> value="2">2nd Line
			</select></th>
			<input type="hidden" name="lineorder#counter1#_required" value="Please enter the line that #description1# is on.">
			<cfif UseYN Is 1>
				<th bgcolor="#tdclr#"><input type="text" name="sortorder#counter1#" value="#sortorder#" size="2" maxlength="2"></th>
			<cfelse>
				<th bgcolor="#tdclr#"><input type="text" name="sortorder#counter1#" value="" size="2" maxlength="2"></th>
			</cfif>
			<td bgcolor="#tdclr#"><input type="checkbox" <cfif useyn is 1>checked</cfif> name="useyn#counter1#" value="1"></td>
			<td bgcolor="#tbclr#">#description1#<cfif FieldName1 Is "TypeCode"> Width:<input type="Text" name="CodeWide" value="#CodeWide#" size="3"></cfif></td>
		</tr>
	</cfoutput>
		<tr>
			<cfoutput><input type="hidden" name="LoopCount" value="#counter1#"></cfoutput>
			<th colspan="4"><input type="image" src="images/update.gif" name="UpdateEM" border="0"></th>
		</tr>
	</form>
	</table>
	</center>
	<cfdirectory action="list" directory="#billpath#/cfm/integration" filter="*.cfm" name="getint">
	<cfif getint.recordcount gt 0>
		<cfset intcode = "importcreditcard">
		<cfset intcount = 1>
		<table>
			<tr>
				<cfloop query="getint">
					<cfinclude template="integration/#name#">
				</cfloop>
			</tr>
		</table>
		<cfif intcount Is 0>
			<table>
				<tr>
					<td>Click on your credit card software for a generic setup.</td>
				</tr>
			</table>
		</cfif>
	</cfif>
<cfelseif tab Is 7>
	<cfif CheckLock.RecordCount GT 0>
		<cfoutput>
		<form method="post" action="ccsetup.cfm">
			<tr bgcolor="#tbclr#">
				<td colspan="#HowWide#">Live Debiting is currently locked.  Click Unlock to reset.</td>
			</tr>
			<tr>
				<th colspan="#HowWide#"><input type="Submit" name="UnlockLive" value="Unlock"></th>
			</tr>
			<input type="Hidden" name="Tab2" value="4">
		</form>
		</cfoutput>
	</cfif>
	<cfoutput>
		<tr>
			<th colspan="#HowWide#">					
				<table border="1">
					<tr>
						<form method="post" action="ccsetup.cfm">
							<th bgcolor=<cfif FormTab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif FormTab Is 1>checked</cfif> name="FormTab" value="1" onclick="submit()" id="Tab1"><label for="Tab1">General</label></th>
							<th bgcolor=<cfif FormTab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif FormTab Is 3>checked</cfif> name="FormTab" value="3" onclick="submit()" id="Tab3"><label for="Tab3">Codes</label></th>
							<cfif CCCompSel Is "FormBased">
								<th bgcolor=<cfif FormTab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="Radio" <cfif FormTab Is 2>checked</cfif> name="FormTab" value="2" onclick="submit()" id="Tab2"><label for="Tab2">Form Fields</label></th>
							</cfif>
							<input type="Hidden" name="Tab2" value="4">
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfoutput>
	
		<cfif FormTab Is 1>
			<cfoutput>
				<form method="post" action="ccsetup.cfm">
					<tr bgcolor="#tdclr#"> 
						<cfset HowWide2 = HowWide - 1>
						<td colspan="#HowWide2#" align="right" bgcolor="#tbclr#">Auto Debit Software</td>
			</cfoutput>
						<td><select name="cccompany">
							<option value="N/A">None
							<cfoutput query="GetValues">
								<option <cfif FieldValue Is 1>selected</cfif> value="#Description1#">#FieldName1#
							</cfoutput>
						</select></td>
					</tr>
				<cfoutput>
					<tr bgcolor="#tbclr#">
						<td bgcolor="#tdclr#"><input type="Checkbox" <cfif TestMode.UseYN Is "1">checked</cfif> name="TestMode" value="#TestMode.ccoutputid#"></td>
						<td colspan="2">Turn Live Mode On</td>
					</tr>
					<tr bgcolor="#thclr#">
						<th>Use</th>
						<th>Description</th>
						<th>Value</th>
					</tr>
				</cfoutput>
				<cfset LoopCount = 0>		 
				<cfoutput query="GetSetups">
					<cfset LoopCount = LoopCount + 1>
					<tr>
						<td bgcolor="#tdclr#"><input type="Checkbox" <cfif UseYN Is "1">checked</cfif> name="UseYN#LoopCount#" value="1"></td>
						<td bgcolor="#tbclr#">#Description1#</td>
						<td bgcolor="#tdclr#"><input type="Text" name="FieldValue#LoopCount#" value="#FieldValue#" size="20"></td>
						<input type="Hidden" name="ccoutputid#LoopCount#" value="#ccoutputid#">
					</tr>
				</cfoutput>										  
				<cfoutput>
					<input type="Hidden" name="Tab2" value="4">
					<input type="Hidden" name="FormTab" value="1">
					<cfparam name="LoopCount" default="0">
					<input type="Hidden" name="LoopCount" value="#LoopCount#">
				</cfoutput>
				<tr>
					<cfoutput>
						<th colspan="#HowWide#"><input type="image" src="images/edit.gif" name="SelCCLive" border="0"></th>
					</cfoutput>
				</tr>
			</form>
		<cfelseif FormTab Is 3>
			<form method="post" name="EditInfo" action="ccsetup.cfm">
				<cfoutput><tr bgcolor="#thclr#"></cfoutput>
					<th>Field name</th>
					<th>Value</th>
				</tr>
				<cfoutput query="GetCCInfoTab8">
					<tr bgcolor="#tdclr#">
						<td bgcolor="#tbclr#">#Description1#</td>
						<td><input type="Text" name="#FieldName1#" value="#FieldValue#" size="5"></td>
					</tr>
				</cfoutput>
				<tr>
					<cfoutput>
						<th colspan="#HowWide#"><input type="Image"  src="images/edit.gif" name="SetCodeValues" border="0"></th>
						<input type="Hidden" name="Tab2" value="4">
						<input type="Hidden" name="FormTab" value="3">
					</cfoutput>
				</tr>
			</form>
		<cfelse>
			<cfif CCCompSel Is "FormBased">
			<form method="post" name="AddInfo" action="ccsetup.cfm">
				<tr>
					<cfoutput><td align="right" colspan="#HowWide#"><input type="Image" src="images/addnew.gif" name="AddNewForm" border="0"></td></cfoutput>
				</tr>
				<input type="Hidden" name="tab" value="24">
				<input type="Hidden" name="tab2" value="4">
				<input type="Hidden" name="formtab" value="2">
			</form>
			<form method="post" name="EditInfo" action="ccsetup.cfm">
				<cfoutput><tr bgcolor="#thclr#"></cfoutput>
					<th>Use</th>
					<th>Field name</th>
					<th>Value</th>
					<th>Delete</th>
				</tr>
				<cfset LoopCount = 0>
				<cfoutput query="AllFormFields">
					<cfset LoopCount = LoopCount + 1>
					<tr bgcolor="#tdclr#">
						<th><input type="Checkbox" <cfif UseYN Is "1">checked</cfif> value="1" name="UseYN#LoopCount#"></th>
						<td><input type="Text" name="FieldName1#LoopCount#" value="#FieldName1#"></td>
						<td><input type="Text" name="FieldValue#LoopCount#" value="#FieldValue#"></td>
						<th><input type="Checkbox" name="DelSelected" value="#CCOutputID#" onClick="SetValues(#CCOutputID#,this)"></th>
						<input type="Hidden" name="ID#LoopCount#" value="#CCOutputID#">
					</tr>
				</cfoutput>
				<tr>
					<cfoutput>
						<th colspan="#HowWide#">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<th><input type="image" src="images/edit.gif" name="SetCCForm" border="0"></th>
									<input type="Hidden" name="Tab2" value="4">
									<input type="Hidden" name="LoopCount" value="#LoopCount#">
									<input type="Hidden" name="FormTab" value="2">
									<input type="Hidden" name="Tab" value="7">
									<input type="Hidden" name="CCCompSel" value="#CCCompSel#">
			</form>
			<form method="post" action="ccsetup.cfm" name="PickDelete" onSubmit="return confirm('Click Ok to confirm deleting the selected form fields.')">
									<input type="hidden" name="DelThese" value="0">
									<th><input type="image" src="images/delete.gif" name="DelForms" border="0"></th>
									<input type="Hidden" name="Tab2" value="4">
									<input type="Hidden" name="FormTab" value="2">
									<input type="Hidden" name="Tab" value="7">
									<input type="Hidden" name="CCCompSel" value="#CCCompSel#">
								</tr>
							</table>
						</th>						
					</cfoutput>
				</tr>
			</form>
				<cfoutput>
					<tr>
						<th colspan="4">
							<table border="1">
								<tr>
									<th bgcolor="#thclr#" colspan="4">Available Variables</th>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>AccountID</td><td>%CC00</td>
									<td>First Name</td><td>%CC01</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Last Name</td><td>%CC02</td>
									<td>Address</td><td>%CC03</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Phone</td><td>%CC04</td>
									<td>Zip</td><td>%CC05</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Email</td><td>%CC06</td>
									<td>Amount</td><td>%CC07</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Card Number</td><td>%CC08</td>
									<td>Exp Month</td><td>%CC09</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Exp Year</td><td>%CC10</td>
									<td>Card Type</td><td>%CC11</td>
								</tr>
								<tr bgcolor="#tbclr#">
									<td>Unique Number</td>
									<td>%CC12</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
							</table>
						</th>
					</tr>
				</cfoutput>
			</cfif>
		</cfif>
</table>
<cfelseif tab Is 24>
	<cfoutput>
		<form method="post" action="ccsetup.cfm">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">Form Field Name</td>
				<td colspan="3"><input type="Text" name="FormField" size="30"></td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#">Field Value</td>
				<td colspan="3"><input type="Text" name="FormValue" size="30"></td>
			</tr>
			<input type="Hidden" name="FormValue_Required" value="Please enter the Value for the form field.">
			<input type="Hidden" name="FormField_Required" value="Please enter the Form Field Name.">
			<tr>
				<th colspan="4"><input type="image" name="AddFormInfo" border="0" src="images/enter.gif"></th>
			</tr>
		</form>
		<tr>
			<th colspan="4">
				<table border="1">
					<tr>
						<th bgcolor="#thclr#" colspan="4">Available Variables</th>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>AccountID</td><td>%CC00</td>
						<td>First Name</td><td>%CC01</td>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>Last Name</td><td>%CC02</td>
						<td>Address</td><td>%CC03</td>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>Phone</td><td>%CC04</td>
						<td>Zip</td><td>%CC05</td>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>Email</td><td>%CC06</td>
						<td>Amount</td><td>%CC07</td>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>Card Number</td><td>%CC08</td>
						<td>Exp Month</td><td>%CC09</td>
					</tr>
					<tr bgcolor="#tbclr#">
						<td>Exp Year</td><td>%CC10</td>
						<td>Card Type</td><td>%CC11</td>
					</tr>
				</table>
			</th>
		</tr>
	</cfoutput>
</table>
<cfelseif tab Is 21>
	<form method="post" action="ccsetup.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="1">
			<tr>
				<th bgcolor="#tbclr#" colspan="3"><b>Note: For Date and Time use ##Date####Time##</b></th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#"><input type="text" name="sortorder" size="2" maxlength="2"></td>
				<input type="hidden" name="sortorder_required" value="Please enter the output field number.">
				<input type="hidden" name="sortorder_integer" value="Please enter a number for the output field.">
				<td bgcolor="#tdclr#"><input type="checkbox" checked name="useyn" value="1"></td>
				<input type="hidden" name="description1_required" value="Please enter the output needed in description.">
				<td bgcolor="#tbclr#"><input type="text" name="description1"></td>
			</tr>
			<tr>
				<th colspan="3"><input type="image" src="images/enter.gif" name="enter1" border="0"></th>
			</tr>
		</cfoutput>
	</form>		
</table>
<cfelseif tab Is 23>
	<form method="post" action="ccsetup.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="3">
			<tr>
				<th bgcolor="#tbclr#" colspan="3"><b>Note: For Date and Time use ##Date####Time##</b></th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#"><input type="text" name="sortorder" size="2" maxlength="2"></td>
				<input type="hidden" name="sortorder_required" value="Please enter the output field number.">
				<input type="hidden" name="sortorder_integer" value="Please enter a number for the output field.">
				<td bgcolor="#tdclr#"><input type="checkbox" checked name="useyn" value="1"></td>
				<input type="hidden" name="description1_required" value="Please enter the output needed in description.">
				<td bgcolor="#tbclr#"><input type="text" name="description1"></td>
			</tr>
			<tr>
				<th colspan="3"><input type="image" src="images/enter.gif" name="Enter3" border="0"></th>
			</tr>
		</cfoutput>
	</form>		
</table>
</cfif>

<cfinclude template="footer.cfm">
</body>
</html>
      