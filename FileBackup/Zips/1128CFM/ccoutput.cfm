<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page copies the batch credit card file info to CCBatchDetail. --->
<!--- 4.0.0 09/19/98 --->
<!--- ccoutput.cfm --->

<cfquery name="GetCCDefs" datasource="#pds#">
	SELECT * 
	FROM CustomCCOutput
	WHERE UseTab = 0 
</cfquery>
<cfloop query="GetCCDefs">
	<cfparam name="#FieldName1#" default="#Description1#">
</cfloop>
<cfif IsDefined("Process.x")>
	<cfquery name="SeeHowMany" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 19 
		AND AdminID = #MyAdminID# 
		ORDER BY GrpListID 
	</cfquery>
	<cfset TheBatches = "">
	<cfset HowManyFiles = Ceiling(SeeHowMany.Recordcount/MaxPerFile)>
	<cfloop index="B5" from="1" to="#HowManyFiles#">
		<cfset Srow = (B5 * MaxPerFile) - (MaxPerFile - 1)>
		<cfset SID = SeeHowMany.GrpListID[Srow]>
		<cfset Erow = Srow + MaxPerFile - 1>
		<cfif Erow GT SeeHowMany.Recordcount>
			<cfset Erow = SeeHowMany.Recordcount>
		</cfif>
		<cfset EID = SeeHowMany.GrpListID[Erow]>
		<cftransaction>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO CCBatchHist 
				(AdminIDExport, ExportDate, OutputFileAs, OutPutFilePath) 
				VALUES 
				(#MyAdminID#, #Now()#, '#CCOutFile#','#CCOutPath#')
			</cfquery>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(BatchID) as MID 
				FROM CCBatchHist
			</cfquery>
			<cfset ThisBatchID = GetID.MID>
			<cfset Pos1 = FindNoCase(".","#Reverse(CCOutFile)#")>
			<cfset Pos2 = Len(CCOutFile) - Pos1>
			<cfset Pos3 = Pos1 - 1>
			<cfset TheOutFileName = Left(CCOutFile,Pos2)>
			<cfset TheOutFileExt = Right(CCoutFile,Pos3)>
			<cfif HowManyFiles GT 1>
				<cfset TheFileName = TheOutFileName & ThisBatchID & "-#B5#." & TheOutFileExt>
			<cfelse>
				<cfset TheFileName = TheOutFileName & ThisBatchID & "." & TheOutFileExt>
			</cfif>
			<cfquery name="UpdFileName" datasource="#pds#">
				UPDATE CCBatchHist SET 
				OutputFileAs = '#TheFileName#' 
				WHERE BatchID = #ThisBatchID# 
			</cfquery>
			<cfset TheBatches = ListAppend(TheBatches,GetID.MID)>
			<cfquery name="InsDetailData" datasource="#pds#">
				INSERT INTO CCBatchDetail 
				(GrpListID,AccountID, EMailAddr, BatchAmount, BatchRefund, AccntPlanID, Company, Firstname, LastName, BatchID)
				SELECT GrpListID,AccountID, EMail, CurBal, CurBal2, AccntPlanID, Company, Firstname, LastName, #ThisBatchID# 
				FROM GrpLists 
				WHERE GrpListID <= #EID# 
				AND GrpListID >= #SID# 
				AND AdminID = #MyAdminID# 
				AND ReportID = 19 				
			</cfquery>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE GrpLists 
				SET ReportURLID2 = 1 
				WHERE GrpListID <= #EID# 
				AND GrpListID >= #SID# 
				AND AdminID = #MyAdminID# 
				AND ReportID = 19 
			</cfquery>
		</cftransaction>
	</cfloop>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CCBatchDetail SET 
		CCBatchDetail.AVSAddress = C.AVSAddress, 
		CCBatchDetail.AVSZip = C.AVSZip, 
		CCBatchDetail.CCNumber = C.CCNumber, 
		CCBatchDetail.CCMonth = C.CCMonth, 
		CCBatchDetail.CCYear = C.CCYear, 
		CCBatchDetail.CCCardHolder = C.CCCardHolder, 
		CCBatchDetail.CCType = C.CCType 
		FROM CCBatchDetail D, PayByCC C 
		WHERE D.AccntPlanID = C.AccntPlanID 
		AND BatchID In (#TheBatches#) 
		AND C.ActiveYN = 1 
	</cfquery>
</cfif>
<cfquery name="FileOutputs" datasource="#pds#">
	SELECT H.BatchID, H.OutPutFilePath, H.OutputFileAs, 
	Count(BatchDetailID) as BatchNum 
	FROM CCBatchHist H, CCBatchDetail D 
	WHERE H.BatchID = D.BatchID 
	<cfif GetOpts.CCViewAll Is 0>
		AND H.AdminIDExport = #MyAdminID# 
	</cfif>
	AND H.ExportedBy Is Null 
	GROUP BY H.BatchID, H.OutPutFilePath, H.OutputFileAs
	ORDER BY H.BatchID 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Credit Card Output</title>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif IsDefined("Goto")>
	<form method="post" action="ccimport.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Credit Card Batch Files</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="4">The following file(s) need to be created and batch processed.</td>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Select</th>
		<th>File Name</th>
		<th>Customers</th>
		<th>File Path</th>
	</tr>
</cfoutput>
	<form method="post" action="ccoutput2.cfm?RequestTimeout=500" onsubmit="MsgWindow()">
		<cfoutput query="FileOutputs">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" name="SelectedIDs" value="#BatchID#"></th>
				<td>#OutputFileAs#</td>
				<td align="right">#BatchNum#</td>
				<td>#OutPutFilePath#</td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="5">
				<table border="0">
					<tr>
						<th><input type="image" src="images/beginoutput.gif" name="CreateFiles" border="0"></th>
						<input type="hidden" name="SelectedIDs_Required" value="Please select the batches to output.">
	</form>
	<form method="post" action="ccbatch.cfm">
						<cfoutput>
							<input type="hidden" name="TheBatches" value="#ValueList(FileOutputs.BatchID)#">
						</cfoutput>
						<th><input type="image" src="images/delete.gif" name="StartOver" border="0"></th>
					</tr>
				</table>
			</th>
		</tr>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   