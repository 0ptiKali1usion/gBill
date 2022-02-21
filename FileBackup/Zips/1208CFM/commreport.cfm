<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Report List. --->
<!--- commreport.cfm --->

<cfinclude template="security.cfm">

<cfif IsDefined("SaveMe.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CommReport SET 
		ReportTitle = '#ReportTitle#', 
		ReportMemo = <cfif Trim(ReportMemo) Is "">Null<cfelse>'#ReportMemo#'</cfif>, 
		<cfif IsDate(PaidDate)>
			PaidDate = #ParseDateTime(PaidDate)#, 
		</cfif>
		KeepYN = 1 
		WHERE ReportID = #ReportID#  
	</cfquery>
</cfif>

<cfquery name="AllReports" datasource="#pds#">
	SELECT * 
	FROM CommReport 
	WHERE KeepYN = 1 
	ORDER BY StartDate 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Commission Report List</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="5" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Commission Reports List</font></th>
	</tr>
	<tr>
		<form method="post" action="commission.cfm">
			<td align="right" colspan="5"><input type="Image" src="images/addnew.gif" border="0" name="NewReport"></td>
		</form>
	</tr>
	<tr bgcolor="#thclr#">
		<th>View</th>
		<th>Report Start</th>
		<th>Title</th>
		<th>Date Paid</th>
		<th>Created By</th>
	</tr>
</cfoutput>
	<cfif AllReports.RecordCount GT 0>
		<form method="post" action="commview.cfm">
			<cfoutput query="AllReports">
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#"><input type="Radio" name="ReportID" value="#ReportID#" onclick="submit()"></th>
					<td>#LSDateFormat(StartDate, '#DateMask1#')#</td>
					<td>#ReportTitle#</td>
					<cfif PaidDate Is "">
						<td>&nbsp;</td>
					<cfelse>
						<td>#LSDateFormat(PaidDate, '#DateMask1#')#</td>
					</cfif>
					<td>#CreatedBy#</td>
				</tr>
			</cfoutput>
		</form>
	<cfelse>
		<tr>
			<cfoutput>
				<td bgcolor="#tbclr#" colspan="5">No reports available</td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 