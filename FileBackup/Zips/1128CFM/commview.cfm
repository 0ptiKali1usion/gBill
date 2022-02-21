<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Description. --->
<!--- commview.cfm --->

<cfset securepage="commreport.cfm">
<cfinclude template="security.cfm">

<cfif (IsDefined("DeleteSome.x")) AND (ISDefined("DelIDs"))>
	<cfquery name="DelSome" datasource="#pds#">
		DELETE FROM CommDetail 
		WHERE DetailID In (#DelIDs#)
	</cfquery>
	<cfquery name="GetAmount" datasource="#pds#">
		SELECT sum(AmountPerc) as PercDue, 
		Sum(AmountSet) as SetDue 
		FROM CommDetail 
		WHERE ReportID = #ReportID# 
	</cfquery>
	<cfset TotalDue = GetAmount.PercDue + GetAmount.SetDue>
	<cfquery name="UpdReport" datasource="#pds#">
		UPDATE CommReport SET 
		TotalDue = #TotalDue# 
		WHERE ReportID = #ReportID# 
	</cfquery>	
</cfif>

<cfquery name="GetReportInfo" datasource="#pds#">
	SELECT * 
	FROM CommReport 
	WHERE ReportID = #ReportID# 
</cfquery>
<cfquery name="GetReportDetails" datasource="#pds#">
	SELECT * 
	FROM CommDetail 
	WHERE ReportID = #ReportID# 
</cfquery>
<cfquery name="GetCriteria" datasource="#pds#">
	SELECT * 
	FROM CommCriteria 
	WHERE ReportID = #ReportID# 
	ORDER BY TypeID
</cfquery>

<cfparam name="Page" default="1">

<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset MaxRows = GetReportDetails.RecordCount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow -1)>
	<cfset MaxRows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(GetReportDetails.RecordCount/Mrow)>
<cfset HowWide = 7>
<cfset PagePerc = 0>
<cfset PageSet = 0>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Commission Report</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="commreport.cfm">
	<input type="Image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Commission Report</font></th>
	</tr>
</cfoutput>
	<cfoutput query="GetReportInfo">
		<tr>
			<th colspan="#HowWide#" bgcolor="#thclr#">#ReportTitle# Created: #LSDateFormat(ReportMade, '#DateMask1#')#</th>
		</tr>
		<tr>
			<td colspan="#HowWide#" bgcolor="#tbclr#">#LSDateFormat(StartDate, '#DateMask1#')# to #LSDateFormat(EndDate, '#DateMask1#')#</td>
		</tr>
		<tr>
			<form method="post" action="commsave.cfm">
				<td colspan="#HowWide#" align="right"><input type="Image" src="images/saverep.gif" name="SaveRep" border="0"></td></td>
				<input type="Hidden" name="ReportID" value="#ReportID#">
			</form>
		</tr>
	</cfoutput>
		<cfif GetReportDetails.RecordCount GT Mrow>
			<form method="post" action="commview.cfm">
				<tr>
					<cfoutput><td colspan="#HowWide#"><select name="Page" onchange="submit()"></cfoutput>
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5#</cfoutput>
						</cfloop>
						<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GetReportDetails.RecordCount#</cfoutput>
					</select></td>
					<cfoutput><input type="Hidden" name="ReportID" value="#ReportID#"></cfoutput>
				</tr>
			</form>
		</cfif>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Name</th>
			<th>Date</th>
			<th>Amount</th>
			<th>%</th>
			<th>Set</th>
			<th>Due</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" action="commview.cfm" onsubmit="return confirm('Click Ok to confirm deleting the selected records.')">
		<cfoutput query="GetReportDetails" startrow="#srow#" maxrows="#MaxRows#">
			<tr bgcolor="#tbclr#">
				<td>#LastName# #FirstName#</td>
				<td>#LSDateFormat(TransDate, '#DateMask1#')#</td>
				<td align="right">#LSCurrencyFormat(TransAmount)#</td>
				<td align="right">#LSCurrencyFormat(AmountPerc)#</td>
				<td align="right">#LSCurrencyFormat(AmountSet)#</td>
				<cfset AmountDue = AmountPerc + AmountSet>
				<cfset PagePerc = PagePerc + AmountPerc>
				<cfset PageSet = PageSet + AmountSet>
				<td align="right">#LSCurrencyFormat(AmountDue)#</td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DelIDs" value="#DetailID#"></th>
			</tr>
		</cfoutput>
		<cfoutput>
			<tr>
				<td bgcolor="#thclr#" align="right" colspan="3">Page Total</td>
				<cfset PageTotal = PagePerc + PageSet>
				<td bgcolor="#tdclr#" align="right">#LSCurrencyFormat(PagePerc)#</td>
				<td bgcolor="#tdclr#" align="right">#LSCurrencyFormat(PageSet)#</td>
				<td bgcolor="#tdclr#" align="right">#LSCurrencyFormat(PageTotal)#</td>
				<td bgcolor="#tbclr#">&nbsp;</td>
			</tr>
			<tr>
				<td bgcolor="#thclr#" align="right" colspan="5">Total Due</td>
				<td bgcolor="#tdclr#" align="right">#LSCurrencyFormat(GetReportInfo.TotalDue)#</td>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<input type="Hidden" name="ReportID" value="#ReportID#">
			</tr>
			<cfif GetReportInfo.PaidDate Is Not "">
				<tr>
					<td bgcolor="#thclr#" align="right" colspan="5">Paid</td>
					<td bgcolor="#tdclr#" align="right">#LSDateFormat(GetReportInfo.PaidDate, '#DateMask1#')#</td>
					<td bgcolor="#tbclr#">&nbsp;</td>
				</tr>
			</cfif>
			<tr>
				<th colspan="#HowWide#"><input type="Image" src="images/delete.gif" name="DeleteSome" border="0"></th>
			</tr>
		</cfoutput>
	</form>
	<cfif GetCriteria.RecordCount GT 0>
		<tr>
			<cfoutput>
				<th bgcolor="#thclr#" colspan="#HowWide#">Report Details</th>
			</cfoutput>
		</tr>
		<cfoutput query="GetCriteria" group="TypeID">
			<cfif TypeID Is "1">
				<tr>
					<th bgcolor="#thclr#" colspan="#HowWide#">Plans</th>
				</tr>
			<cfelseif TypeID Is "2">
				<tr>
					<th bgcolor="#thclr#" colspan="#HowWide#">POPs</th>
				</tr>
			<cfelseif TypeID Is "3">
				<tr>
					<th bgcolor="#thclr#" colspan="#HowWide#">Domains</th>
				</tr>
			<cfelseif TypeID Is "4">
				<tr>
					<th bgcolor="#thclr#" colspan="#HowWide#">Salespeople</th>
				</tr>
			</cfif>
			<cfoutput>
				<tr>
					<td bgcolor="#tbclr#" colspan="#HowWide#">#TypeStr#</td>		
				</tr>
			</cfoutput>
		</cfoutput>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
