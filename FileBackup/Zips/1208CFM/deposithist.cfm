<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that makes the deposit. --->
<!---	4.0.0 09/07/99 --->
<!--- deposithist.cfm --->

<cfinclude template="security.cfm">

<cfparam name="Page" default="1">
<cfquery name="GetDeposits" datasource="#pds#">
	SELECT DepositDate, DepositNumID, DepositNumber 
	FROM DepositHist 
	GROUP BY DepositDate, DepositNumID, DepositNumber 
	ORDER BY DepositDate desc
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = GetDeposits.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(GetDeposits.Recordcount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Deposit History</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="depositsearch.cfm">
	<input type="image" src="images/search.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Deposit History</font></th>
	</tr>
</cfoutput>
<cfif GetDeposits.Recordcount GT Mrow>
	<tr>
		<form method="post" action="deposithist.cfm">
			<td colspan="3"><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
					<cfset DispStr = LSDateFormat(GetDeposits.DepositDate[ArrayPoint], '#DateMask1#')>
					<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
			</select></td>
		</form>
	</tr>
</cfif>
<cfoutput query="GetDeposits" startrow="#Srow#" maxrows="#Maxrows#">
	<form method="post" action="deposithist2.cfm">
		<tr bgcolor="#tbclr#">
			<td bgcolor="#tdclr#"><input type="radio" name="DepositNumID" value="#DepositNumID#" onclick="submit()"></td>
			<td>#LSDateFormat(DepositDate, '#DateMask1#')#</td>
			<td>#DepositNumber#</td>
		</tr>
	</form>
</cfoutput>
<cfif GetDeposits.Recordcount GT Mrow>
	<tr>
		<form method="post" action="deposithist.cfm">
			<td colspan="3"><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
					<cfset DispStr = LSDateFormat(GetDeposits.DepositDate[ArrayPoint], '#DateMask1#')>
					<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
			</select></td>
		</form>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>  

