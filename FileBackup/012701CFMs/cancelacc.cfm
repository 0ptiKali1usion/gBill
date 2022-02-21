<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the date selector for cancelled accounts. --->
<!---	4.0.0 09/07/99 --->
<!--- cancelacc.cfm --->

<cfinclude template="security.cfm">

<cfset ReportSecure = "cancelacc.cfm">
<cfset ReportID = 6>
<cfset LetterID = 0>
<cfset ShowFilters = "1">
<cfset ShowDateRange = "1">
<cfset ShowLogicNameA = "1">
<cfset ShowLogicNameB = "0">
<cfset ShowPPDS = "0">
<cfset CriteriaToSearch = "OwedMin,CreditMin">
<cfset ReturnPage = "cancelacc.cfm">
<cfset SendHeader = "Name,City,Cancel Date,Owe,Credit,Reason">
<cfset SendFields = "Name,City,ReportDate,CurBal,CurBal2,ReportHeader">
<cfset ReportTitle = "Cancelled Accounts">
<cfset HowWide = "2">
<cfset FirstDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone,Accountid;User ID">

<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(CancelDate) as MinDate 
	FROM Accounts 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDateDropDnS = LowDate.MinDate>
<cfelse>
	<cfset StartDateDropDnS = Now()>
</cfif>
<cfset StartDateDropDnE = Now()>
<cfset StartDateSelect = CreateDate(Year(Now()),Month(Now()),1)>

<cfif IsDefined("Report.x")>
	<cfset Date1 = CreateDate(FromYear, FromMon, FromDay)>
	<cfset Date2 = CreateDate(ToYear,ToMon,ToDay)>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfquery name="getaccounts" datasource="#pds#">
		INSERT INTO GrpLists 
		(LastName, FirstName, City, AccountID, Phone, Company, ReportDate, ReportHeader, ReportID, 
		AdminID, ReportTitle, CreateDate, CurBal, CurBal2) 
		Select A.LastName, A.FirstName, A.City, A.AccountID, A.Dayphone, A.Company, A.CancelDate, 
		A.CancelReason, 6, #MyAdminID#, 'Cancelled between #LSDateFormat(Date1, '#DateMask1#')# and #LSDateFormat(Date2, '#DateMask1#')#', #Now()#, 
		Sum(T.DebitLeft), Sum(T.CreditLeft)  
		FROM Accounts A, TransActions T 
		WHERE A.AccountID *= T.AccountID 
		AND A.AccountID Is NOT Null 
		AND A.CancelDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
		AND A.CancelDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
		AND A.CancelYN = 1 
		AND <cfif FirstParam Is Not "AccountID">A.#FirstParam#<cfelse>Convert(varchar(10),A.AccountID)</cfif>
		<cfif FirstAction Is "Starts">Like '#FirstField#%' 
		<cfelseif FirstAction Is "Contains">Like '%#FirstField#%' 
		<cfelseif FirstAction Is "Like">Like '#FirstField#' 
		<cfelseif FirstAction Is "NotStarts">Not Like '#FirstField#%' 
		<cfelseif FirstAction Is "NotContains">Not Like '%#FirstField#%' 
		<cfelseif FirstAction Is "Not">Not Like '#FirstField#' 
		</cfif>
		GROUP BY A.LastName, A.FirstName, A.City, A.AccountID, A.Dayphone, A.Company, A.CancelDate, 
		A.CancelReason 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		CurBal = 0 
		WHERE CurBal Is Null 
		AND ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		CurBal2 = 0 
		WHERE CurBal2 Is Null 
		AND ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif OwedMin Is Not "NA" OR CreditMin Is Not "NA">
		<cfif OwedMin Is Not "NA">
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE ReportID = #ReportID# 
				AND AdminID = #MyAdminID# 
				AND CurBal < #OwedMin# 
				AND CurBal2 = 0 
			</cfquery>
		</cfif>
		<cfif CreditMin Is Not "NA">
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE ReportID = #ReportID# 
				AND AdminID = #MyAdminID# 
				AND CurBal2 < #CreditMin# 
				AND CurBal = 0 
			</cfquery>
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="No">
<cfinclude template="reportpage.cfm">
 