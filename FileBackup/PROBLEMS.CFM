<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 12/12/00 --->
<!--- problems.cfm --->

<cfinclude template="security.cfm">

<cfquery name="EMailCheck" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID In 
		(SELECT AccountID 
		 FROM AccountsEMail 
		 GROUP BY AccountID 
		 HAVING Sum(PrEmail) > 1 )
</cfquery>
<cfquery name="EMailCheck2" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID NOT In 
		(SELECT AccountID 
		 FROM AccountsEMail 
		 WHERE PrEMail = 1) 
	AND AccountID In 
		(SELECT AccountID 
		 FROM AccountsEMail)
</cfquery>
<cfquery name="NoSales" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE SalesPersonID NOT In 
		(SELECT AdminID 
		 FROM Admin) 
</cfquery>
<cfquery name="InvalidPlans" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID In 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE PlanID NOT In 
		 	(SELECT PlanID 
			 FROM Plans)
		)
</cfquery>
<cfquery name="InvalidPOPs" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID In 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE POPID NOT In 
		 	(SELECT POPID 
			 FROM POPs)
		)
</cfquery>
<cfquery name="InvalidDoms" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID In 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE AuthDomainID NOT In 
		 	(SELECT DomainID 
			 FROM Domains)
		 OR FTPDomainID NOT In 
		 	(SELECT DomainID 
			 FROM Domains) 
		 OR EMailDomainID NOT In 
		 	(SELECT DomainID 
			 FROM Domains)
		)
</cfquery>
<cfquery name="MissingStartDates" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE StartDate Is Null
</cfquery>
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>gBill Problems</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Problems</font></th>
	</tr>
</cfoutput>
	<cfif EMailCheck.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="EMailCheck">
			<tr bgcolor="#tbclr#">
				<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
				<td>Has more than one primary EMail address.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif EMailCheck2.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="EMailCheck2">
			<tr bgcolor="#tbclr#">
				<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
				<td>Has no primary EMail address.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif NoSales.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="NoSales">
			<tr bgcolor="#tbclr#">
				<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
				<td>Has no selected staff member.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif MissingStartDates.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="MissingStartDates">
			<tr bgcolor="#tbclr#">
				<td><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
				<td>Has no start date.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif InvalidPlans.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="InvalidPlans">
			<tr bgcolor="#tbclr#">
				<td>#LastName#, #FirstName#</a></td>
				<td>Is on a plan that is no longer in the database.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif InvalidPOPs.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="InvalidPOPs">
			<tr bgcolor="#tbclr#">
				<td>#LastName#, #FirstName#</td>
				<td>Is in a POP that is no longer in the database.</td>
			</tr>
		</cfoutput>
	</cfif>
	<cfif InvalidDoms.RecordCount GT 0>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Problem</th>
			</tr>
		</cfoutput>
		<cfoutput query="InvalidDoms">
			<tr bgcolor="#tbclr#">
				<td>#LastName#, #FirstName#</td>
				<td>Is in a domain that is no longer in the database.</td>
			</tr>
		</cfoutput>
	</cfif>
</table>
</center>
</body>
</html>
 
