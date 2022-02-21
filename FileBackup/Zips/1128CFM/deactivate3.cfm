<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Deactivates entire account. --->
<!---	4.0.0 10/27/99 --->
<!-- deactivate.cfm -->

<cfif GetOpts.DeactC Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfparam name="SubStatus" default="Ignore">

<cfquery name="CurrentAmount" datasource="#pds#">
	SELECT Sum(Debit-Credit) AS CurBal 
	FROM Transactions 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif SubStatus Is "All">
	<cfquery name="AllIDs" datasource="#pds#">
		SELECT AccountID 
		FROM Multi 
		WHERE PrimaryID = #AccountID# 
	</cfquery>
	<cfset AllTheIDs = ValueList(AllIDs.AccountID)>
<cfelse>
	<cfset AllTheIDs = AccountID>
</cfif>
<cfif CurrentAmount.CurBal Is "">
	<cfset AmntStat = "None">
	<cfset CustAmount = 0>
<cfelseif CurrentAmount.CurBal GT 0>
	<cfset AmntStat = "Owes">
	<cfset CustAmount = ABS(CurrentAmount.CurBal)>
<cfelseif CurrentAmount.CurBal LT 0>
	<cfset AmntStat = "Credit">
	<cfset CustBal = ABS(CurrentAmount.CurBal)>
	<cfset CustAmount = ABS(CurrentAmount.CurBal)>
<cfelse>
	<cfset AmntStat = "None">
	<cfset CustAmount = 0>
</cfif>

<cfif (AmntStat Is "Owes") OR (AmntStat Is "None")>
	<cfset SkipThree = 1>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="deactivate4.cfm">
	<cfabort>
</cfif>
<cfparam name="NextBilling" default="0">
<cfparam name="MyTotalTax" default="0">
<cfparam name="MyTotalBill" default="0">
<!--- Deact Now --->
<cfif DeactWhen Is "Now">
	<cfset NextBilling = NextBilling + 0>
<!--- Deact Later --->
<cfelseif DeactWhen Is "Later">
<!--- No More Billing --->
	<cfif BillMethod Is 1>
		<cfset NextBilling = NextBilling + 0>
<!--- Prorate Next Billing --->
	<cfelseif BillMethod Is 2>
		<cfset MyTotalTax = 0>
		<cfset MyTotalBill = 0>
		<cfquery name="GetDetails" datasource="#pds#">
			SELECT A.AccntPlanID, A.POPID, P.RecurringAmount, P.RecurDiscount, 
			P.Taxable, P.Taxable2, L.Tax1, L.Tax2, L.Tax3, L.Tax4, 
			L.Tax1Type, L.Tax2Type, L.Tax3Type, L.Tax4Type, A.AccountID, 
			A.Taxable, A.NextDueDate, P.RecurringCycle 
			FROM AccntPlans A, Plans P, POPS L 
			WHERE A.PlanID = P.PlanID 
			AND A.POPID = L.POPID 
			AND A.NextDueDate < #CreateODBCDateTime(WhenRun)# 
			AND A.AccountID In (#AllTheIDs#) 
		</cfquery>
		<cfloop query="GetDetails">
			<cfif Taxable Is 1>
				<cfset Date1 = CreateDateTime(Year(NextDueDate),Month(NextDueDate),Day(NextDueDate),0,0,0)>
				<cfset Date2 = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
				<cfset RAmount1 = RecurringAmount/(RecurringCycle*(365/12))>
				<cfset DAmount2 = RecurDiscount/(RecurringCycle*(365/12))>
				<cfset NumDays = DateDiff("d",Date1,Date2)>

				<cfset Total1 = RAmount1*NumDays>
				<cfset Total1 = Trim(NumberFormat(Total1, '9999999999999999999.99'))>
				<cfset Total2 = DAmount2*NumDays>
				<cfset Total2 = Trim(NumberFormat(Total2, '9999999999999999999.99'))>

				<cfset TotalTax1 = 0>
				<cfset TotalTax2 = 0>
				<cfif Total1 GT 0>
					<cfif Taxable Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax4/100))>
						</cfif>
					<cfelseif Taxable Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax4/100))>
						</cfif>
					</cfif>
				</cfif>
				<cfif Total2 GT 0>
					<cfif Taxable2 Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax4/100))>
						</cfif>
					<cfelseif Taxable2 Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax4/100))>
						</cfif>
					</cfif>
				</cfif>
				<cfset MyTotalTax = MyTotalTax + TotalTax1 - TotalTax2>
				<cfset MyTotalBill = MyTotalBill + Total1 - Total2>
			</cfif>
		</cfloop>
<!--- Full Amount Next Billing --->
	<cfelseif BillMethod Is 3>
		<cfset MyTotalTax = 0>
		<cfset MyTotalBill = 0>
		<cfquery name="GetDetails" datasource="#pds#">
			SELECT A.AccntPlanID, A.POPID, P.RecurringAmount, P.RecurDiscount, 
			P.Taxable, P.Taxable2, L.Tax1, L.Tax2, L.Tax3, L.Tax4, 
			L.Tax1Type, L.Tax2Type, L.Tax3Type, L.Tax4Type, A.AccountID, 
			A.Taxable 
			FROM AccntPlans A, Plans P, POPS L 
			WHERE A.PlanID = P.PlanID 
			AND A.POPID = L.POPID 
			AND A.NextDueDate < #CreateODBCDateTime(WhenRun)# 
			AND A.AccountID In (#AllTheIDs#) 
		</cfquery>
		<cfloop query="GetDetails">
			<cfif Taxable Is 1>
				<cfset Total1 = RecurringAmount>
				<cfset Total2 = RecurDiscount>
				<cfset TotalTax1 = 0>
				<cfset TotalTax2 = 0>
				<cfif Total1 GT 0>
					<cfif Taxable Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax1 = (RecurringAmount*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax1 = (RecurringAmount*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax1 = (RecurringAmount*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax1 = (RecurringAmount*(Tax4/100))>
						</cfif>
					<cfelseif Taxable Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax1 = (RecurringAmount*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax1 = (RecurringAmount*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax1 = (RecurringAmount*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax1 = (RecurringAmount*(Tax4/100))>
						</cfif>
					</cfif>
				</cfif>
				<cfif Total2 GT 0>
					<cfif Taxable2 Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax2 = (RecurDiscount*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax2 = (RecurDiscount*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax2 = (RecurDiscount*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax2 = (RecurDiscount*(Tax4/100))>
						</cfif>
					<cfelseif Taxable2 Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax2 = (RecurDiscount*(Tax1/100))>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax2 = (RecurDiscount*(Tax2/100))>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax2 = (RecurDiscount*(Tax3/100))>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax2 = (RecurDiscount*(Tax4/100))>
						</cfif>
					</cfif>
				</cfif>
				<cfset MyTotalTax = MyTotalTax + TotalTax1 - TotalTax2>
				<cfset MyTotalBill = MyTotalBill + RecurringAmount - RecurDiscount>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<cfset NextBilling = MyTotalBill + MyTotalTax>
<cfset CustAmount = CustAmount - NextBilling>
<cfset CustAmount = Trim(NumberFormat(CustAmount, '99999999999999.99'))>

<cfif CustAmount LTE 0>
	<cfset SkipThree = 1>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="deactivate4.cfm">
	<cfabort>
</cfif>

<cfif IsDefined("AmntStatus")>
	<cfset StatSet = AmntStatus>
<cfelse>
	<cfset StatSet = "">
</cfif>
<cfif IsDefined("AmntAmount")>
	<cfset StatAmnt = AmntAmount>
<cfelse>
	<cfparam name="StatAmnt" default="#CustAmount#">
</cfif>
<cfif IsDefined("RefundMethod")>
	<cfset TheRefund = RefundMethod>
<cfelse>
	<cfset TheRefund = "Ck">
</cfif>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Account Balance</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif SkipTwo Is 1>
<form method="post" action="deactivate.cfm">
<cfelse>
<form method="post" action="deactivate2.cfm">
</cfif>
	<input type="image" src="images/return.gif" name="GoBack" border="0">
	<cfoutput>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="hidden" name="SkipTwo" value="#SkipTwo#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Account Balance</font></th>
	</tr>
	<form method="post" action="deactivate4.cfm">
		<tr>
			<td bgcolor="#tbclr#">&nbsp;</td>
			<td bgcolor="#tbclr#" align="right">#LSCurrencyFormat(CustBal)#</td>
			<td bgcolor="#tbclr#">Current Credit</td>
		</tr>
		<cfif MyTotalBill GT 0>
			<tr>
				<td bgcolor="#tbclr#" align="right">#LSCurrencyFormat(MyTotalBill)#</td>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tbclr#">Upcoming Billing</td>
			</tr>
		</cfif>
		<cfif MyTotalTax GT 0>
			<tr>
				<td bgcolor="#tbclr#" align="right">#LSCurrencyFormat(MyTotalTax)#</td>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tbclr#">Upcoming Tax</td>
			</tr>
		</cfif>
		<cfif NextBilling GT 0>
			<tr>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tbclr#" align="right">#LSCurrencyFormat(NextBilling)#</td>
				<td bgcolor="#tbclr#">Total Upcoming Billing</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tbclr#" align="right">#LSCurrencyFormat(CustAmount)#</td>
				<td bgcolor="#tbclr#">Final Balance</td>
			</tr>
		</cfif>
		<tr>
			<th bgcolor="#tdclr#"><input type="radio" <cfif StatSet Is "None">checked</cfif> name="AmntStatus" value="None"></th>
			<td bgcolor="#tbclr#" colspan="2">Keep Credit Balance of #LSCurrencyFormat(CustAmount)#</td>
		</tr>
		<tr valign="top">
			<th bgcolor="#tdclr#" rowspan="2"><input type="radio" <cfif StatSet Is "Refund">checked</cfif> name="AmntStatus" value="Refund"></th>
			<td bgcolor="#tdclr#" colspan="2">Refund <input type="text" name="AmntAmount" value="#StatAmnt#" size="10"></td>
		</tr>
		<tr>
			<td bgcolor="#tdclr#" colspan="2">Refund by <select name="RefundMethod">
				<option <cfif TheRefund Is "CA">selected</cfif> value="CA">Cash
				<option <cfif TheRefund Is "CK">selected</cfif> value="Ck">Check
				<option <cfif TheRefund Is "CC">selected</cfif> value="CC">Credit Card
			</select></td>
		</tr>
		<tr>
			<th colspan="3"><input type="image" src="images/continue.gif" name="Step3" border="0"></th>
		</tr>
		<input type="hidden" name="AmntStatus_Required" value="Please select what to do with the credit balance.">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="hidden" name="CreditAmount" value="#CustAmount#">
		<input type="hidden" name="ReturnTo" value="deactivate3.cfm">
		<input type="hidden" name="SkipTwo" value="#SkipTwo#">
		<input type="hidden" name="SkipThree" value="0">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
