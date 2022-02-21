<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page allows editing the IPAD values. --->
<!--- 4.0.0 07/26/99 --->
<!--- ipad.cfm --->
<cfif IsDefined("UpdateEMail.X")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE IPADMail SET 
		CMD1 = '#CMD1#', 
		DNS_Mask = '#DNS_Mask#', 
		MailBox = <cfif Trim(MailBox) Is "">Null<cfelse>'#MailBox#'</cfif> 
		WHERE IPADMailID = #IPADMailID# 
	</cfquery>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'ipad.cfm' 
		AND L.LocationAction = 'Change' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'EMail') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
</cfif>
<cfif IsDefined("AddNewEMail.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO IPADMail 
		(Cmd1, DNS_Mask, MailBox)
		VALUES ('#cmd1#', 
		<cfif Trim(DNS_Mask) Is "">Null<cfelse>'#DNS_Mask#'</cfif>,
		<cfif Trim(MailBox) Is "">Null<cfelse>'#MailBox#'</cfif>) 
	</cfquery>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'ipad.cfm' 
		AND L.LocationAction = 'Change' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'EMail') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
</cfif> 
<cfif IsDefined("DelIPADEMail.x")>
	<cfquery name="remove1" datasource="#pds#">
		DELETE FROM IPADMail 
		WHERE IPADMailID In (#DelThese#) 
	</cfquery>
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'ipad.cfm' 
		AND L.LocationAction = 'Change' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'EMail') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
</cfif>

<cfparam name="tab" default="1">
<cfparam name="page" default="1">
<cfif tab Is 1>
	<cfset HowWide = 5>
	<cfparam name="obid" default="cmd1">
	<cfparam name="obdir" default="asc">
	<cfquery name="IPADValues" datasource="#pds#">
		SELECT * FROM IPADMail
		ORDER BY #obid# #obdir#
	</cfquery>
	<cfset PageNumber = Ceiling(IPADValues.RecordCount/Mrow)>
<cfelseif tab is 21>
	<cfset HowWide = 2>
	<cfquery name="OneValue" datasource="#pds#">
		SELECT * FROM IPADMail 
		WHERE IPADMailID = #IPADMailID#
	</cfquery>
</cfif>
<cfif tab LT 20>
	<cfif Page GT 0>
		<cfset MaxRows = mrow>
		<cfset Srow = (page * mrow) - (mrow - 1)>
	<cfelse>
		<cfset Srow = 1>
		<cfset MaxRows = IPADValues.RecordCount>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>IPAD Setup</title>
<cfif tab LT 20>
<script language="javascript">
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
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab GT 20>
	<form method="post" action="ipad.cfm">
		<cfset ReturnTab = tab - 20>
		<cfoutput>
			<input type="hidden" name="tab" value="#ReturnTab#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="Page" value="#Page#">
		</cfoutput>
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">IPAD EMail Setup</font></th>
	</tr>
</cfoutput>
<cfif tab Is 1>
	<cfif IPADValues.RecordCount GT Mrow>
		<tr>
			<form method="post" action="ipad.cfm">
				<cfoutput>
					<input type="hidden" name="tab" value="#tab#">
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="5"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "cmd1">
							<cfset dispstr = IPADValues.Cmd1[arraypoint]>
						<cfelseif obid Is "DNS_MASK">
							<cfset dispstr = IPADValues.DNS_MASK[arraypoint]>
						<cfelseif obid Is "mailbox">
							<cfset dispstr = IPADValues.mailbox[arraypoint]>
						</cfif>
						<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #IPADValues.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<tr>
		<form method="post" action="ipad.cfm">
			<input type="hidden" name="tab" value="21">
			<input type="hidden" name="IPADMailID" value="0">
			<cfoutput>
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
				<input type="hidden" name="Page" value="#Page#">
			</cfoutput>
			<td align="right" colspan="5"><input type="image" src="images/addnew.gif" border="0"></td>
		</form>
	</tr>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Edit</th>
			<form method="post" action="ipad.cfm">
				<cfif (obid Is "cmd1") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="tab" value="#tab#">
				<th><input type="radio" <cfif obid Is "cmd1">checked</cfif> name="obid" value="cmd1" onclick="submit()" id="col1"><label for="col1">Command</label></th>
			</form>
			<form method="post" action="ipad.cfm">
				<cfif (obid Is "DNS_MASK") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="tab" value="#tab#">
				<th><input type="radio" <cfif obid Is "DNS_MASK">checked</cfif> name="obid" value="DNS_MASK" onclick="submit()" id="col2"><label for="col2">EMail</label></th>
			</form>
			<form method="post" action="ipad.cfm">
				<cfif (obid Is "mailbox") AND (obdir Is "asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="tab" value="#tab#">
				<th><input type="radio" <cfif obid Is "mailbox">checked</cfif> name="obid" value="mailbox" onclick="submit()" id="col3"><label for="col3">Path or To</label></th>
			</form>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" name="EditInfo" action="ipad.cfm">
		<input type="hidden" name="tab" value="21">
		<cfoutput>
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
		</cfoutput>
		<cfset LoopCount = 0>		
		<cfoutput query="IPADValues" startrow="#srow#" maxrows="#maxrows#">
			<cfset LoopCount = LoopCount + 1>
			<tr valign="top" bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="IPADMailID" value="#IPADMailID#" onclick="submit()"></th>
				<td>#Cmd1# </td>
				<td>#DNS_Mask# </td>
				<td>#MailBox# </td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#IPADMailID#" onclick="SetValues(#IPADMailID#,this)"></th>
			</tr>
		</cfoutput>
		<cfoutput><input type="hidden" name="LoopCount" value="#LoopCount#"></cfoutput>
	</form>
	<tr>
		<form method="post" name="PickDelete" action="IPAD.cfm" onSubmit="return confirm ('Press OK to confirm deleting this selected EMail items.')">
			<input type="hidden" name="DelThese" value="0">
			<cfoutput>
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
				<input type="hidden" name="Page" value="#Page#">
				<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
			<th colspan="5"><input type="image" src="images/delete.gif" name="DelIPADEMail" border="0"></th>
		</form>
	</tr>
	<cfif IPADValues.RecordCount GT Mrow>
		<tr>
			<form method="post" action="ipad.cfm">
				<cfoutput>
					<input type="hidden" name="tab" value="#tab#">
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="5"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset arraypoint = (B5*mrow)-(mrow-1)>
						<cfif obid Is "cmd1">
							<cfset dispstr = IPADValues.Cmd1[arraypoint]>
						<cfelseif obid Is "DNS_MASK">
							<cfset dispstr = IPADValues.DNS_MASK[arraypoint]>
						<cfelseif obid Is "mailbox">
							<cfset dispstr = IPADValues.mailbox[arraypoint]>
						</cfif>
						<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #IPADValues.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfelseif tab Is 21>
	<cfoutput>
		<form method="post" action="IPAD.cfm">
			<input type="hidden" name="IPADMailID" value="#OneValue.IPADMailID#">
			<input type="hidden" name="tab" value="1">
			<tr>
				<td align="right" bgcolor="#tbclr#">Command</td>
				<td bgcolor="#tdclr#"><select name="Cmd1">
					<option <cfif OneValue.cmd1 is "BADFROM">selected</cfif> value="BADFROM">Bad From (E-Mail)
					<option <cfif OneValue.cmd1 is "BADTO">selected</cfif> value="BADTO">Bad To (E-Mail)
					<option <cfif OneValue.cmd1 is "COPY">selected</cfif> value="COPY">Copy (From, To)
					<option <cfif OneValue.cmd1 is "DISFROM">selected</cfif> value="DISFROM">Discard From (E-Mail)
					<option <cfif OneValue.cmd1 is "DISTO">selected</cfif> value="DISTO">Discard To (E-Mail)
					<option <cfif OneValue.cmd1 is "FWDFROM">selected</cfif> value="FWDFROM">Forward From (E-Mail)
					<option <cfif OneValue.cmd1 is "FWDTO">selected</cfif> value="FWDTO">Forward To (E-Mail)
					<option <cfif OneValue.cmd1 is "LIST">selected</cfif> value="LIST">List (E-Mail, Path/File)
					<option <cfif OneValue.cmd1 is "LISTMGR">selected</cfif> value="LISTMGR">Listmgr (E-Mail, Path/File)
					<option <cfif OneValue.cmd1 is "REJFROM">selected</cfif> value="REJFROM">Reject From (E-Mail)
					<option <cfif OneValue.cmd1 is "REJTO">selected</cfif> value="REJTO">Reject To (E-Mail)
					<option <cfif OneValue.cmd1 is "RESP">selected</cfif> value="RESP">Auto-Respond (E-Mail, Path/File)
					<option <cfif OneValue.cmd1 is "UUCP">selected</cfif> value="UUCP">UUCP Gateway (E-Mail, Path)
					<option <cfif OneValue.cmd1 is "UUCPFWD">selected</cfif> value="UUCPFWD">UUCP Forward (E-Mail, Path)
				</select></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">EMail</td>
				<td bgcolor="#tdclr#"><input type="text" name="dns_mask" value="#OneValue.DNS_Mask#" size="35" maxlength="100"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Path or To</td>
				<td bgcolor="#tdclr#"><input type="text" name="mailbox" value="#OneValue.MailBox#" maxlength="100" size="35"></td>
			</tr>
			<tr>
				<cfif IPADMailID Is 0>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddNewEMail" border="0"></th>
				<cfelse>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
					<input type="hidden" name="page" value="#page#">
					<th colspan="2"><input type="image" src="images/update.gif" name="UpdateEMail" border="0"></th>
				</cfif>
			</tr>
		</form>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 