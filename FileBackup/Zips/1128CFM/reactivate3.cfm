<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- Reactivates entire account. --->
<!---	4.0.0 04/19/00 --->
<!-- reactivate3.cfm -->

<cfif GetOpts.ReactAcnt Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif BillMethod Is "1">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="reactivate4.cfm">
	<cfabort>
</cfif>
<cfif Not IsDefined("ReactPlans")>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="reactivate4.cfm">
	<cfabort>
</cfif>

<cfparam name="SubStatus" default="Ignore">
<cfif BillMethod Is 2>
	<cfloop index="B5" list="#ReactPlans#">
		<cfset MyTotalTax = 0>
		<cfset MyTotalBill = 0>
		<cfset NextDueDate = Evaluate("NextDueDate#B5#")>
		<cfquery name="GetDetails" datasource="#pds#">
			SELECT A.AccntPlanID, A.POPID, P.RecurringAmount, P.RecurDiscount, 
			P.Taxable, P.Taxable2, L.Tax1, L.Tax2, L.Tax3, L.Tax4, P.PlanDesc, 
			L.Tax1Type, L.Tax2Type, L.Tax3Type, L.Tax4Type, A.AccountID, 
			A.Taxable, A.NextDueDate, P.RecurringCycle, L.TaxDesc1, L.TaxDesc2, 
			L.TaxDesc3, L.TaxDesc4 
			FROM AccntPlans A, Plans P, POPS L 
			WHERE A.ReactivateTo = P.PlanID 
			AND A.POPID = L.POPID 
			AND A.AccntPlanID = #B5# 
		</cfquery>
		<cfloop query="GetDetails">
			<cfset "PlanDesc#B5#" = PlanDesc>
			<cfif Taxable Is 1>
				<cfset TheNextDueDate = Evaluate("NextDueDate#B5#")>
				<cfset Date2 = CreateDateTime(Year(TheNextDueDate),Month(TheNextDueDate),Day(TheNextDueDate),0,0,0)>
				<cfset "LastDate#B5#" = DateAdd("s",-1,Date2)>
				<cfset Date1 = CreateDateTime(Year(WhenRun),Month(WhenRun),Day(WhenRun),0,0,0)>
				<cfset RAmount1 = RecurringAmount/(RecurringCycle*(365/12))>
				<cfset DAmount2 = RecurDiscount/(RecurringCycle*(365/12))>
				<cfset NumDays = DateDiff("d",Date1,Date2) - 1>

				<cfset "Tax1Desc#B5#" = TaxDesc1>
				<cfset "Tax2Desc#B5#" = TaxDesc2>
				<cfset "Tax3Desc#B5#" = TaxDesc3>
				<cfset "Tax4Desc#B5#" = TaxDesc4>

				<cfset Total1 = RAmount1*NumDays>
				<cfset Total1 = Trim(NumberFormat(Total1, '9999999999999999999.99'))>
				<cfset Total2 = DAmount2*NumDays>
				<cfset Total2 = Trim(NumberFormat(Total2, '9999999999999999999.99'))>
				
				<cfset TotalTaxType1 = 0>
				<cfset TotalTaxType2 = 0>
				<cfset TotalTaxType3 = 0>
				<cfset TotalTaxType4 = 0>
				
				<cfset TotalTax1 = 0>
				<cfset TotalTax2 = 0>
				<cfif Total1 GT 0>
					<cfif Taxable Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax1/100))>
							<cfset TotalTaxType1 = TotalTaxType1 + TotalTax1>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax2/100))>
							<cfset TotalTaxType2 = TotalTaxType2 + TotalTax1>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax3/100))>
							<cfset TotalTaxType3 = TotalTaxType3 + TotalTax1>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax1 = (Total1*(Tax4/100))>
							<cfset TotalTaxType4 = TotalTaxType4 + TotalTax1>
						</cfif>
					<cfelseif Taxable Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax1/100))>
							<cfset TotalTaxType1 = TotalTaxType1 + TotalTax1>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax2/100))>
							<cfset TotalTaxType2 = TotalTaxType2 + TotalTax1>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax3/100))>
							<cfset TotalTaxType3 = TotalTaxType3 + TotalTax1>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax1 = (Total1*(Tax4/100))>
							<cfset TotalTaxType4 = TotalTaxType4 + TotalTax1>
						</cfif>
					</cfif>
				</cfif>
				<cfif Total2 GT 0>
					<cfif Taxable2 Is 1>
						<cfif Tax1Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax1/100))>
							<cfset TotalTaxType1 = TotalTaxType1 + TotalTax2>
						</cfif>
						<cfif Tax2Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax2/100))>
							<cfset TotalTaxType2 = TotalTaxType2 + TotalTax2>
						</cfif>
						<cfif Tax3Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax3/100))>
							<cfset TotalTaxType3 = TotalTaxType3 + TotalTax2>
						</cfif>
						<cfif Tax4Type Is 0>
							<cfset TotalTax2 = (Total2*(Tax4/100))>
							<cfset TotalTaxType4 = TotalTaxType4 + TotalTax2>
						</cfif>
					<cfelseif Taxable2 Is 2>
						<cfif Tax1Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax1/100))>
							<cfset TotalTaxType1 = TotalTaxType1 + TotalTax2>
						</cfif>
						<cfif Tax2Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax2/100))>
							<cfset TotalTaxType2 = TotalTaxType2 + TotalTax2>
						</cfif>
						<cfif Tax3Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax3/100))>
							<cfset TotalTaxType3 = TotalTaxType3 + TotalTax2>
						</cfif>
						<cfif Tax4Type Is 1>
							<cfset TotalTax2 = (Total2*(Tax4/100))>
							<cfset TotalTaxType4 = TotalTaxType4 + TotalTax2>
						</cfif>
					</cfif>
				</cfif>
				<cfset MyTotalTax = TotalTaxType1 + TotalTaxType2 - TotalTaxType3 + TotalTaxType4>
				<cfset MyTotalBill = MyTotalBill + Total1 - Total2>
				
				<cfset "Tax1Amount#B5#" = TotalTaxType1>
				<cfset "Tax2Amount#B5#" = TotalTaxType2>
				<cfset "Tax3Amount#B5#" = TotalTaxType3>
				<cfset "Tax4Amount#B5#" = TotalTaxType4>
				
				<cfif MyTotalBill LT 0>
					<cfset "MyTotalBill#B5#" = 0>
				<cfelse>
					<cfset "MyTotalBill#B5#" = MyTotalBill>
				</cfif>
				<cfif MyTotalTax LT 0>
					<cfset "MyTotalTax#B5#" = 0>
				<cfelse>
					<cfset "MyTotalTax#B5#" = MyTotalTax>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>
<cfif IsDefined("ChargReactFee")>
	<cfif IsNumeric("ReactFee")>
		<cfset ReactivationFee = ReactFee>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Account Balance</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="reactivate2.cfm">
	<input type="image" src="images/return.gif" name="GoBack" border="0">
	<cfoutput>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="Hidden" name="ReactFee" value="#ReactFee#">
		<input type="Hidden" name="ReactPlans" value="#ReactPlans#">
		<cfif IsDefined("ChargReactFee")>
			<input type="Hidden" name="ChargReactFee" value="#ChargReactFee#">
		</cfif>
	</cfoutput>
	<cfloop index="B5" list="#ReactPlans#">
		<cfset DispStr = Evaluate("NextDueDate#B5#")>
		<cfoutput><input type="Hidden" name="NextDueDate#B5#" value="#DispStr#"></cfoutput>
	</cfloop>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="5" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Final Confirmation</font></th>
	</tr>
	<form method="post" action="reactivate4.cfm">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
		<input type="Hidden" name="ReactFee" value="#ReactFee#">
		<input type="Hidden" name="ReactPlans" value="#ReactPlans#">
		<input type="Hidden" name="AllIDs" value="#ReactPlans#">
		<cfif IsDefined("ChargReactFee")>
			<input type="Hidden" name="ChargReactFee" value="#ChargReactFee#">
		</cfif>
		<tr bgcolor="#thclr#">
			<th>Plan</th>
			<th>Next Due</th>
			<th>Prorate</th>
			<th>Tax</th>
			<th>Reason</th>
		</tr>
</cfoutput>
		<cfset PageTotal = 0>
		<cfset PageTax = 0>
		<cfloop index="B5" list="#ReactPlans#">
			<cfset DispStr = Evaluate("NextDueDate#B5#")>
			<cfset DispDes = Evaluate("PlanDesc#B5#")>
			<cfset DispAmt = Evaluate("MyTotalBill#B5#")>
			<cfset DispTax = Evaluate("MyTotalTax#B5#")>
			<cfset DispDte = Evaluate("LastDate#B5#")>
			<cfset PageTotal = PageTotal + DispAmt>
			<cfset PageTax = PageTax + DispTax>
			<cfset Tax1Descrip = Evaluate("Tax1Desc#B5#")>
			<cfset Tax2Descrip = Evaluate("Tax2Desc#B5#")>
			<cfset Tax3Descrip = Evaluate("Tax3Desc#B5#")>
			<cfset Tax4Descrip = Evaluate("Tax4Desc#B5#")>
			<cfset Tax1Amnt = Evaluate("Tax1Amount#B5#")>
			<cfset Tax2Amnt = Evaluate("Tax2Amount#B5#")>
			<cfset Tax3Amnt = Evaluate("Tax3Amount#B5#")>
			<cfset Tax4Amnt = Evaluate("Tax4Amount#B5#")>
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td>#DispDes#</td>
					<td>#DispStr#</td>
					<td align="right">#LSCurrencyFormat(DispAmt)#</td>
					<td align="right">#LSCurrencyFormat(DispTax)#</td>
					<td bgcolor="#tdclr#"><input type="Text" name="ReactReason#B5#" value="Prorate amount from #LSDateFormat(WhenRun, '#DateMask1#')# to #LSDateFormat(DispDte, '#DateMask1#')#." size="35"></td>
				</tr>
				<input type="Hidden" name="NextDueDate#B5#" value="#DispStr#">
				<input type="Hidden" name="PlanDesc#B5#" value="#DispDes#">
				<input type="Hidden" name="MyTotalBill#B5#" value="#DispAmt#">
				<input type="Hidden" name="MyTotalTax#B5#" value="#DispTax#">
				<input type="Hidden" name="LastDate#B5#" value="#DispDte#">
				<input type="Hidden" name="MyTax1Desc#B5#" value="#Tax1Descrip#">
				<input type="Hidden" name="MyTax2Desc#B5#" value="#Tax2Descrip#">
				<input type="Hidden" name="MyTax3Desc#B5#" value="#Tax3Descrip#">
				<input type="Hidden" name="MyTax4Desc#B5#" value="#Tax4Descrip#">
				<input type="Hidden" name="MyTax1A#B5#" value="#Tax1Amnt#">
				<input type="Hidden" name="MyTax2A#B5#" value="#Tax2Amnt#">
				<input type="Hidden" name="MyTax3A#B5#" value="#Tax3Amnt#">
				<input type="Hidden" name="MyTax4A#B5#" value="#Tax4Amnt#">
			</cfoutput>
		</cfloop>
		<cfif (IsDefined("ChargReactFee")) AND (IsNumeric(ReactFee))>
			<cfset PageTotal = PageTotal + ReactFee>
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td>Reactivation Fee</td>
					<td>&nbsp;</td>
					<td align="right">#LSCurrencyFormat(ReactFee)#</td>
					<td>&nbsp;</td>
					<td bgcolor="#tdclr#"><input type="Text" name="MemoReason" value="#MemoReason#" size="35"></td>
				</tr>
			</cfoutput>
		</cfif>
		<cfif PageTotal GT 0>
			<cfoutput>
				<tr bgcolor="#thclr#">
					<td align="right" colspan="2">Sub Total</td>
					<td align="right">#LSCurrencyFormat(PageTotal)#</td>
					<td align="right">#LSCurrencyFormat(PageTax)#</td>
					<td>&nbsp;</td>
					<cfset GTotal = PageTotal + PageTax>
				</tr>
				<tr bgcolor="#thclr#">
					<td align="right" colspan="3">Grand Total</td>
					<td align="right">#LSCurrencyFormat(GTotal)#</td>
					<td>&nbsp;</td>
				</tr>
			</cfoutput>
		</cfif>
		<cfoutput>
			<tr>
				<th colspan="5"><input type="Image" src="images/continue.gif" border="0" name="Step4"></th>
			</tr>
		</cfoutput>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 