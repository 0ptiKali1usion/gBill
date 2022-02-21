<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- 4.0.0 06/30/99 --->
<!-- intlocations.cfm -->

<cfset securepage="integration.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("mvltloc") AND IsDefined("HaveLocs")>
	<cfquery name="MvLocs" datasource="#pds#">
		DELETE FROM IntScriptLoc 
		WHERE LocationID = #LocationID# 
		AND IntID In (#HaveLocs#)
	</cfquery>
</cfif>
<cfif IsDefined("mvrtloc") AND IsDefined("ChooseLocs")>
	<cfloop index="B5" list="#ChooseLocs#">
		<cfif B5 GT 0>
			<cfquery name="MvLocations" datasource="#pds#">
				INSERT INTO IntScriptLoc 
				(IntID, LocationID) 
				VALUES 
				(#B5#, #LocationID#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="tab" default="1">
<cfparam name="HowWide" default="2">
<cfif IsDefined("LocationID")>
	<cfquery name="OneLocation" datasource="#pds#">
		SELECT * 
		FROM IntLocations 
		WHERE LocationID = #LocationID#
	</cfquery>
</cfif>
<cfif Tab Is 3>
	<cfset HowWide = 3>
	<cfquery name="GetAvailLocs" datasource="#pds#">
		SELECT I.IntID, I.IntDesc 
		FROM Integration I, IntScriptLoc S
		WHERE I.IntID = S.IntID 
		AND S.LocationID = #LocationID# 
		ORDER BY I.IntDesc 
	</cfquery>
	<cfquery name="GetSelectable" datasource="#pds#">
		SELECT IntID, IntDesc 
		FROM Integration 
		WHERE Action <> 'Letter' 
		<cfif GetAvailLocs.RecordCount GT 0>
			AND IntID Not In
				(SELECT I.IntID 
				 FROM Integration I, IntScriptLoc S
				 WHERE I.IntID = S.IntID 
				 AND S.LocationID = #LocationID# 
				)
		</cfif>
		ORDER BY IntDesc 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Edit Script</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="integration.cfm">
	<input type="hidden" name="tab" value="3">
	<input type="image" src="images/return.gif" name="return" border="0"></a>
</form>
<center>

<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#"><cfif IsDefined("OneLocation")>#OneLocation.PageDesc#<cfelse>New Location</cfif></font></th>
		</tr>
		<cfif IsDefined("LocationID")>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="intlocations.cfm">
							<input type="hidden" name="LocationID" value="#LocationID#">
							<td bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is 1>checked</cfif> value="1" onclick="submit()" id="tab1"><label for="tab1">General</label></td>
							<td bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is 3>checked</cfif> value="3" onclick="submit()" id="tab3"><label for="tab3">Scripts</label></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
		</cfif>
</cfoutput>
<cfif tab Is 1>
	<cfoutput>
	<form method="post" action="integration.cfm">
		<input type="hidden" name="tab" value="2">
		<tr>
			<th bgcolor="#thclr#" colspan="#HowWide#">Script Location</th>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Active</td>
			<td bgcolor="#tdclr#"><input <cfif IsDefined("OneLocation")><cfif OneLocation.ActiveYN Is 1>checked</cfif></cfif> type="radio" name="ActiveYN" value="1"> Yes <input type="radio" <cfif IsDefined("OneLocation")><cfif OneLocation.ActiveYN Is 0>checked</cfif><cfelse>checked</cfif> name="ActiveYN" value="0"> No</td>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Description</td>
			<td bgcolor="#tdclr#"><input <cfif IsDefined("OneLocation")>value="#OneLocation.PageDesc#"</cfif> type="text" name="PageDesc" maxlength="255" size="45"></td>
			<input type="hidden" name="PageDesc_Required" value="Please enter a short description for this location.">
		</tr>
		<cfif IsDefined("OneLocation")>
			<tr>
				<td align="right" bgcolor="#tbclr#">Page Name</td>
				<cfif OneLocation.CFVarYN Is 0>
					<td bgcolor="#tdclr#"><input type="text" <cfif IsDefined("OneLocation")>value="#OneLocation.PageName#"</cfif> name="PageName" maxlength="40" size="30"></td>
					<input type="hidden" name="PageName_Required" value="Please enter the cfm name for this location.">
				<cfelse>
					<td bgcolor="#tdclr#">#OneLocation.PageName#</td>
					<input type="hidden" name="PageName" value="#OneLocation.PageName#">
				</cfif>
			</tr>
		<cfelse>
			<tr>
				<td align="right" bgcolor="#tbclr#">Page Name</td>
				<td bgcolor="#tdclr#"><input type="text" name="PageName" maxlength="40" size="30"></td>
				<input type="hidden" name="PageName_Required" value="Please enter the cfm name for this location.">
			</tr>
		</cfif>
		<cfif IsDefined("OneLocation")>
			<cfif OneLocation.CFVarYN Is 0>
				<tr>
					<td align="right" bgcolor="#tbclr#">Action</td>
					<td bgcolor="#tdclr#"><select name="LocationAction">
						<option <cfif OneLocation.LocationAction Is "Change">selected</cfif> value="Change">Change
						<option <cfif OneLocation.LocationAction Is "Create">selected</cfif> value="Create">Create
						<option <cfif OneLocation.LocationAction Is "Delete">selected</cfif> value="Delete">Delete
					</select></td>
				</tr>
			<cfelse>
				<tr>
					<td align="right" bgcolor="#tbclr#">Action</td>
					<td bgcolor="#tdclr#">#OneLocation.LocationAction#</td>
				</tr>
					<input type="Hidden" name="LocationAction" value="#OneLocation.LocationAction#">
			</cfif>
		<cfelse>
			<tr>
				<td align="right" bgcolor="#tbclr#">Action</td>
				<td bgcolor="#tdclr#"><select name="LocationAction">
					<option value="Change">Change
					<option value="Create">Create
					<option value="Delete">Delete
				</select></td>
			</tr>
		</cfif>
		<tr>
			<cfif IsDefined("OneLocation")>
				<input type="hidden" name="LocationID" value="#OneLocation.LocationID#">
				<th colspan="2"><input type="image" src="images/edit.gif" name="EditExtLoc" border="0"></th>
			<cfelse>
				<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewLoc" border="0"></th>
			</cfif>
		</tr>
	</form>
	</cfoutput>
<cfelse>
	<cfoutput>
	<form method="post" action="intlocations.cfm">
		<input type="hidden" name="Tab" value="#Tab#">
		<input type="hidden" name="LocationID" value="#LocationID#">
		<tr valign="top">
			<th colspan="3" bgcolor="#thclr#">Script Selection</th>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Available</th>
			<th>Action</th>
			<th>This Location runs these scripts</th>
		</tr>
		<tr bgcolor="#tdclr#">
</cfoutput>
			<td><select name="ChooseLocs" multiple size="10">
				<cfoutput query="GetSelectable">
					<option value="#IntID#">#IntDesc#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
			<td align="center" valign="middle">
			<input type="submit" name="mvrtloc" value="---->"><br>
			<input type="submit" name="mvltloc" value="<----"><br>
			</td>
			<td><select name="HaveLocs" multiple size="10">
				<cfoutput query="GetAvailLocs">
					<option value="#IntID#">#IntDesc#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
		</tr>
	</form>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
    