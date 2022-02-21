<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the Credit Card batch history. --->
<!---	4.0.0 09/16/99 --->
<!--- batchhist2.cfm  --->

<cfquery name="OneBatch" datasource="#pds#">
	SELECT * 
	FROM CCBatchHist 
	WHERE BatchID = #BatchID# 
</cfquery>
<cfquery name="BatchDetail" datasource="#pds#">
	SELECT * 
	FROM CCBatchDetail 
	WHERE BatchID = #BatchID# 
	ORDER BY LastName, FirstName 
</cfquery>
<cfparam name="page" default="1">
<cfif Page Is 0>
	<cfset srow = 1>
	<cfset maxrows = BatchDetail.Recordcount>
<cfelse>
	<cfset srow = Page*mrow - (mrow-1)>
	<cfset maxrows = mrow>
</cfif>
<cfset PageNumber = Ceiling(BatchDetail.Recordcount/mrow)>
<cfparam name="tab" default="1">
<cfif tab Is 1>
	<cfset HowWide = 7>
<cfelse>
	<cfset HowWide = 1>
</cfif>

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
<cfoutput>
<cfinclude template="coolsheet.cfm"> 
<title>Output of file - #OneBatch.OutputFileAs#</title>
</head>
<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="batchhist.cfm">
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">File: #OneBatch.OutputFileAs#</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="batchhist2.cfm">
						<input type="Hidden" name="BatchID" value="#BatchID#">
						<th bgcolor=<cfif tab is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="Radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" id="tab1" onclick="submit()"><label for="tab1">Output Info</label></th>
					</form>
					<form method="post" action="batchhist2.cfm">
						<input type="Hidden" name="BatchID" value="#BatchID#">
						<th bgcolor=<cfif tab is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="Radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" id="tab2" onclick="submit()"><label for="tab2">Actual Output</label></th>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
	<cfif tab Is "1">
		<cfoutput>
			<cfif BatchDetail.RecordCount GT Mrow>
				<tr bgcolor="#thclr#">
					<form method="post" action="batchhist2.cfm">
						<td colspan="#HowWide#"><select name="Page" onchange="submit()">
							<cfloop index="B5" from="1" to="#PageNumber#">
								<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
								<cfset DispStr = BatchDetail.LastName[ArrayPoint]>
								<option <cfif B5 Is page>selected</cfif> value="#B5#">Page #B5# - #DispStr#
							</cfloop>
						</select></td>
						<input type="Hidden" name="tab" value="#tab#">
						<input type="Hidden" name="BatchID" value="#BatchID#">
					</form>
				</tr>
			</cfif>
			<tr bgcolor="#thclr#">
				<th>Name</th>
				<th>Address</th>
				<th>Zip</th>
				<th colspan="2">Amount</th>
				<th>Response</th>
				<th>Code</th>
			</tr>
		</cfoutput>
		<cfoutput query="BatchDetail" startrow="#srow#" maxrows="#maxrows#">
			<tr bgcolor="#tbclr#">
				<td>#LastName#, #FirstName#</td>
				<td>#AVSAddress#<cfif AVSAddress Is "">&nbsp;</cfif></td>
				<td>#AVSZip#<cfif AVSZip Is "">&nbsp;</cfif></td>
				<cfif BatchAmount GT 0>
					<td>Charge</td>
					<td align="right">#LSCurrencyFormat(BatchAmount)#</td>
				<cfelse>
					<td>Refund</td>
					<td align="right">#LSCurrencyFormat(BatchRefund)#</td>
				</cfif>
				<td>#CCResponse#<cfif CCResponse Is "">&nbsp;</cfif></td>
				<td>#AuthCode#<cfif AuthCode Is "">&nbsp;</cfif></td>
			</tr>
		</cfoutput>
		<cfif BatchDetail.RecordCount GT Mrow>
			<cfoutput>
				<tr bgcolor="#thclr#">
					<form method="post" action="batchhist2.cfm">
						<td colspan="#HowWide#"><select name="Page" onchange="submit()">
							<cfloop index="B5" from="1" to="#PageNumber#">
								<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
								<cfset DispStr = BatchDetail.LastName[ArrayPoint]>
								<option <cfif B5 Is page>selected</cfif> value="#B5#">Page #B5# - #DispStr#
							</cfloop>
						</select></td>
						<input type="Hidden" name="tab" value="#tab#">
						<input type="Hidden" name="BatchID" value="#BatchID#">
					</form>
				</tr>
			</cfoutput>
		</cfif>
	<cfelse>
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#">File: #OneBatch.OutputFileAs#<br>
					Export Date: #LSDateFormat(OneBatch.ExportDate, '#DateMask1#')#<br>
					Exported By: #OneBatch.ExportedBy#<br>
					Import Date: #LSDateFormat(OneBatch.ImportDate, '#DateMask1#')#<br>
					Imported By: #OneBatch.ImportedBy#</td>
			</tr>
			<tr bgcolor="#tbclr#">
		</cfoutput>
				<td><pre><cfoutput query="BatchDetail">#BatchOutput#
</cfoutput></pre></td>
			</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  