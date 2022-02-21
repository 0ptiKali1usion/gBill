<cfsetting enablecfoutputonly="yes">
<!-- Version 5.0.0 -->
<!--- This page allows setting search criteria when looking up an account.
It also serves as the page to search for an account that is to become an admin.
It also serves as the page to search for an account that is to become part of a group account.
--->
<!--- 5.0.0 07/28/99
		3.2.0 09/08/98 --->
<!-- lookup1.cfm -->

<cfinclude template="security.cfm">
<cfif IsDefined("UseExisting")>
	<cfquery name="GetFilter" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE FilterID = #SavedFilter#
	</cfquery>
	<cfquery name="DomainsFilter" datasource="#pds#">
		SELECT DomainID 
		FROM FilterDomains 
		WHERE FilterID = #SavedFilter#
	</cfquery>
	<cfquery name="PlansFilter" datasource="#pds#">
		SELECT PlanID 
		FROM FilterPlans 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="POPsFilter" datasource="#pds#">
		SELECT POPID 
		FROM FilterPOPs 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="SalesFilter" datasource="#pds#">
		SELECT AdminID 
		FROM FilterSalesp 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfif DomainsFilter.RecordCount GT 0>
		<cfset TheDomainID = ValueList(DomainsFilter.DomainID)>
	</cfif>
	<cfif PlansFilter.RecordCOunt GT 0>
		<cfset ThePlanID = ValueList(PlansFilter.PlanID)>
	</cfif>
	<cfif POPsFilter.RecordCount GT 0>
		<cfset ThePOPID = ValueList(POPsFilter.POPID)>
	</cfif>
	<cfif SalesFilter.RecordCount GT 0>
		<cfset SalesPID = ValueList(SalesFilter.AdminID)>
	</cfif>
	<cfset ReportID = 4>
	<cfset FirstParam = GetFilter.FirstParam>
	<cfset SecondParam = GetFilter.SecondParam>
	<cfset FirstAction = GetFilter.FirstAction>
	<cfset SecondAction = GetFilter.SecondAction>
	<cfset FirstField = GetFilter.FirstField>
	<cfset SecondField = GetFilter.SecondField>
	<cfset LogicConnect = GetFilter.LogicConnect>
	<cfset ActiveStatus = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="Reset" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 4 
	</cfquery>
</cfif>
<cfparam name="SavedFilter" default="0">
<cfparam name="TheDomainID" default="0">
<cfparam name="ThePlanID" default="0">
<cfparam name="ThePOPID" default="0">
<cfparam name="SalesPID" default="0">
<cfparam name="FirstParam" default="LastName">
<cfparam name="SecondParam" default="">
<cfparam name="FirstAction" default="starts">
<cfparam name="SecondAction" default="contains">
<cfparam name="FirstField" default="">
<cfparam name="SecondField" default="">
<cfparam name="LogicConnect" default="AND">
<cfparam name="ActiveStatus" default="Active">
<cfparam name="FilterName" default="">
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AdminID, CurPercent 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = 4 
</cfquery>
<cfif CheckFirst.CurPercent Is 0>
	<cfquery name="NotSaved" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 4 
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AdminID, CurPercent 
		FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 4 
	</cfquery>
</cfif>
<cfif CheckFirst.RecordCount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 4 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfquery name="GetPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In 
			(SELECT P.PlanID 
			 FROM PlanAdm P, Admin A, Accounts C
			 WHERE P.AdminID = A.AdminID 
			 AND A.AccountID = C.AccountID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY PlanDesc
	</cfquery>
	<cfquery name="GetDomains" datasource="#pds#">
		SELECT DomainID, DomainName 
		FROM Domains 
		WHERE DomainID In 
			(SELECT D.DomainID 
			 FROM DomAdm D, Admin A, Accounts C
			 WHERE D.AdminID = A.AdminID 
			 AND A.AccountID = C.AccountID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY DomainName
	</cfquery>
	<cfquery name="GetPOPs" datasource="#pds#">
		SELECT POPID, POPName 
		FROM POPs 
		WHERE POPID In 
			(SELECT P.POPID 
			 FROM POPAdm P, Admin A, Accounts C
			 WHERE P.AdminID = A.AdminID 
			 AND A.AccountID = C.AccountID 
			 AND A.AdminID = #MyAdminID#)
		ORDER BY POPName
	</cfquery>
	<cfset FName = "#StaffMemberName.FirstName# #StaffMemberName.LastName#">
	<cfquery name="GetSalesP" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A 
		WHERE C.AccountID = A.AccountID 
		AND SalesPersonYN = 1 
		<cfif GetOpts.WhatView Is 1>
			AND AdminID = #MyAdminID# 
		</cfif>
		ORDER BY C.LastName, C.FirstName 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Search</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=4','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput>
<body #colorset# <cfif CheckFirst.RecordCount Is 0>OnLoad="document.Lookup.FirstField.focus()"</cfif> >
</cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Customer Search</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.RecordCount Is 0>
	<tr>
		<cfoutput>
		<th colspan="4" bgcolor="#tdclr#"><table border="0" width="100%">
		</cfoutput>
				<tr>
					<cfif SavedFilters.RecordCount GT 0>
						<form method="post" action="lookup1.cfm">
							<td colspan="2"><table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
						</form>
						<form method="post" action="lookup1.cfm">
										<td><select name="SavedFilter">
											<cfloop query="SavedFilters">
												<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
											</cfloop>
										</select> <input type="submit" name="UseExisting" value="Load"></td>
									</tr>									
								</table></td>
						</form>
					</cfif>
					<FORM Name="Lookup" METHOD=post ACTION="lookup.cfm" onsubmit="MsgWindow()">
						<cfoutput>
							<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
						</cfoutput>
				</tr>
			</table></th>
	</tr>
		<cfoutput>
		<tr bgcolor="#tdclr#">
			<td colspan="4">
				<table border="0">
					<tr valign="top">
						<td rowspan="2"><SELECT name="FirstParam">
							<option <cfif FirstParam Is "lastname">selected</cfif> value="lastname">Last Name
							<option <cfif FirstParam Is "firstname">selected</cfif> value="firstname">First Name
							<option <cfif FirstParam Is "login">selected</cfif> value="login">gBill Login
							<option <cfif FirstParam Is "company">selected</cfif> value="company">Company
							<option <cfif FirstParam Is "address1">selected</cfif> value="address1">Address
							<option <cfif FirstParam Is "city">selected</cfif> value="city">City
							<option <cfif FirstParam Is "dayphone">selected</cfif> value="dayphone">Home Phone Number
							<option <cfif FirstParam Is "evephone">selected</cfif> value="evephone">Work Phone Number
							<option <cfif FirstParam Is "EMail">selected</cfif> value="EMail">E-Mail Address
							<option <cfif FirstParam Is "Auth">selected</cfif> value="Auth">Auth Login
							<option <cfif FirstParam Is "FTP">selected</cfif> value="FTP">FTP Login
							<option <cfif FirstParam Is "accountid">selected</cfif> value="accountid">UserID
						</SELECT></td>
						<td><INPUT type="radio" <cfif FirstAction Is "Starts">checked</cfif> name="FirstAction" value="Starts"> Starts With</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "contains">checked</cfif> value="contains"> Contains</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "Like">checked</cfif> value="Like"> Like</td>
						<td rowspan="2"><INPUT NAME="FirstField" TYPE="TEXT" value="#FirstField#" SIZE="25" maxlength="100"></td>
					</tr>
					<tr>
						<td><INPUT type="radio" <cfif FirstAction Is "NotStarts">checked</cfif> name="FirstAction" value="NotStarts">Not Starts With</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "NotContains">checked</cfif> value="NotContains">Not Contains</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "Not">checked</cfif> value="Not">Not Like</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="4" align="center" bgcolor="#tdclr#"><INPUT TYPE=RADIO <cfif LogicConnect Is "And">CHECKED</cfif> NAME="LogicConnect" VALUE="And">AND <INPUT TYPE=RADIO <cfif LogicConnect Is "Or">CHECKED</cfif> NAME="LogicConnect" VALUE="Or">OR</td>
		</tr>
		<tr>
			<td colspan="4" bgcolor="#tdclr#">
				<table border="0">
					<tr valign="top">
						<td rowspan="2"><SELECT  name="SecondParam">
							<OPTION value="">-
							<OPTION <cfif SecondParam Is "lastname">selected</cfif> value="lastname">Last Name
							<OPTION <cfif SecondParam Is "firstname">selected</cfif> value="firstname">First Name
							<OPTION <cfif SecondParam Is "login">selected</cfif> value="login">gBill Login
							<OPTION <cfif SecondParam Is "address1">selected</cfif> value="address1">Address
							<OPTION <cfif SecondParam Is "city">selected</cfif> value="city">City
							<OPTION <cfif SecondParam Is "dayphone">selected</cfif> value="dayphone">Home Phone Number
							<OPTION <cfif SecondParam Is "evephone">selected</cfif> value="evephone">Work Phone Number
						</SELECT></td>
						<td><INPUT type="radio" <cfif SecondAction Is "starts">checked</cfif> name="SecondAction" value="starts"> Starts With</td>
						<td><INPUT type="radio" <cfif SecondAction Is "contains">checked</cfif> name="SecondAction" value="contains"> Contains</td>
						<td><INPUT type="radio" name="SecondAction" <cfif SecondAction Is "Like">checked</cfif> value="Like"> Like</td>
						<td rowspan="2"><INPUT NAME="SecondField" TYPE="TEXT" value="#SecondField#" SIZE="25" maxlength="100"></td>
					</tr>
					<tr>
						<td><INPUT type="radio" <cfif SecondAction Is "NotStarts">checked</cfif> name="SecondAction" value="NotStarts">Not Starts With</td>
						<td><INPUT type="radio" <cfif SecondAction Is "NotContains">checked</cfif> name="SecondAction" value="NotContains">Not Contains</td>
						<td><INPUT type="radio" name="SecondAction" <cfif SecondAction Is "Not">checked</cfif> value="Not"> Not Like</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="4" bgcolor="#tdclr#"><INPUT type="radio" name="ActiveStatus" <cfif ActiveStatus Is "Active">checked</cfif> value="Active"> Active Accounts <INPUT type="radio" name="ActiveStatus" <cfif ActiveStatus Is "Inactive">checked</cfif> value="Inactive"> Inactive Accounts <INPUT type="radio" name="ActiveStatus" <cfif ActiveStatus Is "Both">checked</cfif> value="Both"> Both</td>
		</tr>
		<tr>
			<th colspan="4" bgcolor="#tdclr#">Save search results? <input type="Radio" name="savesearch" value="1" checked> Yes <input type="Radio" name="savesearch" value="0"> No</th>
		</tr>
		<tr>
			<th colspan="4"><input type="image" src="images/search.gif" border="0"></th>
		</tr>
		<tr bgcolor="#tdclr#" valign="top">
			<td bgcolor="#tbclr#">Salesperson</td>
	</cfoutput>
			<td><select name="SalesPID" multiple size="6">
				<option <cfif SalesPID Is "0">selected</cfif> value="0">All Salespersons
				<cfoutput query="GetSalesP">
					<option <cfif ListFind(SalesPID,AdminID) GT 0>selected</cfif> value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
			<cfoutput>
			<td align="right" bgcolor="#tbclr#">Plans</td>
			</cfoutput>
			<td><select name="PlanID" multiple size="6">
				<option <cfif ThePlanID Is "0">selected</cfif> value="0">All Plans
				<cfoutput query="GetPlans">
					<option <cfif ListFind(ThePlanID,PlanID) GT 0>selected</cfif> value="#PlanID#">#PlanDesc#
				</cfoutput>
				<option value="">______________________________
			</select></td>
		</tr>
		<cfoutput>
		<tr valign="top" bgcolor="#tdclr#">
			<td align="right" bgcolor="#tbclr#">Domains</td>
		</cfoutput>
			<td><select name="DomainID" multiple size="6">
				<option <cfif TheDomainID Is "0">selected</cfif> value="0">All Domains
				<cfoutput query="GetDomains">
					<option <cfif ListFind(TheDomainID,DomainID) GT 0>selected</cfif> value="#DomainID#">#DomainName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
			<cfoutput>
			<td align="right" bgcolor="#tbclr#">POPs</td>
			</cfoutput>
			<td><select name="POPID" multiple size="6">
					<option <cfif ThePOPID Is "0">selected</cfif> value="0">All POPs
					<cfoutput query="GetPOPS">
						<option <cfif ListFind(ThePOPID,POPID) GT 0>selected</cfif> value="#POPID#">#POPName#
					</cfoutput>
					<option value="">______________________________
			</select></td>
		</tr>
	</form>
<cfelse>
	<cfif CheckFirst.Recordcount Gt 1>
		<cflocation addtoken="no" url="lookup.cfm">
	</cfif>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">You currently have a results list of 1.<br>
			To change the current search criteria click 'Change Criteria'.<br>
			To view the customer info click 'Continue'.</td>
		</tr>
		<tr>
			<th colspan="4">
				<table border="0">
					<tr>
						<form method="post" action="lookup.cfm">
							<td><input type="image" src="images/continue.gif" name="Continue" border="0"></td>
						</form>
						<form method="post" action="lookup1.cfm">
							<td><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfoutput>
</cfif>
</table>		
</center>
<cfinclude template="footer.cfm">
</body>
</html>
     