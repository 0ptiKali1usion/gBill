<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that produces the signup.ini for netsurfer --->
<!---	4.0.0 06/18/99 --->
<!--- netsurfer.cfm --->

<cfif IsDefined("Tab6Submit.x")>
	<cfloop index="B5" list="NetSurferMailDom,NetSurferPop,NetSurferDebug,DebugEmails,DebugSubject">
		<cfset LocValue = Evaluate("#B5#")>
		<cfquery name="UpdateTab6" datasource="#pds#">
			UPDATE NetSurferSetup SET 
			Value1 = '#LocValue#' 
			WHERE NSVarName = '#B5#'
		</cfquery>
	</cfloop>		
</cfif>
<cfif IsDefined("OutputIni")>
	<cfset PathBack = Reverse(OutputDir)>
	<cfset ChckChar = Mid(PathBack,1,1)>
	<cfif ChckChar Is OSType>
		<cfset TheOutDir = OutputDir>
	<cfelse>
		<cfset TheOutDir = OutputDir & OSType>
	</cfif>
	<cfquery name="SaveLastOutput" datasource="#pds#">
		UPDATE NetSurferSetup SET 
		Description = '#TheOutDir#' 
		WHERE NSVarname = 'OutputDir' 
	</cfquery>
	<cffile action="write" file="#TheOutDir#Signup.ini" output="#IniOutput#">
</cfif>
<cfif IsDefined("EditCustom.x")>
	<cfquery name="UpdateCustom" datasource="#pds#">
		UPDATE NetSurferSetup SET 
		NSMemo = '#StripCR(CustomData)#' 
		WHERE NSVarname = 'CustomData' 
		AND UseTab = 4 
	</cfquery>
</cfif>
<cfif IsDefined("SetCardTypes.x")>
	<cfquery name="GetCustomCards" datasource="#pds#">
		SELECT CardType 
		FROM CreditCardTypes 
		WHERE ActiveYN = 1 
		ORDER BY SortOrder, CardType 
	</cfquery>
	<cfset TheCCList = "#ValueList(GetCustomCards.CardType)#">
	<cfset TheCCList = Replace(TheCCList," ","_","All")>
	<cfloop index="B5" list="#TheCCList#">
		<cfif IsDefined("#B5#Use")>
			<cfquery name="Checkfirst" datasource="#pds#">
				SELECT NSVarname 
				FROM NetSurferSetup 
				WHERE UseTab = 3 
				AND NSVarname = '#B5#'
			</cfquery>
			<cfif Checkfirst.recordcount Is 0>
				<cfset TheDesc = Evaluate("#B5#Desc")>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO NetSurferSetup 
					(NSVarname, UseTab, Value1, Description) 
					VALUES
					('#B5#', 3, '1', <cfif Trim(TheDesc) Is "">Null<cfelse>'#Trim(TheDesc)#'</cfif>)
				</cfquery>
			<cfelse>
				<cfset TheDesc = Evaluate("#B5#Desc")>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE NetSurferSetup SET 
					Description = <cfif Trim(TheDesc) Is "">Null<cfelse>'#Trim(TheDesc)#'</cfif> 
					WHERE NSVarname = '#B5#'
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM NetSurferSetup 
				WHERE NSVarname = '#B5#'
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("mvrt") AND IsDefined("HaveNots")>
	<cfloop index="B5" list="#HaveNots#">
		<cfset TheID = ListGetAt("#B5#",1,"|")>
		<cfset TheDesc = ListGetAt("#B5#",2,"|")>
		<cfif TheID gt 0>
			<cfquery name="AddPlan" datasource="#pds#">
				INSERT INTO NetSurferSetup 
				(NSVarname, Value1, Description, UseTab)
				VALUES 
				('PlanID#TheID#','#TheID#','#TheDesc#',2)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("mvlt") AND IsDefined("Haves")>
	<cfloop index="B5" list="#Haves#">
		<cfif B5 gt 0>
			<cfquery name="RemovePlan" datasource="#pds#">
				DELETE FROM NetSurferSetup 
				WHERE Value1 = '#B5#' 
				AND UseTab = 2
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("updvalues.x")>
	<cfloop index="B5" list="#FIELDNAMES#">
		<cfset TheValue = Evaluate("#B5#")>
		<cfif B5 Is "Password">
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT NSVarName 
				FROM NetSurferSetup 
				WHERE NSVarName = 'UnencryptedPassword'
			</cfquery>
			<cfif CheckFirst.RecordCount Is 0>
				<cfquery name="InsData" datasource="#pds#">
					INSERT INTO NetSurferSetup 
					(NSVarname,Value1,Description,ActiveYN,UseTab) 
					VALUES ('UnencryptedPassword','#TheValue#','Password',1,0)
				</cfquery>
			<cfelse>
				<cfquery name="InsData" datasource="#pds#">
					UPDATE NetSurferSetup SET 
					Value1 = '#TheValue#' 
					WHERE NSVarName = 'UnencryptedPassword'
				</cfquery>
			</cfif>
			<cfquery name="getpath" datasource="#pds#">
				SELECT Value1 
				FROM NetSurferSetup 
				WHERE NSVarname = 'PasswordPathway'
			</cfquery>
			<cfset PathBack = reverse(getpath.value1)>
			<cfset SlashCheck = Left(PathBack,1)>
			<cfif SlashCheck Is OSType>
				<cfset TheFilePath = getpath.value1>
			<cfelse>
				<cfset TheFilePath = getpath.value1 & OSType>
			</cfif>
			<cfif FileExists("#TheFilePath#mkpasswd.exe")>
				<cffile action="WRITE" file="#TheFilePath#EPassw.bat"  
				 output="#TheFilePath#mkpasswd.exe #TheValue# > #TheFilePath#EncryptPass.txt">
				<cfx_spawnexec file="#TheFilePath#EPassw.bat" mode="WAIT">
				<cffile action="read" file="#TheFilePath#EncryptPass.txt" variable="FileOut">
				<cfset Pos1 = Find(":","#FileOut#") + 1>
				<cfset Len1 = Len(FileOut) - Pos1>
				<cfset EPass = Mid(FileOut,Pos1,Len1)>
				<cfset TheValue = Trim(EPass)>
				<cffile action="DELETE" file="#TheFilePath#EPassw.bat">
				<cffile action="DELETE" file="#TheFilePath#EncryptPass.txt">
			</cfif>
		</cfif>
		<cfquery name="UpdateInfo" datasource="#pds#">
			UPDATE NetSurferSetup SET 
			Value1 = <cfif Trim(TheValue) Is "">Null<cfelse>'#TheValue#'</cfif> 
			WHERE NSVarName = '#B5#'
		</cfquery>
	</cfloop>
</cfif>
<cfparam name="tab" default="2">
<cfif Tab Is 1>
	<cfparam name="HowWide" default="3">
	<cfquery name="Sections" datasource="#pds#">
		SELECT * 
		FROM NetSurferSetup 
		WHERE UseTab = 1 
		ORDER BY SortOrder, Section 
	</cfquery>
	<cfquery name="NSPlans" datasource="#pds#">
		SELECT Value1 
		FROM NetSurferSetup 
		WHERE UseTab = 2
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		SELECT PlanDesc 
		FROM Plans 
		WHERE PlanID Not In (#deactaccount#,#delaccount#) 
		<cfif NSPlans.recordcount GT 0>
			AND PlanID In (#ValueList(NSPlans.Value1)#)
		</cfif>
		ORDER BY PlanDesc
	</cfquery>
	<cfquery name="DefPlan" datasource="#pds#">
		SELECT Value1 
		FROM NetSurferSetup 
		WHERE NSVarName = 'DefaultServicePlan'
	</cfquery>
	<cfset DefNSPlan = DefPlan.Value1>
	<cfset selectoptions = "">
	<cfoutput query="AllPlans">
		<cfif PlanDesc Is DefNSPlan>
			<cfset selectoptions = selectoptions & "<option selected value=""#PlanDesc#"">#PlanDesc#">
		<cfelse>
			<cfset selectoptions = selectoptions & "<option value=""#PlanDesc#"">#PlanDesc#">
		</cfif>
	</cfoutput>
	<cfquery name="GetUnencPwd" datasource="#pds#">
		SELECT Value1 
		FROM NetSurferSetup
		WHERE NSVarName = 'UnencryptedPassword'
	</cfquery>
	<cfquery name="DefPayment" datasource="#pds#">
		SELECT Value1 
		FROM NetSurferSetup 
		WHERE NSVarName = 'DefaultPaymentPlan'
	</cfquery>
	<cfquery name="GetCustomCards" datasource="#pds#">
		SELECT CardType, ActiveYN 
		FROM CreditCardTypes 
		ORDER BY SortOrder, CardType 
	</cfquery>
	<cfloop query="GetCustomCards">
		<cfset "#Replace(CardType," ","_","All")#" = "#ActiveYN#">
	</cfloop>
	<cfquery name="GetCards" datasource="#pds#">
		SELECT Value1, NSVarname, Description 
		FROM NetSurferSetup 
		WHERE UseTab = 3 
		ORDER BY NSVarName 
	</cfquery>
	<cfset CardLoop = "">
	<cfloop query="GetCards">
		<cfset CardLoop = CardLoop & "<option">
		<cfif DefPayment.Value1 Is NSVarName>
			<cfset CardLoop = CardLoop & " selected">
		</cfif>
		<cfset CardLoop = CardLoop & " value=""#Replace(NSVarName,"_"," ","All")#"">#Replace(NSVarName,"_"," ","All")#
">
	</cfloop>	
	<cfloop query="GetCards">
		<cfset "#NSVarname#Use" = GetCards.Value1>
		<cfset "#NSVarname#Desc" = GetCards.Description>
	</cfloop>
<cfelseif Tab Is 2>
	<cfparam name="HowWide" default="3">
	<cfquery name="HavePlans" datasource="#pds#">
		SELECT Value1, Description 
		FROM NetSurferSetup 
		WHERE UseTab = 2
	</cfquery>
	<cfquery name="AvailPlans" datasource="#pds#">
		SELECT PlanDesc, PlanID 
		FROM Plans 
		WHERE PlanID Not In (#deactaccount#,#delaccount#) 
		<cfif HavePlans.RecordCount gt 0>
			AND PlanID Not In (#ValueList(HavePlans.Value1)#)
		</cfif>
		ORDER BY PlanDesc
	</cfquery>
<cfelseif Tab Is 3>
	<cfparam name="HowWide" default="3">
	<cfquery name="GetCustomCards" datasource="#pds#">
		SELECT CardType, ActiveYN 
		FROM CreditCardTypes 
		ORDER BY SortOrder, CardType 
	</cfquery>
	<cfoutput query="GetCustomCards">
		<cfset "#Replace(CardType," ","_","All")#" = "#ActiveYN#">
	</cfoutput>
	<cfquery name="OldCards" datasource="#pds#">
		DELETE 
		FROM NetSurferSetup 
		WHERE UseTab = 3 
		<cfloop query="GetCustomCards">
			AND NSVarName <> '#Replace(CardType," ","_","All")#'
		</cfloop>
	</cfquery>
	<cfquery name="GetCards" datasource="#pds#">
		SELECT Value1, NSVarname, Description 
		FROM NetSurferSetup 
		WHERE UseTab = 3
	</cfquery>
	<cfoutput query="GetCards">
		<cfset "#NSVarname#Use" = GetCards.Value1>
		<cfset "#NSVarname#Desc" = GetCards.Description>
	</cfoutput>
<cfelseif Tab Is 4>
	<cfparam name="HowWide" default="1">
	<cfquery name="CustomDataArea" datasource="#pds#">
		SELECT * 
		FROM NetSurferSetup 
		WHERE UseTab = 4 
		AND NSVarname = 'CustomData'
	</cfquery>
	<cfif CustomDataArea.recordcount Is 0>
		<cfquery name="adddata" datasource="#pds#">
			INSERT INTO NetSurferSetup 
			(NSVarname, UseTab, NSMemo, Description, ActiveYN) 
			VALUES 
			('CustomData', 4, '[Custom Screen 1]
Heading=Miscellaneous Information
Instructions=Please enter the following information:
Field1=Password
Prompt1=Password
MinLength1=0
MaxLength1=20

Field2=Extrafield1
Prompt2=#extrainfo1#
MinLength1=0
MaxLength1=50

Field3=Extrafield2
Prompt3=#extrainfo2#
MinLength1=0
MaxLength1=50

Field4=Extrafield3
Prompt4=#extrainfo3#
MinLength1=0
MaxLength1=50
', 'Custom screens for Netsurfer signup', 0)
		</cfquery>
		<cfquery name="CustomDataArea" datasource="#pds#">
			SELECT * 
			FROM NetSurferSetup 
			WHERE UseTab = 4 
			AND NSVarname = 'CustomData'
		</cfquery>
	</cfif>
<cfelseif tab is 5>
	<cfparam name="HowWide" default="1">
	<cfquery name="OutputDir" datasource="#pds#">
		SELECT Description 
		FROM NetSurferSetup 
		WHERE UseTab = 5 
		AND NSVarname = 'OutputDir'
	</cfquery>
	<cfif OutputDir.recordcount Is 0>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO NetSurferSetup 
			(NSVarname, UseTab, Description) 
			VALUES 
			('OutputDir', 5, '#BillPath#')
		</cfquery>
		<cfquery name="OutputDir" datasource="#pds#">
			SELECT Description 
			FROM NetSurferSetup 
			WHERE UseTab = 5 
			AND NSVarname = 'OutputDir'
		</cfquery>
	</cfif>
	<cfquery name="Tab1" datasource="#pds#">
		SELECT * 
		FROM NetSurferSetup 
		WHERE UseTab = 1 
		AND SortOrder > 0 
		ORDER BY SortOrder, Section 
	</cfquery>
	<cfset inioutput = "">
	<cfset sectioncount = 1>
	<cfoutput query="Tab1" group="Section">
		<cfif sectioncount Is 0>
			<cfset inioutput = inioutput & "
">
		</cfif>
		<cfset inioutput = inioutput & "[#Section#]
">
		<cfset sectioncount = 0>
		<cfoutput>
			<cfset inioutput = inioutput & "#NSVarname#=#Value1#
">
		</cfoutput>
	</cfoutput>
	<cfquery name="AllThePlans" datasource="#pds#">
		SELECT Value1 
		FROM NetSUrferSetup 
		WHERE UseTab = 2
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		SELECT PlanDesc, RecurringAmount, fixedamount
		FROM Plans 
		WHERE PlanID In (#ValueList(AllThePlans.Value1)#)
	</cfquery>
	<cfset inioutput = inioutput & "
">
	<cfset counterplan = 1>
	<cfoutput query="AllPlans">
		<cfset inioutput = inioutput & "[Service Plan #counterplan#]
Description=#PlanDesc#
SetupFee=#Trim(LSNumberFormat(fixedamount, '999999999999.99'))#
Price=#Trim(LSNumberFormat(recurringamount, '999999999999.99'))#
Details=

">
		<cfset counterplan = counterplan + 1>
	</cfoutput>
	<cfquery name="AllPays" datasource="#pds#">
		SELECT * 
		FROM NetSurferSetup 
		WHERE UseTab = 3
	</cfquery>
	<cfset countercard = 1>
	<cfoutput query="AllPays">
		<cfset inioutput = inioutput & "[Payment Plan #countercard#]
Description=#Replace(NSVarname, "_", " ","All")#
Type=Credit Card
Details=#Description#

">
		<cfset countercard = countercard + 1>
	</cfoutput>
	<cfquery name="CustomData" datasource="#pds#">
		SELECT NSMemo 
		FROM NetSurferSetup 
		WHERE UseTab = 4 
		AND NSVarname = 'CustomData'
	</cfquery>
	<cfset inioutput = inioutput & "#CustomData.NSMemo#

">
<cfelseif tab Is 6>
	<cfparam name="HowWide" default="2">
	<cfquery name="tab6" datasource="#pds#">
		SELECT * 
		FROM NetSurferSetup 
		WHERE UseTab = 6 
		ORDER BY SortOrder
	</cfquery>	
	<cfquery name="AllDomains" datasource="#pds#">
		SELECT DomainName 
		FROM Domains 
		WHERE ShowYN = 1 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="AllPOPs" datasource="#pds#">
		SELECT POPName 
		FROM POPs 
		WHERE showyn = 1 
		ORDER BY POPName
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Netsurfer Setup</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Netsurfer Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr bgcolor="#ttNTab#">
					<form method="post" action="netsurfer.cfm">
						<td <cfif tab Is 2>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Plans</label></td>
						<td <cfif tab Is 3>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Payment</label></td>
						<td <cfif tab Is 1>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Sections</label></td>
						<td <cfif tab Is 4>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Custom Fields</label></td>
						<td <cfif tab Is 6>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 6>checked</cfif> name="tab" value="6" onclick="submit()" id="tab6"><label for="tab6">Setup Values</label></td>
						<td <cfif tab Is 5>bgcolor="#ttSTab#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">Preview</label></td>
					</form>
				</tr>
			</table>		
		</th>
	</tr>
</cfoutput>	
<cfif tab is 1>
	<cfoutput>
	<tr bgcolor="#thclr#"></cfoutput>
		<th>Name</th>
		<th>Value</th>
		<th>Description</th>
	</tr>
	<form method="post" action="netsurfer.cfm">
		<input type="hidden" name="tab" value="1">
		<cfoutput query="Sections" group="Section">
			<tr>
				<th bgcolor="#thclr#" colspan="3"><b>[#Section#]</b></th>
			</tr>
			<cfoutput>
				<tr>
					<td bgcolor="#tbclr#">#NSVarname#</td>
					<cfif NSVarname Is "DefaultServicePlan">
						<td bgcolor="#tdclr#"><select name="#NSVarName#">
						#selectoptions#
						</select>
						</td>
					<cfelseif NSVarName Is "DefaultPaymentPlan">
						<td bgcolor="#tdclr#"><select name="DefaultPaymentPlan">
							#CardLoop#
							<cfif GetCards.Recordcount Is 0><option value="0">No Cards are selected</cfif>
						</select></td>
					<cfelseif NSVarname Is "Password">
						<td bgcolor="#tdclr#"><input type="password" name="#NSVarName#" value="#GetUnencPwd.Value1#"></td>					
					<cfelse>
						<td bgcolor="#tdclr#"><input type="text" name="#NSVarName#" value="#Value1#"></td>
					</cfif>
					<td bgcolor="#tbclr#">#Description#</td>
				</tr>
			</cfoutput>
		</cfoutput>
		<tr>
			<th colspan="3"><input type="image" name="updvalues" src="images/update.gif" border="0"></th>
		</tr>
	</form>
</table>

<cfelseif tab Is 2>
	<cfoutput>
	<form method="post" action="netsurfer.cfm">
		<input type="hidden" name="tab" value="2">
			<tr bgcolor="#thclr#"></cfoutput>
				<th>Available To Add</th>
				<th>Action</th>
				<th>Available To Netsurfer Signups</th>
			</tr>
			<cfoutput><tr valign="top" bgcolor="#tdclr#"></cfoutput>
				<td><select size="10" multiple name="HaveNots">
					<cfoutput query="AvailPlans">
						<option value="#PlanID#|#PlanDesc#">#PlanDesc#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td valign="middle" align="center">
				<input type="submit" name="mvrt" value="---->"><br>
				<input type="submit" name="mvlt" value="<----"><br>
				</td>
				<td><select size="10" multiple name="Haves">
					<cfoutput query="HavePlans">
						<option value="#Value1#">#Description#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>
		</table>
	</form>
<cfelseif Tab Is 3>
	<cfoutput>
	<form method="post" action="netsurfer.cfm">
		<input type="hidden" name="tab" value="3">
			<tr bgcolor="#thclr#">
				<th>Use</th>
				<th>Card</th>
				<th>Description</th>
			</tr>
			<cfloop query="GetCustomCards">
				<cfif ActiveYN Is 1>
					<tr bgcolor="#tbclr#">
						<td><input <cfif IsDefined("#Replace(CardType," ","_","All")#Use")>checked</cfif> type="checkbox" name="#Replace(CardType," ","_","All")#Use" value="1"></td>
						<td>#CardType#</td>
						<td><input value=<cfif IsDefined("#Replace(CardType," ","_","All")#Desc") AND IsDefined("#Replace(CardType," ","_","All")#Use")><cfset DispDesc = Evaluate("#Replace(CardType," ","_","All")#Desc")>"#DispDesc#"
						<cfelse>"Charges will appear on your #CardType# credit card bill as Company Name."
						</cfif> type="text" name="#Replace(CardType," ","_","All")#Desc" size="35"></td>
					</tr>
				</cfif>
			</cfloop>
			<tr>
				<th colspan="3"><input type="image" name="SetCardTypes" src="images/update.gif" border="0"></th>
			</tr>
		</table>
	</form>
	</cfoutput>
<cfelseif tab Is 4>
	<cfoutput>
	<form method="post" action="netsurfer.cfm">
		<input type="hidden" name="tab" value="4">
			<tr>
				<td bgcolor="#thclr#">#CustomDataArea.Description#</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#"><textarea name="CustomData" rows="15" cols="70">#CustomDataArea.NSMemo#</textarea></td>
			</tr>
			<tr>
				<td align="center"><input type="image" src="images/update.gif" name="EditCustom" border="0"></td>
			</tr>
		</table>
	</form>
	</cfoutput>
<cfelseif tab Is 5>
	<cfoutput>
			<form method="post" action="netsurfer.cfm">
				<input type="hidden" name="tab" value="5">
				<input type="hidden" name="IniOutput" value="#inioutput#">
				<tr>
					<td bgcolor="#thclr#"><input type="submit" name="OutputIni" value="Output Signup.Ini"> to <input value="#OutputDir.Description#" type="text" name="OutputDir" size="35"></td>
				</tr> 
			</form>
			<tr>
				<td bgcolor="#tbclr#"><pre>#inioutput#</pre></td>
			</tr>
		</table>	
	</cfoutput>
<cfelseif tab Is 6>
			<form method="post" action="netsurfer.cfm">
				<input type="hidden" name="tab" value="6">
				<cfloop query="tab6">
					<cfoutput><tr bgcolor="#tdclr#"></cfoutput>
						<cfif NsVarName Is "NetSurferMailDom">
							<cfoutput><td bgcolor="#tbclr#">Default Domain</td></cfoutput>
							<cfset DefDom = Value1>
							<td><select name="NetSurferMailDom">
								<cfoutput query="AllDomains">
									<option <cfif DefDom Is DomainName>selected</cfif> value="#DomainName#">#DomainName#
								</cfoutput>
							</select></td>
						<cfelseif NSVarName Is "NetSurferPop">
							<cfoutput><td bgcolor="#tbclr#">Default POP</td></cfoutput>
							<cfset DefPOP = Value1>
							<td><select name="NetSurferPop">
								<cfoutput query="AllPOPs">
									<option <cfif DefPOP Is POPName>selected</cfif> value="#POPName#">#POPName#
								</cfoutput>
							</select></td>
						<cfelseif NSVarName Is "NetSurferDebug">
							<cfoutput><td bgcolor="#tbclr#">Send Debugging EMail</td></cfoutput>
							<td><input <cfif Value1 Is "1">checked</cfif> type="radio" name="NetSurferDebug" value="1"> Yes <input <cfif Value1 Is "0">checked</cfif> type="radio" name="NetSurferDebug" value="0"> No</td>
						<cfelseif NSVarName Is "DebugEmails">
							<cfoutput><td bgcolor="#tbclr#">Address for Debugging EMail</td>
							<td><input type="text" name="DebugEmails" value="#Value1#" size="35"></td></cfoutput>
						<cfelseif NSVarName Is "DebugSubject">
							<cfoutput><td bgcolor="#tbclr#">Subject for Debugging EMail</td>
							<td><input type="text" name="DebugSubject" value="#Value1#" size="35"></td></cfoutput>
						</cfif>					
					</tr>				
				</cfloop>
				<tr>
					<th colspan="2"><input type="image" src="images/update.gif" name="Tab6Submit" border="0""></th>
				</tr>
			</form>
		</table>
</cfif>


</center>
<cfinclude template="footer.cfm">
</body>
</html>
 