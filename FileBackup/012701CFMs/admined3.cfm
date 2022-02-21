<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page allows editing the admins permissions. --->
<!---	4.0.3 Added New Permission for the Edit Misc on the Customer Info page.
		4.0.2 01/19/01	Fixed an error with the Clean up for personal sorting.
		4.0.1 10/24/00 Renamed the personal settings prompt names to be descriptive of their function.
		4.0.0 06/30/99 Added new permissions. Removed Tasks.
		3.2.1 09/09/98 Changed default settings to all No.
		3.2.0 09/08/98 --->
<!--- admined3.cfm --->
<cfset securepage="adminedt.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("ReturnID")>
	<cfset AdminID = ReturnID>
	<cfset Tab = Page>
</cfif>
<cfif IsDefined("CreateReport.x")>
	<cfif IsDefined("ClearHist")>
		<cfquery name="StartOver" datasource="#pds#">
			DELETE FROM GrpLists 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 23 
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT GrpListID 
		FROM GrpLists 
		WHERE ReportID = 23 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="Range" datasource="#pds#">
			INSERT INTO GrpLists 
			(LastName, FirstName, AccountID, ReportDate, MemoField, ReportTab, 
			 TabType, ReportID, AdminID, ReportTitle, CreateDate) 
			SELECT A.LastName, A.FirstName, A.AccountID, B.ActionDate, B.ActionDesc, B.Action, 
			1, 23, #MyAdminID#, 'Staff gBill History', #Now()# 
			FROM Accounts A, Admin S, BOBHist B 
			WHERE B.AdminID = S.AdminID 
			AND S.AccountID = A.AccountID 
			AND B.AdminID Is Not Null 
			<cfif AdminID Is Not 0>
				AND B.AdminID In (#AdminID#) 
			</cfif>
			<cfif IsDefined("Action")>
				<cfif Action Is Not "0">
					<cfset LogicConnect = 1>
					AND (
					<cfloop index="B5" list="#Action#">
						<cfif LogicConnect Is 1><cfset LogicConnect = 2><cfelse>OR</cfif> B.Action Like '#B5#'
					</cfloop>
					)
				</cfif>
			</cfif>
			AND B.ActionDate < {ts'#ToYear#-#ToMon#-#ToDay# 23:59:59'} 
			AND B.ActionDate > {ts'#FromYear#-#FromMon#-#FromDay# 00:00:00'} 
		</cfquery>		
	</cfif>
	<cfset SendReportID = 23>
	<cfset SendLetterID = 0>
	<cfset ReturnPage = "admined3.cfm">
	<cfset SendHeader = "Staff,Date,Time,Action">
	<cfset SendFields = "Name,ReportDate,ReportTime,MemoField">
	<cfset ReturnID = AdminID>
	<cfset Page = 6>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>	
</cfif>
<cfif IsDefined("MoveRightS") AND IsDefined("AvailSales")>
	<cfloop index="B5" list="#AvailSales#">
		<cfif B5 GT 0>
			<cfquery name="AddSales" datasource="#pds#">
				INSERT INTO SalesAdm 
				(AdminID, SalesID) 
				VALUES 
				(#AdminID#, #B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT A.FirstName + ' ' + A.LastName As FullName 
			FROM Accounts A, Admin S 
			WHERE A.AccountID = S.AccountID 
			AND AdminID IN (#AvailSales#) 
			ORDER BY A.LastName, A.FirstName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to view signups for the following salespeople: #ValueList(TheNames.FullName)#.')
		</cfquery>
	</cfif>
</cfif>

<cfif IsDefined("MoveLeftS") AND IsDefined("HaveSales")>
	<cfquery name="RemoveLetter" datasource="#pds#">
		DELETE FROM SalesAdm
		WHERE AdminID = #AdminID# 
		AND SalesID In (#HaveSales#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT A.FirstName + ' ' + A.LastName As FullName 
			FROM Accounts A, Admin S 
			WHERE A.AccountID = S.AccountID 
			AND AdminID IN (#HaveSales#) 
			ORDER BY A.LastName, A.FirstName 
		</cfquery>
		<cfset TheNameList = ValueList(TheNames.FullName)>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to view the signups of the following salespeople: #TheNameList#.')
		</cfquery>
	</cfif>
</cfif>

<cfif IsDefined("MoveRightInt") AND IsDefined("AvailLetters")>
	<cfloop index="B5" list="#AvailLetters#">
		<cfif B5 GT 0>
			<cfquery name="AddLetter" datasource="#pds#">
				INSERT INTO LetterAdm
				(AdminID, IntID) 
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="LetterNames" datasource="#pds#">
			SELECT IntDesc 
			FROM Integration 
			WHERE IntID IN (#AvailLetters#) 
			ORDER BY IntDesc
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to the letters: #ValueList(LetterNames.IntDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftInt") AND IsDefined("HaveLetters")>
	<cfquery name="RemoveLetter" datasource="#pds#">
		DELETE FROM LetterAdm
		WHERE AdminID = #AdminID# 
		AND IntID In (#HaveLetters#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="LetterNames" datasource="#pds#">
			SELECT IntDesc 
			FROM Integration 
			WHERE IntID IN (#HaveLetters#) 
			ORDER BY IntDesc
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to the letters: #ValueList(LetterNames.IntDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveRightService") AND IsDefined("AvailServices")>
	<cfloop index="B5" list="#AvailServices#">
		<cfif B5 GT 0>
			<cfquery name="AddService" datasource="#pds#">
				INSERT INTO SAdm
				(AdminID, ServiceID) 
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("MoveLeftService") AND IsDefined("HaveServices")>
	<cfquery name="RemoveService" datasource="#pds#">
		DELETE FROM SAdm
		WHERE AdminID = #AdminID# 
		AND ServiceID In (#HaveServices#)
	</cfquery>
</cfif>
<cfif IsDefined("MoveRightDom") AND IsDefined("AvailDomains")>
	<cfloop index="B5" list="#AvailDomains#">
		<cfif B5 GT 0>
			<cfquery name="AddDomain" datasource="#pds#">
				INSERT INTO DomAdm
				(AdminID, DomainID) 
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID IN (#AvailDomains#) 
			ORDER BY DomainName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these domains: #ValueList(TheNames.DomainName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftDom") AND IsDefined("HaveDomains")>
	<cfquery name="RemoveDomain" datasource="#pds#">
		DELETE FROM DomAdm
		WHERE AdminID = #AdminID# 
		AND DomainID In (#HaveDomains#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID IN (#HaveDomains#) 
			ORDER BY DomainName
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these domains: #ValueList(TheNames.DomainName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveRightPOP") AND IsDefined("AvailPOPs")>
	<cfloop index="B5" list="#AvailPOPs#">
		<cfif B5 GT 0>
			<cfquery name="AddPOP" datasource="#pds#">
				INSERT INTO POPAdm
				(AdminID, POPID) 
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID IN (#AvailPOPs#) 
			ORDER BY POPName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these POPs: #ValueList(TheNames.POPName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftPOP") AND IsDefined("HavePOP")>
	<cfquery name="RemovePOP" datasource="#pds#">
		DELETE FROM POPAdm
		WHERE AdminID = #AdminID# 
		AND POPID In (#HavePOP#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID IN (#HavePOP#) 
			ORDER BY POPName 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these POPs: #ValueList(TheNames.POPName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveRightPlan") AND IsDefined("AvailPlan")>
	<cfloop index="B5" list="#AvailPlan#">
		<cfif B5 GT 0>
			<cfquery name="AddPlan" datasource="#pds#">
				INSERT INTO PlanAdm
				(AdminID, PlanID) 
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID IN (#AvailPlan#) 
			ORDER BY PlanDesc 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these plans: #ValueList(TheNames.PlanDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftPlan") AND IsDefined("HavePlan")>
	<cfquery name="RemovePlan" datasource="#pds#">
		DELETE FROM PlanAdm
		WHERE AdminID = #AdminID# 
		AND PlanID In (#HavePlan#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID IN (#HavePlan#) 
			ORDER BY PlanDesc 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these plans: #ValueList(TheNames.PlanDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveRightMenu") AND IsDefined("Avail")>
	<cfloop index="B5" list="#Avail#">
		<cfif B5 gt 0>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AdminID 
				FROM AdmSort 
				WHERE AdminID = #AdminID# 
				AND LevelID = 
					(SELECT Menu 
					 FROM MenuItems 
					 WHERE MenuID = #B5#)
			</cfquery>
			<cfquery name="AddMenu" datasource="#pds#">
				INSERT INTO Connect 
				(AdminID, MenuID)
				VALUES 
				(#AdminID#,#B5#)
			</cfquery>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="GetSort" datasource="#pds#">
					SELECT max(SortOrder) as MSO 
					FROM AdmSort 
					WHERE AdminID = #AdminID# 
				</cfquery>
				<cfquery name="GetLevel" datasource="#pds#">
					SELECT Menu 
					FROM MenuItems 
					WHERE MenuID = #B5# 
				</cfquery>
				<cfif GetSort.MSO Is "">
					<cfset NewSort = 1>
				<cfelse>
					<cfset NewSort = 1 + GetSort.MSO>
				</cfif>
				<cfquery name="InsData" datasource="#pds#">
					INSERT INTO AdmSort 
					(AdminID, LevelID, SortOrder)
					VALUES 
					(#AdminID#, #GetLevel.Menu#, #NewSort#)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT Title 
			FROM MenuItems 
			WHERE MenuID IN (#Avail#) 
			ORDER BY Title 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these menu items: #ValueList(TheNames.Title)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("MoveLeftMenu") AND IsDefined("HaveMenu")>
	<cfquery name="RemovePlan" datasource="#pds#">
		DELETE FROM Connect
		WHERE AdminID = #AdminID# 
		AND MenuID In (#HaveMenu#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoName" datasource="#pds#">
			SELECT FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #AdminID#) 
		</cfquery>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT Title 
			FROM MenuItems 
			WHERE MenuID IN (#HaveMenu#) 
			ORDER BY Title 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed permissions for #GetWhoName.FirstName# #GetWhoName.LastName# to these menu items: #ValueList(TheNames.Title)#.')
		</cfquery>
	</cfif>
	<cfquery name="CleanUpSort" datasource="#pds#">
		DELETE FROM AdmSort 
		WHERE AdminID = #AdminID# 
		AND LevelID Not IN 
			(SELECT AdmSort.LevelID 
			 FROM AdmSort A 
			 WHERE A.AdminID = #AdminID# 
			 AND A.LevelID In 
			 	(SELECT Menu 
				 FROM MenuItems M, Connect C 
				 WHERE M.MenuID = C.MenuID AND C.AdminID = #AdminID#) 
			) 
	</cfquery>
</cfif>
<cfif IsDefined("UpdPrivs.x")>
	<cfif KeepDays GT 365>
		<cfset KeepDays = 365>
	</cfif>
	<cfif KeepDays LT 0>
		<cfset KeepDays = 0>
	</cfif>
	<cfif SessOut LT 5>
		<cfset SessOut = 5>
	</cfif>
	<cfif SessOut GT 1440>
		<cfset SessOut = 1440>
	</cfif>
	<cfquery name="SetUserPrivs" datasource="#pds#">
		UPDATE Admin SET 
		editinfo = #editinfo#, chpass = #chpass#, editpay = #editpay#, menulev = #menulev#, payhist = #payhist#, 
		supphist = #supphist#, sesshist = #sesshist#, viewother = #viewother#, 
		chplan = #chplan#, waivea = #waivea#, deactc = #deactc#, cancelc = #cancelc#, 
		cancela = #cancela#, deltrans = #deltrans#, schevent = #schevent#, 
		ReactAcnt = #ReactAcnt#, ViewCPasswd = #ViewCPasswd#, ViewAPasswd = #ViewAPasswd#, 
		EditName = #EditName#, BOBHist = #BOBHist#, BOBAHist = #BOBAHist#, KeepDays = #KeepDays#, 
		SessOut = #SessOut#, tblwidth = '#tblwidth#', mrow = #mrow#, color1 = '#color1#', color2 = '#color2#', 
		color3 = '#color3#', color4 = '#color4#', tbclr = '#tbclr#', tdclr = '#tdclr#', thclr = '#thclr#', 
		ttclr = '#ttclr#', ttfont = '#ttfont#', ttsize = #ttsize#, perfontsize = '#perfontsize#', 
		perfontname = '#perfontname#', OpenNew = #OpenNew#, SalesPersonYN = #SalesPersonYN#, EditMisc = #EditMisc#, 
		OnlineSignup = #OnlineSignup#, SendEMail = #SendEMail#, OverRide = #OverRide#, PrivRep = #PrivRep#, 
		SUserYN = #SuserYN# 
		WHERE AdminID = #AdminID#		
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = (SELECT AccountID 
									 FROM Admin 
									 WHERE AdminID = #AdminID#)
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#GetWhoIs.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the staff permissions for #GetWhoIs.FirstName# #GetWhoIs.LastName#.')
			</cfquery>
		</cfif>
	</cfif>
	<cfset SUTotal = editinfo + chpass + editpay + menulev + payhist + supphist + sesshist + viewother + chplan + waivea + deactc + cancelc + cancela + deltrans + schevent + ReactAcnt + ViewCPasswd + ViewAPasswd + EditName + BOBHist + BOBAHist + SalesPersonYN + OnlineSignup + SendEMail + OverRide + EditMisc>
	<cfquery name="UpdateLevel" datasource="#pds#">
		UPDATE Admin SET 
		SLevel = #SUTotal# 
		WHERE AdminID = #AdminID#
	</cfquery>
</cfif>
<cfif IsDefined("MakeSU")>
	<cfquery name="MakeSuperUser" datasource="#pds#">
		UPDATE Admin SET 
		editinfo = 1, chpass = 1, editpay = 1, menulev = 1, payhist = 1, supphist = 1, 
		sesshist = 1, viewother = 1, chplan = 1, waivea = 1, 
		deactc = 1, cancelc = 1, cancela = 1, deltrans = 1, EditMisc = 1, 
		schevent = 1, ReactAcnt = 1, ViewCPasswd = 1, ViewAPasswd = 1, 
		EditName = 1, BOBHist = 1, BOBAHist = 1, KeepDays = 0, SessOut = 1440, 
		SUserYN = 1, SalesPersonYN = 1, OnlineSignup = 1, SendEMail = 1, OverRide = 1, 
		PrivRep = 0 
		WHERE AdminID = #AdminID#		
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = (SELECT AccountID 
									 FROM Admin 
									 WHERE AdminID = #AdminID#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#GetWhoIs.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# made #GetWhoIs.FirstName# #GetWhoIs.LastName# a Super User.')
		</cfquery>
	</cfif>
	<cfquery name="UpdateLevel" datasource="#pds#">
		UPDATE Admin SET 
		SLevel = 32 
		WHERE AdminID = #AdminID#
	</cfquery>	
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM Connect 
		WHERE AdminID = #AdminID#
	</cfquery>
	<cfquery name="AllMenuItems" datasource="#pds#">
		INSERT INTO Connect 
		(MenuID, AdminID)
		SELECT MenuID, #AdminID# 
		FROM MenuItems 
		WHERE ActiveYN = 1 
		ORDER BY MenuID
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT LevelID 
		FROM Levels 
		WHERE LevelID IN 
			(SELECT Menu 
			 FROM MenuItems 
			 WHERE MenuID In 
			 		(SELECT MenuID 
					 FROM Connect 
					 WHERE AdminID = #AdminID#
					)
			)
		AND LevelID NOT IN 
			(SELECT LevelID 
			 FROM AdmSort 
			 WHERE AdminID = #AdminID#)
	</cfquery>
	<!--- Add any new to the Personal Sort --->
	<cfif CheckFirst.Recordcount GT 0>
		<cfquery name="MaxSort" datasource="#pds#">
			SELECT Max(SortOrder) as MSO 
			FROM AdmSort 
			WHERE AdminID = #AdminID#
		</cfquery>
		<cfset TheSort = MaxSort.MSO>
		<cfif Trim(TheSort) Is "">
			<cfset TheSort = 1>
		<cfelse>
			<cfset TheSort = TheSort + 1>
		</cfif>
		<cfloop query="CheckFirst">
			<cfquery name="AddNew" datasource="#pds#">
				INSERT INTO AdmSort 
				(AdminID,LevelID,SortOrder)
				VALUES 
				(#AdminID#,#LevelID#,#TheSort#)
			</cfquery>
			<cfset TheSort = TheSort + 1>
		</cfloop>
	</cfif>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM SalesAdm 
		WHERE AdminID = #AdminID# 
	</cfquery>
	<cfquery name="AllStaff" datasource="#pds#">
		INSERT INTO SalesAdm 
		(AdminID, SalesID) 
		SELECT #AdminID#, AdminID 
		FROM Admin 
		ORDER BY AdminID 
	</cfquery>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM PlanAdm 
		WHERE AdminID = #AdminID#
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		INSERT INTO PlanAdm 
		(PlanID, AdminID)
		SELECT PlanID, #AdminID# 
		FROM Plans 
		ORDER BY PlanID
	</cfquery>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM POPAdm 
		WHERE AdminID = #AdminID#
	</cfquery>
	<cfquery name="AllPOPs" datasource="#pds#">
		INSERT INTO POPAdm 
		(POPID, AdminID)
		SELECT POPID, #AdminID# 
		FROM POPs 
		ORDER BY POPID
	</cfquery>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM DomAdm 
		WHERE AdminID = #AdminID#
	</cfquery>
	<cfquery name="AllDomains" datasource="#pds#">
		INSERT INTO DomAdm 
		(DomainID, AdminID)
		SELECT DomainID, #AdminID# 
		FROM Domains 
		ORDER BY DomainID
	</cfquery>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM LetterAdm 
		WHERE AdminID = #AdminID#
	</cfquery>
	<cfquery name="AllLetters" datasource="#pds#">
		INSERT INTO LetterAdm 
		(AdminID, IntID)
		SELECT #AdminID#, IntID 
		FROM Integration 
		WHERE Action = 'Letter' 
		ORDER BY IntID
	</cfquery>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM SAdm 
		WHERE AdminID = #AdminID#
	</cfquery>
</cfif>
<cfif IsDefined("AddStaffMember")>
	<cftransaction>
		<cfquery NAME="InsInfo" datasource="#pds#">
			INSERT INTO admin 
			(accountid, lastsess, editinfo, chpass, editpay, menulev, payhist, supphist, 
			 sesshist, viewother, chplan, waivea, deactc, cancelc, tblwidth, tbclr, 
			 tdclr, thclr, cancela, deltrans, frames, schevent, color1, color2, 
			 color3, color4, ReactAcnt, ViewCPasswd, ViewAPasswd, EditName, BOBHist, BOBAHist, 
			 KeepDays, SessOut, ttfont, ttsize, ttclr, mrow, perfontsize, perfontname, SUserYN, 
			 SalesPersonYN, SendEMail, OnlineSignup, OverRide, PrivRep, OpenNew, EditMisc 
			) 
			VALUES 
			(#accountid#, #Now()#, 0, 0, 0, 0, 0, 0, 
			 0, 0, 0, 0, 0, 0, '0', 'FFFFFF', 
			 'FFFFFF', 'CFCFCF', 0, 0, 0, 0, 'FFFFFF','009900',
			 'Black','009900', 0, 0, 0, 0, 0, 0, 
			 30, 60, 'FFFFFF', 3, '666666', 
			 50, 'small', 'Arial', 0, 0, 0, 0, 0, 30, 1, 0)
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(AdminID) as MaxID 
			FROM Admin
		</cfquery>
		<cfset AdminID = NewID.MaxID>
	</cftransaction>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = (SELECT AccountID 
									 FROM Admin 
									 WHERE AdminID = #AdminID#)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,#GetWhoIs.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# added #GetWhoIs.FirstName# #GetWhoIs.LastName# to the staff list.')
		</cfquery>
	</cfif>
	<cfquery name="UpdateLevel" datasource="#pds#">
		UPDATE Admin SET 
		SLevel = 0 
		WHERE AdminID = #AdminID#
	</cfquery>	
</cfif>

<cfparam name="tab" default="1">
<cfquery NAME="onep" datasource="#pds#">
	SELECT Admin.*, U.FirstName, U.LastName 
	FROM Accounts U, Admin 
	WHERE Admin.AccountID = U.AccountID 
	AND Admin.AdminID = #AdminID#
</cfquery>
<cfif Tab Is 1>
	<cfset HowWide = 6>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
<cfelseif Tab Is 2>
	<cfset HowWide = 3>
	<cfquery NAME="HaveTitles" datasource="#pds#">
		SELECT M.MenuID, M.Title, L.LevelName, L.Sort
		FROM Connect C, MenuItems M, Levels L 
		WHERE C.MenuID = M.MenuID 
		AND M.Menu = L.LevelID 
		AND AdminID = #AdminID# 
		ORDER BY L.Sort, M.Title 
	</cfquery>
	<cfquery NAME="AllTitles" datasource="#pds#">
		SELECT M.MenuID, M.Title, L.LevelName, L.Sort 
		FROM MenuItems M, Levels L 
		WHERE M.Menu = L.LevelID 
		<CFIF HaveTitles.RecordCount GT 0>
			AND M.MenuID Not In 
				(SELECT M.MenuID 
				 FROM Connect C, MenuItems M, Levels L 
				 WHERE C.MenuID = M.MenuID 
				 AND M.Menu = L.LevelID 
				 AND AdminID = #AdminID# 
				) 
		</CFIF>
		AND M.ActiveYN = 1 
		ORDER BY L.Sort, M.Title 
	</cfquery>
<cfelseif tab Is 3>
	<cfset HowWide = 3>
		<cfquery NAME="HavePlans" datasource="#pds#">
			SELECT P.PlanID, P.PlanDesc 
			FROM Plans P, PlanAdm A 
			WHERE P.PlanID = A.PlanID 
			AND A.AdminID = #AdminID# 
			ORDER BY PlanDesc
		</cfquery>
		<cfquery NAME="allplans" datasource="#pds#">
			SELECT P.PlanID, P.PlanDesc 
			FROM Plans P
		   <CFIF Haveplans.RecordCount GT 0>
			   WHERE PlanID Not In 
					(SELECT P.PlanID 
					 FROM Plans P, PlanAdm A 
					 WHERE P.PlanID = A.PlanID 
					 AND A.AdminID = #AdminID# 
					) 
		   </CFIF>
			ORDER BY plandesc 
		</cfquery>
<cfelseif tab Is 4>
	<cfset HowWide = 3>
	<cfquery NAME="HavePOPs" datasource="#pds#">
		SELECT P.POPID, P.POPName 
		FROM POPs P, POPAdm A 
		WHERE P.POPID = A.POPID 
		AND A.AdminID = #AdminID#
		ORDER BY POPName 
	</cfquery>
	<cfquery NAME="AllPOPs" datasource="#pds#">
		SELECT P.POPID, P.POPName 
		FROM POPs P  
	   <CFIF HavePOPs.RecordCount GT 0>
			WHERE POPID Not In 
				(SELECT P.POPID 
				 FROM POPs P, POPAdm A 
				 WHERE P.POPID = A.POPID 
				 AND A.AdminID = #AdminID#
				)
		</CFIF>
		ORDER BY POPName
	</cfquery>
<cfelseif tab Is 5>
	<cfset HowWide = 3>
	<cfquery NAME="HaveDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, DomAdm A 
		WHERE D.DomainID = A.DomainID 
		AND A.AdminID = #AdminID#
		ORDER BY DomainName 
	</cfquery>
	<cfquery NAME="AllDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D 
	   <CFIF HaveDomains.RecordCount GT 0>
			WHERE DomainID Not In 
				(SELECT D.DomainID 
				 FROM Domains D, DomAdm A 
				 WHERE D.DomainID = A.DomainID 
				 AND A.AdminID = #AdminID#
				)
		</CFIF>
		ORDER BY DomainName 
	</cfquery>
<cfelseif tab Is 6>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfset HowWide = 3>
	<cfquery name="GetHist" datasource="#pds#" maxrows="#Mrow#">
		SELECT * 
		FROM BOBHist 
		WHERE AdminID = #AdminID# 
		ORDER BY ActionDate desc
	</cfquery>
	<cfquery name="GetDates" datasource="#pds#">
		SELECT Min(ActionDate) MinDate 
		FROM BOBHist 
		WHERE AdminID = #AdminID# 
	</cfquery>
	<cfif GetDates.MinDate Is "">
		<cfset FromDate = CreateDate(year(Now()),month(now()),1)>
	<cfelse>
		<cfset FromDate = GetDates.MinDate>
	</cfif>
	<cfset FromYear = Year(FromDate)>
	<cfset FromMon = Month(FromDate)>
	<cfif FromMon LT 10>
		<cfset FromMon = "0" & FromMon>
	</cfif>
	<cfset FromDay = Day(FromDate)>
	<cfif FromDay LT 10>
		<cfset FromDay = "0" & FromDay>
	</cfif>
	<cfset ToYear = Year(Now())>
	<cfset ToMon = Month(Now())>
	<cfif ToMon LT 10>
		<cfset ToMon = "0" & ToMon>
	</cfif>
	<cfset ToDay = Day(Now())>
	<cfif ToDay LT 10>
		<cfset ToDay = "0" & ToDay>
	</cfif>
<cfelseif tab Is 7>
	<cfset HowWide = 3>
	<cfquery name="HaveLetters" datasource="#pds#">
		SELECT I.IntID, I.IntDesc 
		FROM Integration I, LetterAdm L 
		WHERE I.IntID = L.IntID 
		AND L.AdminID = #AdminID# 
		AND I.Action = 'Letter' 
		ORDER BY IntDesc 
	</cfquery>
	<cfquery name="AllLetters" datasource="#pds#">
		SELECT I.IntID, I.IntDesc 
		FROM Integration I 
		WHERE I.Action = 'Letter'
		<cfif HaveLetters.Recordcount GT 0>
			AND IntID Not In 
				(SELECT I.IntID 
				 FROM Integration I, LetterAdm L 
				 WHERE I.IntID = L.IntID 
				 AND L.AdminID = #AdminID# )
		</cfif>
		ORDER BY IntDesc 
	</cfquery>
<cfelseif tab Is 8>
	<cfset HowWide = 3>
	<cfquery name="HaveSales" datasource="#pds#">
		SELECT A.FirstName, A.LastName, S.AdminID as SalesID
		FROM Accounts A, Admin S, SalesAdm SA
		WHERE A.AccountID = S.AccountID 
		AND S.AdminID = SA.SalesID 
		AND SA.AdminID = #AdminID# 
		ORDER BY A.LastName, A.FirstName 
	</cfquery>
	<cfquery name="AllSales" datasource="#pds#">
		SELECT A.FirstName, A.LastName, S.AdminID as SalesID 
		FROM Accounts A, Admin S 
		WHERE A.AccountID = S.AccountID 
		<cfif HaveSales.Recordcount GT 0>
			AND S.AdminID NOT IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #AdminID#)
		</cfif>
		ORDER BY A.LastName, A.FirstName 
	</cfquery>
<cfelseif tab Is 9>
	<cfset HowWide = 3>
	<cfquery NAME="HaveServices" datasource="#pds#">
		SELECT S.ServiceID, S.Service 
		FROM Services S, SAdm A 
		WHERE S.ServiceID = A.ServiceID 
		AND A.AdminID = #AdminID# 
		ORDER BY Service 
	</cfquery>
	<cfquery NAME="AllServices" datasource="#pds#">
		SELECT S.ServiceID, S.Service 
		FROM Services S 
		<CFIF HaveServices.RecordCount GT 0>
			WHERE ServiceID Not In 
				(SELECT S.ServiceID 
				 FROM Services S, SAdm A 
				 WHERE S.ServiceID = A.ServiceID 
				 AND A.AdminID = #AdminID# 
				)
		</CFIF>
		ORDER BY Service
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Staff Permissions</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="adminedt.cfm">
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#Onep.FirstName# #Onep.LastName# Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="admined3.cfm">
						<input type="hidden" name="AdminID" value="#AdminID#">
						<td bgcolor=<cfif tab is "1">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Permissions</label></td>
						<td bgcolor=<cfif tab is "2">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Menu Items</label></td>
						<td bgcolor=<cfif tab is "8">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 8>checked</cfif> name="tab" value="8" onclick="submit()" id="tab8"><label for="tab8">Sales</label></td>
						<td bgcolor=<cfif tab is "3">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Plans</label></td>
						<td bgcolor=<cfif tab is "4">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">POPs</label></td>
						<td bgcolor=<cfif tab is "5">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">Domains</label></td>
						<td bgcolor=<cfif tab is "7">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 7>checked</cfif> name="tab" value="7" onclick="submit()" id="tab7"><label for="tab7">Letters</label></td>
						<td bgcolor=<cfif tab is "6">"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 6>checked</cfif> name="tab" value="6" onclick="submit()" id="tab6"><label for="tab6">gBill Recent History</label></td>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif tab Is 1>
	<cfoutput>
		<tr>
			<th align="right" colspan="#HowWide#" bgcolor="#thclr#">Last Session: #LSDateFormat(Onep.lastsess, '#datemask1#')# #TimeFormat(Onep.lastsess, 'hh:mm tt')#</th>
		</tr>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="AdminID" value="#onep.AdminID#">
			<tr>
				<td colspan="6">
					<table border="0" width="100%">
						<tr>
							<td><cfif onep.SUserYN is "1"><b>Super User</b></cfif></td>
							<td align="right"><input type="submit" name="MakeSU" value="Make Super User"></td>
						</tr>
					</table>
				 </td>
			</tr>
		</form>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="AdminID" value="#onep.AdminID#">
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Edit User Info</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="editinfo" <cfif onep.editinfo is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="editinfo" <cfif onep.editinfo is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Edit MIsc Info</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="editmisc" <cfif onep.editmisc is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="editmisc" <cfif onep.editmisc is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Edit Pay Method</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="editpay" <cfif onep.editpay is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="editpay" <cfif onep.editpay is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Change Passwords</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="chpass" <cfif onep.chpass is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="chpass" <cfif onep.chpass is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Customer Passwords</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="ViewCPasswd" <cfif onep.ViewCPasswd is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="ViewCPasswd" <cfif onep.ViewCPasswd is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Admin Passwords</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="ViewAPasswd" <cfif onep.ViewAPasswd is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="ViewAPasswd" <cfif onep.ViewAPasswd is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">View Session History</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="sesshist" <cfif onep.sesshist is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="sesshist" <cfif onep.sesshist is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Support History</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="supphist" <cfif onep.supphist is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="supphist" <cfif onep.supphist is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Customer History</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="BOBHist" <cfif onep.BOBHist is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="BOBHist" <cfif onep.BOBHist is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">View Admin History</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="BOBAHist" <cfif onep.BOBAHist is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="BOBAHist" <cfif onep.BOBAHist is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Scheduled Events</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="schevent" <cfif onep.schevent is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="schevent" <cfif onep.schevent is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Pay History</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="payhist" <cfif onep.payhist is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="payhist" <cfif onep.payhist is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Manage Accounts</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="chplan" <cfif onep.chplan is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="chplan" <cfif onep.chplan is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Override Plan Limits</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="OverRide" <cfif onep.OverRide is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="OverRide" <cfif onep.OverRide is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">View Multi Accounts</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="viewother" <cfif onep.viewother is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="viewother" <cfif onep.viewother is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Send Customer's E-Mail</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="SendEMail" <cfif onep.SendEMail is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="SendEMail" <cfif onep.SendEMail is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Approve Online Signups</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="OnlineSignup" <cfif onep.onlinesignup is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="OnlineSignup" <cfif onep.onlinesignup is "0">checked</cfif> value="0">No</td>
				<td  bgcolor="#tbclr#" align=right><font size="2">Waive Setup Fees</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="waivea" <cfif onep.waivea is 1>checked</cfif> value="1">Yes <INPUT TYPE="radio" name="waivea" <cfif onep.waivea is 0>checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Enter Payments:</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="menulev" <cfif onep.menulev is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="menulev" <cfif onep.menulev is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Deactive Accounts</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="deactc" <cfif onep.deactc is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="deactc" <cfif onep.deactc is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Reactivate Accounts</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="ReactAcnt" <cfif onep.ReactAcnt is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="ReactAcnt" <cfif onep.ReactAcnt is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Cancel Accounts</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="cancelc" <cfif onep.cancelc is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="cancelc" <cfif onep.cancelc is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Delete Accounts</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="cancela" <cfif onep.cancela is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="cancela" <cfif onep.cancela is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Delete Transactions</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="deltrans" <cfif onep.deltrans is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="deltrans" <cfif onep.deltrans is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Salesperson</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="SalesPersonYN" <cfif onep.SalesPersonYN is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="SalesPersonYN" <cfif onep.SalesPersonYN is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Select Salesperson</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="EditName" <cfif onep.EditName is "1">checked</cfif> value="1">Yes <INPUT TYPE="radio" name="EditName" <cfif onep.EditName is "0">checked</cfif> value="0">No</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Super User</font></td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="SUserYN" <cfif onep.SUserYN is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="SUserYN" <cfif onep.SUserYN is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Keep Private Reports for</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.PrivRep#" name="PrivRep" maxlength="4" size="4">days</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Keep Admin History For</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" name="KeepDays" value="#onep.KeepDays#" size="3" maxlength="3">days</td>
				<td align=right bgcolor="#tbclr#"><font size="2">Sessions Timeout After</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.Sessout#" name="SessOut" maxlength="4" size="5">minutes</td>
			</tr>
			<tr>
				<th colspan="6" bgcolor="#thclr#">Personal Settings</th>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Table Border Width</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.tblwidth#" name="tblwidth" size="3" maxlength="2"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Report Rows</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.mrow#" name="mrow" size="3" maxlength="2"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Page Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.color1#" name="color1" size="8" maxlength="15"></td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Visited Link</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.color2#" name="color2" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Text Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.color3#" name="color3" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Link</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.color4#" name="color4" size="8" maxlength="15"></td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Text Cell Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.tbclr#" name="tbclr" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Data Cell Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.tdclr#" name="tdclr" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Header Cell Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.thclr#" name="thclr" size="8" maxlength="15"></td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Title Bar Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.ttclr#" name="ttclr" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Title Bar Text Color</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.ttfont#" name="ttfont" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Title Font Size</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.ttsize#" name="ttsize" size="3" maxlength="1"></td>
			</tr>
			<tr>
				<td align=right bgcolor="#tbclr#"><font size="2">Page Font Size</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.perfontsize#" name="perfontsize" size="3" maxlength="1"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Page Font</td>
				<td bgcolor="#tdclr#"><font size="2"><input type="text" value="#onep.perfontname#" name="perfontname" size="8" maxlength="15"></td>
				<td align=right bgcolor="#tbclr#"><font size="2">Open New Window</td>
				<td bgcolor="#tdclr#"><font size="2"><INPUT TYPE="radio" name="OpenNew" <cfif onep.OpenNew is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="OpenNew" <cfif Onep.OpenNew is "0">checked</cfif> value="0">No</td>
			</tr>
			<tr>
				<th colspan="6"><INPUT TYPE="image" name="UpdPrivs" src="images/update.gif" border="0"></th>
			</tr>
		</form>
	</cfoutput>
<cfelseif tab Is 2>
	<cfoutput>
		<tr>
			<th colspan="3" bgcolor="#thclr#">Select Menu Items</th>
		</tr>
		<tr>
			<th bgcolor="#thclr#">Available
			<td bgcolor="#thclr#">&nbsp;</td>
			<th bgcolor="#thclr#">Currently Have</th>
		</tr>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="AdminID" value="#onep.AdminID#">
			<input type="hidden" name="Tab" value="#tab#">
			<tr bgcolor="#tdclr#">
	</cfoutput>		
				<td align="center"><select name="Avail" Multiple size=10>
					<cfoutput query="AllTitles" group="Sort">
						<option value="0">#UCASE(LevelName)#
						<cfoutput>
							<option value="#MenuID#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Title#
						</cfoutput>
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td valign="middle" align="center">
				<INPUT TYPE="submit" Name="MoveRightMenu" value="---->"><br>
				<INPUT TYPE="submit" Name="MoveLeftMenu" value="<----"><br>				
				</td>
				<td align="center"><select name="HaveMenu" Multiple size=10>
					<cfoutput query="HaveTitles" group="LevelName">
						<option value="0">#UCASE(LevelName)#
						<cfoutput>
							<option value=#MenuID#>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Title#
						</cfoutput>
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>
		</form>
<cfelseif tab Is 3>
	<cfoutput>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="adminid" value="#adminid#">
			<tr>
				<th colspan="3" bgcolor="#thclr#">Select Plans</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Available</th>
				<th>Action</th>
				<th>Currently Have</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>	
				<td align="center"><select name="AvailPlan" Multiple size=10>
					<cfoutput query="AllPlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MoveRightPlan" value="---->"><br>
					<input type="submit" name="MoveLeftPlan" value="<----"><br>
				</td>
				<td align="center"><select name="HavePlan" Multiple size=10>
					<cfoutput query="haveplans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>		
		</form>
<cfelseif tab Is 4>
	<cfoutput>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="adminid" value="#adminid#">
			<tr>
				<th colspan="3" bgcolor="#thclr#">Select POPs</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Available</th>
				<th>Action</th>
				<th>Currently Have</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>	
				<td align="center"><select name="AvailPOPs" Multiple size=10>
					<cfoutput query="AllPOPs">
						<option value="#POPID#">#POPName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MoveRightPOP" value="---->"><br>
					<input type="submit" name="MoveLeftPOP" value="<----"><br>
				</td>
				<td align="center"><select name="HavePOP" Multiple size=10>
					<cfoutput query="HavePOPs">
						<option value="#POPID#">#POPName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>		
		</form>
<cfelseif tab Is 5>
	<cfoutput>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="adminid" value="#adminid#">
			<tr>
				<th colspan="3" bgcolor="#thclr#">Select Domains</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Available</th>
				<th>Action</th>
				<th>Currently Have</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>	
				<td align="center"><select name="AvailDomains" Multiple size=10>
					<cfoutput query="AllDomains">
						<option value="#DomainID#">#DomainName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MoveRightDom" value="---->"><br>
					<input type="submit" name="MoveLeftDom" value="<----"><br>
				</td>
				<td align="center"><select name="HaveDomains" Multiple size=10>
					<cfoutput query="HaveDomains">
						<option value="#DomainID#">#DomainName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>		
		</form>
<cfelseif tab Is 6>
	<cfoutput>
		<tr>
			<th colspan="#HowWide#" bgcolor="#thclr#">Recent History</th>
		</tr>
		<form method="post" action="admined3.cfm">
			<input type="Hidden" name="FromYear" value="#FromYear#">
			<input type="Hidden" name="FromMon" value="#FromMon#">
			<input type="Hidden" name="FromDay" value="#FromDay#">
			<input type="Hidden" name="ToYear" value="#ToYear#">
			<input type="Hidden" name="ToMon" value="#ToMon#">
			<input type="Hidden" name="ToDay" value="#ToDay#">
			<input type="Hidden" name="Action" value="0">
			<input type="Hidden" name="AdminID" value="#AdminID#">
			<input type="Hidden" name="ClearHist" value="1">
			<input type="Hidden" name="ReturnPage" value="admined3.cfm">
			<tr>
				<td colspan="#HowWide#" align="right"><input type="Submit" name="CreateReport.x" value="Full Report"></td>
			</tr>
		</form>
		<tr bgcolor="#thclr#">
			<th>Date</th>
			<th>Time</th>
			<th>Action</th>
		</tr>
	</cfoutput>
	<cfoutput query="GetHist">
		<tr bgcolor="#tbclr#" valign="top">
			<td>#LSDateFormat(ActionDate, '#datemask1#')#</td>
			<td>#LSTimeFormat(ActionDate, 'hh:mm tt')#</td>
			<td>#ActionDesc#</td>
		</tr>
	</cfoutput>
<cfelseif tab Is 7>
	<cfoutput>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="adminid" value="#adminid#">
			<tr>
				<th colspan="3" bgcolor="#thclr#">Select Letters</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Available</th>
				<th>Action</th>
				<th>Currently Have</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>	
				<td align="center"><select name="AvailLetters" Multiple size=10>
					<cfoutput query="AllLetters">
						<option value="#IntID#">#IntDesc#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MoveRightInt" value="---->"><br>
					<input type="submit" name="MoveLeftInt" value="<----"><br>
				</td>
				<td align="center"><select name="HaveLetters" Multiple size=10>
					<cfoutput query="HaveLetters">
						<option value="#IntID#">#IntDesc#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>		
		</form>
<cfelseif tab Is 8>
	<cfoutput>
		<form method="post" action="admined3.cfm">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="adminid" value="#adminid#">
			<tr>
				<th colspan="3" bgcolor="#thclr#">Select Salespeople to view their signups</th>
			</tr>
			<tr bgcolor="#thclr#">
				<th>Available</th>
				<th>Action</th>
				<th>Currently Have</th>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>	
				<td align="center"><select name="AvailSales" Multiple size=10>
					<cfoutput query="AllSales">
						<option value="#SalesID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MoveRightS" value="---->"><br>
					<input type="submit" name="MoveLeftS" value="<----"><br>
				</td>
				<td align="center"><select name="HaveSales" Multiple size=10>
					<cfoutput query="HaveSales">
						<option value="#SalesID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="0">______________________________
				</select></td>
			</tr>		
		</form>
</cfif>

</table>

</center>
<cfinclude template="footer.cfm">
</body>
</html>
                       