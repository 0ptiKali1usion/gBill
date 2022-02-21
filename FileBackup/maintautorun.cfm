<cfsetting enablecfoutputonly="Yes">
<!-- Version 4.0.0 -->
<!--- This page allows entries in the autorun table to be scheduled and ran automatically. --->
<!--- 4.0.1 02/01/01 Modifed to work with cfcancelaccnt.cfm 
		4.0.0	03/03/00 --->
<!-- maintautorun.cfm -->
<!--- Actual AutoRuns 
Cancel
	AccountID - The accountid of the person to be cancelled.
	AccntPlanID - The accounts to be cancelled.  If 0 then all for the accountid are cancelled.
	Memo1 - The reason.
	Value1 - If 1 Then delete calls history. If 0 then save history.
	Value2 - The location that scheduled the cancel event.
	ScheduledBy - The admin that scheduled this event.
	WhenRun - The date and time for this to happen.

Deactivate
	AccountID - The accountid of the person to be deactivated.
	AccntPlanID - The accounts to be deactivated.  If 0 then all for the accountid are deactivated.
	AuthID - The actual auth account to be reactivared.  If 0 then all for the AccntPlanID are reactivated.	Memo1 - The reason.
	ScheduledBy - The admin that scheduled this event.
	Value2 - The location that scheduled the deactivation.
	WhenRun - The date and time for this to happen.
	
Rollback
	PlanID - The planid to change to.
	Memo1 - The reason for changing.
	Memo2 - BOBHist String
	AccountID - The ID to rollback.
	AccntPlanID - The plan to be rolled back.
	AuthID - The actual auth account to be reactivared.  If 0 then all for the AccntPlanID are reactivated.
	ScheduledBy - Who scheduled this.
	Value2 - The location that scheduled the rollback.
	DoAction - Rollbacks
	WhenRun - The date and time for this to happen.

Reactivate
	AccountID - The accountid of the person to be reactivated.
	AccntPlanID - The accounts to be reactivated.  If 0 then all for the accountid are reactivated.
	AuthID - The actual auth account to be reactivared.  If 0 then all for the AccntPlanID are reactivated.
	Memo1 - The reason.
	Value1 - The location that scheduled the reactivation.
	ScheduledBy - The admin that scheduled this event.
	WhenRun - The date and time for this to happen.
	Date1 - The date to make the account next due on.
	
EMailDelay 
	AccountID - The accountid of the person being emailed.
	EMailFrom - From address 
	EMailSubject - Subject
	EMailTo - To address
	EMailCC - CC address'
	FileAttach - The file to be attached
	Value1 - Server
	Value2 - Port
	Memo1 - The Message
	WhenRun - The date and time for this to happen.
	ScheduledBy - The admin that scheduled this event.
	Memo2 - Reason

DeleteFile
	FileAttach - The file to be deleted.

RunCustom
	value2 - The Custom CFM to run
	accountid - The Id to send to the Custom CFM

PlanTypeChangeBack
	AccountID
	AuthID
	AccntPlanID
	Value1 - 1= Set to rollback tyoe,  2 = Set to Old Filter
	ScheduledBy
	WhenRun

RadiusCleanUp
	Value1 - Datasource of Radius 
	Value2 - Table Name
	EMailFrom - UserName Field
	BillMethod - 1 = Delete   2 = Update to: AppendChar & AccountID & EMailFrom 
	EMailFrom - Radius UserName
	AccountID - AccountID

IPAD 
	value1 - File Type (Slip, FTP, or EMail)
	WhenRun
	ScheduledBy
--->
<!--- Reset 0 values in Transactions --->
<cfquery name="ResetDebits" datasource="#pds#">
	UPDATE TransActions Set 
	DebitLeft = 0 
	WHERE TransID IN 
		(SELECT T.TransID
		 FROM Transactions T 
		 WHERE T.DebitLeft < 0.001 
		 And T.DebitLeft > 0)
</cfquery>
<cfquery name="ResetCredits" datasource="#pds#">
	UPDATE TransActions Set 
	CreditLeft = 0 
	WHERE TransID IN 
		(SELECT T.TransID
		 FROM Transactions T 
		 WHERE T.CreditLeft < 0.001 
		 And T.CreditLeft > 0)
</cfquery>
<!--- AutoRun --->
<cfparam name="ARType" default="All">
<cfparam name="ARAccountID" default="0">
<cfparam name="ARAccntPlanID" default="0">

<cfquery name="GetSomeValues" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE VarName In ('DelAccount','DeactAccount','DateMask1','Locale')
</cfquery>
<cfloop query="GetSomeValues">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfset MidNight = CreateDateTime(year(Now()),month(Now()),day(Now()),0,0,0)>
<cfquery name="seeifjobs" datasource="#pds#" maxrows="50">
	SELECT * 
	FROM AutoRun
	WHERE WhenRun < #Now()# 
	<cfif ARType Is Not "All">
		AND DoAction = '#ARType#'
	</cfif> 
	<cfif ARAccountID Is Not "0">
		AND AccountID = #ARAccountID# 
	</cfif>
	<cfif ARAccntPlanID Is Not "0">
		AND AccntPlanID = #ARAccntPlanID# 
	</cfif>
	ORDER BY AutoRunID 
</cfquery>
<cfset mymessage = "">
<cfif seeifjobs.recordcount is not 0>
  	<cfloop query="seeifjobs">
		<cfif DoAction Is "EMailDelay">
			<cfif NonDemoSendEMail Is 1>
				<cfif Value2 Is "">
					<cfset ThePort = "25">
				<cfelse>
					<cfset ThePort = Value2>
				</cfif>
				<cfif FileAttach Is "">
					<cfset TheFileAttach = "">
				<cfelse>
					<cfif FileExists("#FileAttach#")>
						<cfset TheFileAttach = FileAttach>
					<cfelse>
						<cfset TheFileAttach = "">
					</cfif>
				</cfif>
				<cfif (Trim(Value1) Is Not "") AND (Trim(TheFileAttach) Is Not "")>
					<cfmail to="#EMailTo#" from="#EMailFrom#" subject="#EMailSubject#" 
					 server="#Value1#" port="#ThePort#" cc="#EMailCC#" mimeattach="#TheFileAttach#">
#Memo1#
</cfmail>
				<cfelseif (Trim(Value1) Is Not "") AND (Trim(TheFileAttach) Is "")>
					<cfmail to="#EMailTo#" from="#EMailFrom#" subject="#EMailSubject#" 
					 server="#Value1#" port="#ThePort#" cc="#EMailCC#">
#Memo1#
</cfmail>
				<cfelse>
					<cfmail to="#EMailTo#" from="#EMailFrom#" subject="#EMailSubject#" cc="#EMailCC#">
#Memo1#
</cfmail>
				</cfif>
			</cfif>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist 
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				('#Memo1#', #AccountID#, 0, #Now()#, 'gBill Automatic', '#ScheduledBy# scheduled an email to #EMailTo#. #Memo2#')
			</cfquery>
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "Rollback">
			<cfquery name="GetPlanValues" datasource="#pds#">
				SELECT Value1, VarName 
				FROM Setup 
				WHERE VarName In ('DeactAccount','DelAccount')
			</cfquery>
			<cfloop query="GetPlanValues">
				<cfset "#VarName#" = Value1>
			</cfloop>
			<cfif PlanID Is DeactAccount>
				<cfquery name="SchDeact" datasource="#pds#">
					INSERT INTO AutoRun 
					(PlanID, AccountID, AccntPlanID, AuthID, Memo1, Memo2, ScheduledBy, DoAction, WhenRun)
					VALUES 
					(#PlanID#, #AccountID#, #AccntPlanID#, <cfif AuthID Is "">Null<cfelse>#AuthID#</cfif>, 
					<cfif Memo1 Is "">Null<cfelse>'#Memo1#'</cfif>, 
					<cfif Memo2 Is "">Null<cfelse>'#Memo2#'</cfif>, 'gBill Auto Hour Check', 'Deactivate',#Now()#)
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist 
					(AccountID, AdminID, ActionDate, Action, ActionDesc)
					VALUES 
					(#AccountID#, 0, #Now()#, 'gBill Automatic', 'Deactivation scheduled due to the scheduled rollback being the deactivated plan.')
				</cfquery>	
				<cfquery name="RemoveAction" datasource="#pds#">
					DELETE FROM AutoRun 
					WHERE AutoRunID = #AutoRunID#
				</cfquery>
			<cfelseif PlanID Is DelAccount>
				<cfquery name="SchCancel" datasource="#pds#">
					INSERT INTO AutoRun 
					(DoAction, WhenRun, AccountID, AccntPlanID, Memo1, Value1, Value2, ScheduledBy)
					VALUES 
					('Cancel', #Now()#,#AccountID#, #AccntPlanID#, <cfif Trim(Memo1) Is "">Null<cfelse>'#Memo1#'</cfif>, 1 
					 'accntmanage9.cfm', 'Auto Rollback')
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist 
					(AccountID, AdminID, ActionDate, Action, ActionDesc)
					VALUES 
					(#AccountID#, 0, #Now()#, 'gBill Automatic', 'Cancellation scheduled due to the scheduled rollback being the cancelled plan.')
				</cfquery>	
				<cfquery name="RemoveAction" datasource="#pds#">
					DELETE FROM AutoRun 
					WHERE AutoRunID = #AutoRunID#
				</cfquery>
			<cfelse>
				<cfquery name="GetCurPlan" datasource="#pds#">
					SELECT PlanDesc 
					FROM Plans 
					WHERE PlanID = 
						(SELECT PlanID 
						 FROM AccntPlans 
						 WHERE AccntPlanID = #AccntPlanID#)
				</cfquery>
				<cfquery name="GetNewPlan" datasource="#pds#">
					SELECT PlanDesc, ExpireTo, ExpireDays
					FROM Plans 
					WHERE PlanID = 
						(SELECT PlanID 
						 FROM AccntPlans 
						 WHERE AccntPlanID = #PlanID#)
				</cfquery>
				<cfif GetNewPlan.ExpireDays GT 0>
					<!--- Set The Rollback --->
					<cfset DateToRollBack = DateAdd("d",PlanRollbacks.ExpireDays,Now())>
					<cfset DateRollBack = CreateDateTime(Year(DateToRollBack),Month(DateToRollBack),Day(DateToRollBack),0,0,0)>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT PlanID, PlanDesc 
						FROM Plans 
						WHERE PlanID = #PlanRollbacks.ExpireTo# 
					</cfquery>
					<cfif CheckFirst.Recordcount GT 0>
						<cfquery name="RollBackSched" datasource="#pds#">
							INSERT INTO AutoRun 
							(WhenRun, DoAction, PlanID, Memo1, Memo2, AccountID, AccntPlanID, AuthID, ScheduledBy) 
							VALUES 
							(#CreateODBCDateTime(DateRollBack)#, 'Rollback', #GetNewPlan.ExpireTo#,
							 'Scheduled to change from #GetNewPlan.PlanDesc# to #CheckFirst.PlanDesc#', 
							 'Scheduled to change from #GetNewPlan.PlanDesc# to #CheckFirst.PlanDesc# on #LSDateFormat(DateRollBack, '#DateMask1#')#',
							 #AccountID#, #AccntPlanID#, 0, '#StaffMemberName.FirstName# #StaffMemberName.Lastname#') 
						</cfquery>
					</cfif>
				</cfif>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE AccntPlans SET 
					PlanID = #PlanID# 
					WHERE AccntPlanID = #AccntPlanID# 
				</cfquery>		
				<cfif Memo2 Is "">
					<cfset DescOfAction = "Plan rolled back from #GetCurPlan.PlanDesc# to #GetNewPlan.PlanDesc# due to being out of hours.">
				<cfelse>
					<cfset DescOfAction = Memo2>
				</cfif>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist 
					(AccountID, AdminID, ActionDate, Action, ActionDesc)
					VALUES 
					(#AccountID#, 0, #Now()#, 'gBill Automatic', '#DescOfAction#')
				</cfquery>	
				<cfquery name="RemoveAction" datasource="#pds#">
					DELETE FROM AutoRun 
					WHERE AutoRunID = #AutoRunID#
				</cfquery>
			</cfif>
		<cfelseif DoAction Is "Cancel">
			<cfset LocAccntPlanID = AccntPlanID>
			<cfset LocReason = Memo1>
			<cfset LocDelete = Value1>
			<cfset LocScheduledBy = ScheduledBy>
			<cfset SendAccountID = AccountID>
			<cfif (AuthID Is Not "") AND (AuthID Is Not 0)>
				<cfset LocAuthID = AuthID>
			</cfif>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT CancelYN 
				FROM Accounts 
				WHERE AccountID = #AccountID# 
				AND CancelYN = 0 
			</cfquery>
			<cfif CheckFirst.RecordCount GT 0>
				<cf_cfcancelaccnt AccountID="#AccountID#" AccntPlanID="#AccntPlanID#" 
				 CancelReason="#Memo1#" DeleteHist="#Value1#" ScheduledBy="#ScheduledBy#" 
				 IntLocation="#Value2#">
			</cfif>
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "Deactivate">
			<cfset LocAccntPlanID = AccntPlanID>
			<cfset SendAccountID = AccountID>
			<cfset LocScheduledBy = ScheduledBy>
			<cfset LocReason = Memo1>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AccountID 
				FROM Accounts 
				WHERE AccountID = #AccountID# 
				AND DeactivatedYN = 0 
			</cfquery>
			<cfif CheckFirst.RecordCount Is 0>
				<cfinclude template="cfdeactivate.cfm">
			</cfif>
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "Reactivate">
			<cfset LocAccntPlanID = AccntPlanID>
			<cfset SendAccountID = AccountID>
			<cfset LocScheduledBy = ScheduledBy>
			<cfset LocReason = Memo1>
			<cfinclude template="cfreactivate.cfm">
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "PlanTypeChangeBack">
			<cfset LocAuthID = AuthID>
			<cfset LocType = Value1>
			<cfinclude template="cfchangeauth.cfm">
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "RadiusCleanUp">
			<cfif BillMethod Is 1>
				<cfquery name="RemoveRadius" datasource="#Value1#">
					DELETE FROM #Value2# 
					WHERE #EMailFrom# = '#EMailSubject#'
				</cfquery>
			<cfelse>
				<cfquery name="UpdRadius" datasource="#Value1#">
					UPDATE #Value2# SET 
					#EMailFrom# = '#EMailTo#' 
					WHERE #EMailFrom# = '#EMailSubject#'
				</cfquery>
			</cfif>
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "RunCustom">
			<cfif FileExists("#GetDirectoryFromPath(CF_TEMPLATE_PATH)##value2#")>
				<cfset LocID = AccountID>
				<cfinclude template="#value2#">
			</cfif>		
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "PermanentCustom">
			<cfif FileExists("#GetDirectoryFromPath(CF_TEMPLATE_PATH)##value2#")>
				<cfinclude template="#value2#">
			</cfif>		
		<cfelseif DoAction Is "IPAD">
			<cfset IPADType = Value1>
			<cfset Rescheduled = Value2>
			<cfinclude template="ipadfiles.cfm">
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		<cfelseif DoAction Is "DeleteFile">
			<cfif FileExists("#fileAttach#")>
				<cffile action="DELETE" file="#fileAttach#"> 
			</cfif>
			<cfquery name="RemoveAction" datasource="#pds#">
				DELETE FROM AutoRun 
				WHERE AutoRunID = #AutoRunID#
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<!--- Delete Old Reports --->
<cfif ARType Is "All">
<cfquery name="AllAdmins" datasource="#pds#">
	SELECT PrivRep, AdminID 
	FROM Admin 
	WHERE AdminID In 
		(SELECT AdminID 
		 FROM GrpLists 
		 GROUP BY AdminID) 
</cfquery>
<cfif AllAdmins.RecordCount GT 0>
	<cfloop query="AllAdmins">
		<cfif PrivRep GT 0>
			<cfset DelDate = DateAdd("d",-#PrivRep#,Now())>
			<cfquery name="GetReports" datasource="#pds#">
				DELETE FROM GrpListInfo 
				WHERE AdminID = #AdminID# 
				AND ReportID IN 
					(SELECT ReportID 
					 FROM GrpLists 
					 WHERE AdminID = #AdminID# 
					 AND CreateDate < #DelDate# 
					 GROUP BY ReportID )
			</cfquery>
			<cfquery name="DelOld" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE AdminID = #AdminID# 
				AND CreateDate < #DelDate# 			
			</cfquery>
			<cfquery name="DelOldEMails" datasource="#pds#">
				DELETE FROM EMailOutgoing 
				WHERE AdminID = #AdminID# 
				AND CreateDate < #DelDate# 			
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<!--- Delete old gBill History --->
<cfquery name="AllHistAdmins" datasource="#pds#">
	SELECT KeepDays, AdminID 
	FROM Admin 
	WHERE AdminID In 
		(SELECT AdminID 
		 FROM BOBHist 
		 WHERE AccountID = 0 
		 GROUP BY AdminID)
</cfquery>
<cfif AllHistAdmins.RecordCount GT 0>
	<cfloop query="AllHistAdmins">
		<cfif KeepDays GT 0>
			<cfset DelHDate = DateAdd("d",-KeepDays,Now())>
			<cfquery name="DelOldHist" datasource="#pds#">
				DELETE FROM BOBHist 
				WHERE AdminID = #AdminID# 
				AND ActionDate < #DelHDate# 
				AND (AccountID Is NULL OR AccountID = 0) 
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<!--- Reset Radius timelimits --->
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT DateValue1 
	FROM Setup 
	WHERE VarName = 'ResetAuth' 
</cfquery>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="InsData" datasource="#pds#">
		INSERT INTO Setup 
		(DateValue1, VarName, AutoLoadYN, Description) 
		VALUES 
		(#Now()#,'ResetAuth',0,'Last Time Reset Auth time limits ran.')
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT DateValue1 
		FROM Setup 
		WHERE VarName = 'ResetAuth' 	
	</cfquery>
</cfif>
<cfif CheckFirst.DateValue1 LT Midnight>
	<cftransaction>
		<cfquery name="ResetAuths" datasource="#pds#">
			UPDATE AccountsAuth SET 
			AccountsAuth.EMailedYN = 0, 
			AccountsAuth.SecondsLeft = S.BaseAmount*3600, 
			AccountsAuth.EMailDate = Null, 
			AccountsAuth.MonthTotalTime = S.BaseAmount*3600, 
			AccountsAuth.EMailSecsLeft = P.EMailWarn*3600 
			FROM AccountsAuth AS A, AccntPlans AS AP, Plans AS P, Spans AS S 
			WHERE A.AccntPlanID = AP.AccntPlanID 
			AND AP.PlanID = P.PlanID 
			AND P.planid = S.PlanID 
			AND DatePart(dd,AP.NextDueDate) = #DatePart("d",Now())# 
		</cfquery>
		<cfquery name="UpdSetup" datasource="#pds#">
			UPDATE SETUP SET 
			DateValue1 = #Now()# 
			WHERE VarName = 'ResetAuth' 
		</cfquery>
	</cftransaction>
</cfif>

<cfsetting enablecfoutputonly="No" showdebugoutput="Yes">
<html>
<head>
<title>Auto Run</title>
</head>
<body>
<cfoutput>
	#mymessage#
</cfoutput>
Done.
</body>
</html>

</cfif>