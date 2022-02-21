<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the authentication database setup. --->
<!--- 4.0.0 11/09/99 --->
<!--- customauthsetup2.cfm --->

<cfset securepage="customauthsetup.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SetDefault")>
	<cfquery name="ResetAll" datasource="#pds#">
		UPDATE CustomAuth SET 
		DefaultYN = 0 
	</cfquery>
	<cfquery name="SetOne" datasource="#pds#">
		UPDATE CustomAuth SET 
		DefaultYN = 1 
		WHERE CAuthID = #CAuthID# 
	</cfquery>
</cfif>
<cfif IsDefined("DelSel.x")>
	<cftransaction>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomAuth 
			WHERE CAuthID = #DelID#
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomAuthAccount 
			WHERE CAuthID = #DelID#
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomAuthSetup 
			WHERE CAuthID = #DelID#
		</cfquery>
		<cfquery name="ResetData" datasource="#pds#">
			UPDATE Domains SET 
			CAuthID = 0 
			WHERE CAuthID = #DelID# 
		</cfquery>
	</cftransaction>
</cfif>
<cfif IsDefined("NewAuth.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CAuthID 
		FROM CustomAuth 
	</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
		<cfif AuthType Is 1>
			<cfset NDT = DateAdd("m",-1,Now())>
			<cfset NextDateTime = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),0,0,0)>
		<cfelse>
			<cfset NextDateTime = "">
		</cfif>
		<cftransaction>
			<cfquery name="AddFirstOne" datasource="#pds#">
				INSERT INTO CustomAuth 
				(AuthDescription, ActiveYN, DefaultYN, UniqueBy, AuthType, 
				 LastImport, LastComplete, LastImportSpan, LastCompleteSpan, 
				 LastImportAmount, LastCompleteAmount) 
				VALUES 
				('#AuthDescription#',#ActiveYN#, 1, #UniqueBy#, #AuthType#, 
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif>, 
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif>,
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif>, 
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif>,
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif>, 
				 <cfif NextDateTime Is "">Null<cfelse>#CreateODBCDateTime(NextDateTime)#</cfif> )
			</cfquery>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(CAuthID) as NewID 
				FROM CustomAuth
			</cfquery>
			<cfset CAuthID = GetID.NewID>
		</cftransaction>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomAuthSetup SET 
			CAuthID = #CAuthID# 
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomAuthAccount SET 
			CAuthID = #CAuthID# 
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Domains SET 
			CAuthID = #CAuthID# 
			WHERE DomainID IN (#TheHaveNots#)
		</cfquery>
	<cfelse>
		<cftransaction>
			<cfquery name="AddFirstOne" datasource="#pds#">
				INSERT INTO CustomAuth 
				(AuthDescription, ActiveYN, DefaultYN, UniqueBy, AuthType) 
				VALUES 
				('#AuthDescription#',#ActiveYN#, 0, #UniqueBy#, #AuthType#)
			</cfquery>
			<cfquery name="GetID" datasource="#pds#">
				SELECT Max(CAuthID) as NewID 
				FROM CustomAuth
			</cfquery>
			<cfquery name="GetOldID" datasource="#pds#">
				SELECT CAuthID as OldID 
				FROM CustomAuth 
				WHERE DefaultYN = 1 
			</cfquery>
			<cfset CAuthID = GetID.NewID>
			<cfset CAOldID = GetOldID.OldID>
			<cfquery name="NewData" datasource="#pds#">
				INSERT INTO CustomAuthAccount 
				(DBFieldName, DataNeed, OrderBy, DataType, CAuthID) 
				SELECT DBFieldName, DataNeed, OrderBy, DataType, #CAuthID# 
				FROM CustomAuthAccount 
				WHERE CAuthID = #CAOldID# 
			</cfquery>
			<cfquery name="NewData" datasource="#pds#">
				INSERT INTO CustomAuthSetup 
				(DBType, descrip1, BOBName, DBName, useyn, cfvaryn, sortorder, fortable, 
				 ODBCSType, UseTab, DataType, CAuthID) 
				SELECT DBType, descrip1, BOBName, DBName, useyn, cfvaryn, sortorder, fortable, 
				ODBCSType, UseTab, DataType, #CAuthID# 
				FROM CustomAuthSetup 
				WHERE CAuthID = #CAOldID# 
			</cfquery>
			<cfquery name="UpdNew" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				DBName = Null 
				WHERE CAuthID = #CAuthID#
			</cfquery>
		</cftransaction>
	</cfif>
	<cfset ptab = 5>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="customauthsetup2.cfm">
	<cfabort>
</cfif>
<cfparam name="Tab" default="1">
<cfparam name="Page" default="1">
<cfif Tab Lt 20>
	<cfset HowWide = 5>
<cfelseif Tab Is 22>
	<cfset HowWide = 1>
	<cfquery name="GetDesc" datasource="#pds#">
		SELECT AuthDescription 
		FROM CustomAuth 
		WHERE CAuthID = #CAuthID#
	</cfquery>
<cfelse>
	<cfset HowWide = 2>
</cfif>
<cfquery name="AllAuthSetups" datasource="#pds#">
	SELECT * 
	FROM CustomAuth 
	ORDER BY DefaultYN desc, AuthDescription
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllAuthSetups.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllAuthSetups.Recordcount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Authentication Setup</title>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab gte 20>
	<form method="post" action="customauthsetup.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Custom Authentications</font></th>
	</tr>
</cfoutput>
<cfif Tab Is 20>
	<form method="post" action="customauthsetup.cfm">
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td><input type="text" name="AuthDescription" value="" maxlength="255" size="45"></td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Data Type</td>
				<td bgcolor="#tdclr#"><input type="Radio" name="AuthType" value="0">Text File <input type="Radio" checked name="AuthType" value="1">ODBC Database</td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Usernames are unique</td>
				<td bgcolor="#tdclr#"><input type="Radio" name="UniqueBy" value="1">By Domain<br>
				<input type="Radio" checked name="UniqueBy" value="2">By This Custom Auth Only<br>
				<input type="Radio" name="UniqueBy" value="3">Globally - All Custom Auth</td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="NewAuth" border="0"></th>
			</tr>
			<input type="hidden" name="AuthDescription_Required" value="Please enter a description for this Authentication setup.">
			<input type="hidden" name="ActiveYN" value="1">
			<input type="hidden" name="Tab" value="21">
		</cfoutput>
	</form>
<cfelseif Tab Is 22>
	<form method="post" action="customauthsetup.cfm">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#">You have selected to delete #GetDesc.AuthDescription#<br>
				Click Continue to comfirm deleting the selected setup.</td>
			</tr>
			<tr>
				<th><input type="image" src="images/continue.gif" name="DelSel" border="0"></th>
			</tr>
			<input type="hidden" name="DelID" value="#CAuthID#">
		</cfoutput>
	</form>
<cfelse>
	<tr>
		<cfoutput>
			<form method="post" action="customauthsetup.cfm">
				<th align="right" colspan="#HowWide#"><input type="image" name="addauth" src="images/addnew.gif" border="0"></th>
				<input type="hidden" name="tab" value="20">
			</form>
		</cfoutput>
	</tr>
	<tr>
		<cfoutput>
			<th bgcolor="#thclr#">Edit</th>
			<th bgcolor="#thclr#">Default</th>
			<th bgcolor="#thclr#">Description</th>
			<th bgcolor="#thclr#">Type</th>
			<th bgcolor="#thclr#">Delete</th>
		</cfoutput>
	</tr>
	<cfoutput query="AllAuthSetups" startrow="#Srow#" maxrows="#Maxrows#">
		<tr bgcolor="#tbclr#">
			<form method="post" action="customauthsetup2.cfm">
				<th bgcolor="#tdclr#"><input type="radio" name="CAuthID" value="#CAuthID#" onclick="submit()"></th>
			</form>
			<form method="post" action="customauthsetup.cfm">
				<th bgcolor="#tdclr#"><input type="radio" <cfif DefaultYN Is 1>checked</cfif> name="DefaultYN" value="1" onclick="submit()"></th>
				<input type="hidden" name="CAuthID" value="#CAuthID#">
				<input type="hidden" name="SetDefault" value="1">
			</form>
			<td>#AuthDescription#</td>
			<cfif AuthType Is 0>
				<td>Text</td>
			<cfelse>
				<td>Database</td>
			</cfif>
			<cfif (AllAuthSetups.Recordcount GT 1) AND (DefaultYN Is 0)>
				<form method="post" action="customauthsetup.cfm">
					<th bgcolor="#tdclr#"><input type="radio" value="#CAuthID#" name="CAuthID" onclick="submit()"></th>
					<input type="hidden" name="tab" value="22">
				</form>
			<cfelse>
				<th bgcolor="#tdclr#">&nbsp;</th>
			</cfif>
		</tr>
	</cfoutput>
</cfif>
</table>
<cfinclude template="footer.cfm">
</body>
</html>
 