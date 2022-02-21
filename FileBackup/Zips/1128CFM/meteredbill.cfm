<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 09/12/99 
		3.4.0 04/15/99 --->
<!--- meteredbill.cfm --->

<cfinclude template="security.cfm">
<cfparam name="strMessage" default="0">

<cfif (IsDefined("DeleteEM")) AND (IsDefined("DeleteSel.x"))>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM TimeTemp 
		WHERE TimeTempID In (#DeleteEM#)
	</cfquery>
	<cfset strMessage = 1>
</cfif>
<cfif ((IsDefined("SelectEM.x")) AND (IsDefined("DebitEm")))OR (IsDefined("DebitAll.x"))>
	<cfset strMessage = 1>
	<cfif IsDefined("DeleteEM")>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM TimeTemp 
			WHERE TimeTempID In (#DeleteEM#)
		</cfquery>
	</cfif>
	<cfif IsDefined("DebitAll.x")>
		<cfquery name="GetAllIDs" datasource="#pds#">
			SELECT TimeTempID 
			FROM TimeTemp 
		</cfquery>
		<cfset DebitEM = ValueList(GetAllIDs.TimeTempID)>
	</cfif>
	<cfloop index="B1" list="#DebitEM#">
			<cfquery name="OneAtATime" datasource="#pds#">
				SELECT * 
				FROM TimeTemp 
				WHERE TimeTempID = #B1#
			</cfquery>
			<cfif OneAtATime.Recordcount Is Not 0>
				<cfquery name="GetNextDueDay" datasource="#pds#">
					SELECT A.NextDueDate, P.PayDueDays, P.DeactDays
					FROM AccntPlans A, Plans P 
					WHERE A.PlanID = P.PlanID 
					AND AccntPlanID = #OneAtATime.AccntPlanID#
				</cfquery>
				<cfset TodaysDateIs = Now()>
				<cfset FirstCheckDate = CreateDateTime(Year(TodaysDateIs),Month(TodaysDateIs),Day(GetNextDueDay.NextDueDate),0,0,0)>
				<cfif FirstCheckDate LT Now()>
					<cfset FirstCheckDate = DateAdd("m",2,FirstCheckDate)>
				<cfelse>
					<cfset FirstCheckDate = DateAdd("m",1,FirstCheckDate)>
				</cfif>
				<cfset SecondCheckDate = DateAdd("d",GetNextDueDay.PayDueDays,FirstCheckDate)>
				<cfset ThirdCheckDate = DateAdd("d",GetNextDueDay.DeactDays,FirstCheckDate)>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE TimeTemp SET 
					PaymentDueDate = #CreateODBCDateTime(FirstCheckDate)# 
					<cfif GetNextDueDay.PayDueDays GT 0>
						, PaymentLateDate = #CreateODBCDateTime(SecondCheckDate)#
					</cfif>
					<cfif GetNextDueDay.DeactDays GT 0>
						, AccntCutOffDate = #CreateODBCDateTime(ThirdCheckDate)#
					</cfif>
					WHERE TimeTempID = #B1# 
				</cfquery>
				<cfset whoami = OneAtATime.login>
				<cfset sdate = CreateODBCDateTime(OneAtATime.fromdate)>
				<cfset edate = CreateODBCDateTime(OneAtATime.todate2)>
				<cfif oneatatime.SpanType is 1>
					<cfquery name="setdone" datasource="#pds#">
						UPDATE Calls SET 
						BilledYN = 1 
						WHERE UserName = '#whoami#' 
						AND CallDate <= #edate# 
						AND CallDate >= #sdate# 
					</cfquery>
				<cfelse>
					<cfquery name="setdone" datasource="#pds#">
						UPDATE TimeStore 
						SET FinishedYN = 1
						WHERE login = '#whoami#' 
						AND LastBillDate <= #edate#
						AND LastBillDate >= #sdate# 
					</cfquery>
				</cfif>
			</cfif>
	</cfloop>
	<cftransaction>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				SELECT Null, 0, #MyAdminID#, #Now()#, 'Debit Metered', '#StaffMemberName.FirstName# #StaffMemberName.LastName# debited the metered billing for ' + FirstName + ' ' + LastName + '.' 
				FROM TimeTemp 
				WHERE TimeTempID In (#debitem#) 
			</cfquery>
		</cfif>
		<cfquery name="moveem" datasource="#pds#">
			INSERT INTO TransActions
			(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
			 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
			 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
			 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
			 FirstName,LastName)
			SELECT PAccountID, #Now()#, 0, TotAmount, Memo1, 0, EnteredBy, 0, 
			EMailDomainID, FTPDomainID, AuthDomainID, POPID, PlanID, 0, 0, 
			AccountID, 0, PaymentDueDate, AccntCutOffDate, 0 , PaymentLateDate, 0, 0, 0, 
			FromDate, ToDate2, PlanPayBy, SalesPersonID, AccntPlanID, TotAmount, 0, 0, FirstName, LastName 
			FROM TimeTemp 
			WHERE TimeTempID In (#debitem#)
		</cfquery>
		<cfquery name="moveem" datasource="#pds#">
			INSERT INTO TransActions
			(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
			 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
			 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
			 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
			 FirstName,LastName)
			SELECT paccountid, #Now()#, 0, Tax1, TaxDesc1, 0, EnteredBy, 1, 
			EMailDomainID, FTPDomainID, AuthDomainID, POPID, PlanID, 1, 0, 
			AccountID, 0, PaymentDueDate, AccntCutOffDate, 0 , PaymentLateDate, 0, 0, 0, FromDate, ToDate2, 
			PlanPayBy, SalesPersonID, AccntPlanID, Tax1, 0, 0, FirstName, LastName 
			FROM TimeTemp 
			WHERE Tax1 > 0 
			AND TimeTempID In (#debitem#)
		</cfquery>
		<cfquery name="moveem" datasource="#pds#">
			INSERT INTO TransActions
			(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
			 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
			 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
			 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
			 FirstName,LastName)
			SELECT paccountid, #Now()#, 0, Tax2, TaxDesc2, 0, EnteredBy, 1, 
			EMailDomainID, FTPDomainID, AuthDomainID, POPID, PlanID, 2, 0, 
			AccountID, 0, PaymentDueDate, AccntCutOffDate, 0 , PaymentLateDate, 0, 0, 0, FromDate, ToDate2, 
			PlanPayBy, SalesPersonID, AccntPlanID, Tax2, 0, 0, FirstName, LastName  
			FROM TimeTemp WHERE Tax2 > 0 
			AND TimeTempID In (#debitem#)			
		</cfquery>
		<cfquery name="moveem" datasource="#pds#">
			INSERT INTO TransActions
			(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
			 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
			 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
			 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
			 FirstName,LastName)
			SELECT paccountid, #Now()#, 0, Tax3, TaxDesc3, 0, EnteredBy, 1, 
			EMailDomainID, FTPDomainID, AuthDomainID, POPID, PlanID, 3, 0, 
			AccountID, 0, PaymentDueDate, AccntCutOffDate, 0 , PaymentLateDate, 0, 0, 0, FromDate, ToDate2, 
			PlanPayBy, SalesPersonID, AccntPlanID, Tax3, 0, 0, FirstName, LastName  
			FROM TimeTemp WHERE Tax3 > 0 
			AND TimeTempID In (#debitem#)			
		</cfquery>
		<cfquery name="moveem" datasource="#pds#">
			INSERT INTO TransActions
			(AccountID,DateTime1,Credit,Debit,MemoField,AdjustmentYN,EnteredBy,TaxYN,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,TaxLevel,FinishedYN,
			 SubAccountID,SetUpFeeYN,PaymentDueDate,AccntCutOffDate,PrintedYN,
			 PaymentLateDate,EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate,
			 DebitToDate,PlanPayBy,SalesPersonID,AccntPlanID,DebitLeft,CreditLeft,DiscountYN,
			 FirstName,LastName)
			SELECT paccountid, #Now()#, 0, Tax4, TaxDesc4, 0, EnteredBy, 1, 
			EMailDomainID, FTPDomainID, AuthDomainID, POPID, PlanID, 4, 0, 
			AccountID, 0, PaymentDueDate, AccntCutOffDate, 0 , PaymentLateDate, 0, 0, 0, FromDate, ToDate2, 
			PlanPayBy, SalesPersonID, AccntPlanID, Tax4, 0, 0, FirstName, LastName  
			FROM TimeTemp WHERE Tax4 > 0 
			AND TimeTempID in (#debitem#)			
		</cfquery>
		<cfset TransType = "Debit">
		<cfset TheAccountID = DebitEm>
		<cfinclude template="cfpayment.cfm">
		<cfquery name="moveon" datasource="#pds#">
			DELETE FROM TimeTemp 
			WHERE TimeTempid in (#debitem#)
		</cfquery>
	</cftransaction>
</cfif>

<cfparam name="Page" default="1">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfquery name="AllDue" datasource="#pds#">
	SELECT * 
	FROM TimeTemp 
	WHERE CAuthID > 0 
	ORDER BY <cfif obid Is "Name">LastName #obdir#, FirstName #obdir#<cfelse>#obid# #obdir#</cfif>
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllDue.Recordcount>
<cfelse>
	<cfset Srow = (Page*Mrow)-(Mrow-1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllDue.Recordcount/mrow)>
<cfset TotalAmount = 0>
<cfset TotalTax = 0>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Metered Billing Pending Charges</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="6" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Metered Billing</font></th>
	</tr>
</cfoutput>
<cfif AllDue.Recordcount Is 0>
	<cfoutput>
		<tr>
			<cfif strMessage Is 0>
				<td colspan="6" bgcolor="#tbclr#">There are no metered records to process.</td>
			<cfelse>
				<td colspan="6" bgcolor="#tbclr#">Finished processing metered records.</td>
			</cfif>
		</tr>
	</cfoutput>
<cfelse>
	<cfif AllDue.Recordcount gt Mrow>
		<tr>
			<form method="post" action="meteredbill.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="6"><select name="Page" onchange="submit()">
					<cfloop Index="B5" from="1" To="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfset DispStr = AllDue.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDue.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Charge</th>
			<th>Name</th>
			<th>Description</th>
			<th>Amount</th>
			<th>Tax</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" action="meteredbill.cfm?RequestTimeout=800">
		<cfoutput>
			<input type="hidden" name="page" value="#Page#">
		</cfoutput>
		<cfoutput query="AllDue" startrow="#Srow#" maxrows="#Maxrows#">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input checked type="checkbox" name="DebitEm" value="#TimeTempID#"></th>
				<td><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
				<td bgcolor="#tbclr#">#Memo1#</td>
				<td align="right">#LSCurrencyFormat(TotAmount)#</td>
				<cfset TaxAmount = Tax1 + Tax2 + Tax3 + Tax4>
				<td align="right">#LSCurrencyFormat(TaxAmount)#</td>
				<cfset TotalAmount = TotalAmount + TotAmount>
				<cfset TotalTax = TotalTax + TaxAmount>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DeleteEM" value="#TimeTempID#"</th>
			</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="#thclr#">
			<th colspan="3" align="right">Total</th>
			<th align="right">#LSCurrencyFormat(TotalAmount)#</th>
			<th align="right">#LSCurrencyFormat(TotalTax)#</th>
			<th>&nbsp;</th>
		</tr>
		<tr>
			<th BGCOLOR="#thclr#" COLSPAN="6">WARNING!  Clicking Delete will delete the selected charges and never bill the customer for these charges.</th>
		</tr>
		</cfoutput>
		<tr>
			<th colspan="6">
				<table border=0>
					<tr>
						<th><input type="image" name="SelectEm" src="images/debitcheck.gif" border="0"></th>
						<cfif AllDue.Recordcount gt Mrow>
							<th><input type="image" src="images/debitall2.gif" name="DebitAll" border="0"></th>
						</cfif>
						<th><input type="image" name="DeleteSel" src="images/delete.gif" border="0"></th>
					</tr>
				</table>
			</th>
		</tr>
	</form>
	<cfif AllDue.Recordcount gt Mrow>
		<tr>
			<form method="post" action="meteredbill.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="6"><select name="Page" onchange="submit()">
					<cfloop Index="B5" from="1" To="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfset DispStr = AllDue.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDue.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  