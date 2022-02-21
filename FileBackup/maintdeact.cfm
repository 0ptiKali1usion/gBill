<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Deactivates past due accounts --->
<!---	4.0.0 08/15/00 --->
<!--- maintdeact.cfm --->

<cfparam name="MinAmountOwe" default="0.009">

<cfquery name="GetPlans" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName = 'DeactAccount' 
	OR VarName = 'DelAccount' 
</cfquery>
<cfloop query="GetPlans">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfquery name="WhoIsDue" datasource="#pds#">
	INSERT INTO AutoRun 
	(Memo1, WhenRun, DoAction, AccountID, AccntPlanID, PlanID, ScheduledBy, BillMethod)
	SELECT 'Deactivated due to late payment.', #Now()#, 'Deactivate', P.AccountID, 0, P.PlanID, 'gBill', 1 
	FROM AccntPlans P 
	WHERE PlanID NOT IN (#DeactAccount#, #DelAccount#) 
	AND P.AccountID IN 
		(SELECT A.AccountID 
		 FROM Accounts A 
		 WHERE NoAuto = 0) 
	AND P.AccountID IN 
		(SELECT T.AccountID
		 FROM TransActions T 
		 GROUP BY T.AccountID 
		 HAVING Sum(Debit-Credit) > #MinAmountOwe#) 
	AND P.AccountID IN 
		(SELECT T.AccountID 
		 FROM TransActions T 
		 WHERE AccntCutOffDate < #Now()# 
		 AND DebitLeft > 0.009) 	
</cfquery>

<html>
<head>
<title>Schedule Deactivations</title>
</head>
<body>
Deactivations scheduled
</body>
</html>