<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the payment history for an individual account.--->
<!--- 4.0.2 01/25/01 Added the customer name to the end of the Memo when displaying the history.
		4.0.1 11/28/00 Fixed error when clicking on the columns to sort the history
		4.0.0 
		3.4.0 --->
<!--- pmhist.cfm --->
<cfif GetOpts.PayHist Is 1>
	<cfset SecurePage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfquery name="GetName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfif (IsDefined("SendMail.x")) AND (Not IsDefined("PaymentHistory"))>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT AccountID 
		FROM EMailOutgoing 
		WHERE LetterID = 24 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfif CheckFirst.Recordcount GT 0>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM EMailOutgoing 
			WHERE LetterID = 24 
			AND AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfquery name="GetEMailInfo" datasource="#pds#">
		SELECT FirstName, LastName, AccountID, Company 
		FROM Accounts 
		WHERE AccountID In  
			(SELECT AccountID 
			 FROM AccountsEMail 
			 WHERE EMail = '#EMailAddr#')
	</cfquery>
	<cfif GetEMailInfo.Recordcount Is 0>
		<cfquery name="GetEMailInfo" datasource="#pds#">
			SELECT FirstName, LastName, AccountID, Company 
			FROM Accounts 
			WHERE AccountID = #AccountID# 
		</cfquery>
	</cfif>
	<cfif GetEMailInfo.Recordcount Is Not 1>
		<cfquery name="InsLetter" datasource="#pds#">
			INSERT INTO EMailOutgoing 
			(AccountID, LastName, FirstName, Company, EMailAddr, 
			 EMailDate, AdminID, LetterID, SelectedLetter, CreateDate) 
			VALUES 
			(#AccountID#, <cfif GetEMailInfo.LastName Is "">Null<cfelse>'#GetEMailInfo.LastName#'</cfif>, 
			 <cfif GetEMailInfo.FirstName Is "">Null<cfelse>'#GetEMailInfo.FirstName#'</cfif>, 
			 <cfif GetEMailInfo.Company Is "">Null<cfelse>'#GetEMailInfo.Company#'</cfif>, 
			 '#EMailAddr#', #Now()#, #MyAdminID#, 24, #EMailLetterID#, #Now()#)
		</cfquery>
		<cfset LetterID = 24>
		<cfset PaymentHistory = 1>
		<cfsetting enablecfoutputonly="no">
		<cfinclude template="emailsend.cfm">
	</cfif>
</cfif>
<cfif GetOpts.DelTrans Is 1>
	<cfif IsDefined("DelSelected.x") AND IsDefined("RemoveSelected")>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM TransActions 
			WHERE TransID In (#RemoveSelected#)
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,#AccountID#,#MyAdminID#, #Now()#,'Deleted Transactions','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted transactions for #GetName.FirstName# #GetName.LastName#.')
			</cfquery>
		</cfif>
	</cfif>
</cfif>

<cfquery name="CheckForMulti" datasource="#pds#">
	SELECT MultiID 
	FROM Multi 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="GetPrimary" datasource="#pds#">
	SELECT FirstName, LastName, AccountID 
	FROM Accounts 
	WHERE AccountID = 
		(SELECT PrimaryID 
		 FROM Multi 
		 WHERE AccountID = #AccountID#)
</cfquery>
<cfquery name="GetPrimaryEMail" datasource="#pds#">
	SELECT EMail 
	FROM AccountsEMail 
	WHERE AccountID = 
		(SELECT PrimaryID 
		 FROM Multi 
		 WHERE AccountID = #AccountID#)
	AND PrEMail = 1 
</cfquery>
<cfparam name="page" default="1">
<cfparam name="obid" default="DateTime1">
<cfparam name="obdir" default="desc">
<cfquery NAME="GetTotals" datasource="#pds#">
	SELECT Sum(credit-debit) AS GrndTot
	FROM Transactions 
	WHERE AccountID IN
   <cfif CheckForMulti.Recordcount Is 1>
		(SELECT AccountID 
		 FROM Multi 
		 WHERE BillingID = 
		 	(SELECT BillingID 
			 FROM Multi 
			 WHERE AccountID = #AccountID#) 
		) 
   <cfelse>
		(#AccountID#) 
   </cfif>
</cfquery>
<cfquery NAME="GetInfo" datasource="#pds#">
	SELECT * 
	FROM Transactions 
	WHERE AccountID in
   <cfif CheckForMulti.Recordcount Is 1>
		(SELECT AccountID 
		 FROM Multi 
		 WHERE BillingID = 
		 	(SELECT BillingID 
			 FROM Multi 
			 WHERE AccountID = #AccountID#) 
		) 
   <cfelse>
		(#AccountID#) 
   </cfif>
	ORDER BY #obid# #obdir# 
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = GetInfo.Recordcount>
<cfelse>
	<cfset Srow = (Page*Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(GetInfo.Recordcount/Mrow)>

<cfif GetTotals.GrndTot Is "">
	<cfset GrandTotal = 0>
<cfelse>
	<cfset GrandTotal = GetTotals.GrndTot>
</cfif>
<cfset CurRow = tbclr>
<cfif GetOpts.DelTrans Is 1>
	<cfset HowWide = 8>
<cfelse>
	<cfset HowWide = 7>
</cfif>
<cfquery name="GetLetters" datasource="#pds#">
	SELECT IntID, IntDesc 
	FROM Integration 
	WHERE ActiveYN = 1 
	AND Action = 'Letter' 
	AND IntID In 
		(SELECT IntID 
		 FROM LetterAdm 
		 WHERE AdminID = #MyAdminID#) 
	<cfif GetPrimaryEMail.Recordcount Is 0>
		AND IntID = 0 
	</cfif>
	<cfif GetOpts.SendEmail Is 0>
		AND IntID = 0 
	</cfif>
	ORDER BY IntDesc 
</cfquery>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Payment History</TITLE>
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
<form method="post" action="custinf1.cfm">
	<input type="image" src="images/returncust.gif" name="return" border="0">
	<input type="hidden" name="accountid" value="#AccountID#">
</form>
<CENTER>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Financial History For #GetName.FirstName# #GetName.LastName#</font></th>
	</tr>
	<cfif CheckForMulti.Recordcount GT 0>
		<tr>
			<th colspan="#HowWide#" align="right" bgcolor="#thclr#">Group Contact: <a href="custinf1.cfm?accountid=#GetPrimary.AccountID#" <cfif getopts.OpenNew Is 1>target="_blank"</cfif> >#GetPrimary.FirstName# #GetPrimary.Lastname#</a></th>
		</tr>
	</cfif>
	<tr>
		<th colspan="#HowWide#" align="right" bgcolor="#thclr#">Current Balance<cfif GrandTotal lt 0> Owes:<cfelseif GrandTotal Is 0>:<cfelse> Credit:</cfif> #LSCurrencyFormat(abs(GrandTotal))#</th>
	</tr>
</cfoutput>
<cfif GetInfo.Recordcount GT 0>
	<cfif GetInfo.Recordcount GT Mrow>
		<tr>
			<form method="post" action="pmthist.cfm">
			<cfoutput><td colspan="#HowWide#"></cfoutput><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "DateTime1">
						<cfset DispStr = LSDateFormat(GetInfo.DateTime1[ArrayPoint], '#DateMask1#')>
					<cfelseif obid Is "MemoField">
						<cfset DispStr = GetInfo.MemoField[ArrayPoint]>
					<cfelseif obid Is "Credit">
						<cfset DispStr = LSCurrencyFormat(ABS(GetInfo.Credit[ArrayPoint]))>
					<cfelseif obid Is "Debit">
						<cfset DispStr = LSCurrencyFormat(ABS(GetInfo.Debit[ArrayPoint]))>
					<cfelseif obid Is "EnteredBy">
						<cfset DispStr = GetInfo.EnteredBy[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GetInfo.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="hidden" name="AccountID" value="#AccountID#">
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
			</cfoutput>
			</form>
		</tr>
	</cfif>
	<cfif GetLetters.Recordcount GT 0>
		<cfoutput>
			<tr bgcolor="#tdclr#" valign="top">
				<form method="post" action="pmthist.cfm" onsubmit="MsgWindow()">
					<td colspan="#HowWide#">
						<table border="0">
		</cfoutput>
							<tr>
								<td><select name="EMailLetterID">
									<cfoutput query="GetLetters">
										<option value="#IntID#">#IntDesc#
									</cfoutput>
								</select></td>
								<td><input type="image" src="images/sendemail.gif" name="SendMail" border="0"></td>
								<cfoutput><td><input type="text" name="EMailAddr" value="#GetPrimaryEMail.EMail#" size="25"></td></cfoutput>
							</tr>
						</table>
					</td>
					<cfoutput>
						<input type="hidden" name="AccountID" value="#AccountID#">
						<input type="hidden" name="obid" value="#obid#">
						<input type="hidden" name="obdir" value="#obdir#">
						<input type="hidden" name="page" value="#page#">
					</cfoutput>
				</form>
			</tr>
	</cfif>
	<cfoutput>
		<tr bgcolor="#thclr#">
			<form method="post" action="pmthist.cfm">
				<cfif obid Is "DateTime1" AND obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" <cfif obid Is "DateTime1">checked</cfif> name="obid" value="DateTime1" id="Col1" onclick="submit()"><label for="Col1">Date</label></th>
				<input type="hidden" name="accountid" value="#AccountID#">
			</form>
			<form method="post" action="pmthist.cfm">
				<cfif obid Is "MemoField" AND obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" <cfif obid Is "MemoField">checked</cfif> name="obid" value="MemoField" id="Col5" onclick="submit()"><label for="Col5">Memo</label></th>
				<input type="hidden" name="accountid" value="#AccountID#">
			</form>
			<form method="post" action="pmthist.cfm">
				<cfif obid Is "Credit" AND obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" <cfif obid Is "Credit">checked</cfif> name="obid" value="Credit" id="Col2" onclick="submit()"><label for="Col2">Credit</label></th>
				<input type="hidden" name="accountid" value="#AccountID#">
			</form>
			<form method="post" action="pmthist.cfm">
				<cfif obid Is "Debit" AND obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" <cfif obid Is "Debit">checked</cfif> name="obid" value="Debit" id="Col3" onclick="submit()"><label for="Col3">Debit</label></th>
				<input type="hidden" name="accountid" value="#AccountID#">
			</form>
			<th>Paid</th>
			<th>Pay Method</th>
			<form method="post" action="pmthist.cfm">
				<cfif obid Is "EnteredBy" AND obdir Is "asc">
					<input type="hidden" name="obdir" value="desc">
				<cfelse>
					<input type="hidden" name="obdir" value="asc">
				</cfif>
				<th><input type="radio" <cfif obid Is "EnteredBy">checked</cfif> name="obid" value="EnteredBy" id="Col4" onclick="submit()"><label for="Col4">Entered By</label></th>
				<input type="hidden" name="accountid" value="#AccountID#">
			</form>
			<th>Delete</th>
	</cfoutput>
		</tr>
	<form method="post" action="pmthist.cfm">
		<cfoutput QUERY="GetInfo" startrow="#srow#" maxrows="#maxrows#">
			<tr valign="top" bgcolor="#CurRow#">
				<td>#LSDateFormat(DateTime1, '#datemask1#')#</td>
				<td>#MemoField#-#LastName#, #FirstName#</td>
				<cfif credit gt 0>
					<td ALIGN=right NOWRAP>#LSCurrencyFormat(ABS(Credit))#</td>
				<cfelseif debit lt 0>
					<td ALIGN=right NOWRAP>#LSCurrencyFormat(ABS(Debit))#</td>
				<cfelse>
					<td ALIGN=right NOWRAP>&nbsp;</td>
			   </cfif>
				<cfif credit lt 0>
					<td ALIGN=right NOWRAP>#LSCurrencyFormat(ABS(Credit))#</td>
			   <cfelseif debit gt 0>
					<td ALIGN=right NOWRAP>#LSCurrencyFormat(ABS(Debit))#</td>
				<cfelse>
					<td ALIGN=right NOWRAP>&nbsp;</td>
				</cfif>
				<cfif DebitLeft - CreditLeft Is 0>
					<td>Yes</td>
					<cfset ShowMe = 1>
				<cfelse>
					<td>No</td>
					<cfset ShowMe = 0>
				</cfif>
				<cfif ShowMe Is 0>
					<cfif PlanPayBy Is "CC">
						<td>Credit Card</td>
					<cfelseif PlanPayBy Is "Ck">
						<td>Check</td>
					<cfelseif PlanPayBy Is "CD">
						<td>Check Debit</td>
					<cfelseif PlanPayBy Is "PO">
						<td>PO</td>
					<cfelse>
						<td>&nbsp;</td>
					</cfif>
				<cfelse>
					<td>#PayType#&nbsp;</td>
				</cfif>
				<td>#EnteredBY#<cfif Trim(EnteredBy) Is "">&nbsp;</cfif></td>
				<cfif GetOpts.DelTrans Is 1>
					<th><input type="checkbox" name="RemoveSelected" value="#TransID#"></th>
				</cfif>
			</tr>
			<cfif CurRow Is tbclr>
				<cfset CurRow = tdclr>
			<cfelse>
				<cfset CurRow = tbclr>
			</cfif>
		</cfoutput>
		<cfif GetOpts.DelTrans Is 1>
			<cfoutput>
				<tr>
					<th colspan="#HowWide#"><input type="image" name="DelSelected" src="images/delete.gif" border="0"></th>
				</tr>
				<input type="hidden" name="AccountID" value="#AccountID#">
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
				<input type="hidden" name="page" value="#page#">
			</cfoutput>
		</cfif>
	</form>
	<cfif GetInfo.Recordcount GT Mrow>
		<tr>
			<form method="post" action="pmthist.cfm">
			<cfoutput><td colspan="#HowWide#"></cfoutput><select name="Page" onchange="submit()">
				<cfloop index="B5" from="1" to="#PageNumber#">
					<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
					<cfif obid Is "DateTime1">
						<cfset DispStr = LSDateFormat(GetInfo.DateTime1[ArrayPoint], '#DateMask1#')>
					<cfelseif obid Is "MemoField">
						<cfset DispStr = GetInfo.MemoField[ArrayPoint]>
					<cfelseif obid Is "Credit">
						<cfset DispStr = LSCurrencyFormat(ABS(GetInfo.Credit[ArrayPoint]))>
					<cfelseif obid Is "Debit">
						<cfset DispStr = LSCurrencyFormat(ABS(GetInfo.Debit[ArrayPoint]))>
					<cfelseif obid Is "EnteredBy">
						<cfset DispStr = GetInfo.EnteredBy[ArrayPoint]>
					</cfif>
					<cfoutput><option <cfif B5 Is Page>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
				</cfloop>
				<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GetInfo.Recordcount#</cfoutput>
			</select></td>
			<cfoutput>
				<input type="hidden" name="AccountID" value="#AccountID#">
				<input type="hidden" name="obid" value="#obid#">
				<input type="hidden" name="obdir" value="#obdir#">
			</cfoutput>
			</form>
		</tr>
	</cfif>
</cfif>
</table>
</CENTER>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
 