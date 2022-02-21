<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 4 of the credit card auth importer. --->
<!--- 4.0.0 10/08/99 --->
<!--- ccimport4.cfm --->

<cfset securepage = "ccimport.cfm">
<cfinclude template="security.cfm">
<cfparam name="ApproveCode" default="Approval">

<cfif (IsDefined("MakeItSo.x")) AND (IsDefined("SelEm"))>
	<cfquery name="GetLocaleInfo" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1') 
	</cfquery>
	<cfloop query="GetLocaleInfo">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfloop index="B5" list="#SelEm#">
		<!--- Get Info from CCTemp --->
		<cfquery name="GetInfo" datasource="#pds#">
			SELECT * 
			FROM CCAutoTemp 
			WHERE CCTempID = #B5#
		</cfquery>
		<cfset BatchID = GetInfo.BatchID>
		<cfset AccountID = GetInfo.AccountID>
		<!--- Insert Transactions --->
		<cfquery name="GetIDs" datasource="#pds#">
			SELECT FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID, PayBy 
			FROM AccntPlans 
			WHERE AccntPlanID In 
				(SELECT AccntPlanID 
				 FROM AccntPlans 
				 WHERE AccountID = #AccountID#) 
		</cfquery>
		<cfquery name="PersonalInfo" datasource="#pds#">
			SELECT FirstName, LastName, SalesPersonID 
			FROM Accounts 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cftransaction>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO TransActions 
				(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
				 MemoField,AdjustmentYN,EnteredBy,
				 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
				 SubAccountID,SetUpFeeYN,
				 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
				 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
				 PlanPayBy,SalesPersonID,AccntPlanID,DiscountYN,
				 FirstName, LastName, PayType) 
				VALUES 
				(#AccountID#, #Now()#,
				<cfif ImportHow Is 1>
					#GetInfo.Amount#, 0, 0, 0, #GetInfo.Amount#, 0, 'Payment - #GetInfo.Memo1#',
				<cfelseif ImportHow Is 2>
					0, 0, 0, 0, 0, 0, '#GetInfo.Memo1#',
				<cfelseif ImportHow Is 3>
					0, #GetInfo.Amount#, 0, 0, 0, #GetInfo.Amount#, 'Refund - #GetInfo.Memo1#',
				</cfif>
				 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
			 	<cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
				<cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
			 	<cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
			 	<cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
			 	<cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
				 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
				 '#GetIDs.PayBy#', #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
			 	 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', 'Credit Card'
				) 
			</cfquery>
			<cfquery name="TheID" datasource="#pds#">
				SELECT Max(TransID) As NewID 
				FROM TransActions 
			</cfquery>
			<cfset TransID = TheID.NewID>
		</cftransaction>
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#AccountID#,#MyAdminID#, #Now()#,'Financial',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# imported a credit card payment of #LSCurrencyFormat(GetInfo.Amount)# for #GetWhoName.FirstName# #GetWhoName.LastName#.')
			</cfquery>
		</cfif>
		<!--- Update BatchDetail History --->
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CCBatchDetail SET 
			TransID = #TransID#, 
			CCResponse = '#GetInfo.ResponseCode#', 
			AuthCode = '#GetInfo.Memo1#' 
			WHERE BatchID = #BatchID# 
			AND AccountID = #AccountID# 
		</cfquery>
		<!--- Delete From CCTemp --->
		<cfquery name="RemoveFrom" datasource="#pds#">
			DELETE FROM CCAutoTemp 
			WHERE CCTempID = #B5# 
		</cfquery>
		<!--- If last record then Update CCBatchHist --->
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT CCTempID 
			FROM CCAutoTemp 
			WHERE BatchID = #BatchID# 
		</cfquery>
		<cfif CheckFirst.RecordCount Is 0>
			<cfquery name="UpdBatchInfo" datasource="#pds#">
				UPDATE CCBatchHist SET 
				TransImportDate = #Now()#, 
				TransImportBy = '#StaffMemberName.FirstName# #StaffMemberName.LastName#' 
				WHERE BatchID = #BatchID# 
			</cfquery>		
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("DelSelected.x")) AND (IsDefined("DelEm"))>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM CCAutoTemp 
		WHERE CCTempID In (#DelEm#) 
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CCTempID 
		FROM CCAutoTemp 
		WHERE BatchID = #BatchID# 
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="UpdBatchInfo" datasource="#pds#">
			UPDATE CCBatchHist SET 
			TransImportDate = #Now()#, 
			TransImportBy = '#StaffMemberName.FirstName# #StaffMemberName.LastName#' 
			WHERE BatchID = #BatchID# 
		</cfquery>		
	</cfif>
</cfif>
<cfif IsDefined("ContinueImport.x")>
	<cfquery name="getccinput" datasource="#pds#">
		SELECT * 
		FROM CustomCCInput
		WHERE UseYN = 1 
		AND LineOrder = 1 
		ORDER BY LineOrder, SortOrder
	</cfquery>
	<cfquery name="GetCCInputL2" datasource="#pds#">
		SELECT * 
		FROM CustomCCInput
		WHERE UseYN = 1 
		AND LineOrder = 2 
		ORDER BY SortOrder
	</cfquery>	
	<cfquery name="GetCCOutput" datasource="#pds#">
		SELECT FieldName1, Description1 
		FROM CustomCCOutput 
		WHERE UseTab = 0 
		OR UseTab = 4 
	</cfquery>
	<cfloop query="GetCCOutput">
		<cfset "#FieldName1#" = Description1>
	</cfloop>
	<cfset ColumnNames = "#ValueList(getccinput.fieldname1)#">
	<cfset ColumnNames2 = "#ValueList(getccinputl2.fieldname1)#">
	<cfset FileName = "#ImportFilePath##ImportFileName#">
	<cfset WantedColumns = "#ValueList(getccinput.sortorder)#">
	<cfset WantedColumns2 = "#ValueList(getccinputl2.sortorder)#">
	<cfset DelimString = "#ccdelimit#">
	<cfset StripChar=Chr(34)>
	<cfif delimstring is "pipe">
		<cfset delimstring = "|">
	</cfif>
	<cfif ColumnNames2 Is Not "">
		<cfset AllColumns = ColumnNames & "," & ColumnNames2>
	<cfelse>
		<cfset AllColumns = ColumnNames>
	</cfif>
	<cfset ImportQuery=QueryNew(#AllColumns#)>
	<cffile action="read" File="#ImportFilePath##ImportFileName#" Variable="message">
	<cfquery name="ImportInfo" datasource="#pds#">
		SELECT Description1, FieldName1 
		FROM CustomCCOutput 
		WHERE UseTab = 4 
	</cfquery>
	<cfset TheCurRow=0>
	<cfif CCInputHeadRow is 1>
		<cfset linecount = 3>
	<cfelse>
		<cfset linecount = 1>
	</cfif>
	<cfloop index="CurrentRow" list="#message#" delimiters="
">
		<cfif linecount is 1>
			<cfif ccinputlines gt 1>
				<cfset linecount = 2>
			</cfif>
	  		<cfset TheCurRow=TheCurRow+1>
			<cfset TheColumn=0>
			<cfset n=QueryAddRow(ImportQuery)>
		   <cfset currentrow = Replace("#CurrentRow#","#DelimString##DelimString#","#DelimString# #DelimString#","All")>
	   	<cfset currentrow = Replace("#CurrentRow#","#DelimString##DelimString#","#DelimString# #DelimString#","All")>	
			<cfloop index="Theval" list="#CurrentRow#" delimiters="#DelimString#">
				<cfset TheColumn=TheColumn+1>
				<cfif ListFind("#WantedColumns#",TheColumn,",")>
					<cfset t = QuerySetCell(ImportQuery,"#Trim(ListGetAt(ColumnNames,ListFind(WantedColumns,TheColumn),","))#",Replace(Theval,StripChar,"","All"))> 
				</cfif>
			</cfloop>
		<cfelseif linecount is 2>
			<cfset linecount = 1>
			<cfset TheColumn=0>
	   	<cfset currentrow = Replace("#CurrentRow#","#DelimString##DelimString#","#DelimString# #DelimString#","All")>
		   <cfset currentrow = Replace("#CurrentRow#","#DelimString##DelimString#","#DelimString# #DelimString#","All")>	
			<cfloop index="Theval" list="#CurrentRow#" delimiters="#DelimString#">
	   		<cfset TheColumn=TheColumn+1>
				<cfif ListFind("#WantedColumns2#",TheColumn,",")>
	   	   	<cfset t = QuerySetCell(ImportQuery,"#Trim(ListGetAt(ColumnNames2,ListFind(WantedColumns2,TheColumn),","))#",Replace(Theval,StripChar,"","All"))> 
		   	</cfif>
			</cfloop>
		<cfelseif linecount is 3>
			<cfset linecount = 1>
		</cfif>
	</cfloop>
	<cfquery name="GetCodeWide" datasource="#pds#">
		SELECT Description1 
		FROM CustomCCOutput 
		WHERE UseTab = 4 
		AND FieldName1 = 'CodeWide' 
	</cfquery>
	<cfset CodeWide = GetCodeWide.Description1>
	<cfloop query="ImportQuery">
		<cfif Trim(AccountID) Is Not "">
			<cfquery name="getlogin" datasource="#pds#">
				SELECT login 
				FROM Accounts 
				WHERE AccountID = #AccountID#
			</cfquery>
			<cfset ThePaymentAmount = Replace("#ImportQuery.amount#","$","")>
			<cfset ThePaymentCode = Replace(ThePaymentAmount,".","")>
			<cfset RAmnt = LSParseNumber(#thepaymentamount#)>
			<cfset TheResponseCode = Replace(ResponseCode,ThePaymentCode,"")>
			<cfset TheResponseCode = Trim(TheResponseCode)>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT CCTempID 
				FROM CCAutoTemp 
				WHERE BatchID = #BatchID# 
				AND AccountID = #AccountID# 
				AND Amount = #RAmnt# 
				AND Memo1 = '#AuthCode#' 
				AND ResponseCode = '#TheResponseCode#' 
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="Import#ImportQuery.Accountid#" datasource="#pds#">
					INSERT INTO CCAutoTemp 
					(BatchID, Credit, Debit, DateTime1, Adjustmentyn, EnteredBy, AccountID 
					<cfif (ListFind(ColumnNames,"Amount") GT 0) OR (ListFind(ColumnNames2,"Amount") GT 0)>
					 	, Amount
					</cfif>
					<cfif (ListFind(ColumnNames,"AuthCode") GT 0) OR (ListFind(ColumnNames2,"AuthCode") GT 0)>
					 	, Memo1 
					</cfif>
					<cfif (ListFind(ColumnNames,"CCNum") GT 0) OR (ListFind(ColumnNames2,"CCNum") GT 0)>
						, CCNumber
					</cfif>
					<cfif (ListFind(ColumnNames,"TypeCode") GT 0) OR (ListFind(ColumnNames2,"TypeCode") GT 0)>
						, PayType
					</cfif>
					<cfif (ListFind(ColumnNames,"ResponseCode") GT 0) OR (ListFind(ColumnNames2,"ResponseCode") GT 0)>
						, ResponseCode
					</cfif>
					 ) 
					VALUES 
					(#BatchID#, 0, 0, #Now()#, 0, '#StaffMemberName.Firstname# #StaffMemberName.Lastname#', 
					 #Accountid#
					<cfif (ListFind(ColumnNames,"Amount") GT 0) OR (ListFind(ColumnNames2,"Amount") GT 0)>
					 	, #ThePaymentAmount#
					</cfif>
					<cfif (ListFind(ColumnNames,"AuthCode") GT 0) OR (ListFind(ColumnNames2,"AuthCode") GT 0)>
					 	,  '#AuthCode#'
					</cfif>
					<cfif (ListFind(ColumnNames,"CCNum") GT 0) OR (ListFind(ColumnNames2,"CCNum") GT 0)>
						, '#CCNum#' 
					</cfif>
					<cfif (ListFind(ColumnNames,"TypeCode") GT 0) OR (ListFind(ColumnNames2,"TypeCode") GT 0)>
						, <cfif CodeWide GT 0>'#Left(TypeCode,CodeWide)#'<cfelse>'#TypeCode#'</cfif> 
					</cfif>
					<cfif (ListFind(ColumnNames,"ResponseCode") GT 0) OR (ListFind(ColumnNames2,"ResponseCode") GT 0)>
						, '#TheResponseCode#'
					</cfif>
					)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CCAutoTemp SET 
		FirstName = A.FirstName, 
		LastName = A.LastName 
		FROM Accounts A, CCAutoTemp C 
		WHERE A.AccountID = C.AccountID 
		AND C.BatchID = #BatchID#
	</cfquery>
	<cfquery name="UpdBatch" datasource="#pds#">
		UPDATE CCBatchHist SET 
		ImportedBy = '#StaffMemberName.FirstName# #StaffMemberName.LastName#', 
		ImportFileAs = '#ImportFileName#', 
		ImportFilePath = '#ImportFilePath#', 
		ImportDate = #Now()# 
		WHERE BatchID = #BatchID# 
	</cfquery>
</cfif>
<cfparam name="page" default="1">
<cfparam name="TransType" default="All">
<cfparam name="Responses" default="All">

<cfquery name="AllImported" datasource="#pds#">
	SELECT * 
	FROM CCAutoTemp 
	WHERE BatchID = #BatchID# 
	<cfif TransType Is Not "All">
		AND PayType = '#TransType#' 
	</cfif>
	<cfif Responses Is Not "All">
		AND ResponseCode = '#Responses#' 
	</cfif>
</cfquery>
<cfif AllImported.RecordCount Is 0>
	<cfquery name="AllImported" datasource="#pds#">
		SELECT * 
		FROM CCAutoTemp 
		WHERE BatchID = #BatchID# 
	</cfquery>
	<cfif AllImported.RecordCount Is 0>
		<cfset MessageStr = "Finished importing.">
	</cfif>
</cfif>
<cfquery name="Types" datasource="#pds#">
	SELECT PayType 
	FROM CCAutoTemp 
	WHERE BatchID = #BatchID# 
	GROUP BY PayType 
	ORDER BY PayType 
</cfquery>
<cfquery name="TheResponses" datasource="#pds#">
	Select ResponseCode 
	FROM CCAutoTemp 
	WHERE BatchID = #BatchID# 
	AND ResponseCode Is Not Null 
	AND ResponseCode <> ''
	GROUP BY ResponseCode 
	ORDER BY ResponseCode 
</cfquery>
<!--- <cfloop query="TheResponses">
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CCRID 
		FROM CCResponses 
		WHERE ResponseCode = '#ResponseCode#' 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset ShowAll = 0>
		<cfset securepage = "ccimport.cfm">
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="ccresponse.cfm">
		<cfabort>
	</cfif>
</cfloop> --->
<cfif page Is 0>
	<cfset srow = 1>
	<cfset maxrows = AllImported.Recordcount>
<cfelse>
	<cfset srow = (page * mrow) - (mrow - 1)>
	<cfset maxrows = mrow>
</cfif>
<cfset PageNumber = Ceiling(AllImported.Recordcount/mrow)>
<cfset HowWide = 8>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'Locale'
</cfquery>
<cfset Locale = GetLocale.Value1>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Import CC Batch</title>
<script language="javascript">
<!--  
function SelectAll(tf)
	{
	 var len = document.CCImport.SelEm.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.CCImport.SelEm[i].checked=tf;
		}
	}
// -->
</script>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Import CC Batch</font></th>
	</tr>
</cfoutput>
	<cfif IsDefined("MessageStr")>
		<tr>
			<cfoutput>
				<td colspan="#HowWide#" bgcolor="#tbclr#">#MessageStr#</td>
			</cfoutput>
		</tr>
	<cfelse>
		<form method="post" action="ccimport4.cfm">
			<tr>
				<cfoutput><td colspan="#HowWide#"><select name="page" onchange="submit()"></cfoutput>
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfset DispStr = AllImported.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#b5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #AllImported.Recordcount#</cfoutput>
				</select></td>
			</tr>
			<cfoutput>
				<input type="hidden" name="BatchID" value="#BatchID#">
				<input type="hidden" name="Responses" value="#Responses#">
				<input type="hidden" name="TransType" value="#TransType#">
			</cfoutput>
		</form>
		<form method="post" action="ccimport4.cfm?RequestTimeout=500" name="CCImport">
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td colspan="#HowWide#">Transaction Type <select name="TransType" onchange="submit()"></cfoutput>
						<option <cfif TransType Is "All">selected</cfif> value="All">All
						<cfoutput query="Types">
							<option <cfif TransType Is "#PayType#">selected</cfif> value="#PayType#">#PayType#
						</cfoutput>
					</select></td>	
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td colspan="#HowWide#">Codes <select name="Responses" onchange="submit()"></cfoutput>
						<option <cfif Responses Is "All">selected</cfif> value="All">All
						<cfoutput query="TheResponses">
							<option <cfif Responses Is "#ResponseCode#">selected</cfif> value="#ResponseCode#">#ResponseCode#
						</cfoutput>
					</select></td>
			</tr>
			<cfoutput>
				<tr bgcolor="#thclr#" valign="top">
					<th>Select<br><font size="1"><a href="javascript:SelectAll(true)">Select</a> <a href="javascript:SelectAll(false)">Clear</a></font></th>
					<th>Name</th>
					<th>Amount</th>
					<th>Card Number</th>
					<th>Trans Code</th>
					<th>Response</th>
					<th>Description</th>
					<th>Delete</th>
				</tr>
			</cfoutput>
			<cfoutput query="AllImported" startrow="#srow#" maxrows="#Maxrows#">
				<tr bgcolor="#tbclr#">
					<cfif Trim(CCNumber) Is "">
						<cfset CCStr = "">
					<cfelse>
						<cfset RghtStr = Right(CCNumber,4)>
						<cfset LeftStr = Left(CCNumber,1)>
						<cfset MddlStr = Len(CCNumber) - 5>
						<cfset CCStr = LeftStr & "#RepeatString("*",MddlStr)#" & RghtStr>
					</cfif>
					<th bgcolor="#tdclr#"><input type="Checkbox" name="SelEm" value="#CCTempID#"></th>
					<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
					<td align="right">#LSCurrencyFormat(Amount)#</td>
					<td>#CCStr#</td>
					<td>#PayType#<cfif PayType Is "">&nbsp;</cfif></td>
					<td>#ResponseCode#<cfif ResponseCode Is "">&nbsp;</cfif></td>
					<td>#Memo1#<cfif Memo1 Is "">&nbsp;</cfif></td>
					<th bgcolor="#tdclr#"><input type="Checkbox" name="DelEm" value="#CCTempID#"></th>
				</tr>
			</cfoutput>
			<cfoutput>
				<tr>
					<td colspan="#HowWide#" bgcolor="#tdclr#"><b>Import selected as:</b> <select name="ImportHow">
						<option selected value="1">Payment
						<option value="2">Information
						<option value="3">Refund
					</select></td>
				</tr>
				<tr>
					<td colspan="#HowWide#">
						<table border="0" width="100%">
							<tr valign="top">
								<td valign="top"><input type="image" src="images/startimp.gif" name="MakeItSo" border="0"></td>						
								<td align="right" colspan="#HowWide#"><input type="image" name="DelSelected" src="images/delete.gif" border="0"></td>
							</tr>
						</table>
					</td>
				</tr>
				<input type="hidden" name="BatchID" value="#BatchID#">
			</cfoutput>
		</form>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 