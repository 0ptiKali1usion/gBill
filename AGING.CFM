<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is a report of a 30/60/90 recievables report. --->
<!--- 4.0.0 09/01/99 
		3.4.0 03/05/99 --->
<!-- aging.cfm -->
<cfif IsDefined("DeleteReports.x")>
	<cfquery name="RemoveReport" datasource="#pds#">
		DELETE FROM AgingTemp 
		WHERE ReportID In (#DelThese#)  
		<cfif GetOpts.SUserYN Is 0>
			AND AdminID = #MyAdminID# 
		</cfif>
	</cfquery>
</cfif>

<cfif IsDefined("CreateReport.x")>
	<cfset MyDate = CreateDateTime(#FromYear#, #FromMon#, #FromDay#, 23, 59, 59)>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT Max(ReportID) as MaxID 
		FROM AgingTemp 
	</cfquery>
	<cfif CheckFirst.MaxID Is "">
		<cfset ReportID = 1>
	<cfelse>
		<cfset ReportID = CheckFirst.MaxID + 1>
	</cfif>
		<cfparam name="Past30" default="30">
		<cfparam name="Past60" default="60">
		<cfparam name="Past90" default="90">
		<cfset MyDate30 = DateAdd("d","-#Past30#",MyDate)>
		<cfset MyDate60 = DateAdd("d","-#Past60#",MyDate)>
		<cfset MyDate90 = DateAdd("d","-#Past90#",MyDate)>
		<cfquery name="startreport" datasource="#pds#">
			INSERT INTO AgingTemp (AccountID, FirstName, LastName, Login, Phone, 
			AdminID, ReportDate, ReportID, ReportName, CurChr, Past30, Past60, Past90, LastPayDt)	
			SELECT a.AccountID, a.FirstName, a.LastName, a.Login, a.dayphone, 
			#MyAdminID#, #MyDate#, #ReportID#, '#ReportName#', 
				ISNULL((SELECT Sum(Debit) FROM transactions B WHERE b.accountid = a.accountid 
				 AND datetime1 > #MyDate30# AND datetime1 <= #MyDate#),0) as CurChr, 
				ISNULL((SELECT Sum(Debit) FROM transactions B WHERE b.accountid = a.accountid 
				 AND datetime1 > #MyDate60# AND datetime1 <= #MyDate30#),0) as Past30, 
				ISNULL((SELECT Sum(Debit) FROM transactions B WHERE b.accountid = a.accountid 
				 AND datetime1 > #MyDate90# AND datetime1 <= #MyDate60#),0) as Past60, 
				ISNULL((SELECT Sum(Debit) FROM transactions B WHERE b.accountid = a.accountid 
				 AND datetime1 <= #MyDate90#),0) as Past90, 
				(SELECT max(datetime1) FROM transactions B WHERE b.accountid = a.accountid 
				 AND credit > 0 AND datetime1 <= #MyDate#) as LastPayDt 
			FROM accounts a, Transactions b 
			WHERE a.accountid = b.accountid 
			AND b.datetime1 <= #MyDate#
			GROUP BY a.accountid, a.firstname, a.lastname, a.login, a.dayphone 
			HAVING Sum(b.Debit - b.credit) > #MinAmount# 
		</cfquery>
		<cfquery name="updbal" datasource="#pds#">
			UPDATE AgingTemp 
			SET AgingTemp.LastPayAm = t.credit, 
			TotalPay = ISNULL((SELECT Sum(Credit) FROM transactions B 
									 WHERE b.accountid = a.accountid 
									 AND datetime1 <= #MyDate#),0), 
			CurBal = ISNULL((SELECT Sum(Debit-Credit) FROM transactions B 
								  WHERE b.accountid = a.accountid 
								  AND datetime1 <= #MyDate#),0)
			FROM Transactions t, AgingTemp a 
			WHERE t.accountid = a.accountid 		
			AND a.ReportID = #ReportID#
		</cfquery>
		<cfquery name="updamount" datasource="#pds#">
			UPDATE AgingTemp 
			SET AgingTemp.LastPayAm = t.credit
			FROM Transactions t, AgingTemp a 
			WHERE t.accountid = a.accountid 
			AND t.datetime1 = a.lastpaydt 
			AND a.ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE AgingTemp 
			SET AgingTemp.EMailAddr = E.EMail 
			FROM AccountsEMail E, AgingTemp A 
			WHERE A.AccountID = E.AccountID 
			AND E.PrEMail = 1 
			AND A.ReportID = #ReportID# 
			AND A.AdminID = #MyAdminID# 
		</cfquery>
		<!--- Set the display values --->
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display90 = (Past90 - TotalPay), 
			Display60 = (Past90+Past60-TotalPay), 
			Display30 = (Past90+Past60+Past30-TotalPay), 
			DisplayCur = (Past90+Past60+Past30+CurChr-TotalPay)
			WHERE ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display90 = 0 
			WHERE Display90 < 0 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display60 = 0 
			WHERE Display60 < 0 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display30 = 0 
			WHERE Display30 < 0 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			DisplayCur = 0 
			WHERE DisplayCur < 0 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display90 = Past90 
			WHERE Past90 < Display90 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display60 = Past60 
			WHERE Past60 < Display60 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			Display30 = Past30 
			WHERE Past30 < Display30 
			AND ReportID = #ReportID#
		</cfquery>
		<cfquery name="UpdDisp90" datasource="#pds#">
			UPDATE AgingTemp SET 
			DisplayCur = CurChr 
			WHERE CurChr < DisplayCur 
			AND ReportID = #ReportID#
		</cfquery>
</cfif>
<cfparam name="AlreadyExists" default="0">
<cfquery name="LowDate" datasource="#pds#">
	SELECT Min(DateTime1) as MinDate 
	FROM Transactions 
</cfquery>
<cfif LowDate.MinDate Is Not "">
	<cfset StartDates = LowDate.MinDate>
<cfelse>
	<cfset StartDates = Now()>
</cfif>
<cfset mm2 = Month(StartDates)>
<cfset yy2 = Year(StartDates)>
<cfset dd2 = Day(StartDates)>

<cfparam name="obdir" default="desc">
<cfparam name="Page" default="1">
<cfquery name="SessionDates" datasource="#pds#">
	SELECT ReportID, ReportDate, ReportName, AdminID 
	FROM AgingTemp 
	GROUP BY ReportID, ReportDate, ReportName, AdminID 
	ORDER BY ReportDate #obdir# 
</cfquery>
<cfif Page Is 0>
	<cfset MaxRows = SessionDates.Recordcount>
	<cfset SRow = 1>
<cfelse>
	<cfset MaxRows = MRow>
	<cfset SRow = (Page * Mrow) - (Mrow -1)>
</cfif>
<cfset PageNumber = Ceiling(SessionDates.Recordcount/Mrow)>

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
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!-- 
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
<cfinclude template="jsdates2.cfm">
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">

<cfif IsDefined("AddNew.x")>
	<form method="post" action="aging.cfm">
		<input type="image" name="return" src="images/return.gif" border="0">
	</form>
	<center>
	<cfoutput>
		<table border="#tblwidth#">
			<tr>
				<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Select Date For New Report</font></th>
			</tr>
	</cfoutput>
			<CFFORM NAME="getdate" ACTION="aging.cfm?RequestTimeout=500" ENABLECAB="No" onsubmit="MsgWindow()">
	<cfoutput>
				<tr>
					<th bgcolor="#thclr#" colspan="2">Select Maximum Date for report</th>
				</tr>
				<tr bgcolor="#tdclr#">
					<td bgcolor="#tbclr#" align=right>From</td>
	</cfoutput>
					<td><Select name="FromMon" onChange="getdays()">
						<cfloop index="B5" From="01" To="12">
							<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
							<cfoutput><option <cfif mmm is B5>selected</cfif> value="#B5#">#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
						</cfloop>
					</select><SELECT name="FromDay">
						<cfloop index="B5" From="01" To="#numDays#">
							<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
							<cfoutput><option <cfif B5 Is "1">selected</cfif> value="#B5#">#b5#</cfoutput>
						</cfloop>
					</select><SELECT name="FromYear" onChange="getdays()">
						<cfloop index="B4" from="#yy2#" to="#yyy#">
							<cfoutput><option <cfif yyy is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
						</cfloop>
					</select></td>
				</tr>
	<cfoutput>
				<tr>
					<td bgcolor="#tbclr#" align="right">Report Name</td>
					<td bgcolor="#tdclr#"><input type="text" name="ReportName" maxlength="250" size="25"></td>
				</tr>
				<tr>
					<td bgcolor="#tbclr#" align="right">Minimum Amount Owed</td>
					<td bgcolor="#tdclr#"><cfinput type="text" name="MinAmount" value="0" maxlength="5" size="5" validate="float" required="yes" message="Please enter the minimum amount for this report.  The minimum amount must be a number."></td>
				</tr>
	</cfoutput>
				<tr>
					<th colspan=2><input type="image" name="CreateReport" src="images/lookup.gif" border="0"></td>
				</tr>		
			</cfform>
		</table>
<cfelse>
	<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="4" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Aging Receivables Reports</font></th>
		</tr>
	</cfoutput>
	<cfif SessionDates.Recordcount GT Mrow>
			<tr>
				<form method="post" action="aging.cfm">
					<cfoutput>
						<input type="hidden" name="obdir" value="#obdir#">
					</cfoutput>
					<td colspan="4"><select name="Page" onchange="submit()">
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
							<cfset DispStr = LSDateFormat(SessionDates.ReportDate[ArrayPoint], '#DateMask1#')>
							<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
						</cfloop>
					</select></td>
				</form>
			</tr>
	</cfif>
	<cfoutput>
		<tr>
			<form method="post" action="aging.cfm">
				<td colspan="4" align="right"><input type="image" name="AddNew" src="images/addnew.gif" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>View</th>
			<form method="post" action="aging.cfm">
				<cfif obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" name="obid" value="ReportDate" onclick="submit()" id="col1"><label for="col1">Report Date</label></th>
				<th>Report</th>
			</form>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" action="aging2.cfm" name="EditInfo">
		<cfset LoopCount = 0>
		<cfoutput query="SessionDates" startrow="#Srow#" maxrows="#Maxrows#">
			<tr>
				<th bgcolor="#tdclr#"><input type="radio" name="DispReport" value="#ReportID#" onclick="submit()"></th>
				<td bgcolor="#tbclr#">#LSDateFormat(ReportDate, '#DateMask1#')#</td>
				<td bgcolor="#tbclr#">#ReportName#&nbsp;</td>
				<cfif (AdminID Is MyAdminID) OR (GetOpts.SUserYN Is 1)>
					<cfset LoopCount = LoopCount + 1>
					<th bgcolor="#tdclr#"><input type="checkbox" value="#ReportID#" name="DelSelected" onClick="SetValues(#ReportID#,this)"></th>
				</cfif>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#LoopCount#">
		</cfoutput>
	</form>
		<cfoutput>
			<tr>
				<form method="post" name="PickDelete" action="aging.cfm" onSubmit="return confirm('Click OK to confirm deleting the selected reports.')">
					<input type="hidden" name="DelThese" value="0">
					<th colspan="4"><input type="image" name="DeleteReports" src="images/delete.gif" border="0"></th>
				</form>
			</tr>
		</cfoutput>
		<cfif SessionDates.Recordcount GT Mrow>
			<tr>
				<form method="post" action="aging.cfm">
					<cfoutput>
						<input type="hidden" name="obdir" value="#obdir#">
					</cfoutput>
					<td colspan="3"><select name="Page" onchange="submit()">
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
							<cfset DispStr = LSDateFormat(SessionDates.ReportDate[ArrayPoint], '#DateMask1#')>
							<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
						</cfloop>
					</select></td>
				</form>
			</tr>
		</cfif>
	</table>
</cfif>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   