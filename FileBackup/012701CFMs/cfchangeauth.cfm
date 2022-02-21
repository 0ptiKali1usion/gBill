<!--- Version 4.0.0 --->
<!--- This page deactivates an account. It needs accountid. 
It runs as cfinclude but functions like a custom tag. --->
<!---	4.0.0 10/29/99 
		3.2.0 09/08/98 
		3.1.1 08/24/98 Modified to work with custom authentication.
		3.1.0 07/15/98 --->
<!--- cfdeactivate.cfm --->
<cfset TheAuthID = LocAuthID
<!--- Get Account Info --->
<cfquery name="GetInfo" datasource="#pds#">
	SELECT PlanID 
	FROM AccntPlans 
	WHERE AccntPlanID = 
		(SELECT AccntPlanID 
		 FROM AccountsAuth 
		 WHERE AuthID = #TheAuthID#)
</cfquery>
<cfquery name="PlanInfo" datasource="#pds#">
	SELECT HoursUp, RollBackTo2 
	FROM Plans 
	WHERE PlanID = 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = 
		 	(SELECT AccntPlanID 
			 FROM AccountsAuth 
			 WHERE AuthID = #TheAuthID#)
		)
</cfquery>
<cfif PlanInfo.Recordcount GT 0>
	<cfif PlanInfo.HoursUP Is 3>
		<cfquery name="AuthInfo" datasource="#pds#">
			SELECT * 
			FROM AccountsAuth 
			WHERE AuthID = #TheAuthID# 
		</cfquery>
		<cfquery name="GetMyAuthDetails" datasource="#pds#">
			SELECT C.DBName, C.CAuthID, A.AuthDescription 
			FROM CustomAuthSetup C, CustomAuth A 
			WHERE C.CAuthID = A.CAuthID 
			AND C.BOBName = 'authodbc' 
			AND A.CAuthID = 
				(SELECT CAuthID 
				 FROM Domains 
				 WHERE DomainID = 
				 	(SELECT DomainID 
					 FROM AccountsAuth 
					 WHERE AuthID = #TheAuthID#)
				)
		</cfquery>
		<cfset CAuthID = GetMyAuthDetails.CAuthID>
		<cfquery name="GetTableName" datasource="#pds#">
			SELECT DBName, CRSID 
			FROM CustomAuthSetup 
			WHERE BOBName = 'accounts' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetLoginName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'accntlogin' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfquery name="GetType" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE BOBName = 'acnttype' 
			AND CAuthID = #CAuthID#
		</cfquery>
		<cfif (GetTableName.DBName is not "") AND (GetLoginName.DBName is not "")
   	 AND (GetType.DBName is not "")>
		 	<cfif LocType Is 1>
				<cfquery name="UpdType" datasource="#GetMyAuthDetails.DBName#">
					UPDATE #GetTableName.DBName# SET 
					#GetType.DBName# = '#PlanInfo.RollBack2#' 
					WHERE #GetLoginName.DBName# = '#AuthInfo.UserName#'
				</cfquery>
			<cfelse>
				<cfquery name="UpdType" datasource="#GetMyAuthDetails.DBName#">
					UPDATE #GetTableName.DBName# SET 
					#GetType.DBName# = '#AuthInfo.OldFilter#' 
					WHERE #GetLoginName.DBName# = '#AuthInfo.UserName#'
				</cfquery>
			</cfif>
		</cfif>
	 	<cfif LocType Is 1>
			<cfquery name="UpdAuth" datasource="#pds#">
				UPDATE AccountsAuth SET 
				OldFilter = Filter, 
				Filter1 = '#PlanInfo.RollBack2#' 
				WHERE AuthID = #TheAuthID# 
			</cfquery>
		<cfelse>
			<cfquery name="UpdAuth" datasource="#pds#">
				UPDATE AccountsAuth SET 
				Filter1 = '#AuthInfo.OldFilter#' 
				WHERE AuthID = #TheAuthID# 
			</cfquery>
		</cfif>
		<!--- Run Auth Scripts --->
		<cfquery name="GetScripts" datasource="#pds#">
			SELECT I.IntID 
			FROM Integration I, IntScriptLoc S, IntLocations L 
			WHERE I.IntID = S.IntID 
			AND S.LocationID = L.LocationID 
			AND L.ActiveYN = 1 
			AND I.ActiveYN = 1 
			AND L.PageName = 'cfchangeauth.cfm' 
			AND L.LocationAction = 'Change' 
			AND I.TypeID = 
				(SELECT TypeID 
				 FROM IntTypes 
				 WHERE TypeStr = 'Authentication') 
		</cfquery>		
		<cfif GetScripts.RecordCount GT 0>
			<cfset LocScriptID = ValueList(GetScripts.IntID)>
			<cfset LocAuthID = TheAuthID>
			<cfset LocAccntPlanID = AuthInfo.AccntPlanID>
			<cfsetting enablecfoutputonly="no">
			<cfinclude template="runintegration.cfm">
			<cfsetting enablecfoutputonly="yes">
		</cfif>
	</cfif>
</cfif> 
 