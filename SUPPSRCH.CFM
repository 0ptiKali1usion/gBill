<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that allows searching the support history of all users. --->
<!--- 4.0.0 10/22/99 
		3.2.0 09/08/98 --->
<!--- suppsrch.cfm --->
<cfset LogicConnect = 0>
<cfquery name="SearchResults" datasource="#pds#">
	SELECT * 
	FROM support  
	<cfif (IsDefined("search1")) OR (IsDefined("search2")) OR (IsDefined("search3"))>
		<cfif (Search1 is not "") OR (Search2 is not "") OR (Search3 is not "")>
			WHERE (
			<cfif IsDefined("search1")>
				<cfif Search1 is not "">
					Problem Like '%#search1#%' 
				</cfif>
				<cfset LogicConnect = 1>
			</cfif>
			<cfif IsDefined("search2")>
				<cfif Search2 is not "">
					<cfif LogicConnect Is 1>OR</cfif> Problem Like '%#search2#%' 
				</cfif>
				<cfset LogicConnect = 1>
			</cfif>
			<cfif IsDefined("search3")>
				<cfif Search3 is not "">
					<cfif LogicConnect Is 1>OR</cfif> Problem Like '%#search3#%' 
				</cfif>
				<cfset LogicConnect = 1>
			</cfif>
			)
		</cfif>		
	<cfelseif IsDefined("SupportID")>
		WHERE SupportID = #SupportID# 
	</cfif>
</cfquery>
<cfparam name="Tab" default="1">
<cfset ReturnID = AccountID>
<cfif Tab Is 1>
	<cfset HowWide = 2>
<cfelseif Tab Is 2>
	<cfset HowWide = 1>
</cfif>
<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Search Results</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method=post action="support.cfm">
<input type="image" src="images/return.gif" border="0">
<input type="hidden" name="AccountID" value="#AccountID#">
</form>
<CENTER>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Search Results</font></th>
	</tr>
</cfoutput>
<cfoutput query="SearchResults">
<tr valign=top>
	<td bgcolor="#tbclr#">#problem#</td>
<cfif Tab Is 1>
		<form method=post action="suppsrch.cfm">
			<input type="hidden" name="SupportID" value="#SupportID#">
			<input type="hidden" name="AccountID" value="#ReturnID#">
			<input type="hidden" name="Tab" value="3">
			<td><input type="image" src="images/view.gif" border="0"></td>
		</form>
	</tr>	
<cfelse>
	</tr>
	<tr>
		<td bgcolor="#tbclr#"><font color=red>#solution#</font></td>
	</tr>
</cfif>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
 