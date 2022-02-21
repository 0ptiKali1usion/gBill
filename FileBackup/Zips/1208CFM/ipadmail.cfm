<!--- Version 4.0.0 --->
<!--- 4.0.0 07/26/99 --->
<!--- ipadmail.cfm --->
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
 