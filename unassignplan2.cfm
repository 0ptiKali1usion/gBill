<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- unassignplan2.cfm --->
<cfset SecurePage = "unassignplan.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("UpdatePlans.x")>
	<cfif IsDate("#NextDue#")>
		<cfset TheNextDue = CreateDateTime(Year(NextDue),Month(NextDue),day(NextDue),0,0,0)>
	<cfelse>
		<cfset NextFirst = DateAdd("m",1,Now())>
		<cfset TheNextDue = CreateDateTime(Year(NextFirst),Month(NextFirst),1,0,0,0)>
	</cfif>
	<cfquery name="InsPlans" datasource="#pds#">
		INSERT INTO AccntPlans 
		(AccountID, PlanID, NextDueDate, POPID, EMailDomainID, FTPDomainID, AuthDomainID, 
		 StartDate, LastDebitDate, AccntStatus, PayBy, PostalRem, Taxable, BillingStatus) 
		SELECT AccountID, #PlanID#, #CreateODBCDateTime(TheNextDue)#, #POPID#, #DomainID#, #DomainID#, #DomainID#, 
		#Now()#, #Now()#, 0, 'ck', 0, 1, 1 
		FROM Accounts 
		WHERE AccountID In  
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 32 
			 AND AdminID = #MyAdminID# )
		AND AccountID NOT In 
			(SELECT AccountID 
			 FROM AccntPlans)
	</cfquery>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 32 
		AND AccountID IN 
			(SELECT AccountID 
			 FROM GrpLists 
			 WHERE ReportID = 32 
			 AND AdminID = #MyAdminID#) 		
	</cfquery>
</cfif>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1','DeactAccount','DelAccount') 
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfquery name="GetPlans" datasource="#pds#">
	SELECT P.PlanDesc, P.PlanID 
	FROM Plans P 
	WHERE P.PlanID In 
		(SELECT PlanID 
		 FROM PlanAdm 
		 WHERE AdminID = #MyAdminID#) 
	AND P.PlanID NOT In (#DeactAccount#,#DelAccount#) 
	ORDER BY P.PlanDesc 
</cfquery>
<cfquery name="GetPOPs" datasource="#pds#">
	SELECT P.POPName, P.POPID, DefPOP 
	FROM POPs P
	WHERE P.POPID In 
		(SELECT POPID 
		 FROM POPAdm 
		 WHERE AdminID = #MyAdminID#)
	ORDER BY P.POPName 
</cfquery>
<cfquery name="GetDomain" datasource="#pds#">
	SELECT D.DomainName, D.DomainID, Primary1 
	FROM Domains D 
	WHERE D.DomainID In 
		(SELECT DomainID 
		 FROM DomAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY D.DomainName 
</cfquery>
<cfquery name="CheckNow" datasource="#pds#">
	SELECT AccountID 
	FROM GrpLists 
	WHERE ReportID = 32 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfquery name="CheckForMore" datasource="#pds#">
	SELECT AccountID 
	FROM Accounts 
	WHERE AccountID NOT In 
		(SELECT AccountID 
		 FROM AccntPlans) 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Assign Plan</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif CheckNow.RecordCount GT 0>
	<form method="post" action="grplist.cfm">
		<input type="Image" src="images/viewlist.gif" name="GoBack" border="0">
		<input type="Hidden" name="SendReportID" value="32">
		<input type="Hidden" name="SendLetterID" value="0">
		<input type="Hidden" name="SendHeader" value="Name,Address,Company,Phone">
		<input type="Hidden" name="SendFields" value="Name,Address,Company,Phone">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Assign Plan</font></th>
	</tr>
</cfoutput>
	<cfif CheckNow.RecordCount GT 0>
		<cfoutput>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">Everyone listed on the report will be assigned the following values.</td>
		</tr>
		<form method="post" action="unassignplan2.cfm">
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Next Due</td>
				<td><input type="Text" name="NextDue" value="#LSDateFormat(Now(), '#DateMask1#')#"></td>
		</cfoutput>
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Domain</td>
			</cfoutput>
				<td><select name="DomainID">
					<cfoutput query="GetDomain">
						<option <cfif Primary1 Is 1>selected</cfif> value="#DomainID#">#DomainName#
					</cfoutput>
				</select></td>
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Plans</td>
			</cfoutput>
				<td><select name="PlanID">
					<cfoutput query="GetPlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
				</select></td>		
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">POPs</td>
			</cfoutput>
				<td><select name="POPID">
					<cfoutput query="GetPOPs">
						<option <cfif DefPOP Is 1>selected</cfif> value="#POPID#">#POPName#
					</cfoutput>
				</select>
				</td>
			</tr>
			<tr>
				<th colspan="2"><input type="Image" name="UpdatePlans" src="images/update.gif" border="0"></th>
			</tr>
		</form>
	<cfelse>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#">You have assigned all the selected customers.
				<cfif CheckForMore.RecordCount GT 0><br><a href="unassignplan.cfm">Create New List</a></cfif></td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
