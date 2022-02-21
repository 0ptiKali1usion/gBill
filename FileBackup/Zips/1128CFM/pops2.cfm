<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that updates the pops or adds a new one.--->
<!--- 4.0.0 07/24/99 
		3.2.0 09/08/98 --->
<!--- pops2.cfm --->
<cfif (IsDefined("MvRt5")) AND (IsDefined("WantIt"))>
	<cfloop index="B5" list="#WantIt#">
		<cfif B5 GT 0>
			<cfquery name="AddEm" datasource="#pds#">
				INSERT INTO POPsStates 
				(PopId, StateID) 
				VALUES 
				(#POPID#, #B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetStates" datasource="#pds#">
			SELECT StateName 
			FROM States 
			WHERE StateID In (#WantIt#) 
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# gave the following states access to #GetPOP.POPName#.  #ValueList(GetStates.StateName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvLt5")) AND (IsDefined("HaveIt"))>
   <cfquery name="removeem" datasource="#pds#">
		DELETE FROM POPsStates 
		WHERE StateID In (#HaveIt#) 
		AND POPID = #POPID# 
   </cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetStates" datasource="#pds#">
			SELECT StateName 
			FROM States 
			WHERE StateID In (#HaveIt#) 
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following states from access to #GetPOP.POPName#.  #ValueList(GetStates.StateName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvRt4")) AND (IsDefined("WantIt"))>
	<cfloop index="B5" list="#WantIt#">
		<cfif B5 GT 0>
			<cfquery name="AddEm" datasource="#pds#">
				INSERT INTO POPPlans 
				(PopId, PlanID) 
				VALUES 
				(#POPID#, #B5#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetStates" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID In (#WantIt#) 
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# gave the following plans access to #GetPOP.POPName#.  #ValueList(GetStates.PlanDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvLt4")) AND (IsDefined("HaveIt"))>
   <cfquery name="removeem" datasource="#pds#">
		DELETE FROM POPPlans 
		WHERE PlanID In (#HaveIt#) 
		AND POPID = #POPID# 
   </cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPlans" datasource="#pds#">
			SELECT PlanDesc 
			FROM Plans 
			WHERE PlanID In (#HaveIt#) 
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following plans from access to #GetPOP.POPName#.  #ValueList(GetPlans.PlanDesc)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvRt3")) AND (IsDefined("WantIt"))>
	<cfloop index="B5" list="#WantIt#">
		<cfif B5 GT 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO POPAdm 
				(PopId, AdminID)
				VALUES 
				(#PopId#, #B5#)
   		</cfquery>
		</cfif>
   </cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetStaff" datasource="#pds#">
			SELECT FirstName + ' ' + LastName As Name 
			FROM Accounts 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID In (#WantIt#) 
				)
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following staff to have access to #GetPOP.POPName#.  #ValueList(GetStaff.Name)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvLt3")) AND (IsDefined("HaveIt"))>
   <cfquery name="DelData" datasource="#pds#">
		DELETE FROM POPAdm 
		WHERE POPID = #POPID# 
		AND AdminID In (#HaveIt#)
   </cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetStaff" datasource="#pds#">
			SELECT FirstName + ' ' + LastName As Name 
			FROM Accounts 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID In (#HaveIt#) 
				)
		</cfquery>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following staff from access to #GetPOP.POPName#.  #ValueList(GetStaff.Name)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdTax.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE POPs SET 
		Tax1 = <cfif Trim(Tax1) Is "">Null<cfelse>#Tax1#</cfif>, 
		Tax2 = <cfif Trim(Tax2) Is "">Null<cfelse>#Tax2#</cfif>, 
		Tax3 = <cfif Trim(Tax3) Is "">Null<cfelse>#Tax3#</cfif>, 
		Tax4 = <cfif Trim(Tax4) Is "">Null<cfelse>#Tax4#</cfif>, 
		TaxDesc1 = <cfif Trim(TaxDesc1) Is "">Null<cfelse>'#TaxDesc1#'</cfif>, 
		TaxDesc2 = <cfif Trim(TaxDesc2) Is "">Null<cfelse>'#TaxDesc2#'</cfif>, 
		TaxDesc3 = <cfif Trim(TaxDesc3) Is "">Null<cfelse>'#TaxDesc3#'</cfif>, 
		TaxDesc4 = <cfif Trim(TaxDesc4) Is "">Null<cfelse>'#TaxDesc4#'</cfif>, 
		Tax1Type = #Tax1Type#, 
		Tax2Type = #Tax2Type#, 
		Tax3Type = #Tax3Type#, 
		Tax4Type = #Tax4Type# 
		WHERE POPID = #POPID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetPOP" datasource="#pds#">
			SELECT POPName 
			FROM POPs 
			WHERE POPID = #POPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# updated the Tax Information for #GetPOP.POPName#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("EnterPOP.x")>
	<cftransaction>
		<cfquery name="EnterData" datasource="#pds#">
			INSERT INTO POPs 
			(POPName, Contact, Address, Address2, City, State, Zip, 
			 <cfif IsDefined("Address3")>Address3,</cfif> 
			 <cfif IsDefined("Country")>Country,</cfif> Phone1, 
			 PhoneData, Phone2, DataAreaCode, ShowYN, tax1, tax2, tax3, tax4, Tax1Type, Tax2Type, 
			 Tax3Type, Tax4Type) 
			VALUES 
			('#POPName#', '#Contact#', 
			 <cfif Trim(Address) Is "">Null<cfelse>'#Address#'</cfif>, 
			 <cfif Trim(Address2) Is "">Null<cfelse>'#Address2#'</cfif>, 
			 '#City#', '#State#', '#Zip#', 
			 <cfif IsDefined("Address3")><cfif Trim(Address3) Is "">Null<cfelse>'#Address3#'</cfif>,</cfif> 
			 <cfif IsDefined("Country")>'#Country#',</cfif> '#Phone1#', 
			 '#PhoneData#', <cfif Trim(Phone2) Is "">Null<cfelse>'#Phone2#'</cfif>, 
			 '#DataAreaCode#', #ShowYN#, 0, 0, 0, 0, 0, 0, 0, 0)
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(POPID) as MxID 
			FROM POPs
		</cfquery>
		<cfset POPID = NewID.MxID>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the POP #POPName#.')
		</cfquery>
	</cfif>
	</cftransaction>
</cfif>
<cfif IsDefined("UpdatePOP.x")>
	<cfquery name="GetPOP" datasource="#pds#">
		SELECT POPName 
		FROM POPs 
		WHERE POPID = #POPID# 
	</cfquery>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE POPs SET 
		EditedYN = 1, 
		POPName = '#POPName#',
		Contact = '#Contact#', 
		Address = <cfif Trim(Address) Is "">Null<cfelse>'#Address#'</cfif>, 
		Address2 = <cfif Trim(Address2) Is "">Null<cfelse>'#Address2#'</cfif>, 
		City = <cfif Trim(City) Is "">Null<cfelse>'#City#'</cfif>, 
		State = '#State#', 
		Zip = '#Zip#', 
	   <cfif International is "1">
			Address3 = <cfif Trim(Address3) Is "">Null<cfelse>'#Address3#'</cfif>, 
			Country = '#Country#', 
	   </cfif>
		Phone1 = '#Phone1#', 
		PhoneData = '#PhoneData#', 
		Phone2 = <cfif Trim(phone2) Is "">Null<cfelse>'#phone2#'</cfif>, 
		DataAreaCode = '#DataAreaCode#', 
		Showyn = #ShowYN# 
		WHERE POPID = #POPID#		
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'POPs','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the POP #GetPOP.POPName#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("EditID")>
	<cfset POPID = #EditID#>
</cfif>
<cfparam name="tab" default="1">
<cfparam name="POPID" default="0">
<cfquery name="OnePOP" datasource="#pds#">
	SELECT * FROM POPs 
	WHERE POPID = #POPID#
</cfquery>

<cfif tab Is 1>
	<cfset HowWide = 2>
	<cfquery name="AllStates" datasource="#pds#">
		SELECT Abbr, StateName, DefState 
		FROM states 
		WHERE ActiveYN = 1 
		ORDER BY StateName
	</cfquery>
	<cfquery name="AllCountries" datasource="#pds#">
		SELECT CountryAbbr, Country, DefCountry
		FROM Countries 
		WHERE ActiveYN = 1 
		ORDER BY Country 
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 3>
<cfelseif tab Is 3>
	<cfset HowWide = 3>
	<cfquery name="getwhohas" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, admin A, PopAdm P 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID = P.AdminID 
		AND P.POPID = #POPID#
		ORDER BY C.LastName, C.FirstName
	</cfquery>
	<cfquery name="getwhowants" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, admin A 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID Not In 
			(SELECT A.AdminID 
			 FROM Accounts C, admin A, PopAdm P 
			 WHERE C.AccountID = A.AccountID 
			 AND A.AdminID = P.AdminID 
			 AND P.POPID = #POPID#)
		ORDER BY C.LastName, C.FirstName
	</cfquery>
<cfelseif tab Is 4>
	<cfset HowWide = 3>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT P.PlanDesc, P.PlanID 
		FROM POPPlans O, Plans P 
		WHERE P.PlanID = O.PlanID 
		AND O.POPID = #POPID# 
		Order By P.PlanDesc 
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT P.PlanDesc, P.PlanID 
		FROM Plans P 
		WHERE P.PlanID <> #delaccount# 
		AND P.PlanID <> #deactaccount# 
		AND P.PlanID Not In 
			(SELECT P.PlanID 
			 FROM POPPlans O, Plans P 
			 WHERE P.PlanID = O.PlanID 
			 AND O.POPID = #POPID#) 
		Order By P.PlanDesc 
	</cfquery>
<cfelseif tab Is 5>
	<cfset HowWide = 3>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT S.StateName, S.StateID 
		FROM States S, POPsStates P 
		WHERE P.StateID = S.StateID 
		AND P.POPID = #POPID# 
		Order By S.StateName 
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT S.StateName, S.StateID 
		FROM States S 
		WHERE S.StateID Not In 
			(SELECT S.StateID 
			 FROM States S, POPsStates P 
			 WHERE P.StateID = S.StateID 
			 AND P.POPID = #POPID#) 
		Order By S.StateName 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>POP Setup</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="pops.cfm">
	<cfoutput>
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="obid" value="#obid#">
	</cfoutput>
	<input type="image" src="images/return.gif" name="Return" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#"><cfif Trim(OnePOP.POPName) Is "">POP Setup<cfelse>#OnePOP.POPName#</cfif></font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="pops2.cfm">
						<input type="hidden" name="page" value="#page#">
						<input type="hidden" name="obdir" value="#obdir#">
						<input type="hidden" name="obid" value="#obid#">
						<input type="hidden" name="POPID" value="#POPID#">
						<th bgcolor=<cfif tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">General</label></th>
						<cfif POPID Is 0>
							<th bgcolor="#thclr#">Tax Information</th>
							<th bgcolor="#thclr#">Staff Setup</th>
							<th bgcolor="#thclr#">Plan Setup</th>
							<th bgcolor="#thclr#">State/Prov Setup</th>
						<cfelse>
							<th bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Tax Information</label></th>
							<th bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Staff Setup</label></th>
							<th bgcolor=<cfif tab Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Plan Setup</label></th>
							<th bgcolor=<cfif tab Is 5>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">State/Prov Setup</label></th>				
						</cfif>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif tab Is 1>
	<cfinclude template="popstab1.cfm">
<cfelseif tab Is 2>
	<cfinclude template="popstab2.cfm">
<cfelseif tab Is 3>
	<cfinclude template="popstab3.cfm">
<cfelseif tab Is 4>
	<cfinclude template="popstab4.cfm">
<cfelseif tab Is 5>
	<cfinclude template="popstab5.cfm">
</cfif>
</table>


</center>
<cfinclude template="footer.cfm">
</body>
</html>

   