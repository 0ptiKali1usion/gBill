<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is the Integration tab for the plans setup.--->
<!---	4.0.0 07/16/99
		3.2.1 09/10/98 Moved IPAD Auth to the Integration tab 
		3.2.0 09/08/98
		3.1.1 08/24/98 Modified to work with Custom Authentication.
		3.1.0 07/15/98 --->
<!--- plantab3.cfm --->
<cfsetting enablecfoutputonly="No">
<cfoutput>
<form method="post" action="listplan2.cfm">
	<input type="hidden" name="Page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="PlanID" value="#PlanID#">
	<input type="hidden" name="tab" value="#tab#">
<tr>
	<th colspan="#HowWide#" bgcolor="#tbclr#">There <cfif SelDomains.RecordCount GT 1>are<cfelse>is</cfif> #SelDomains.RecordCount# domain<cfif SelDomains.RecordCount Is Not 1>s</cfif> available to select from with this plan.</th>
</tr>
<tr valign="top">
	<th colspan="#HowWide#" bgcolor="#thclr#" colspan="4">Authentication</th>
</tr>
<tr valign="top">
	<td bgcolor="#tbclr#" align="right">Setup Authentication</td>
	<td bgcolor="#tdclr#"><input type="radio" name="Radius" value="1" <cfif OnePlan.Radius Is 1>Checked</cfif> >Yes <input type="radio" name="Radius" value="0" <cfif OnePlan.Radius Is 0>Checked</cfif> >No</td>
	<td bgcolor="#tbclr#" align="right">How Many Auths</td>
	<td bgcolor="#tdclr#"><input type="text" name="AuthNumber" value="#OnePlan.AuthNumber#" size="3" maxlength="2"></td>
</tr>	
</cfoutput>
<cfif OnePlan.Radius Is 1>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">Login Min Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthMinLogin" value="#OnePlan.AuthMinLogin#" size="3" maxlength="3"></td>
		<td bgcolor="#tbclr#" align="right">Login Max Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthMaxLogin" value="#OnePlan.AuthMaxLogin#" size="3" maxlength="3"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">Password Min Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthMinPassw" value="#OnePlan.AuthMinPassw#" size="3" maxlength="3"></td>
		<td bgcolor="#tbclr#" align="right">Password Max Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthMaxPassw" value="#OnePlan.AuthMaxPassw#" size="3" maxlength="3"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td nowrap bgcolor="#tbclr#" align="right">Require Mixed Passwords</td>
		<td bgcolor="#tdclr#"><input type="radio" name="AuthMixPassw" <cfif OnePlan.AuthMixPassw Is 1>checked</cfif> value="1">Yes <input type="radio" name="AuthMixPassw" <cfif OnePlan.AuthMixPassw Is 0>checked</cfif> value="0">No</td>
		<td align=right bgcolor="#tbclr#">Template</td>
	</cfoutput>
		<cfif (tbacnttypes is not "") AND (acnttypesfd is not "")>
			<td><select name="PlanType">
				<cfif gettypes.recordcount is 0>
					<option value="PPP">PPP
				<cfelse>
					<cfoutput query="gettypes">
						<option <cfif #oneplan.plantype# is #accounttype1#>Selected</cfif> >#AccountType1#
					</cfoutput>
				</cfif>
			</select></td>
		<cfelse>
			<cfoutput><td bgcolor="#tdclr#"><input type="text" name="plantype" value="#oneplan.plantype#" size="10"></td></cfoutput>
		</cfif>
	</tr>
	<cfoutput>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Login Limit</td>
		<td bgcolor="#tdclr#"><input type="text" size="3" maxlength="8" value="#oneplan.LoginLimit#" name="LoginLimit"></td>
		<td bgcolor="#tbclr#" align="right">Default Auth Server</td>
	</cfoutput>
		<cfset ShowWarning = 1>
		<td><select name="DefAuthServer">
			<cfloop query="DefAuth">
				<cfoutput><option <cfif OnePlan.DefAuthServer Is DomainName>selected<cfset ShowWarning = 0></cfif> value="#DomainName#">#DomainName# - #AuthServer#</cfoutput>
			</cfloop>
			<cfif DefAuth.RecordCount Is 0>
				<option value="">There are no domains selected for the Auth Integration
			</cfif>
			<cfif ShowWarning Is 1 AND DefAuth.RecordCount GT 0>
				<option selected value="">Please Select the Default Auth Server
			</cfif>
		</select></td>
	</tr>
	<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">Max Idle Time</td>
		<td nowrap bgcolor="#tdclr#"><input value="#OnePlan.Max_Idle1#" type="text" name="Max_Idle1" size="4" maxlength="8"> seconds</td>
		<td bgcolor="#tbclr#" align="right">Max Connect Time</td>
		<td bgcolor="#tdclr#"><input value="#OnePlan.Max_Connect1#" type="text" name="Max_Connect1" size="5" maxlength="8"> seconds</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" nowrap align=right>AW Lowercase Usernames</td>
		<td><input type="radio" name="LowerAWYN" value="1" <cfif OnePlan.LowerAWYN is 1>Checked</cfif> >Yes <input type="radio" name="LowerAWYN" <cfif OnePlan.LowerAWYN is 0>Checked</cfif> value="0">No</td>
		<td bgcolor="#tbclr#" nowrap align=right>OS Lowercase Usernames</td>
		<td><input type="radio" name="LowerOSYN" value="1" <cfif OnePlan.LowerOSYN is 1>Checked</cfif> >Yes <input type="radio" name="LowerOSYN" <cfif OnePlan.LowerOSYN is 0>Checked</cfif> value="0">No</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" nowrap align=right>AW Prompt Static IP</td>
		<td bgcolor="#tdclr#"><input type="radio" name="AWStaticIPYN" <cfif OnePlan.AWStaticIPYN is 1>Checked</cfif> value="1">Yes <input type="radio" name="AWStaticIPYN" <cfif OnePlan.AWStaticIPYN is 0>Checked</cfif> value="0">No</td>
		<td bgcolor="#tbclr#" nowrap align=right>OS Prompt Static IP</td>
		<td bgcolor="#tdclr#"><input type="radio" name="OSStaticIPYN" <cfif OnePlan.OSStaticIPYN is 1>Checked</cfif> value="1">Yes <input type="radio" name="OSStaticIPYN" <cfif OnePlan.OSStaticIPYN is 0>Checked</cfif> value="0">No</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Keep Session History</td>
		<td bgcolor="#tdclr#"><input type="text" name="SessHistKeep" value="#OnePlan.SessHistKeep#" size="4" maxlength="4"> days</td>
		<td bgcolor="#tbclr#" align="right">Prefix Chars</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthAddChars" value="#OnePlan.AuthAddChars#" size="10" maxlength="15"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Total Hours</td>	
		<td bgcolor="#tdclr#"><input type="text" name="BaseHours" value="#OnePlan.BaseHours#" size="4"></td>
		<td bgcolor="#tbclr#" align="right">Suffix Chars</td>
		<td bgcolor="#tdclr#"><input type="text" name="AuthSufChars" value="#OnePlan.AuthSufChars#" size="10" maxlength="15"></td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" align=right>EMail Warning</td>
		<td bgcolor="#tdclr#"><input type="text" name="EMailWarn" value="#OnePlan.EMailWarn#" maxlength="3" size="3"> hours left</td>
		<td bgcolor="#tbclr#">&nbsp;</td>
		<td bgcolor="#tbclr#">&nbsp;</td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">EMail Warning Letter</td>
	</cfoutput>
		<td colspan="3"><select name="WarningLetterID">
			<option value="0">None
			<cfoutput query="EMailLetters">
				<option <cfif OnePlan.WarningLetterID Is IntID>selected</cfif> value="#IntID#">#IntDesc#
			</cfoutput>
		</select></td>
	</tr>
	<cfoutput>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Hours Limit Action</td>
		<td colspan="3">
			<table border="0" bgcolor="#tdclr#">
	</cfoutput>
				<tr>
					<td><input type="radio" <cfif OnePlan.HoursUp Is 1>checked</cfif> name="HoursUp" value="1">N/A</td>
					<td>Use Metered Billing</td>
				</tr>
				<tr>
					<td><input type="radio" <cfif OnePlan.HoursUp Is 2>checked</cfif> name="HoursUp" value="2">Rollback</td>
					<td><select name="RollbackTo1">
						<option value="0">N/A
						<cfloop query="AllOthPlans">
							<cfoutput><option <cfif (OnePlan.HoursUp Is 2) AND (OnePlan.RollBackTo Is PlanID)>selected</cfif> value="#PlanID#">#PlanDesc#</cfoutput>
						</cfloop>
					</select></td>
				</tr>
				<tr>
					<td><input type="radio" <cfif OnePlan.HoursUp Is 3>checked</cfif> name="HoursUp" value="3">Change Auth</td>
					<cfif (tbacnttypes is not "") AND (acnttypesfd is not "")>
						<td><select name="RollBackTo2">
							<cfif gettypes.recordcount is 0>
								<option value="NA">N/A
								<option value="PPP">PPP
							<cfelse>
								<option value="NA">N/A
								<cfoutput query="gettypes">
									<option <cfif (OnePlan.HoursUp Is 3) AND (OnePlan.RollBackTo Is AccountType1)>Selected</cfif> >#AccountType1#
								</cfoutput>
							</cfif>
						</select></td>
					<cfelse>
						<cfoutput><td bgcolor="#tdclr#"><input type="text" name="RollBackTo2" <cfif OnePlan.HoursUp Is 3>value="#oneplan.RollBackTo#"</cfif> size="10"></td></cfoutput>
					</cfif>
				</tr>
			</table>
		</td>
	</tr>
</cfif>
<cfoutput>
<tr valign="top">
	<th colspan="#HowWide#" bgcolor="#thclr#">EMail</th>
</tr>
<tr valign="top">
	<td bgcolor="#tbclr#" align=right>Setup E-Mail</td>
	<td bgcolor="#tdclr#"><input type="radio" name="emailyn" value="1" <cfif (#oneplan.emailyn# is 1) OR (#oneplan.emailyn# is "")>Checked</cfif> >Yes <input type="radio" name="emailyn" value="0" <cfif #oneplan.emailyn# is 0>Checked</cfif> >No</td>
	<td bgcolor="#tbclr#">How Many EMails</td>
	<td bgcolor="#tdclr#"><input type="text" value="#oneplan.freeemails#" size="3" maxlength="3" name="freeemails"></td>
</tr>
</cfoutput>
<cfif OnePlan.EMailYN Is 1>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right colspan="3">Make EMail Username Match Auth Login And Password</td>
		<td bgcolor="#tdclr#"><input type="radio" name="EMailMatchYN" <cfif OnePlan.EMailMatchYN Is 1>checked</cfif> value="1"> Yes <input type="radio" name="EMailMatchYN" <cfif OnePlan.EMailMatchYN Is 0>checked</cfif> value="0"> No</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" colspan="3" align=right>EMail Login Different Than EMail Address</td>
		<td bgcolor="#tdclr#"><input type="radio" name="EMailLogDiffYN" <cfif OnePlan.EMailLogDiffYN Is 1>checked</cfif> value="1"> Yes <input type="radio" name="EMailLogDiffYN" <cfif OnePlan.EMailLogDiffYN Is 0>checked</cfif> value="0"> No</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Login Min Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="MailMinLogin" value="#OnePlan.MailMinLogin#" size="4" maxlength="3"></td>
		<td bgcolor="#tbclr#" align=right>Login Max Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="MailMaxLogin" value="#OnePlan.MailMaxLogin#" size="4" maxlength="3"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Password Min Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="MailMinPassw" value="#OnePlan.MailMinPassw#" size="4" maxlength="3"></td>
		<td bgcolor="#tbclr#" align=right>Password Max Length</td>
		<td bgcolor="#tdclr#"><input type="text" name="MailMaxPassw" value="#OnePlan.MailMaxPassw#" size="4" maxlength="3"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Require Mixed Passwords</td>
		<td bgcolor="#tdclr#"><input type="radio" name="MailMixPassw" <cfif OnePlan.MailMixPassw Is 1>checked</cfif> value="1"> Yes <input type="radio" name="MailMixPassw" <cfif OnePlan.MailMixPassw Is 0>checked</cfif> value="0"> No</td>
		<td bgcolor="#tbclr#" align="right">Mailbox Limit</td>
		<cfif OnePlan.MailBoxLimit is "">
			<cfset kblimit = 0>
		<cfelse>
			<cfset kblimit = OnePlan.MailBoxLimit>
		</cfif>
		<td bgcolor="#tdclr#"><input value="#kblimit#" type="text" name="MailBoxLimit" size="10" maxlength="10"> Bytes</td>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Scriptable Alias</td>
		<td bgcolor="#tdclr#"><input type="radio" name="EMailAliasYN" <cfif OnePlan.EMailAliasYN Is 1>checked</cfif> value="1"> Yes <input type="radio" name="EMailAliasYN" <cfif OnePlan.EMailAliasYN Is 0>checked</cfif> value="0"> No</td>
		<td bgcolor="#tbclr#" align=right>Default EMail Server</td>
</cfoutput>
		<cfset ShowWarning = 1>
		<td><select name="DefMailServer">
			<cfloop query="DefEMail">
				<cfoutput><option <cfif OnePlan.DefMailServer Is DomainName>selected<cfset ShowWarning = 0></cfif> value="#DomainName#">#DomainName# - #POP3Server#</cfoutput>
			</cfloop>
			<cfif DefEMail.RecordCount Is 0>
				<option value="">There are no domains selected for the EMail Integration
			</cfif>
			<cfif ShowWarning Is 1 AND DefEMail.RecordCount GT 0>
				<option selected value="">Please Select the Default EMail Server
			</cfif>
		</select></td>
	</tr>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">Mailbox Path</td>
		<td bgcolor="#tdclr#" colspan="3"><input value="#OnePlan.MailBox#" type="text" name="MailBox" size="40" maxlength="100"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>AW Lowercase Usernames</td>
		<td><input type="radio" name="AWMailLower" <cfif OnePlan.AWMailLower Is 1>checked</cfif> value="1"> Yes <input type="radio" name="AWMailLower" <cfif OnePlan.AWMailLower Is 0>checked</cfif> value="0"> No</td>
		<td bgcolor="#tbclr#" align=right>OS Lowercase Usernames</td>
		<td><input type="radio" name="OSMailLower" <cfif OnePlan.OSMailLower Is 1>checked</cfif> value="1"> Yes <input type="radio" name="OSMailLower" <cfif OnePlan.OSMailLower Is 0>checked</cfif> value="0"> No</td>
	</tr>
</cfoutput>
</cfif>
<cfoutput>
<tr valign="top">
	<th colspan="#HowWide#" bgcolor="#thclr#">FTP</th>
</tr>
<tr valign="top">
	<td bgcolor="#tbclr#" align=right>Setup FTP</td>
	<td bgcolor="#tdclr#"><input type="radio" name="ftpyn" value="1" <cfif (#oneplan.ftpyn# is 1) OR (#oneplan.ftpyn# is "")>Checked</cfif> >Yes <input type="radio" name="ftpyn" value="0" <cfif #oneplan.ftpyn# is 0>Checked</cfif> >No</td>
	<td bgcolor="#tbclr#" align=right>How Many FTPs</td>
	<td bgcolor="#tdclr#"><input type="text" name="FTPNumber" value="#OnePlan.FTPNumber#" size="3" maxlength="2"></td>
</tr>
</cfoutput>
<cfif OnePlan.FTPYN Is 1>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right colspan="3">Make FTP Username Match Auth Login And Password</td>
		<td bgcolor="#tdclr#"><input type="radio" name="FTPMatchYN" <cfif OnePlan.FTPMatchYN Is 1>Checked</cfif> value="1">Yes <input type="radio" name="FTPMatchYN" <cfif OnePlan.FTPMatchYN is 0>Checked</cfif> value="0">No</td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Prefix Chars</td>
		<td bgcolor="#tdclr#"><input type="text" name="FTPAddChars" value="#OnePlan.FTPAddChars#" size="10" maxlength="15"></td>
		<td bgcolor="#tbclr#" align=right>Suffix Chars</td>
		<td bgcolor="#tdclr#"><input type="text" name="FTPSufChars" value="#OnePlan.FTPSufChars#" size="10" maxlength="25"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Login Min Length</td>
		<td><input type="text" name="FTPMinLogin" value="#OnePlan.FTPMinLogin#" size="4" maxlength="3"></td>
		<td bgcolor="#tbclr#" align=right>Login Max Length</td>
		<td><input type="text" name="FTPMaxLogin" value="#OnePlan.FTPMaxLogin#" size="4" maxlength="3"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Password Min Length</td>
		<td><input type="text" name="FTPMinPassw" value="#OnePlan.FTPMinPassw#" size="4" maxlength="3"></td>
		<td bgcolor="#tbclr#" align=right>Password Max Length</td>
		<td><input type="text" name="FTPMaxPassw" value="#OnePlan.FTPMaxPassw#" size="4" maxlength="3"></td>
	</tr>
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>Require Mixed Passwords</td>
		<td><input type="radio" name="FTPMixPassw" <cfif OnePlan.FTPMixPassw Is 1>Checked</cfif> value="1">Yes <input type="radio" name="FTPMixPassw" <cfif OnePlan.FTPMixPassw is 0>Checked</cfif> value="0">No</td>
		<td bgcolor="#tbclr#" align="right">Default FTP Server</td>
	</cfoutput>	
		<cfset ShowWarning = 1>
		<td><select name="DefFTPServer">
			<cfloop query="DefFTP">
				<cfoutput><option <cfif OnePlan.DefFTPServer Is DomainName>selected<cfset ShowWarning = 0></cfif> value="#DomainName#">#DomainName# - #FTPServer#</cfoutput>
			</cfloop>
			<cfif DefFTP.RecordCount Is 0>
				<option value="">There are no domains selected for the FTP Integration
			</cfif>
			<cfif ShowWarning Is 1 AND DefFTP.RecordCount GT 0>
				<option selected value="">Please Select the Default FTP Server
			</cfif>
		</select></td>
	</tr>
	<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">Start Directory</td>
		<td bgcolor="#tdclr#" colspan="3"><input value="#OnePlan.Start_Dir#" type="text" name="start_dir" maxlength="150" size="40"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" valign=top align=right>Max Idle Time</td>
		<td bgcolor="#tdclr#"><input type="text" name="Max_Idle" value="#OnePlan.Max_Idle#" size="3" maxlength="8"> seconds</td>
		<td bgcolor="#tbclr#" valign=top align=right>Max Connect Time</td>
		<td bgcolor="#tdclr#"><input type="text" name="Max_Connect" value="#OnePlan.Max_Connect#" size="4" maxlength="8"> seconds</td>
	</tr>		
	<tr valign="top" bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align=right>AW Lowercase Usernames</td>
		<td><input type="radio" name="AWFTPLower" <cfif OnePlan.AWFTPLower Is 1>Checked</cfif> value="1">Yes <input type="radio" name="AWFTPLower" <cfif OnePlan.AWFTPLower is 0>Checked</cfif> value="0">No</td>
		<td bgcolor="#tbclr#" align=right>OS Lowercase Usernames</td>
		<td><input type="radio" name="OSFTPLower" <cfif OnePlan.OSFTPLower Is 1>Checked</cfif> value="1">Yes <input type="radio" name="OSFTPLower" <cfif OnePlan.OSFTPLower is 0>Checked</cfif> value="0">No</td>
	</tr>
	<tr valign="top">
		<th colspan="4">
			<table width="100%" cellpadding="0" border="0">
				<tr valign="top">
					<td bgcolor="#tbclr#" align="RIGHT">Read</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.Read1 is "1">checked</cfif> type="checkbox" name="read1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Write</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.Write1 is "1">checked</cfif> type="checkbox" name="write1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Create</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.Create1 is "1">checked</cfif> type="checkbox" name="create1" value="1"></th>
					<td bgcolor="#tbclr#" align="RIGHT">Delete</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.Delete1 is "1">checked</cfif> type="checkbox" name="delete1" value="1"></th>
				</tr>
				<tr valign="top">
					<td bgcolor="#tbclr#" align="RIGHT">Make Dirs</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.MkDir1 is "1">checked</cfif> type="checkbox" name="mkdir1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Remove Dirs</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.RmDir1 is "1">checked</cfif> type="checkbox" name="rmdir1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">No Redir</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.NoRedir1 is "1">checked</cfif> type="checkbox" name="noredir1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Any Directory</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.AnyDir1 is "1">checked</cfif> type="checkbox" name="anydir1" value="1"></th>
				</tr>
				<tr valign="top">
					<td bgcolor="#tbclr#" align="RIGHT">Any Drive</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.AnyDrive1 is "1">checked</cfif> type="checkbox" name="anydrive1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">No Drive</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.NoDrive1 is "1">checked</cfif> type="checkbox" name="nodrive1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Put Any</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.PutAny1 is "1">checked</cfif> type="checkbox" name="putany1" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Super Level</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.Super1 is "1">checked</cfif> type="checkbox" name="super1" value="1"></th>
				</tr>
				<tr valign="top">
					<td bgcolor="#tbclr#" align="RIGHT">Execute Files</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.FTPExecFile is "1">checked</cfif> type="checkbox" name="FTPExecFile" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">List Dirs</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.FTPListDirs is "1">checked</cfif> type="checkbox" name="FTPListDirs" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">Inherit Dirs</td>
					<th bgcolor="#tdclr#"><input <cfif OnePlan.FTPInheritD is "1">checked</cfif> type="checkbox" name="FTPInheritD" value="1"></th> 
					<td bgcolor="#tbclr#" align="RIGHT">&nbsp;</td>
					<th bgcolor="#tdclr#">&nbsp;</th>
				</tr>
			</table>				
		</td>
	</tr>
	</cfoutput>
</cfif>
<cfoutput>
<tr valign="top">
	<th colspan="4" bgcolor="#thclr#">Misc</th>
</tr>
<tr valign="top">
	<td bgcolor="#tbclr#" align=right>Ext. System File</td>
	<td bgcolor="#tdclr#"><input type="text" value="#OnePlan.ExtSysFile#" name="ExtSysFile" size="15"></td>
	<input type="hidden" name="WebHostYN" value="0">
	<td bgcolor="#tbclr#" align=right>Prefix</td>
	<td bgcolor="#tdclr#"><input type="Text" size="5" maxlength="5" name="DeactPassWord" value="#OnePlan.DeactPassWord#"> to passwords when deactivating.</td>
</tr>
<tr valign="top">
	<th colspan="4"><input type="image" src="images/update.gif" border="0" name="UpdateTab3"></th>
</tr>
</cfoutput>
</form>
 