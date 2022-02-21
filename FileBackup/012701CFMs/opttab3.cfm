<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 07/20/99
		3.2.0 09/08/98 --->
<!--- opttab3.cfm --->

<cfquery name="AllAuths" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	ORDER BY AuthDescription
</cfquery>

<cfsetting enablecfoutputonly="No">
<cfoutput>
<form method="post" name="Theform" action="options.cfm">
	<INPUT type="hidden" name="tab" value="#tab#">
	<tr>
		<th colspan="2" bgcolor="#thclr#">File Output Setup</th>
	</tr>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#">IPAD Custom Auth</td>
</cfoutput>		
		<td><select name="IPADCAuthID">
			<cfoutput query="AllAuths">
				<option <cfif CAuthID Is IPADCAuthID>selected</cfif> value="#CAuthID#">#AuthDescription#
			</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr>
		<th colspan="2" bgcolor="#thclr#">Authentication</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">IPAD Slip Path#OSType#Filename</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADslipfile")>value="#IPADslipfile#"</cfif> type="text" name="IPADslipfile" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#" align="right"><Input <cfif IsDefined("IPADslipfileftp")><cfif IPADslipfileftp is 1>checked</cfif></cfif> value="1" type="checkbox" name="IPADslipfileftp" size="40"></td>
		<th bgcolor="#tbclr#" align="left">FTP the above file to:</th>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">IPAD Slip Server</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADslipserver")>value="#IPADslipserver#"</cfif> type="text" name="IPADslipserver" size="40"></td>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">FTP Account Login</th>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADsliplogin")>value="#IPADsliplogin#"</cfif> type="text" name="IPADsliplogin" size="20"></td>
	</tr>
	<tr>
		<td align="RIGHT" bgcolor="#tbclr#">FTP Account Password</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADslippassw")>value="#IPADslippassw#"</cfif> type="password" name="IPADslippassw" size="20"></td>
	</tr>
	<tr>
		<th colspan="2" bgcolor="#thclr#">E-Mail</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="right">Default Server EMail Path</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADmailpath")>value="#IPADmailpath#"</cfif> type="text" name="IPADmailpath" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">IPAD EMail Path#OSType#Filename</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADmailfile")>value="#IPADmailfile#"</cfif> type="text" name="IPADmailfile" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="right"><Input <cfif IsDefined("IPADmailfileftp")><cfif IPADmailfileftp is 1>checked</cfif></cfif> value="1" type="checkbox" name="IPADmailfileftp" size="40"></td>
		<th bgcolor="#tbclr#" align="left">FTP the above file to:</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">IPAD Mail Server</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADmailserver")>value="#IPADmailserver#"</cfif> type="text" name="IPADmailserver" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">FTP Account Login</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADmaillogin")>value="#IPADmaillogin#"</cfif> type="text" name="IPADmaillogin" size="20"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">FTP Account Password</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADmailpassw")>value="#IPADmailpassw#"</cfif> type="password" name="IPADmailpassw" size="20"></td>
	</tr>
	<tr>
		<th colspan="2" bgcolor="#thclr#">FTP</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">IPAD FTP Path#OSType#Filename</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADftpfile")>value="#IPADftpfile#"</cfif> type="text" name="IPADftpfile" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tdclr#" align="right"><Input <cfif IsDefined("IPADftpfileftp")><cfif IPADftpfileftp is 1>checked</cfif></cfif> value="1" type="checkbox" name="IPADftpfileftp" size="40"></td>
		<th bgcolor="#tbclr#" align="left">FTP the above file to:</th>
	</tr>
	<tr>
		<th bgcolor="#tbclr#" align="RIGHT">IPAD FTP Server</th>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADftpserver")>value="#IPADftpserver#"</cfif> type="text" name="IPADftpserver" size="40"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">FTP Account Login</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADftplogin")>value="#IPADftplogin#"</cfif> type="text" name="IPADftplogin" size="20"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align="RIGHT">FTP Account Password</td>
		<td bgcolor="#tdclr#"><Input <cfif IsDefined("IPADftppassw")>value="#IPADftppassw#"</cfif> type="password" name="IPADftppassw" size="20"></td>
	</tr>
	<tr>
		<th colspan="2"><INPUT type="image" src="images/enter.gif" border="0" name="Updtab3"></th>
	</tr>
</cfoutput>




