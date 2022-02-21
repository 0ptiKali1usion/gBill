<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 11/01/99 --->
<!--- accntmanage3.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="PrevDate" datasource="#pds#">
	SELECT NextDueDate, PlanID 
	FROM AccntPlans 
	WHERE AccntPlanID = #AccntPlanID# 
</cfquery>
<cfquery name="PlanDetails" datasource="#pds#">
	SELECT * 
	FROM Plans 
	WHERE PlanID = #PrevDate.PlanID# 
</cfquery>
<cfif PrevDate.NextDueDate GT NextDueDate>
	<cfset NextDuePlan = DateAdd("m",-PlanDetails.RecurringCycle,PrevDate.NextDueDate)>
	<cfset DaysNumber = ABS(DateDiff("d",PrevDate.NextDueDate,NextDuePlan))>
	<cfset DayAmount = (PlanDetails.RecurringAmount - PlanDetails.RecurDiscount)/(DaysNumber)>
	<cfset DaysNumber2 = DateDiff("d",PrevDate.NextDueDate,NextDueDate)>
	<cfset ProRateAmount = DayAmount * ABS(DaysNumber2)>
<cfelseif PrevDate.NextDueDate LT NextDueDate>
	<cfset NextDuePlan = DateAdd("m",PlanDetails.RecurringCycle,PrevDate.NextDueDate)>
	<cfset DaysNumber = DateDiff("d",PrevDate.NextDueDate,NextDuePlan)>
	<cfset DayAmount = (PlanDetails.RecurringAmount - PlanDetails.RecurDiscount)/(DaysNumber)>
	<cfset DaysNumber2 = DateDiff("d",PrevDate.NextDueDate,NextDueDate)>
	<cfset ProRateAmount = DayAmount * ABS(DaysNumber2)>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Next Due Date Change</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="accntmanage2.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
</form>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Next Due Date Change</font></th>
	</tr>
	<tr bgcolor="#tbclr#">
		<td align="right">Previous Due Date</td>
		<td>#LSDateFormat(PrevDate.NextDueDate, '#DateMask1#')#</td>
	</tr>
	<tr bgcolor="#tbclr#">
		<td align="right">New Due Date</td>
		<td>#LSDateFormat(NextDueDate, '#DateMask1#')#</td>
	</tr>
	<tr bgcolor="#tbclr#">
		<td align="right">Prorated Amount</td>
		<td>#LSCurrencyFormat(ProRateAmount)#</td>
	</tr>
	<form method="post" action="accntmanage2.cfm">
		<tr bgcolor="#tbclr#">
			<td align="right">How to apply the prorate</td>
			<td bgcolor="#tdclr#"><select name="ProrateHandle">
				<option value="0">Do not apply
				<option value="1">Charge the customer
				<option value="2">Credit the customer
			</select></td>		
		</tr>
		<tr bgcolor="#tbclr#">
			<td align="right">Reason</td>
			<td bgcolor="#tdclr#"><input type="text" name="ProrateReason" value="Prorate for changing next due date" maxlength="200" size="35"></td>
		</tr>
		<tr>
			<th colspan="2"><input type="image" name="EditDueDate" src="images/continue.gif" border="0"></th>
		</tr>
		<input type="hidden" name="ProRateAmount" value="#ProRateAmount#">
		<input type="hidden" name="POPID" value="#POPID#">
		<input type="hidden" name="NextDueDate" value="#NextDueDate#">
		<input type="hidden" name="AuthAccounts" value="#AuthAccounts#">
		<input type="hidden" name="FTPAccounts" value="#FTPAccounts#">
		<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
		<input type="hidden" name="EMailAccounts" value="#EMailAccounts#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 