<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 3 of the mass emailer. --->
<!--- 4.0.0 09/08/98 --->
<!--- email2.cfm --->

<cfif IsDefined("continue.x")>
	<cfset SendLetterID = 6>
	<cfquery name="GetLetterInfo" datasource="#pds#">
		SELECT FromAddr, SelectedLetter, LetterBody, EMailSubject 
		FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6
	</cfquery>
	<cfquery name="GetEMail" datasource="#pds#">
		SELECT EMail 
		FROM AccountsEMail 
		WHERE PREmail = 1 
		AND AccountID = (SELECT AccountID 
						  FROM Admin 
						  WHERE AdminID = #MyAdminID#)
	</cfquery>
	<cfif Mid(GetLetterInfo.FromAddr,1,7) Is "billing">
		<cfset WhoFrom = "billing">
		<cfset Len1 = Len(GetLetterInfo.FromAddr) - 8>
		<cfset BDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset CDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset SDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset WhoFrom2 = "">
	<cfelseif Mid(GetLetterInfo.FromAddr,1,7) Is "service">
		<cfset WhoFrom = "service">
		<cfset Len1 = Len(GetLetterInfo.FromAddr) - 8>
		<cfset BDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset CDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset SDomainName = Mid(GetLetterInfo.FromAddr,8,Len1)>
		<cfset WhoFrom2 = "">
	<cfelseif GetLetterInfo.FromAddr Is "#GetEMail.EMail#">
		<cfset WhoFrom = "#GetEMail.EMail#">
		<cfset Pos1 = Find("@", GetLetterInfo.FromAddr)>
		<cfset Pos2 = Pos1 + 1>
		<cfset Len1 = Len(GetLetterInfo.FromAddr) - (Pos1)>
		<cfset BDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset CDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset SDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset WhoFrom2 = "">
	<cfelse>
		<cfset WhoFrom = "custom">
		<cfset Pos1 = Find("@", GetLetterInfo.FromAddr)>
		<cfset Pos2 = Pos1 + 1>
		<cfset Pos3 = Pos1 - 1>
		<cfset Len1 = Len(GetLetterInfo.FromAddr) - (Pos1)>
		<cfset BDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset CDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset SDomainName = Mid(GetLetterInfo.FromAddr,Pos2,Len1)>
		<cfset WhoFrom2 = Mid(GetLetterInfo.FromAddr,1,Pos3)>
	</cfif> 
	<cfset Message = GetLetterInfo.LetterBody>
	<cfset Subject = GetLetterInfo.EMailSubject>
	<cfset LetterID = GetLetterInfo.SelectedLetter>
	<cfset BegDay = "01">	
	<cfset EndDay = "31">
	<cfset MinAmnt = "NA">
	<cfset MinCredit = "NA">
	<cfset Credit = "0">
	<cfset CheckD = "0">
	<cfset Postal = "0">
	<cfset GroupSubs = "0">
	<cfset DomainID = "0">
	<cfset PlanID = "0">
	<cfset POPID = "0">
	<cfset SalesPID = "0">
</cfif>
<cfif IsDefined("deleteem.x")>
	<cfset SendLetterID = 6>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6 
		AND AccountID In (#DelEMail#)
	</cfquery>
</cfif>
<cfparam name="ReturnID" default="0">
<cfparam name="ReturnPage" default="">
<cfsetting enablecfoutputonly="no">
<cfif IsDefined("LetterID")>
	<cfif (LetterID Is 0) AND (Trim(message) Is "")>
		<html>
		<head>
		<title>Please enter your message</title>
		</head>	
		<cfoutput><body #colorset#></cfoutput>
		<cfinclude template="header.cfm">
		<center>
		<form method="post" action="email1.cfm">
		<cfoutput>
			<table border="#tblwidth#">
				<tr>
					<td bgcolor="#tbclr#">You selected the option to type a letter but did not enter a message.  
					Please return to the email form and enter your message.</td>
				</tr>
				<tr>
					<th><input type="image" src="images/return.gif" name="return" border="0"></th>
				</tr>
			</table>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
		</cfoutput>
		</form>
		</center>
		<cfinclude template="footer.cfm">
		</body>	
		</html>		
		<cfabort>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="yes">
<!--- Select the emails into EMailOutgoing --->
<cfif (IsDefined("SendExisting.x")) OR (IsDefined("ListExists.x"))>
	<cfset SendLetterID = 6>
	<cfif WhoFrom Is "billing">
		<cfset TheFromAddr = "billing@#BDomainName#">
	<cfelseif WhoFrom Is "custom">
		<cfset whofrom2 = Trim(Replace(whofrom2," ","","All"))>
		<cfset TheFromAddr = "#whofrom2#@#CDomainName#">
	<cfelseif WhoFrom Is "service">
		<cfset TheFromAddr = "service@#SDomainName#">
	<cfelse>
		<cfset TheFromAddr = "#WhoFrom#">
	</cfif>
	<cfif LetterID Is Not 0>
		<cfquery name="EMailValues" datasource="#pds#">
			SELECT EMailMessage, EMailFrom, EMailSubject, EMailRepeatMsg 
			FROM Integration 
			WHERE IntID = #LetterID# 
		</cfquery>
		<cfset WhoFrom = "custom">
		<cfset EMailAddress = EMailValues.EMailFrom>
		<cfif Trim(EMailAddress) Is "">
			<cfset EMailAddress = "service@#SDomainName#">
		</cfif>
		<cfset Pos1 = Find("@", EMailAddress)>
		<cfset Pos2 = Pos1 + 1>
		<cfset Pos3 = Pos1 - 1>
		<cfset Len1 = Len(EMailAddress) - (Pos1)>
		<cfset BDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset CDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset SDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset WhoFrom2 = Mid(EMailAddress,1,Pos3)>
		<cfset TheFromAddr = EMailAddress>
		<cfset Message = EMailValues.EMailMessage & "
" & EMailValues.EMailRepeatMsg>
		<cfset Subject = EMailValues.EMailSubject>
	</cfif>
	<cfquery name="UpdData"	datasource="#pds#">
		UPDATE EMailOutgoing SET 
		FromAddr = '#TheFromAddr#', 
		SelectedLetter = #LetterID#, 
		LetterBody = '#Message#', 
		EMailSubject = '#Subject#' 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6 
	</cfquery>
</cfif>
<cfif (IsDefined("EditFirst.x")) OR (IsDefined("SendNow.x"))>
	<cfset SendLetterID = 6>
	<cfif WhoFrom Is "billing">
		<cfset TheFromAddr = "billing@#BDomainName#">
	<cfelseif WhoFrom Is "custom">
		<cfset whofrom2 = Trim(Replace(whofrom2," ","","All"))>
		<cfset TheFromAddr = "#whofrom2#@#CDomainName#">
	<cfelseif WhoFrom Is "service">
		<cfset TheFromAddr = "service@#SDomainName#">
	<cfelse>
		<cfset TheFromAddr = "#WhoFrom#">
	</cfif>
	<cfquery name="GetEmails" datasource="#pds#">
		INSERT INTO EMailOutgoing 
		(AccountID, LetterID, LastName, FirstName, StartDate, Company,
		EMailAddr, EMailDate, LetterBody, AdminID, FromAddr, SelectedLetter, BalDue, CreateDate)
		SELECT A.AccountID, 6, A.LastName, A.FirstName, A.StartDate, A.Company, 
		E.EMail, #Now()#, Null, #MyAdminID#, '#TheFromAddr#', #LetterID#, 
		Sum(Debit - Credit), #Now()# 
		FROM Accounts A, AccntPlans P, AccountsEMail E, Transactions T  
		WHERE A.AccountID = P.AccountID 
		AND P.AccntPlanID = E.AccntPlanID 
		AND T.AccountID = A.AccountID 
		AND E.PrEMail = 1 
		<cfif PlanID Is "0">
			AND P.PlanID In 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #MyAdminID#)
		<cfelse>
			AND P.PlanID In (#PlanID#) 
		</cfif>
		<cfif DomainID Is "0">
			AND E.DomainID In 
				(SELECT DomainID 
				 FROM DomAdm 
				 WHERE AdminID = #MyAdminID#)
		<cfelse>
			AND E.DomainID In (#DomainID#) 
		</cfif>
		<cfif POPID Is "0">
			AND P.POPID In 
				(SELECT POPID 
				 FROM POPAdm 
				 WHERE AdminID = #MyAdminID#)
		<cfelse>
			AND P.POPID In (#POPID#) 
		</cfif>
		<cfif SalesPID Is "0">
			<cfif GetOpts.WhatView Is 0>
				AND A.SalesPersonID = #MyAdminID#
			</cfif>
		<cfelse>
			AND A.SalesPersonID In (#SalesPID#) 
		</cfif>
		AND (P.PayBy = 'ck' 
		<cfif Credit Is "1">
			OR P.PayBy = 'cc'
		</cfif>
		<cfif CheckD Is "1">
			OR P.PayBy = 'cd' 
		</cfif>
		)
		<cfif Postal Is "1">
			AND P.PostalRem = 0
		</cfif>
		<cfif BODBCType is "sql">
			AND DatePart(dd,P.NextDueDate) <= #endday# 
			And DatePart(dd,P.NextDueDate) >= #begday# 
		<cfelseif BODBCType is "access">
			AND DatePart('d',P.NextDueDate) <= #endday# 
			AND DatePart('d',P.NextDueDate) >= #begday# 
		</cfif>
		GROUP BY A.AccountID, A.LastName, A.FirstName, A.StartDate, A.Company, 
		E.EMail 
	</cfquery>
	<cfif MinAmnt Is Not "NA">
		<cfquery name="RemoveWrongBals" datasource="#pds#">
			DELETE FROM EMailOutgoing 
			WHERE BalDue < #MinAmnt# 
			<cfif MinCredit Is Not "NA">
				AND BalDue >= 0 
			</cfif>
			AND AdminID = #MyAdminID# 
			AND LetterID = 6 
		</cfquery>
	</cfif>
	<cfif MinCredit Is Not "NA">
		<cfquery name="RemoveWrongCredits" datasource="#pds#">
			DELETE FROM EMailOutgoing 
			WHERE BalDue <= 0 
			<cfif MinAmnt Is Not "NA">
				AND BalDue > -#MinCredit# 
			</cfif>
			AND AdminID = #MyAdminID# 
			AND LetterID = 6 
		</cfquery>
	</cfif>
	<cfquery name="EMailValues" datasource="#pds#">
		SELECT EMailMessage, EMailFrom, EMailSubject, EMailRepeatMsg 
		FROM Integration 
		WHERE IntID = #LetterID# 
	</cfquery>
	<cfif LetterID Is Not 0>
		<cfset WhoFrom = "custom">
		<cfset EMailAddress = EMailValues.EMailFrom>
		<cfif Trim(EMailAddress) Is "">
			<cfset EMailAddress = "service@#SDomainName#">
		</cfif>
		<cfset Pos1 = Find("@", EMailAddress)>
		<cfset Pos2 = Pos1 + 1>
		<cfset Pos3 = Pos1 - 1>
		<cfset Len1 = Len(EMailAddress) - (Pos1)>
		<cfset BDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset CDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset SDomainName = Mid(EMailAddress,Pos2,Len1)>
		<cfset WhoFrom2 = Mid(EMailAddress,1,Pos3)>
		<cfset TheFromAddr = EMailAddress>
		<cfset Message = EMailValues.EMailMessage & "
" & EMailValues.EMailRepeatMsg>
		<cfset Subject = EMailValues.EMailSubject>
	</cfif>
	<cfquery name="UpdSubject" datasource="#pds#">
		UPDATE EMailOutGoing SET 
		EMailSubject = '#Subject#', 
		<cfif EMailValues.Recordcount Is Not 0>
			FromAddr = '#TheFromAddr#', 
		</cfif>
		LetterBody = '#Message#' 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6 
	</cfquery>
	<cfif IsDefined("GroupSubs")>
		<cfquery name="Remove Subs" datasource="#pds#">
			SELECT * FROM EMailOutgoing 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Multi 
				 WHERE BillTo = 0)
		</cfquery>
	</cfif>
	<cfif IsDefined("SendNow.x")>
		<cflocation addtoken="no" url="email3.cfm">
	</cfif>
</cfif>

<!--- Select from EMailOutgoing --->
<cfquery name="GetDomainName" datasource="#pds#">
	SELECT * 
	FROM Domains 
	WHERE primary1 = 1 
</cfquery>
<cfparam name="Message" default="">
<cfparam name="Subject" default="">
<cfparam name="LetterID" default="0">
<cfparam name="BDomainName" default="#GetDomainName.DomainName#">
<cfparam name="CDomainName" default="#GetDomainName.DomainName#">
<cfparam name="SDomainName" default="#GetDomainName.DomainName#">
<cfparam name="BegDay" default="01">
<cfparam name="EndDay" default="31">
<cfparam name="MinAmnt" default="NA">
<cfparam name="MinCredit" default="NA">
<cfparam name="Credit" default="0">
<cfparam name="CheckD" default="0">
<cfparam name="Postal" default="0">
<cfparam name="GroupSubs" default="0">
<cfparam name="DomainID" default="0">
<cfparam name="PlanID" default="0">
<cfparam name="POPID" default="0">
<cfparam name="SalesPID" default="0">
<cfparam name="WhoFrom" default="">
<cfparam name="WhoFrom2" default="">
<cfparam name="ordby" default="Name">
<cfparam name="orddir" default="asc">
<cfquery name="EMailList" datasource="#pds#">
	SELECT *
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = #SendLetterID# 
	ORDER BY 
	<cfif ordby is "Name">
		Lastname #orddir#, FirstName #orddir#
	<cfelse>
		#ordby# #orddir#
	</cfif>	
</cfquery>

<cfsetting enablecfoutputonly="no">
<cfif EMailList.RecordCount is 0>
	<html>
	<head>
	<title>No E-Mail To Send</TITLE>
	<cfinclude template="coolsheet.cfm">
	</head>
	<cfoutput><body #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<cfif SendLetterID Is Not 6>
		<cfoutput>
			<form method="post" action="#ReturnPage#">
				<input type="hidden" name="ReturnID" value="#ReturnID#">
				<input type="image" src="images/return.gif" border="0">
			</form>
		</cfoutput>
	<cfelseif SendLetterID Is 6>
		<form method="post" action="email.cfm">
			<input type="image" src="images/changecriteria.gif" border="0">
				<cfoutput>
					<input type="hidden" name="WhoFrom" value="#WhoFrom#">
					<input type="hidden" name="Message" value="#Message#">
					<input type="hidden" name="Subject" value="#Subject#">
					<input type="hidden" name="BDomainName" value="#BDomainName#">
					<input type="hidden" name="CDomainName" value="#CDomainName#">
					<input type="hidden" name="SDomainName" value="#SDomainName#">
					<input type="hidden" name="whofrom2" value="#whofrom2#">
					<input type="hidden" name="LetterID" value="#LetterID#">
					<input type="hidden" name="SendLetterID" value="#SendLetterID#">
					<input type="hidden" name="BegDay" value="#BegDay#">
					<input type="hidden" name="EndDay" value="#EndDay#">
					<input type="hidden" name="MinAmnt" value="#MinAmnt#">
					<input type="hidden" name="MinCredit" value="#MinCredit#">
					<input type="hidden" name="ReturnID" value="#ReturnID#">
					<input type="hidden" name="ReturnPage" value="#ReturnPage#">
					<cfif IsDefined("Credit")>
						<input type="hidden" name="Credit" value="#Credit#">
					<cfelse>
						<input type="hidden" name="Credit" value="0">
					</cfif>
					<cfif IsDefined("CheckD")>
						<input type="hidden" name="CheckD" value="#CheckD#">
					<cfelse>
						<input type="hidden" name="CheckD" value="0">
					</cfif>
					<cfif IsDefined("Postal")>
						<input type="hidden" name="Postal" value="#Postal#">
					<cfelse>
						<input type="hidden" name="Postal" value="0">
					</cfif>
					<cfif IsDefined("GroupSubs")>
						<input type="hidden" name="GroupSubs" value="#GroupSubs#">
					<cfelse>
						<input type="hidden" name="GroupSubs" value="0">
					</cfif>
					<input type="hidden" name="DomainID" value="#DomainID#">
					<input type="hidden" name="PlanID" value="#PlanID#">
					<input type="hidden" name="POPID" value="#POPID#">
					<input type="hidden" name="SalesPID" value="#SalesPID#">
				</cfoutput>
		</form>
	</cfif>
	<center>
		<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">There were no matches for the selected customer criteria.</td>
			</tr>
		</table>
		</cfoutput>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
	<cfabort>
</cfif>
<cfsetting enablecfoutputonly="yes">
<cfparam name="Page" default="1">
<cfparam name="mrow" default="25">	
<cfif Page GT 0>
	<cfset MaxRows = mrow>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
<cfelse>
	<cfset Srow = 1>
	<cfset MaxRows = EMailList.RecordCount>
</cfif>
<cfset NumPages = Ceiling(EMailList.RecordCount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>E-Mail List</title>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif SendLetterID Is Not 6>
	<cfoutput>
		<form method="post" action="#ReturnPage#">
				<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="image" src="images/return.gif" border="0">
		</form>
	</cfoutput>
<cfelseif SendLetterID Is 6>
	<form method="post" action="email1.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
	<input type="hidden" name="WhoFrom" value="#WhoFrom#">
	<input type="hidden" name="Message" value="#Message#">
	<input type="hidden" name="Subject" value="#Subject#">
	<input type="hidden" name="BDomainName" value="#BDomainName#">
	<input type="hidden" name="CDomainName" value="#CDomainName#">
	<input type="hidden" name="SDomainName" value="#SDomainName#">
	<input type="hidden" name="whofrom2" value="#whofrom2#">
	<input type="hidden" name="LetterID" value="#LetterID#">
	<input type="hidden" name="SendLetterID" value="#SendLetterID#">
	<input type="hidden" name="BegDay" value="#BegDay#">
	<input type="hidden" name="EndDay" value="#EndDay#">
	<input type="hidden" name="MinAmnt" value="#MinAmnt#">
	<input type="hidden" name="MinCredit" value="#MinCredit#">
	<input type="hidden" name="ReturnID" value="#ReturnID#">
	<input type="hidden" name="ReturnPage" value="#ReturnPage#">
	<cfif IsDefined("Credit")>
		<input type="hidden" name="Credit" value="#Credit#">
	<cfelse>
		<input type="hidden" name="Credit" value="0">
	</cfif>
	<cfif IsDefined("CheckD")>
		<input type="hidden" name="CheckD" value="#CheckD#">
	<cfelse>
		<input type="hidden" name="CheckD" value="0">
	</cfif>
	<cfif IsDefined("Postal")>
		<input type="hidden" name="Postal" value="#Postal#">
	<cfelse>
		<input type="hidden" name="Postal" value="0">
	</cfif>
	<cfif IsDefined("GroupSubs")>
		<input type="hidden" name="GroupSubs" value="#GroupSubs#">
	<cfelse>
		<input type="hidden" name="GroupSubs" value="0">
	</cfif>
	<input type="hidden" name="DomainID" value="#DomainID#">
	<input type="hidden" name="PlanID" value="#PlanID#">
	<input type="hidden" name="POPID" value="#POPID#">
	<input type="hidden" name="SalesPID" value="#SalesPID#">
	</cfoutput>
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="5" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">E-Mail List</font></th>
	</tr>
</cfoutput>
<cfif EMailList.Recordcount GT mrow>
	<form method="post" action="email2.cfm">
		<cfoutput>
			<input type="hidden" name="ordby" value="#ordby#">
			<input type="hidden" name="orddir" value="#orddir#">
			<tr bgcolor="#tdclr#">
		</cfoutput>
			<td colspan="5"><select name="Page" onChange="submit()">
				<cfloop index="B5" from="1" to="#NumPages#">
					<cfset ArrayPoint = B5 * Mrow - (Mrow - 1)>
					<cfif ordby is "Name">
						<cfset disp = EMailList.LastName[ArrayPoint]>
					<cfelseif ordby is "EMailAddr">
						<cfset disp = EMailList.EMailAddr[ArrayPoint]>
					<cfelseif ordby Is "Baldue">
						<cfset disp = EMailList.BalDue[ArrayPoint]>
						<cfset disp = LSCurrencyFormat(disp)>
					<cfelseif ordby is "startdate">
						<cfset disp = LSDateFormat(EMailList.StartDate[ArrayPoint], '#DateMask1#')>
					</cfif>
					<cfoutput><option <cfif Page Is B5>Selected</cfif> value="#B5#">Page #B5# - #disp#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>Selected</cfif> value="0">View All - #EMailList.Recordcount#</cfoutput>
			</select></td>
		</tr>
		<cfoutput>
		<input type="hidden" name="WhoFrom" value="#WhoFrom#">
		<input type="hidden" name="Message" value="#Message#">
		<input type="hidden" name="Subject" value="#Subject#">
		<input type="hidden" name="BDomainName" value="#BDomainName#">
		<input type="hidden" name="CDomainName" value="#CDomainName#">
		<input type="hidden" name="SDomainName" value="#SDomainName#">
		<input type="hidden" name="whofrom2" value="#whofrom2#">
		<input type="hidden" name="LetterID" value="#LetterID#">
		<input type="hidden" name="SendLetterID" value="#SendLetterID#">
		<input type="hidden" name="BegDay" value="#BegDay#">
		<input type="hidden" name="EndDay" value="#EndDay#">
		<input type="hidden" name="MinAmnt" value="#MinAmnt#">
		<input type="hidden" name="MinCredit" value="#MinCredit#">
		<input type="hidden" name="ReturnID" value="#ReturnID#">
		<input type="hidden" name="ReturnPage" value="#ReturnPage#">
		<cfif IsDefined("Credit")>
			<input type="hidden" name="Credit" value="#Credit#">
		<cfelse>
			<input type="hidden" name="Credit" value="0">
		</cfif>
		<cfif IsDefined("CheckD")>
			<input type="hidden" name="CheckD" value="#CheckD#">
		<cfelse>
			<input type="hidden" name="CheckD" value="0">
		</cfif>
		<cfif IsDefined("Postal")>
			<input type="hidden" name="Postal" value="#Postal#">
		<cfelse>
			<input type="hidden" name="Postal" value="0">
		</cfif>
		<cfif IsDefined("GroupSubs")>
			<input type="hidden" name="GroupSubs" value="#GroupSubs#">
		<cfelse>
			<input type="hidden" name="GroupSubs" value="0">
		</cfif>
		<input type="hidden" name="DomainID" value="#DomainID#">
		<input type="hidden" name="PlanID" value="#PlanID#">
		<input type="hidden" name="POPID" value="#POPID#">
		<input type="hidden" name="SalesPID" value="#SalesPID#">
		</cfoutput>
	</form>
</cfif>
<cfoutput>
	<tr bgcolor="#thclr#">
		<td>&nbsp;</td>
		<form method=post action="email2.cfm" name="info">
			<input type="hidden" name="Page" value="#Page#">
			<cfif Ordby Is "Name" AND Orddir Is "Asc">
				<input type="hidden" name="Orddir" value="Desc">
			<cfelse>
				<input type="hidden" name="Orddir" value="Asc">
			</cfif>
			<td><input type="radio" <cfif ordby Is "Name">checked</cfif> name="ordby" value="Name" onclick="submit()" id="col1"><label for="col1">Name</label></td>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendLetterID" value="#SendLetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
		</form>
		<form method=post action="email2.cfm" name="info">
			<input type="hidden" name="Page" value="#Page#">
			<cfif Ordby Is "EMailAddr" AND Orddir Is "Asc">
				<input type="hidden" name="Orddir" value="Desc">
			<cfelse>
				<input type="hidden" name="Orddir" value="Asc">
			</cfif>
			<td><input type="radio" <cfif ordby Is "EMailAddr">checked</cfif> name="ordby" value="EMailAddr" onclick="submit()" id="col2"><label for="col2">E-Mail</label></td>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendLetterID" value="#SendLetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
		</form>
		<form method=post action="email2.cfm" name="info">
			<input type="hidden" name="Page" value="#Page#">
			<cfif Ordby Is "BalDue" AND Orddir Is "Asc">
				<input type="hidden" name="Orddir" value="Desc">
			<cfelse>
				<input type="hidden" name="Orddir" value="Asc">
			</cfif>
			<td><input type="radio" <cfif ordby Is "BalDue">checked</cfif> name="ordby" value="BalDue" onclick="submit()" id="col3"><label for="col3">Balance</label></td>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendLetterID" value="#SendLetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
		</form>
		<form method=post action="email2.cfm" name="info">
			<input type="hidden" name="Page" value="#Page#">
			<cfif Ordby Is "StartDate" AND Orddir Is "Asc">
				<input type="hidden" name="Orddir" value="Desc">
			<cfelse>
				<input type="hidden" name="Orddir" value="Asc">
			</cfif>
			<td><input type="radio" <cfif ordby Is "StartDate">checked</cfif> name="ordby" value="StartDate" onclick="submit()" id="col4"><label for="col4">Start Date</label></td>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendLetterID" value="#SendLetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
		</form>
	</tr>
	</cfoutput>
	<form method="post" action="email2.cfm" onsubmit="return confirm ('Click Ok to confirm removing the selected customers from this EMail list.')">
	<cfoutput query="EMailList" startrow="#Srow#" maxrows="#MaxRows#">
		<tr bgcolor="#tbclr#">
			<td bgcolor="#tdclr#"><input type="checkbox" name="DelEMail" value="#AccountID#"</td>
			<td><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#Lastname#, #FirstName#</a></td>
			<td>#EMailAddr#</td>
			<td align="right"><cfif BalDue LT 0>Credit: </cfif>#LSCurrencyFormat(ABS(BalDue))#</td>
			<td>#LSDateFormat(StartDate, '#datemask1#')#</td>
		</tr>
	</cfoutput>
	<cfoutput>
			<input type="hidden" name="WhoFrom" value="#WhoFrom#">
			<input type="hidden" name="Message" value="#Message#">
			<input type="hidden" name="Subject" value="#Subject#">
			<input type="hidden" name="BDomainName" value="#BDomainName#">
			<input type="hidden" name="CDomainName" value="#CDomainName#">
			<input type="hidden" name="SDomainName" value="#SDomainName#">
			<input type="hidden" name="whofrom2" value="#whofrom2#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendLetterID" value="#SendLetterID#">
			<input type="hidden" name="BegDay" value="#BegDay#">
			<input type="hidden" name="EndDay" value="#EndDay#">
			<input type="hidden" name="MinAmnt" value="#MinAmnt#">
			<input type="hidden" name="MinCredit" value="#MinCredit#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<cfif IsDefined("Credit")>
				<input type="hidden" name="Credit" value="#Credit#">
			<cfelse>
				<input type="hidden" name="Credit" value="0">
			</cfif>
			<cfif IsDefined("CheckD")>
				<input type="hidden" name="CheckD" value="#CheckD#">
			<cfelse>
				<input type="hidden" name="CheckD" value="0">
			</cfif>
			<cfif IsDefined("Postal")>
				<input type="hidden" name="Postal" value="#Postal#">
			<cfelse>
				<input type="hidden" name="Postal" value="0">
			</cfif>
			<cfif IsDefined("GroupSubs")>
				<input type="hidden" name="GroupSubs" value="#GroupSubs#">
			<cfelse>
				<input type="hidden" name="GroupSubs" value="0">
			</cfif>
			<input type="hidden" name="DomainID" value="#DomainID#">
			<input type="hidden" name="PlanID" value="#PlanID#">
			<input type="hidden" name="POPID" value="#POPID#">
			<input type="hidden" name="SalesPID" value="#SalesPID#">
	</cfoutput>
	<tr>
		<th colspan="5">
			<table border="0" width="100%">
				<tr>
					<th><input name="deleteem" type="image" src="images/delete.gif" border="0"></th>
	</form>
	<form method="post" name="SendEMail" action="email3.cfm">
					<input type="hidden" name="ReturnID" value="#ReturnID#">
					<input type="hidden" name="ReturnPage" value="#ReturnPage#">
					<th><input type="image" name="sendit" src="images/sendemail.gif" border="0"></th>
	</form>
				</tr>
			</table>
		</th>
	</tr>
<cfif EMailList.Recordcount GT mrow>
	<form method="post" action="email2.cfm">
		<cfoutput>
			<input type="hidden" name="ordby" value="#ordby#">
			<input type="hidden" name="orddir" value="#orddir#">
			<input type="hidden" name="ReturnID" value="#ReturnID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<tr bgcolor="#tdclr#">
		</cfoutput>
			<td colspan="5"><select name="Page" onChange="submit()">
				<cfloop index="B5" from="1" to="#NumPages#">
					<cfset ArrayPoint = B5 * Mrow - (Mrow - 1)>
					<cfif ordby is "Name">
						<cfset disp = EMailList.LastName[ArrayPoint]>
					<cfelseif ordby is "EMailAddr">
						<cfset disp = EMailList.EMailAddr[ArrayPoint]>
					<cfelseif ordby Is "Baldue">
						<cfset disp = EMailList.BalDue[ArrayPoint]>
						<cfset disp = LSCurrencyFormat(disp)>
					<cfelseif ordby is "startdate">
						<cfset disp = LSDateFormat(EMailList.StartDate[ArrayPoint], '#DateMask1#')>
					</cfif>
					<cfoutput><option <cfif Page Is B5>Selected</cfif> value="#B5#">Page #B5# - #disp#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>Selected</cfif> value="0">View All - #EMailList.Recordcount#</cfoutput>
			</select></td>
		</tr>
		<cfoutput>
		<input type="hidden" name="WhoFrom" value="#WhoFrom#">
		<input type="hidden" name="Message" value="#Message#">
		<input type="hidden" name="Subject" value="#Subject#">
		<input type="hidden" name="BDomainName" value="#BDomainName#">
		<input type="hidden" name="CDomainName" value="#CDomainName#">
		<input type="hidden" name="SDomainName" value="#SDomainName#">
		<input type="hidden" name="whofrom2" value="#whofrom2#">
		<input type="hidden" name="LetterID" value="#LetterID#">
		<input type="hidden" name="SendLetterID" value="#SendLetterID#">
		<input type="hidden" name="BegDay" value="#BegDay#">
		<input type="hidden" name="EndDay" value="#EndDay#">
		<input type="hidden" name="MinAmnt" value="#MinAmnt#">
		<input type="hidden" name="MinCredit" value="#MinCredit#">
		<cfif IsDefined("Credit")>
			<input type="hidden" name="Credit" value="#Credit#">
		<cfelse>
			<input type="hidden" name="Credit" value="0">
		</cfif>
		<cfif IsDefined("CheckD")>
			<input type="hidden" name="CheckD" value="#CheckD#">
		<cfelse>
			<input type="hidden" name="CheckD" value="0">
		</cfif>
		<cfif IsDefined("Postal")>
			<input type="hidden" name="Postal" value="#Postal#">
		<cfelse>
			<input type="hidden" name="Postal" value="0">
		</cfif>
		<cfif IsDefined("GroupSubs")>
			<input type="hidden" name="GroupSubs" value="#GroupSubs#">
		<cfelse>
			<input type="hidden" name="GroupSubs" value="0">
		</cfif>
		<input type="hidden" name="DomainID" value="#DomainID#">
		<input type="hidden" name="PlanID" value="#PlanID#">
		<input type="hidden" name="POPID" value="#POPID#">
		<input type="hidden" name="SalesPID" value="#SalesPID#">
		</cfoutput>
	</form>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
         