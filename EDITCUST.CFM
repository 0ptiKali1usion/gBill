<cfsetting enablecfoutputonly="no">
<!--- Version 4.0.0 --->
<!--- This page edits the customers personal information. --->
<!---	4.0.0 09/25/99
		3.2.2 10/08/98 Hide date fields based on users permissions.
		3.2.1 09/16/98 Modified to work with Custom OS options.
		3.2.0 09/08/98 --->
<!--- editcust.cfm --->
<cfif GetOpts.EditInfo Is 1>
	<cfset SecurePage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfif IsDefined("EditCust.x")>
	<cfif IsDefined("StartDate")>
		<cfset sdate = LSParseDateTime(startdate)>
	</cfif>
	<cfquery name="FieldNames" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE ActiveYN = 1 
		AND BOBFieldName <> 'POPID' 
		AND BOBFieldName <> 'PromoCode' 
		AND BOBFieldName <> 'SalespersonID' 
		AND (PageNumber = 1 OR PageNumber = 2) 
	</cfquery>
	<cfquery name="updinfo" datasource="#pds#">
		UPDATE accounts SET 
		<cfloop query="FieldNames"><cfset TheStr = Evaluate("#BOBFieldName#")>
			#BOBFieldName# = 
			<cfif Trim(TheStr) Is "">NULL
			<cfelse>
				<cfif DataType Is "Text">'#TheStr#'<cfelse>#TheStr#</cfif>
			</cfif>,
		</cfloop>
		<cfif IsDefined("SalesPersonID")>
			SalesPersonID = #SalesPersonID#, 
		</cfif>
		StartDate = #SDate# 
		WHERE AccountID = #AccountID# 
	</cfquery>
</cfif>
<cfquery name="SignUpInfo" datasource="#PDS#">
SELECT * 
FROM Accounts 
WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="WhichPage" datasource="#pds#">
	SELECT RowOrder, PageNumber 
	FROM WizardSetup 
	WHERE ActiveYN = 1 
	AND BOBFieldName <> 'POPID' 
	AND BOBFieldName <> 'PromoCode' 
	AND BOBFieldName <> 'SalespersonID' 
	AND (PageNumber = 1 OR PageNumber = 2) 
	GROUP BY PageNumber, RowOrder 
	ORDER BY PageNumber, RowOrder 
</cfquery>
<cfquery name="MaxSort" datasource="#pds#">
	SELECT max(SortOrder) as HowWide 
	FROM WizardSetup 
	WHERE ActiveYN = 1 
	AND BOBFieldName <> 'POPID' 
	AND BOBFieldName <> 'PromoCode' 
	AND BOBFieldName <> 'SalespersonID' 
	AND (PageNumber = 1  OR PageNumber = 2)
</cfquery>
<cfset HowWide = MaxSort.HowWide * 2>
<cfset HideRow = 0>
<cfquery name="AllSales" datasource="#pds#">
	SELECT A.FirstName, A.LastName, S.AdminID 
	FROM Accounts A, Admin S 
	WHERE A.AccountID = S.AccountID 
	AND S.SalesPersonYN = 1 
	AND S.AdminID In 
		(SELECT SalesID 
		 FROM SalesAdm 
		 WHERE AdminID = #MyAdminID#) 
	ORDER BY A.LastName, A.FirstName 
</cfquery>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Edit Customer Information</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="custinf1.cfm">
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="image" src="images/return.gif" border="0">
	</form>
<center>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#SignUpInfo.FirstName# #SignUpInfo.LastName#</font></th>
	</tr>
</cfoutput>
<form method="post" action="editcust.cfm">
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" colspan="#HowWide#"><b>* Required</b></td>
	</tr>
	<tr valign="top">
		<td bgcolor="#tbclr#" align=right>Start Date</td>
		<cfset ThisRow = HowWide - 1>
		<td colspan="#ThisRow#" bgcolor="#tdclr#"><input type="text" name="StartDate" value="#LSDateFormat(SignUpInfo.StartDate, '#datemask1#')#"> <font size="1">(#datemask1#)</font></td>
	</tr>
</cfoutput>
<cfinclude template="wizardfields.cfm">
<cfif GetOpts.EditName Is "1">
	<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align="right">Salesperson</td>
	</cfoutput>
		<td colspan="5"><select name="SalesPersonID">
			<cfloop query="AllSales">
				<cfoutput><option <cfif SignUpInfo.SalesPersonID Is AdminID>selected</cfif> value="#AdminID#">#LastName#, #FirstName#</cfoutput>
			</cfloop>
		</select></td>
	</tr>
</cfif>
<cfoutput>
	<tr>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<th colspan="#HowWide#"><INPUT name="EditCust" type="image" src="images/update.gif" border="0"></th>
	</tr>
</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 