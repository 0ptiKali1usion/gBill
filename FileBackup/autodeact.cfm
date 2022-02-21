<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a list of all customers that do not auto deactivate. --->
<!--- 4.0.0 09/06/99 --->
<!--- autodeact.cfm --->

<cfinclude template="security.cfm">
<cfif (IsDefined("RemoveSelected.x")) AND (IsDefined("DeleteID"))>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 30 
		AND GrpListID In (#DeleteID#)
	</cfquery>
</cfif>
<cfif IsDefined("CarryOn.x")>
	<cfparam name="postal" default="0">
	<cfparam name="credit" default="0">
	<cfparam name="GroupSubs" default="0">
	<cfparam name="CheckD" default="0">
	<cfquery name="InsData" datasource="#PDS#">
		INSERT INTO GrpLists 
		(AccountID, FirstName, LastName, City, Address, Phone, 
		 Company, AdminID, ReportID, ReportTitle, CreateDate)
		SELECT A.AccountID, A.FirstName, A.LastName, A.City, A.Address1, A.DayPhone, 
		A.Company, #MyAdminID#, 30, 'Auto Deactivate Exempt List', #Now()# 
		FROM Accounts A 
		WHERE A.CancelYN = 0 
		AND NoAuto = 1 
		<cfif (GroupSubs Is "1") OR (Credit Is "1") OR (CheckD Is "1") OR (Postal Is "1")>
			AND A.AccountID IN 
				(SELECT AccountID 
				 FROM AccntPlans 
				 WHERE PayBy IN 
				 	(
					 <cfif (GroupSubs Is "1")>'CK',</cfif>
					 <cfif (Credit Is "1")>'CC',</cfif>
					 <cfif (CheckD Is "1")>'CD',</cfif>
					 <cfif (Postal Is "1")>'PO',</cfif>
					 'JAF'
				 	)
				)
 		</cfif>
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans 
			 WHERE PlanID IN 
			<cfif PlanID Is "0">
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #MyAdminID#)
			<cfelse>
				(#PlanID#) 
			</cfif>
			)
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans 
			 WHERE POPID IN 
			<cfif POPID Is "0">
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#)
			<cfelse>
				(#POPID#) 
			</cfif>
			)
		AND A.AccountID IN 
			(SELECT AccountID 
			 FROM AccntPlans 
			<cfif DomainID Is "0">
				WHERE FTPDomainID In 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)
				OR EMailDomainID In 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)			
				OR AuthDomainID In 
					(SELECT DomainID 
					 FROM DomAdm 
					 WHERE AdminID = #MyAdminID#)
			<cfelse>
				WHERE FTPDomainID In (#DomainID#)
				OR EMailDomainID In (#DomainID#) 
				OR AuthDomainID In (#DomainID#) 
			</cfif>
			)
		<cfif SalesPID Is "0">
			<cfif GetOpts.WhatView Is 0>
				AND A.SalesPersonID = #MyAdminID#
			</cfif>
		<cfelse>
			AND A.SalesPersonID In (#SalesPID#) 
		</cfif>
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT ReportID 
		FROM GrpListInfo 
		WHERE ReportID = 30 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="InfoTable" datasource="#pds#">
			INSERT INTO GrpListInfo 
			(ReportID, AdminID, DestinationCFM, DestinationIMG) 
			VALUES 
			(30, #MyAdminID#, 'autodeact2.cfm', 'addnew.gif')
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 30 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = A.PayBy 
		FROM AccntPlans A, GrpLists G 
		WHERE G.AccountID = A.AccountID 
		AND G.ReportID = 30 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check' 
		WHERE ReportTab = 'ck'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Check Debit' 
		WHERE ReportTab = 'cd'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Credit Card' 
		WHERE ReportTab = 'cc'
	</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
		UPDATE GrpLists SET 
		ReportTab = 'Purchase Order' 
		WHERE ReportTab = 'po'
	</cfquery>
	<cfquery name="LoopRecords" datasource="#pds#">
		SELECT * 
		FROM GrpLists 
		WHERE ReportID = 30 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendReportID = 30>
	<cfset SendLetterID = 30>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 30 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset ReturnPage = "autodeact.cfm">
	<cfset SendHeader = "Name,Company,Pay By,Phone,E-Mail">
	<cfset SendFields = "Name,Company,ReportTab,Phone,EMail">
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 30 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="StartOver2" datasource="#pds#">
		DELETE FROM GrpListInfo 
		WHERE ReportID = 30 
		AND AdminID = #MyAdminID#
	</cfquery>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 30 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="getemail" datasource="#pds#">
		SELECT EMail 
		FROM AccountsEMail 
		WHERE PrEMail = 1 
		AND AccountID = 
			(SELECT AccountID 
			 FROM Admin 
			 WHERE AdminID = #MyAdminID#)
	</cfquery>
	<cfquery name="GetPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In 
			(SELECT P.PlanID 
			 FROM PlanAdm P, Admin A 
			 WHERE P.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY PlanDesc
	</cfquery>
	<cfquery name="GetDomains" datasource="#pds#">
		SELECT DomainID, DomainName 
		FROM Domains 
		WHERE DomainID In 
			(SELECT D.DomainID 
			 FROM DomAdm D, Admin A 
			 WHERE D.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY DomainName
	</cfquery>
	<cfquery name="GetPOPs" datasource="#pds#">
		SELECT POPID, POPName 
		FROM POPs 
		WHERE POPID In 
			(SELECT P.POPID 
			 FROM POPAdm P, Admin A 
			 WHERE P.AdminID = A.AdminID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY POPName
	</cfquery>
	<cfquery name="GetSalesP" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID
		FROM Accounts C, Admin A 
		WHERE C.AccountID = A.AccountID 
		AND A.SalesPersonYN = 1 
		<cfif GetOpts.EditName Is 0>
			AND AdminID = #MyAdminID# 
		</cfif>
		ORDER BY LastName, FirstName 
	</cfquery>
	<cfparam name="Credit" default="1">
	<cfparam name="CheckD" default="1">
	<cfparam name="MinAMnt" default="NA">
	<cfparam name="Postal" default="1">
	<cfparam name="MinCredit" default="NA">
	<cfparam name="GroupSubs" default="1">
	<cfparam name="TheDomainID" default="0">
	<cfparam name="ThePlanID" default="0">
	<cfparam name="ThePOPID" default="0">
	<cfparam name="SalesPID" default="0">
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Auto Deactivate Exemption List</TITLE>
	<cfinclude template="coolsheet.cfm"></head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select Criteria</font></th>
		</tr>
	</cfoutput>
	<form method="post" action="autodeact.cfm">
		<cfoutput>
			<tr valign="top" bgcolor="#tdclr#">
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Credit Is 1>checked</cfif> name="Credit" value="1"></td>
				<td bgcolor="#tbclr#">Include Credit Card Customers</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif CheckD Is 1>checked</cfif> name="CheckD" value="1"></td>
				<td bgcolor="#tbclr#">Include Check Debit Customers</td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
				<td bgcolor="#tbclr#">Include Purchase Order Customers</td>
				<input type="hidden" name="MinCredit" value="NA">
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif GroupSubs Is 1>checked</cfif> name="GroupSubs" value="1"></td>
				<td bgcolor="#tbclr#">Include Check/Cash Customers</td>
			</tr>
			<tr>
				<th colspan="4"><input type="image" src="images/continue.gif" name="CarryOn" border="0"></th>
			</tr>
			<tr valign="top" bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" colspan="2">Plans</td>
				<td colspan="2" bgcolor="#tbclr#">POPs</td>
			</tr>
			<tr bgcolor="#tdclr#">
		</cfoutput>
				<td colspan="2"><select name="PlanID" multiple size="6">
					<option <cfif ThePlanID Is "0">selected</cfif> value="0">All Plans
					<cfoutput query="GetPlans">
						<option <cfif ListFind(ThePlanID,PlanID) GT 0>selected</cfif> value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="">______________________________
				</select></td>
				<td colspan="2"><select name="POPID" multiple size="6">
					<option <cfif ThePOPID Is 0>selected</cfif> value="0">All POPs
					<cfoutput query="GetPOPS">
						<option <cfif ListFind(ThePOPID,POPID) GT 0>selected</cfif> value="#POPID#">#POPName#
					</cfoutput>
					<option value="">______________________________
				</select></td>
			</tr>
			<cfoutput>
			<tr valign="top" bgcolor="#tdclr#">
				<td colspan="2" bgcolor="#tbclr#">Domains</td>
				<td bgcolor="#tbclr#" colspan="2">Salesperson</td>
			</tr>
			<tr valign="top" bgcolor="#tdclr#">
			</cfoutput>
				<td colspan="2"><select name="DomainID" multiple size="6">
					<option <cfif TheDomainID Is "0">selected</cfif> value="0">All Domains
					<cfoutput query="GetDomains">
						<option <cfif ListFind(TheDomainID,DomainID) GT 0>selected</cfif> value="#DomainID#">#DomainName#
					</cfoutput>
					<option value="">______________________________
				</select></td>
				<td colspan="2"><select name="SalesPID" multiple size="6">
					<option <cfif SalesPID Is "0">selected</cfif> value="0">All Salespersons
					<cfoutput query="GetSalesP">
						<option <cfif ListFind(SalesPID,AdminID) GT 0>selected</cfif> value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="">______________________________
					</select></td>
			</tr>
		</form>
	</table>
	</center>
		<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Session In Progress</title>
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="coolsheet.cfm">
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td align="center" colspan="2" bgcolor="#thclr#">Auto Deactivate Exclusion</td>
	</cfoutput>
		</tr>
		<tr>
			<form method="post" action="grplist.cfm">
				<input type="hidden" name="SendReportID" value="30">
				<input type="hidden" name="SendLetterID" value="30">
				<input type="hidden" name="ReturnPage" value="autodeact.cfm">
				<input type="hidden" name="SendHeader" value="Name,Company,Pay By,Phone,E-Mail">
				<input type="hidden" name="SendFields" value="Name,Company,ReportTab,Phone,EMail">
				<td><input type="image" src="images/viewlist.gif" name="continue" border="0"></td>
			</form>
			<form method="post" action="autodeact.cfm">
				<td><input type="image" src="images/changecriteria.gif" name="startover" border="0"></td>
			</form>
		</tr>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>
 