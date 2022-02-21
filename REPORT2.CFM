<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of how many customers are on each plan by pop. --->
<!--- 4.0.0 09/08/99
		3.2.0 09/08/98 --->
<!--- report2.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 26 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfquery name="Check" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE ReportID = 26 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfif Check.RecordCount GT 0>
<cfsetting enablecfoutputonly="No">
	<html>
	<head>
	<title>Report exists</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<td colspan="4" bgcolor="#tbclr#">This is already a report in progress.</td>
			</tr>
			<tr>
				<form method="post" action="grplist.cfm">
					<input type="hidden" name="SendReportID" value="26">
					<input type="hidden" name="SendLetterID" value="26">
					<input type="hidden" name="ReturnPage" value="report2.cfm">
					<input type="hidden" name="SendHeader" value="Name,Company,Phone,E-Mail">
					<input type="hidden" name="SendFields" value="Name,Company,Phone,EMail">
					<th colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
				</form>
				<form method="post" action="report2.cfm">
					<th colspan="2" width="50%"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
				</form>
			</tr>
		</table>
	</cfoutput>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
	<cfabort>	
</cfif>
<cfif IsDefined("ListIt")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 26 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID#
		</cfquery>
		<cfquery name="GetPlan" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID = #PlanID# 
		</cfquery>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, Company, Phone, ReportID, AdminID, ReportTitle, CreateDate) 
			SELECT LastName, FirstName, AccountID, Company, DayPhone, 26, #MyAdminID#, '#GetPlan.PlanDesc# Customers in #GetPOP.POPName#', #Now()# 
			FROM Accounts 
			WHERE AccountID In
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE PlanID = #PlanID# 
				 AND POPID = #POPID#)
		</cfquery>
	</cfif>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 26 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 26>
	<cfset SendLetterID = 26>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 26 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "report2.cfm">
	<cfset SendHeader = "Name,Company,Phone,E-Mail">
	<cfset SendFields = "Name,Company,Phone,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfif IsDefined("ShowReport.x")>
	<cfquery name="AllPOPs" datasource="#pds#">
		SELECT P.POPName, P.POPID, Count(A.AccountID) AS COaid 
		FROM AccntPlans A, POPs P 
		WHERE A.POPID = P.POPID 
		AND P.POPID IN 
			(SELECT POPID 
			 FROM POPAdm 
			 WHERE AdminID = #MyAdminID#) 
		<cfif SelectedPOPs GT 0>
			AND P.POPID IN (#SelectedPOPs#)
		</cfif>
		GROUP BY P.POPName, P.POPID 
		ORDER BY P.POPName 
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		SELECT P.PlanID, P.PlanDesc, Count(A.AccountID) AS COaid 
		FROM AccntPlans A, Plans P 
		WHERE A.PlanID = P.PlanID 
		AND P.PlanID IN 
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		<cfif SelectedPlans GT 0>
			AND P.PlanID IN (#SelectedPlans#)
		</cfif>
		GROUP BY P.PlanID, P.PlanDesc 
		ORDER BY P.PlanDesc
	</cfquery>
	<cfloop query="AllPlans">
		<cfset ThePlanID = AllPlans.PlanID>
	   <cfloop query="AllPOPs">
			<cfset ThePOPID = AllPOPs.POPID>
			<cfquery name="r#ThePOPID#tots#ThePlanID#" datasource="#pds#">
				SELECT Count(AccountID) as caid 
				FROM AccntPlans 
				WHERE PlanID = #ThePlanID# 
				AND POPID = #ThePOPID# 
			</cfquery>
		</cfloop>
	</cfloop>
	<cfset HTot = 0>
	<cfset GrndTot = 0>
	<cfset HowWide = AllPOPs.Recordcount + 2>
	<cfoutput query="AllPOPs">
		<cfset "vtot#POPID#" = 0>
	</cfoutput>
	
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Report Of Plans By POP</title>
	<cfinclude template="coolsheet.cfm"></head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Report Of Plans By POP</font></tD>
		</tr>
		<tr valign="top">
			<th bgcolor="#thclr#">Plans \ POPs</th>
	</cfoutput>
	  		<cfloop query="AllPOPs">
				<cfoutput><td bgcolor="#thclr#">#popname#</td></cfoutput>
			</cfloop>
			<cfoutput><td bgcolor="#thclr#">Total</td></cfoutput>
		</tr>
		<cfloop query="AllPlans">
			<cfset OuterID = AllPlans.PlanID>
			<cfoutput>
			<tr>
				<td bgcolor="#thclr#">#plandesc#</td>
			</cfoutput>
				<cfset ThePlanID = PlanID>
				<cfloop query="AllPOPs">
					<cfset tot2 = Evaluate("r#AllPOPs.POPID#tots#outerid#.caid")>
					<cfset HTot = HTot + Tot2>
					<cfset "vtot#POPID#" = Evaluate("vtot#POPID#") + Tot2>
					<cfoutput>
						<cfif Tot2 GT 0>
							<cfif IsDefined("ShowList")>
								<form method="post" action="report2.cfm">
									<input type="Hidden" name="POPID" value="#POPID#">
									<input type="Hidden" name="PlanID" value="#ThePlanID#">
									<td align="right" bgcolor="#tbclr#"><font size="2"><input type="Submit" name="ListIt" value="List"></font> #Tot2#</td>
								</form>
							<cfelse>
									<td align="right" bgcolor="#tbclr#">#Tot2#</td>							
							</cfif>
						<cfelse>
							<td align="right" bgcolor="#tbclr#">#Tot2#</td>
						</cfif>
					</cfoutput>
				</cfloop>
				<cfoutput>
					<th align="right" bgcolor="#tbclr#">#HTot#</th>
				</cfoutput>
				<cfset GrndTot = GrndTot + HTot>
				<cfset HTot = 0>
			</tr>
		</cfloop>
		<cfoutput>
		<tr>
			<td bgcolor="#thclr#"><b>Total</b></td>
		</cfoutput>
			<cfoutput query="AllPOPs">
				<th align="right" bgcolor="#tdclr#">#Evaluate("vtot#POPID#")#</th>
			</cfoutput>
			<cfoutput><th bgcolor="#tdclr#">#GrndTot#</th></cfoutput>
		</tr>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
 	<cfquery name="SelectablePlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		ORDER BY PlanDesc 
	</cfquery>
 	<cfquery name="SelectablePOPs" datasource="#pds#">
		SELECT POPName, POPID 
		FROM POPs 
		WHERE POPID IN 
			(SELECT POPID 
			 FROM POPAdm 
			 WHERE AdminID = #MyAdminID#)
		ORDER BY POPName 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Select Criteria</title>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Report Of Plans By Domain Criteria</font></td>
		</tr>	
		<form method="post" action="report2.cfm">
			<tr>
				<td bgcolor="#tbclr#">Plans</td>
				<td bgcolor="#tbclr#">POPs</td>
			</tr>
			<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
				<td><select name="SelectedPlans" size="10" multiple>
					<option selected value="0">All Plans
					<cfoutput query="SelectablePlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">___________________________________
				</select></td>
				<td><select name="SelectedPOPs" size="10" multiple>
					<option selected value="0">All POPs
					<cfoutput query="SelectablePOPs">
						<option value="#POPID#">#POPName#
					</cfoutput>
					<option value="0">___________________________________
				</select></td>
			</tr>
			<tr>
				<cfoutput>
					<th bgcolor="#tdclr#" colspan="2"><input type="Checkbox" name="ShowList" value="1">Show List Option </th>
				</cfoutput>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ShowReport" border="0"></th>
			</tr>
		</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
 </cfif>
   