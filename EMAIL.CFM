<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 1 of the mass emailer. --->
<!--- 3.2.0 09/08/98 --->
<!--- email.cfm --->

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
	<cfset LetterID = 6>
	<cfset BegDay = GetFilter.FirstParam>
	<cfset EndDay = GetFilter.SecondParam>
	<cfset MinAmnt = GetFilter.FirstAction>
	<cfset MinCredit = GetFilter.SecondAction>
	<cfset Credit = GetFilter.FirstField>
	<cfset CheckD = GetFilter.SecondField>
	<cfset Postal = GetFilter.LogicConnect>
	<cfset GroupSubs = GetFilter.ActiveStatus>
	<cfset FilterName = GetFilter.FilterName>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE LetterID = 6 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT AccountID 
	FROM EMailOutgoing 
	WHERE LetterID = 6 
	AND AdminID = #MyAdminID#
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE LetterID = 6 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfquery name="getemail" datasource="#pds#">
		SELECT EMail 
		FROM AccountsEMail 
		WHERE PrEMail = 1 
		AND AccountID = 
			(SELECT AccountID 
			 FROM Admin 
			 WHERE AdminID = #MyAdminID#)
	</cfquery>
	<cfparam name="SavedFilter" default="0">
	<cfparam name="FilterName" default="">
	<cfparam name="BegDay" default="1">
	<cfparam name="Credit" default="1">
	<cfparam name="EndDay" default="31">
	<cfparam name="CheckD" default="1">
	<cfparam name="MinAMnt" default="NA">
	<cfparam name="Postal" default="1">
	<cfparam name="MinCredit" default="NA">
	<cfparam name="GroupSubs" default="1">
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Mass E-Mail Criteria</TITLE>
<script language="javascript">
<!--  
function FilterWindow()
	{
    window.open('filter.cfm?LetterID=6','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
	<cfinclude template="coolsheet.cfm"></head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th bgcolor="#ttclr#" colspan="4"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select Criteria</font></th>
		</tr>
		<tr>
			<th colspan="4" bgcolor="#tdclr#"><table border="0" width="100%">
		</tr>
	</cfoutput>
			<tr>
				<cfif SavedFilters.RecordCount GT 0>
					<form method="post" action="email.cfm">
						<td colspan="2"><table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
					</form>
					<form method="post" action="email.cfm">
										<td><select name="SavedFilter">
											<cfloop query="SavedFilters">
												<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
											</cfloop>
										</select> <input type="submit" name="UseExisting" value="Load"></td>
									</tr>									
								</table></td>
								<cfoutput>
								<cfif IsDefined("WhoFrom")>
									<input type="hidden" name="WhoFrom" value="#WhoFrom#">
								</cfif>
								<cfif IsDefined("Message")>
									<input type="hidden" name="Message" value="#Message#">
								</cfif>
								<cfif IsDefined("Subject")>
									<input type="hidden" name="Subject" value="#Subject#">
								</cfif>
								<cfif IsDefined("BDomainName")>
									<input type="hidden" name="BDomainName" value="#BDomainName#">
								</cfif>
								<cfif IsDefined("CDomainName")>
									<input type="hidden" name="CDomainName" value="#CDomainName#">
								</cfif>
								<cfif IsDefined("SDomainName")>
									<input type="hidden" name="SDomainName" value="#SDomainName#">
								</cfif>
								<cfif IsDefined("whofrom2")>
									<input type="hidden" name="whofrom2" value="#whofrom2#">
								</cfif>
								<cfif IsDefined("LetterID")>
									<input type="hidden" name="LetterID" value="#LetterID#">
								</cfif>
								</cfoutput>
						</form>
					</cfif>
		<form method="post" action="email1.cfm">
						<cfoutput>
							<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
						</cfoutput>
				</tr>
			</table></th>
		</tr>
		<cfoutput>
			<tr valign="top" bgcolor="#tdclr#">
			</cfoutput>
				<td align="right"><select name="begday">
					<cfloop index="B5" from="1" to="31">
						<cfif #B5# lt 10><cfset #B5# = "0" & #B5#></cfif>
						<cfoutput><option <cfif BegDay Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
					</cfloop>
				</select></td>
				<cfoutput>
				<td bgcolor="#tbclr#">Beginning Due Day</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Credit Is 1>checked</cfif> name="Credit" value="1"></td>
				<td bgcolor="#tbclr#">Include Credit Card Customers</td>
				</cfoutput>
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
			</cfoutput>
				<td align="right"><select name="EndDay">
					<cfloop index="B5" from="1" to="31">
						<cfif #B5# lt 10><cfset #B5# = "0" & #B5#></cfif>
						<cfoutput><option <cfif EndDay Is B5>Selected</cfif> value="#B5#">#B5#</cfoutput>
					</cfloop>	
				</select></td>			
			<cfoutput>
				<td bgcolor="#tbclr#">Ending Due Day</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif CheckD Is 1>checked</cfif> name="CheckD" value="1"></td>
				<td bgcolor="#tbclr#">Include Check Debit Customers</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#" align="right"><input type="text" name="MinAmnt" size="5" value="#MinAmnt#"></td>
				<td bgcolor="#tbclr#">Min Amount Owed</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif Postal Is 1>checked</cfif> name="Postal" value="1"></td>
				<td bgcolor="#tbclr#">Include Postal Statement Customers</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#" align="right"><input type="text" name="MinCredit" size="5" value="#MinCredit#"></td>
				<td bgcolor="#tbclr#">Min Credit Amount</td>
				<td align="right" bgcolor="#tdclr#"><input type="checkbox" <cfif GroupSubs Is 1>checked</cfif> name="GroupSubs" value="1"></td>
				<td bgcolor="#tbclr#">Include Group SubAccounts</td>
			</tr>
			<tr>
				<th colspan="4"><input type="image" src="images/continue.gif" name="CarryOn" border="0"></th>
			</tr>
			</cfoutput>
			<cfinclude template="searchcriteria.cfm">
			<cfoutput>
			<cfif IsDefined("WhoFrom")>
				<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			</cfif>
			<cfif IsDefined("Message")>
				<input type="hidden" name="Message" value="#Message#">
			</cfif>
			<cfif IsDefined("Subject")>
				<input type="hidden" name="Subject" value="#Subject#">
			</cfif>
			<cfif IsDefined("BDomainName")>
				<input type="hidden" name="BDomainName" value="#BDomainName#">
			</cfif>
			<cfif IsDefined("CDomainName")>
				<input type="hidden" name="CDomainName" value="#CDomainName#">
			</cfif>
			<cfif IsDefined("SDomainName")>
				<input type="hidden" name="SDomainName" value="#SDomainName#">
			</cfif>
			<cfif IsDefined("whofrom2")>
				<input type="hidden" name="whofrom2" value="#whofrom2#">
			</cfif>
			<cfif IsDefined("LetterID")>
				<input type="hidden" name="LetterID" value="#LetterID#">
			</cfif>
			</cfoutput>
		</form>
	</table>
	</center>
		<cfinclude template="footer.cfm">
	</body>
	</html>
<cfelse>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>EMail Session In Progress</title>
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<td align="center" colspan="2" bgcolor="#thclr#">Mass EMail Tool</td>
	</cfoutput>
		</tr>
		<tr>
			<form method="post" action="email2.cfm">
				<td><input type="image" src="images/viewlist.gif" name="continue" border="0"></td>
				<cfoutput>
					<cfif IsDefined("WhoFrom")>
						<input type="hidden" name="WhoFrom" value="#WhoFrom#">
					</cfif>
					<cfif IsDefined("Message")>
						<input type="hidden" name="Message" value="#Message#">
					</cfif>
					<cfif IsDefined("Subject")>
						<input type="hidden" name="Subject" value="#Subject#">
					</cfif>
					<cfif IsDefined("BDomainName")>
						<input type="hidden" name="BDomainName" value="#BDomainName#">
					</cfif>
					<cfif IsDefined("CDomainName")>
						<input type="hidden" name="CDomainName" value="#CDomainName#">
					</cfif>
					<cfif IsDefined("SDomainName")>
						<input type="hidden" name="SDomainName" value="#SDomainName#">
					</cfif>
					<cfif IsDefined("whofrom2")>
						<input type="hidden" name="whofrom2" value="#whofrom2#">
					</cfif>
					<cfif IsDefined("LetterID")>
						<input type="hidden" name="LetterID" value="#LetterID#">
					</cfif>
				</cfoutput>
			</form>
			<form method="post" action="email.cfm">
				<td><input type="image" src="images/changecriteria.gif" name="startover" border="0"></td>
				<cfoutput>
				<cfif IsDefined("WhoFrom")>
					<input type="hidden" name="WhoFrom" value="#WhoFrom#">
				</cfif>
				<cfif IsDefined("Message")>
					<input type="hidden" name="Message" value="#Message#">
				</cfif>
				<cfif IsDefined("Subject")>
					<input type="hidden" name="Subject" value="#Subject#">
				</cfif>
				<cfif IsDefined("BDomainName")>
					<input type="hidden" name="BDomainName" value="#BDomainName#">
				</cfif>
				<cfif IsDefined("CDomainName")>
					<input type="hidden" name="CDomainName" value="#CDomainName#">
				</cfif>
				<cfif IsDefined("SDomainName")>
					<input type="hidden" name="SDomainName" value="#SDomainName#">
				</cfif>
				<cfif IsDefined("whofrom2")>
					<input type="hidden" name="whofrom2" value="#whofrom2#">
				</cfif>
				<cfif IsDefined("LetterID")>
					<input type="hidden" name="LetterID" value="#LetterID#">
				</cfif>
				</cfoutput>
			</form>
		</tr>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>
    