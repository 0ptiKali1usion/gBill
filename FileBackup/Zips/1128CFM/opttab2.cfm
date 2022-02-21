<!--- Version 4.0.0 --->
<!---	4.0.0 07/20/99
		3.2.2 09//1/98 Added Vircom to Radius Options.
		3.2.1 09/09/98 Added check for blank BODBCType to select Access.
		3.2.0 09/08/98
		3.1.1 08/24/98 Added Ascend and Livingston to Radius Options.
		3.1.0 07/15/98 --->
<!--- opttab2.cfm --->

<cfoutput>
<form method="post" name="Theform" action="options.cfm">
	<INPUT type="hidden" name="tab" value="#tab#">
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">Company Name</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="compname" size="30" <cfif IsDefined("compname")>value="#compname#"</cfif> ></td>
	</tr>
	<INPUT type="hidden" name="compname_required" value="Please enter your company name">
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">Tech Support E-Mail</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="servmail" size="30" <cfif IsDefined("servmail")>value="#servmail#"</cfif> size="30" maxlength="30"></td>
	</tr>
	<INPUT type="hidden" name="servmail_required">
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">Problem Warning E-Mail</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="warnemail" size="30" <cfif IsDefined("warnemail")>value="#warnemail#"</cfif> size="30" maxlength="30"></td>
	</tr>
	<INPUT type="hidden" name="warnemail_required">
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">Address</td>
		<td><INPUT type=text name="compaddr" size="30" <cfif IsDefined("compaddr")>value="#compaddr#"</cfif> maxlength="30"></td>
	</tr>
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">City</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="compcity" size="30" <cfif IsDefined("compcity")>value="#compcity#"</cfif> maxlength="30"></td>
	</tr>
	<tr valign=top bgcolor="#tdclr#">
		<td align=right bgcolor="#tbclr#">State ZIP</td>
</cfoutput>
		<td><select name="compstate">
			<cfoutput query="AllStates">
				<option <cfif IsDefined("compstate")><cfif abbr is "#compstate#">selected</cfif></cfif> value="#abbr#">#StateName#
			</cfoutput>
		</select> <cfoutput><INPUT type=text name="compzip" <cfif IsDefined("compzip")>value="#compzip#"</cfif> size="10"></cfoutput></td>
	</tr>
<cfoutput>
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">1st Web Site URL</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="hpurl" <cfif IsDefined("hpurl")>value="#hpurl#"</cfif> size="30" maxlength="30"></td>
	</tr>
	<INPUT type="hidden" name="hpurl_required" value="Please enter the URL for your home page">
	<tr valign=top>
		<td align=right bgcolor="#tbclr#">ISP Logo File:</td>
		<td bgcolor="#tdclr#"><INPUT type=text name="complogo" size="30" <cfif IsDefined("complogo")>value="#complogo#"</cfif> maxlength="30"></td>
	</tr>
	<tr>
		<th colspan="2"><INPUT type="image" src="images/update.gif" border="0" name="UpdTab2"></th>
	</tr>
</cfoutput>

    