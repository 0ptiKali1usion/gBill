<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Reactivates entire account. --->
<!---	4.0.1 02/05/01 Fixed an error when the next due day is greater than the number of days in the month.
		4.0.0 04/19/00 --->
<!--- reactivate2.cfm --->

<cfif GetOpts.ReactAcnt Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif DeactWhen Is "Now">
	<cfset LocReactDate = Now()>
<cfelse>
	<cfset LocReactDate = WhenRun>
</cfif>
<cfset NoDates = 0>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccntPlanID 
	FROM AccntPlans 
	WHERE AccountID = #AccountID# 
	AND PlanID = #DeactAccount#
	AND ReactivateTo Not In 
		(SELECT PlanID 
		 FROM Plans) 
</cfquery>
<cfif CheckFirst.RecordCount GT 0>
	<cfquery name="CleanUp" datasource="#pds#">
		UPDATE AccntPlans SET 
		ReactivateTo = 
			(SELECT PlanID 
			 FROM Plans 
			 WHERE DefPlan =1)
		WHERE AccountID = #AccountID# 
		AND PlanID = #DeactAccount#
		AND ReactivateTo Not In 
			(SELECT PlanID 
			 FROM Plans) 
	</cfquery>
</cfif>
<cfquery name="CheckAccounts" datasource="#pds#">
	SELECT A.*, P.PlanDesc, P.RecurringAmount, P.RecurDiscount, P.RecurringCycle 
	FROM AccntPlans A, Plans P 
	WHERE A.ReactivateTo = P.PlanID 
	AND A.AccountID = #AccountID# 
	AND P.RecurringAmount - P.RecurDiscount > 0 
</cfquery>
<cfparam name="BillMethod" default="2">
<cfif IsDefined("SubStatus")>
	<cfif SubStatus Is "All">
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT AccntPlanID 
			FROM AccntPlans 
			WHERE AccountID <> #AccountID#
			AND AccountID IN 
				(SELECT AccountID 
				 FROM Multi 
				 WHERE PrimaryID = #AccountID#)
			AND PlanID = #DeactAccount#
			AND ReactivateTo Not In 
				(SELECT PlanID 
				 FROM Plans) 
		</cfquery>
		<cfif CheckFirst.RecordCount GT 0>
			<cfquery name="CleanUp" datasource="#pds#">
				UPDATE AccntPlans SET 
				ReactivateTo = 
					(SELECT PlanID 
					 FROM Plans 
					 WHERE DefPlan =1)
				WHERE AccountID <> #AccountID#
				AND AccountID IN 
					(SELECT AccountID 
					 FROM Multi 
					 WHERE PrimaryID = #AccountID#)
				AND PlanID = #DeactAccount#
				AND ReactivateTo Not In 
					(SELECT PlanID 
					 FROM Plans) 
			</cfquery>
		</cfif>
		<cfquery name="CheckSubAccounts" datasource="#pds#">
			SELECT A.*, P.PlanDesc, P.RecurringAmount, P.RecurDiscount, P.RecurringCycle 
			FROM AccntPlans A, Plans P 
			WHERE A.ReactivateTo = P.PlanID 
			AND AccountID <> #AccountID#
			AND AccountID IN 
				(SELECT AccountID 
				 FROM Multi 
				 WHERE PrimaryID = #AccountID#)
			AND AccntPlanID In 
				(SELECT A.AccntPlanID 
				 FROM AccntPlans A, Plans P 
				 WHERE A.ReactivateTo = P.PlanID 
				 AND A.AccountID = #AccountID# 
				 AND P.RecurringAmount - P.RecurDiscount > 0 )
		</cfquery>
	</cfif>
<cfelse>
	<cfset SubStatus = "Ignore">
</cfif>
<cfif IsDefined("CheckSubAccounts")>
	<cfparam name="ReactPlans" default="#ValueList(CheckAccounts.AccntPlanID)#,#ValueList(CheckSubAccounts.AccntPlanID)#">
<cfelse>
	<cfparam name="ReactPlans" default="#ValueList(CheckAccounts.AccntPlanID)#">
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
<title>Reactivate</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="reactivate.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
	<cfoutput>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="MemoReason" value="#MemoReason#">
		<input type="Hidden" name="BillMethod" value="#BillMethod#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
 	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Billing</font></th>
	</tr>
	<form method="post" action="reactivate3.cfm">
		<tr>
			<th bgcolor="#tdclr#"><input type="Radio" <cfif BillMethod Is "1">checked</cfif> name="BillMethod" value="1"></th>
			<td bgcolor="#tbclr#" colspan="3">Start billing on next due date</td>
		</tr>
		<tr valign="top">
			<cfif IsDefined("CheckSubAccounts")>
				<cfset SubHigh = CheckSubAccounts.RecordCount>
				<cfset ExtraHigh = 4>
			<cfelse>
				<cfset SubHigh = 0>
				<cfset ExtraHigh = 3>
			</cfif>
			<cfset HowTall = ExtraHigh + CheckAccounts.Recordcount + SubHigh>
			<th bgcolor="#tdclr#" rowspan="#HowTall#"><input type="Radio" <cfif BillMethod Is "2">checked</cfif> name="BillMethod" value="2"></th>
			<td bgcolor="#tbclr#" colspan="3">Prorate from #LSDateFormat(WhenRun, '#DateMask1#')# to next due date.</td>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Select</th>
			<th>Reactivate To</th>
			<th>Next Due Date</th>
		</tr>
</cfoutput>
		<cfoutput query="CheckAccounts">
			<tr valign="top">
				<th bgcolor="#tdclr#"><input type="Checkbox" <cfif ListFind(ReactPlans,AccntPlanID)>checked</cfif> name="ReactPlans" value="#AccntPlanID#"></th>
				<td bgcolor="#tbclr#">#PlanDesc#</td>
				<cfif Not IsDefined("NextDue")>
					<cfif IsDefined("NextDueDate#AccntPlanID#")>
						<cfset NextDue = Evaluate("NextDueDate#AccntPlanID#")>
					<cfelse>
						<cfif Day(NextDueDate) GT DaysInMonth(LocReactDate)>
							<cfset locDayNext = DaysInMonth(LocReactDate)>
						<cfelse>
							<cfset locDayNext = Day(NextDueDate)>
						</cfif>
						<cfset NextDue = CreateDateTime(Year(LocReactDate),Month(LocReactDate),locDayNext,0,0,0)>
						<cfif NextDue LT LocReactDate>
							<cfset NextDue = DateAdd("m",1,NextDue)>
						</cfif>
					</cfif>
				</cfif>
				<td bgcolor="#tdclr#"><input type="Text" name="NextDueDate#AccntPlanID#" value="#LSDateFormat(NextDue, '#DateMask1#')#" size="12"></td>
			</tr>
		</cfoutput>
		<cfif IsDefined("CheckSubAccounts")>
			<cfif CheckSubAccounts.RecordCount GT 0>
				<cfoutput>
					<tr>
						<th colspan="3" bgcolor="#thclr#">Sub Accounts</th>
					</tr>
				</cfoutput>
				<cfoutput query="CheckSubAccounts">
					<tr valign="top">
						<th bgcolor="#tdclr#"><input type="Checkbox" <cfif ListFind(ReactPlans,AccntPlanID)>checked</cfif> name="ReactPlans" value="#AccntPlanID#"></th>
						<td bgcolor="#tbclr#">#PlanDesc#</td>
						<cfif Not IsDefined("NextDue")>
							<cfset NextDue = CreateDateTime(Year(Now()),Month(Now()),Day(NextDueDate),0,0,0)>
							<cfif NextDue LT Now()>
								<cfset NextDue = DateAdd("m",1,NextDue)>
							</cfif>
						</cfif>
						<td bgcolor="#tdclr#"><input type="Text" name="NextDueDate#AccntPlanID#" value="#LSDateFormat(NextDue, '#DateMask1#')#" size="12"></td>
					</tr>
				</cfoutput>
			</cfif>
		</cfif>
<cfoutput>
		<tr>
			<th colspan="3" bgcolor="#tbclr#">All of the above will be Reactivated on #LSDateFormat(WhenRun, '#DateMask1#')#.<br> Only the selected ones will be charged.</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<th><input type="Checkbox" <cfif IsDefined("ChargReactFee")>checked</cfif> name="ChargReactFee" value="1"></th>
			<cfif IsDefined("ReactFee")>
				<cfset TheFee = ReactFee>
			<cfelse>
				<cfset TheFee = "">
			</cfif>
			<td colspan="3">Charge Activation Fee of <input type="Text" name="ReactFee" value="#TheFee#" size="8"></td>
		</tr>
		<tr bgcolor="#tdclr#">
			<th>&nbsp;</th>
			<td colspan="3"><input type="Text" name="MemoReason" value="#MemoReason#" size="40"></td>
		</tr>
		<tr>
			<th colspan="4"><input type="Image" src="images/continue.gif" name="Step2" border="0"></th>
		</tr>
		<input type="Hidden" name="BillMethod_Required" value="Please select the method to handle the billing.">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="Hidden" name="DeactWhen" value="#DeactWhen#">
		<input type="Hidden" name="WhenRun" value="#WhenRun#">
		<input type="Hidden" name="SubStatus" value="#SubStatus#">
		<input type="hidden" name="ReturnTo" value="reactivate2.cfm">
		<input type="Hidden" name="AllIDs" value="#ReactPlans#">
	</form>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 