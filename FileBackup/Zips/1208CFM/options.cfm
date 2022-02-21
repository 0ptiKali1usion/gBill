<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the main options page.  Each tab is selectable from this page. --->
<!--- 4.0.0 07/20/99
		3.2.0 09/08/98 --->
<!--- options.cfm --->

<cfinclude template="security.cfm">

<!---   Save the changes   --->
<cfinclude template="options2.cfm">

<cfquery NAME="allvs" DATASOURCE="#pds#">
	SELECT * 
	FROM Setup 
	WHERE AutoLoadYN = 1
</cfquery>
<cfloop query="allvs">
	<cfset "#varname#" = Value1>
</cfloop>
<cfquery name="OtherValues" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName In ('IPADCAuthID') 
</cfquery>
<cfloop query="OtherValues">
	<cfset "#varname#" = Value1>
</cfloop>
<!---   End of save changes section --->

<cfparam name="tab" default="1">
<cfparam name="datemask1" default="MMM/DD/YYYY">
<cfparam name="International" default="0">
<cfif datemask1 is "MMM/DD/YYYY">
	<cfset var1 = 0>
	<cfset var2 = 1>
<cfelse>
	<cfset var1 = 1>
	<cfset var2 = 0>
</cfif>

<cfif tab Is 1>
	<cfset HowWide = 3>
	<cfquery name="getplans" datasource="#pds#">
		SELECT * 
		FROM Plans 
		ORDER BY PlanDesc
	</cfquery>
	<cfquery name="getletters" datasource="#pds#">
		SELECT IntID, IntDesc 
		FROM Integration 
		WHERE TypeID = 7 
		ORDER BY IntDesc 
	</cfquery>
	<cfquery name="CheckOSType" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'OSType' 
	</cfquery>
	<cfset country1 = Server.ColdFusion.SupportedLocales>
	<cfset f0 = Mid("#datemask1#","1","1")>
   <cfif f0 is "M">
   	<cfset pos1 = 5>
	   <cfset howmany2 = 3>
	   <cfset howmany3 = 2>
   <cfelse>
   	<cfset pos1 = 4>
	   <cfset howmany2 = 2>
   	<cfset howmany3 = 3>
   </cfif>
	<cfset f1 = Mid("#datemask1#","1",howmany2)>
	<cfset f2 = Mid("#datemask1#",pos1,howmany3)>
   <cfset howmany1 = Len(datemask1) - 7>
	<cfset f3 = Mid("#datemask1#","8",howmany1)>
	<cfhtmlhead text="<script language=""JavaScript"">
<!-- 
function toggleit()
   {
   if (document.Theform.f1.options[document.Theform.f1.selectedIndex].value == 'MMM')
      {
	  document.Theform.f2.options.length = 1
	  document.Theform.f2.options[0].text = 'Day'
	  document.Theform.f2.options[0].value = 'DD'	  
	  document.Theform.f2.options[0].selected = 1
	  }
   if (document.Theform.f1.options[document.Theform.f1.selectedIndex].value == 'DD')
      {
	  document.Theform.f2.options.length = 1
	  document.Theform.f2.options[0].text = 'Month'
	  document.Theform.f2.options[0].value = 'MMM'	  
	  document.Theform.f2.options[0].selected = 1
	  }
   }
function toggleit2()
   {   	  
   if (document.Theform.f2.options[document.Theform.f2.selectedIndex].value == 'MMM')
      {
	  document.Theform.f1.options.length = 1
	  document.Theform.f1.options[0].text = 'Day'
	  document.Theform.f1.options[0].value = 'DD'	  
	  document.Theform.f1.options[0].selected = true
	  }
   if (document.Theform.f2.options[document.Theform.f2.selectedIndex].value == 'DD')
      {
	  document.Theform.f1.options.length = 1
	  document.Theform.f1.options[0].text = 'Month'
	  document.Theform.f1.options[0].value = 'MMM'	  
	  document.Theform.f1.options[0].selected = true
	  }
   }
function resetit()
   {
   document.Theform.f1.options.length = 2
   document.Theform.f1.options[0].text = 'Month';
   document.Theform.f1.options[0].value = 'MMM';
   document.Theform.f1.options[1].text = 'Day';
   document.Theform.f1.options[1].value = 'DD';
   document.Theform.f1.options[#var1#].defaultSelected = true
   document.Theform.f2.options.length = 2
   document.Theform.f2.options[0].text = 'Month';
   document.Theform.f2.options[0].value = 'MMM';
   document.Theform.f2.options[1].text = 'Day';
   document.Theform.f2.options[1].value = 'DD';
   document.Theform.f2.options[#var2#].defaultSelected = true
   }
// -- End Hiding Here -->
</script>

">
<cfelseif tab Is 2>
	<cfset HowWide = 2>
	<cfquery name="AllStates" datasource="#pds#">
		SELECT Abbr, StateName 
		FROM States 
		WHERE ActiveYN = 1 
		ORDER BY Abbr
	</cfquery>	
<cfelseif tab Is 3>
	<cfset HowWide = 2>
<cfelseif tab Is 4>
	<cfset HowWide = 5>
	<cfquery name="AllCCTypes" datasource="#pds#">
		SELECT * 
		FROM CreditCardTypes 
		Order By ActiveYN desc, CardType
	</cfquery>
<cfelseif tab Is 24>
	<cfset HowWide = 3>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Options</TITLE>
<cfif tab Is 4>
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.DelCount.value
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
<cfif tab GT 20>
	<form method="post" action="options.cfm">
		<cfset ReturnTab = 4>
		<cfoutput>
		<input type="hidden" name="tab" value="4">
		</cfoutput>
		<input type="image" src="images/return.gif" name="return" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">gBill System Configuration</font></th>
	</tr>
	<cfif tab LT 24>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="options.cfm">
							<th bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onClick="submit()" id="tab1"><label for="tab1">gBill System</label></th>
							<th bgcolor=<cfif Tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onClick="submit()" id="tab2"><label for="tab2">Company</label></th>
							<th bgcolor=<cfif Tab Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onClick="submit()" id="tab4"><label for="tab4">Credit Cards</label></th>
							<!--- <th bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onClick="submit()" id="tab3"><label for="tab3">IPAD</label></th> --->
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfif>
</cfoutput>
<cfif tab Is 1>
	<cfinclude template="opttab1.cfm">
<cfelseif tab Is 2>
	<cfinclude template="opttab2.cfm">
<cfelseif tab Is 3>
	<cfinclude template="opttab3.cfm">
<cfelseif tab Is 4>
	<cfinclude template="opttab4.cfm">
<cfelseif tab Is 24>
	<form method="post" action="options.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="4">
			<tr>
				<td align="right" bgcolor="#tbclr#">Card</td>
				<td bgcolor="#tdclr#"><input type="text" name="CardType" maxlength="25" size="25"></td>
				<input type="hidden" name="CardType_Required" value="Please enter the card name">
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Use In Account Wizard</td>
				<td bgcolor="#tdclr#"><input type="radio" name="UseAW" checked value="1"> Yes <input type="radio" name="UseAW" value="0"> No </td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Use In Online Signup</td>
				<td bgcolor="#tdclr#"><input type="radio" name="UseOS" checked value="1"> Yes <input type="radio" name="UseOS" value="0"> No </td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="EnterCardType" border="0"></th>
			</tr>
		</cfoutput>
	</form>		
	</table>
</cfif>
</table>

</center>
<cfinclude template="footer.cfm">
</body>
</html>
  



