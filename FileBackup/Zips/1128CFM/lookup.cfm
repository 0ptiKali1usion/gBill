<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 07/28/99 --->
<!--- lookup.cfm --->
<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 4 
		AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
	</cfquery>
	<cfif CheckFirst.RecordCount GT 0>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterDomains 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPlans 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPOPs 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterSalesp 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="ChangeFilter" datasource="#pds#">
			DELETE FROM Filters 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM Filters 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 4 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,ReportID,FilterName,FirstParam,SecondParam,FirstAction,SecondAction,
				 FirstField,SecondField,LogicConnect,ActiveStatus) 
				VALUES 
				(#MyAdminID#,4,
				 <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 '#FirstParam#',
				<cfif Trim(SecondParam) Is "">Null<cfelse>'#SecondParam#'</cfif>,'#FirstAction#',
				'#SecondAction#',<cfif Trim(FirstField) Is "">Null<cfelse>'#FirstField#'</cfif>, 
				 <cfif Trim(SecondField) Is "">Null<cfelse>'#SecondField#'</cfif>, 
				 '#LogicConnect#','#ActiveStatus#')
			</cfquery>
			<cfquery name="NewFilter" datasource="#pds#">
				SELECT Max(FilterID) as NewID 
				FROM Filters 
			</cfquery>
			<cfset FilterID = NewFilter.NewID>
		</cftransaction>
		<cfloop index="B5" list="#PlanID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPlans 
					(FilterID, PlanID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#POPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPOPs 
					(FilterID, POPID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#DomainID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterDomains 
					(FilterID, DomainID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#SalesPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterSalesp 
					(FilterID, AdminID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<cfif IsDefined("ActiveStatus")>
		<cfquery name="SearchResults" datasource="#pds#">
			INSERT INTO GrpLists 
			(ReportID,AdminID,AccountID,FirstName,Lastname,City,Address,CurPercent,Phone,Company,
			 PhoneWk, Login, EMail, CreateDate)
			SELECT 4,#MyAdminID#,A.AccountID,A.FirstName,A.Lastname,A.City,
			A.Address1, #savesearch#, 
			<cfif FirstParam Is Not "evephone">A.DayPhone<cfelse>Null</cfif>, 
			A.Company, 
			<cfif FirstParam Is "evephone">A.EvePhone<cfelse>Null</cfif>, 
			<cfif FirstParam Is "EMail">
				A.Login, E.EMail, #Now()#
				FROM Accounts A, AccntPlans P, AccountsEMail E 
				WHERE A.AccountID = P.AccountID 
				AND P.AccntPlanID = E.AccntPlanID
			<cfelseif FirstParam Is "Auth">
				R.UserName, Null, #Now()# 
				FROM Accounts A, AccntPlans P, AccountsAuth R 
				WHERE A.AccountID = P.AccountID 
				AND P.AccntPlanID = R.AccntPlanID
			<cfelseif FirstParam Is "FTP">
				F.UserName, Null, #Now()# 
				FROM Accounts A, AccntPlans P, AccountsFTP F 
				WHERE A.AccountID = P.AccountID 
				AND P.AccntPlanID = F.AccntPlanID
			<cfelse>
				A.Login, Null, #Now()# 
				FROM Accounts A 
				WHERE 0 = 0 
			</cfif>
			<cfif ActiveStatus Is "Active">
				AND A.CancelYN = 0 
			<cfelseif ActiveStatus Is "InActive">
				AND A.CancelYN = 1 
			</cfif>
			<cfif (SalesPID Is Not 0) AND (SalesPID Is Not "")>
				AND A.SalesPersonID In (#SalesPID#)
			</cfif>
			<cfif FirstParam Is "EMail">
				AND (E.Email 
			<cfelseif FirstParam Is "Auth">
				AND (R.UserName
			<cfelseif FirstParam Is "FTP">
				AND (F.UserName
			<cfelse>
				AND (<cfif FirstParam Is Not "accountid">A.#FirstParam#<cfelse>Convert(varchar(10),A.AccountID)</cfif>
			</cfif>
			<cfif FirstAction Is "Starts">Like '#FirstField#%' 
			<cfelseif FirstAction Is "Contains">Like '%#FirstField#%' 
			<cfelseif FirstAction Is "Like">Like '#FirstField#' 
			<cfelseif FirstAction Is "NotStarts">Not Like '#FirstField#%' 
			<cfelseif FirstAction Is "NotContains">Not Like '%#FirstField#%' 
			<cfelseif FirstAction Is "Not">Not Like '#FirstField#' 
			</cfif>
			<cfif SecondParam Is Not "">
				#LogicConnect#
				A.#SecondParam# 
				<cfif SecondAction Is "Starts">Like '#SecondField#%' 
				<cfelseif SecondAction Is "Contains">Like '%#SecondField#%' 
				<cfelseif SecondAction Is "Like">Like '#SecondField#' 
				<cfelseif SecondAction Is "NotStarts">Not Like '#SecondField#%' 
				<cfelseif SecondAction Is "NotContains">Not Like '%#SecondField#%' 
				<cfelseif SecondAction Is "Not">Not Like '#SecondField#' 
				</cfif>
			</cfif>)
			<cfif FirstParam Is "EMail">
				AND A.AccountID In 
					(SELECT P.AccountID 
					 FROM AccntPlans P, AccountsEMail E 
					 WHERE P.AccntPlanID = E.AccntPlanID)
			<cfelseif FirstParam Is "Auth">
				AND A.AccountID In 
					(SELECT P.AccountID 
					 FROM AccntPlans P, AccountsAuth R 
					 WHERE P.AccntPlanID = R.AccntPlanID)
			<cfelseif FirstParam Is "FTP">
				AND A.AccountID In 
					(SELECT P.AccountID 
					 FROM AccntPlans P, AccountsFTP F 
					 WHERE P.AccntPlanID = F.AccntPlanID)
			</cfif>
			<cfif (FirstParam Is "EMail") OR (FirstParam Is "FTP") OR (FirstParam Is "Auth")>
				<cfif (PlanID Is Not 0) AND (PlanID Is Not "")>
					AND P.PlanID In (#PlanID#)
				<cfelse>
					AND P.PlanID In 
							(SELECT PlanID 
							 FROM PlanAdm 
							 WHERE AdminID = #MyAdminID#) 
				</cfif>
				<cfif (POPID Is Not 0) AND (POPID Is Not "")>
				 	AND P.POPID In (#POPID#)
				<cfelse>
					AND P.POPID In 
							(SELECT POPID 
							 FROM POPAdm 
							 WHERE AdminID = #MyAdminID#) 
				</cfif>
			<cfelse>	
				<cfif (PlanID Is Not 0) AND (PlanID Is Not "")>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE PlanID IN (#PlanID#) 
						)
				<cfelse>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE PlanID In 
						 	(SELECT PlanID 
							 FROM PlanAdm 
							 WHERE AdminID = #MyAdminID#)
						)
				</cfif>
				<cfif (POPID Is Not 0) AND (POPID Is Not "")>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE POPID In (#POPID#) )
				<cfelse>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE POPID IN 
						 	(SELECT POPID 
							 FROM POPAdm 
							 WHERE AdminID = #MyAdminID#)
						)
				</cfif>	
				<cfif (DomainID Is Not 0) AND (DomainID Is Not "")>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE FTPDomainID IN (#DomainID#) 
						 OR AuthDomainID IN (#DomainID#) 
						 OR EMailDomainID IN (#DomainID#) 
						)
				<cfelse>
					AND A.AccountID IN 
						(SELECT AccountID 
						 FROM AccntPlans 
						 WHERE AuthDomainID IN 
						 	(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#)
						 OR FTPDomainID IN 
						 	(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#)
						 OR EMailDomainID IN 
						 	(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#)
						)
				</cfif>			
			</cfif>
			<cfif FirstParam Is "EMail">
				<cfif (DomainID Is Not 0) AND (DomainID Is Not "")>
					AND E.DomainID In (#DomainID#) 
				<cfelse>
					AND E.DomainID In 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
				</cfif>
			<cfelseif FirstParam Is "Auth">
				<cfif (DomainID Is Not 0) AND (DomainID Is Not "")>
					AND R.DomainID In (#DomainID#) 
				<cfelse>
					AND R.DomainID In 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
				</cfif>
			<cfelseif FirstParam Is "FTP">
				<cfif (DomainID Is Not 0) AND (DomainID Is Not "")>
					AND F.DomainID In (#DomainID#) 
				<cfelse>
					AND F.DomainID In 
							(SELECT DomainID 
							 FROM DomAdm 
							 WHERE AdminID = #MyAdminID#) 
				</cfif>
			</cfif>
		</cfquery>
	<cfquery name="GetEMails" datasource="#pds#">
		UPDATE GrpLists SET 
		EMail = E.Email 
		FROM AccountsEMail E, GrpLists G 
		WHERE G.AccountID = E.AccountID 
		AND E.PrEMail = 1 
		AND G.ReportID = 4 
		AND G.AdminID = #MyAdminID# 
		AND G.EMail Is Null 
	</cfquery>
	<cfif FirstParam Is "login">
		<cfset obid = "login">
	<cfelseif FirstParam Is "lastname">
		<cfset obid = "Name">
	<cfelseif FirstParam Is "firstname">
		<cfset obid = "Name">
	<cfelseif FirstParam Is "company">
		<cfset obid = "Company">
	<cfelseif FirstParam Is "address1">
		<cfset obid = "Address">
	<cfelseif FirstParam Is "city">
		<cfset obid = "City">
	<cfelseif FirstParam Is "dayphone">
		<cfset obid = "Phone">
	<cfelseif FirstParam Is "evephone">
		<cfset obid = "PhoneWk">
	<cfelseif FirstParam Is "E.email">
		<cfset obid = "EMail">
	<cfelseif FirstParam Is "accountid">
		<cfset obid = "AccountID">
	<cfelse>
		<cfset obid = "Login">
	</cfif>
</cfif>
<cfparam name="Page" default="1">
<cfparam name="obdir" default="asc">
<cfparam name="obid" default="Name">
<cfquery name="TheResults" datasource="#pds#">
	SELECT * 
	FROM GrpLists 
	WHERE ReportID = 4 
	AND AdminID = #MyAdminID# 
	ORDER BY <cfif obid Is "Name">LastName #obdir#, FirstName #obdir#<cfelse>#obid# #obdir#</cfif> 
</cfquery>
<cfif TheResults.RecordCount Is 1>
	<cfset AccountID = TheResults.AccountID>
	<cflocation url="custinf1.cfm?AccountID=#AccountID#" addtoken="no">
</cfif>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset MaxRows = TheResults.RecordCount>
<cfelse>
	<cfset MaxRows = Mrow>
	<cfset Srow = (Page*Mrow)-(Mrow-1)>
</cfif>
<cfset PageNumber = Ceiling(TheResults.RecordCount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Results</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="lookup1.cfm">
	<input type="image" src="images/changecriteria.gif" name="StartOver" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="7" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
	</tr>
</cfoutput>
	<cfif TheResults.RecordCount GT Mrow>
		<tr>
			<form method="post" action="lookup.cfm">
				<td colspan="7"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfif obid Is "login">
							<cfset dispstr = TheResults.login[ArrayPoint]>
						<cfelseif obid Is "Name">
							<cfset dispstr = TheResults.LastName[ArrayPoint]>
						<cfelseif obid Is "Company">
							<cfset dispstr = TheResults.Company[ArrayPoint]>
						<cfelseif obid Is "Address">
							<cfset dispstr = TheResults.Address[ArrayPoint]>
						<cfelseif obid Is "City">
							<cfset dispstr = TheResults.City[ArrayPoint]>
						<cfelseif obid Is "Phone">
							<cfset dispstr = TheResults.Phone[ArrayPoint]>
						<cfelseif obid Is "PhoneWk">
							<cfset dispstr = TheResults.PhoneWk[ArrayPoint]>
						<cfelseif obid Is "EMail">
							<cfset dispstr = TheResults.EMail[ArrayPoint]>
						<cfelseif obid Is "AccountID">
							<cfset dispstr = TheResults.AccountID[ArrayPoint]>
						</cfif>
						<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #TheResults.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfoutput>
	<cfif TheResults.RecordCount GT 0>
		<tr bgcolor="#thclr#">
			<th>Name</th>
			<th>Company</th>
			<th>Login</th>
			<th>Phone</th>
			<th>Address</th>
			<th>City</th>
			<th>EMail</th>
		</tr>
	<cfelse>
		<tr bgcolor="#tbclr#">
			<td colspan="7">No results were found for your search.<br>
			To change the current search criteria click 'Change Criteria'.</td>
		</tr>
		<tr>
			<form method="post" action="lookup1.cfm">
				<th colspan="7"><input type="image" name="Change" src="images/changecriteria.gif" border="0"></th>
			</form>
		</tr>
	</cfif>
</cfoutput>
<cfoutput query="TheResults" startrow="#Srow#" maxrows="#MaxRows#">
	<tr bgcolor="#tbclr#" valign="top">
		<td nowrap><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_#FirstName##LastName#"</cfif> >#LastName#, #FirstName#</a></td>
		<td><cfif Trim(Company) Is "">&nbsp;<cfelse>#Company#</cfif></td>
		<td><cfif Trim(Login) Is "">&nbsp;<cfelse>#Login#</cfif></td>
		<cfif Trim(Phone) Is Not "">
			<td>#Phone#</td>
		<cfelse>
			<td><cfif Trim(PhoneWk) Is "">&nbsp;<cfelse>#PhoneWk#</cfif></td>
		</cfif>
		<td><cfif Trim(Address) Is "">&nbsp;<cfelse>#Address#</cfif></td>
		<td><cfif Trim(City) Is "">&nbsp;<cfelse>#City#</cfif></td>
		<td><cfif Trim(EMail) Is "">&nbsp;<cfelse><a href="mailto.cfm?email=#EMail#">#EMail#</a></cfif></td>
	</tr>
</cfoutput>
	<cfif TheResults.RecordCount GT Mrow>
		<tr>
			<form method="post" action="lookup.cfm">
				<td colspan="7"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfif obid Is "login">
							<cfset dispstr = TheResults.login[ArrayPoint]>
						<cfelseif obid Is "Name">
							<cfset dispstr = TheResults.LastName[ArrayPoint]>
						<cfelseif obid Is "Company">
							<cfset dispstr = TheResults.Company[ArrayPoint]>
						<cfelseif obid Is "Address">
							<cfset dispstr = TheResults.Address[ArrayPoint]>
						<cfelseif obid Is "City">
							<cfset dispstr = TheResults.City[ArrayPoint]>
						<cfelseif obid Is "Phone">
							<cfset dispstr = TheResults.Phone[ArrayPoint]>
						<cfelseif obid Is "PhoneWk">
							<cfset dispstr = TheResults.PhoneWk[ArrayPoint]>
						<cfelseif obid Is "EMail">
							<cfset dispstr = TheResults.EMail[ArrayPoint]>
						<cfelseif obid Is "AccountID">
							<cfset dispstr = TheResults.AccountID[ArrayPoint]>
						</cfif>
						<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #dispstr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #TheResults.RecordCount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

    