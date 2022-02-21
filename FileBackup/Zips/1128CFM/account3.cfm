<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is the account wizard. --->
<!---	4.0.0. 8/14/99 --->
<!-- account2.cfm -->

<cfset securepage="account.cfm">
<cfinclude template="security.cfm">
<cfparam name="ProRateCutOffYN" default="0">
<cfquery name="StartOver" datasource="#pds#">
	DELETE FROM 
	AccntTempFin
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="PlanInfo" datasource="#pds#">
	SELECT P.PlanID, P.PlanDesc, P.RecurringAmount, P.RecurDiscount, 
	P.FixedDiscount, P.FixedAmount, P.RAMemo, P.RDMemo, P.FAMemo, 
	P.FDMemo, P.RecurringCycle, AWPayCK, AWPayCD, AWPayCC, AWPayPO, 
	P.ProratePYN, P.SynchBillingYN, P.SynchDays, P.ProrateCutDays, 
	P.Taxable, P.Taxable2, P.Taxable3, P.Taxable4 
	FROM Plans P 
	WHERE PlanID In (#SignUpInfo.SelectPlan#) 
	ORDER BY PlanDesc
</cfquery>
<cfquery name="TaxInfo" datasource="#pds#">
	SELECT Tax1, Tax2, Tax3, Tax4, TaxDesc1, TaxDesc2, TaxDesc3, 
	TaxDesc4, Tax1Type, Tax2Type, Tax3Type, Tax4Type 
	FROM POPs 
	WHERE POPID = #SignUpInfo.POPID# 
</cfquery>
<cfparam name="AllowCD" default="0">
<cfparam name="AllowCk" default="0">
<cfparam name="AllowCC" default="0">
<cfparam name="AllowPO" default="0">
<cfquery name="Accounts" datasource="#pds#">
	SELECT A.*, P.PlanDesc, P.RecurringAmount, P.RecurDiscount, 
	P.FixedDiscount, P.FixedAmount, P.RAMemo, P.RDMemo, P.FAMemo, 
	P.FDMemo, P.RecurringCycle 
	FROM Plans P, AccntTempInfo A 
	WHERE P.PlanID = A.PlanID 
	AND A.AccountID = #AccountID# 
	Order By P.PlanDesc, A.Type 
</cfquery>

<cfsetting enablecfoutputonly="no">
<tr>
	<cfoutput>
		<th bgcolor="#thclr#" colspan="#HowWide#">Billing Informaton</th>
	</cfoutput>
</tr>   
<cfoutput query="SignUpInfo">
	<tr>
		<td bgcolor="#tbclr#" colspan="#HowWide#">#Address1#</td>
	</tr>
	<cfif Trim(Address2) Is Not "">
		<tr>
			<td bgcolor="#tbclr#" colspan="#HowWide#">#Address2#</td>
		</tr>
	</cfif>
	<cfif Trim(Address3) Is Not "">
		<tr>
			<td bgcolor="#tbclr#" colspan="#HowWide#">#Address3#</td>
		</tr>
	</cfif>
	<tr>
		<td bgcolor="#tbclr#" colspan="#HowWide#">#City#, #State# #Zip#</td>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="#HowWide#">#dayphone#&nbsp;</td>
	</tr>
<form method="post" action="account4.cfm">
	<tr>
		<td bgcolor="#thclr#" colspan="#HowWide#">Current Charges</td>
	</tr>
</cfoutput>
<cfsetting enablecfoutputonly="yes">
<cfset CurChrg = 0>
<cfset SubTotal = 0>
<cfset ServsTotal2 = 0>
<cfset GoodsTotal2 = 0>
<cfset ServsTotal = 0>
<cfset GoodsTotal = 0>
<cfset GoodsTax = 0>
<cfset ServsTax = 0>
<cfloop query="PlanInfo">
	<cfif AWPayCk Is 1>
		<cfset AllowCk = 1>
	<cfelse>
		<cfset AllowCk = 0>
	</cfif>
	<cfif AWPayCD Is 1>
		<cfif (SignUpInfo.CheckD2 Is Not "") 
		  AND (SignUpInfo.CheckD3 Is Not "") 
		  AND (SignUpInfo.CheckDigit Is Not "")>
			<cfset AllowCD = 1>
		<cfelse>
			<cfset AllowCD = 0>
		</cfif>
	<cfelse>
		<cfset AllowCD = 0>
	</cfif>
	<cfif AWPayCC Is 1>
		<cfif (SignUpInfo.CCType Is Not "")
		  AND (SignUpInfo.CCNum Is Not "") 
		  AND (SignUpInfo.CCMon Is Not "")
		  AND (SignUpInfo.CCYear IS Not "")>
			<cfset AllowCC = 1>
		<cfelse>
			<cfset AllowCC =0>
		</cfif>
	<cfelse>
		<cfset AllowCC = 0>
	</cfif>
	<cfif AWPayPO Is 1>
		<cfif (SignUpInfo.PONum Is Not "")>
			<cfset AllowPO = 1>
		<cfelse>
			<cfset AllowPO = 0>
		</cfif>
	<cfelse>
		<cfset AllowP0 = 0>
	</cfif>
	<cfif SynchBillingYN Is 1>
		<cfset SynchTo = SynchDays>
		<cfset CurDay = DatePart("d",Now())>
		<cfset SynchDay = 32>
		<cfset LowDay = 32>
		<cfloop index="B4" list="#SynchTo#">
			<cfif (B4 GTE CurDay) AND (B4 LT SynchDay)>
				<cfset SynchDay = B4>
			</cfif>
			<cfif B4 LT LowDay>
				<cfset LowDay = B4>
			</cfif>
		</cfloop>
		<cfif SynchDay Is 32>
			<cfset SynchDay = LowDay>
		</cfif>
		<cfif SynchDay GT DaysInMonth(Now())>
			<cfset SynchDay = DaysInMonth(Now())>
		</cfif>
		<cfif SynchDay LT 1>
			<cfset SynchDay = 1>
		</cfif>
		<cfset ProrateCutDays = 0>
	<cfelse>
		<cfset SynchDay = DatePart("d",Now())>
	</cfif>
	<cfif ProratePYN Is 1>
		<cfset ProRateYN = 1>
		<cfset TodayDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
		<cfset NextDue = CreateDateTime(Year(Now()),Month(Now()),SynchDay,0,0,0)>
		<cfif TodayDate Is NextDue>
			<cfset CurRA = RecurringAmount>
			<cfset CurRD = RecurDiscount>
			<cfset ProRateYN = 0>
			<cfset NextDue = DateAdd("m",RecurringCycle,NextDue)>
			<cfset NumDays = 100>
		<cfelse>
			<cfif NextDue LT TodayDate>
				<cfset NextDue = DateAdd("m",1,NextDue)>
			</cfif>
			<cfset NextDue2 = DateAdd("m",RecurringCycle,NextDue)>
			<cfset NumDays = DateDiff("d",TodayDate,NextDue)>
			<cfset NumDays2 = DateDiff("d",NextDue,NextDue2)>
			<cfset CostPerDayRA = RecurringAmount/NumDays2>
			<cfset CostPerDayRD = RecurDiscount/NumDays2>
			<cfset CurRA = NumDays * CostPerDayRA>
			<cfset CurRD = NumDays * CostPerDayRD>
		</cfif>
	<cfelse>
		<cfset ProRateYN = 0>
		<cfset CurRA = RecurringAmount>
		<cfset CurRD = RecurDiscount>
		<cfset NextDue = CreateDateTime(Year(Now()),Month(Now()),SynchDay,0,0,0)>
		<cfif NextDue GT Now()>
			<cfset TodayDate = DateAdd("m",-1,NextDue)>
		<cfelse>
			<cfset TodayDate = NextDue>
			<cfset NextDue = DateAdd("m",1,NextDue)>
		</cfif>
		<cfset NumDays = DateDiff("d",TodayDate,NextDue)>
	</cfif>
	<cfset EndNextDue = NextDue>
	<cfset "EndNextDue#PlanID#" = NextDue>
	<cfoutput>
	<tr>
		<td bgcolor="#tbclr#" colspan="#HowWide#">#PlanDesc#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Pay By</td>
		<cfset SelectedYet = 0>
		<td bgcolor="#tdclr#"><cfif AllowCk Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayByCur#PlanID#" value="CK">Check/ Cash</cfif>
			<cfif AllowCC Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayByCur#PlanID#" value="CC">Credit Card</cfif>
			<cfif AllowCD Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayByCur#PlanID#" value="CD">Check Debit</cfif>
			<cfif AllowPO Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayByCur#PlanID#" value="PO">Purchase Order</cfif></td>
	</tr>
	<input type="hidden" name="PayByCur#PlanID#_Required" value="Please select the payment method for the current amount.">
	</cfoutput>
	<cfif CurRA GT 0>
		<cfset CurChrg = CurChrg + CurRA>
		<cfset SubTotal = SubTotal + CurRA>
		<cfif (Taxable Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal = ServsTotal + CurRA>
			<cfset ServsTotal2 = ServsTotal2 + CurRA>
		<cfelseif (Taxable Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal = GoodsTotal + CurRA>
			<cfset GoodsTotal2 = GoodsTotal2 + CurRA>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">#LSCurrencyFormat(CurRA)#</td>
			<cfif ProRateYN Is 1>
				<cfset DispDate = DateAdd("s",-1,NextDue)>
				<cfset MemoStr = RAMemo & "  Prorated for #LSDateFormat(TodayDate, '#DateMask1#')# to #LSDateFormat(DispDate, '#DateMask1#')#.">
				<cfset TheEndDate = NextDue>
			<cfelse>
				<cfset DispDate = DateAdd("s",-1,NextDue)>
				<cfset MemoStr = RAMemo & "  #LSDateFormat(TodayDate, '#DateMask1#')# to #LSDateFormat(DispDate, '#DateMask1#')#.">
				<cfset TheEndDate = EndNextDue>
			</cfif>
			<td>#MemoStr#</td>
		</tr>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO AccntTempFin 
			(AccountID, PlanID, TransAmount, TransMemo, TransactionType, StartDate, EndDate) 
			VALUES 
			(#AccountID#, #PlanID#, #CurRA#, '#MemoStr#', 'RA', #TodayDate#, #TheEndDate#)
		</cfquery>
		<cfif NumDays LT ProrateCutDays>
			<cfset CurChrg = CurChrg + RecurringAmount>
			<cfset SubTotal = SubTotal + RecurringAmount>
			<cfif (Taxable Is 1) AND (SignUpInfo.Taxfree Is 0)>
				<cfset ServsTotal = ServsTotal + RecurringAmount>
				<cfset ServsTotal2 = ServsTotal2 + RecurringAmount>
			<cfelseif (Taxable Is 2) AND (SignUpInfo.Taxfree Is 0)>
				<cfset GoodsTotal = GoodsTotal + RecurringAmount>
				<cfset GoodsTotal2 = GoodsTotal2 + RecurringAmount>
			</cfif>
			<cfset "EndNextDue#PlanID#" = DateAdd("m",RecurringCycle,NextDue)>
			<cfset EndNextDue = DateAdd("m",RecurringCycle,NextDue)>
			<cfset DispDate = DateAdd("s",-1,EndNextDue)>
			<tr bgcolor="#tbclr#">
				<td align="right">#LSCurrencyFormat(RecurringAmount)#</td>
				<td>#RAMemo#&nbsp;#LSDateFormat(NextDue, '#DateMask1#')# to #LSDateFormat(DispDate, '#DateMask1#')#</td>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TransactionType, StartDate, EndDate) 
					VALUES 
					(#AccountID#, #PlanID#, #RecurringAmount#, '#RAMemo# #LSDateFormat(NextDue, '#DateMask1#')# to #LSDateFormat(EndNextDue, '#DateMask1#')#','RA', #NextDue#, #EndNextDue#)
				</cfquery>
			</tr>
		</cfif>
		</cfoutput>
	</cfif>
	<cfif (FixedAmount GT 0) AND (SignUpInfo.WaiveA Is Not 1)>
		<cfset CurChrg = CurChrg + FixedAmount>
		<cfset SubTotal = SubTotal + FixedAmount>
		<cfif (Taxable3 Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal = ServsTotal + FixedAmount>
			<cfset ServsTotal2 = ServsTotal2 + FixedAmount>
		<cfelseif (Taxable3 Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal = GoodsTotal + FixedAmount>
			<cfset GoodsTotal2 = GoodsTotal2 + FixedAmount>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">#LSCurrencyFormat(FixedAmount)#</td>
			<td>#FAMemo#&nbsp;</td>
		</tr>
		</cfoutput>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO AccntTempFin 
			(AccountID, PlanID, TransAmount, TransMemo, TransactionType) 
			VALUES 
			(#AccountID#, #PlanID#, #FixedAmount#, '#FAMemo#', 'FA')
		</cfquery>
	</cfif>
	<cfif CurRD GT 0>
		<cfset CurChrg = CurChrg - CurRD>
		<cfset SubTotal = SubTotal - CurRD>
		<cfif (Taxable2 Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal = ServsTotal - CurRD>
			<cfset ServsTotal2 = ServsTotal2 - CurRD>
		<cfelseif (Taxable2 Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal = GoodsTotal - CurRD>
			<cfset GoodsTotal2 = GoodsTotal2 - CurRD>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">-#LSCurrencyFormat(CurRD)#</td>
			<cfif ProRateYN is 1>
				<cfset MemoStr = RDMemo & " Prorated for #LSDateFormat(TodayDate, '#DateMask1#')# to #LSDateFormat(NextDue, '#DateMask1#')#.">
			<cfelse>
				<cfset MemoStr = RDMemo & "  #LSDateFormat(TodayDate, '#DateMask1#')# to #LSDateFormat(EndNextDue, '#DateMask1#')#.">
			</cfif>
			<td>#MemoStr#</td>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO AccntTempFin 
				(AccountID, PlanID, TransAmount, TransMemo, TransactionType) 
				VALUES 
				(#AccountID#, #PlanID#, #CurRD#, '#MemoStr#', 'RD')
			</cfquery>
		</tr>
		<cfif NumDays LT ProrateCutDays>
			<cfset CurChrg = CurChrg - RecurDiscount>
			<cfset SubTotal = SubTotal - RecurDiscount>
			<cfif (Taxable Is 1) AND (SignUpInfo.Taxfree Is 0)>
				<cfset ServsTotal = ServsTotal - RecurDiscount>
				<cfset ServsTotal2 = ServsTotal2 - RecurDiscount>
			<cfelseif (Taxable Is 2) AND (SignUpInfo.Taxfree Is 0)>
				<cfset GoodsTotal = GoodsTotal - RecurDiscount>
				<cfset GoodsTotal2 = GoodsTotal2 - RecurDiscount>
			</cfif>
			<cfset "EndNextDue#PlanID#" = DateAdd("m",RecurringCycle,NextDue)>
			<cfset EndNextDue = DateAdd("m",RecurringCycle,NextDue)>
			<tr bgcolor="#tbclr#">
				<td align="right">-#LSCurrencyFormat(RecurDiscount)#</td>
				<td>#RDMemo#&nbsp;#LSDateFormat(NextDue, '#DateMask1#')# to #LSDateFormat(EndNextDue, '#DateMask1#')#</td>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #RecurDiscount#, '#RDMemo# #LSDateFormat(NextDue, '#DateMask1#')# to #LSDateFormat(EndNextDue, '#DateMask1#')#', 'RD')
				</cfquery>
			</tr>
		</cfif>
		</cfoutput>
	</cfif>
	<cfif FixedDiscount GT 0>
		<cfset CurChrg = CurChrg - FixedDiscount>
		<cfset SubTotal = SubTotal - FixedDiscount>
		<cfif (Taxable4 Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal = ServsTotal - FixedDiscount>
			<cfset ServsTotal2 = ServsTotal2 - FixedDiscount>
		<cfelseif (Taxable4 Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal = GoodsTotal - FixedDiscount>
			<cfset GoodsTotal2 = GoodsTotal2 - FixedDiscount>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">-#LSCurrencyFormat(FixedDiscount)#</td>
			<td>#FDMemo#&nbsp;</td>
		</tr>
		</cfoutput>
		<cfquery name="InsTrans" datasource="#pds#">
			INSERT INTO AccntTempFin 
			(AccountID, PlanID, TransAmount, TransMemo, TransactionType) 
			VALUES 
			(#AccountID#, #PlanID#, #FixedDiscount#, '#FDMemo#', 'FD')
		</cfquery>
	</cfif>
	
	<!--- Caluculate the Postal Invoice Charge --->
	<cfif SignUpInfo.PostalInv Is 1>
		<cfquery name="PostalInfo" datasource="#pds#">
			SELECT AWChrgPostYN, AWChrgAmount, AWChrgPostRecYN, AWChrgPostTax, AWChrgPostMemo 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfset PChrgPst = 0>
		<cfset PAmount = 0>
		<cfset PChrgRec = 0>
		<cfset PTaxType = "">
		<cfset PMemo = "">		
		<cfloop query="PostalInfo">
			<cfif (AWChrgPostYN Is 1) AND (AWChrgAmount GT PAmount)>
				<cfset PChrgPst = AWChrgPostYN>
				<cfset PAmount = AWChrgAmount>
				<cfset PChrgRec = AWChrgPostRecYN>
				<cfset PTaxType = AWChrgPostTax>
				<cfset PMemo = AWChrgPostMemo>
			</cfif>
		</cfloop>
		<cfif (PChrgPst Is 1) AND (PChrgRec Is 1)>
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td align="right">#LSCurrencyFormat(PAmount)#</td>
					<td>#PMemo#</td>
				</tr>
			</cfoutput>
			<cfquery name="InsTrans" datasource="#pds#">
				INSERT INTO AccntTempFin 
				(AccountID, PlanID, TransAmount, TransMemo, TransactionType) 
				VALUES 
				(#AccountID#, #PlanID#, #PAmount#, '#PMemo#', 'PO')
			</cfquery>
			<cfset CurChrg = CurChrg + PAmount>
			<cfset SubTotal = SubTotal + PAmount>			
			<cfif (PTaxType Is 1) AND (SignUpInfo.Taxfree Is 0)>
				<cfset ServsTotal = ServsTotal + PAmount>
				<cfset ServsTotal2 = ServsTotal2 + PAmount>
			<cfelseif (PTaxType Is 2) AND (SignUpInfo.Taxfree Is 0)>
				<cfset GoodsTotal = GoodsTotal + PAmount>
				<cfset GoodsTotal2 = GoodsTotal2 + PAmount>
			</cfif>
		</cfif>
	</cfif>

	<cfset GoodsTaxCur = 0>
	<cfset ServsTaxCur = 0>
	<cfif ServsTotal GT 0>
		<cfif TaxInfo.Tax1Type Is 0>
			<cfset Tax1Amount = (Int(ServsTotal2 * TaxInfo.Tax1)/100)>
			<cfset ServsTaxCur = ServsTaxCur + Tax1Amount>
			<cfif Tax1Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #Tax1Amount#, '#TaxInfo.TaxDesc1#', 1, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax2Type Is 0>
			<cfset Tax2Amount = (Int(ServsTotal2 * TaxInfo.Tax2)/100)>
			<cfset ServsTaxCur = ServsTaxCur + Tax2Amount>
			<cfif Tax2Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #Tax2Amount#, '#TaxInfo.TaxDesc2#', 2, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax3Type Is 0>
			<cfset Tax3Amount = (Int(ServsTotal2 * TaxInfo.Tax3)/100)>
			<cfset ServsTaxCur = ServsTaxCur + Tax3Amount>
			<cfif Tax3Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #Tax3Amount#, '#TaxInfo.TaxDesc3#', 3, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax4Type Is 0>
			<cfset Tax4Amount = (Int(ServsTotal2 * TaxInfo.Tax4)/100)>
			<cfset ServsTaxCur = ServsTaxCur + Tax4Amount>
			<cfif Tax4Amount GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #Tax4Amount#, '#TaxInfo.TaxDesc4#', 4, 'TX')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfif GoodsTotal GT 0>
		<cfif TaxInfo.Tax1Type Is 1>
			<cfset TaxAmount1 = (Int(GoodsTotal2 * TaxInfo.Tax1)/100)>
			<cfset GoodsTaxCur = GoodsTaxCur + TaxAmount1>
			<cfif TaxAmount1 GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #TaxAmount1#, '#TaxInfo.TaxDesc1#', 1, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax2Type Is 1>
			<cfset TaxAmount2 = (Int(GoodsTotal2 * TaxInfo.Tax2)/100)>
			<cfset GoodsTaxCur = GoodsTaxCur + TaxAmount2>
			<cfif TaxAmount2 GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #TaxAmount2#, '#TaxInfo.TaxDesc2#', 2, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax3Type Is 1>
			<cfset TaxAmount3 = (Int(GoodsTotal2 * TaxInfo.Tax3)/100)>
			<cfset GoodsTaxCur = GoodsTaxCur + TaxAmount3>
			<cfif TaxAmount3 GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #TaxAmount3#, '#TaxInfo.TaxDesc3#', 3, 'TX')
				</cfquery>
			</cfif>
		</cfif>
		<cfif TaxInfo.Tax4Type Is 1>
			<cfset TaxAmount4 = (Int(GoodsTotal2 * TaxInfo.Tax4)/100)> 
			<cfset GoodsTaxCur = GoodsTaxCur + TaxAmount4>
			<cfif TaxAmount4 GT 0>
				<cfquery name="InsTrans" datasource="#pds#">
					INSERT INTO AccntTempFin 
					(AccountID, PlanID, TransAmount, TransMemo, TaxLevel, TransactionType) 
					VALUES 
					(#AccountID#, #PlanID#, #TaxAmount4#, '#TaxInfo.TaxDesc4#', 4, 'TX')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfset TotalTaxCur = ServsTaxCur + GoodsTaxCur>
	<cfif TotalTaxCur GT 0>
		<cfset SubTotal = SubTotal + TotalTaxCur>
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<td align="right">#LSCurrencyFormat(TotalTaxCur)#</td>
				<td>Tax - #PlanDesc#</td>
			</tr>
		</cfoutput>	
	</cfif>
	<cfoutput>
	<tr bgcolor="#tbclr#">
		<td align="right">#LSCurrencyFormat(SubTotal)#</td>
		<td>Amount due for #PlanDesc#</td>
	</tr>
	</cfoutput>
	<cfset SubTotal = 0>
	<cfset TotalTaxCur = 0>
	<cfset GoodsTotal2 = 0>
	<cfset ServsTotal2 = 0>
</cfloop>
<cfif ServsTotal GT 0>
	<cfif TaxInfo.Tax1Type Is 0>
		<cfset ServsTax = ServsTax + (Int(ServsTotal * TaxInfo.Tax1)/100)>
	</cfif>
	<cfif TaxInfo.Tax2Type Is 0>
		<cfset ServsTax = ServsTax + (Int(ServsTotal * TaxInfo.Tax2)/100)>
	</cfif>
	<cfif TaxInfo.Tax3Type Is 0>
		<cfset ServsTax = ServsTax + (Int(ServsTotal * TaxInfo.Tax3)/100)>
	</cfif>
	<cfif TaxInfo.Tax4Type Is 0>
		<cfset ServsTax = ServsTax + (Int(ServsTotal * TaxInfo.Tax4)/100)>
	</cfif>
</cfif>
<cfif GoodsTotal GT 0>
	<cfif TaxInfo.Tax1Type Is 1>
		<cfset GoodsTax = GoodsTax + (Int(GoodsTotal * TaxInfo.Tax1)/100)>
	</cfif>
	<cfif TaxInfo.Tax2Type Is 1>
		<cfset GoodsTax = GoodsTax + (Int(GoodsTotal * TaxInfo.Tax2)/100)>
	</cfif>
	<cfif TaxInfo.Tax3Type Is 1>
		<cfset GoodsTax = GoodsTax + (Int(GoodsTotal * TaxInfo.Tax3)/100)>
	</cfif>
	<cfif TaxInfo.Tax4Type Is 1>
		<cfset GoodsTax = GoodsTax + (Int(GoodsTotal * TaxInfo.Tax4)/100)>
	</cfif>
</cfif>
<cfset TotalTax= ServsTax + GoodsTax>
<cfif TotalTax GT 0>
	<tr bgcolor="#tdclr#">
		<td align="right">#LSCurrencyFormat(TotalTax)#</td>
		<td>Total Tax</td>
	</tr>
	<cfset CurChrg = CurChrg + TotalTax>
</cfif>
<cfoutput>	
	<tr>
		<td align="right" bgcolor="#tdclr#">#LSCurrencyFormat(CurChrg)#</td>
		<td bgcolor="#tdclr#">Total amount due.</td>
	</tr>
	<tr>
		<th colspan="#HowWide#" bgcolor="#thclr#">Payment Info</th>
	</tr>
</cfoutput>  
<cfloop query="PlanInfo">
	<cfif AWPayCk Is 1>
		<cfset AllowCk = 1>
	<cfelse>
		<cfset AllowCk = 0>
	</cfif>
	<cfif AWPayCD Is 1>
		<cfif (SignUpInfo.CheckD2 Is Not "") 
		  AND (SignUpInfo.CheckD3 Is Not "") 
		  AND (SignUpInfo.CheckDigit Is Not "")>
			<cfset AllowCD = 1>
		<cfelse>
			<cfset AllowCD = 0>
		</cfif>
	<cfelse>
		<cfset AllowCD = 0>
	</cfif>
	<cfif AWPayCC Is 1>
		<cfif (SignUpInfo.CCType Is Not "")
		  AND (SignUpInfo.CCNum Is Not "") 
		  AND (SignUpInfo.CCMon Is Not "")
		  AND (SignUpInfo.CCYear IS Not "")>
			<cfset AllowCC = 1>
		<cfelse>
			<cfset AllowCC =0>
		</cfif>
	<cfelse>
		<cfset AllowCC = 0>
	</cfif>
	<cfif AWPayPO Is 1>
		<cfif (SignUpInfo.PONum Is Not "")>
			<cfset AllowPO = 1>
		<cfelse>
			<cfset AllowPO = 0>
		</cfif>
	<cfelse>
		<cfset AllowP0 = 0>
	</cfif>
	<cfif SynchBillingYN Is 1>
		<cfset SynchTo = SynchDays>
		<cfset CurDay = DatePart("d",Now())>
		<cfset SynchDay = 32>
		<cfset LowDay = 32>
		<cfloop index="B4" list="#SynchTo#">
			<cfif (B4 GTE CurDay) AND (B4 LT SynchDay)>
				<cfset SynchDay = B4>
			</cfif>
			<cfif B4 LT LowDay>
				<cfset LowDay = B4>
			</cfif>
		</cfloop>
		<cfif SynchDay Is 32>
			<cfset SynchDay = LowDay>
		</cfif>
		<cfif SynchDay GT DaysInMonth(Now())>
			<cfset SynchDay = DaysInMonth(Now())>
		</cfif>
		<cfif SynchDay LT 1>
			<cfset SynchDay = 1>
		</cfif>
		<cfset ProrateCutDays = 0>
	<cfelse>
		<cfset SynchDay = DatePart("d",Now())>
	</cfif>
	<cfset ServsTotal2 = 0>
	<cfset GoodsTotal2 = 0>
	<cfset GoodsTax2 = 0>
	<cfset ServsTax2 = 0>
	<cfset RecurTot = 0>
	<cfoutput>
	<tr>
		<td colspan="#HowWide#" bgcolor="#tbclr#">#PlanDesc#</td>
	</tr>
	<tr>
		<td align="right" bgcolor="#tbclr#">Pay By</td>
		<cfset SelectedYet = "0">
		<td bgcolor="#tdclr#"><cfif AllowCk Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayBy#PlanID#" value="CK">Check/ Cash</cfif>
			<cfif AllowCC Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayBy#PlanID#" value="CC">Credit Card</cfif>
			<cfif AllowCD Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayBy#PlanID#" value="CD">Check Debit</cfif>
			<cfif AllowPO Is "1"><input type="radio" <cfif SelectedYet Is 0>checked<cfset SelectedYet = 1></cfif> name="PayBy#PlanID#" value="PO">Purchase Order</cfif></td>
	</tr>
	<input type="hidden" name="PayBy#PlanID#_Required" value="Please select the payment method for #PlanDesc#">
	</cfoutput>
	<cfif RecurringAmount GT 0>
		<cfset RecurTot = RecurTot + RecurringAmount>
		<cfif (Taxable Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal2 = ServsTotal2 + RecurringAmount>
		<cfelseif (Taxable Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal2 = GoodsTotal2 + RecurringAmount>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">#LSCurrencyFormat(RecurringAmount)#</td>
			<td>#RAMemo#&nbsp;</td>
		</tr>
		</cfoutput>
	</cfif>
	<cfif RecurDiscount GT 0>
		<cfset RecurTot = RecurTot - RecurDiscount>
		<cfif (Taxable2 Is 1) AND (SignUpInfo.Taxfree Is 0)>
			<cfset ServsTotal2 = ServsTotal2 - RecurDiscount>
		<cfelseif (Taxable2 Is 2) AND (SignUpInfo.Taxfree Is 0)>
			<cfset GoodsTotal2 = GoodsTotal2 - RecurDiscount>
		</cfif>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">-#LSCurrencyFormat(RecurDiscount)#</td>
			<td>#RDMemo#&nbsp;</td>
		</tr>
		</cfoutput>
	</cfif>
	<!--- Caluculate the Postal Invoice Charge --->
	<cfif SignUpInfo.PostalInv Is 1>
		<cfquery name="PostalInfo" datasource="#pds#">
			SELECT AWChrgPostYN, AWChrgAmount, AWChrgPostRecYN, AWChrgPostTax, AWChrgPostMemo 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfset PChrgPst = 0>
		<cfset PAmount = 0>
		<cfset PChrgRec = 0>
		<cfset PTaxType = "">
		<cfset PMemo = "">		
		<cfloop query="PostalInfo">
			<cfif (AWChrgPostYN Is 1) AND (AWChrgAmount GT PAmount)>
				<cfset PChrgPst = AWChrgPostYN>
				<cfset PAmount = AWChrgAmount>
				<cfset PChrgRec = AWChrgPostRecYN>
				<cfset PTaxType = AWChrgPostTax>
				<cfset PMemo = AWChrgPostMemo>
			</cfif>
		</cfloop>
		<cfif (PChrgPst Is 1) AND (PChrgRec Is 1)>
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<td align="right">#LSCurrencyFormat(PAmount)#</td>
					<td>#PMemo#</td>
				</tr>
			</cfoutput>
			<cfset RecurTot = RecurTot + PAmount>
			<cfif (PTaxType Is 1) AND (SignUpInfo.Taxfree Is 0)>
				<cfset ServsTotal2 = ServsTotal2 + PAmount>
			<cfelseif (PTaxType Is 2) AND (SignUpInfo.Taxfree Is 0)>
				<cfset GoodsTotal2 = GoodsTotal2 + PAmount>
			</cfif>
		</cfif>
	</cfif>
	<cfif ServsTotal2 GT 0>
		<cfif TaxInfo.Tax1Type Is 0>
			<cfset ServsTax2 = ServsTax2 + (ServsTotal2 * (TaxInfo.Tax1/100))>
		</cfif>
		<cfif TaxInfo.Tax2Type Is 0>
			<cfset ServsTax2 = ServsTax2 + (ServsTotal2 * (TaxInfo.Tax2/100))>
		</cfif>
		<cfif TaxInfo.Tax3Type Is 0>
			<cfset ServsTax2 = ServsTax2 + (ServsTotal2 * (TaxInfo.Tax3/100))>
		</cfif>
		<cfif TaxInfo.Tax4Type Is 0>
			<cfset ServsTax2 = ServsTax2 + (ServsTotal2 * (TaxInfo.Tax4/100))>
		</cfif>
	</cfif>
	<cfif GoodsTotal2 GT 0>
		<cfif TaxInfo.Tax1Type Is 1>
			<cfset GoodsTax2 = GoodsTax2 + (GoodsTotal2 * (TaxInfo.Tax1/100))>
		</cfif>
		<cfif TaxInfo.Tax2Type Is 1>
			<cfset GoodsTax2 = GoodsTax2 + (GoodsTotal2 * (TaxInfo.Tax2/100))>
		</cfif>
		<cfif TaxInfo.Tax3Type Is 1>
			<cfset GoodsTax2 = GoodsTax2 + (GoodsTotal2 * (TaxInfo.Tax3/100))>
		</cfif>
		<cfif TaxInfo.Tax4Type Is 1>
			<cfset GoodsTax2 = GoodsTax2 + (GoodsTotal2 * (TaxInfo.Tax4/100))>
		</cfif>
	</cfif>
	<cfset TotalTax2 = ServsTax2 + GoodsTax2>	
	<cfif TotalTax2 GT 0>
		<cfoutput>
		<tr bgcolor="#tbclr#">
			<td align="right">#LSCurrencyFormat(TotalTax2)#</td>
			<td>Tax</td>
		</tr>
		</cfoutput>
		<cfset RecurTot = RecurTot + TotalTax2>
	</cfif>
	<cfoutput>	
	<tr bgcolor="#tbclr#">
	</cfoutput>
		<cfif (SynchDay Is 1) OR (SynchDay Is 21)>
			<cfset SynchDayDisp = SynchDay & "st">
		<cfelseif (SynchDay Is 2) OR (SynchDay Is 22)>
			<cfset SynchDayDisp = SynchDay & "nd">
		<cfelseif (SynchDay Is 3) OR (SynchDay Is 23)>
			<cfset SynchDayDisp = SynchDay & "rd">
		<cfelseif SynchDay GTE 24>
			<cfset SynchDayDisp = SynchDay & "th">
		<cfelseif (SynchDay GTE 4) AND (SynchDay LTE 20)>
			<cfset SynchDayDisp = SynchDay & "th">
		</cfif>
		<cfset TheDueDate = Evaluate("EndNextDue#PlanID#")>
	<cfoutput>
		<td bgcolor="#tdclr#" align="right">#LSCurrencyFormat(RecurTot)#</td>
		<td>will be due every <cfif Int(RecurringCycle) Is 1>month<cfelse>#Int(RecurringCycle)# months</cfif> on the #SynchDayDisp# starting #LSDateFormat(TheDueDate, '#DateMask1#')#.</td>
	</tr>
	</cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="no">
	<tr>
		<th colspan="2"><input type="Image" src="images/continue.gif" border="0" name="AlmostDone"></th>
	</tr>
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="MakeBOBAcnt" value="1">
	</cfoutput>
</form>
 