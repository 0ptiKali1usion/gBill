<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the Credit Card batch history. --->
<!---	4.0.0 09/16/99 --->
<!--- batchhist.cfm  --->

<cfparam name="page" default="1">
<cfquery name="PastBatches" datasource="#pds#">
	SELECT * 
	FROM CCBatchHist 
	WHERE ImportDate Is Not Null 
</cfquery>
<cfif Page Is "0">
	<cfset Srow = 1>
	<cfset Maxrows = PastBatches.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(PastBatches.Recordcount/Mrow)>

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
<title>Batch History</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="batchhist3.cfm">
<input type="image" src="images/search.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Credit Card Batch History</font></th>
	</tr>
</cfoutput>
<cfif PastBatches.Recordcount GT 0>
	<cfif PastBatches.Recordcount GT Mrow>
		<tr>
			<form method="post" action="batchhist.cfm">
				<td colspan="3"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (Page * Mrow) - (Mrow - 1)>
						<cfset DispStr = PastBatches.ImportDate[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>View</th>
			<th>Import Date</th>
			<th>Imported By</th>
		</tr>
	</cfoutput>
	<cfoutput query="PastBatches" startrow="#Srow#" maxrows="#Maxrows#">
		<form method="post" action="batchhist2.cfm">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="BatchID" value="#BatchID#" onclick="submit()"></th>
				<td>#LSDateFormat(ImportDate, '#DateMask1#')#</td>
				<td>#ImportedBy#</td>
			</tr>
		</form>
	</cfoutput>
	<cfif PastBatches.Recordcount GT Mrow>
		<tr>
			<form method="post" action="batchhist.cfm">
				<td colspan="3"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (Page * Mrow) - (Mrow - 1)>
						<cfset DispStr = PastBatches.ImportDate[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfelse>
	<cfoutput>
		<tr bgcolor="#tbclr#">
			<td colspan="3">There is no batch history.</td>
		</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>


