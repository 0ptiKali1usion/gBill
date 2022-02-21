<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.0 07/03/99 --->
<!--- grplist.cfm --->

<cfif IsDefined("StartOver.x")>
	<cfquery name="DelEmailOutgoing" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = #LetterID# 
	</cfquery>
</cfif>
<cfif IsDefined("EMailList.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AccountID 
		FROM EMailOutgoing 
		WHERE LetterID = #LetterID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsEMailOutGoing" datasource="#pds#">
			INSERT INTO EMailOutgoing 
			(AccountID, LastName, FirstName, Company, EMailAddr, 
			EMailDate, AdminID, LetterID, SelectedLetter, CreateDate) 
			SELECT A.AccountID, A.LastName, A.FirstName, A.Company, A.EMail, 
			#Now()#, #MyAdminID#, #LetterID#, #EMailLetterID#, #Now()# 
			FROM GrpLists A 
			WHERE A.ReportID = #ReportID# 
			AND A.AdminID = #MyAdminID# 	
			AND A.EMail IS NOT NULL 
			<cfif SelectedTab Is Not "All">
				AND A.ReportTab = '#SelectedTab#' 
			</cfif>
			GROUP BY A.AccountID, A.LastName, A.FirstName, A.Company, A.EMail 
		</cfquery>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE EMailOutgoing SET EMailOutgoing.StartDate = 
		A.StartDate 
		FROM Accounts A, EMailOutgoing G 
		WHERE A.AccountID = G.AccountID 
		AND G.LetterID = #LetterID# 
		AND G.AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="EMailValues" datasource="#pds#">
		SELECT EMailMessage, EMailFrom, EMailSubject, EMailRepeatMsg 
		FROM Integration 
		WHERE IntID = #LetterID# 
	</cfquery>
	<cfset EMailOutgoingMessage = EMailValues.EMailMessage & "
" & EMailValues.EMailRepeatMsg>
	<cfquery name="EMailLetters" datasource="#pds#">
		UPDATE EMailOutgoing SET 
		EMailSubject = '#EMailValues.EMailSubject#', 
		FromAddr = '#EMailValues.EMailFrom#', 
		LetterBody = '#EMailOutgoingMessage#'
		WHERE LetterID = #LetterID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="emaillist.cfm">
	<cfabort>
</cfif>
<cfif (IsDefined("DelSelected.x")) AND (IsDefined("DelGrpListID"))>
	<cfinclude template="grplistdel.cfm">
	<cfquery name="RemoveFromList" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE GrpListID In (#DelGrpListID#) 
	</cfquery>
</cfif>
<cfif IsDefined("SendReportID")>
	<cfset ReportID = SendReportID>
</cfif>
<cfif IsDefined("SendLetterID")>
	<cfset LetterID = SendLetterID>
</cfif>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = #LetterID# 
	</cfquery>
</cfif>
<cfquery name="CheckEMail" datasource="#pds#">
	SELECT AccountID 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = #LetterID# 
</cfquery>
<cfset DefaultObid = ListGetAt(SendFields,1)>
<cfparam name="Page2" default="1">
<cfparam name="obdir2" default="asc">
<cfparam name="obid2" default="#DefaultObid#">
<cfquery name="GetLetters" datasource="#pds#">
	SELECT IntID, IntDesc 
	FROM Integration 
	WHERE ActiveYN = 1 
	AND Action = 'Letter' 
	AND IntID In 
		(SELECT IntID 
		 FROM LetterAdm 
		 WHERE AdminID = #MyAdminID#) 
	<cfif LetterID Is 0>
		AND IntID = 0 
	</cfif>
	<cfif GetOpts.SendEmail Is 0>
		AND IntID = 0 
	</cfif>
</cfquery>
<cfparam name="TabList" default="">
<cfparam name="SelectedTab" default="All">
<cfquery name="List" datasource="#pds#">
	SELECT * 
	FROM GrpLists 
	WHERE ReportID = #ReportID# 
	AND AdminID = #MyAdminID# 
	<cfif SelectedTab Is Not "All">
		AND ReportTab = '#SelectedTab#'
	</cfif>
	ORDER BY <cfif obid2 Is "Name">LastName #obdir2#, FirstName #obdir2#
				<cfelseif obid2 Is "URL">ReportStr #obdir2#
				<cfelseif obid2 Is "SessTime">CurTime #obdir2# 
				<cfelse>#obid2# #obdir2#
				</cfif> 
</cfquery>
<cfif List.RecordCount Is 0>
	<cfquery name="List" datasource="#pds#">
		SELECT * 
		FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		ORDER BY <cfif obid2 Is "Name">LastName #obdir2#, FirstName #obdir2#
					<cfelseif obid2 Is "URL">ReportStr #obdir2#
					<cfelseif obid2 Is "SessTime">CurTime #obdir2# 
					<cfelse>#obid2# #obdir2#
					</cfif> 
	</cfquery>
</cfif>
<cfif Trim(List.ReportTab) Is Not "">
	<cfquery name="TabLists" datasource="#pds#">
		SELECT ReportTab 
		FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		GROUP BY ReportTab 
		ORDER BY ReportTab
	</cfquery>
	<cfset TabList = ValueList(TabLists.ReportTab)>
</cfif>
<cfif Page2 Is 0>
	<cfset MaxRows = List.RecordCount>
	<cfset Srow = 1>
<cfelse>
	<cfset MaxRows = mrow>
	<cfset Srow = (Page2*Mrow)-(Mrow-1)>
</cfif>
<cfset PageNumber = Ceiling(List.RecordCount/Mrow)>
<cfset HowWide = ListLen(SendHeader) + 1>
<cfif GetOpts.SendEmail Is "0">
	<cfif ListContains(SendHeader,"E-Mail")>
		<cfset HowWide = HowWide - 1>
	</cfif>
</cfif>
<cfset PageTotal = 0>
<cfset PageTotal2 = 0>
<cfset ShowTotal = 0>
<cfset ShowTotal2 = 0>
<cfif ListFindNoCase(SendFields,"CurBal")>
	<cfquery name="CurBalTotal" datasource="#pds#">
		SELECT Sum(CurBal) As CBTot 
		FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = #ReportID#
	</cfquery>
</cfif>
<cfif ListFindNoCase(SendFields,"CurBal2")>
	<cfquery name="CurBalTotal2" datasource="#pds#">
		SELECT Sum(CurBal2) As CBTot 
		FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = #ReportID#
	</cfquery>
</cfif>
<cfquery name="CheckDest" datasource="#pds#">
	SELECT * 
	FROM GrpListInfo 
	WHERE ReportID = #ReportID# 
	AND AdminID = #MyAdminID# 
</cfquery>
<cfset SessTimeTotal = 0>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Customer List</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function SelectAll(tf)
	{
	 var len = document.Results.DelGrpListID.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.Results.DelGrpListID[i].checked=tf;
		}
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onLoad="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="#ReturnPage#">
		<cfif IsDefined("page")>
			<input type="hidden" name="page" value="#Page#">
		</cfif>
		<cfif IsDefined("ReturnID")>
			<input type="hidden" name="ReturnID" value="#ReturnID#">
		</cfif>
		<cfif IsDefined("obdir")>
			<input type="hidden" name="obdir" value="#obdir#">
		</cfif>
		<cfif IsDefined("obid")>
			<input type="hidden" name="obid" value="#obid#">
		</cfif>
		<input type="image" src="images/return.gif" name="return" border=0>
	</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<cfif Trim(List.ReportTitle) Is "">
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Search Results</font></th>
		<cfelse>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">#List.ReportTitle#</font></th>
		</cfif>
	</tr>
</cfoutput>
<cfif List.RecordCount GT Mrow>	
	<tr>
		<form method="post" action="grplist.cfm">
			<cfoutput>
			<input type="hidden" name="SelectedTab" value="#SelectedTab#">
			<input type="hidden" name="ReportID" value="#ReportID#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SendHeader" value="#SendHeader#">
			<input type="hidden" name="SendFields" value="#SendFields#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<input type="hidden" name="obdir2" value="#obdir2#">
			<input type="hidden" name="obid2" value="#obid2#">
			<cfif IsDefined("ReturnID")>
				<input type="hidden" name="ReturnID" value="#ReturnID#">
			</cfif>
			<cfif IsDefined("page")>
				<input type="hidden" name="page" value="#Page#">
			</cfif>
			<cfif IsDefined("obdir")>
				<input type="hidden" name="obdir" value="#obdir#">
			</cfif>
			<cfif IsDefined("obid")>
				<input type="hidden" name="obid" value="#obid#">
			</cfif>
			<td colspan="#HowWide#"><select name="Page2" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
					<cfif obid2 Is "CurBal">
						<cfset BuildStr = List.CurBal[ArrayPoint]>
						<cfset DispStr = LSCurrencyFormat(BuildStr)>
					<cfelseif obid2 Is "CurBal2">
						<cfset BuildStr = List.CurBal2[ArrayPoint]>
						<cfset DispStr = LSCurrencyFormat(BuildStr)>
					<cfelseif obid2 Is "Name">
						<cfset DispStr = List.LastName[ArrayPoint]>
					<cfelseif obid2 Is "URL">
						<cfset DispStr = List.ReportStr[ArrayPoint]>
					<cfelseif obid2 Is "ReportDate">
						<cfset DispStr = List.ReportDate[ArrayPoint]>
						<cfset DispStr = LSDateFormat(DispStr, '#DateMask1#')>
					<cfelseif obid2 Is "Sesstime">
						<cfset DisplayStr = List.CurTime[ArrayPoint]>
						<cfset Hours = Int(DisplayStr/3600)>
							<cfset HourSecs = Hours * 3600>
							<cfset DisplayStr2 = DisplayStr - HourSecs>
						<cfset Minutes = Int(DisplayStr2/60)>
							<cfset MinSecs = Minutes * 60>
							<cfset DisplayStr3 = DisplayStr - HourSecs - MinSecs>
						<cfset Seconds = DisplayStr3>
						<cfset DispStr = "#Hours#:">
						<cfif Minutes LT 10>
							<cfset DispStr = DispStr & "0" & "#Minutes#:">
						<cfelse>
							<cfset DispStr = DispStr & "#Minutes#:">
						</cfif>
						<cfif Seconds LT 10>
							<cfset DispStr = DispStr & "0" & Seconds>
						<cfelse>
							<cfset DispStr = DispStr & Seconds>
						</cfif>
					<cfelse>
						<cfset DispStr = Evaluate("List.#obid2#[ArrayPoint]")>
					</cfif>
					<cfoutput><option <cfif Page2 Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page2 Is 0>selected</cfif> value="0">View All - #List.RecordCount#</cfoutput>
			</select></td>
		</form>
	</tr>
</cfif>
<cfif TabList Is Not "">
	<cfif List.TabType Is 1>
		<tr>
			<cfoutput>
				<form method="post" action="grplist.cfm">
					<input type="hidden" name="ReportID" value="#ReportID#">
					<input type="hidden" name="LetterID" value="#LetterID#">
					<input type="hidden" name="SendHeader" value="#SendHeader#">
					<input type="hidden" name="SendFields" value="#SendFields#">
					<input type="hidden" name="ReturnPage" value="#ReturnPage#">
					<input type="hidden" name="obdir2" value="#obdir2#">
					<input type="hidden" name="obid2" value="#obid2#">
					<cfif IsDefined("ReturnID")>
						<input type="hidden" name="ReturnID" value="#ReturnID#">
					</cfif>
					<cfif IsDefined("page")>
						<input type="hidden" name="page" value="#Page#">
					</cfif>
					<cfif IsDefined("obdir")>
						<input type="hidden" name="obdir" value="#obdir#">
					</cfif>
					<cfif IsDefined("obid")>
						<input type="hidden" name="obid" value="#obid#">
					</cfif>
					<td colspan="#HowWide#"><select name="SelectedTab" onchange="submit()">
			</cfoutput>
						<option <cfif SelectedTab Is "All">selected</cfif> value="All">All
						<cfloop index="B5" list="#TabList#">
							<cfoutput><option <cfif SelectedTab Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
						</cfloop>
					</select></td>
				</form>
		</tr>
	<cfelse>
		<tr>
			<cfoutput>
			<th colspan="#HowWide#">
				<table border="1">
					<tr bgcolor="#tdclr#">
						<form method="post" action="grplist.cfm">
							<input type="hidden" name="ReportID" value="#ReportID#">
							<input type="hidden" name="LetterID" value="#LetterID#">
							<input type="hidden" name="SendHeader" value="#SendHeader#">
							<input type="hidden" name="SendFields" value="#SendFields#">
							<input type="hidden" name="ReturnPage" value="#ReturnPage#">
							<input type="hidden" name="obdir2" value="#obdir2#">
							<input type="hidden" name="obid2" value="#obid2#">
							<cfif IsDefined("ReturnID")>
								<input type="hidden" name="ReturnID" value="#ReturnID#">
							</cfif>
							<cfif IsDefined("page")>
								<input type="hidden" name="page" value="#Page#">
							</cfif>
							<cfif IsDefined("obdir")>
								<input type="hidden" name="obdir" value="#obdir#">
							</cfif>
							<cfif IsDefined("obid")>
								<input type="hidden" name="obid" value="#obid#">
							</cfif>
							<th <cfif SelectedTab Is "All">bgcolor="#tbclr#"</cfif> ><input type="radio" <cfif SelectedTab Is "All">checked</cfif> name="SelectedTab" value="All" onclick="submit()" id ="col1"><label for="col1">All</label></th>
						</form>
			</cfoutput>
						<cfset Lpcount = 1>
						<cfloop index="B5" list="#TabList#">
							<cfset Lpcount = Lpcount + 1>
							<cfoutput>
							<form method="post" action="grplist.cfm">
								<input type="hidden" name="ReportID" value="#ReportID#">
								<input type="hidden" name="LetterID" value="#LetterID#">
								<input type="hidden" name="SendHeader" value="#SendHeader#">
								<input type="hidden" name="SendFields" value="#SendFields#">
								<input type="hidden" name="ReturnPage" value="#ReturnPage#">
								<input type="hidden" name="obdir2" value="#obdir2#">
								<input type="hidden" name="obid2" value="#obid2#">
								<cfif IsDefined("ReturnID")>
									<input type="hidden" name="ReturnID" value="#ReturnID#">
								</cfif>
								<cfif IsDefined("page")>
									<input type="hidden" name="page" value="#Page#">
								</cfif>
								<cfif IsDefined("obdir")>
									<input type="hidden" name="obdir" value="#obdir#">
								</cfif>
								<cfif IsDefined("obid")>
									<input type="hidden" name="obid" value="#obid#">
								</cfif>
								<th <cfif B5 Is SelectedTab>bgcolor="#tbclr#"</cfif> ><input type="radio" <cfif SelectedTab Is B5>checked</cfif> name="SelectedTab" value="#B5#" onclick="submit()" id ="col#Lpcount#"><label for="col#Lpcount#">#B5#</label></th>
							</form>
							</cfoutput>
						</cfloop>
					</tr>
				</table>
			</th>
		</tr>
	</cfif>
</cfif>
<cfif List.Recordcount GT 0>
	<cfif GetLetters.Recordcount GT 0>
		<cfif CheckEMail.Recordcount Is 0>
			<cfoutput>
				<tr bgcolor="#tdclr#" valign="top">
					<form method="post" action="grplist.cfm" onsubmit="MsgWindow()">
						<cfif IsDefined("ReturnID")>
							<input type="hidden" name="ReturnID" value="#ReturnID#">
						</cfif>
						<input type="hidden" name="SendHeader" value="#SendHeader#">
						<input type="hidden" name="SelectedTab" value="#SelectedTab#">						
						<input type="hidden" name="SendFields" value="#SendFields#">
						<input type="hidden" name="LetterID" value="#LetterID#">
						<input type="hidden" name="ReportID" value="#ReportID#">
						<input type="hidden" name="ReturnPage" value="#ReturnPage#">
						<input type="hidden" name="ReturnTo" value="grplist.cfm">
						<input type="hidden" name="obid2" value="#obid2#">
						<input type="hidden" name="obdir2" value="#obdir2#">
						<input type="hidden" name="page2" value="#page2#">
						<cfif IsDefined("page")>
							<input type="hidden" name="page" value="#Page#">
						</cfif>
						<cfif IsDefined("obdir")>
							<input type="hidden" name="obdir" value="#obdir#">
						</cfif>
						<cfif IsDefined("obid")>
							<input type="hidden" name="obid" value="#obid#">
						</cfif>
						<td colspan="#HowWide#"><select name="EMailLetterID">
			</cfoutput>
							<cfoutput query="GetLetters">
								<option value="#IntID#">#IntDesc#
							</cfoutput>
						</select><input type="image" name="EMailList" src="images/viewlist.gif" border="0"></td>
					</form>
				</tr>
		<cfelse>
			<tr>
				<cfoutput><th colspan="#HowWide#"></cfoutput>
					<table border="0">
						<tr>
							<form method="post" action="emaillist.cfm">
								<cfoutput>
									<cfif IsDefined("ReturnID")>
										<input type="hidden" name="ReturnID" value="#ReturnID#">
									</cfif>
									<input type="hidden" name="LetterID" value="#LetterID#">
									<input type="hidden" name="SelectedTab" value="#SelectedTab#">
									<input type="hidden" name="ReportID" value="#ReportID#">
									<input type="hidden" name="ReturnPage" value="#ReturnPage#">
									<input type="hidden" name="ReturnTo" value="grplist.cfm">
									<input type="hidden" name="SendHeader" value="#SendHeader#">
									<input type="hidden" name="SendFields" value="#SendFields#">
									<input type="hidden" name="obid2" value="#obid2#">
									<input type="hidden" name="obdir2" value="#obdir2#">
									<input type="hidden" name="Page2" value="#Page2#">
									<cfif IsDefined("page")>
										<input type="hidden" name="page" value="#Page#">
									</cfif>
									<cfif IsDefined("obdir")>
										<input type="hidden" name="obdir" value="#obdir#">
									</cfif>
									<cfif IsDefined("obid")>
										<input type="hidden" name="obid" value="#obid#">
									</cfif>
								</cfoutput>
								<td><input type="image" name="CurrentList" src="images/viewlist.gif" border="0"></td>
							</form>
							<form action="grplist.cfm" method="post">			
								<cfoutput>
									<input type="hidden" name="ReportID" value="#ReportID#">
									<input type="hidden" name="SelectedTab" value="#SelectedTab#">
									<input type="hidden" name="LetterID" value="#LetterID#">
									<input type="hidden" name="SendHeader" value="#SendHeader#">
									<input type="hidden" name="SendFields" value="#SendFields#">
									<input type="hidden" name="ReturnPage" value="#ReturnPage#">
									<input type="hidden" name="obid2" value="#obid2#">
									<input type="hidden" name="obdir2" value="#obdir2#">
									<input type="hidden" name="Page2" value="#Page2#">
									<cfif IsDefined("page")>
										<input type="hidden" name="page" value="#Page#">
									</cfif>
									<cfif IsDefined("obdir")>
										<input type="hidden" name="obdir" value="#obdir#">
									</cfif>
									<cfif IsDefined("obid")>
										<input type="hidden" name="obid" value="#obid#">
									</cfif>
								</cfoutput>
								<td><input type="image" name="StartOver" src="images/changecriteria.gif" border="0"></td>
							</form>
						</tr>
					</table>
				</th>
			</tr>
		</cfif>
	</cfif>
	<cfif CheckDest.Recordcount GT 0>
		<cfif CheckDest.ReportTab Is "">
			<tr valign="top" align="right">
				<cfoutput>
					<form method="post" action="#CheckDest.DestinationCFM#" onsubmit="self.focus()">
						<td colspan="#HowWide#"><input type="image" name="Process" src="images/#CheckDest.DestinationIMG#" border="0"></td>
					</form>
				</cfoutput>
			</tr>
		<cfelseif CheckDest.ReportTab Is SelectedTab>
			<tr valign="top" align="right">
				<cfoutput>
					<form method="post" action="#CheckDest.DestinationCFM#" onsubmit="self.focus()">
						<td colspan="#HowWide#"><input type="image" name="Process" src="images/#CheckDest.DestinationIMG#" border="0"></td>
					</form>
				</cfoutput>
			</tr>
		</cfif>
	</cfif>
	<cfoutput>
		<tr bgcolor="#thclr#" valign="top">
			<th>Remove<br><font size="1"><a href="javascript:SelectAll(true)">Select</a> <a href="javascript:SelectAll(false)">Clear</a></font></th>
	</cfoutput>
			<cfset counter1 = 0>
			<cfloop index="B4" list="#SendHeader#">
				<cfif (B4 Is Not "E-Mail") OR (GetOpts.SendEMail Is "1")>
					<cfset counter1 = counter1 + 1>
					<cfset B3 = ListGetAt(SendFields,Counter1)>
					<form method="post" action="grplist.cfm">
						<cfoutput>
							<cfif IsDefined("page")><input type="hidden" name="page" value="#Page#">
							</cfif>
							<cfif IsDefined("ReturnID")><input type="hidden" name="ReturnID" value="#ReturnID#">
							</cfif>
							<cfif IsDefined("obdir")><input type="hidden" name="obdir" value="#obdir#">
							</cfif>
							<cfif IsDefined("obid")><input type="hidden" name="obid" value="#obid#">
							</cfif>
							<input type="hidden" name="LetterID" value="#LetterID#">
							<input type="hidden" name="SelectedTab" value="#SelectedTab#">
							<input type="hidden" name="ReportID" value="#ReportID#">
							<input type="hidden" name="ReturnPage" value="#ReturnPage#">
							<input type="hidden" name="SendHeader" value="#SendHeader#">
							<input type="hidden" name="SendFields" value="#SendFields#">
							<input type="hidden" name="Page2" value="#Page2#">
							<cfif (obid2 Is B3) AND (obdir2 Is "asc")>
								<input type="hidden" name="obdir2" value="desc">
							<cfelse>
								<input type="hidden" name="obdir2" value="asc">
							</cfif>
							<th nowrap><cfif B3 Is Not "MemoField"><input type="radio" <cfif obid2 Is B3>checked</cfif> name="obid2" value="#B3#" onclick="submit()" id="col#counter1#"><label for="col#counter1#">#B4#</label><cfelse>#B4#</cfif></th>
						</cfoutput>
					</form>
				</cfif>
			</cfloop>
		</tr>
	<cfset LastRow = (Srow + MaxRows) -1>
	<form method="post" name="Results" action="grplist.cfm" onSubmit="return confirm ('Click Ok to confirm removing the selected customers from the list.')">
		<cfoutput>
			<cfif IsDefined("page")><input type="hidden" name="page" value="#Page#">
			</cfif>
			<cfif IsDefined("ReturnID")><input type="hidden" name="ReturnID" value="#ReturnID#">
			</cfif>
			<cfif IsDefined("obdir")><input type="hidden" name="obdir" value="#obdir#">
			</cfif>
			<cfif IsDefined("obid")><input type="hidden" name="obid" value="#obid#">
			</cfif>
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="SelectedTab" value="#SelectedTab#">
			<input type="hidden" name="ReportID" value="#ReportID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<input type="hidden" name="SendHeader" value="#SendHeader#">
			<input type="hidden" name="SendFields" value="#SendFields#">
			<input type="hidden" name="Page2" value="#Page2#">
			<input type="hidden" name="obdir2" value="#obdir2#">
			<input type="hidden" name="obid2" value="#obid2#">
		</cfoutput>
		<cfloop query="List" startrow="#Srow#" endrow="#LastRow#">
			<cfoutput><tr valign="top" bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" name="DelGrpListID" value="#GrpListID#"></th>
			</cfoutput>
				<cfloop index="B4" list="#SendFields#">
					<cfif B4 Is "Name">
						<cfif AccountID Is "">
							<td nowrap>***</td>
						<cfelse>
							<cfoutput>
								<td nowrap><a href="custinf1.cfm?Accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="New"</cfif> >#LastName#, #FirstName#</a></td>
							</cfoutput>	
						</cfif>
					<cfelseif B4 Is "EMail">
						<cfoutput>
							<cfif GetOpts.SendEmail Is "1">
								<td><cfif Trim(Email) Is "">&nbsp;<cfelse><a href="mailto.cfm?email=#email#" target="_blank">#email#</a></cfif></td>
							</cfif>
						</cfoutput>
					<cfelseif B4 Is "ReportDate">
						<cfoutput><td><cfif Trim(ReportDate) Is "">&nbsp;<cfelse>#LSDateFormat(ReportDate, '#DateMask1#')#</cfif></td>
						</cfoutput>
					<cfelseif B4 Is "ReportDate2">
						<cfoutput><td><cfif Trim(ReportDate2) Is "">&nbsp;<cfelse>#LSDateFormat(ReportDate2, '#DateMask1#')#</cfif></td>
						</cfoutput>
					<cfelseif B4 Is "CurBal">
						<cfset PageTotal = PageTotal + CurBal>
						<cfset ShowTotal = 1>
						<cfoutput><td align="right"><cfif Trim(CurBal) Is "">&nbsp;<cfelse>#LSCurrencyFormat(CurBal)#</cfif></td>
						</cfoutput>
					<cfelseif B4 Is "CurBal2">
						<cfset PageTotal2 = PageTotal2 + CurBal2>
						<cfset ShowTotal2 = 1>
						<cfoutput><td align="right"><cfif Trim(CurBal2) Is "">&nbsp;<cfelse>#LSCurrencyFormat(CurBal2)#</cfif></td>
						</cfoutput>
					<cfelseif B4 Is "CurPercent">
						<cfoutput><td align="right">#Trim(NumberFormat(CurPercent, '99999999.99'))#%</td></cfoutput>
					<cfelseif B4 Is "URL">
						<cfif Trim(ReportURL) Is "">
							<td>&nbsp;</td>
						<cfelse>
							<cfoutput>
								<cfif Trim(ReportURLID) Is Not "">
									<td><a href="#ReportURL##ReportURLID#" target="_ViewMail"><cfif Trim(ReportStr) Is "">Link<cfelse>#ReportStr#</cfif></a></td>
								<cfelseif Trim(ReportURLID2) Is Not "">
									<td><a href="#ReportURL##ReportURLID2#" target="_New"><cfif Trim(ReportStr) Is "">Link<cfelse>#ReportStr#</cfif></a></td>
								<cfelse>
									<td><a href="#ReportURL#" target="_New"><cfif Trim(ReportStr) Is "">Link<cfelse>#ReportStr#</cfif></a></td>
								</cfif>
							</cfoutput>
						</cfif>
					<cfelseif B4 Is "SessTime">
						<cfset TotalTime = CurTime>
						<cfset SessTimeTotal = SessTimeTotal + TotalTime>
						<cfset Hours = Int(CurTime/3600)>
							<cfset HourSecs = Hours * 3600>
							<cfset CurTime2 = TotalTime-HourSecs>
						<cfset Minutes = Int(CurTime2/60)>
							<cfset MinSecs = Minutes * 60>
							<cfset CurTime3 = TotalTime - HourSecs - MinSecs>
						<cfset Seconds = CurTime3>
						<cfoutput>
							<td align="right">#Hours#:<cfif Minutes LT 10>0</cfif>#Minutes#:<cfif Seconds LT 10>0</cfif>#Seconds#</td>
						</cfoutput>
					<cfelseif B4 Is "StartTime">
						<cfoutput><td align="right">#TimeFormat(StartTime, 'hh:mm:ss tt')#</td></cfoutput>
					<cfelseif B4 Is "EndTime">
						<cfoutput><td align="right">#TimeFormat(EndTime, 'hh:mm:ss tt')#</td></cfoutput>
					<cfelse>
						<cfset DispString = Evaluate("#B4#")>
						<cfoutput><td><cfif Trim(DispString) Is "">&nbsp;<cfelse>#DispString#</cfif></td>
						</cfoutput>
					</cfif>
				</cfloop>
			</tr>
		</cfloop>
		<cfif (ShowTotal Is 1) AND (ShowTotal2 Is 0)>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal")>
			<cfset Pos1 = WhereAt>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfif List.RecordCount GT Mrow>
				<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Page Total</td>
						<cfset CWide = Cwide + Pos1>
						<cfset HeaderTitle = 1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(PageTotal)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Page Total</td>
						</cfif>
					</cfif>
				</tr>
				</cfoutput>
			</cfif>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal")>
			<cfset Pos1 = WhereAt>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Grand Total</td>
						<cfset HeaderTitle = 1>
						<cfset CWide = Cwide + Pos1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(CurBalTotal.CBTot)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Grand Total</td>	
						</cfif>
					</cfif>
				</tr>
			</cfoutput>
		<cfelseif (ShowTotal Is 0) AND (ShowTotal2 Is 1)>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal2")>
			<cfset Pos1 = WhereAt>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfif List.RecordCount GT Mrow>	
				<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Page Total</td>
						<cfset CWide = Cwide + Pos1>
						<cfset HeaderTitle = 1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(PageTotal2)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Page Total</td>
						</cfif>
					</cfif>
				</tr>
				</cfoutput>
			</cfif>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal2")>
			<cfset Pos1 = WhereAt>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Grand Total</td>
						<cfset HeaderTitle = 1>
						<cfset CWide = Cwide + Pos1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(CurBalTotal2.CBTot)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Grand Total</td>	
						</cfif>
					</cfif>
				</tr>
			</cfoutput>
		<cfelseif (ShowTotal Is 1) AND (ShowTotal2 Is 1)>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal")>
			<cfset WhereAt2 = ListFindNoCase(SendFields,"CurBal2")>
			<cfset Pos1 = Min(WhereAt,WhereAt2)>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfif List.RecordCount GT Mrow>	
				<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Page Total</td>
						<cfset CWide = Cwide + Pos1>
						<cfset HeaderTitle = 1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(PageTotal)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					<cfelse>	
						<td align="right">#LSCurrencyFormat(PageTotal2)#</td>
						<cfset T1 = 2>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfif T1 Is 1>
						<cfset Pos2 = WhereAt2 - WhereAt - 1>
						<cfif Pos2 GT 1>
							<cfif HeaderTitle Is "1">
								<td colspan="#Pos2#">&nbsp;</td>
							<cfelse>
								<td colspan="#Pos2#">Page Total</td>
								<cfset HeaderTitle = 1>
							</cfif>
							<td align="right">#LSCurrencyFormat(PageTotal2)#</td>
							<cfset CWide = Cwide + Pos2 + 1>
						<cfelse>
							<td align="right">#LSCurrencyFormat(PageTotal2)#</td>
							<cfset CWide = Cwide + 1>
						</cfif>
					<cfelse>
						<cfset Pos2 = WhereAt - WhereAt2 - 1>
						<cfif Pos2 GT 1>
							<cfif HeaderTitle Is "1">
								<td colspan="#Pos2#">&nbsp;</td>
							<cfelse>
								<td colspan="#Pos2#">Page Total</td>
								<cfset HeaderTitle = 1>
							</cfif>
							<td align="right">#LSCurrencyFormat(PageTotal)#</td>
							<cfset CWide = Cwide + Pos2 + 1>
						<cfelse>
							<td align="right">#LSCurrencyFormat(PageTotal)#</td>
							<cfset CWide = Cwide + 1>
						</cfif>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Page Total</td>
						</cfif>
					</cfif>
				</tr>
				</cfoutput>
			</cfif>
			<cfset WhereAt = ListFindNoCase(SendFields,"CurBal")>
			<cfset WhereAt2 = ListFindNoCase(SendFields,"CurBal2")>
			<cfset Pos1 = Min(WhereAt,WhereAt2)>
			<cfset CWide = 0>
			<cfset HeaderTitle = 0>
			<cfoutput>
				<tr bgcolor="#thclr#">
					<cfif Pos1 GT 1>
						<td colspan="#Pos1#" align="right">Grand Total</td>
						<cfset HeaderTitle = 1>
						<cfset CWide = Cwide + Pos1>
					<cfelseif Pos1 Is 1>
						<td>&nbsp;</td>
						<cfset CWide = CWide + Pos1>
					</cfif>
					<cfif Pos1 Is WhereAt>
						<td align="right">#LSCurrencyFormat(CurBalTotal.CBTot)#</td>
						<cfset T1 = 1>
						<cfset CWide = Cwide + 1>
					<cfelse>
						<td align="right">#LSCurrencyFormat(CurBalTotal2.CBTot)#</td>
						<cfset T1 = 2>
						<cfset CWide = Cwide + 1>
					</cfif>
					<cfif T1 Is 1>
						<cfset Pos2 = WhereAt2 - WhereAt - 1>
						<cfif Pos2 GT 1>
							<cfif HeaderTitle Is "1">
								<td colspan="#Pos2#">&nbsp;</td>
							<cfelse>
								<td align="right" colspan="#Pos2#">Grand Total</td>
								<cfset HeaderTitle = "1">
							</cfif>
							<td align="right">#LSCurrencyFormat(CurBalTotal2.CBTot)#</td>
							<cfset CWide = Cwide + Pos2 + 1>
						<cfelse>
							<td align="right">#LSCurrencyFormat(CurBalTotal2.CBTot)#</td>
							<cfset CWide = Cwide + 1>
						</cfif>
					<cfelse>
						<cfset Pos2 = WhereAt - WhereAt2 - 1>
						<cfif Pos2 GT 1>
							<cfif HeaderTitle Is "1">
								<td colspan="#Pos2#">&nbsp;</td>
							<cfelse>
								<td align="right" colspan="#Pos2#">Grand Total</td>
								<cfset HeaderTitle = 1>
							</cfif>
							<td align="right">#LSCurrencyFormat(CurBalTotal.CBTot)#</td>
							<cfset CWide = Cwide + Pos2 + 1>
						<cfelse>
							<td align="right">#LSCurrencyFormat(CurBalTotal.CBTot)#</td>
							<cfset CWide = Cwide + 1>
						</cfif>
					</cfif>
					<cfset CLeft = HowWide - CWide>
					<cfif CLeft GT 0>
						<cfif HeaderTitle Is "1">
							<td colspan="#CLeft#">&nbsp;</td>
						<cfelse>
							<td colspan="#CLeft#">Grand Total</td>	
						</cfif>
					</cfif>
				</tr>
			</cfoutput>
		</cfif>
		<cfif SessTimeTotal GT 0>
			<cfset TheWideCell = HowWide>
			<cfset CellNum = ListFind(SendFields,'SessTime')>
			<cfoutput><tr bgcolor="#thclr#"></cfoutput>
				<cfif CellNum GT 0>
					<cfset TheWideCell = TheWideCell - CellNum>
					<cfoutput>
						<td colspan="#CellNum#">&nbsp;</td>
					</cfoutput>
				</cfif>
				<cfset TheWideCell = TheWideCell - 1>
				<cfset TotalTime2 = SessTimeTotal>
				<cfset THours = Int(TotalTime2/3600)>
				<cfset HourSecs2 = THours * 3600>
				<cfset TotalTime3 = TotalTime2-HourSecs2>
				<cfset TMinutes = Int(TotalTime3/60)>
				<cfset MinSecs2 = TMinutes * 60>
				<cfset TotalTime4 = TotalTime2 - HourSecs2 - MinSecs2>
				<cfset TSeconds = TotalTime4>
				<cfoutput>
					<td align="right">#THours#:<cfif TMinutes LT 10>0</cfif>#TMinutes#:<cfif TSeconds LT 10>0</cfif>#TSeconds#</td>
					<cfif TheWideCell GT 0>
						<td colspan="#TheWideCell#">&nbsp;</td>
					</cfif>
				</cfoutput>
			</tr>
		</cfif>
		<cfoutput>
			<tr>
				<th colspan="#HowWide#"><input type="image" name="DelSelected" src="images/remove.gif" border="0"></th>
			</tr>
		</cfoutput>
	</form>
<cfelse>
	<tr>
		<cfoutput>
			<td colspan="#HowWide#" bgcolor="#tbclr#">There was no match for the selected criteria.</td>
		</cfoutput>
	</tr>
</cfif>
<cfif List.RecordCount GT Mrow>	
	<tr>
		<form method="post" action="grplist.cfm">
			<cfoutput>
			<input type="hidden" name="ReportID" value="#ReportID#">
			<input type="hidden" name="SelectedTab" value="#SelectedTab#">
			<input type="hidden" name="SendHeader" value="#SendHeader#">
			<input type="hidden" name="SendFields" value="#SendFields#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<input type="hidden" name="obid2" value="#obid2#">
			<input type="hidden" name="obdir2" value="#obdir2#">
			<cfif IsDefined("ReturnID")>
				<input type="hidden" name="ReturnID" value="#ReturnID#">
			</cfif>
			<cfif IsDefined("page")>
				<input type="hidden" name="page" value="#Page#">
			</cfif>
			<cfif IsDefined("orddir")>
				<input type="hidden" name="orddir" value="#orddir#">
			</cfif>
			<cfif IsDefined("ordby")>
				<input type="hidden" name="ordby" value="#ordby#">
			</cfif>
			<td colspan="#HowWide#"><select name="Page2" onchange="submit()">
			</cfoutput>
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
					<cfif obid2 Is "CurBal">
						<cfset BuildStr = List.CurBal[ArrayPoint]>
						<cfset DispStr = LSCurrencyFormat(BuildStr)>
					<cfelseif obid2 Is "CurBal2">
						<cfset BuildStr = List.CurBal2[ArrayPoint]>
						<cfset DispStr = LSCurrencyFormat(BuildStr)>
					<cfelseif obid2 Is "Name">
						<cfset DispStr = List.LastName[ArrayPoint]>
					<cfelseif obid2 Is "URL">
						<cfset DispStr = List.ReportStr[ArrayPoint]>
					<cfelseif obid2 Is "Sesstime">
						<cfset DisplayStr = List.CurTime[ArrayPoint]>
						<cfset Hours = Int(DisplayStr/3600)>
							<cfset HourSecs = Hours * 3600>
							<cfset DisplayStr2 = DisplayStr - HourSecs>
						<cfset Minutes = Int(DisplayStr2/60)>
							<cfset MinSecs = Minutes * 60>
							<cfset DisplayStr3 = DisplayStr - HourSecs - MinSecs>
						<cfset Seconds = DisplayStr3>
						<cfset DispStr = "#Hours#:">
						<cfif Minutes LT 10>
							<cfset DispStr = DispStr & "0" & "#Minutes#:">
						<cfelse>
							<cfset DispStr = DispStr & "#Minutes#:">
						</cfif>
						<cfif Seconds LT 10>
							<cfset DispStr = DispStr & "0" & Seconds>
						<cfelse>
							<cfset DispStr = DispStr & Seconds>
						</cfif>
					<cfelse>
						<cfset DispStr = Evaluate("List.#obid2#[ArrayPoint]")>
					</cfif>
					<cfoutput><option <cfif Page2 Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page2 Is 0>selected</cfif> value="0">View All - #List.RecordCount#</cfoutput>
			</select></td>
		</form>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 