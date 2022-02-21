<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Edit existing email account. --->
<!---	4.0.0 12/01/99 --->
<!--- accntemail4.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("EditOne.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT * 
		FROM CustomEMailSetup 
		WHERE ActiveYN = 1 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'EPass' 
		AND BOBName <> 'Login' 
		AND CEMailID = #CEMailID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AccountsEMail SET 
		<cfloop query="GetFields">
			<cfset UpdValue = Evaluate("#BOBName#")>
			#BOBName# = 
				<cfif DataType Is "Text">
					<cfif Trim(UpdValue) Is "">NULL<cfelse>'#UpdValue#'</cfif>
				<cfelseif DataType Is "Number">
					<cfif Trim(UpdValue) Is "">NULL<cfelse>#UpdValue#</cfif>
				<cfelseif DataType Is "Date">
					<cfif Trim(UpdValue) Is "">NULL<cfelse>#CreateODBCDateTime(UpdValue)#</cfif>
				</cfif>
				<cfif BOBName Is "FName">
					<cfset TheFullName = "">
					<cfif (IsDefined("FName")) AND (IsDefined("LName"))>
						<cfset TheFullName = TheFullName & FName & " " & LName>
					</cfif>
					, FullName = '#TheFullName#' 
				</cfif>
				,
		</cfloop>
		AccntPlanID = #NewPlanID# 
		WHERE EMailID = #EMailID# 
	</cfquery>
	<cfquery name="UpdAliases" datasource="#pds#">
		UPDATE AccountsEMail SET 
		AccntPlanID = #NewPlanID# 
		WHERE AliasTo = #EMailID# 
	</cfquery>
	<!---  Scripts  --->
	<cfquery name="GetScripts" datasource="#pds#">
		SELECT I.IntID 
		FROM Integration I, IntScriptLoc S, IntLocations L 
		WHERE I.IntID = S.IntID 
		AND S.LocationID = L.LocationID 
		AND L.ActiveYN = 1 
		AND I.ActiveYN = 1 
		AND L.PageName = 'accntemail4.cfm' 
		AND L.LocationAction = 'Change' 
		AND I.TypeID = 
			(SELECT TypeID 
			 FROM IntTypes 
			 WHERE TypeStr = 'EMail') 
	</cfquery>
	<cfif GetScripts.RecordCount GT 0>
		<cfset LocScriptID = ValueList(GetScripts.IntID)>
		<cfset LocEMailID = EMailID>
		<cfset LocAccntPlanID = AccntPlanID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="runintegration.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfif FileExists(ExpandPath("external#OSType#extchangeemail.cfm"))>
		<cfset SendID = EMailID>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="external#OSType#extchangeemail.cfm">
		<cfsetting enablecfoutputonly="yes">
	</cfif>
	<cfsetting enablecfoutputonly="no">
	<cfset Tab = 4>
	<cfinclude template="accntmanage2.cfm">
	<cfabort>
</cfif>
<cfquery name="AuthInfo" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>
<cfquery name="SelectedPlan" datasource="#pds#">
	SELECT PlanID, PlanDesc 
	FROM Plans 
	WHERE PlanID = 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = 
		 	(SELECT AccntPlanID 
			 FROM AccountsEMail 
			 WHERE EMailID = #EMailID#)
		)
</cfquery>
<cfquery name="OtherPlans" datasource="#pds#">
	SELECT AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails, Count(E.EMailID) as IntNumber 
	FROM Plans P, AccntPlans AP, AccountsEMail E 
	WHERE P.PlanID = AP.PlanID 
	AND E.AccntPlanID = AP.AccntPlanID 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND AP.AccntPlanID <> #AccntPlanID# 
	GROUP BY AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails 
	HAVING Count(E.EMailID) < P.FreeEmails 
	OR Count(E.EMailID) < AP.EMailAccounts 
	UNION 
	SELECT AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails, 0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID <> #AccntPlanID# 
	AND AP.AccountID = #AuthInfo.AccountID# 
	AND (P.FreeEmails > 0 OR AP.EMailAccounts > 0) 
	AND AP.AccntPlanID NOT IN 
		(SELECT AccntPlanID 
		 FROM AccountsEMail)
	UNION 
	SELECT AP.AccntPlanID, AP.EMailAccounts, P.PlanID, P.PlanDesc, P.FreeEmails, 	0 as IntNumber  
	FROM Plans P, AccntPlans AP 
	WHERE P.PlanID = AP.PlanID 
	AND AP.AccntPlanID = #AccntPlanID# 
	ORDER BY P.PlanDesc
</cfquery>
<cfquery name="EmailEdit" datasource="#pds#">
	SELECT * 
	FROM AccountsEMail 
	WHERE EMailID = #EMailID# 
</cfquery>
<cfquery name="EMailFields" datasource="#pds#">
	SELECT * 
	FROM CustomEMailSetup 
	WHERE ActiveYN = 1 
	AND BOBName <> 'DomainName' 
	AND BOBName <> 'EPass' 
	AND BOBName <> 'Login' 
	AND CEMailID = 
		(SELECT CEMailID 
		 FROM Domains 
		 WHERE DomainID = #EmailEdit.DomainID#)
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>E-Mail Edit</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccntPlanID" value="#AccntPlanID#"></cfoutput>
	<input type="hidden" name="tab" value="4">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#EmailEdit.EMail#</font></th>
	</tr>
</cfoutput>
<form method="post" action="accntemail4.cfm">
	<cfif OtherPlans.Recordcount GT 0>
		<cfoutput>
			<tr>
				<th bgcolor="#thclr#" colspan="2">#SelectedPlan.PlanDesc#</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Change To</td>
		</cfoutput>
				<td><select name="NewPlanID">
					<cfoutput query="OtherPlans">
						<option <cfif PlanID Is SelectedPlan.PlanID>selected</cfif> value="#AccntPlanID#">#PlanDesc#
					</cfoutput>
				</select></td>
			</tr>
	</cfif>
	<cfoutput query="EMailFields">
		<tr>
			<td align="right" bgcolor="#tbclr#">#EMailDescription#</td>
			<cfset DispValue = Evaluate("EmailEdit.#BOBName#")>
			<td bgcolor="#tdclr#"><input type="text" name="#BOBName#" value="#DispValue#"></td>
		</tr>
		<input type="hidden" name="#BOBName#_Required" value="Please enter: #EMailDescription#">
	</cfoutput>
	<tr>
		<th colspan="2"><input type="image" src="images/update.gif" name="EditOne" border="0"></th>
	</tr>
	<cfoutput>
		<input type="hidden" name="EMailID" value="#EmailEdit.EMailID#">
		<input type="hidden" name="CEMailID" value="#EMailFields.CEMailID#">
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 