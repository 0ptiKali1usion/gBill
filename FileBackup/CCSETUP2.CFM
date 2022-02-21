<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page sets up the credit card import format.
--->
<!---	4.0.0 07/26/99 --->
<!--- ccsetup2.cfm --->

<cfset securepage = "ccsetup.cfm">
<cfinclude template="security.cfm">
<cfif (IsDefined("SetGeneric")) AND (IsDefined("CCB"))>
	<cfparam name="FldNameDelim" default=",">
	<cfparam name="FldValueDelim" default=";">
	<cfset IntCode = "CreditCardBatch">
	<cfinclude template="integration/#TheCode#.cfm">
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null, 0, #MyAdminID#, #Now()#, 'System', 
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the credit card batch setup to #TheDisp#.') 
		</cfquery>
	</cfif>
	<cfquery name="ResetTabs" datasource="#pds#">
		UPDATE CustomCCOutput SET 
		UseYN = 0, 
		SortOrder = 100 
		WHERE UseTab In (1,2) 
	</cfquery>
	<cfquery name="RemoveCustom" datasource="#pds#">
		DELETE FROM CustomCCOutput 
		WHERE UseTab In (1,2) 
		AND CFVarYN = 0 
	</cfquery>
	<cfloop index="B5" list="#FieldCodes#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B5,1,#FldValueDelim#)>
		<cfset SortOrder = ListGetAt(B5,2,#FldValueDelim#)>
		<cfquery name="SetOutput" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			UseYN = 1, 
			SortOrder = #SortOrder# 
			WHERE UseTab In (1,2) 
			AND FieldName1 = '#FieldName1#' 
		</cfquery>
	</cfloop>
	<cfloop index="B4" list="#CustomFields1#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B4,1,#FldValueDelim#)>
		<cfset Description1 = ListGetAt(B4,2,#FldValueDelim#)>
		<cfset SortOrder = ListGetAt(B4,3,#FldValueDelim#)> 
		<cfquery name="AddCustom" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab) 
			VALUES 
			('#FieldName1#', <cfif Trim(Description1) Is "">Null<cfelse>'#Trim(Description1)#'</cfif>, 1, #SortOrder#, 0, 1) 
		</cfquery>
	</cfloop>
	<cfloop index="B4" list="#CustomFields2#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B4,1,#FldValueDelim#)>
		<cfset Description1 = ListGetAt(B4,2,#FldValueDelim#)>
		<cfset SortOrder = ListGetAt(B4,3,#FldValueDelim#)> 
		<cfquery name="AddCustom" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab) 
			VALUES 
			('#FieldName1#', <cfif Trim(Description1) Is "">Null<cfelse>'#Trim(Description1)#'</cfif>, 1, #SortOrder#, 0, 2) 
		</cfquery>
	</cfloop>
	<cfloop index="B3" list="#FieldGeneral#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B3,1,#FldValueDelim#)>
		<cfset Description1 = ListGetAt(B3,2,#FldValueDelim#)>
		<cfif Description1 Is "**@**">
			<cfset Description1 = ",">
		</cfif>
		<cfquery name="UpdGeneral" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			Description1 = <cfif Trim(Description1) Is "">Null<cfelse>'#Description1#'</cfif> 
			WHERE UseTab = 0 
			AND FieldName1 = '#FieldName1#' 
		</cfquery>
	</cfloop>
	<cfquery name="ResetAll" datasource="#pds#">
		UPDATE CustomCCInput SET 
		SortOrder = 100, 
		LineOrder = 1, 
		UseYN = 0 
	</cfquery>
	<cfloop index="B2" list="#ImportCodes#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B2,1,#FldValueDelim#)>
		<cfset SortOrder = ListGetAt(B2,2,#FldValueDelim#)>
		<cfset LineOrder = ListGetAt(B2,3,#FldValueDelim#)>
		<cfquery name="SetImport" datasource="#pds#">
			UPDATE CustomCCInput SET 
			SortOrder = #SortOrder#, 
			LineOrder = #LineOrder#, 
			UseYN = 1 
			WHERE FieldName1 = '#FieldName1#' 
		</cfquery>
	</cfloop>
	<cfloop index="B1" list="#ImportGeneral#" delimiters="#FldNameDelim#">
		<cfset FieldName1 = ListGetAt(B1,1,#FldValueDelim#)>
		<cfset Description1 = ListGetAt(B1,2,#FldValueDelim#)>
		<cfquery name="SetGeneral" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			Description1 = '#Description1#' 
			WHERE FieldName1 = '#FieldName1#' 
			AND UseTab = 4 
		</cfquery>
	</cfloop>
</cfif>

<cfif (IsDefined("SetGeneric")) AND (IsDefined("CCLD"))>
	<cfparam name="UseTabDelim" default=",">
	<cfparam name="FldNameDelim" default=",">
	<cfparam name="FldValueDelim" default=",">
	<cfset IntCode = "CreditCardLive">
	<cfinclude template="integration/#TheCode#.cfm">
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null, 0, #MyAdminID#, #Now()#, 'System', 
			 '#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the credit card live debit setup to #TheDisp#.') 
		</cfquery>
	</cfif>
	<cfquery name="ResetValue3" datasource="#pds#">
		UPDATE CustomCCOutput SET 
		UseYN = 0, 
		FieldValue = '0' 
		WHERE UseTab = 3 
	</cfquery>
	<cfquery name="ResetValues5" datasource="#pds#">
		UPDATE CustomCCOutput SET 
		UseYN = 0, 
		FieldValue = Null 
		WHERE UseTab = 5 
	</cfquery>
	<cfquery name="ResetValues7" datasource="#pds#">
		DELETE FROM CustomCCOutput 
		WHERE UseTab = 7 
	</cfquery>
	<cfset counter = 1>
	<cfloop index="B5" list="#FldName#" delimiters="#FldNameDelim#">
		<cfset TheTab = ListGetAt(UseTab,counter,"#UseTabDelim#")>
		<cfset TheValue = ListGetAt(FldValue,counter,"#FldValueDelim#")>
		<cfif TheTab Is 7>
			<cfquery name="AddValue" datasource="#pds#">
				INSERT INTO CustomCCOutput 
				(FieldName1, Description1, UseYN, SortOrder, CFVarYN, UseTab, FieldValue) 
				VALUES 
				('#B5#',Null,1,100,1,7,'#TheValue#') 
			</cfquery>
		<cfelse>
			<cfquery name="UpdValue" datasource="#pds#">
				UPDATE CustomCCOutput SET 
				FieldValue = <cfif Trim(TheValue) Is "">Null<cfelse>'#Trim(TheValue)#'</cfif>, 
				UseYN = <cfif TheTab Is 3>0<cfelse>1</cfif>
				WHERE UseTab = #TheTab# 
				AND FieldName1 = '#B5#' 
			</cfquery>
		</cfif>
		<cfset counter = counter + 1>
	</cfloop>
</cfif>
<cfif IsDefined("SetCodeValues.x")>
	<cfquery name="GetLoops" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE UseTab = 8 
	</cfquery>
	<cfloop query="GetLoops">
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			FieldValue = '#Evaluate(FieldName1)#' 
			WHERE FieldName1 = '#FieldName1#' 
			AND UseTab = 8 
		</cfquery>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the codes tab of live debit credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("DelForms.x")>
	<cfif DelThese Is Not "0">
		<!--- BOB History --->
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="TheNames" datasource="#pds#">
				SELECT FieldName1 
				FROM CustomCCOutput 
				WHERE CCOutputID IN (#DelThese#) 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'System',
				'#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following values from the credit card setup: #ValueList(TheNames.FieldName1)#.')
			</cfquery>
		</cfif>	
		<cfquery name="DelData" datasource="#pds#">
			DELETE 
			FROM CustomCCOutput 
			WHERE CCOutputID IN (#DelThese#)
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("SetCCForm.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset FN = Evaluate("FieldName1#B5#")>
		<cfset FV = Evaluate("FieldValue#B5#")>
		<cfset ID = Evaluate("ID#B5#")>
		<cfif IsDefined("UseYN#B5#")>
			<cfset UY = 1>
		<cfelse>
			<cfset UY = 0>
		</cfif>
		<cfquery name="UpdateData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			FieldName1 = '#FN#', 
			FieldValue = '#FV#', 
			UseYN = #UY# 
			WHERE CCOutputID = #ID# 
		</cfquery>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the form fields tab of the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("AddFormInfo.x")>
	<cfquery name="AddFld" datasource="#pds#">
		INSERT INTO CustomCCOutput 
		(FieldName1,FieldValue,UseTab,UseYN,CFVarYN)
		VALUES 
		('#Trim(FormField)#','#Trim(FormValue)#',7,1,0)
	</cfquery>
	<cfset tab = 7>
	<cfset tab2 = 4>
	<cfset CCCompSel = "FormBased">
	<cfset FormTab = 2>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added a field to the form fields tab of the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("AddNewForm.x")>
	<cfset Tab = 24>
</cfif>
<cfif IsDefined("UnlockLive")>
	<cfquery name="Unlock" datasource="#pds#">
		UPDATE CustomCCOutput SET 
		UseYN = 0 
		WHERE UseTab = 6 
		AND FieldName1 = 'CCAutoLock'
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# unlocked the credit card lock on the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("SelCCLive.x")>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the general tab for live debit on the credit card setup.')
		</cfquery>
	</cfif>	
	<cfif IsDefined("TestMode")>
		<cfquery name="UpdTest" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			UseYN = 1 
			WHERE FieldName1 = 'Mode' 
			AND UseTab = 5 
		</cfquery>
	<cfelse>
		<cfquery name="UpdTest" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			UseYN = 0 
			WHERE FieldName1 = 'Mode' 
			AND UseTab = 5 
		</cfquery>
	</cfif>
	<cftransaction>
		<cfquery name="UpdOld" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			FieldValue = '0' 
			WHERE UseTab = 3 
		</cfquery>
		<cfquery name="UpdNew" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			FieldValue = '1' 
			WHERE UseTab = 3 
			AND Description1 = '#cccompany#' 
		</cfquery>
	</cftransaction>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfif IsDefined("UseYN#B5#")>
			<cfset UseIt = 1>
		<cfelse>
			<cfset UseIt = 0>
		</cfif>
		<cfset ID = Evaluate("ccoutputid#B5#")>
		<cfset TheValue = Evaluate("FieldValue#B5#")>
		<cfquery name="UpdFld" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			FieldValue = <cfif Trim(TheValue) Is "">Null<cfelse>'#TheValue#'</cfif>, 
			UseYN = #UseIt# 
			WHERE CCOutputID = #ID# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("SetGeneric")>
	<cfif tab Is 1>
		<cfset intcode = "savecreditcard">
		<cfinclude template="integration/#thecode#.cfm">
	<cfelseif tab Is 2>
		<cfset intcode = "savecreditcardimp">
		<cfinclude template="integration/#thecode#.cfm">
	</cfif>
</cfif>
<cfif IsDefined("UpdateEM.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CustomCCOutput SET 
		Description1 = <cfif form.ccinputlines is "">Null<cfelse>'#ccinputlines#'</cfif> 
		WHERE FieldName1 = 'ccinputlines' 
		AND UseTab = 4 
	</cfquery>
	<cfquery name="setccinputheadrow" datasource="#pds#">
		Update CustomCCOutput SET 
		Description1 = <cfif form.ccinputheadrow is "">Null<cfelse>'#ccinputheadrow#'</cfif> 
		WHERE FieldName1 = 'ccinputheadrow' 
		AND UseTab = 4
	</cfquery>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfif IsDefined("UseYN#B5#")>
			<cfset var1 = Evaluate("UseYN#B5#")>
		<cfelse>
			<cfset var1 = 0>
		</cfif>
		<cfset var2 = Evaluate("SortOrder#B5#")>
		<cfset var3 = Evaluate("LineOrder#B5#")>
		<cfset var4 = Evaluate("CCInputID#B5#")>
		<cfif IsDefined("UseYN#B5#")>
			<cfset var1 = Evaluate("UseYN#B5#")>
			<cfif Trim(var2) Is "">
				<cfset var1 = 0>
				<cfset var2 = 100>
			</cfif>
		<cfelse>
			<cfset var1 = 0>
			<cfset var2 = 100>
			<cfset var3 = 100>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCInput SET 
			UseYN = #var1#,
			SortOrder = #var2#, 
			LineOrder = #var3#  
			WHERE CCInputId = #var4#
		</cfquery>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the batch import tab on the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("EnterGen.X")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE Fieldname1 = 'ccenclosenull'
		AND UseTab = 0
	</cfquery>
   <cfif CheckFirst.RecordCount Is Not 0>
   	<cfquery name="UpdData" datasource="#pds#">
		   Update CustomCCOutput SET 
			Description1 = '#ccenclosenull#' 
		   WHERE Fieldname1 = 'ccenclosenull'
			AND UseTab = 0
	   </cfquery>
   <cfelse>
   	<cfquery name="AddData" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1,UseTab)
		   Values ('ccenclosenull', '#ccenclosenull#',0)
	   </cfquery>
   </cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE Fieldname1 = 'ccamountperiod'
		AND UseTab = 0
	</cfquery>
   <cfif CheckFirst.RecordCount Is Not 0>
   	<cfquery name="UpdData" datasource="#pds#">
		   Update CustomCCOutput SET 
			Description1 = '#ccamountperiod#' 
		   WHERE Fieldname1 = 'ccamountperiod'
			AND UseTab = 0
	   </cfquery>
   <cfelse>
   	<cfquery name="AddData" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1,UseTab)
		   Values ('ccamountperiod', '#ccamountperiod#',0)
	   </cfquery>
   </cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE Fieldname1 = 'ccyearformat'
		AND UseTab = 0
	</cfquery>
   <cfif CheckFirst.RecordCount Is Not 0>
   	<cfquery name="UpdData" datasource="#pds#">
		   Update CustomCCOutput SET 
			Description1 = '#ccyearformat#' 
		   WHERE Fieldname1 = 'ccyearformat'
			AND UseTab = 0
	   </cfquery>
   <cfelse>
   	<cfquery name="AddData" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1,UseTab)
		   Values ('ccyearformat', '#ccyearformat#',0)
	   </cfquery>
   </cfif>
	<cfset CheckChar = Right(ccoutpath,1)>
	<cfif (CheckChar Is Not "\") AND (CheckChar Is Not "/")>
		<cfset LocCCOut = ccoutpath & OSType>
	<cfelse>
		<cfset LocCCOut = ccoutpath>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE Fieldname1 = 'ccoutpath'
		AND UseTab = 0
	</cfquery>
   <cfif CheckFirst.RecordCount Is Not 0>
   	<cfquery name="UpdData" datasource="#pds#">
		   Update CustomCCOutput SET 
			Description1 = <cfif Trim(LocCCOut) Is "">Null<cfelse>'#LocCCOut#'</cfif> 
		   WHERE Fieldname1 = 'ccoutpath'
			AND UseTab = 0
	   </cfquery>
   <cfelse>
   	<cfquery name="AddData" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1,UseTab)
		   Values ('ccoutpath', '#LocCCOut#',0)
	   </cfquery>
   </cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccoutfile'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab) 
			VALUES 
			('ccoutfile','#ccoutfile#',0)
		</cfquery>
	<cfelse>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			Description1 = <cfif Trim(ccoutfile) Is "">Null<cfelse>'#ccoutfile#'</cfif> 
			WHERE FieldName1 = 'ccoutfile'
			AND UseTab = 0
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'MaxPerFile'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab) 
			VALUES 
			('MaxPerFile','#MaxPerFile#',0)
		</cfquery>
	<cfelse>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			Description1 = <cfif Trim(MaxPerFile) Is "">Null<cfelse>'#MaxPerFile#'</cfif> 
			WHERE FieldName1 = 'MaxPerFile'
			AND UseTab = 0
		</cfquery>
	</cfif>
	<cfquery name="CheckDelimit" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccdelimit'
		AND UseTab = 0
	</cfquery>
	<cfif form.ccdelimit is "|">
   	<cfif CheckDelimit.RecordCount Is Not 0>
			<cfquery name="UpdData" datasource="#pds#">
				Update CustomCCOutput SET 
				Description1 = 'pipe' 
				WHERE FieldName1 = 'ccdelimit'
				AND UseTab = 0
			</cfquery>
		<cfelse>
			<cfquery name="InsData" datasource="#pds#">
			INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab) 
			Values 
			('ccdelimit','pipe',0)
			</cfquery>
		</cfif>
	<cfelse>
		<cfset theccdelimit = form.ccdelimit>
		<cfif theccdelimit is "sp">
	   	<cfset theccdelimit = " ">
	   <cfelseif theccdelimit is "tb">
			<cfset theccdelimit = "	">
		</cfif>
	   <cfif CheckDelimit.Recordcount Is Not 0>
			<cfquery name="UpdData" datasource="#pds#">
				Update CustomCCOutput SET 
				Description1 = <cfif theccdelimit is "">Null<cfelse>'#theccdelimit#'</cfif> 
				WHERE FieldName1 = 'ccdelimit'
				AND UseTab = 0
			</cfquery>
		<cfelse>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO CustomCCOutput 
				(FieldName1, Description1, UseTab)
				Values 
				('ccdelimit',<cfif theccdelimit is "">Null<cfelse>'#theccdelimit#'</cfif>,0)
			</cfquery>
	   </cfif>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccnumfield'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = '#ccnumfield#' 
			WHERE FieldName1 = 'ccnumfield'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values 
			('ccnumfield', '#ccnumfield#',0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccenclose'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = <cfif ccenclose is "">Null<cfelse>'#ccenclose#'</cfif> 
			WHERE FieldName1 = 'ccenclose'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values ('ccenclose',<cfif ccenclose is "">Null<cfelse>'#ccenclose#'</cfif>,0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccoutputheadrow'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = <cfif ccoutputheadrow is "">Null<cfelse>'#ccoutputheadrow#'</cfif> 
			WHERE FieldName1 = 'ccoutputheadrow'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values 
			('ccoutputheadrow',<cfif ccoutputheadrow is "">Null<cfelse>'#ccoutputheadrow#'</cfif>,0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'cchrout'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = <cfif cchrout is "">Null<cfelse>'#cchrout#'</cfif> 
			WHERE FieldName1= 'cchrout'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values 
			('cchrout',<cfif cchrout is "">Null<cfelse>'#cchrout#'</cfif>,0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'ccdateformat'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = '#ccdateformat#' 
			WHERE FieldName1 = 'ccdateformat'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
	   	Values 
			('ccdateformat','#ccdateformat#',0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'cctimeformat'
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = '#cctimeformat#' 
			WHERE FieldName1 = 'cctimeformat'
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values ('cctimeformat','#cctimeformat#',0)
		</cfquery>
	</cfif>   
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * FROM CustomCCOutput 
		WHERE FieldName1 = 'ccamountformat' 
		AND UseTab = 0
	</cfquery>
	<cfif CheckFirst.Recordcount Is Not 0>
		<cfquery name="UpdData" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = <cfif ccamountformat is "">Null<cfelse>'#ccamountformat#'</cfif> 
			WHERE FieldName1 = 'ccamountformat' 
			AND UseTab = 0
		</cfquery>
	<cfelse>
		<cfquery name="AddData" datasource="#pds#">
	   	INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values 
			('ccamountformat',<cfif ccamountformat is "">Null<cfelse>'#ccamountformat#'</cfif>,0) 
		</cfquery>
	</cfif>   
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the general batch export tab on the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("EnterIt.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var2 = Evaluate("SortOrder#B5#")>
		<cfset var3 = Evaluate("CCOutputID#B5#")>
		<cfif IsDefined("Description1#B5#")>
			<cfset var4 = Evaluate("Description1#B5#")>
		</cfif>
		<cfif IsDefined("UseYN#B5#")>
			<cfset var1 = Evaluate("UseYN#B5#")>
		<cfelse>
			<cfset var1 = 0>
			<cfset var2 = 100>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			UseYN = #var1#, 
			<cfif IsDefined("Description1#B5#")>
				Description1 = '#var4#', 
			</cfif>
			SortOrder = #var2# 
			WHERE CCOutputID = #var3#
		</cfquery>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the sale tab for batch export on the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif (IsDefined("DelOne.x")) AND (IsDefined("DeleteEm"))>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPrevData" datasource="#pds#">
			SELECT FieldName1 
			FROM CustomCCOutput 
			WHERE ccoutputid In (#DeleteEm#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following values on the credit card setup: #ValueList(GetPrevData.FieldName1)#.')
		</cfquery>
	</cfif>	
	<cfquery name="deleteone" datasource="#pds#">
		DELETE FROM CustomCCOutput 
		WHERE ccoutputid In (#DeleteEm#)
	</cfquery>
</cfif>
<cfif IsDefined("Enter1.x")>
	<cfquery name="enternewone" datasource="#pds#">
		INSERT INTO customccoutput
		(fieldname1,description1,useyn,sortorder,cfvaryn,usetab)
		VALUES ('#description1#','#description1#',1,#sortorder#,0,1)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPrevData" datasource="#pds#">
			SELECT FieldName1 
			FROM CustomCCOutput 
			WHERE ccoutputid In (#DeleteEm#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following value on the credit card setup: #description1#.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("Enter3.x")>
	<cfquery name="enternewone" datasource="#pds#">
		INSERT INTO customccoutput
		(fieldname1,description1,useyn,sortorder,cfvaryn,usetab)
		VALUES ('#description1#','#description1#',1,#sortorder#,0,2)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPrevData" datasource="#pds#">
			SELECT FieldName1 
			FROM CustomCCOutput 
			WHERE ccoutputid In (#DeleteEm#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following value on the credit card setup: #description1#.')
		</cfquery>
	</cfif>	
</cfif>
<cfif IsDefined("Edit1")>
	<CFIF IsDefined("useyn")>
		<cfquery name="setvalue" datasource="#pds#">
			UPDATE customccoutput SET useyn = 1,
			sortorder = #sortorder# 
			WHERE ccoutputid = #ccoutputid#
		</cfquery>
	<cfelse>
		<cfquery name="setvalue" datasource="#pds#">
			UPDATE customccoutput SET useyn = 0,
			sortorder = 100  
			WHERE ccoutputid = #ccoutputid#
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("SelCC")>
	<cfquery datasource="#pds#" name="CheckFirst">
		SELECT * 
		FROM CustomCCOutput 
		WHERE FieldName1 = 'cccompanyie'
	</cfquery>
   <cfif CheckFirst.RecordCount Is Not 0>
		<cfquery name="setcccompanyie" datasource="#pds#">
			Update CustomCCOutput SET 
			Description1 = '#cccompanyie#' 
			WHERE FieldName1 = 'cccompanyie' 
			AND UseTab = 3 
		</cfquery>
   <cfelse>
		<cfquery name="setcccompanyie" datasource="#pds#">
		   INSERT INTO CustomCCOutput 
			(FieldName1, Description1, UseTab)
		   Values ('cccompanyie', '#cccompanyie#',3)
		</cfquery>
   </cfif>
</cfif>
<cfif IsDefined("EnterIt3.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var2 = Evaluate("SortOrder#B5#")>
		<cfset var3 = Evaluate("CCOutputID#B5#")>
		<cfif IsDefined("Description1#B5#")>
			<cfset var4 = Evaluate("Description1#B5#")>
		</cfif>
		<cfif IsDefined("UseYN#B5#")>
			<cfset var1 = Evaluate("UseYN#B5#")>
		<cfelse>
			<cfset var1 = 0>
			<cfset var2 = 100>
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomCCOutput SET 
			UseYN = #var1#, 
			<cfif IsDefined("Description1#B5#")>
				Description1 = '#var4#', 
			</cfif>
			SortOrder = #var2# 
			WHERE CCOutputID = #var3#
		</cfquery>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the refund tab for batch export on the credit card setup.')
		</cfquery>
	</cfif>	
</cfif>
<cfif (IsDefined("DelThree.x")) AND (IsDefined("DeleteEm"))>
	<cfquery name="deleteone" datasource="#pds#">
		DELETE FROM CustomCCOutput 
		WHERE ccoutputid In (#DeleteEm#)
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">



