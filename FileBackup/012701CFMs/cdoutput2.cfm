<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page outputs the check debit file. --->
<!---	4.0.0 04/27/00 
		3.4.0 06/16/99 Added code to get the maximum width of a row.
		3.2.1 10/22/98 Changed the query checkdebitersbal to work with SQL.
		3.2.0 09/08/98 --->
<!-- cdoutput2.cfm -->

<cfquery name="CDValues" datasource="#pds#">
	SELECT * 
	FROM CustomCDOutput 
	WHERE UseTab = 6 
</cfquery>
<cfloop query="CDValues">
	<cfset "#FieldName1#" = Description1>
</cfloop>

<cfparam name="thecdfile" default="cdebit.txt">
<cfparam name="cdoutpath" default="c:\">
<cfparam name="setcdrecwidth" default="100">
<cfparam name="cddateformat" default="YYYYMMDD">
<cfparam name="cdtimeformat" default="hhmm">
<cfparam name="cdminbaldue" default="0.01">
<cfparam NAME="cdUseP" DEFAULT="1">

<cfset strow = url.srow>
<cfset stprow = strow + mrow>

<cfquery name="checkdebiters" datasource="#pds#">
	SELECT AP.AccountID, P.BankName as CheckD1, P.BankAddress as CheckD2, 
	P.RouteNumber as CheckD3, P.AccntNumber as CheckD4, P.NameOnAccnt as CheckD5, 
	P.CheckDigit, A.FirstName, A.LastName, Sum([Debit]-[Credit]) AS Total, 
	Convert(decimal(8,2),(Sum(debit-credit))) as bal 
	FROM Accounts A, AccntPlans AP, PayByCD P, Transactions T 
	WHERE A.AccountID = AP.AccountID 
	AND AP.AccntPlanID = P.AccntPlanID 
	AND AP.AccntPlanID = T.AccntPlanID 
	AND AP.PayBy = 'CD' 
	GROUP BY AP.AccountID, P.BankName, P.BankAddress, P.RouteNumber, P.AccntNumber, 
	P.NameOnAccnt, P.CheckDigit, A.FirstName, A.LastName 
	HAVING Sum(Debit-Credit) > #CDMinBalDue# 
</cfquery>

<cfset howmany=checkdebiters.recordcount>

<cfif strow lte checkdebiters.recordcount>
   <cfif stprow gt checkdebiters.recordcount>
	   <cfset stprow = checkdebiters.recordcount>
   </cfif>

<cfquery name="thefields" datasource="#pds#">
	SELECT * 
	FROM CustomCDOutput 
	WHERE usetab = 3  
	AND useyn = 1 
	ORDER BY startorder
</cfquery>
<cfquery name="maxvalue" datasource="#pds#">
	SELECT max(endorder) as setwidth 
	FROM CustomCDOutput 
	WHERE usetab = 3  
	AND useyn = 1 
</cfquery>
<cfset setcdrecwidth = maxvalue.setwidth>

<cfloop query="thefields">
	<cfset "thestring#startorder#" = fieldname1>
	<cfset "cfvar#startorder#" = cfvaryn>
	<cfset "start#startorder#" = startorder>
	<cfset "end#startorder#" = endorder>
	<cfset "pjustify#startorder#" = pjustify>
	<cfset "padchar#startorder#" = padchar>
</cfloop>

<cfset myoutput = "">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','VarName')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfloop query="checkdebiters" startrow="#strow#" endrow="#stprow#">

<cfloop index="B5" from="1" to="#setcdrecwidth#">
	<cfif IsDefined("thestring#B5#")>
		<cfset theoutput = Evaluate("thestring#B5#")>
		<cfset thejustify = Evaluate("pjustify#B5#")>
		<cfset thepadchar = Evaluate("padchar#B5#")>
		   <cfif theoutput contains "date">
		      <cfset pos1 = Evaluate("start#B5#")>
		      <cfset pos2 = Evaluate("end#B5#")>
		      <cfset len1 = pos2 - pos1 + 1>
		      <cfset thestring = #LSDateFormat(Now(), '#cddateformat#')#>
			<cfelseif theoutput contains "day">
				<cfset thestring = DayOfYear(Now())>
			<cfelseif theoutput contains "bal">
				<cfset pos1 = Evaluate("start#B5#")>
		      <cfset pos2 = Evaluate("end#B5#")>
		      <cfset len1 = pos2 - pos1 + 1>
		      <cfset cfvar = Evaluate("cfvar#B5#")>
		      <cfif cfvar is 1>
		         <cfset thestring = Evaluate("#theoutput#")>
		      <cfelse>
		         <cfset thestring = theoutput>
		      </cfif>
				<cfif cdUseP is 0>
					<cfset thestring = Evaluate("#theoutput#") * 100>
				</cfif>
				<cfif cdUseDS is 1>
					<cfset moneysign = LSCurrencyFormat(0)>
					<cfset moneysign = Left(moneysign,1)>
					<cfset thestring = moneysign & thestring>
				</cfif>
			<cfelseif theoutput contains "seqnumber">
		      <cfset pos1 = Evaluate("start#B5#")>
		      <cfset pos2 = Evaluate("end#B5#")>
		      <cfset len1 = pos2 - pos1 + 1>
		      <cfset thestring = strow - 1 + currentrow>
		   <cfelse>
				<cfset pos1 = Evaluate("start#B5#")>
		      <cfset pos2 = Evaluate("end#B5#")>
		      <cfset len1 = pos2 - pos1 + 1>
		      <cfset cfvar = Evaluate("cfvar#B5#")>
		      <cfif cfvar is 1>
		         <cfset thestring = Evaluate("#theoutput#")>
		      <cfelse>
		         <cfset thestring = theoutput>
		      </cfif>
		   </cfif>
			<cfset thestring = Left("#thestring#",#len1#)>
			<cfif thejustify is "N">
				<cfset thejustify = "R">
			</cfif>
			<cf_gspadchar pvalue="#thestring#" padchar="#thepadchar#"
			 justify="#thejustify#" pwidth="#len1#">
			<cfset myoutput = myoutput & newvalue>
	</cfif>
</cfloop>

<cffile action="append" file="#cdoutpath##TheCDFile#" 
output = "#myoutput#">
<cfset myoutput = "">

</cfloop>

</cfif>

<cfset srow = srow + mrow + 1>


<cfif url.srow lt checkdebiters.recordcount>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Check Debit Customers</TITLE>
<cfinclude template="coolsheet.cfm">
<cfoutput>
<META HTTP-Equiv=Refresh content="1; URL=cdoutput2.cfm?srow=#srow#&howmany=#howmany#">
</head>
<body #colorset#>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Processing</font></th>
	</tr>
	<tr>
		<td bgcolor="#tbclr#">Processing the file #cdoutpath##thecdfile#.<br>
		Please stand by.</td>
	</tr>
</table>
</cfoutput>
</body>
</html>

<cfelse>

	<cfquery name="checkdebitersbal" datasource="#pds#">
		SELECT Sum([Debit]-[Credit]) AS Total, 
		Convert(decimal(8,2),(Sum(debit-credit))) as bal, 
		AP.PayBy as PayType 
		FROM AccntPlans AP, Transactions T 
		WHERE AP.AccntPlanID = T.AccntPlanID 
		AND AP.PayBy = 'CD' 
		AND AP.AccountID IN 
			(SELECT AP.AccountID 
			 FROM AccntPlans AP, Transactions T 
			 WHERE AP.AccntPlanID = T.AccntPlanID 
			 AND AP.PayBy = 'CD' 
			 GROUP BY AP.AccountID 
			 HAVING Sum(Debit-Credit) > #CDMinBalDue# 
			)
		GROUP BY AP.PayBy 
	</cfquery>
	<cfset myoutput = "">
	
	<cfloop index="B5" from="4" to="5">
		<cfquery name="thefields" datasource="#pds#">
			SELECT * 
			FROM CustomCDOutput 
			WHERE usetab = #B5# 
			AND useyn = 1 
			ORDER BY startorder
		</cfquery>
		<cfloop query="thefields">
			<cfset len1 = endorder - startorder + 1>
			<cfset thestring = "#fieldname1#">
		   <cfif thestring contains "countall">
			   <cfset thestring = checkdebiters.recordcount>
		   <cfelseif thestring contains "countdebits">
			   <cfset thestring = checkdebiters.recordcount>
		   <cfelseif thestring contains "sumall">
			   <cfset thestring = checkdebitersbal.bal>
				<cfif cdUseP is 0>
					<cfset thestring = Evaluate("#thestring#") * 100>
				</cfif>
				<cfif cdUseDS is 1>
					<cfset moneysign = LSCurrencyFormat(0)>
					<cfset moneysign = Left(moneysign,1)>
					<cfset thestring = moneysign & thestring>
				</cfif>
		   <cfelseif thestring contains "sumdebits">
			   <cfset thestring = checkdebitersbal.bal>
				<cfif cdUseP is 0>
					<cfset thestring = Evaluate("#thestring#") * 100>
				</cfif>
				<cfif cdUseDS is 1>
					<cfset moneysign = LSCurrencyFormat(0)>
					<cfset moneysign = Left(moneysign,1)>
					<cfset thestring = moneysign & thestring>
				</cfif>
			<cfelseif thestring contains "BlockTotal">
				<cfset thestring = Ceiling((howmany+4)/10)>
			<cfelseif thestring contains "acntadd">
					<cfquery name="GetRouteTotal" datasource="#pds#">
						SELECT P.AccountID, P.RouteNumber as c1 
						FROM PayByCD P, Transactions T 
						WHERE P.AccountID = T.AccountID 
						GROUP BY P.AccountID, P.RouteNumber 
						HAVING Sum(debit-credit) > #cdminbaldue# 
					</cfquery>
				<cfset thertotal = 0>
				<cfoutput query="GetRouteTotal">
					<cfif Trim(c1) is not "">
						<cfif IsNumeric(c1)>
							<cfset thertotal = thertotal + c1>
						</cfif>
					</cfif>
				</cfoutput>
				<cfset thestring = Int(thertotal)>
				<cfif len(thestring) gt 10>
					<cfset thestring = Right(thestring,10)>
				</cfif>
		   </cfif>
			<cfset thestring = Left("#thestring#","#len1#")>
			<cfif pjustify is "N">
				<cfset thejustify = "R">
			<cfelseif pjustify is "">
				<cfset thejustify = "R">
			<cfelse>
				<cfset thejustify = pjustify>
			</cfif>
			<cf_gspadchar pvalue="#thestring#" padchar="#padchar#"
			justify="#thejustify#" pwidth="#len1#">
			<cfset myoutput = myoutput & newvalue>
		</cfloop>
			<cfif (B5 is 4) AND (thefields.recordcount gt 0)>
			<cfset myoutput = myoutput & "
">
		</cfif>
	</cfloop>
	
	<cffile action="APPEND" file="#cdoutpath##TheCDFile#" output="#myoutput#">

	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'******Need Type ******',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# output #TheCDFile# for check debit customers.')
		</cfquery>
	</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Processing Complete</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Done processing</font></th>
			</tr>
			<tr>
				<td bgcolor="#tbclr#">You may now use the file<BR>
					<b>#cdoutpath##thecdfile#</b><BR>
					to process your check debit customers.</td>
			</tr>
		</table>
	</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>

</cfif>
 