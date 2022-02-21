<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is a report of how many customers are on each plan by domain. --->
<!--- 4.0.0 09/08/99
		3.2.0 09/08/98 --->
<!--- report.cfm --->

<cfinclude template="security.cfm">

<cfif IsDefined("ShowReport.x")>
	<cfif (Mrow1 Is "") OR (Mrow1 Is "0")>
		<cfset Mrow1 = Mrow>
	</cfif>
	<cfif (Mrow2 Is "") OR (Mrow2 Is "0")>
		<cfset Mrow2 = Mrow>
	</cfif>
	<cfquery name="AllDoms" datasource="#pds#">
		SELECT D.DomainName, D.DomainID, Count(A.AccountID) AS COaid 
		FROM AccntPlans A, Domains D 
		WHERE A.EMailDomainID = D.DomainID 
		AND D.DomainID IN 
			(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#)
		<cfif SelectedDomains GT 0>
			AND D.DomainID IN (#SelectedDomains#)
		</cfif>
		GROUP BY D.Domainname, D.DomainID 
		ORDER BY D.DomainName 
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		SELECT P.PlanID, P.PlanDesc, Count(A.AccountID) AS COaid 
		FROM AccntPlans A, Plans P 
		WHERE A.PlanID = P.PlanID 
		AND P.PlanID IN 
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		<cfif SelectedPlans GT 0>
			AND P.PlanID IN (#SelectedPlans#)
		</cfif>
		GROUP BY P.PlanID, P.PlanDesc 
		ORDER BY P.PlanDesc
	</cfquery>
	<cfparam name="Mrow2" default="#AllDoms.RecordCount#">
	<cfparam name="Mrow1" default="#AllPlans.RecordCount#">
	<cfparam name="Pgv" default="1">
	<cfif Pgv Is 0>
		<cfset MaxRows2 = AllDoms.RecordCount>
		<cfset Srow2 = 1>
		<cfset Erow2 = MaxRows2>
	<cfelse>
		<cfset MaxRows2 = Mrow2>
		<cfset Srow2 = (Pgv*Mrow2)-(Mrow2-1)>
		<cfset Erow2 = Srow2 + (Mrow2 - 1)>
		<cfif Erow2 GT AllDoms.RecordCount>
			<cfset Erow2 = AllDoms.RecordCount>
		</cfif>
	</cfif>
	<cfset PageNumber2 = Ceiling(AllDoms.RecordCount/Mrow2)>

	<cfparam name="Pg" default="1">
	<cfif Pg Is 0>
		<cfset MaxRows = AllPlans.RecordCount>
		<cfset Srow = 1>
	<cfelse>
		<cfset MaxRows = Mrow1>
		<cfset Srow = (Pg*Mrow1)-(Mrow1-1)>
	</cfif>
	<cfset PageNumber = Ceiling(AllPlans.RecordCount/Mrow1)>
	<cfset Erow = Srow + (Mrow1 - 1)>
	<cfif Erow GT AllPlans.RecordCount>
		<cfset Erow = AllPlans.RecordCount>
	</cfif>
	<cfloop query="AllPlans">
		<cfset ThePlanID = AllPlans.PlanID>
	   <cfloop query="AllDoms">
			<cfset TheDomID = AllDoms.DomainID>
			<cfif TheDomID Is "">
				<cfset TheDomID = 0>
			</cfif>
			<cfquery name="r#TheDomID#tots#ThePlanID#" datasource="#pds#">
				SELECT Count(AccountID) AS CaID 
				FROM AccntPlans
				WHERE PlanID = #ThePlanID# 
				AND EMailDomainID = #TheDomID# 
			</cfquery>
		</cfloop>
	</cfloop>
	<cfoutput query="AllDoms">
		<cfif DomainID Is "">
			<cfset TheDomID = 0>
		<cfelse>
			<cfset TheDomID = DomainID>
		</cfif>
		<cfset "vtot#TheDomID#" = 0>
	</cfoutput>
	<cfset HTot = 0>
	<cfset GrndTot = 0>
	<cfset HowWide2 = (Erow2 - Srow2) +3>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Report Of Plans By Domain</title>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<form method="post" action="report.cfm">
		<input type="image" name="Change" src="images/changecriteria.gif" border="0">
	</form>
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide2#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Report Of Plans By Domain (Based on EMail addresses)</font></th>
		</tr>	
	</cfoutput>
		<cfif PageNumber GT 1 OR PageNumber2 GT 1>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td colspan="#HowWide2#">
					<table border="0" width="100%">
						<tr>
			</cfoutput>
							<form method="post" action="report.cfm">
								<cfif PageNumber GT 1>
									<td><select name="Pg" onchange="submit()">
										<cfloop index="B5" from="1" to="#PageNumber#">
											<cfset ArrayPoint = B5*Mrow1-(Mrow1-1)>
											<cfset DispStr = AllPlans.PlanDesc[ArrayPoint]>
											<cfoutput><option <cfif B5 Is Pg>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
										</cfloop>
										<cfoutput><option <cfif Pg Is 0>selected</cfif> value="0">View All #AllPlans.RecordCount#</cfoutput>
									</select></td>
								</cfif>
								<cfif PageNumber2 GT 1>
									<td align="right"><select name="Pgv" onchange="submit()">
										<cfloop index="B5" from="1" to="#PageNumber2#">
											<cfset ArrayPoint = B5*Mrow2-(Mrow2-1)>
											<cfset DispStr = AllDoms.DomainName[ArrayPoint]>
											<cfoutput><option <cfif B5 Is Pgv>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
										</cfloop>
										<cfoutput><option <cfif Pgv Is 0>selected</cfif> value="0">View All #AllDoms.RecordCount#</cfoutput>
									</select></td>
								</cfif>
								<cfoutput>
									<input type="Hidden" name="SelectedDomains" value="#SelectedDomains#">
									<input type="Hidden" name="SelectedPlans" value="#SelectedPlans#">
									<input type="Hidden" name="ShowReport.x" value="1">
								</cfoutput>
							</form>
						</tr>
					</table>
				</td>
			</tr>
		</cfif>
		<cfoutput>
		<tr valign="top" bgcolor="#thclr#">
		</cfoutput>
			<th>Plans \ Domains</th>
			<cfloop query="AllDoms" startrow="#Srow2#" endrow="#Erow2#">
				<cfoutput><td bgcolor="#thclr#">#domainname#</td></cfoutput>
			</cfloop>
			<cfoutput><td bgcolor="#thclr#">Total</td></cfoutput>
		</tr>
		<cfloop query="AllPlans" startrow="#srow#" endrow="#erow#">
			<cfset OuterID = AllPlans.PlanID>	
			<cfoutput>
			<tr>
				<td bgcolor="#thclr#">#plandesc#</td>
			</cfoutput>
				<cfloop query="AllDoms" startrow="#Srow2#" endrow="#Erow2#">
					<cfif DomainID Is "">
						<cfset TheDomID = 0>
					<cfelse>
						<cfset TheDomID = DomainID>
					</cfif>
					<cfset tot2 = Evaluate("r#TheDomID#tots#OuterID#.caid")>
					<cfset HTot = HTot + Tot2>
					<cfset "vtot#TheDomID#" = Evaluate("vtot#TheDomID#") + Tot2>
					<cfoutput><td align="right" bgcolor="#tbclr#">#Tot2#</td></cfoutput>
				</cfloop>
				<cfoutput><th align="right" bgcolor="#tbclr#">#HTot#</th></cfoutput>   
				<cfset GrndTot = GrndTot + HTot>
				<cfset HTot = 0>
			</tr>
		</cfloop>
		<cfoutput>
		<tr>
			<td bgcolor="#thclr#"><b>Total</b></td>
		</cfoutput>
			<cfloop query="AllDoms" startrow="#Srow2#" endrow="#Erow2#">
				<cfif DomainID Is "">
					<cfset TheDomID = 0>
				<cfelse>
					<cfset TheDomID = DomainID>
				</cfif>
				<cfoutput><th align="right" bgcolor="#tdclr#">#Evaluate("vtot#TheDomID#")#</th></cfoutput>
			</cfloop>
			<cfoutput><th bgcolor="#tdclr#">#GrndTot#</th></cfoutput>
		</tr>
		<cfif PageNumber GT 1 OR PageNumber2 GT 1>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td colspan="#HowWide2#">
					<table border="0" width="100%">
						<tr>
			</cfoutput>
							<form method="post" action="report.cfm">
								<cfif PageNumber GT 1>
									<td><select name="Pg" onchange="submit()">
										<cfloop index="B5" from="1" to="#PageNumber#">
											<cfset ArrayPoint = B5*Mrow1-(Mrow1-1)>
											<cfset DispStr = AllPlans.PlanDesc[ArrayPoint]>
											<cfoutput><option <cfif B5 Is Pg>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
										</cfloop>
										<cfoutput><option <cfif Pg Is 0>selected</cfif> value="0">View All #AllPlans.RecordCount#</cfoutput>
									</select></td>
								</cfif>
								<cfif PageNumber2 GT 1>
									<td align="right"><select name="Pgv" onchange="submit()">
										<cfloop index="B5" from="1" to="#PageNumber2#">
											<cfset ArrayPoint = B5*Mrow2-(Mrow2-1)>
											<cfset DispStr = AllDoms.DomainName[ArrayPoint]>
											<cfoutput><option <cfif B5 Is Pgv>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
										</cfloop>
										<cfoutput><option <cfif Pgv Is 0>selected</cfif> value="0">View All #AllDoms.RecordCount#</cfoutput>
									</select></td>
								</cfif>
								<cfoutput>
									<input type="Hidden" name="SelectedDomains" value="#SelectedDomains#">
									<input type="Hidden" name="SelectedPlans" value="#SelectedPlans#">
									<input type="Hidden" name="ShowReport.x" value="1">
								</cfoutput>
							</form>
						</tr>
					</table>
				</td>
			</tr>
		</cfif>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
 <cfelse>
 	<cfquery name="SelectablePlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID In
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		ORDER BY PlanDesc 
	</cfquery>
 	<cfquery name="SelectableDomains" datasource="#pds#">
		SELECT DomainName, DomainID 
		FROM Domains 
		WHERE DomainID IN 
			(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		AND DomainID IN 
			(SELECT EMailDomainID 
			 FROM AccntPlans 
			 GROUP BY EMailDomainID) 
		ORDER BY DomainName 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<html>
	<head>
	<title>Select Criteria</title>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Report Of Plans By Domain Criteria</font></th>
		</tr>	
		<form method="post" action="report.cfm">
			<tr valign="top">
				<td bgcolor="#tbclr#">Plans</td>
				<td bgcolor="#tbclr#">Domains</td>
			</tr>
			<tr>
				<td bgcolor="#tdclr#"><input type="Text" value="#SelectablePlans.RecordCount#" name="Mrow1" size="3"> Plans Per Page</td>
				<td bgcolor="#tdclr#"><input type="Text" value="#SelectableDomains.RecordCount#" name="Mrow2" size="3"> Domains Per Page</td>
			</tr>
			<tr bgcolor="#tdclr#">
	</cfoutput>
				<td><select name="SelectedPlans" size="10" multiple>
					<option selected value="0">All Plans
					<cfoutput query="SelectablePlans">
						<option value="#PlanID#">#PlanDesc#
					</cfoutput>
					<option value="0">___________________________________
				</select></td>
				<td><select name="SelectedDomains" size="10" multiple>
					<option selected value="0">All Domains
					<cfoutput query="SelectableDomains">
						<option value="#DomainID#">#DomainName#
					</cfoutput>
					<option value="0">___________________________________
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/viewlist.gif" name="ShowReport" border="0"></th>
			</tr>
		</form>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
 </cfif>
   