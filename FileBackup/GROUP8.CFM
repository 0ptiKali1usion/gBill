<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 01/23/01 --->
<!--- group8.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="GetPersonalInfo" datasource="#pds#">
	SELECT * 
	FROM Accounts 
	WHERE AccountID = 
		(SELECT PrimaryID 
		 FROM Multi 
		 WHERE AccountID = #OldAccountID#) 
</cfquery>
<cfquery name="GetGroupID" datasource="#pds#">
	SELECT BillingID 
	FROM Multi 
	WHERE AccountID = #OldAccountID# 
</cfquery>
<cfquery name="GetFields" datasource="#pds#">
	SELECT BOBFieldName, DataType 
	FROM WizardSetup 
	WHERE PageNumber = 1
	AND ActiveYN = 1 
	AND AWUseYN = 1 
	ORDER BY RowOrder, SortOrder
</cfquery>
<cfset LoopCounter = 1>
<cftransaction>
	<cfquery name="TempInfo" datasource="#pds#">
		INSERT INTO AccntTemp 
		(#ValueList(GetFields.BOBFieldName)#,AdminID,TabCompleted,StartDate,WaiveA,CardHold,SalesPersonID,GroupID)
		VALUES 
		(<cfloop index="B5" list="#ValueList(GetFields.BOBFieldName)#">
			<cfset DataType = ListGetAt("#ValueList(GetFields.DataType)#",LoopCounter)>
			<cfset LoopCounter = LoopCounter + 1>
			<cfset FieldValue = Evaluate("GetPersonalInfo.#B5#")>
			<cfif Trim(FieldValue) Is "">NULL,
			<cfelse>
				<cfif DataType Is "Text">'#Trim(FieldValue)#',
				<cfelseif DataType Is "Number">#FieldValue#,
				<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#,
				</cfif>
			</cfif>
		</cfloop>#MyAdminID#,1,#Now()#,0,'#GetPersonalInfo.FirstName# #GetPersonalInfo.LastName#',#MyAdminID#, #GetGroupID.BillingID# )
	</cfquery>
	<cfquery name="NewID" datasource="#pds#">
		SELECT max(AccountID) As MaxID 
		FROM AccntTemp 
	</cfquery>
	<cfset AccountID = NewID.MaxID>
	<cfset tab = 1>
</cftransaction>
<cfinclude template="account1.cfm">


