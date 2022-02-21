<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page allows setting search criteria when looking up an account.
It also serves as the page to search for an account that is to become an admin.
It also serves as the page to search for an account that is to become part of a group account.
--->
<!--- 4.0.1 02/08/01 Added Feature to look for an AutoLoad filter.
		4.0.0 07/28/99
		3.2.0 09/08/98 --->
<!--- lookup1.cfm --->

<cfinclude template="security.cfm">
<cfquery name="CheckForOnLoad" datasource="#pds#">
	SELECT RepID 
	FROM Reports 
	WHERE ReportID = 4 
</cfquery>
<cfif CheckForOnLoad.RecordCount GT 0>
	<cfquery name="GetTheOnLoad" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = 4 
		AND AdminID = #MyAdminID# 
		AND OnLoadPage = 1
	</cfquery>
	<cfif GetTheOnLoad.RecordCount GT 0>
		<cfset UseExisting = 1>
		<cfset SavedFilter = GetTheOnLoad.FilterID>
	</cfif>
</cfif>

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
	<cfset SaveSearch = GetFilter.SaveSearch>
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
<cfparam name="SaveSearch" default="1">
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AdminID, CurPercent, FirstName, LastName 
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
		SELECT AdminID, CurPercent, FirstName, LastName 
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
	<cfset FName = "#StaffMemberName.FirstName# #StaffMemberName.LastName#">
</cfif>
<cfquery name="GetExtraSearch" datasource="#pds#">
	SELECT V.FieldName, W.ScreenPrompt 
	FROM ReportSetup S, ReportValues V, WizardSetup W 
	WHERE S.ReportID = V.ReportID 
	AND V.WizID = W.WizID 
	AND S.ReportID = 4 
	AND V.ActiveYN = 1
	ORDER BY V.SortOrder, W.ScreenPrompt 
</cfquery>
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
<body #colorset# <cfif (CheckFirst.RecordCount Is 0) AND (IsDefined("lookup.x"))>OnLoad="document.Lookup.FirstField.focus()"</cfif> >
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
		</cfoutput>
							<cfoutput query="GetExtraSearch">
								<option <cfif FirstParam Is "#FieldName#">selected</cfif> value="#FieldName#">#ScreenPrompt#
							</cfoutput>
						</SELECT></td>
		<cfoutput>
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
		</cfoutput>
							<cfoutput query="GetExtraSearch">
								<option <cfif FirstParam Is "#FieldName#">selected</cfif> value="#FieldName#">#ScreenPrompt#
							</cfoutput>
						</SELECT></td>
		<cfoutput>
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
			<th colspan="4" bgcolor="#tdclr#">Save search results? <input type="Radio" name="savesearch" <cfif SaveSearch Is "1">checked</cfif> value="1"> Yes <input type="Radio" name="savesearch" <cfif SaveSearch Is "0">checked</cfif> value="0"> No</th>
		</tr>
		<tr>
			<th colspan="4"><input type="image" name="lookup" src="images/search.gif" border="0"></th>
		</tr>
	</cfoutput>
		<cfinclude template="searchcriteria.cfm">
	</form>
<cfelse>
	<cfif CheckFirst.Recordcount Gt 1>
		<cflocation addtoken="no" url="lookup.cfm">
	</cfif>
	<cfoutput>
		<tr>
			<td colspan="4" bgcolor="#tbclr#">You currently have a saved result list of 1.<br>
			To change the current search criteria click 'Change Criteria'.<br>
			To view #CheckFirst.FirstName# #CheckFirst.LastName# click 'Continue'.</td>
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
     