<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Cancels entire account. --->
<!---	4.0.0 04/19/00 --->
<!--- custcan2.cfm --->

<cfif GetOpts.CancelC Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("CxReason")>
	<cfset MemoReason = CxReason>
</cfif>
<cfset NoDates = 0>
<cfif DeactWhen Is "Now">
	<cfset CheckDate = Now()>
	<cfset BillMethod = 1>
	<cfset SkipTwo = 1>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="custcan3.cfm">
	<cfabort>
<cfelseif DeactWhen Is "Later">
	<cfset CheckDate = WhenRun>
</cfif>
<cfquery name="CheckAccounts" datasource="#pds#">
	SELECT A.AccntPlanID 
	FROM AccntPlans A, Plans P 
	WHERE A.PlanID = P.PlanID 
	AND A.AccountID = #AccountID# 
	AND A.NextDueDate < #CreateODBCDateTime(CheckDate)# 
	AND P.RecurringAmount - P.RecurDiscount > 0 
</cfquery>
<cfif CheckAccounts.Recordcount GT 0>
	<cfset NoDates = 1>
</cfif>

<cfif IsDefined("SubStatus")>
	<cfif SubStatus Is "All">
		<cfquery name="CheckSubAccounts" datasource="#pds#">
			SELECT AccntPlanID 
			FROM AccntPlans 
			WHERE NextDueDate < #CreateODBCDateTime(CheckDate)# 
			AND AccountID IN 
				(SELECT AccountID 
				 FROM Multi 
				 WHERE PrimaryID = #AccountID#)
		</cfquery>
		<cfif CheckSubAccounts.Recordcount GT 0>
			<cfset NoDates = 1>
		</cfif>
	</cfif>
<cfelse>
	<cfset SubStatus = "Ignore">
</cfif>
<cfif NoDates Is 0>
	<cfset BillMethod = 1>
	<cfset SkipTwo = 1>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="custcan3.cfm">
	<cfabort>
</cfif>

<cfif IsDefined("BillMethod")>
	<cfset TheBMethod = BillMethod>
<cfelse>
	<cfset TheBMethod = "">
</cfif>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Cancel</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custcan.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<cfoutput>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
 	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Billing</font></th>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tbclr#">One or more plans will have a billing date before #LSDateFormat(CheckDate, '#DateMask1#')#.<br>
		How should gBill handle these billing dates?</td>
	</tr>
	<form method="post" action="custcan3.cfm">
		<tr>
			<th bgcolor="#tdclr#"><input type="Radio" <cfif TheBMethod Is "1">checked</cfif> name="BillMethod" value="1"></th>
			<td bgcolor="#tbclr#">Stop billing now</td>
		</tr>
		<tr>
			<th bgcolor="#tdclr#"><input type="Radio" <cfif TheBMethod Is "2">checked</cfif> name="BillMethod" value="2"></th>
			<td bgcolor="#tbclr#">Prorate the last billing</td>
		</tr>
		<tr>
			<th bgcolor="#tdclr#"><input type="Radio" <cfif TheBMethod Is "3">checked</cfif> name="BillMethod" value="3"></th>
			<td bgcolor="#tbclr#">Full amount on next billing</td>
		</tr>
		<tr>
			<th colspan="2"><input type="Image" src="images/continue.gif" name="Step2" border="0"></th>
		</tr>
		<input type="Hidden" name="BillMethod_Required" value="Please select the method to handle the billing.">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="hidden" name="ReturnTo" value="custcan2.cfm">
		<input type="hidden" name="SkipTwo" value="0">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 