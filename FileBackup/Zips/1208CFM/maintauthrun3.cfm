<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 03/21/00 --->
<!--- maintauthrun3.cfm --->

<cfquery name="GetDeactivates" datasource="#pds#">
	SELECT A.AccntPlanID, P.PlanID, A.AccountID, R.AuthID 
	FROM AccountsAuth R, AccntPlans A, Plans P 
	WHERE R.AccntPlanID = A.AccntPlanID 
	AND A.PlanID = P.PlanID 
	AND R.WarningAction = 2 
	AND R.SecondsLeft <= 0 
	AND R.DeactSchedYN = 0 
</cfquery>
<cfif GetDeactivates.RecordCount GT 0>
	<cfquery name="SchedDeact" datasource="#pds#">
		INSERT INTO AutoRun 
		(PlanID, AccountID, AccntPlanID, AuthID, Memo1, ScheduledBy, DoAction, WhenRun)
		SELECT P.RollBackTo, A.AccountID, A.AccntPlanID, R.AuthID, 'Used up allowed hours.',
		'gBill Auto Hour Check', 'Rollback', #Now()# 
		FROM AccountsAuth R, AccntPlans A, Plans P 
		WHERE R.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND R.WarningAction = 2 
		AND R.SecondsLeft <= 0 
		AND R.DeactSchedYN = 0 
	</cfquery>
	<cfquery name="BOBHist" datasource="#pds#">
		INSERT INTO BOBHist 
		(AccountID, AdminID, ActionDate, Action, ActionDesc)
		SELECT A.AccountID, 0, #Now()#, 'gBill Automatic', 'Scheduled Plan Rollback due to over plan hours.' 
		FROM AccountsAuth R, AccntPlans A, Plans P 
		WHERE R.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND R.WarningAction = 2 
		AND R.SecondsLeft <= 0 
		AND R.DeactSchedYN = 0 
	</cfquery>
	<cfquery name="SetFlag" datasource="#pds#">
		UPDATE AccountsAuth SET 
		DeactSchedYN = 1 
		WHERE AuthID In 
			(SELECT R.AuthID
			 FROM AccountsAuth R, AccntPlans A, Plans P 
			 WHERE R.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND R.WarningAction = 2 
			 AND R.SecondsLeft <= 0 
			 AND R.DeactSchedYN = 0)
	</cfquery>
	<cfloop query="GetDeactivates" >
		<!--- Find First of their month --->
		<cfquery name="GetDate" datasource="#pds#">
			SELECT NextDueDate 
			FROM AccntPlans
			WHERE AccntPlanID = #AccntPlanID# 
		</cfquery>
		<cfset ThisMonth = Now()>
		<cfset FirstMonth = CreateDateTime(Year(ThisMonth),Month(ThisMonth),DatePart("d",GetDate.NextDueDate),0,0,0)>
		<cfif FirstMonth LT Now()>
			<cfset FirstMonth = DateAdd("m",1,FirstMonth)>
		</cfif>
		<!--- Schedule React --->
		<cfquery name="SchedReact" datasource="#pds#">
			INSERT INTO AutoRun 
			(PlanID, AccountID, AccntPlanID, AuthID, Memo1, ScheduledBy, DoAction, WhenRun)
			VALUES 
			(#PlanID#, #AccountID#, #AccntPlanID#, #AuthID#, 'Reset hours.', 
			'gBill Auto Hour Check', 'Reactivate', #CreateODBCDateTime(FirstMonth)#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(AccountID, AdminID, ActionDate, Action, ActionDesc)
			VALUES 
			(#AccountID#, 0, #Now()#, 'gBill Automatic', 'Scheduled to be reactivated when their plans hours start over.')
		</cfquery>
	</cfloop>
</cfif>

<!--- Set the Account Type --->
<cfquery name="GetDeactivates2" datasource="#pds#">
	SELECT A.AccntPlanID, P.PlanID, A.AccountID, R.AuthID 
	FROM AccountsAuth R, AccntPlans A, Plans P 
	WHERE R.AccntPlanID = A.AccntPlanID 
	AND A.PlanID = P.PlanID 
	AND R.WarningAction = 3 
	AND R.SecondsLeft <= 0 
	AND R.DeactSchedYN = 0 
</cfquery>
<cfif GetDeactivates2.RecordCount GT 0>
	<cfquery name="SchedDeact" datasource="#pds#">
		INSERT INTO AutoRun 
		(PlanID, AccountID, AccntPlanID, AuthID, Value1, Memo1, ScheduledBy, DoAction, WhenRun)
		SELECT P.PlanID, A.AccountID, A.AccntPlanID, R.AuthID, 1, 'Used up allowed hours.',
		'gBill Auto Hour Check', 'PlanTypeChangeBack', #Now()# 
		FROM AccountsAuth R, AccntPlans A, Plans P 
		WHERE R.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND R.WarningAction = 3 
		AND R.SecondsLeft <= 0 
		AND R.DeactSchedYN = 0 
	</cfquery>
	<cfquery name="BOBHist" datasource="#pds#">
		INSERT INTO BOBHist 
		(AccountID, AdminID, ActionDate, Action, ActionDesc)
		SELECT A.AccountID, 0, #Now()#, 'gBill Automatic', 'Scheduled Plan Type due to over plan hours.' 
		FROM AccountsAuth R, AccntPlans A, Plans P 
		WHERE R.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND R.WarningAction = 3 
		AND R.SecondsLeft <= 0 
		AND R.DeactSchedYN = 0 
	</cfquery>
	<cfquery name="SetFlag" datasource="#pds#">
		UPDATE AccountsAuth SET 
		DeactSchedYN = 1 
		WHERE AuthID In 
			(SELECT R.AuthID
			 FROM AccountsAuth R, AccntPlans A, Plans P 
			 WHERE R.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND R.WarningAction = 2 
			 AND R.SecondsLeft <= 0 
			 AND R.DeactSchedYN = 0)
	</cfquery>
	<cfloop query="GetDeactivates">
		<!--- Find First of their month --->
		<cfquery name="GetDate" datasource="#pds#">
			SELECT NextDueDate 
			FROM AccntPlans
			WHERE AccntPlanID = #AccntPlanID# 
		</cfquery>
		<cfset ThisMonth = Now()>
		<cfset FirstMonth = CreateDateTime(Year(ThisMonth),Month(ThisMonth),DatePart("d",GetDate.NextDueDate),0,0,0)>
		<cfif FirstMonth LT Now()>
			<cfset FirstMonth = DateAdd("m",1,FirstMonth)>
		</cfif>
	<!--- Schedule A changeback --->
		<cfquery name="SchedReact" datasource="#pds#">
			INSERT INTO AutoRun 
			(PlanID, AccountID, AccntPlanID, AuthID, Value1, Memo1, ScheduledBy, DoAction, WhenRun)
			VALUES 
			(#PlanID#, #AccountID#, #AccntPlanID#, #AuthID#, 2, 'Reset plan type.',
			'gBill Auto Hour Check', 'PlanTypeChangeBack', #CreateODBCDateTime(FirstMonth)#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist 
			(AccountID, AdminID, ActionDate, Action, ActionDesc)
			VALUES 
			(#AccountID#, 0, #Now()#, 'gBill Automatic', 'Scheduled Plan Type to be reactivated when their plans hours start over.')
		</cfquery>
	</cfloop>
</cfif>
 