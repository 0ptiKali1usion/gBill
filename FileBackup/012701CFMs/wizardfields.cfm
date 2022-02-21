<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the setup page for the wizard drop downs. --->
<!---	4.0.2 01/25/01 Fixed an error with the Default Postal Option.
		4.0.1 01/16/01 Fixed problem where page 1 would not allow going to page 2 when Salesperson was required.
		4.0.0 09/28/99 --->
<!--- wizardfields.cfm --->

<cfsetting enablecfoutputonly="no">
<cfloop query="WhichPage">
	<cfif HideRow Is 0><tr valign="top"><cfelse><cfset HideRow = 0></cfif>
		<cfquery name="GetRow" datasource="#pds#">
			SELECT * 
			FROM WizardSetup 
			WHERE PageNumber = #PageNumber# 
			AND RowOrder = #RowOrder# 
			AND ActiveYN = 1 
			AND AWUseYN = 1 
			ORDER BY SortOrder 
		</cfquery>
		<cfset ColCount = HowWide/GetRow.RecordCount>
		<cfloop query="GetRow">
				<cfif BOBFieldName Is "Country">
					<cfquery name="AllCountries" datasource="#pds#">
						SELECT CountryAbbr, Country, DefCountry 
						FROM Countries 
						WHERE ActiveYN = 1 
						ORDER BY Country
					</cfquery>
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="Country">
					</cfoutput>
							<cfloop query="AllCountries">
								<cfoutput><option <cfif IsDefined("AccountID")><cfif SignUpInfo.Country Is CountryAbbr>selected</cfif><cfelse><cfif DefCountry Is 1>selected</cfif></cfif> value="#CountryAbbr#">#Country#</cfoutput>
							</cfloop>
						</select></td>
						<cfif InputRequired Is 1>
							<cfoutput>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfoutput>
						</cfif>
				<cfelseif BOBFieldName Is "State">
					<cfquery name="AllStates" datasource="#pds#">
						SELECT Abbr, StateName, DefState 
						FROM States 
						WHERE ActiveYN = 1 
						AND StateID In 
							(SELECT StateID 
							 FROM POPsStates 
							 WHERE POPID IN 
							 	(SELECT POPID 
								 FROM POPAdm 
								 WHERE AdminID = #MyAdminID#))
						ORDER BY StateName
					</cfquery>
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="State">
					</cfoutput>
							<cfloop query="AllStates">
								<cfoutput><option <cfif IsDefined("AccountID")><cfif SignUpInfo.State Is Abbr>selected</cfif><cfelse><cfif DefState Is 1>selected</cfif></cfif> value="#Abbr#">#StateName#</cfoutput>
							</cfloop>
						</select></td>
						<cfif InputRequired Is 1>
							<cfoutput>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfoutput>
						</cfif>
				<cfelseif BOBFieldName Is "ModemSpeed">
					<cfquery name="AllSpeeds" datasource="#pds#">
						SELECT * 
						FROM ModemSpeeds 
						WHERE AccountYN = 1 
						ORDER BY SortOrder 
					</cfquery>
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>		
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="ModemSpeed">
					</cfoutput>
					<cfoutput query="AllSpeeds">
						<option <cfif IsDefined("AccountID")><cfif SignUpInfo.ModemSpeed Is ModemSpeed>selected</cfif><cfelse><cfif DefSpeed Is 1>selected</cfif></cfif> value="#ModemSpeed#">#ModemSpeed#
					</cfoutput>
					</select></td>
					<cfif InputRequired Is 1>
						<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
					</cfif>
				<cfelseif BOBFieldName Is "OSVersion">
					<cfquery name="AllOSOptions" datasource="#pds#">
						SELECT * 
						FROM OSVersion 
						WHERE AccountYN = 1 
						ORDER BY SortOrder 
					</cfquery>				
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>		
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="OSVersion">
					</cfoutput>
					<cfoutput query="AllOSOptions">
						<option <cfif osv Is SignUpInfo.OSVersion>Selected</cfif> value="#OSV#">#OSV#
					</cfoutput>
					</select></td>
					<cfif InputRequired Is 1>
						<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
					</cfif>
				<cfelseif BOBFieldName Is "POPID">
					<cfquery name="AvailPops" datasource="#pds#">
						SELECT P.POPID, P.POPName, P.DataAreaCode, P.PhoneData, P.DefPOP 
						FROM POPs P, POPsStates S 
						WHERE P.POPID = S.POPID 
						<cfif IsDefined("GetOpts")>
							AND P.POPID In 
								(SELECT POPID 
								 FROM POPAdm 
								 WHERE AdminID = #GetOpts.AdminID#) 
						</cfif>
						AND S.StateID = 
								(Select StateID 
								 FROM States 
								 WHERE Abbr = '#SignUpInfo.State#')
						ORDER BY POPName 
					</cfquery>
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>		
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="POPID">
					</cfoutput>
					<cfoutput query="AvailPOPS">
						<option <cfif SignUpInfo.POPID Is POPID>selected<cfelseif (DefPOP Is 1) AND (SignUpInfo.POPID Is "")>selected</cfif> value="#POPID#">#POPName# - (#DataAreaCode# #PhoneData#)
					</cfoutput>
					</select></td>
					<cfif InputRequired Is 1>
						<cfoutput>
							<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
						</cfoutput>
					</cfif>
				<cfelseif BOBFieldName Is "SalespersonID">
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>
					</cfoutput>			
					<cfif GetOpts.EditName Is 1>
						<cfquery name="SalesPeople" datasource="#pds#">
							SELECT A.AdminID, C.FirstName, C.LastName 
							FROM Accounts C, Admin A 
							WHERE C.AccountID = A.AccountID 
							AND A.SalesPersonYN = 1 
							AND A.AdminID In 
								(SELECT SalesID 
								 FROM SalesAdm 
								 WHERE AdminID = #MyAdminID#) 
							ORDER BY C.LastName, C.FirstName 
						</cfquery>
						<cfoutput>
						<td bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><select name="#BOBFieldName#">
						</cfoutput>
							<cfoutput query="SalesPeople">
								<option <cfif IsDefined("AccountID")><cfif SignUpInfo.SalesPersonID Is AdminID>selected</cfif><cfelse><cfif AdminID Is MyAdminID>selected</cfif></cfif> value="#AdminID#">#LastName#, #FirstName#
							</cfoutput>
						</select></td>
						<cfif InputRequired Is 1>
							<cfoutput>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfoutput>
						</cfif>
					<cfelse>
						<cfoutput>
							<td bgcolor="#tdclr#" colspan="#TheCol#">#StaffMemberName.FirstName# #StaffMemberName.LastName#</td>
							<input type="hidden" name="SalespersonID" value="#MyAdminID#">
						</cfoutput>
					</cfif>
				<cfelseif BOBFieldName Is "SelectPlan">
					<cfsetting enablecfoutputonly="yes">
					<cfhtmlhead text="<script language=""javascript"">
<!--  
function MsgWindow(var1)
	{
 	 var var2 = var1
    window.open('plandesc.cfm?PlanID='+var2,'Description','scrollbars=auto,status=no,width=400,height=200,location=no,resizable=no');
	}
// -->
</script>
">
					<cfquery name="AvailPlans" datasource="#pds#">
						SELECT PlanID, PlanDesc, RecurDiscount, FixedDiscount, FixedAmount, RecurringAmount, DefPlan, RecurringCycle, 
						OSPlanDisplay, AWPlanDisplay 
						FROM Plans 
						WHERE PlanID <> #delaccount# 
						AND PlanID <> #deactaccount# 
						AND ShowAWYN = 1 
						<cfif IsDefined("GetOpts")>
							AND PlanID In 
									(SELECT PlanID 
									 FROM PlanAdm 
									 WHERE AdminID = #GetOpts.AdminID#)
						</cfif>
						AND PlanID In 
								(SELECT PlanID 
								 FROM POPPlans 
								 WHERE POPID = #SignUpInfo.POPID#) 
						<cfif IsDefined("SignUpInfo.PromoCode")>
							OR PlanID In 
								(SELECT PlanID 
								 FROM Plans 
								 WHERE TotalInternetCode = '#SignUpInfo.PromoCode#')
						</cfif>
						ORDER BY PlanDesc
					</cfquery>
					<cfquery name="GetLocale" datasource="#pds#">
						SELECT Value1 
						FROM Setup 
						WHERE VarName = 'Locale'
					</cfquery>
					<cfset Locale = GetLocale.Value1>
					<cfsetting enablecfoutputonly="no">
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
								<td bgcolor="#tbclr#" colspan="#ColCount#">#ScreenPrompt#</td>
							</tr>
							<tr valign="top">
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>		
						<td bgcolor="#tdclr#" colspan="#ColCount#">
							<table border="1" width="100%">
								<tr bgcolor="#thclr#">
									<th>Select</th>
									<th>Months</th>
									<th>Service</th>
									<th>Recurring</th>
									<th>Discount</th>
									<th>Setup</th>
									<th>Discount</th>
									<th>Total</th>
								</tr>
								<tr>
									<td colspan="8" bgcolor="#thclr#">* Click on the Service Name for a description.<cfif IsDefined("MyAdminID")><br>! Important Staff Note</cfif></td>
								</tr>
					</cfoutput>
								<cfoutput query="AvailPlans">
									<tr bgcolor="#tbclr#">
										<th bgcolor="#tdclr#"><input type="checkbox" <cfif ListFind(SignUpInfo.SelectPlan,PlanID) GT 0>checked</cfif> name="SelectPlan" value="#PlanID#"></th>
										<td align="right">#Int(RecurringCycle)# <cfif RecurringCycle Is 1>Month<cfelse>Months</cfif></td>
										<cfif (Trim(AWPlanDisplay) Is Not "") OR (Trim(OSPlanDisplay) Is Not "")>
											<td><a href="plandesc.cfm?PlanID=#PlanID#" target="_PlanDesc" onclick="MsgWindow(#PlanID#);return false"><cfif (Trim(AWPlanDisplay) Is Not "")>! </cfif> *#PlanDesc#</a></td>
										<cfelse>
											<td>#PlanDesc#</td>
										</cfif>
										<td align="right">#LSCurrencyFormat(RecurringAmount)#</td>
										<td align="right">#LSCurrencyFormat(RecurDiscount)#</td>
										<td align="right">#LSCurrencyFormat(FixedAmount)#</td>
										<td align="right">#LSCurrencyFormat(FixedDiscount)#</td>
										<cfset TOT = RecurringAmount + FixedAmount - RecurDiscount - FixedDiscount>
										<td align="right">#LSCurrencyFormat(TOT)#</td>
									</tr>
								</cfoutput>
								<input type="hidden" name="SelectPlan_Required" value="Please select the desired service.">
							</table>
						</td>
				<cfelseif BOBFieldName Is "waivea">
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>			
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>		
						<td bgcolor="#tdclr#" colspan="#TheCol#"><input type="radio" <cfif SignUpInfo.WaiveA Is 1>checked</cfif> name="WaiveA" value="1">Yes <input type="radio" <cfif SignUpInfo.WaiveA Is 0>checked</cfif> name="WaiveA" value="0">No</td>
						<cfif InputRequired Is 1>
							<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
						</cfif>
					</cfoutput>					
				<cfelseif BOBFieldName Is "userinfo">
					<cfquery name="GetPlansInfo" datasource="#pds#">
						SELECT PlanDesc, PlanID, DefAuthServer, DefMailServer, DefFTPServer, 
						Radius, AuthNumber, LowerAWYN, AWStaticIPYN, AuthAddChars, AuthMaxLogin, AuthMaxPassw, AuthMixPassw, AuthMinPassw, AuthMinLogin, 
						emailyn, freeemails, EMailMatchYN, EMailLogDiffYN, AWMailLower, MailMaxLogin, MailMaxPassw, MailMinLogin, MailMinPassw, MailMixPassw, 
						ftpyn, FTPNumber, FTPMatchYN, FTPAddChars, AWFTPLower, FTPMaxLogin, FTPMaxPassw, FTPMinLogin, FTPMinPassw, FTPMixPassw,  
						BOBLogin, WebHostYN, ExpireTo, ExpireDays, AuthSufChars, FTPSufChars 
						FROM Plans 
						WHERE PlanID In (#SignUpInfo.SelectPlan#) 
						ORDER BY PlanDesc 
					</cfquery>
					<cfset BOBLoginType = "">
					<cfloop query="GetPlansInfo">
						<cfif (ExpireTo Is Not "") AND (ExpireTo GT "0")>
							<cfquery name="CheckRollbacks" datasource="#pds#">
								SELECT PlanDesc, PlanID, 
								Radius, AuthNumber, LowerAWYN, AWStaticIPYN, AuthAddChars, AuthMaxLogin, AuthMaxPassw, AuthMixPassw, AuthMinPassw, AuthMinLogin, 
								emailyn, freeemails, EMailMatchYN, EMailLogDiffYN, AWMailLower, MailMaxLogin, MailMaxPassw, MailMinLogin, MailMinPassw, MailMixPassw, 
								ftpyn, FTPNumber, FTPMatchYN, FTPAddChars, AWFTPLower, FTPMaxLogin, FTPMaxPassw, FTPMinLogin, FTPMinPassw, FTPMixPassw,  
								BOBLogin, WebHostYN, ExpireTo, ExpireDays 
								FROM Plans 
								WHERE PlanID = #ExpireTo#
							</cfquery>
							<cfquery name="DomainInfo" datasource="#pds#">
								SELECT DomainID, DomainName, Primary1 
								FROM Domains 
								WHERE DomainID In 
									(SELECT DomainID 
									 FROM DomPlans 
									 WHERE PlanID = #PlanID#)
								AND DomainID In 
									(SELECT DomainID 
									 FROM DomPlans 
									 WHERE PlanID = #CheckRollbacks.PlanID#) 
								AND DomainID In 
									(SELECT DomainID 
									 FROM DomAdm 
									 WHERE AdminID = #MyAdminID#)
								Order By DomainName
							</cfquery>
							<cfset Rollback = 1>
						<cfelse>
							<cfquery name="DomainInfo" datasource="#pds#">
								SELECT DomainID, DomainName, Primary1 
								FROM Domains 
								WHERE DomainID In 
									(SELECT DomainID 
									 FROM DomPlans 
									 WHERE PlanID = #PlanID#)
								AND DomainID In 
									(SELECT DomainID 
									 FROM DomAdm 
									 WHERE AdminID = #MyAdminID#)
								Order By DomainName
							</cfquery>
							<cfset Rollback = 0>
						</cfif>
						<cfquery name="AuthDomainInfo" datasource="#pds#">
							SELECT AuthServer, DomainName, DomainID 
							FROM Domains 
							WHERE DomainID IN 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#) 
							<cfif GetOpts.OverRide Is "0">
								AND DomainID IN 
									(SELECT DomainID 
									 FROM DomAPlans 
									 WHERE PlanID = #PlanID#) 
							</cfif>
							ORDER BY DomainName 
						</cfquery>
						<cfquery name="FTPDomainInfo" datasource="#pds#">
							SELECT FTPServer, DomainName, DomainID 
							FROM Domains 
							WHERE DomainID IN 
								(SELECT DomainID 
								 FROM DomAdm 
								 WHERE AdminID = #MyAdminID#) 
							<cfif GetOpts.OverRide Is "0">
								AND DomainID IN 
									(SELECT DomainID 
									 FROM DomFPlans 
									 WHERE PlanID = #PlanID#) 
							</cfif>
							ORDER BY DomainName 
						</cfquery>
						<cfset BOBLoginType = ListAppend(BOBLoginType,BOBLogin)>
						<!--- Check to see if E-Mail addresses match the authentication login --->
						<cfset EMatch = EMailMatchYN>
						<cfif Rollback Is 1>
							<cfif CheckRollbacks.EMailMatchYN Is 1>
								<cfset EMatch = 1>
							</cfif>
						</cfif>
						<!--- Check to see if FTP logins match the auth login --->
						<cfset FTPMatch = FTPMatchYN>
						<cfif Rollback Is 1>								
							<cfif CheckRollbacks.FTPMatchYN Is 1>
								<cfset FTPMatch = 1>
							</cfif>
						</cfif>
						<!--- Start the form --->
						<cfif IsDefined("ShowTr")><tr valign="top"></cfif>
							<cfset ShowTr = 1>
							<cfoutput>
								<th bgcolor="#thclr#" colspan="#ColCount#">#PlanDesc#</th>
							</cfoutput>
						</tr>
						<cfif Rollback Is 1>
							<tr valign="top">
								<cfoutput>
									<td bgcolor="#tbclr#" colspan="#ColCount#">Expires to: #CheckRollbacks.PlanDesc# in #ExpireDays# days </td>
								</cfoutput>
							</tr>
						</cfif>
						<cfset TotAuth = 0>
						<cfif Radius Is 1>
							<tr valign="top">
								<cfoutput><th bgcolor="#thclr#" colspan="#ColCount#">Authentication</th></cfoutput>
							</tr>
							<cfset TheDefAuthServer = DefAuthServer>
							<cfset TotalAuth = AuthNumber>
							<cfset MaxAuth = AuthMaxLogin>
							<cfset MinAuth = AuthMinLogin>
							<cfset MaxAuthP = AuthMaxPassw>
							<cfset MinAuthP = AuthMinPassw>
							<cfset AuthCase = LowerAWYN>
							<cfset MixedPassword = AuthMixPassw>
							<cfset AskStaticIP = AWStaticIPYN>
							<cfset TheAddChars = Trim(AuthAddChars)>
							<cfset TheLstChars = Trim(AuthSufChars)>
							<cfif Rollback Is 1>
								<cfset TotalAuth2 = CheckRollbacks.AuthNumber>
								<cfset TotalAuth = Min(AuthNumber,TotalAuth2)>
								<cfset MaxAuth = Min(AuthMaxLogin,CheckRollbacks.AuthMaxLogin)>
								<cfset MinAuth = Min(AuthMinLogin,CheckRollbacks.AuthMinLogin)>
								<cfset MaxAuthP = Min(AuthMaxPassw,CheckRollbacks.AuthMaxPassw)>
								<cfset MinAuthP = Min(AuthMaxPassw,CheckRollbacks.AuthMinPassw)>
								<cfif CheckRollbacks.LowerAWYN Is 1>
									<cfset AuthCase = 1>
								</cfif>
								<cfif CheckRollbacks.AuthMixPassw Is 1>
									<cfset MixedPassword = 1>
								</cfif>
								<cfif CheckRollbacks.AWStaticIPYN Is 1>
									<cfset AskStaticIP = 1>
								</cfif>
								<cfif Trim(CheckRollbacks.AuthAddChars) Is Not "">
									<cfset TheAddChars = Trim(CheckRollbacks.AuthAddChars)>
								</cfif>
							</cfif>
							<cfset countera = 0>
							<cfloop index="B5" from="1" to="#TotalAuth#">
								<cfset countera = countera + 1>
								<cfoutput>
									<tr valign="top">
										<td bgcolor="#tbclr#" align="right">Login</td>
										<cfif IsDefined("Plan#PlanID#ALogin#B5#")>
											<cfset ThisValue = Evaluate("Plan#PlanID#ALogin#B5#")>
										<cfelse>
											<cfset ThisValue = "">
										</cfif>
										<td bgcolor="#tdclr#">#TheAddChars#<input type="text" value="#ThisValue#" name="Plan#PlanID#ALogin#B5#" maxlength="#MaxAuth#" size="35">#TheLstChars#<br>
										<font size="1">#MinAuth# - #MaxAuth# characters.</font><cfif EMatch Is 1><font size="1">This is also your e-mail address.</font></cfif><cfif Authcase Is 1><font size="1"> (Must be lowercase)</font></cfif></td>
									</tr>
									<cfif AuthDomainInfo.RecordCount GT 1>
									<tr valign="top">
										<td bgcolor="#tbclr#" align="right">Auth Server</td>
										<cfif IsDefined("Plan#PlanID#AServer#B5#")>
											<cfset ThisValue = Evaluate("Plan#PlanID#AServer#B5#")>
										<cfelse>
											<cfset ThisValue = TheDefAuthServer>
										</cfif>
										<td bgcolor="#tdclr#"><select name="Plan#PlanID#AServer#B5#">
											<cfloop query="AuthDomainInfo">
												<option <cfif ThisValue Is DomainID>selected<cfelseif ThisValue Is DomainName>selected</cfif> value="#DomainID#">#DomainName# - #AuthServer#
											</cfloop>
										</select></td>
									</tr>
									<cfelse>
										<input type="Hidden" name="Plan#PlanID#AServer#B5#" value="#AuthDomainInfo.DomainID#">
									</cfif>
									<tr valign="top">
										<td bgcolor="#tbclr#" align="right">Password</td>
										<cfif IsDefined("Plan#PlanID#APassword#B5#")>
											<cfset ThisValue = Evaluate("Plan#PlanID#APassword#B5#")>
										<cfelse>
											<cfset ThisValue = "">
										</cfif>
										<td bgcolor="#tdclr#"><input type="text" value="#ThisValue#" name="Plan#PlanID#APassword#B5#" maxlength="#MaxAuthP#"><br>
										<font size="1">#MinAuthP# - #MaxAuthP# characters.</font><cfif MixedPassword Is 1><font size="1"> (Must contain letters and numbers)</font></cfif></td>
									</tr>
									<input type="Hidden" name="Plan#PlanID#StaticIP#B5#" value="0">
								</cfoutput>
<!---									<cfif AskStaticIP Is 1>
								<cfoutput>
										<tr valign="top">
											<td align="right" bgcolor="#tbclr#">Assign Static IP</td>
											<cfif IsDefined("Plan#PlanID#StaticIP#B5#")>
												<cfset ThisValue = 1>
											<cfelse>
												<cfset ThisValue = 0>
											</cfif>
											<td bgcolor="#tdclr#"><input <cfif ThisValue Is 1>checked</cfif> type="checkbox" name="Plan#PlanID#StaticIP#B5#" value="1"></td>
										</tr>
									</cfif>
								</cfoutput>
--->
							</cfloop>
							<cfset TotAuth = countera>
						</cfif>
						<cfoutput>
							<input type="hidden" name="Setup#PlanID#AuthNum" value="#TotAuth#">
							<input type="hidden" name="Setup#PlanID#Server" value="#DefAuthServer#">
						</cfoutput>
						<cfset TotEMail = 0>
						<cfif (EMailYN Is 1) AND (EMatch Is 0)>
							<tr valign="top">
								<cfoutput><th bgcolor="#thclr#" colspan="#ColCount#">EMail</th></cfoutput>
							</tr>
							<cfset TotalEMail = FreeEMails>
							<cfset ELogDiff = EMailLogDiffYN>
							<cfset MailLower = AWMailLower>
							<cfset MailMax = MailMaxLogin>
							<cfset MailMaxP = MailMaxPassw>
							<cfset MailMin = MailMinLogin>
							<cfset MailMinP = MailMinPassw>
							<cfset MailMixP = MailMixPassw>
							<cfif Rollback Is 1>
								<cfset TotalEMail2 = CheckRollbacks.FreeEMails>
								<cfset TotalEMail = Min(FreeEMails,TotalEMail2)>
								<cfset MailMax = Min(MailMaxLogin,CheckRollbacks.MailMaxLogin)>
								<cfset MailMaxP = Min(MailMaxPassw,CheckRollbacks.MailMaxPassw)>
								<cfset MailMin = Min(MailMinLogin,CheckRollbacks.MailMinLogin)>
								<cfset MailMinP = Min(MailMinPassw,CheckRollbacks.MailMinPassw)>
								<cfif CheckRollbacks.MailMixPassw Is 1>
									<cfset MailMixP = 1>
								</cfif>
								<cfif CheckRollbacks.AWMailLower Is 1>
									<cfset MailLower = 1>
								</cfif>
								<cfif CheckRollbacks.EMailLogDiffYN Is 0>
									<cfset ELogDiff = 0>
								</cfif>
							</cfif>
							<cfset countere = 0>
								<cfloop index="B4" from="1" to="#TotalEMail#">
									<cfset countere = countere + 1>
									<cfoutput>
										<tr valign="top" bgcolor="#tdclr#">
											<td bgcolor="#tbclr#" align="right">E-Mail Address</td>
											<cfif IsDefined("Plan#PlanID#EUserName#B4#")>
												<cfset ThisValue = Evaluate("Plan#PlanID#EUserName#B4#")>
											<cfelse>
												<cfset ThisValue = "">
											</cfif>
											<cfif IsDefined("Plan#PlanID#EDomainID#B4#")>
												<cfset ThisValue2 = Evaluate("Plan#PlanID#EDomainID#B4#")>
											<cfelse>
												<cfset ThisValue2 = DefMailServer>
											</cfif>
											<td><input type="text" value="#ThisValue#" name="Plan#PlanID#EUserName#B4#" size="20" maxlength="#MailMax#">@<select name="Plan#PlanID#EDomainName#B4#"></cfoutput>
												<cfoutput query="DomainInfo">
													<option <cfif DomainID Is ThisValue2>selected<cfelseif ThisValue2 Is DomainName>selected</cfif> value="#DomainID#">#DomainName#
												</cfoutput>
											</select><br>
									<cfoutput>
											<font size="1">#MailMin# - #MailMax# characters.</font><cfif MailLower Is 1><font size="1"> (Must be lowercase)</font></cfif></td>
										</tr>
										<cfif ELogDiff Is Not 0>
											<tr valign="top">
												<td bgcolor="#tbclr#" align="right">Login</td>
												<cfif IsDefined("Plan#PlanID#ELogin#B4#")>
													<cfset ThisValue = Evaluate("Plan#PlanID#ELogin#B4#")>
												<cfelse>
													<cfset ThisValue = "">
												</cfif>
												<td bgcolor="#tdclr#"><input type="text" value="#ThisValue#" name="Plan#PlanID#ELogin#B4#" size="35" maxlength="#MailMax#"><br>
												<font size="1">#MailMin# - #MailMax# characters.</font><cfif MailLower Is 1><font size="1"> (Must be lowercase)</font></cfif></td>
											</tr>
										</cfif>
										<tr valign="top">
											<td bgcolor="#tbclr#" align="right">Password</td>
											<cfif IsDefined("Plan#PlanID#EPassword#B4#")>
												<cfset ThisValue = Evaluate("Plan#PlanID#EPassword#B4#")>
											<cfelse>
												<cfset ThisValue = "">
											</cfif>
											<td bgcolor="#tdclr#"><input type="text" value="#ThisValue#" name="Plan#PlanID#EPassword#B4#" size="35" maxlength="#MailMaxP#"><br>
											<font size="1">#MailMinP# - #MailMaxP# characters.</font><cfif MailMixP Is 1><font size="1"> (Must contain letters and numbers)</font></cfif></td>
										</tr>
									</cfoutput>
								</cfloop>
								<cfset TotEMail = countere>
						</cfif>
						<cfoutput><input type="hidden" name="Setup#PlanID#EMailNum" value="#TotEMail#"></cfoutput>
						<cfset TotFTP = 0>
						<cfif (FTPYN Is 1) AND (FTPMatch Is 0)>
							<tr valign="top">
								<cfoutput><th bgcolor="#thclr#" colspan="#ColCount#">FTP</th></cfoutput>
							</tr>
							<cfset TheDefFTPServer = DefFTPServer>
							<cfset TotalFTP = FTPNumber>
							<cfset FTPLower = AWFTPLower>
							<cfset FTPMaxL = FTPMaxLogin>
							<cfset FTPMaxP = FTPMaxPassw>
							<cfset FTPMinL = FTPMinLogin>
							<cfset FTPMinP = FTPMinPassw>
							<cfset FTPMixP = FTPMixPassw>		
							<cfset FTPAddC = Trim(FTPAddChars)>		
							<cfset FTPSufC = Trim(FTPSufChars)>					
							<cfif Rollback Is 1>
								<cfset TotalFTP = Min(FTPNumber,CheckRollbacks.FTPNumber)>
								<cfset FTPMaxL = Min(FTPMaxLogin,CheckRollbacks.FTPMaxLogin)>
								<cfset FTPMaxP = Min(FTPMaxPassw,CheckRollbacks.FTPMaxPassw)>
								<cfset FTPMinL = Min(FTPMinLogin,CheckRollbacks.FTPMinLogin)>
								<cfset FTPMinP = Min(FTPMinPassw,CheckRollbacks.FTPMinPassw)>
								<cfif CheckRollbacks.FTPMixPassw Is 1>
									<cfset FTPMixP = 1>
								</cfif>
								<cfif CheckRollbacks.AWFTPLower Is 1>
									<cfset FTPLower = 1>
								</cfif>
								<cfif Trim(CheckRollbacks.FTPAddChars) Is Not "">
									<cfset FTPAddC = Trim(CheckRollbacks.FTPAddChars)>
								</cfif>
							</cfif>
							<cfset counterf = 0>
							<cfloop index="B3" from="1" to="#TotalFTP#">
								<cfset counterf = counterf + 1>
								<cfoutput>
									<tr bgcolor="#tbclr#">
										<td align="right">Login</td>
										<cfif IsDefined("Plan#PlanID#FLogin#B3#")>
											<cfset ThisValue = Evaluate("Plan#PlanID#FLogin#B3#")>
										<cfelse>
											<cfset ThisValue = "">
										</cfif>
										<td bgcolor="#tdclr#">#FTPAddC#<input type="text" value="#ThisValue#" name="Plan#PlanID#FLogin#B3#" maxlength="#FTPMaxL#" size="35">#FTPSufC#<br>
										<font size="1">#FTPMinL# - #FTPMaxL# characters.</font><cfif FTPLower Is 1><font size="1"> (Must be lowercase)</font></cfif></td>
									</tr>
									<cfif FTPDomainInfo.RecordCount GT 1>
										<tr bgcolor="#tbclr#">
											<td align="right">FTP Server</td>
											<cfif IsDefined("Plan#PlanID#FServer#B3#")>
												<cfset ThisValue = Evaluate("Plan#PlanID#FServer#B3#")>
											<cfelse>
												<cfset ThisValue = DefFTPServer>
											</cfif>
											<td bgcolor="#tdclr#"><select name="Plan#PlanID#FServer#B3#">
												<cfloop query="FTPDomainInfo">
													<option <cfif ThisValue Is DomainID>selected<cfelseif ThisValue Is DomainName>selected</cfif> value="#DomainID#">#DomainName# - #FTPServer#
												</cfloop>
											</select></td>
										</tr>
									<cfelse>
										<input type="Hidden" name="Plan#PlanID#FServer#B3#" value="#FTPDomainInfo.DomainID#">
									</cfif>
									<tr valign="top">
										<td bgcolor="#tbclr#" align="right">Password</td>
										<cfif IsDefined("Plan#PlanID#FPassword#B3#")>
											<cfset ThisValue = Evaluate("Plan#PlanID#FPassword#B3#")>
										<cfelse>
											<cfset ThisValue = "">
										</cfif>
										<td bgcolor="#tdclr#"><input type="text" value="#ThisValue#" name="Plan#PlanID#FPassword#B3#" maxlength="#FTPMaxP#" size="35"><br>
										<font size="1">#FTPMinP# - #FTPMaxP# characters.</font><cfif FTPMixP Is 1><font size="1"> (Must contain letters and numbers)</font></cfif></td>
									</tr>
								</cfoutput>
							</cfloop>
							<cfset TotFTP = counterf>
						</cfif>
						<cfoutput>
							<input type="hidden" name="Setup#PlanID#FTPNum" value="#TotFTP#">
							<input type="hidden" name="Setup#PlanID#FServer" value="#DefFTPServer#">
						</cfoutput>
						<cfif WebHostYN Is 1>
							<tr valign="top">
								<cfoutput><th bgcolor="#thclr#" colspan="#ColCount#">Web Hosting</th></cfoutput>
							</tr>
						</cfif>
					</cfloop>
					<tr valign="top">
						<cfoutput><th bgcolor="#thclr#" colspan="#ColCount#">gBill Login</th></cfoutput>
					</tr>
					<cfoutput>
						<tr bgcolor="#tbclr#" valign="top">
							<td align="right">Login</td>
							<td bgcolor="#tdclr#">*<input type="text" value="#SignUpInfo.Login#" name="BOBLogin" maxlength="75" size="35"></td>
							<input type="hidden" name="BOBLogin_Required" value="Please enter the login to be used for gBill.">
						</tr>
						<tr valign="top" bgcolor="#tbclr#">
							<td align="right">Password</td>
							<td bgcolor="#tdclr#">*<input type="text" value="#SignUpInfo.Password#" name="BOBPassword" maxlength="75" size="35"></td>
							<input type="hidden" name="BOBPassword_Required" value="Please enter the password to be used for gBill.">
						</tr>
					</cfoutput>
				<cfelseif BOBFieldName Is "creditcard">
						<cfquery name="PlanInfo" datasource="#pds#">
							SELECT AWPayCC, AWChkMod, AWUseAVS 
							FROM Plans 
							WHERE PlanID In (#ValueList(SignUpInfo.SelectPlan)#)
						</cfquery>
						<cfif ListFind(#ValueList(PlanInfo.AWPayCC)#,1) GT 0>
								<cfquery name="CCInfo" datasource="#pds#">
									SELECT * 
									FROM PayTypes 
									WHERE UseTab = 2 
									AND ActiveYN = 1 
									ORDER BY SortOrder 
								</cfquery>
								<cfoutput><th bgcolor="#thclr#" colspan="2">Credit Card</th></cfoutput>
							</tr>
							<cfloop query="CCInfo">
								<cfoutput>
									<tr>
										<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
								</cfoutput>
										<cfif FieldName Is "CCNumber">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CCNum" value="#SignUpInfo.CCNum#" size="16" maxlength="#FieldSize#"></td>
											</cfoutput>
										<cfelseif FieldName Is "CCType">
											<cfquery name="GetCardTypes" datasource="#pds#">
												SELECT CardType 
												FROM CreditCardTypes 
												WHERE ActiveYN = 1 
												AND UseAw = 1 
												AND CardTypeId In 
													(SELECT CardTypeID 
													 FROM PlanCCTypes 
													 WHERE WizardType ='AW' 
													 AND PlanID In (#ValueList(SignUpInfo.SelectPlan)#) 
													 GROUP BY CardTypeID ) 
												Order By SortOrder, CardType 
											</cfquery>
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><select name="CCType">
											</cfoutput>
												<cfloop query="GetCardTypes">
													<cfoutput><option <cfif SignUpInfo.CCType Is CardType>selected</cfif> value="#CardType#">#CardType#</cfoutput>
												</cfloop>
											</select></td>
										<cfelseif FieldName Is "CCMonth">
											<cfoutput>
											<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><select name="CCMon">
											</cfoutput>
												<cfloop index="B5" from="1" to="12">
													<cfif B5 LT 10><cfset B5 = "0" & B5></cfif>
													<cfoutput><option <cfif SignUpInfo.CCMon Is B5>selected</cfif> value="#B5#">#MonthAsString(B5)#</cfoutput>
												</cfloop>
											</select></td>
										<cfelseif FieldName Is "CCYear">
											<cfoutput>
											<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><select name="CCYear">
											</cfoutput>
												<cfset EYear = DateAdd("yyyy","10",Now())>
												<cfloop index="B5" from="#Year(Now())#" to="#Year(EYear)#">
													<cfoutput><option <cfif SignUpInfo.CCYear Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
												</cfloop>
											</select></td>
										<cfelseif FieldName Is "CCCardHolder">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CardHold#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CardHold" maxlength="#FieldSize#"></td>
											</cfoutput>
										<cfelseif FieldName Is "AVSAddress">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.AVSAddr#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="AVSAddr" maxlength="#FieldSize#"></td>
											</cfoutput>
										<cfelseif FieldName Is "AVSZip">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.AVSZip#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="AVSZip" maxlength="#FieldSize#"></td>
											</cfoutput>
										<cfelse>
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#FieldName#" value="" maxlength="#FieldSize#"></td>
											</cfoutput>
										</cfif>
									</tr>
							</cfloop>
						<cfelse>
							<cfset HideRow = 1>
						</cfif>
				<cfelseif BOBFieldName Is "checkdebit">
						<cfquery name="PlanInfo" datasource="#pds#">
							SELECT AWPayCD 
							FROM Plans 
							WHERE PlanID In (#ValueList(SignUpInfo.SelectPlan)#)
						</cfquery>
						<cfif ListFind(#ValueList(PlanInfo.AWPayCD)#,1) GT 0>
								<cfoutput><th bgcolor="#thclr#" colspan="2">Check Debit</th></cfoutput>
							</tr>
							<cfquery name="CDInfo" datasource="#pds#">
								SELECT * 
								FROM PayTypes 
								WHERE UseTab = 1 
								AND ActiveYN = 1 
								ORDER BY SortOrder 
							</cfquery>
							<cfloop query="CDInfo">
								<cfoutput>
									<tr>
										<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
								</cfoutput>
									<cfif FieldName Is "BankName">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckD1#" maxlength="35" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckD1" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelseif FieldName Is "RouteNumber">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckD2#" maxlength="35" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckD2" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelseif FieldName Is "AccntNumber">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckD3#" maxlength="35" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckD3" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelseif FieldName Is "BankAddress">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckD4#" maxlength="35" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckD4" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelseif FieldName Is "NameOnAccnt">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckD5#" maxlength="35" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckD5" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelseif FieldName Is "CheckDigit">
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#SignUpInfo.CheckDigit#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="CheckDigit" size="2" maxlength="#FieldSize#"></td>
											</cfoutput>
									<cfelse>
										<cfset TheValue = Evaluate("SignUpInfo.#FieldName#")>
											<cfoutput>
												<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#TheValue#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#FieldName#" maxlength="#FieldSize#"></td>
											</cfoutput>
									</cfif>
							</cfloop>
						<cfelse>
							<cfset HideRow = 1>
						</cfif>
				<cfelseif BOBFieldName Is "checkcash">
						<cfquery name="PlanInfo" datasource="#pds#">
							SELECT AWPayCk 
							FROM Plans 
							WHERE PlanID In (#ValueList(SignUpInfo.SelectPlan)#)
						</cfquery>
						<cfif ListFind(#ValueList(PlanInfo.AWPayCk)#,1) GT 0>
								<cfoutput><th bgcolor="#thclr#" colspan="2">Check/ Cash</th></cfoutput>
							</tr>
							<cfquery name="CKInfo" datasource="#pds#">
								SELECT * 
								FROM PayTypes 
								WHERE UseTab = 4 
								AND ActiveYN = 1 
								ORDER BY SortOrder 
							</cfquery>
							<cfloop query="CKInfo">
								<cfoutput>
									<tr>
										<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
								</cfoutput>
								<cfset TheValue = Evaluate("SignUpInfo.#FieldName#")>
								<cfoutput>
									<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#TheValue#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#FieldName#" maxlength="#FieldSize#"></td>
								</cfoutput>
							</cfloop>
						<cfelse>
							<cfset HideRow = 1>
						</cfif>
				<cfelseif BOBFieldName Is "porder">
						<cfquery name="PlanInfo" datasource="#pds#">
							SELECT AWPayPO 
							FROM Plans 
							WHERE PlanID In (#ValueList(SignUpInfo.SelectPlan)#)
						</cfquery>
						<cfif ListFind(#ValueList(PlanInfo.AWPayPO)#,1) GT 0>
							<cfoutput><th bgcolor="#thclr#" colspan="2">Purchase Order</th></cfoutput>
							<cfquery name="POInfo" datasource="#pds#">
								SELECT * 
								FROM PayTypes 
								WHERE UseTab = 3 
								AND ActiveYN = 1 
								ORDER BY SortOrder 
							</cfquery>
							<cfloop query="POInfo">
								<cfoutput>
									<tr>
										<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
								</cfoutput>
								<cfset TheValue = Evaluate("SignUpInfo.#FieldName#")>
								<cfoutput>
									<td bgcolor="#tdclr#"><cfif RequiredYN Is 1><b>*</b></cfif><input type="text" value="#TheValue#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#FieldName#" maxlength="#FieldSize#"></td>
								</cfoutput>
							</cfloop>
						<cfelse>
							<cfset HideRow = 1>
						</cfif>
				<cfelseif BOBFieldName Is "postalinv">
					<cfquery name="PostalData" datasource="#pds#">
						SELECT AWChrgPostYN, AWChrgAmount, AWPostOptYN, AWPostOptDef, AWChrgPostRecYN 
						FROM Plans 
						WHERE PlanID In (#SignUpInfo.SelectPlan#)
					</cfquery>
					<cfquery name="GetLocale" datasource="#pds#">
						SELECT Value1 
						FROM Setup 
						WHERE VarName = 'Locale'
					</cfquery>
					<cfset Locale = GetLocale.Value1>
					<cfset OfferPost = ListFind("#ValueList(PostalData.AWPostOptYN)#",1)>
					<cfif OfferPost GT 0>
						<cfset PostChrg = ListFind("#ValueList(PostalData.AWChrgPostYN)#",1)>
						<cfset ChrgAmnt = 0>
						<cfloop query="PostalData">
							<cfset ChrgAmnt = Max(ChrgAmnt,AWChrgAmount)>
						</cfloop>
						<cfset PostDef = ListFind("#ValueList(PostalData.AWPostOptDef)#",1)>
						<cfif PostDef GT 0>
							<cfset PostDef = 1>
						</cfif>
						<cfif SignUpInfo.PostalInv Is Not "2">
							<cfset PostDef = SignUpInfo.PostalInv>
						</cfif>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<td bgcolor="#tdclr#"><cfif InputRequired Is 1>*</cfif><input type="radio" <cfif PostDef Is 1>checked</cfif> name="postalinv" value="1"> Yes <input type="radio" <cfif PostDef Is 0>checked</cfif> name="postalinv" value="0"> No</td>
						</tr>
						<tr valign="top">
							<cfif PostalData.AWChrgPostRecYN Is 1>
								<td colspan="2" bgcolor="#tbclr#">There is a recurring #LSCurrencyFormat(ChrgAmnt)# charge to have your statement mailed.</td>
							<cfelse>
								<td colspan="2" bgcolor="#tbclr#">There is a #LSCurrencyFormat(ChrgAmnt)# charge to have your statement mailed.</td>
							</cfif>
						</cfoutput>
					<cfelse>
						<cfset HideRow = 1>
					</cfif>
				<cfelse>
					<cfoutput>
						<cfif Trim(ScreenPrompt) Is Not "">
							<td align="right" bgcolor="#tbclr#">#ScreenPrompt#</td>
							<cfset TheCol = ColCount - 1>
						<cfelse>
							<cfset TheCol = ColCount>
						</cfif>
						<cfif InputSize Is 998>
							<cfquery name="GetRefs" datasource="#pds#">
								SELECT RefID, Ref
								FROM LU_Refs
							</cfquery>
							<cfset TheValue = Evaluate("SignUpInfo.#BOBFieldName#")>
							<td nowrap bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif>
							<select name="#BOBFieldName#">
							<cfloop query="GetRefs">
								<option value="#RefID#">#Ref#
							</cfloop>
							</select>
						<cfelseif (InputSize LT 999) AND (InputSize GT 0)>
							<cfset TheValue = Evaluate("SignUpInfo.#BOBFieldName#")>
							<td nowrap bgcolor="#tdclr#" colspan="#TheCol#"><nobr><cfif InputRequired Is 1>*</cfif><input type="text" name="#BOBFieldName#" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> size="#InputSize#" value="#TheValue#"></nobr></td>
							<cfif InputRequired Is 1>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfif>
						<cfelseif InputSize Is 0>
							<cfset TheValue = Evaluate("SignUpInfo.#BOBFieldName#")>
							<td nowrap bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><input type="radio" <cfif TheValue Is 1>checked</cfif> name="#BOBFieldName#" value="1"> Yes <input type="radio" <cfif (TheValue Is 0) OR (TheValue Is "")>checked</cfif> name="#BOBFieldName#" value="0"> No</td>
							<cfif InputRequired Is 1>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfif>
						<cfelse>
							<cfset TheValue = Evaluate("SignUpInfo.#BOBFieldName#")>
							<td nowrap bgcolor="#tdclr#" colspan="#TheCol#"><cfif InputRequired Is 1>*</cfif><textarea name="#BOBFieldName#" rows="4" cols="40">#TheValue#</textarea></td>
							<cfif InputRequired Is 1>
								<input type="hidden" name="#BOBFieldName#_required" value="Please enter #ScreenPrompt#">
							</cfif>
						</cfif>
					</cfoutput>
				</cfif>
		</cfloop>
	<cfif HideRow Is 0></tr></cfif>
</cfloop>
 