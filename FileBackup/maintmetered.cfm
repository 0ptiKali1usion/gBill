<cfsetting enablecfoutputonly="Yes">
<!--- Version 3.2.0 --->
<!--- This pages runs every day and calcultes any meteted charges. --->
<!--- 3.5.0 06/18/99 Changed the dates that are selected to work with sync billing.
		3.4.0 04/15/99 --->
<!--- maintmetered.cfm --->

<cfset DefaultStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
<cfset ImportStartDate = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>

<cfparam name="MessageOutput" default="">

<cfquery NAME="allvs" DATASOURCE="#pds#">
	SELECT * FROM setup 
	WHERE varname = 'DateMask1' 
	OR VarName = 'HoursImport' 
</cfquery>
<cfoutput query="allvs">
	<cfset "#varname#" = #value1#>
</cfoutput>
<cfif IsDefined("Cookie.MyAdminID")>
	<cfquery name="getname" datasource="#pds#">
		SELECT A.FirstName, A.LastName 
		FROM Accounts A, Admin S 
		WHERE A.AccountID = S.AccountID 
		AND S.AdminID = #Cookie.MyAdminID# 
	</cfquery>
	<cfset FName = "#getname.firstname# #getname.lastname#">
<cfelse>
	<cfset FName = "Scheduler">
</cfif>
<cfquery name="GetAuth" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	WHERE AuthType = 1 
	AND LastCompleteAmount < #CreateODBCDateTime(ImportStartDate)# 
	<cfif IsDefined("ID")>
		AND CAuthID = #ID#
	</cfif>
</cfquery>
<cfloop query="GetAuth">
	<cfif IsDate(LastImport)>
		<cfset LIA = CreateDateTime(Year(LastImportAmount),Month(LastImportAmount),Day(LastImportAmount),0,0,0)>
		<cfset TheImport1 = LIA>
	<cfelse>
		<cfset TheImport1 = DefaultStartDate>
	</cfif>
	<cfif IsDate(LastComplete)>
		<cfset LCA = CreateDateTime(Year(LastCompleteAmount),Month(LastCompleteAmount),Day(LastCompleteAmount),0,0,0)>
		<cfset TheImport2 = LCA>
	<cfelse>	
		<cfset TheImport2 = DefaultStartDate>
	</cfif>
	<cfif TheImport1 Is Not TheImport2>
		<cfquery NAME="RemoveOld" DATASOURCE="#pds#">
			DELETE FROM TimeTemp 
			WHERE ToDate2 > #CreateODBCDateTime(TheImport2)# 
			AND CAuthID = #CAuthID# 
		</cfquery>
		<cfquery NAME="SetDate" DATASOURCE="#pds#">
			UPDATE CustomAuth SET 
			LastImportAmount = #CreateODBCDateTime(TheImport2)#, 
			LastCompleteAmount = #CreateODBCDateTime(TheImport2)# 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfquery name="GetNewDates" datasource="#pds#">
			SELECT LastImportAmount, LastCompleteAmount 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfset TheImport1 = GetNewDates.LastImportAmount>
		<cfset TheImport2 = GetNewDates.LastCompleteAmount>
	</cfif>
	<cfset NextTime = DateAdd("d",1,TheImport1)>
	<cfset TimeNow = Now()>
	<cfif TimeNow GTE NextTime>
		<cfquery name="SetNewTime" datasource="#pds#">
			UPDATE CustomAuth SET 
			LastImportAmount = #CreateODBCDateTime(NextTime)# 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
	</cfif>
	<cfset DateCheck1 = CreateDateTime(Year(NextTime),Month(NextTime),Day(NextTime),0,0,0)>
	<cfset DateCheck2 = CreateDateTime(Year(Now()),Month(Now()),Day(Now()),0,0,0)>
	<cfif DateCheck1 LTE DateCheck2>
		<!--- Calculate the daily spans --->
		<cfquery NAME="WhoIsDue" DATASOURCE="#pds#">
			SELECT a.AccountID, c.UserName, s.BaseAmount, Sum(c.AcctSessionTime) AS TotTime, 
			p.TaxDesc1, p.TaxDesc2, p.TaxDesc3, p.TaxDesc4, p.Tax1, p.Tax2, p.Tax3, p.Tax4, 
			s.OverCharge 
			FROM AccountsAuth r, AccntPlans a, Spans s, Pops p, Calls c 
			WHERE r.AccntPlanID = a.AccntPlanID 
			AND a.popid = p.popid 
			AND a.planid = s.planid 
			AND r.UserName = c.UserName 
			AND s.SpanPeriod = 1 
			AND s.SpanUnit = 'Hours' 
			AND c.CallDate < #CreateODBCDateTime(NextTime)# 
			AND c.CallDate >= #CreateODBCDateTime(TheImport1)# 
			AND c.BilledYN = 0 
			AND c.CAuthID = #CAuthID# 
			AND s.OverCharge > 0 
			AND DatePart(dd,a.NextDueDate) = #DatePart("d",(DateAdd("d","0",DateCheck1)))#
			GROUP BY a.AccountID, c.UserName, s.BaseAmount, p.TaxDesc1, p.TaxDesc2, p.TaxDesc3, 
			p.TaxDesc4, p.Tax1, p.Tax2, p.Tax3, p.Tax4, s.OverCharge 
			HAVING Sum(AcctSessionTime) > (s.BaseAmount * 3600)
		</cfquery>
		<cfloop QUERY="WhoIsDue">
			<cfset mytime = (TotTime-(BaseAmount * 3600))/3600>
			<cfset AmountDue = (TotTime-(BaseAmount * 3600))/3600 * OverCharge>
			<cfif Trim(tax1) is "">
				<cfset taxes1 = 0>
			<cfelse>
				<cfset taxes1 = AmountDue * (tax1/100)>
			</cfif>
			<cfif Trim(tax2) is "">
				<cfset taxes2 = 0>
			<cfelse>
				<cfset taxes2 = AmountDue * (tax2/100)>
			</cfif>
			<cfif Trim(tax3) is "">
				<cfset taxes3 = 0>
			<cfelse>
				<cfset taxes3 = AmountDue * (tax3/100)>
			</cfif>
			<cfif Trim(tax4) is "">
				<cfset taxes4 = 0>
			<cfelse>
				<cfset taxes4 = AmountDue * (tax4/100)>
			</cfif>
			<cfquery NAME="Checkfirst" DATASOURCE="#pds#">
				SELECT Login 
				FROM TimeTemp 
				WHERE Login = '#username#' 
				AND TotTime = #TotTime# 
				AND ToDate2 = #yesterday# 
				AND CAuthID = #CAuthID# 
			</cfquery>
			<cfif Checkfirst.recordcount is 0>
				<cfquery name="putin" datasource="#pds#">
					INSERT INTO timetemp (accountid, Login, paccountid, EnteredBy,
					TotTime, FromDate, ToDate2, taxdesc1, taxdesc2, taxdesc3, taxdesc4, 
					tax1, tax2, tax3, tax4, memo1, totamount, totbilled, SpanType, CAuthID) 
					VALUES (#accountid#, '#username#', #accountid#, '#FName#', #TotTime#, 
					#CreateODBCDateTime(lasttime)#, #CreateODBCDateTime(yesterday)#, 
					<cfif Trim(taxdesc1) is "">NULL<cfelse>'#taxdesc1#'</cfif>, 
					<cfif Trim(taxdesc2) is "">NULL<cfelse>'#taxdesc2#'</cfif>, 
					<cfif Trim(taxdesc3) is "">NULL<cfelse>'#taxdesc3#'</cfif>, 
					<cfif Trim(taxdesc4) is "">NULL<cfelse>'#taxdesc4#'</cfif>, 
					<cfif Trim(tax1) is "">NULL<cfelse>#NumberFormat(taxes1, '99999.99')#</cfif>, 
					<cfif Trim(tax2) is "">NULL<cfelse>#NumberFormat(taxes2, '99999.99')#</cfif>, 
					<cfif Trim(tax3) is "">NULL<cfelse>#NumberFormat(taxes3, '99999.99')#</cfif>, 
					<cfif Trim(tax4) is "">NULL<cfelse>#NumberFormat(taxes4, '99999.99')#</cfif>, 
					'#NumberFormat(mytime, '99999.99')# hrs. Over time charge for #LSDateFormat(LastTime, '#datemask1#')# to #LSDateFormat(Yesterday, '#datemask1#')# - #username#', 
					#NumberFormat(AmountDue, '99999.99')#, #OverCharge#, 1, #CAuthID#) 
				</cfquery>
				<cfquery NAME="Updater" DATASOURCE="#pds#">
					UPDATE TimeTemp SET TimeTemp.paccountid = m.primaryid 
					FROM TimeTemp t, Multi m 
					WHERE t.AccountID = m.AccountID 
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Caluclate the Monthly metered customers --->	
		<cfquery name="getmonthlywho" datasource="#pds#">
			SELECT timestore.Login, timestore.AccountID, 
			Pops.taxdesc1, Pops.taxdesc2, Pops.taxdesc3, Pops.taxdesc4, 
			Sum(TotTimeAcc-(TotTimeAllow*3600)) AS TotTime,
			Convert(decimal(8,2),Sum(((tottimeacc-(tottimeallow*3600))/3600.0)*overcharge) ) as totamount,
			Convert(decimal(8,2),Sum((((tottimeacc-(tottimeallow*3600))/3600.0)*overcharge)*(tax1/100)) ) as TaxAmount1,
			Convert(decimal(8,2),Sum((((tottimeacc-(tottimeallow*3600))/3600.0)*overcharge)*(tax2/100)) ) as TaxAmount2,
			Convert(decimal(8,2),Sum((((tottimeacc-(tottimeallow*3600))/3600.0)*overcharge)*(tax3/100)) ) as TaxAmount3,
			Convert(decimal(8,2),Sum((((tottimeacc-(tottimeallow*3600))/3600.0)*overcharge)*(tax4/100)) ) as TaxAmount4,
			Convert(varchar(10),Convert(decimal(8,2),Sum((TotTimeAcc-(TotTimeAllow*3600))/3600.0))) + ' hrs. Over time charge for #LSDateFormat(TheImport1, '#datemask1#')# to #LSDateFormat(NextTime, '#datemask1#')# - ' + timestore.login AS Memo1,
			A.PopID 
			FROM AccntPlans A, Spans, TimeStore, Pops 
			WHERE timestore.SpanID = Spans.SpanID 
			AND A.accountid = timestore.AccountID 
			AND A.popid = pops.popid
			AND timestore.TotTimeAcc > (tottimeallow*3600)
			AND TimeStore.FinishedYN = 0
			AND TimeStore.CAuthID = #CAuthID# 
			AND overcharge > 0
			AND Spans.SpanPeriod = 0
			AND LastBillDate < #CreateODBCDateTime(NextTime)# 
			AND LastBillDate >= #CreateODBCDateTime(TheImport1)# 
			AND DatePart(dd,A.NextDueDate) = #DatePart("d",(DateAdd("d","0",DateCheck1)))#
			GROUP BY timestore.Login, timestore.AccountID, Pops.taxdesc1,
			Pops.taxdesc2, Pops.taxdesc3, Pops.taxdesc4, A.POPID 
			ORDER BY TimeStore.Login, TimeStore.AccountID
		</cfquery>
		<cfloop QUERY="getmonthlywho">
			<cfquery NAME="Checkfirst" DATASOURCE="#pds#">
				SELECT Login 
				FROM TimeTemp 
				WHERE Login = '#login#' 
				AND TotTime = #TotTime# 
				AND ToDate2 = #yesterday# 		
				AND CAuthID = #CAuthID# 
			</cfquery>
			<cfif Checkfirst.recordcount is 0>
				<cfquery name="getdailyinfo" datasource="#pds#">
					INSERT INTO TimeTemp (Login, accountid, taxdesc1, taxdesc2,
					taxdesc3, taxdesc4, FromDate, ToDate2, TotTime, TotAmount, 
					tax1, tax2, tax3, tax4, memo1, EnteredBy, SpanType) 
					VALUES ('#Login#', #accountid#, 
					<cfif trim(taxdesc1) is "">Null<cfelse>'#taxdesc1#'</cfif>, 
					<cfif trim(taxdesc2) is "">Null<cfelse>'#taxdesc2#'</cfif>, 
					<cfif trim(taxdesc3) is "">Null<cfelse>'#taxdesc3#'</cfif>, 
					<cfif trim(taxdesc4) is "">Null<cfelse>'#taxdesc4#'</cfif>, 
					#lasttime#, #yesterday#, #TotTime#, #TotAmount#, 
					<cfif trim(taxAmount1) is "">Null<cfelse>#taxAmount1#</cfif>, 
					<cfif trim(taxAmount2) is "">Null<cfelse>#taxAmount2#</cfif>, 
					<cfif trim(taxAmount3) is "">Null<cfelse>#taxAmount3#</cfif>, 
					<cfif trim(taxAmount4) is "">Null<cfelse>#taxAmount4#</cfif>, 
					'#memo1#', '#fname#', 0)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Calculate the monthly span customers --->
		<cfquery name="getmonthlyspans" datasource="#pds#">
			SELECT timestore.Login, timestore.AccountID, Pops.taxdesc1, Pops.taxdesc2, Pops.taxdesc3, Pops.taxdesc4, 
			Sum(TotTimeAcc-(TotTimeAllow*3600)) AS TotTime,
			Convert	(decimal(8,2),(((Sum(tottimeacc)-(tottimeallow*3600))/3600.0)*overcharge) ) As totamount,
			Convert	(decimal(8,2),((((Sum(tottimeacc)-(tottimeallow*3600))/3600.0)*overcharge)*(tax1/100)) ) As TaxAmount1,
			Convert	(decimal(8,2),((((Sum(tottimeacc)-(tottimeallow*3600))/3600.0)*overcharge)*(tax2/100)) ) As TaxAmount2,
			Convert	(decimal(8,2),((((Sum(tottimeacc)-(tottimeallow*3600))/3600.0)*overcharge)*(tax3/100)) ) As TaxAmount3,
			Convert	(decimal(8,2),((((Sum(tottimeacc)-(tottimeallow*3600))/3600.0)*overcharge)*(tax4/100)) ) As TaxAmount4,
			Convert (varchar(10),Convert (decimal(8,2),(((Sum(TotTimeAcc)-(TotTimeAllow*3600))/3600.0)))) + ' hrs. Over time charge for Oct/01/99 to Oct/31/99 - ' + timestore.login AS Memo1,
			A.PopID 
			FROM AccntPlans A, Spans, TimeStore, Pops 
			WHERE timestore.SpanID = Spans.SpanID 
			AND A.accountid = timestore.AccountID 
			AND A.popid = pops.popid
			AND TimeStore.FinishedYN = 0
			AND TimeStore.CAuthID = #CAuthID# 
			AND OverCharge > 0 
			AND Spans.SpanPeriod = 3
			AND LastBillDate < #CreateODBCDateTime(NextTime)# 
			AND LastBillDate >= #CreateODBCDateTime(TheImport1)# 
			AND DatePart(dd,A.NextDueDate) = #DatePart("d",(DateAdd("d","0",DateCheck1)))#
			GROUP BY timestore.Login, timestore.AccountID, Pops.taxdesc1, POPs.Tax1, Pops.taxdesc2, POPs.Tax2, Pops.Taxdesc3, 
			POPs.Tax3, Pops.taxdesc4, POPs.Tax4, A.POPID, TotTimeAllow, OverCharge 
			HAVING Sum(timestore.TotTimeAcc) > (tottimeallow*3600)
			ORDER BY TimeStore.Login, TimeStore.AccountID
		</cfquery>
		<cfloop QUERY="getmonthlyspans">
			<cfquery NAME="Checkfirst" DATASOURCE="#pds#">
				SELECT Login 
				FROM TimeTemp 
				WHERE Login = '#login#' 
				AND TotTime = #TotTime# 
				AND ToDate2 = #yesterday# 		
				AND CAuthID = #CAuthID# 
			</cfquery>
			<cfif Checkfirst.recordcount is 0>
				<cfquery name="getdailyinfo" datasource="#pds#">
					INSERT INTO TimeTemp (Login, accountid, taxdesc1, taxdesc2,
					taxdesc3, taxdesc4, FromDate, ToDate2, TotTime, TotAmount, 
					tax1, tax2, tax3, tax4, memo1, EnteredBy, SpanType) 
					VALUES ('#Login#', #accountid#, 
					<cfif trim(taxdesc1) is "">Null<cfelse>'#taxdesc1#'</cfif>, 
					<cfif trim(taxdesc2) is "">Null<cfelse>'#taxdesc2#'</cfif>, 
					<cfif trim(taxdesc3) is "">Null<cfelse>'#taxdesc3#'</cfif>, 
					<cfif trim(taxdesc4) is "">Null<cfelse>'#taxdesc4#'</cfif>, 
					#lasttime#, #yesterday#, #TotTime#, #TotAmount#, 
					<cfif trim(taxAmount1) is "">Null<cfelse>#taxAmount1#</cfif>, 
					<cfif trim(taxAmount2) is "">Null<cfelse>#taxAmount2#</cfif>, 
					<cfif trim(taxAmount3) is "">Null<cfelse>#taxAmount3#</cfif>, 
					<cfif trim(taxAmount4) is "">Null<cfelse>#taxAmount4#</cfif>, 
					'#memo1#', '#fname#', 0)
				</cfquery>
			</cfif>
		</cfloop>
		<cfquery NAME="Updater" DATASOURCE="#pds#">
			UPDATE TimeTemp SET TimeTemp.paccountid = m.primaryid 
			FROM TimeTemp t, multi m 
			WHERE t.accountid = m.accountid
		</cfquery>
		<cfquery name="getdailyinfo2" datasource="#pds#">
			UPDATE TimeTemp
			SET TimeTemp.Paccountid = TimeTemp.Accountid 
			WHERE TimeTemp.Paccountid is Null
		</cfquery>
		<cfquery NAME="setnewdate" DATASOURCE="#pds#">
			UPDATE CustomAuth SET 
			LastCompleteAmount = #CreateODBCDateTime(NextTime)# 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfset StopNow = 1>
	</cfif>
</cfloop>

<cfquery NAME="allnames" DATASOURCE="#pds#">
	SELECT Login 
	FROM TimeTemp 
	GROUP BY Login 
</cfquery>
<cfif allnames.RecordCount GT 0>
	<cfset thelist = #ValueList(allnames.login)#>
	<cfset strMessage = "The follwing have charges to be approved.<br>#thelist#">
</cfif>

<cfsetting enablecfoutputonly="No">
<cfoutput>
<html>
<head>
<title>Metered Billing</title>
<cfif IsDefined("catchup")>
	<cfif Not IsDefined("stopnow")>
		<META HTTP-EQUIV=REFRESH CONTENT="2; URL=maintmetered.cfm?Catchup=1&RequestTimeout=500">
	</cfif>
</cfif>
</head>
<body>
<cfif IsDefined("strMessage")>
#strMessage#
</cfif>
</body>
</html>
</cfoutput>
 