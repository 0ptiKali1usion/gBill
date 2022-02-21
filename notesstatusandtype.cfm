<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the date selector for cancelled accounts. --->
<!---	4.0.0 09/07/99 --->
<!--- cancelacc.cfm --->

<cfinclude template="security.cfm">

<cfset ReportSecure = "notesstatusandtype.cfm">
<cfset ReportID = 910>
<cfset LetterID = 0>
<cfset ShowFilters = "1">
<cfset ShowDateRange = "1">
<cfset ShowLogicNameA = "1">
<cfset ShowLogicNameB = "0">
<cfset ShowPPDS = "0">
<cfset CriteriaToSearch = "Status,Type">
<cfset ReturnPage = "notesstatusandtype.cfm">
<cfset SendHeader = "Name,City">
<cfset SendFields = "Name,City">
<cfset ReportTitle = "Search by status and type">
<cfset HowWide = "2">
<cfset FirstDropDown = "LastName;Last Name,FirstName;First Name,Login;gBill Login,Company,Address,City,DayPhone;Home Phone,Evephone;Work Phone,Accountid;User ID">

<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(SupportDate) as MinDate 
	FROM Support 
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
		(LastName, FirstName, City, AccountID, Phone, Company, ReportDate, ReportID, 
		AdminID, ReportTitle, CreateDate, NoteStatus, NoteType) 
		Select A.LastName, A.FirstName, A.City, A.AccountID, A.Dayphone, A.Company, S.SupportDate, 
	    910, #MyAdminID#, '#LSDateFormat(Date1, '#DateMask1#')# and #LSDateFormat(Date2, '#DateMask1#')#', #Now()#,
		S.NoteStatus, S.NoteType  
		FROM Accounts A, TransActions T, Support S 
		WHERE A.AccountID = S.AccountID 
		AND A.AccountID Is NOT Null 
		AND S.SupportDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
		AND S.SupportDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'}
		<cfif Status GT 0>AND S.NoteStatus = #Status#</cfif>
		<cfif Type GT 0>AND S.NoteType = #Type#</cfif>  
		AND <cfif FirstParam Is Not "AccountID">A.#FirstParam#<cfelse>Convert(varchar(10),A.AccountID)</cfif>
		<cfif FirstAction Is "Starts">Like '#FirstField#%' 
		<cfelseif FirstAction Is "Contains">Like '%#FirstField#%' 
		<cfelseif FirstAction Is "Like">Like '#FirstField#' 
		<cfelseif FirstAction Is "NotStarts">Not Like '#FirstField#%' 
		<cfelseif FirstAction Is "NotContains">Not Like '%#FirstField#%' 
		<cfelseif FirstAction Is "Not">Not Like '#FirstField#' 
		</cfif>
		GROUP BY A.LastName, A.FirstName, A.City, A.AccountID, A.Dayphone, A.Company, S.SupportDate, S.NoteStatus, S.NoteType 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
<cfinclude template="reportpage.cfm">
 