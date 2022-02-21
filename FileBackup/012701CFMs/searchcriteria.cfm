<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 12/10/00 --->
<!--- searchcriteria.cfm --->

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
<cfquery name="GetSalesP" datasource="#pds#">
	SELECT C.FirstName, C.LastName, A.AdminID 
	FROM Accounts C, Admin A 
	WHERE C.AccountID = A.AccountID 
	AND A.AdminID IN 
		(SELECT SalesID 
		 FROM SalesAdm 
		 WHERE AdminID = #MyAdminID#)
	ORDER BY C.LastName, C.FirstName 
</cfquery>
<cfparam name="TheDomainID" default="0">
<cfparam name="ThePlanID" default="0">
<cfparam name="ThePOPID" default="0">
<cfparam name="SalesPID" default="0">

<cfsetting enablecfoutputonly="No">
<cfoutput>
<tr bgcolor="#tdclr#" valign="top">
	<td align="right" bgcolor="#tbclr#">Plans</td>
</cfoutput>
	<td><select name="PlanID" multiple size="6">
		<option <cfif ThePlanID Is "0">selected</cfif> value="0">All Plans
		<cfoutput query="GetPlans">
			<option <cfif ListFind(ThePlanID,PlanID) GT 0>selected</cfif> value="#PlanID#">#PlanDesc#
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
<cfoutput>
<tr valign="top" bgcolor="#tdclr#">
	<td align="right" bgcolor="#tbclr#">Salesperson</td>
</cfoutput>
	<td><select name="SalesPID" multiple size="6">
		<option <cfif SalesPID Is 0>selected</cfif> value="0">All Salespersons
		<cfoutput query="GetSalesP">
			<option <cfif ListFind(SalesPID,AdminID) GT 0>selected</cfif> value="#AdminID#">#LastName#, #FirstName#
		</cfoutput>
		<option value="">______________________________
	</select></td>
<cfoutput>
	<td align="right" bgcolor="#tbclr#">Domains</td>
</cfoutput>
	<td><select name="DomainID" multiple size="6">
		<option <cfif TheDomainID Is "0">selected</cfif> value="0">All Domains
		<cfoutput query="GetDomains">
			<option <cfif ListFind(TheDomainID,DomainID) GT 0>selected</cfif> value="#DomainID#">#DomainName#
		</cfoutput>
		<option value="">______________________________
	</select></td>
</tr>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  