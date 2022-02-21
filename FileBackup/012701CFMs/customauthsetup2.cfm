<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the authentication database setup. --->
<!--- 4.0.0 06/24/99
		3.2.0 09/08/98 --->
<!--- customauthsetup2.cfm --->

<cfset securepage="customauthsetup.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("SetGeneric")>
	<cfparam name="AuthType" default="ODBC">
	<cfparam name="GenericFCDelim" default=",">
	<cfparam name="GenericFVDelim" default=",">
	<cfparam name="CreateFCDelim" default=",">
	<cfparam name="CreateFVDelim" default=",">
	<cfparam name="CreateFV2Delim" default=",">
	<cfparam name="CreateFV3Delim" default=",">
	<cfset intcode = "Authentication">
	<cfinclude template="integration/#TheCode#.cfm">
	<cfset counter = 1>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetAuth" datasource="#pds#">
			SELECT AuthDescription 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null, 0, #MyAdminID#, #Now()#, 'System', 
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the custom auth #GetAuth.AuthDescription# to #TheDisp#.') 
		</cfquery>
	</cfif>
	<cfquery name="UpdDT" datasource="#pds#">
		UPDATE CustomAuth SET 
		AuthType = <cfif AuthType Is "Text">0<cfelse>1</cfif> 
		WHERE CAuthID = #CAuthID# 
	</cfquery>
	<cfquery name="ResetValues" datasource="#pds#">
		UPDATE CustomAuthSetup SET 
		ActiveYN = 0, 
		DBName = Null, 
		SortOrder = 0 
		WHERE CAuthID = #CAuthID# 
		AND CFVarYN = 1 
	</cfquery>
	<cfloop index="B5" list="#GenericFieldCodes#" delimiters="#GenericFCDelim#">
		<cfset TheValue = ListGetAt(GenericFieldValues,counter,"#GenericFVDelim#")>
		<cfif Trim(TheValue) Is Not "">
			<cfquery name="UpdRad" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				DBName = '#Trim(TheValue)#', 
				ActiveYN = 1 
				WHERE BOBName = '#B5#' 
				AND CAuthID = #CAuthID# 
			</cfquery>
		</cfif>
		<cfset counter = counter + 1>
	</cfloop>
	<cfquery name="ForTables" datasource="#pds#">
		SELECT ForTable 
		FROM CustomAuthSetup 
		WHERE CAuthID = #CAuthID# 
		AND DBType = 'Tb' 
		GROUP BY ForTable 
	</cfquery>
	<cfloop query="ForTables">
		<cfquery name="ResetSort" datasource="#pds#">
			SELECT CRSID 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ActiveYN = 1 
			AND DBType = 'Fd' 
			AND ForTable = #ForTable# 
			ORDER BY SortOrder, Descrip1 
		</cfquery>
		<cfloop query="ResetSort">
			<cfquery name="SetNewSort" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				SortOrder = #CurrentRow# 
				WHERE CRSID = #CRSID# 
			</cfquery>
		</cfloop>
	</cfloop>
	<cfquery name="removeold" datasource="#pds#">
		Delete FROM CustomAuthAccount 
		WHERE CAuthID = #CAuthID#
	</cfquery>
	<cfset counter = 1>
	<cfloop index="B5" list="#CreateFieldCodes#" delimiters="#CreateFCDelim#">
		<cfset thevalue = ListGetAt(CreateFieldValues,counter, "#CreateFVDelim#")>
		<cfset thevalu2 = ListGetAt(Createfieldvalues2,counter,"#CreateFV2Delim#")>
		<cfset thevalu3 = ListGetAt(Createfieldvalues3,counter,"#CreateFV3Delim#")>
		<cfquery name="updrad" datasource="#pds#">
			INSERT INTO CustomAuthAccount 
			(dbfieldname, DataNeed, DataType, OrderBy, CAuthID)
			VALUES 
			('#B5#','#Trim(thevalue)#','#Trim(thevalu2)#',#thevalu3#, #CAuthID#)
		</cfquery>
		<cfset counter = counter + 1>
	</cfloop>
</cfif>
<cfif IsDefined("EnterOne.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CAAID 
		FROM CustomAuthAccount 
		WHERE CAuthID = #CAuthID# 
		AND DBFieldName = '#Trim(DBFieldName)#'
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="enterdata" datasource="#pds#">
			INSERT INTO CustomAuthAccount 
			(DBFieldName, DataNeed, OrderBy, DataType, CAuthID) 
			Values 
			('#Trim(DBFieldName)#', '#DataNeed#', #OrderBy#, '#DataType#', #CAuthID#)
		</cfquery>
	<cfelse>
		<cfset DispError = "The field #Trim(DBFieldName)# is already in the create setup.<br>Two fields with the same name is not allowed in a database table.">
		<cfif OrderBy Is 1>
			<cfset tab = 11>
		<cfelse>
			<cfset tab = 12>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("DeleteField.x")>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM CustomAuthAccount 
		WHERE CAAID In (#DelThese#)
	</cfquery>
</cfif>
<cfif IsDefined("EditOne.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("CAAID#B5#")>
		<cfset var2 = Evaluate("DBFieldName#B5#")>
		<cfset var3 = Evaluate("DataNeed#B5#")>
		<cfset var4 = Evaluate("DataType#B5#")>
		<cfquery name="editdata" datasource="#pds#">
			UPDATE CustomAuthAccount SET 
			DBFieldName = <cfif Trim(var2) Is "">Null<cfelse>'#var2#'</cfif>,
			DataNeed = <cfif Trim(var3) Is "">Null<cfelse>'#var3#'</cfif>,
			DataType = <cfif Trim(var4) Is "">Null<cfelse>'#var4#'</cfif> 
			WHERE CAAID = #var1#
		</cfquery>
	</cfloop>
</cfif>
<cfif (IsDefined("MvRt")) AND (IsDefined("TheHaveNots"))>
	<cfquery name="MvEmRight" datasource="#pds#">
		UPDATE Domains SET 
		CAuthID = #CAuthID# 
		WHERE DomainID IN (#TheHaveNots#)
	</cfquery>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("TheHaves"))>
	<cfquery name="MvEmLeft" datasource="#pds#">
		UPDATE Domains SET 
		CAuthID = 0 
		WHERE DomainID IN (#TheHaves#)
	</cfquery>
</cfif>
<cfif (IsDefined("DelAuth.x")) AND (IsDefined("DelThese"))>
	<cfquery name="ForTables" datasource="#pds#">
		SELECT ForTable 
		FROM CustomAuthSetup 
		WHERE CAuthID = #CAuthID# 
		AND CRSID In (#DelThese#) 
		GROUP BY ForTable 
	</cfquery>
	<cfquery name="DelThese" datasource="#pds#">
		DELETE FROM CustomAuthSetup 
		WHERE CRSID In (#DelThese#) 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfloop query="ForTables">
		<cfquery name="ResetSort" datasource="#pds#">
			SELECT CRSID 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ActiveYN = 1 
			AND DBType = 'Fd' 
			AND ForTable = #ForTable# 
			ORDER BY SortOrder, Descrip1 
		</cfquery>
		<cfloop query="ResetSort">
			<cfquery name="SetNewSort" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				SortOrder = #CurrentRow# 
				WHERE CRSID = #CRSID# 
			</cfquery>
		</cfloop>
	</cfloop>
</cfif>
<cfif IsDefined("AddField.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CRSID 
		FROM CustomAuthSetup 
		WHERE DBName = '#DBName#' 
		AND CAuthID = #CAuthID# 
		AND ForTable = #ForTable# 
		AND DBType = 'Fd' 
	</cfquery>
	<cfif CheckFirst.RecordCount GT 0>
		<cfquery name="TableName" datasource="#pds#">
			SELECT DBName 
			FROM CustomAuthSetup 
			WHERE ForTable = #ForTable# 
			AND CAuthID = #CAuthID# 
			AND DBType = 'Tb' 
		</cfquery>
		<cfset tab = 21>
		<cfset DispError = "The field #DBName# already exists in the #TableName.DBName# table.">
		<cfset TheForTable = ForTable>
	<cfelse>
		<cfquery name="GetSort" datasource="#pds#">
			SELECT Max(SortOrder) as LastOne 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ForTable = #ForTable# 
			AND DBType = 'Fd' 
		</cfquery>
		<cfquery name="OtherValues" datasource="#pds#">
			SELECT ODBCSType, UseTab 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ForTable = #ForTable# 
			AND DBType = 'Tb' 
		</cfquery>
		<cfset NewSort = GetSort.LastOne>
		<cfif NewSort Is "">
			<cfset NewSort = 1>
		<cfelse>
			<cfset NewSort = NewSort + 1>
		</cfif>
		<cfquery name="AddMe" datasource="#pds#">
			INSERT INTO CustomAuthSetup 
			(DBType, Descrip1, DBName, CFVarYN, SortOrder, ForTable, ODBCSType, UseTab, 
			 DataType, CAuthID, ReportTotal, ReportUse, ActiveYN, BOBName) 
			VALUES 
			('Fd', '#Descrip1#', '#DBName#', 0, #NewSort#, #ForTable#, '#OtherValues.ODBCSType#', #OtherValues.UseTab#, 
			 '#DataType#', #CAuthID#, 0, 0, 1, 'Custom') 
		</cfquery>
		<cfif OtherValues.UseTab Is 1>
			<cfset tab = 1>
		<cfelse>
			<cfset tab = 3>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("EnterInfo.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT CRSID 
		FROM CustomAuthSetup 
		<cfif Tab Is 1>
			WHERE UseTab = 1 
		<cfelseif Tab Is 3>
			WHERE UseTab = 2 
		<cfelse> 
			WHERE UseTab = 0 
		</cfif>
		AND CAuthID = #CAuthID# 
		AND 
			(ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID = #CAuthID#)
			 OR ForTable Is Null
			 )
		ORDER BY ForTable, DBType DESC, ActiveYN Desc, SortOrder, Descrip1
	</cfquery>
	<cfloop index="B5" list="#ValueList(GetFields.CRSID)#">
		<cfif IsDefined("ActiveYN#B5#")>
			<cfset var1 = 1>
		<cfelse>
			<cfset var1 = 0>
		</cfif>
		<cfif IsDefined("DBName#B5#")>
			<cfset var2 = Evaluate("DBName#B5#")>
		<cfelse>
			<cfset var2 = "">
		</cfif>
		<cfif IsDefined("DataType#B5#")>
			<cfset var3 = Evaluate("DataType#B5#")>
		<cfelse>
			<cfset var3 = "">
		</cfif>
		<cfif IsDefined("DBType#B5#")>
			<cfset var5 = Evaluate("DBType#B5#")>
		<cfelse>
			<cfset var5 = "Fd">
		</cfif>
		<cfif IsDefined("SortOrder#B5#")>
			<cfset var4 = Evaluate("SortOrder#B5#")>
		<cfelse>
			<cfif var5 Is "Fd">
				<cfquery name="CheckFor" datasource="#pds#">
					SELECT CRSID 
					FROM CustomAuthSetup 
					WHERE ForTable = 
						(SELECT ForTable 
						 FROM CustomAuthSetup 
						 WHERE CRSID = #B5#) 
					AND ActiveYN = 1 
					AND CAuthID = #CAuthID# 
				</cfquery>
				<cfset var4 = CheckFor.RecordCount>
			<cfelse>
				<cfset var4 = 0>
			</cfif>
		</cfif>
		<cfif IsDefined("ReportTotal#B5#")>
			<cfset var6 = Evaluate("ReportTotal#B5#")>
		<cfelse>
			<cfset var6 = 0>
		</cfif>
		<cfif IsDefined("ReportUse#B5#")>
			<cfset var7 = Evaluate("ReportUse#B5#")>
		<cfelse>
			<cfset var7 = 0>
		</cfif>
		<cfif IsDefined("UseYN#B5#")>
			<cfset var8 = Evaluate("UseYN#B5#")>
		<cfelse>
			<cfset var8 = 0>
		</cfif>
		<cfif IsDefined("Descrip1#B5#")>
			<cfset descrip = Evaluate("Descrip1#B5#")>
			<cfif trim(descrip) Is Not "">
				<cfset var9 = descrip>
			</cfif>
		</cfif>
		<cfif var1 Is 0>
			<cfset var2 = "">
			<cfset var3 = "">
			<cfset var4 = 0>
			<cfset var6 = 0>
			<cfset var7 = 0>
			<cfset var8 = 0>
		</cfif>
		<cfquery name="UpdInfo" datasource="#pds#">
			UPDATE CustomAuthSetup SET 
			ActiveYN = #var1#, 
			DBName = <cfif Trim(var2) Is "">Null<cfelse>'#Trim(var2)#'</cfif>, 
			DataType = <cfif Trim(var3) Is "">Null<cfelse>'#Trim(var3)#'</cfif>, 
			<cfif IsDefined("var9")>
				Descrip1 = '#var9#', 
			</cfif>
			ReportTotal = #var6#, 
			ReportUse = #var7#, 
			UseYN = #var8#, 
			SortOrder = #var4# 
			WHERE CRSID = #B5# 
		</cfquery>
	</cfloop>
	<cfquery name="ForTables" datasource="#pds#">
		SELECT ForTable 
		FROM CustomAuthSetup 
		WHERE CAuthID = #CAuthID# 
		AND ActiveYN = 1 
		AND DBType = 'Tb' 
	</cfquery>
	<cfloop query="ForTables">
		<cfquery name="ResetSort" datasource="#pds#">
			SELECT CRSID 
			FROM CustomAuthSetup 
			WHERE CAuthID = #CAuthID# 
			AND ActiveYN = 1 
			AND DBType = 'Fd' 
			AND ForTable = #ForTable# 
			ORDER BY SortOrder 
		</cfquery>
		<cfloop query="ResetSort">
			<cfquery name="SetNewSort" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				SortOrder = #CurrentRow# 
				WHERE CRSID = #CRSID# 
			</cfquery>
		</cfloop>
	</cfloop>
</cfif>
<cfif IsDefined("SetGeneral.x")>
	<cfif IsDefined("LastComplete")>
		<cfif IsDate(LastComplete)>
			<cfset NDT = LSParseDateTime(LastComplete)>
		<cfelse>
			<cfset NDT = DateAdd("m",-1,Now())>
		</cfif>
		<cfset NextDateTime = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
	</cfif>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetAuth" datasource="#pds#">
			SELECT AuthDescription 
			FROM CustomAuth 
			WHERE CAuthID = #CAuthID# 
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CustomAuth SET 
		AuthDescription = '#AuthDescription#', 
		AuthType = #AuthType#, 
		SessLookup = #SessLookup#, 
		<cfif IsDefined("NextDateTime")>LastImport = #CreateODBCDateTime(NextDateTime)#,</cfif> 
		<cfif IsDefined("NextDateTime")>LastComplete = #CreateODBCDateTime(NextDateTime)#,</cfif> 
		<cfif IsDefined("LastCompleteSpan")>LastImportSpan = #CreateODBCDateTime(LastCompleteSpan)#,</cfif> 
		<cfif IsDefined("LastCompleteSpan")>LastCompleteSpan = #CreateODBCDateTime(LastCompleteSpan)#,</cfif> 
		<cfif IsDefined("LastCompleteAmount")>LastImportAmount = #CreateODBCDateTime(LastCompleteAmount)#,</cfif> 
		<cfif IsDefined("LastCompleteAmount")>LastCompleteAmount = #CreateODBCDateTime(LastCompleteAmount)#,</cfif> 
		UniqueBy = #UniqueBY# 
		WHERE CAuthID = #CAuthID# 
	</cfquery>
	<cfquery name="GetTables" datasource="#pds#">
		SELECT CRSID 
		FROM CustomAuthSetup 
		WHERE DBType = 'TB' 
		AND CAuthID = #CAuthID# 
		ORDER BY Descrip1
	</cfquery>
	<cfset ActiveList = "">
	<cfset InActiveList = "">
	<cfloop query="GetTables">
		<cfif IsDefined("ActiveYN#CRSID#")>
			<cfset ActiveList = ListAppend(ActiveList,#CRSID#)>
		<cfelse>
			<cfset InActiveList =  ListAppend(InActiveList,#CRSID#)>
		</cfif>
	</cfloop>
	<cfif ActiveList Is Not "">
		<cfquery name="SetActive" datasource="#pds#">
			UPDATE CustomAuthSetup SET 
			ActiveYN = 1 
			WHERE CRSID In (#ActiveList#)
		</cfquery>
	</cfif>
	<cfif InActiveList Is Not "">
		<cfquery name="SetInActive" datasource="#pds#">
			UPDATE CustomAuthSetup SET 
			ActiveYN = 0 
			WHERE CRSID In (#InActiveList#)
		</cfquery>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		
		<cfquery name="ActiveTables" datasource="#pds#">
			SELECT Descrip1 
			FROM CustomAuthSetup 
			WHERE CRSID In <cfif ActiveList Is "">(0)<cfelse>(#ActiveList#)</cfif> 
		</cfquery>
		<cfset BOBHistMess = "#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the custom auth: #AuthDescription#.">
		<cfif ActiveTables.RecordCount GT 0>
			<cfset BOBHistMess = BOBHistMess & "  The following tables were set to active: #ValueList(ActiveTables.Descrip1)#.">
		<cfelse>
			<cfset BOBHistMess = BOBHistMess & "  All tables were set to inactive.">
	  	</cfif>
		<cfif GetAuth.AuthDescription Is Not AuthDescription>
			<cfset BOBHistMess = BOBHistMess & "  The name was changed from #GetAuth.AuthDescription#.">
		</cfif>
		<cfif UniqueBy Is 1>
			<cfset BOBHistMess = BOBHistMess & "  #AuthDescription# was set unique by Domain.">
		<cfelseif UniqueBy Is 2>
			<cfset BOBHistMess = BOBHistMess & "  #AuthDescription# was set unique by Custom Auth.">
		<cfelseif UniqueBy Is 3>
			<cfset BOBHistMess = BOBHistMess & "  #AuthDescription# was set unique globally.">
		</cfif>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#BOBHistMess#')
		</cfquery>
	</cfif>
</cfif>

<cfparam name="tab" default="5">
<cfif (tab is 1) OR (tab Is 3)>
	<cfset HowWide = 6>
	<cfset HowWide2 = 3>
	<cfif tab Is 3>
		<cfset HowWide = HowWide + 2>
		<cfset HowWide2 = 5>
	</cfif>
	<cfquery name="GetDS" datasource="#pds#">
		SELECT * FROM CustomAuthSetup 
		WHERE DBType = 'DS' 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		<cfif tab Is 1>
			WHERE UseTab = 1 
		<cfelseif tab Is 3>
			WHERE UseTab = 2 
		<cfelse>
			WHERE UseTab = 0 
		</cfif>
		AND CAuthID = #CAuthID# 
		AND 
			(ForTable In 
				(SELECT ForTable 
				 FROM CustomAuthSetup 
				 WHERE DBType = 'Tb' 
				 AND ActiveYN = 1 
				 AND CAuthID = #CAuthID#)
			 OR ForTable Is Null
			 )
		ORDER BY ForTable, DBType DESC, ActiveYN Desc, SortOrder, Descrip1 
	</cfquery>
<cfelseif tab is 2>
	<cfset HowWide = 4>
	<cfquery name="GetAccountInfo" datasource="#pds#">
		SELECT * 
		FROM CustomAuthAccount 
		WHERE CAuthID = #CAuthID# 
		ORDER BY DBFieldName
	</cfquery>
	<cfquery name="GetVariables" datasource="#pds#">
		SELECT * 
		FROM IntVariables 
		WHERE CustomYN = 0 
		AND UseCreateYN = 1 
		ORDER BY UseText
	</cfquery>
<cfelseif tab Is 4>
	<cfset HowWide = 3>
	<cfquery name="GetSelected" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, CustomAuth A 
		WHERE D.CauthID = A.CauthID 
		AND D.CAuthID = #CAuthID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="AvailOnes" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, A.AuthDescription 
		FROM Domains D, CustomAuth A 
		WHERE D.CauthID = A.CauthID 
		AND D.CAuthID <> #CAuthID# 
		UNION 
		SELECT D.DomainID, D.DomainName, 'None' as AuthDescription 
		FROM Domains D 
		WHERE D.CAuthID = 0 
		OR D.CAuthID Is Null 
		ORDER BY DomainName
	</cfquery>
<cfelseif tab Is 5>
	<cfset HowWide = 2>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfquery name="GetAuthValues" datasource="#pds#">
		SELECT * 
		FROM CustomAuth 
		WHERE CAuthID = #CAuthID#
	</cfquery>
	<cfquery name="GetTables" datasource="#pds#">
		SELECT * 
		FROM CustomAuthSetup 
		WHERE DBType = 'TB' 
		AND CAuthID = #CAuthID# 
		ORDER BY Descrip1
	</cfquery>
<cfelseif (tab Is 11) OR (tab Is 12)>
	<cfset HowWide = 3>
	<cfquery name="GetVariables" datasource="#pds#">
		SELECT * 
		FROM IntVariables 
		WHERE CustomYN = 0 
		AND UseCreateYN = 1 
		ORDER BY UseText
	</cfquery>
<cfelseif (tab Is 21) OR (tab Is 23)>
	<cfset HowWide = 2>
	<cfquery name="AuthTables" datasource="#pds#">
		SELECT Descrip1, ForTable, CRSID, DBName  
		FROM CustomAuthSetup 
		WHERE CAuthID = #CAuthID# 
		AND DBType = 'Tb' 
		AND ActiveYN = 1 
		ORDER BY Descrip1 
	</cfquery>
	<cfparam name="DataType" default="Text">
<cfelseif tab Is 11>
	<cfset HowWide = 3>
</cfif>
<cfquery name="SetupDescrip" datasource="#pds#">
	SELECT AuthDescription 
	FROM CustomAuth 
	WHERE CAuthID = #CAuthID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Authentication Setup</title>
<script language="javascript">
<!-- 
function CheckFor()
	{
	 var var1 = document.PickDelete.DelThese.value
	 return confirm ('Please Click Ok to confirm deleting the selected fields.')
	}
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<cfif tab gte 20>
	<form method="post" action="customauthsetup2.cfm">
		<cfoutput>
			<cfset GoToTab = Tab - 20>
			<input type="hidden" name="tab" value="#GoToTab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		<input type="image" src="images/return.gif" border="0">
	</form>
<cfelseif tab gte 10>
	<form method="post" action="customauthsetup2.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="2">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		<input type="image" src="images/return.gif" border="0">
	</form>
<cfelse>
	<form method="post" action="customauthsetup.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#SetupDescrip.AuthDescription# Setup</font></th>
		</tr>
		<cfif tab lte 5>
			<tr>
				<th colspan="#HowWide#">
					<table border="1">
						<tr>
							<form method="post" action="customauthsetup2.cfm">
								<td bgcolor=<cfif tab is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">General</label></td>
								<td bgcolor=<cfif tab is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Authentication</label></td>
								<td bgcolor=<cfif tab is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Accounting</label></td>							
								<td bgcolor=<cfif tab is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Account Creation</label></td>
								<td bgcolor=<cfif tab is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Domains</label></td>
								<input type="hidden" name="CAuthID" value="#CAuthID#">
							</form>
						</tr>
					</table>
				</th>
			</tr>
		</cfif>
		<cfif (tab Is 1) OR (tab Is 3)>
			<tr>
				<form method="post" action="customauthsetup2.cfm">
					<cfset GoToTab = 20 + tab>
					<input type="hidden" name="tab" value="#GoToTab#">
					<input type="hidden" name="CAuthID" value="#CAuthID#">
					<td colspan="#HowWide#" align="right"><input type="image" name="addnew" src="images/addnew.gif" border="0"></td>
				</form>
			</tr>
		</cfif>
</cfoutput>
<cfif (tab is "1") OR (tab is "3")>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Use</th>
			<th>Description</th>
			<th>Field Name</th>
			<th>Data Type</th>
			<cfif tab Is 3>
				<th colspan="3">Session History Report</th>
			<cfelse>
				<th>Sort</th>
			</cfif>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" name="EditInfo" action="customauthsetup2.cfm">
		<cfset LoopCount = 0>
		<cfoutput query="GetFields" group="ODBCSType">
			<cfoutput group="fortable">
				<tr>
					<cfif DBType is "DS">
						<td bgcolor="#thclr#" colspan="#HowWide#">DataSource</td>
					<cfelseif DBType Is "Dt">
						<td bgcolor="#thclr#" colspan="#HowWide#">Database Info</td>
					<cfelseif DBType is "Tb">
						<td bgcolor="#thclr#" colspan="#HowWide#">#Descrip1#</td>
						<cfsetting enablecfoutputonly="Yes">
							<cfquery name="HowMany" datasource="#pds#">
								SELECT CRSID 
								FROM CustomAuthSetup 
								WHERE CAuthID = #CAuthID# 
								AND ForTable = #ForTable# 
								AND DBType = 'Fd' 
								AND ActiveYN = 1 
							</cfquery>
							<cfset SortNumber = HowMany.RecordCount>
							<cfif SortNumber Is "">
								<cfset SortNumber = 0>
							</cfif>
							<cfset "SortNumber#ForTable#" = SortNumber>
						<cfsetting enablecfoutputonly="No">
					</cfif>
				</tr>
				<cfoutput>
					<tr>
						<th bgcolor="#tdclr#"><input type="checkbox" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#CRSID#" value="#CRSID#"><input type="Hidden" name="DBType#CRSID#" value="#DBType#"></th>
						<td bgcolor="#tbclr#"><input type="Text" name="Descrip1#CRSID#" value="#Descrip1#"></td>
						<cfif DBType Is Not "Dt">
							<td bgcolor="#tdclr#"><input type="text" name="DBName#CRSID#" value="#DBName#"></td>
						<cfelse>
							<td bgcolor="#tdclr#"><select name="DBName#CRSID#">
								<option <cfif DBName Is "Access">selected</cfif> value="Access">Access
								<option <cfif DBName Is "SQL">selected</cfif> value="SQL">SQL Server
							</select></td>
						</cfif>
						<cfif DBType Is "Fd">
							<td bgcolor="#tdclr#"><select name="DataType#CRSID#">
								<option value="">N/A
								<option <cfif DataType Is "Date">selected</cfif> value="Date">Date
								<option <cfif DataType Is "Number">selected</cfif> value="Number">Number
								<option <cfif DataType Is "Text">selected</cfif> value="Text">Text
							</select></td>
						<cfelseif DBType Is "Tb">
							<cfif tab Is 1>
								<td colspan="#HowWide2#" bgcolor="#tbclr#">Table</td>
							<cfelse>
								<td bgcolor="#tbclr#">Table</td>
								<th bgcolor="#thclr#">Staff</th>
								<th bgcolor="#thclr#">Cust</th>
								<th bgcolor="#thclr#">Sort</th>
								<th bgcolor="#thclr#">&nbsp;</th>
							</cfif>
						<cfelseif DBType Is "Ds">
							<td colspan="#HowWide2#" bgcolor="#tbclr#">Datasource</td>
						<cfelse>
							<td colspan="#HowWide2#" bgcolor="#tbclr#">&nbsp;</td>
						</cfif>
						<cfif DBType Is "Fd">
							<cfif (tab Is 3) AND (ActiveYN Is 0)>
								<td bgcolor="#tdclr#">&nbsp;</td>
								<!--- <td bgcolor="#tdclr#">&nbsp;</td> --->
								<td bgcolor="#tdclr#">&nbsp;</td>
							<cfelseif (tab Is 3) AND (ActiveYN Is 1)>
								<th bgcolor="#tdclr#"><input type="Checkbox" <cfif ReportUse Is 1>checked</cfif> name="ReportUse#CRSID#" value="1"></th>
								<th bgcolor="#tdclr#"><input type="Checkbox" <cfif UseYN Is 1>checked</cfif> name="UseYN#CRSID#" value="1"></th>
								<!--- <td bgcolor="#tdclr#"><select name="ReportTotal#CRSID#">
									<option <cfif ReportTotal Is 0>selected</cfif> value="0">None
									<option <cfif ReportTotal Is 1>selected</cfif> value="1">Time
									<option <cfif ReportTotal Is 2>selected</cfif> value="2">Number
								</select></td> --->
							</cfif>
							<cfset HowMany = Evaluate("SortNumber#ForTable#")>
							<cfif (HowMany Is 0) OR (ActiveYN Is 0)>
								<td bgcolor="#tdclr#">&nbsp;</td>
							<cfelse>
								<td bgcolor="#tdclr#"><select name="SortOrder#CRSID#">
									<cfloop index="B5" from="1" to="#HowMany#">
										<option <cfif SortOrder Is B5>selected</cfif> value="#B5#">#B5#
									</cfloop>
								</select></td>
							</cfif>
						<cfelseif DBType Is "Tb">
						<cfelse>
						</cfif>
						<cfif (CFVarYN Is 0) AND (DBType Is "Fd" Or DBType Is "Tb")>
							<cfset LoopCount = LoopCount + 1>
							<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#CRSID#" onClick="SetValues(#CRSID#,this)"></th>
						<cfelse>
							<cfif DBType Is "Fd">
								<td bgcolor="#tdclr#">&nbsp;</td>
							<cfelse>
							</cfif>
						</cfif>
					</tr>
				</cfoutput>
			</cfoutput>
		</cfoutput>
		<cfoutput>
		<input type="hidden" name="LoopCount" value="#LoopCount#">
		<input type="hidden" name="tab" value="#tab#">
		<input type="hidden" name="CAuthID" value="#CAuthID#">
		<tr>
			<th colspan="#HowWide#">
				<table border="0">
					<tr>
						<td><input type="image" src="images/update.gif" name="EnterInfo" border="0"></td>
		</cfoutput>
	</form>
	<form method="post" name="PickDelete" action="customauthsetup2.cfm" onSubmit="return confirm('Click Ok to confirm deleting the selected Custom Authentication entries.')">
						<td><input type="image" src="images/delete.gif" name="DelAuth" border="0"></td>
					</tr>
				</table>
			</th>
		</tr>
		<cfoutput>
			<input type="hidden" name="DelThese" value="0">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
	</form>
<cfelseif tab Is "2">
	<cfoutput>
		<tr>
			<form method="post" action="customauthsetup2.cfm">
				<td colspan="4" align="right"><input type="submit" name="addone" value="Add Single Line"><input type="hidden" name="tab" value="11"><input type="hidden" name="CAuthID" value="#CAuthID#"></td>
			</form>
		</tr>
		<tr>
			<form method="post" action="customauthsetup2.cfm">
				<td colspan="4" align="right"><input type="submit" name="addmulti" value="Add Multi Line"><input type="hidden" name="tab" value="12"><input type="hidden" name="CAuthID" value="#CAuthID#"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" name="EditInfo" action="customauthsetup2.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		<cfset counter1 = 0>
		<cfloop query="GetAccountInfo">
			<cfset counter1 = counter1 + 1>
			<cfoutput>
				<tr valign="top" bgcolor="#tdclr#">
					<input type="hidden" name="CAAID#counter1#" value="#CAAID#">
					<input type="hidden" name="OrderBy#counter1#" value="#orderby#">
					<td><select name="DataType#counter1#">
						<option <cfif datatype is "Date">selected</cfif> value="Date">Date
						<option <cfif datatype is "Number">selected</cfif> value="Number">Number
						<option <cfif datatype is "Text">selected</cfif> value="Text">Text
					</select></td>
					<td><input type="text" name="DBFieldName#counter1#" value="#DBFieldName#" maxlength="35" size="30"></td>
					<cfif orderby Is 1>
						<td><input type="text" name="DataNeed#counter1#" value="#DataNeed#" size="20"></td>
					<cfelse>
						<td><textarea name="DataNeed#counter1#" rows="2" cols="30">#DataNeed#</textarea></td>
					</cfif>
					<th><input type="checkbox" name="DelSelected" value="#CAAID#" onClick="SetValues(#CAAID#,this)"></th>
				</tr>
			</cfoutput>
		</cfloop>
		<cfoutput><input type="hidden" name="LoopCount" value="#counter1#"></cfoutput>
		<tr>
			<th colspan="4">
				<table border="0">
					<tr>
						<td><input type="image" src="images/update.gif" name="editone" border="0"></td>
	</form>
	<form method="post" name="PickDelete" action="customauthsetup2.cfm" onSubmit="return CheckFor()">
						<input type="hidden" name="DelThese" value="0">
						<cfoutput>
						<input type="hidden" name="tab" value="#tab#">
						<input type="hidden" name="CAuthID" value="#CAuthID#">
						</cfoutput>
						<td> <input type="image" src="images/delete.gif" name="DeleteField" border="0"></td>		
					</tr>
				</table>		
			</th>
		</tr>
	</form>
<cfelseif tab Is "4">
	<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Available Domains</th>
		<th>Action</th>
		<th>Selected Domains</th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#" colspan="3">Selecting a domain will override the current setup for the selected domain.</td>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<form method="post" action="customauthsetup2.cfm">
			<th><select name="TheHaveNots" multiple size="10">
				<cfloop query="AvailOnes">
					<cfoutput><option value="#DomainID#">#DomainName# - #AuthDescription#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select></th>
			<th align="center" valign="middle"><input type="submit" name="MvRt" value="---->"><br>
			<input type="submit" name="MvLt" value="<----"><br></th>
			<th><select name="TheHaves" multiple size="10">
				<cfloop query="GetSelected">
					<cfoutput><option value="#DomainID#">#DomainName#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select></th>
			<cfoutput>
				<input type="hidden" name="CAuthID" value="#CAuthID#">
				<input type="hidden" name="tab" value="4">
			</cfoutput>
		</form>
	</tr>
<cfelseif tab Is "5">
	<form method="post" action="customauthsetup2.cfm">
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<td align="right">Auth Description</td>
				<td bgcolor="#tdclr#"><input type="Text" name="AuthDescription" value="#GetAuthValues.AuthDescription#" maxlength="255" size="35"></td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Data Type</td>
				<td bgcolor="#tdclr#"><input type="Radio" <cfif GetAuthValues.AuthType Is "0">checked</cfif> name="AuthType" value="0">Text File <input type="Radio" <cfif GetAuthValues.AuthTYpe Is "1">checked</cfif> name="AuthType" value="1">ODBC Database</td>
			</tr>
			<tr bgcolor="#tdclr#" valign="top">
				<td bgcolor="#tbclr#" align="right">Database Tables</td>
		</cfoutput>
				<td><table border="0">
					<cfloop query="GetTables">
						<cfif CurrentRow Is 1><tr></cfif>
							<cfoutput><td><input type="Checkbox" name="ActiveYN#CRSID#" <cfif ActiveYN Is 1>checked</cfif> value="1">#Descrip1#</td></cfoutput>
						<cfif CurrentRow Mod 3 Is 0></tr></cfif>						
						<cfif CurrentRow Mod 3 Is 0 AND CurrentRow Is NOT RecordCount><tr></cfif>
						<cfif CurrentRow Is RecordCount></tr></cfif>
					</cfloop>
				</table></td>
			</tr>
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">Session History Lookup</td>
				<td bgcolor="#tdclr#" ><input type="Radio" <cfif GetAuthValues.SessLookup Is 0>checked</cfif> name="SessLookup" value="0"> Use Login <input type="Radio" <cfif GetAuthValues.SessLookup Is 1>checked</cfif> name="SessLookup" value="1"> Use Login@DomainName</td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Usernames are unique</td>
				<td bgcolor="#tdclr#"><input type="Radio" <cfif GetAuthValues.UniqueBy Is "1">checked</cfif> name="UniqueBy" value="1">By Domain<br>
				<input type="Radio" <cfif GetAuthValues.UniqueBy Is "2">checked</cfif> name="UniqueBy" value="2">By This Custom Auth Only<br>
				<input type="Radio" <cfif GetAuthValues.UniqueBy Is "3">checked</cfif> name="UniqueBy" value="3">Globally - All Custom Auth</td>
			</tr>
			<cfif GetAuthValues.AuthType Is 1>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Monthly Span Import</td>
					<cfif GetAuthValues.LastComplete Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastComplete>
					</cfif>
					<cfset LastComplete = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastComplete" value="#LSDateFormat(LastComplete, '#DateMask1#')# #TimeFormat(LastComplete, 'hh tt')#"> <a href="maintradiusimport.cfm?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Daily Span Import</td>
					<cfif GetAuthValues.LastCompleteSpan Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastCompleteSpan>
					</cfif>
					<cfset LastCompleteS = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastCompleteSpan" value="#LSDateFormat(LastCompleteS, '#DateMask1#')# #TimeFormat(LastCompleteS, 'hh tt')#"> <a href="maintmeterbill.cfm?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Daily $ Calculated</td>
					<cfif GetAuthValues.LastCompleteAmount Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastCompleteAmount>
					</cfif>
					<cfset LastCompleteS = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastCompleteAmount" value="#LSDateFormat(LastCompleteS, '#DateMask1#')# #TimeFormat(LastCompleteS, 'hh tt')#"> <a href="maintmetered.cfm?catchup=1?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td colspan="2">Changing the import times will not reset any metered billing that you have already billed.<br>
               The maximum you can reset is 1 month.</td>
				</tr>
			</cfif>
			<tr>
				<th colspan="2"><input type="Image" src="images/update.gif" border="0" name="SetGeneral"></th>
			</tr>
			<input type="Hidden" name="CAuthID" value="#CAuthID#">
			<input type="Hidden" name="AuthDescription_Required" value="Please enter the description for this authentication setup.">
		</cfoutput>
		<input type="Hidden" name="tab" value="5">
	</form>
<cfelseif tab Is 11>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
		</tr>
		<cfif IsDefined("DispError")>
			<tr>
				<td bgcolor="#tbclr#" colspan="3">#DispError#</td>
			</tr>
		</cfif>
	</cfoutput>
	<form method="post" action="customauthsetup2.cfm">
		<tr>
			<input type="hidden" name="tab" value="2">
			<input type="hidden" name="OrderBy" value="1">
			<td><select name="DataType">
				<option value="Date">Date
				<option value="Number">Number
				<option value="Text">Text
			</select></td>
			<td><input type="text" name="DBFieldName" maxlength="35" size="30"></td>
			<td><input type="text" name="DataNeed" size="30"></td>
			<input type="hidden" name="DBFieldName_required" value="Please enter the Database Field Name.">
			<input type="hidden" name="DataNeed_required" value="Please enter the Data needed.">
		</tr>
		<tr>
			<th colspan="3"><input type="image" src="images/enter.gif" name="EnterOne" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
	</form>
<cfelseif tab Is 12>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
		</tr>
		<cfif IsDefined("DispError")>
			<tr>
				<td bgcolor="#tbclr#" colspan="3">#DispError#</td>
			</tr>
		</cfif>
	</cfoutput>
	<form method="post" action="customauthsetup2.cfm">
		<tr valign="top">
			<input type="hidden" name="tab" value="2">
			<input type="hidden" name="OrderBy" value="0">
			<td><select name="DataType">
				<option <cfif IsDefined("DataType")><cfif DataType Is "Date">selected</cfif></cfif> value="Date">Date
				<option <cfif IsDefined("DataType")><cfif DataType Is "Number">selected</cfif></cfif> value="Number">Number
				<option <cfif IsDefined("DataType")><cfif DataType Is "Text">selected</cfif></cfif> value="Text">Text
			</select></td>
			<cfoutput>
				<td><input type="text" name="DBFieldName" <cfif IsDefined("DBFieldName")>value="#DBFieldName#"</cfif> maxlength="35" size="30"></td>
				<td><textarea rows="5" cols="30" name="DataNeed"><cfif IsDefined("DataNeed")>#DataNeed#</cfif></textarea></td>
				<input type="hidden" name="DBFieldName_required" value="Please enter the Database Field Name.">
				<input type="hidden" name="DataNeed_required" value="Please enter the Data needed.">
			</cfoutput>
		</tr>
		<tr>
			<th colspan="3"><input type="image" src="images/enter.gif" name="EnterOne" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
	</form>
<cfelseif (tab Is 21) OR (tab Is 23)>
	<cfoutput>
		<form method="post" action="customauthsetup2.cfm">
			<cfif IsDefined("DispError")>
				<tr bgcolor="#tbclr#">
					<td colspan="2">#DispError#</td>
				</tr>
			</cfif>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Table Name</td>
	</cfoutput>
				<td><select name="ForTable">
					<cfoutput query="AuthTables">
						<option <cfif IsDefined("TheForTable")><cfif TheForTable Is ForTable>selected</cfif></cfif> value="#ForTable#">#Descrip1# - #DBName#
					</cfoutput>
				</select></td>
			</tr>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Field Name</td>
				<td><input type="text" name="DBName" <cfif IsDefined("DBName")>value="#DBName#"</cfif> size="25" maxlength="45"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td bgcolor="#tdclr#"><input type="text" name="Descrip1" <cfif IsDefined("Descrip1")>value="#Descrip1#"</cfif> maxlength="35" size="35"></td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Data Type</td>
				<td><select name="DataType">
					<option <cfif DataType Is "Date">selected</cfif> value="Date">Date
					<option <cfif DataType Is "Number">selected</cfif> value="Number">Number
					<option <cfif DataType Is "Text">selected</cfif> value="Text">Text
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" border="0" name="AddField"></th>
			</tr>
			<input type="hidden" name="CAuthID" value="#CAuthID#">
			<input type="Hidden" name="tab" value="#tab#">
		</cfoutput>
		</form>
</cfif>
<cfif (tab Is 2) OR (tab Is 11) OR (tab Is 12)>
	<tr>
		<cfset counter1 = 0>
		<cfoutput>
		<th colspan="#HowWide#">
			<table border="1" bgcolor="#tbclr#">
		</cfoutput>
				<cfoutput query="GetVariables">
					<cfset counter1 = counter1  + 1>
					<cfif counter1 Is 1><tr></cfif>
					<td><font size="2">#UseText# = #ForText#</font></td>
					<cfif counter1 Is 3></tr><cfset counter1 = 0></cfif>
				</cfoutput>
				<cfoutput>
					<cfif counter1 Is 1>
						<td>&nbsp;</td><td>&nbsp;</td></tr>
					<cfelseif counter1 Is 2>
						<td>&nbsp;</td></tr>
					<cfelseif counter1 Is 3>
						</tr>
					</cfif>
				</cfoutput>
			</table>
		</th>
	</tr>
</cfif>
</table>


<cfif tab Is "5">
	<cfdirectory action="list" directory="#billpath#cfm/integration" sort="name" filter="*.cfm" name="getint">
	<cfset ShowButton = 0>
	<cfif getint.recordcount gt 0>
		<cfset intcode = "authentication">
		<cfset intcount = 1>
		<table>
			<tr>
				<cfloop query="getint">
					<cfinclude template="integration/#Name#">
					<cfif ShowButton Is 1>
						<cfset intcount = 0>
						<form method="post" action="customauthsetup2.cfm">
							<cfoutput>
								<input type="hidden" name="TheCode" value="#TheCode#">
								<input type="Hidden" name="TheDisp" value="#TheDisp#">
								<td><input type="submit" name="SetGeneric" value="#TheDisp#"></td>
								<input type="hidden" name="CAuthID" value="#CAuthID#">
								<input type="Hidden" name="tab" value="#tab#">
							</cfoutput>
						</form>
					</cfif>
				</cfloop>
			</tr>
		</table>
		<cfif intcount Is 0>
			<cfoutput>
				<table>
					<tr>
						<td bgcolor="#tbclr#">Click on your authentication software for a generic setup.</td>
					</tr>
				</table>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>
<cfinclude template="footer.cfm">
</body>
</html>
 