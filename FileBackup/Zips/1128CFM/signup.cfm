<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of signup activity during a selected date range. --->
<!--- 4.0.0 09/10/99 
		3.2.0 09/08/98 --->
<!--- signup.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 12 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("Report.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 12 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset Date1 = CreateDate(FromYear,FromMon,FromDay)>
		<cfset Date2 = CreateDate(ToYear,ToMon,ToDay)>
		<cfquery name="Range" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, Company, Phone, AccntPlanID, ReportDate, 
			 ReportID, AdminID, ReportTitle, CreateDate) 	
			SELECT A.LastName, A.FirstName, A.AccountID, A.Company, A.Dayphone,
			A.SalesPersonID, A.StartDate, 12, #MyAdminID#, 'Signups from #LSDateFormat(date1, '#DateMask1#')# to #LSDateFormat(date2, '#DateMask1#')#', #Now()# 
			FROM Accounts A 
			WHERE AccountID In 
				(SELECT P.AccountID 
				 FROM AccntPlans P 
				 WHERE P.POPID IN 
				 	<cfif SelectedPOPs Is Not 0>
						(#SelectedPOPs#)
					<cfelse>
				 		(SELECT POPID 
						 FROM POPAdm 
						 WHERE AdminID = #MyAdminID#) 
					</cfif>
				 AND P.PlanID IN 
				 	<cfif SelectedPlans Is Not 0>
						(#SelectedPlans#)
					<cfelse>
						(SELECT PlanID 
						 FROM PlanAdm 
						 WHERE AdminID = #MyAdminID#) 
					</cfif>
				<cfif SelectedDomains Is Not 0>
				 AND (P.EMailDomainID IN 
							(#SelectedDomains#) 
						OR 
						P.FTPDomainID IN 
							(#SelectedDomains#) 
						OR 
						P.AuthDomainID IN 
							(#SelectedDomains#) 
					)
				)
				<cfelse>
				 AND (P.EMailDomainID IN 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
						OR 
						P.FTPDomainID IN 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
						OR 
						P.AuthDomainID IN 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
					)
				)
				</cfif>
			AND A.StartDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
			AND A.StartDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
			<cfif SelectedSales Is Not 0>
				AND A.SalesPersonID IN (#SelectedSales#)
			</cfif>
		</cfquery>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 12 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="GetSalesperson" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportHeader = A.FirstName + ' ' + A.LastName 
		FROM Accounts A, Admin S, GrpLists G 
		WHERE A.AccountID = S.AccountID 
		AND S.AdminID = G.AccntPlanID 
		AND G.ReportID = 12 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 12>
	<cfset SendLetterID = 12>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 12 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "signup.cfm">
	<cfset SendHeader = "Name,Company,Phone,Salesperson,Signup Date,E-Mail">
	<cfset SendFields = "Name,Company,Phone,ReportHeader,ReportDate,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfquery name="NullDate" datasource="#PDS#"> 
	SELECT *
	FROM Accounts 
	WHERE AccountID In 
		(SELECT A.AccountID  
		 FROM Accounts A, AccntPlans P
		 WHERE A.AccountID = P.AccountID 
		 AND A.StartDate Is Null 
		 AND P.POPID IN 
		 	(SELECT POPID 
			 FROM POPAdm 
			 WHERE AdminID = #MyAdminID#) 
		 AND P.PlanID IN 
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		AND 	(P.EMailDomainID IN 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				OR 
				P.FTPDomainID IN 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				OR 
				P.AuthDomainID IN 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#) 
				 )
			)
</cfquery>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 12 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="AvailPlans" datasource="#pds#">
	SELECT PlanID, PlanDesc 
	FROM Plans 
	WHERE PlanID IN 
		(SELECT PlanID 
		 FROM PlanAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY PlanDesc
</cfquery>
<cfquery name="AvailPOPs" datasource="#pds#">
	SELECT POPID, POPName 
	FROM POPs 
	WHERE POPID IN 
		(SELECT POPID 
		 FROM POPAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY POPName
</cfquery>
<cfquery name="AvailDomains" datasource="#pds#">
	SELECT DomainID, DomainName 
	FROM Domains 
	WHERE DomainID IN 
		(SELECT DomainID 
		 FROM DomAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY DomainName
</cfquery>
<cfquery name="AvailSales" datasource="#pds#">
	SELECT C.LastName, C.FirstName, A.AdminID 
	FROM Accounts C, Admin A 
	WHERE C.AccountID = A. AccountID 
	AND A.SalesPersonYN = 1 
	ORDER BY C.LastName, C.FirstName 
</cfquery>
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(StartDate) as MinDate 
	FROM Accounts 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDates = LowDate.MinDate>
<cfelse>
	<cfset StartDates = Now()>
</cfif>
<cfset mm2 = Month(StartDates)>
<cfset yy2 = Year(StartDates)>
<cfset dd2 = Day(StartDates)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Signup Report</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
<cfinclude template="jsdates.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Signup Activity</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.Recordcount Is 0>
	<cfoutput>
	<form name="getdate" method=post action="signup.cfm" onsubmit="return checkdates();MsgWindow()">
	<tr bgcolor="#tdclr#" valign="top">
		<td bgcolor="#tbclr#" align=right>From</td>
	</cfoutput>
		<td><Select name="FromMon" onChange="getdays()">
			<cfloop index="B5" From="01" To="12">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #mmm# is "#B5#">selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
			</cfloop>
		</select><SELECT name="FromDay">
			<cfloop index="B5" From="01" To="#numdays#">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option value="#B5#">#b5#</cfoutput>
			</cfloop>
		</select><SELECT name="FromYear" onChange="getdays()">
			<cfloop index="B4" from="#yy2#" to="#yyy#">
				<cfoutput><option <cfif #yyy# is "#B4#">selected</cfif> value="#B4#">#B4#</cfoutput>
			</cfloop>
		</select></td>
	<cfoutput>
		<td bgcolor="#tbclr#" align=right>To</td>
	</cfoutput>		
		<td><Select name="ToMon" onChange="getdays2()">
			<cfloop index="B5" From="01" To="12">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #mmm# is "#B5#">selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
			</cfloop>
		</select><SELECT name="ToDay">
			<cfloop index="B5" From="01" To="#numdays#">
				<cfif #b5# lt 10><cfset #B5# = "0" & "#B5#"></cfif>
				<cfoutput><option <cfif #ddd# is "#B5#">selected</cfif> value="#B5#">#b5#</cfoutput>
			</cfloop>
		</select><SELECT name="ToYear" onChange="getdays2()">
			<cfloop index="B4" from="#yy2#" to="#yyy#">
				<cfoutput><option <cfif #yyy# is "#B4#">selected</cfif> value="#B4#">#B4#</cfoutput>
			</cfloop>
		</select></td>
	</tr>
	<cfoutput>
	<tr>
		<th colspan="4"><input type="image" name="Report" src="images/viewlist.gif" border="0"></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" colspan="2">Plans</td>
		<td bgcolor="#tbclr#" colspan="2">POPs</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<td colspan="2"><select name="SelectedPlans" size="10" multiple>
			<option value="0" selected>All Plans
			<cfoutput query="AvailPlans"><option value="#PlanID#">#PlanDesc#
			</cfoutput>
			<option value="">______________________________
		</select></td>
		<td colspan="2"><select name="SelectedPOPs" size="10" multiple>
			<option value="0" selected>All POPs
			<cfoutput query="AvailPOPs"><option value="#POPID#">#POPName#
			</cfoutput>
			<option value="">______________________________
		</select></td>
	</tr>
	<cfoutput>
	<tr bgcolor="#tdclr#" valign="top">
		<td colspan="2" bgcolor="#tbclr#">Domains</td>
		<td colspan="2" bgcolor="#tbclr#">Salesperson</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<td colspan="2"><select name="SelectedDomains" size="10" multiple>
			<option value="0" selected>All Domains
			<cfoutput query="AvailDomains"><option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="">______________________________
		</select></td>
		<td colspan="2"><select name="SelectedSales" size="10" multiple>
			<option value="0" selected>All Salespeople
			<cfoutput query="AvailSales"><option value="#AdminID#">#LastName#, #FirstName#
			</cfoutput>
			<option value="">______________________________
		</select></td>
	</tr>
	</form>
	<cfif NullDate.Recordcount GT 0>
		<tr>
			<cfoutput>
			<th bgcolor="#thclr#" colspan="4">The following accounts are missing startdates.</th>
			</cfoutput>
		</tr>
		<cfoutput query="nulldate">
			<tr bgcolor="#tbclr#">
				<td colspan="4"><a href="custinf1.cfm?accountid=#AccountID#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#LastName#, #FirstName#</a></td>
			</tr>
		</cfoutput>
	</cfif>	
<cfelse>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">This is already a Signup report in progress.</td>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="12">
				<input type="hidden" name="SendLetterID" value="12">
				<input type="hidden" name="ReturnPage" value="signup.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Phone,Salesperson,Signup Date,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,Phone,ReportHeader,ReportDate,EMail">
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
			</form>
			<form method="post" action="signup.cfm">
				<th colspan="2" width="50%"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
			</form>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 