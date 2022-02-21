<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is a report of a 30/60/90 recievables report. --->
<!--- 4.0.0 03/05/99 --->
<!-- aging2.cfm -->
<cfparam name="Past30" default="30">
<cfparam name="Past60" default="60">
<cfparam name="Past90" default="90">
<cfif IsDefined("ReturnID")>
	<cfset DispReport = ReturnID>
</cfif>
<cfif IsDefined("AgingReport.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AccountID 
		FROM EMailOutgoing 
		WHERE LetterID = 11 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO EMailOutgoing 
			(AccountID, LastName, FirstName, Company, EMailAddr, BalDue, 
			 EMailDate, AdminID, LetterID, SelectedLetter, CreateDate) 
			SELECT AccountID, LastName, FirstName, Null, EMailAddr, CurBal, 
			#Now()#, #MyAdminID#, 11, #EMailLetterID#, #Now()# 
			FROM AgingTemp 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = #ReturnID# 
			AND EMailAddr Is Not Null
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE EMailOutgoing SET EMailOutgoing.StartDate = 
		A.StartDate 
		FROM Accounts A, EMailOutgoing G 
		WHERE A.AccountID = G.AccountID 
		AND G.LetterID = 11 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="EMailValues" datasource="#pds#">
		SELECT EMailMessage, EMailFrom, EMailSubject, EMailRepeatMsg 
		FROM Integration 
		WHERE IntID = #EMailLetterID# 
	</cfquery>
	<cfset EMailOutgoingMessage = EMailValues.EMailMessage & "
" & EMailValues.EMailRepeatMsg>
	<cfquery name="EMailLetters" datasource="#pds#">
		UPDATE EMailOutgoing SET 
		EMailSubject = '#EMailValues.EMailSubject#', 
		FromAddr = '#EMailValues.EMailFrom#', 
		LetterBody = '#EMailOutgoingMessage#'
		WHERE LetterID = 11 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="emaillist.cfm">
	<cfabort>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 11 
	</cfquery>
</cfif>
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfparam name="Mrow" default="50">
<cfparam name="Page" default="1">
<cfparam name="TotBal" default="0">
<cfparam name="TotCur" default="0">
<cfparam name="TotP30" default="0">
<cfparam name="TotP60" default="0">
<cfparam name="TotP90" default="0">

<cfquery name="GetReport" datasource="#pds#">
	SELECT * FROM AgingTemp 
	WHERE ReportID = #DispReport# 
	ORDER BY <cfif obid Is "Name">LastName #obdir#, FirstName #obdir#<cfelse>#obid# #obdir#</cfif>
</cfquery>
<cfquery name="GetLetters" datasource="#pds#">
	SELECT IntID, IntDesc 
	FROM Integration 
	WHERE ActiveYN = 1 
	AND Action = 'Letter' 
	AND IntID In 
		(SELECT IntID 
		 FROM LetterAdm 
		 WHERE AdminID = #MyAdminID#) 
	<cfif GetOpts.SendEmail Is 0>
		AND IntID = 0 
	</cfif>
</cfquery>
<cfquery name="CheckEMail" datasource="#pds#">
	SELECT AccountID 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = 11 
</cfquery>
<cfif Page GT 0>
	<cfset MaxRows = mrow>
	<cfset Srow = (page * mrow) - (mrow - 1)>
<cfelse>
	<cfset Srow = 1>
	<cfset MaxRows = GetReport.RecordCount>
</cfif>
<cfset PageNumber = Ceiling(GetReport.RecordCount/mrow)>

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
<title>Aging Receivables</TITLE>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="aging.cfm">
	<input type="image" name="return" src="images/return.gif" border="0">
</form>
<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="8" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#LSDateFormat(GetReport.ReportDate, '#datemask1#')# - Aging Report</font></th>
		</tr>
	</cfoutput>
		<cfif getreport.recordcount gt mrow>
			<tr>
				<form method="post" action="aging2.cfm">
					<cfoutput>
						<input type="hidden" name="DispReport" value="#DispReport#">
						<input type="hidden" name="obid" value="#obid#">
						<input type="hidden" name="obdir" value="#obdir#">
					</cfoutput>
					<td colspan=8><select name="Page" onchange="submit()">
						<cfloop index="B5" From="1" To="#PageNumber#">
							<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
							<cfif obid Is "Name">
								<cfset DispStr = GetReport.LastName[ArrayPoint]>
							<cfelseif obid Is "CurBal">
								<cfset DispStr = LSCurrencyFormat(GetReport.CurBal[ArrayPoint])>
							<cfelseif obid Is "CurChr">
								<cfset DispStr = LSCurrencyFormat(GetReport.CurChr[ArrayPoint])>
							<cfelseif obid Is "Display30">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display30[ArrayPoint])>
							<cfelseif obid Is "Display60">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display60[ArrayPoint])>
							<cfelseif obid Is "Display90">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display90[ArrayPoint])>
							<cfelseif obid Is "LastPayDt">
								<cfset DispStr = LSDateFormat(GetReport.LastPayDt[ArrayPoint], '#DateMask1#')>
							<cfelseif obid Is "LastPayAm">
								<cfset DispStr = LSCurrencyFormat(GetReport.LastPayAm[ArrayPoint])>
							</cfif>
							<cfoutput>
								<option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#
							</cfoutput>
						</cfloop>
						<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #GetReport.Recordcount#</cfoutput>
					</select></td>
				</form>
			</tr>
		</cfif>		
		<cfoutput>
		<tr bgcolor="#tdclr#" valign="top">
		</cfoutput>
		<cfif CheckEMail.Recordcount Is 0>
			<form method="post" action="aging2.cfm">
				<cfoutput>
					<input type="hidden" name="SendHeader" value="">
					<input type="hidden" name="SendFields" value="">
					<input type="hidden" name="LetterID" value="11">
					<input type="hidden" name="ReportID" value="11">
					<input type="hidden" name="ReturnPage" value="aging2.cfm">
					<input type="hidden" name="ReturnTo" value="aging2.cfm">
					<input type="hidden" name="obid2" value="">
					<input type="hidden" name="obdir2" value="">
					<input type="hidden" name="page2" value="">					
					<input type="hidden" name="ReturnID" value="#DispReport#">
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
					<input type="hidden" name="page" value="#page#">
				</cfoutput>
				<td colspan="6"><select name="EMailLetterID">
					<cfoutput query="GetLetters">
						<option value="#IntID#">#IntDesc#
					</cfoutput>
				</select><input type="image" name="AgingReport" src="images/viewlist.gif" border="0"></td>
			</form>
		<cfelse>
			<th colspan="6">
				<table border="0">
					<tr>
						<form method="post" action="emaillist.cfm">
							<cfoutput>
								<input type="hidden" name="SendHeader" value="">
								<input type="hidden" name="SendFields" value="">
								<input type="hidden" name="LetterID" value="11">
								<input type="hidden" name="ReportID" value="11">
								<input type="hidden" name="ReturnPage" value="aging2.cfm">
								<input type="hidden" name="ReturnTo" value="aging2.cfm">
								<input type="hidden" name="obid2" value="">
								<input type="hidden" name="obdir2" value="">
								<input type="hidden" name="page2" value="">					
								<input type="hidden" name="ReturnID" value="#DispReport#">
								<input type="hidden" name="obid" value="#obid#">
								<input type="hidden" name="obdir" value="#obdir#">
								<input type="hidden" name="page" value="#page#">
							</cfoutput>
							<td><input type="image" name="CurAgingReport" src="images/viewlist.gif" border="0"></td>
						</form>
						<form action="aging2.cfm" method="post">			
							<cfoutput>
								<input type="hidden" name="DispReport" value="#DispReport#">
								<input type="hidden" name="obid" value="#obid#">
								<input type="hidden" name="obdir" value="#obdir#">
								<input type="hidden" name="Page" value="#Page#">
							</cfoutput>
							<td><input type="image" name="StartOver" src="images/changecriteria.gif" border="0"></td>
						</form>
					</tr>
				</table>
			</th>
		</cfif>
	<cfoutput>
			<th valign="bottom" bgcolor="#thclr#" colspan=2>Last Payment</th>
		</tr>
		<tr bgcolor="#thclr#">
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "Name") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" onclick="submit()" id="col1"><label for="col1">Name</label></th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "CurBal") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="Page" value="#Page#">
				<input type="hidden" name="DispReportID" value="#DispReport#">
				<th><input type="radio" <cfif obid Is "CurBal">checked</cfif> name="obid" value="CurBal" onclick="submit()" id="col2"><label for="col2">Balance</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "CurChr") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "CurChr">checked</cfif> name="obid" value="CurChr" onclick="submit()" id="col3"><label for="col3">Current</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "Display30") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "Display30">checked</cfif> name="obid" value="Display30" onclick="submit()" id="col4"><label for="col4">Over #Past30#</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "Display60") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "Display60">checked</cfif> name="obid" value="Display60" onclick="submit()" id="col5"><label for="col5">Over #Past60#</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "Display90") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "Display90">checked</cfif> name="obid" value="Display90" onclick="submit()" id="col6"><label for="col6">Over #Past90#</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "LastPayDt") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "LastPayDt">checked</cfif> name="obid" value="LastPayDt" onclick="submit()" id="col7"><label for="col7">Date</th>
			</form>
			<form method="post" action="aging2.cfm">
				<cfif (obid Is "LastPayAm") AND (obdir Is "Asc")>
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<input type="hidden" name="DispReport" value="#DispReport#">
				<input type="hidden" name="Page" value="#Page#">
				<th><input type="radio" <cfif obid Is "LastPayAm">checked</cfif> name="obid" value="LastPayAm" onclick="submit()" id="col8"><label for="col8">Amount</th>
			</form>
		</tr>
	</cfoutput>
	<cfoutput query="getreport" startrow="#srow#" maxrows="#maxrows#">
		<tr bgcolor="#tbclr#" valign="top">
			<td><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#lastname#, #firstname#</a></td>
			<td align="right">#LSCurrencyFormat(CurBal)#</td>
			<cfset TotBal = TotBal + CurBal>
			<td align="right">#LSCurrencyFormat(DisplayCur)#</td>
			<cfset TotCur = TotCur + DisplayCur>
			<td align="right">#LSCurrencyFormat(Display30)#</td>
			<cfset TotP30 = TotP30 + Display30>
			<td align="right">#LSCurrencyFormat(Display60)#</td>
			<cfset TotP60 = TotP60 + Display60>
			<td align="right">#LSCurrencyFormat(display90)#</td>
			<cfset TotP90 = TotP90 + display90>
			<td><cfif LastPayDt is "">None<cfelse>#LSDateFormat(LastPayDt, '#datemask1#')#</cfif></td>
			<td align="right">#LSCurrencyFormat(LastPayAm)#</td>
		</tr>
	</cfoutput>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<td>Page Total</td>
			<td align="right">#LSCurrencyFormat(TotBal)#</td>
			<td align="right">#LSCurrencyFormat(TotCur)#</td>
			<td align="right">#LSCurrencyFormat(TotP30)#</td>
			<td align="right">#LSCurrencyFormat(TotP60)#</td>
			<td align="right">#LSCurrencyFormat(TotP90)#</td>
			<td>&nbsp;</td>			
			<td>&nbsp;</td>
		</tr>
	</cfoutput>
		<cfif getreport.recordcount gt mrow>
			<tr>
				<form method="post" action="aging2.cfm">
					<cfoutput>
						<input type="hidden" name="DispReport" value="#DispReport#">
						<input type="hidden" name="obid" value="#obid#">
						<input type="hidden" name="obdir" value="#obdir#">
					</cfoutput>
					<td colspan=8><select name="Page" onchange="submit()">
						<cfloop index="B5" From="1" To="#PageNumber#">
							<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
							<cfif obid Is "Name">
								<cfset DispStr = GetReport.LastName[ArrayPoint]>
							<cfelseif obid Is "CurBal">
								<cfset DispStr = LSCurrencyFormat(GetReport.CurBal[ArrayPoint])>
							<cfelseif obid Is "CurChr">
								<cfset DispStr = LSCurrencyFormat(GetReport.CurChr[ArrayPoint])>
							<cfelseif obid Is "Display30">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display30[ArrayPoint])>
							<cfelseif obid Is "Display60">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display60[ArrayPoint])>
							<cfelseif obid Is "Display90">
								<cfset DispStr = LSCurrencyFormat(GetReport.Display90[ArrayPoint])>
							<cfelseif obid Is "LastPayDt">
								<cfset DispStr = LSDateFormat(GetReport.LastPayDt[ArrayPoint], '#DateMask1#')>
							<cfelseif obid Is "LastPayAm">
								<cfset DispStr = LSCurrencyFormat(GetReport.LastPayAm[ArrayPoint])>
							</cfif>							
							<cfoutput>
								<option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#
							</cfoutput>
						</cfloop>
						<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #GetReport.Recordcount#</cfoutput>
					</select></td>
				</form>
			</tr>
		</cfif>		
	</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
       