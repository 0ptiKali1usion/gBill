<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 03/27/00 --->
<!--- maintsessiondel.cfm --->

<cfquery name="CheckFirst" datasource="#pds#" maxrows="50">
	SELECT * 
	FROM SessionDelete 
</cfquery>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfif DateMask1 Is "">
	<cfset DateMask1 = "mmm/dd/yyyy">
</cfif>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="AllAuthTypes" datasource="#pds#">
		INSERT INTO SessionDelete 
		(UserName, DomainID, CAuthID, SessHistKeep, AccountID)
		SELECT A.UserName, A.DomainID, D.CAuthID, P.SessHistKeep, AP.AccountID 
		FROM Domains D, AccountsAuth A, AccntPlans AP, Plans P 
		WHERE D.DomainID = A.DomainID 
		AND A.AccntPlanID = AP.AccntPlanID 
		AND AP.PlanID = P.PlanID 
		AND P.SessHistKeep > 0 
		GROUP BY A.UserName, A.DomainID, D.CAuthID, P.SessHistKeep, AP.AccountID
	</cfquery>
	<cfquery name="AddAuthODBC" datasource="#pds#">
		UPDATE SessionDelete SET 
		ODBCName = C.DBName 
		FROM CustomAuthSetup C, SessionDelete S 
		WHERE C.CAuthID = S.CAuthID 
		AND C.BOBName = 'accntodbc' 
	</cfquery>
	<cfquery name="RemoveIncorrects" datasource="#pds#">
		DELETE FROM SessionDelete 
		WHERE ODBCName Is Null 
	</cfquery>
	<cfquery name="AddAuthTable" datasource="#pds#">
		UPDATE SessionDelete SET 
		TableName = C.DBName 
		FROM CustomAuthSetup C, SessionDelete S 
		WHERE C.CAuthID = S.CAuthID 
		AND C.BOBName = 'tbcalls' 
	</cfquery>
	<cfquery name="AddAuthUsername" datasource="#pds#">
		UPDATE SessionDelete SET 
		UserNameField = C.DBName 
		FROM CustomAuthSetup C, SessionDelete S 
		WHERE C.CAuthID = S.CAuthID 
		AND C.BOBName = 'callslogin' 
	</cfquery>
	<cfquery name="AddAuthDateName" datasource="#pds#">
		UPDATE SessionDelete SET 
		CallDateName = C.DBName 
		FROM CustomAuthSetup C, SessionDelete S 
		WHERE C.CAuthID = S.CAuthID 
		AND C.BOBName = 'calldatetime' 
	</cfquery>
	<cfquery name="AddAuthDateName" datasource="#pds#">
		UPDATE SessionDelete SET 
		CallDateName = C.DBName 
		FROM CustomAuthSetup C, SessionDelete S 
		WHERE C.CAuthID = S.CAuthID 
		AND C.BOBName = 'calldate' 
		AND S.CallDateName Is Null 
	</cfquery>
<cfelse>
	<cfloop query="CheckFirst">
		<cfif (ODBCName Is Not "") AND (TableName Is Not "") 
		 AND (CallDateName Is Not "") AND (UserNameField Is Not "")>
		 	<cfset Date1 = DateAdd("d","-#SessHistKeep#",Now())>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist 
				(AccountID, AdminID, ActionDate, Action, ActionDesc)
				VALUES 
				(#AccountID#, 0, #Now()#, 'gBill Automatic','#Username# session history older than #LSDateFormat(Date1 ,'#DateMask1#')# was deleted.')
			</cfquery>
			<cfquery name="AllAuthInfo" datasource="#ODBCName#">
				DELETE FROM #TableName# 
				WHERE #CallDateName# < #Date1# 
				AND #UserNameField# = '#UserName#' 
			</cfquery>
			<cfquery name="ClearTable" datasource="#pds#">
				DELETE 
				FROM SessionDelete 
				WHERE UserName = '#UserName#' 
				AND DomainID = #DomainID# 
			</cfquery>
		<cfelse>
			<cfquery name="AuthInfo" datasource="#pds#">
				SELECT * 
				FROM CustomAuth 
				WHERE CAuthID = #CAuthID#
			</cfquery>
			<cfquery name="GetEMail" datasource="#pds#">
				SELECT Value1 
				FROM Setup 
				WHERE VarName = 'warnemail' 
			</cfquery>
			<cfmail to="#GetEMail.Value1#" from="#GetEMail.Value1#" subject="Incorrect Configuration For #AuthInfo.AuthDescription#">
Incorrect Configuration For #AuthInfo.AuthDescription#.
Please enter the Table and field names.<br>
This automatic session delete needs the following information to work:
	ODBC Datasource Name
	Session History Table Name
	Calls Username
	Date Time
The needed information can be entered on the Authentication Setup page.
#HTTP_HOST##Replace(Path_Info,"maintsessiondel.cfm","customauthsetup.cfm")#
</cfmail>
		</cfif>
	</cfloop>
</cfif>
 