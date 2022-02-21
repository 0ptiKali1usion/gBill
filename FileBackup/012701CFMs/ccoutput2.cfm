<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page outputs the batch debit file for credit cards. --->
<!--- 4.0.0 09/20/99
		3.2.0 09/08/98 --->
<!--- ccoutpu2.cfm --->

<cfif IsDefined("CreateFiles.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT TempID 
		FROM TempValues 
		WHERE VariableName = 'SelectedIDs' 
		AND AdminID = #MyAdminID# 
		AND ReportID = 19
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="SaveSetting" datasource="#pds#">
			INSERT INTO TempValues 
			(VariableName, VariableValue, AdminID, ReportID)
			VALUES 
			('SelectedIDs','#SelectedIDs#', #MyAdminID#, 19)
		</cfquery>
	<cfelse>
		<cfquery name="UpdSettings" datasource="#pds#">
			UPDATE TempValues SET 
			VariableValue = '#SelectedIDs#' 
			WHERE VariableName = 'SelectedIDs' 
			AND AdminID = #MyAdminID# 
			AND ReportID = 19
		</cfquery>
	</cfif>
</cfif>
<cfparam name="JumpSecs" default="5">
<cfquery name="GetCCDefs" datasource="#pds#">
	SELECT * 
	FROM CustomCCOutput
	WHERE UseTab = 0 
</cfquery>
<cfloop query="GetCCDefs">
	<cfparam name="#FieldName1#" default="#Description1#">
</cfloop>
<cfparam name="CCDelimit" default=",">
<cfparam name="CCNumfield" default="15">
<cfparam name="CCEnclose" default="0">
<cfparam name="CCHrout" default="">
<cfparam name="CCOutputheadrow" default="0">
<cfparam name="CCDateformat" default="DD-MM-YYYY">
<cfparam name="CCTimeformat" default="hh:mm:ss">
<cfparam name="CCAmountformat" default="">
<cfparam name="CCEncloseNull" default="1">
<CFPARAM name="CCAmountPeriod" default="1">
<cfif CCDelimit is "pipe">
	<cfset CCDelimit = "|">
<cfelseif CCDelimit Is "sp">
	<cfset CCDelimit = " ">
<cfelseif CCDelimit Is "tb">
	<cfset CCDelimit = "	">
</cfif>
<cfquery name="GetBatchIDs" datasource="#pds#">
	SELECT VariableValue 
	FROM TempValues 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 19 
	AND VariableName = 'SelectedIDs'
</cfquery>
<cfset SelectedBatchIDs = GetBatchIDs.VariableValue>
<cfquery name="GetIds" datasource="#pds#">
	SELECT D.BatchDetailID 
	FROM CCBatchDetail D, CCBatchHist H 
	WHERE D.BatchID = H.BatchID 
	AND D.BatchOutput Is Null 
	AND H.BatchID In (#SelectedBatchIDs#) 
	<cfif GetOpts.CCViewAll Is 0>
		AND H.AdminIDExport = #MyAdminID#
	</cfif>
</cfquery>
<cfif GetIds.Recordcount GT 0>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfif IsDefined("CreateFiles.x")>
		<cfquery name="GetFileNames" datasource="#pds#">
			SELECT OutputFileAs, OutputFilePath 
			FROM CCBatchHist 
			WHERE BatchID In 
				(SELECT H.BatchID 
				 FROM CCBatchDetail D, CCBatchHist H 
				 WHERE D.BatchID = H.BatchID 
				 AND D.BatchOutput Is Null 
				 AND H.BatchID In (#SelectedBatchIDs#) 
				 <cfif GetOpts.CCViewAll Is 0>
				 	AND H.AdminIDExport = #MyAdminID#
				 </cfif>
				 )
		</cfquery>
		<cfif CCOutputHeadRow Is "1">
			<cfset StartFileOutput = CCHrOut>
		<cfelse>
			<cfset StartFileOutput = "">
		</cfif>
		<cfloop query="GetFileNames">
			<cffile action="WRITE" file="#OutputFilePath##OutputFileAs#" output="#StartFileOutput#">
		</cfloop>
	</cfif>
	<cfset MaxRow = Mrow * 4>
	<cfquery name="GetOutputStr" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput
		WHERE UseTab = 1 
		AND UseYN = 1 
		ORDER BY SortOrder
	</cfquery>
	<cfloop query="GetOutputStr">
		<cfset "FieldOut#SortOrder#" = Description1>
		<cfset "FieldName#SortOrder#" = FieldName1>
	</cfloop>
	<cfquery name="GetOutputRef" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput
		WHERE UseTab = 2 
		AND UseYN = 1 
		ORDER BY SortOrder
	</cfquery>
	<cfloop query="GetOutputRef">
		<cfset "FieldRef#SortOrder#" = Description1>
		<cfset "FieldNRef#SortOrder#" = FieldName1>
	</cfloop>
	<cfquery name="ProcessWho" datasource="#pds#" maxrows="#Maxrow#">
		SELECT D.*, H.OutputFileAs, H.OutputFilePath 
		FROM CCBatchDetail D, CCBatchHist H 
		WHERE D.BatchID = H.BatchID 
		AND D.BatchOutput Is Null 
		<cfif GetOpts.CCViewAll Is 0>
			AND H.AdminIDExport = #MyAdminID#
		</cfif>
	</cfquery>
	<cfloop query="ProcessWho">
		<cfset BuildString = "">
		<cfif CCYearFormat Is "yy">
			<cfset LoopYear = Mid(CCYear,3,2)>
		<cfelse>
			<cfset LoopYear = CCYear>
		</cfif>
		<cfif BatchAmount GT 0>
			<cfloop index="B5" from="1" to="#CCNumField#">
				<cfif IsDefined("FieldName#B5#")>
					<cfset ThisLoop = Evaluate("FieldOut#B5#")>
					<cfset ThisField = Evaluate("FieldName#B5#")>
					<cfif ThisField Contains "##Date##">
						<cfset ThisLoop = ReplaceNoCase(ThisLoop,"##Date##","#LSDateFormat(Now(), '#CCDateFormat#')#")>
					</cfif>
					<cfif ThisField Contains "##Time##">
						<cfset ThisLoop = ReplaceNoCase(ThisLoop,"##Time##","#LSTimeFormat(Now(), '#CCTimeFormat#')#")>
					</cfif>
					<cfif CCEnclose Is "1">
						<cfif (Trim(ThisLoop) Is "") AND (CCEncloseNull Is 0)>
							<cfset ThisLoop = "">
						<cfelse>
							<cfset ThisLoop = """#ThisLoop#""">
						</cfif>
					</cfif>
					<cfif ThisField Is "cctype">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCType) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCType#">
							<cfelse>
								<cfset ThisLoop = """#CCType#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCType#">
						</cfif>
					<cfelseif ThisField Is "ccnum">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCNumber) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCNumber#">
							<cfelse>
								<cfset ThisLoop = """#CCNumber#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCNumber#">
						</cfif>
					<cfelseif ThisField Is "LastName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LastName) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LastName#">
							<cfelse>
								<cfset ThisLoop = """#LastName#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LastName#">
						</cfif>
					<cfelseif ThisField Is "FirstName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(FirstName) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#FirstName#">
							<cfelse>
								<cfset ThisLoop = """#FirstName#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#FirstName#">
						</cfif>
					<cfelseif ThisField Is "CompName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(Company) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#Company#">
							<cfelse>
								<cfset ThisLoop = """#Company#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#Company#">
						</cfif>
					<cfelseif ThisField Is "AVSZip">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AVSZip) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AVSZip#">
							<cfelse>
								<cfset ThisLoop = """#AVSZip#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AVSZip#">
						</cfif>
					<cfelseif ThisField Is "AVSAddr">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AVSAddress) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AVSAddress#">
							<cfelse>
								<cfset ThisLoop = """#AVSAddress#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AVSAddress#">
						</cfif>
					<cfelseif ThisField Is "CCYearCCMon">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCMonth) Is "") AND (Trim(LoopYear) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LoopYear##CCMonth#">
							<cfelse>
								<cfset ThisLoop = """#LoopYear##CCMonth#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LoopYear##CCMonth#">
						</cfif>
					<cfelseif ThisField Is "CCMon">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCMonth) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCMonth#">
							<cfelse>
								<cfset ThisLoop = """#CMonth#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCMonth#">
						</cfif>
					<cfelseif ThisField Is "CCYear">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LoopYear) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LoopYear#">
							<cfelse>
								<cfset ThisLoop = """#LoopYear#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LoopYear#">
						</cfif>
					<cfelseif ThisField Is "CCMonCCYear">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LoopYear) Is "") AND (Trim(CCMonth) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCMonth##LoopYear#">
							<cfelse>
								<cfset ThisLoop = """#CCMonth##LoopYear#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCMonth##LoopYear#">
						</cfif>
					<cfelseif ThisField Is "CardHold">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCCardHolder) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCCardHolder#">
							<cfelse>
								<cfset ThisLoop = """#CCCardHolder#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCCardHolder#">
						</cfif>
					<cfelseif ThisField Is "Bal">
						<cfif CCEnclose Is "1">
							<cfset DollarFormatAmount = "#CCAmountFormat##Trim(LSNumberFormat(BatchAmount, '99999999.99'))#">
							<cfif CCAmountPeriod Is 0>
								<cfset DollarFormatAmount = Replace(DollarFormatAmount,".","")>
							</cfif>
							<cfif (Trim(DollarFormatAmount) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#DollarFormatAmount#">
							<cfelse>
								<cfset ThisLoop = """#DollarFormatAmount#""">
							</cfif>
						<cfelse>
							<cfset DollarFormatAmount = "#CCAmountFormat##Trim(LSNumberFormat(BatchAmount, '99999999.99'))#">
							<cfif CCAmountPeriod Is 0>
								<cfset DollarFormatAmount = Replace(DollarFormatAmount,".","")>
							</cfif>
							<cfset ThisLoop = "#DollarFormatAmount#">
						</cfif>
					<cfelseif ThisField Is "AccountID">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AccountID) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AccountID#">
							<cfelse>
								<cfset ThisLoop = """#AccountID#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AccountID#">
						</cfif>
					</cfif>
				<cfelse>
					<cfif CCEnclose Is "1">
						<cfif CCEncloseNull Is 0>
							<cfset ThisLoop = "">
						<cfelse>
							<cfset ThisLoop = """""">
						</cfif>
					<cfelse>
						<cfset ThisLoop = "">
					</cfif>
				</cfif>
				<cfset ThisLoop = Trim(ThisLoop)>
				<cfset BuildString = ListAppend(BuildString,"#ThisLoop#","#CCDelimit#")>
			</cfloop>
		<cfelseif BatchRefund GT 0>
			<cfloop index="B5" from="1" to="#CCNumField#">
				<cfif IsDefined("FieldNRef#B5#")>
					<cfset ThisLoop = Evaluate("FieldRef#B5#")>
					<cfset ThisField = Evaluate("FieldNRef#B5#")>
					<cfif ThisField Contains "##Date##">
						<cfset ThisLoop = ReplaceNoCase(ThisLoop,"##Date##","#LSDateFormat(Now(), '#CCDateFormat#')#")>
					</cfif>
					<cfif ThisField Contains "##Time##">
						<cfset ThisLoop = ReplaceNoCase(ThisLoop,"##Time##","#LSTimeFormat(Now(), '#CCTimeFormat#')#")>
					</cfif>
					<cfif CCEnclose Is "1">
						<cfif (Trim(ThisLoop) Is "") AND (CCEncloseNull Is 0)>
							<cfset ThisLoop = "#ThisLoop#">
						<cfelse>
							<cfset ThisLoop = """#ThisLoop#""">
						</cfif>
					</cfif>
					<cfif ThisField Is "cctype">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCType) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCType#">
							<cfelse>
								<cfset ThisLoop = """#CCType#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCType#">
						</cfif>
					<cfelseif ThisField Is "ccnum">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCNumber) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCNumber#">
							<cfelse>
								<cfset ThisLoop = """#CCNumber#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCNumber#">
						</cfif>
					<cfelseif ThisField Is "LastName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LastName) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LastName#">
							<cfelse>
								<cfset ThisLoop = """#LastName#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LastName#">
						</cfif>
					<cfelseif ThisField Is "FirstName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(FirstName) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#FirstName#">
							<cfelse>
								<cfset ThisLoop = """#FirstName#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#FirstName#">
						</cfif>
					<cfelseif ThisField Is "CompName">
						<cfif CCEnclose Is "1">
							<cfif (Trim(Company) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#Company#">
							<cfelse>
								<cfset ThisLoop = """#Company#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#Company#">
						</cfif>
					<cfelseif ThisField Is "AVSZip">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AVSZip) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AVSZip#">
							<cfelse>
								<cfset ThisLoop = """#AVSZip#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AVSZip#">
						</cfif>
					<cfelseif ThisField Is "AVSAddr">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AVSAddress) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AVSAddress#">
							<cfelse>
								<cfset ThisLoop = """#AVSAddress#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AVSAddress#">
						</cfif>
					<cfelseif ThisField Is "CCYearCCMon">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCMonth) Is "") AND (Trim(LoopYear) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LoopYear##CCMonth#">
							<cfelse>
								<cfset ThisLoop = """#LoopYear##CCMonth#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LoopYear##CCMonth#">
						</cfif>
					<cfelseif ThisField Is "CCMon">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCMonth) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCMonth#">
							<cfelse>
								<cfset ThisLoop = """#CCMonth#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCMonth#">
						</cfif>
					<cfelseif ThisField Is "CCYear">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LoopYear) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#LoopYear#">
							<cfelse>
								<cfset ThisLoop = """#LoopYear#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#LoopYear#">
						</cfif>
					<cfelseif ThisField Is "CCMonCCYear">
						<cfif CCEnclose Is "1">
							<cfif (Trim(LoopYear) Is "") AND (Trim(CCMonth) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCMonth##LoopYear#">
							<cfelse>
								<cfset ThisLoop = """#CCMonth##LoopYear#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCMonth##LoopYear#">
						</cfif>
					<cfelseif ThisField Is "CardHold">
						<cfif CCEnclose Is "1">
							<cfif (Trim(CCCardHolder) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#CCCardHolder#">
							<cfelse>
								<cfset ThisLoop = """#CCCardHolder#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#CCCardHolder#">
						</cfif>
					<cfelseif ThisField Is "Bal">
						<cfif CCEnclose Is "1">
							<cfif (Trim(BatchRefund) Is "") AND (CCEncloseNull Is 0)>
								<cfset DollarFormatAmount = "#CCAmountFormat##Trim(LSNumberFormat(BatchRefund, '99999999.99'))#">
							<cfelse>
								<cfset DollarFormatAmount = """#CCAmountFormat##Trim(LSNumberFormat(BatchRefund, '99999999.99'))#""">
							</cfif>
						<cfelse>
							<cfset DollarFormatAmount = "#CCAmountFormat##Trim(LSNumberFormat(BatchRefund, '99999999.99'))#">
						</cfif>
						<cfif CCAmountPeriod Is 0>
							<cfset DollarFormatAmount = Replace(DollarFormatAmount,".","")>
						</cfif>
						<cfset ThisLoop = "#DollarFormatAmount#">
					<cfelseif ThisField Is "AccountID">
						<cfif CCEnclose Is "1">
							<cfif (Trim(AccountID) Is "") AND (CCEncloseNull Is 0)>
								<cfset ThisLoop = "#AccountID#">
							<cfelse>
								<cfset ThisLoop = """#AccountID#""">
							</cfif>
						<cfelse>
							<cfset ThisLoop = "#AccountID#">
						</cfif>
					</cfif>
				<cfelse>
					<cfif CCEnclose Is "1">
						<cfif CCEncloseNull Is 0>
							<cfset ThisLoop = "">
						<cfelse>
							<cfset ThisLoop = """""">
						</cfif>
					<cfelse>
						<cfset ThisLoop = "">
					</cfif>
				</cfif>
				<cfset ThisLoop = Trim(ThisLoop)>
				<cfset BuildString = ListAppend(BuildString,"#ThisLoop#","#CCDelimit#")>
			</cfloop>
		</cfif>
		<cftransaction>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE CCBatchDetail SET 
				BatchOutput = '#BuildString#' 
				WHERE BatchDetailID = #BatchDetailID# 
			</cfquery>
			<cffile action="APPEND" file="#OutputFilePath##OutputFileAs#" 
			 output="#BuildString#">
			<cfif BatchAmount GT 0>
				<cfquery name="UpdPending" datasource="#pds#">
					UPDATE Transactions SET 
					BatchPendingYN = 1, 
					CCProcessDate = #Now()#, 
					CCBatchID = #BatchID# 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #AccntPlanID# 
					AND PlanPayBy = 'cc' 
					AND DebitLeft > 0 
				</cfquery>
			<cfelseif BatchRefund GT 0>
				<cfquery name="UpdPending" datasource="#pds#">
					UPDATE Transactions SET 
					BatchPendingYN = 1, 
					CCProcessDate = #Now()#, 
					CCBatchID = #BatchID# 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #AccntPlanID# 
					AND RefundBy = 'cc' 
					AND RefundedYN = 0 
				</cfquery>
			</cfif>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM 
				GrpLists 
				WHERE GrpListID = #GrpListID# 
			</cfquery>
			<cfquery name="UpdHist" datasource="#pds#">
				UPDATE CCBatchHist SET 
				ExportedBy = '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
				ExportDate = #Now()# 
				WHERE BatchID = #BatchID# 
			</cfquery>
		</cftransaction>
	</cfloop>
		
</cfif>
<cfquery name="GetIds" datasource="#pds#">
	SELECT D.BatchDetailID 
	FROM CCBatchDetail D, CCBatchHist H 
	WHERE D.BatchID = H.BatchID 
	AND D.BatchOutput Is Null 
	AND H.BatchID In (#SelectedBatchIDs#) 
	<cfif GetOpts.CCViewAll Is 0>
		AND H.AdminIDExport = #MyAdminID#
	</cfif>
</cfquery>
<cfquery name="FilesCreated" datasource="#pds#">
	SELECT OutPutFilePath, OutputFileAs 
	FROM CCBatchHist 
	WHERE BatchID In (#SelectedBatchIDs#)
</cfquery>
<!--- BOB History --->
<cfif Not IsDefined("NoBOBHist")>
	<cfquery name="BOBHist" datasource="#pds#">
		INSERT INTO BOBHist
		(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
		VALUES 
		(Null,0,#MyAdminID#, #Now()#,'Financial',
		'#StaffMemberName.FirstName# #StaffMemberName.LastName# created the following credit card output files: #ValueList(FilesCreated.OutputFileAs)#.')
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif GetIds.Recordcount GT 0>
	<title>Processing</title>
<cfelse>
	<title>Finished Processing</title>
</cfif>
<cfinclude template="coolsheet.cfm">
</head>
<cfif GetIds.Recordcount GT 0>
	<cfoutput><META HTTP-EQUIV=REFRESH CONTENT="#JumpSecs#; URL=ccoutput2.cfm?RequestTimeout=300"></cfoutput>
</cfif>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
	<table border="#tblwidth#">
</cfoutput>
		<cfif GetIds.Recordcount GT 0>
			<cfoutput>
				<tr>
					<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Processing ...</font></th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">Please standby.</td>
				</tr>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<tr>
					<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Batch Files</font></th>
				</tr>
				<tr>
					<td bgcolor="#tbclr#">The following <cfif FilesCreated.Recordcount GT 1>files are<cfelse>file is</cfif> ready to process.</td>
				</tr>
			</cfoutput>
			<cfoutput query="FilesCreated">
				<tr>
					<td bgcolor="#tbclr#">#OutputFilePath##OutputFileAs#</td>
				</tr>
			</cfoutput>
		</cfif>
	</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 