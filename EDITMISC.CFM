<cfsetting enablecfoutputonly="no">
<!--- Version 4.0.0 --->
<!--- This page edits the customers misc information. --->
<!---	4.0.0 01/23/01 --->
<!--- editmisc.cfm --->

<cfif GetOpts.EditMisc Is 1>
	<cfset SecurePage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfif IsDefined("EditMisc.x")>
	<cfquery name="FieldNames" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE ActiveYN = 1 
		AND BOBFieldName <> 'WaiveA' 
		AND BOBFieldName <> 'WaiveAReason' 
		AND BOBFieldName <> 'SelectPlan' 
		AND BOBFieldName <> 'UserInfo' 
		AND BOBFieldName <> 'contactemail' 
		AND BOBFieldName <> 'postalinv' 
		AND BOBFieldName <> 'taxfree' 
		AND BOBFieldName <> 'creditcard' 
		AND BOBFieldName <> 'checkdebit' 
		AND BOBFieldName <> 'porder' 
		AND BOBFieldName <> 'checkcash' 
		AND PageNumber IN (3,4,5) 
	</cfquery>
	<cfquery name="updinfo" datasource="#pds#">
		UPDATE Accounts SET 
		<cfloop query="FieldNames"><cfset TheStr = Evaluate("#BOBFieldName#")>
			#BOBFieldName# = 
			<cfif Trim(TheStr) Is "">NULL
			<cfelse>
				<cfif DataType Is "Text">'#TheStr#'<cfelse>#TheStr#</cfif>
			</cfif>
			<cfif CurrentRow Is Not RecordCount>,</cfif>
		</cfloop>
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
	AND BOBFieldName <> 'WaiveA' 
	AND BOBFieldName <> 'WaiveAReason' 
	AND BOBFieldName <> 'SelectPlan' 
	AND BOBFieldName <> 'UserInfo' 
	AND BOBFieldName <> 'contactemail' 
	AND BOBFieldName <> 'postalinv' 
	AND BOBFieldName <> 'taxfree' 
	AND BOBFieldName <> 'creditcard' 
	AND BOBFieldName <> 'checkdebit' 
	AND BOBFieldName <> 'porder' 
	AND BOBFieldName <> 'checkcash' 
	AND PageNumber IN (3,4,5) 
	GROUP BY PageNumber, RowOrder 
	ORDER BY PageNumber, RowOrder 
</cfquery>
<cfquery name="MaxSort" datasource="#pds#">
	SELECT max(SortOrder) as HowWide 
	FROM WizardSetup 
	WHERE ActiveYN = 1 
	AND BOBFieldName <> 'WaiveA' 
	AND BOBFieldName <> 'WaiveAReason' 
	AND BOBFieldName <> 'SelectPlan' 
	AND BOBFieldName <> 'UserInfo'
	AND BOBFieldName <> 'contactemail'
	AND BOBFieldName <> 'postalinv' 
	AND BOBFieldName <> 'taxfree' 
	AND BOBFieldName <> 'creditcard' 
	AND BOBFieldName <> 'checkdebit' 
	AND BOBFieldName <> 'porder' 
	AND BOBFieldName <> 'checkcash' 
	AND PageNumber IN (3,4,5) 
</cfquery>
<cfset HowWide = MaxSort.HowWide * 2>
<cfset HideRow = 0>

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
<title>Edit Customer Misc Information</TITLE>
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
<form method="post" action="editmisc.cfm">
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" colspan="#HowWide#"><b>* Required</b></td>
	</tr>
</cfoutput>
<cfinclude template="wizardfields.cfm">
<cfoutput>
	<tr>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<th colspan="#HowWide#"><INPUT name="EditMisc" type="image" src="images/update.gif" border="0"></th>
	</tr>
</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 