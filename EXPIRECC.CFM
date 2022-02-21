<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a report of credit cards with problem data. --->
<!--- 4.0.0 09/08/99 --->
<!--- This is ReportID of 10 --->
<!--- expirecc.cfm --->

<cfinclude template="security.cfm">
<cfparam name="WarnExpMonth" default="2">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 10 
	</cfquery>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfset TheMonth = Now()>
	<cfset TheMon = DateFormat(TheMonth, 'MM')>
	<cfset TheYear = Year(Now())>
	<cfquery name="getcc" datasource="#pds#">
		SELECT C.*, A.FirstName, A.LastName, A.DayPhone, A.Company 
		FROM PayByCC C, Accounts A 
		WHERE C.AccountID = A.AccountID 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop query="getcc">
		<cfset OncePer = 0>
		<cfif IsNumeric(CCYear) AND IsNumeric(CCMonth)>
			<cfif (CCMonth gt 0) AND (CCMonth lt 13)>
				<cfset CardExpire = CreateDate(CCYear,CCMonth,1)>
				<cfif (CardExpire gt Now()) AND (CardExpire lt (DateAdd("m",WarnExpMonth,Now())) )>
					<cfif (ListFind(ProbType,1)) OR (ListFind(ProbType,0))>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT AccountID 
							FROM GrpLists 
							WHERE AdminID = #MyAdminID# 
							AND ReportID = 10 
							AND AccountID = #AccountID# 
						</cfquery>
						<cfif CheckFirst.Recordcount Is 0>
							<cfquery name="AddData" datasource="#pds#">
								INSERT INTO GrpLists 
								(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
								 Phone, Company, City, CreateDate) 
								VALUES 
								(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
								 'Credit Card will expire soon.', '#DayPhone#', '#Company#', '#CCMonth#/#CCYear#', #Now()#)
							</cfquery>
							<cfset OncePer = 1>
						</cfif>
					</cfif>
				<cfelseif (CCMonth Is TheMon) AND (CCYear Is TheYear)>
					<cfif (ListFind(ProbType,2)) OR (ListFind(ProbType,0))>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT AccountID 
							FROM GrpLists 
							WHERE AdminID = #MyAdminID# 
							AND ReportID = 10 
							AND AccountID = #AccountID# 
						</cfquery>
						<cfif CheckFirst.Recordcount Is 0>
							<cfquery name="AddData" datasource="#pds#">
								INSERT INTO GrpLists 
								(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
								 Phone, Company, City, CreateDate) 
								VALUES 
								(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
								 'Credit Card expires this month.', '#DayPhone#', '#Company#', '#CCMonth#/#CCYear#', #Now()#)
							</cfquery>
							<cfset OncePer = 1>
						</cfif>
					</cfif>
				<cfelseif CreateDate(CCYear,CCMonth,28) LT Now()>
					<cfif (ListFind(ProbType,3)) OR (ListFind(ProbType,0))>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT AccountID 
							FROM GrpLists 
							WHERE AdminID = #MyAdminID# 
							AND ReportID = 10 
							AND AccountID = #AccountID# 
						</cfquery>
						<cfif CheckFirst.Recordcount Is 0>
							<cfquery name="AddData" datasource="#pds#">
								INSERT INTO GrpLists 
								(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
								 Phone, Company, City, CreateDate) 
								VALUES 
								(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
								 'Credit Card is expired.', '#DayPhone#', '#Company#', '#CCMonth#/#CCyear#', #Now()#)
							</cfquery>
							<cfset OncePer = 1>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<cfif OncePer Is 0>
			<cfif (Trim(AvsAddress) Is "") OR (Trim(AVSZip) Is "")>
				<cfif (ListFind(ProbType,8)) OR (ListFind(ProbType,0))>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM GrpLists 
						WHERE AdminID = #MyAdminID# 
						AND ReportID = 10 
						AND AccountID = #AccountID# 
					</cfquery>
					<cfif CheckFirst.Recordcount Is 0>
						<cfquery name="AddData" datasource="#pds#">
							INSERT INTO GrpLists 
							(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
							 Phone, Company, City, CreateDate) 
							VALUES 
							(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#AVSAddress# #AVSZip#', 
							 'Address verification information is missing.', '#DayPhone#', '#Company#', '#AVSAddress# #AVSZip#', #Now()#)
						</cfquery>			
					</cfif>
				</cfif>
			<cfelseif Trim(CCCardHolder) is "" >
				<cfif (ListFind(ProbType,4)) OR (ListFind(ProbType,0))>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM GrpLists 
						WHERE AdminID = #MyAdminID# 
						AND ReportID = 10 
						AND AccountID = #AccountID# 
					</cfquery>
					<cfif CheckFirst.Recordcount Is 0>
						<cfquery name="AddData" datasource="#pds#">
							INSERT INTO GrpLists 
							(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
							 Phone, Company, City, CreateDate) 
							VALUES 
							(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
							 'Card holders name is missing.', '#DayPhone#', '#Company#', '#CCCardHolder#', #Now()#)
						</cfquery>
					</cfif>
				</cfif>
			<cfelseif (Trim(CCNumber) is "") or (Trim(CCNumber) is "-") >
				<cfif (ListFind(ProbType,5)) OR (ListFind(ProbType,0))>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM GrpLists 
						WHERE AdminID = #MyAdminID# 
						AND ReportID = 10 
						AND AccountID = #AccountID# 
					</cfquery>
					<cfif CheckFirst.Recordcount Is 0>
						<cfquery name="AddData" datasource="#pds#">
							INSERT INTO GrpLists 
							(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
							 Phone, Company, City, CreateDate) 
							VALUES 
							(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
							 'Card number is missing.', '#DayPhone#', '#Company#', '#CCNumber#', #Now()#)
						</cfquery>
					</cfif>
				</cfif>
			<cfelseif (CCYear contains "-") OR (CCMonth contains "-") OR (Trim(CCYear) is "") OR (Trim(CCMonth) is "") >
				<cfif (ListFind(ProbType,6)) OR (ListFind(ProbType,0))>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM GrpLists 
						WHERE AdminID = #MyAdminID# 
						AND ReportID = 10 
						AND AccountID = #AccountID# 
					</cfquery>
					<cfif CheckFirst.Recordcount Is 0>
						<cfquery name="AddData" datasource="#pds#">
							INSERT INTO GrpLists 
							(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
							 Phone, Company, City, CreateDate) 
							VALUES 
							(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
							 'Expiration date is invalid.', '#DayPhone#', '#Company#', '#CCMonth#/#CCYear#', #Now()#)
						</cfquery>
					</cfif>
				</cfif>
			<cfelse>
				<CF_CCreditCard CardNumber="#CCNumber#" CardExpYear="#CCYear#"
		     		CardExpMonth="#CCMonth#" CardType="#CCType#">  
				<cfif  #ValidCC# is "No">
					<cfif (ListFind(ProbType,7)) OR (ListFind(ProbType,0))>
						<cfquery name="CheckFirst" datasource="#pds#">
							SELECT AccountID 
							FROM GrpLists 
							WHERE AdminID = #MyAdminID# 
							AND ReportID = 10 
							AND AccountID = #AccountID# 
						</cfquery>
						<cfif CheckFirst.Recordcount Is 0>
							<cfquery name="AddData" datasource="#pds#">
								INSERT INTO GrpLists 
								(ReportID, AdminID, AccountID, FirstName, Lastname, Login, ReportHeader, 
								 Phone, Company, City, CreateDate) 
								VALUES 
								(10, #MyAdminID#, #AccountID#, '#FirstName#', '#LastName#', '#CCCardHolder#', 
								 'Invalid card number.', '#DayPhone#', '#Company#', '************#Right(CCNumber,4)#', #Now()#)
							</cfquery>		
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 10 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTitle = 'Problem Credit Cards' 
		WHERE ReportID = 10 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 10>
	<cfset SendLetterID = 10>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 10 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "expirecc.cfm">
	<cfset SendHeader = "Name,Company,Data,Problem,Phone,E-Mail">
	<cfset SendFields = "Name,Company,City,ReportHeader,Phone,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 10 
	AND AdminID = #MyAdminID# 
</cfquery>

<CFSETTING ENABLECFOUTPUTONLY="No">
<html>
<head>
<title>Problem Credit Cards Report</TITLE>
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
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Problem Credit Cards Report</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<cfoutput>
		<form method="post" action="expirecc.cfm?RequestTimeout=500" onsubmit="MsgWindow()">
			<tr>
				<td colspan="2" bgcolor="#tdclr#"><select name="ProbType" multiple size="9">
					<option selected value="0">All Problems
					<option value="8">Address verification info is missing.
					<option value="4">Card holders name is missing.
					<option value="5">Card number is missing.
					<option value="2">Credit Card expires this month.
					<option value="3">Credit Card is expired.
					<option value="1">Credit Card will expire soon.
					<option value="6">Expiration date is invalid.
					<option value="7">Invalid card number.
					<option value="">________________________________________
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/continue.gif" name="CreateReport" border="0"></th>		
			</tr>
		</form>
	</cfoutput>
<cfelseif CheckFirst.Recordcount GT 0>
	<tr>
		<form method="post" action="grplist.cfm">
			<input type="hidden" name="SendReportID" value="10">
			<input type="hidden" name="SendLetterID" value="10">
			<input type="hidden" name="ReturnPage" value="expirecc.cfm">
			<input type="hidden" name="SendHeader" value="Name,Company,Data,Problem,Phone,E-Mail">
			<input type="hidden" name="SendFields" value="Name,Company,City,ReportHeader,Phone,EMail">
			<td><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></td>
		</form>
		<form method="post" action="expirecc.cfm">
			<td><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></td>
		</form>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
  