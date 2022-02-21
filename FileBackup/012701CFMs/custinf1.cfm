<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is the customer lookup information screen. --->
<!---	4.0.1 01/23/01 Added new Edit Misc Button
		4.0.0 07/29/99 
		3.4.0 06/03/99 Fixed a bug when selecting firstparam of email and secondparam of login.
		3.2.0 09/08/98
		3.1.2 08/14/98 Fixed so that the Extra Info fields labels show up
		3.1.1 07/30/98 Fixed so that the Change Plan button does not show when an account is deactivated.
		3.1.0 07/15/98 --->
<!--- custinf1.cfm --->

<cfif IsDefined("HTTP_REFERER")>
	<cfset TheReferer = GetFileFromPath(HTTP_Referer)>
<cfelse>
	<cflocation url="admin.cfm" addtoken="no">
</cfif>
<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="OneP" datasource="#pds#">
	SELECT A.* 
	FROM Accounts A 
	WHERE A.AccountID = #AccountID# 
	<cfif GetOpts.SUserYN Is 0>
	AND A.SalesPersonID IN 
		(SELECT SalesID 
		 FROM SalesAdm 
		 WHERE AdminID = #MyAdminID#) 
	</cfif>
	AND A.AccountID IN 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE POPID In 
			(SELECT POPID 
			 FROM POPAdm 
			 WHERE AdminID = #MyAdminID#) 
		)
	AND A.AccountID IN 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE PlanID In 
			(SELECT PlanID 
			 FROM PlanAdm 
			 WHERE AdminID = #MyAdminID#) 
		)
	AND A.AccountID IN 
		(SELECT AccountID 
		 FROM AccntPlans 
		 WHERE EMailDomainID In 
		 	(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		 UNION 
		 SELECT AccountID 
		 FROM AccntPlans 
		 WHERE FTPDomainID IN 
		 	(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		 UNION
		 SELECT AccountID 
		 FROM AccntPlans 
		 WHERE AuthDomainID IN 
		 	(SELECT DomainID 
			 FROM DomAdm 
			 WHERE AdminID = #MyAdminID#) 
		)
</cfquery>
<cfif OneP.Recordcount Is 0>
	<cfquery name="ClearResults" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = 4 
	</cfquery>
	<cflocation addtoken="no" url="lookup.cfm">
</cfif>
<cfif OneP.CancelYN Is 1>
	<cfquery name="GetReason" datasource="#pds#">
		SELECT CxReason
		FROM LU_CxReason
		WHERE CxReasonID = #OneP.CancelReason#
	</cfquery>
</cfif>
<cfif OneP.DeactivatedYN Is 1>
	<cfquery name="GetDeactReason" datasource="#pds#">
		SELECT CxReason
		FROM LU_CxReason
		WHERE CxReasonID = #OneP.DeactReason#
	</cfquery>
</cfif>
<cfquery name="CurrentPlans" datasource="#pds#">
	SELECT P.PlanID, P.PlanDesc, A.NextDueDate, A.AccntPlanID, A.PayBy, A.PostalRem, L.POPName 
	FROM Plans P, AccntPlans A, POPs L 
	WHERE P.PlanID = A.PlanID 
	AND A.POPID = L.POPID 
	AND A.AccountID = #OneP.AccountID#
</cfquery>
<cfquery name="SalesPerson" datasource="#pds#">
	SELECT A.FirstName, A.LastName 
	FROM Accounts A, Admin S 
	WHERE A.AccountID = S.AccountID 
	AND S.AdminID = 
	<cfif OneP.SalesPersonID Is "">
		0
	<cfelse>
		#OneP.SalesPersonID#
	</cfif>
</cfquery>
<cfquery name="AdminCheck" datasource="#pds#">
	SELECT AdminID 
	FROM Admin 
	WHERE AccountID = #OneP.AccountID#
</cfquery>
<cfquery name="GroupCheck" datasource="#pds#">
	SELECT BillTo, MultiID, PrimaryID 
	FROM Multi 
	WHERE AccountID = #OneP.AccountID# 
</cfquery>
<cfquery name="MiscCheck" datasource="#pds#">
	SELECT WizID 
	FROM WizardSetup 
	WHERE ActiveYN = 1 
	AND BOBFieldName <> 'WaiveA' 
	AND BOBFieldName <> 'WaiveAReason' 
	AND BOBFieldName <> 'SelectPlan' 
	AND BOBFieldName <> 'UserInfo'
	AND BOBFieldName <> 'contactemail'
	AND BOBFieldName <> 'postalinv' 
	AND BOBFieldName <> 'taxfree' 
	AND BOBFieldName <> 'creditcard' 
	AND BOBFieldName <> 'checkdebit' 
	AND BOBFieldName <> 'porder' 
	AND BOBFieldName <> 'checkcash' 
	AND PageNumber IN (3,4,5) 
</cfquery>
<cfset PasswordShow = 0>
<cfif GetOpts.ViewCPasswd Is "1">
	<cfset PasswordShow = 1>
</cfif>
<cfif AdminCheck.RecordCount GT 0>
	<cfset PasswordShow = 0>
</cfif>
<cfif GetOpts.ViewAPasswd Is "1">
	<cfset PasswordShow = 1>
</cfif>
<cfquery name="CustBal" datasource="#pds#">
	SELECT Sum(Debit - Credit) As Balance 
	FROM Transactions 
	WHERE AccountID = #OneP.AccountID#
</cfquery>
<cfif GroupCheck.RecordCount GT 0>
	<cfquery name="GroupBal" datasource="#pds#">
		SELECT Sum(Debit - Credit) As Balance 
		FROM Transactions 
		WHERE AccountID = 
			(SELECT PrimaryID 
			 FROM Multi 
			 WHERE AccountID = #OneP.AccountID#)
	</cfquery>
</cfif>
<cfquery name="CustomLinks" datasource="#pds#">
	SELECT P.CustLinkURL, P.CustLinkGraphic, P.PlanDesc, P.PlanID 
	FROM Plans P, AccntPlans A
	WHERE P.PlanID = A.PlanID 
	AND A.AccountID = #OneP.AccountID# 
	AND P.CustLinkURL Is Not Null 
	GROUP BY P.CustLinkURL, P.CustLinkGraphic, P.PlanDesc, P.PlanID 
	ORDER BY P.PlanDesc 
</cfquery>
<cfquery name="GetScheduleInfo" datasource="#pds#">
	SELECT * 
	FROM AutoRun 
	WHERE AccountID = #OneP.AccountID# 
	AND (DoAction = 'Rollback' 
	OR DoAction = 'Cancel' 
	OR DoAction = 'Reactivate' 
	OR DoAction = 'Deactivate')
</cfquery>
<cfquery name="GetAllScheds" datasource="#pds#">
	SELECT * 
	FROM AutoRun 
	WHERE AccountID = #OneP.AccountID#
</cfquery>
<cfquery name="GetAllAuths" datasource="#pds#">
	SELECT AuthID 
	FROM AccountsAuth 
	WHERE AccountID = #OneP.AccountID# 
</cfquery>
<!--- BOB History --->
<cfif Not IsDefined("NoBOBHist")>
	<cfquery name="BOBHist" datasource="#pds#">
		INSERT INTO BOBHist
		(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
		VALUES 
		(Null,#OneP.AccountID#,#MyAdminID#, #Now()#,'Page Access',
		'#StaffMemberName.FirstName# #StaffMemberName.LastName# accessed the customer info page for #OneP.FirstName# #OneP.LastName#.')
	</cfquery>
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
<title>#OneP.FirstName# #OneP.LastName#</title>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!--  
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
// -->
</script>
</head>
<cfinclude template="coolsheet.cfm">
<body #colorset# onload="self.focus()">
</cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#OneP.FirstName# #OneP.LastName#</font></th>
	</tr>
	<cfif IsDefined("GroupBal") AND (GroupBal.Balance Is NOT "")>
		<tr valign="top">
			<td colspan="2" valign="top" align="center" bgcolor="#tbclr#">Group Account <cfif GroupBal.Balance GT 0>Currently Owes: #LSCurrencyFormat(GroupBal.Balance)#<cfelse>Current Credit: #LSCurrencyFormat(ABS(GroupBal.Balance))#</cfif></td>
		</tr>
	</cfif>
	<cfif (CustBal.Balance Is Not "") AND (GroupCheck.RecordCount Is 0)>
		<tr valign="top">
			<td colspan="2" valign="top" align="center" bgcolor="#tbclr#"><cfif CustBal.Balance GT 0>Currently Owes: #LSCurrencyFormat(CustBal.Balance)#<cfelse>Current Credit: #LSCurrencyFormat(ABS(CustBal.Balance))#</cfif></td>
		</tr>
	</cfif>
	<cfif OneP.CancelYN Is "1">
		<tr>
			<td colspan="2" bgcolor="#tbclr#">#GetReason.CxReason#</td>
		</tr>
	<cfelseif (OneP.DeactivatedYN Is "1") AND (OneP.CancelYN Is "0")>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">#OneP.DeactReason#</td>
		</tr>
	</cfif>
</cfoutput>
	<cfif GetScheduleInfo.RecordCount GT 0>
		<cfsetting enablecfoutputonly="yes">
			<cfloop query="GetScheduleInfo">
				<cfif DoAction Is "Rollback">
					<cfquery name="GetCurrentPlan" datasource="#pds#">
						SELECT PlanDesc 
						FROM Plans 
						WHERE PlanID = 
									(SELECT PlanID 
									 FROM AccntPlans 
									 WHERE AccntPlanID = #AccntPlanID#)
					</cfquery>
					<cfquery name="getnewplan" datasource="#pds#">
						SELECT PlanDesc 
						FROM Plans 
						WHERE PlanID = #PlanID# 
					</cfquery>
					<cfoutput>
						<tr>
							<td colspan="2" bgcolor="#tbclr#">#GetCurrentPlan.PlanDesc# is scheduled to change to<br>#GetNewPlan.PlanDesc# on #LSDateFormat(WhenRun, '#datemask1#')#.</td>
						</tr>
					</cfoutput>
				<cfelseif DoAction Is "Cancel" AND AccntPlanID Is 0>
					<cfoutput>
						<tr>	
							<td colspan="2" bgcolor="#tbclr#">This account is scheduled to be cancelled on #LSDateFormat(WhenRun, '#datemask1#')#.</td>
						</tr>
					</cfoutput>					
				<cfelseif (DoAction Is "Deactivate") AND (AccntPlanID Is 0)>
					<cfoutput>
						<tr>	
							<td colspan="2" bgcolor="#tbclr#">This account is scheduled to be deactivated on #LSDateFormat(WhenRun, '#datemask1#')#.</td>
						</tr>
					</cfoutput>
				<cfelseif DoAction Is "Reactivate">
					<cfoutput>
						<tr>	
							<td colspan="2" bgcolor="#tbclr#">This account is scheduled to be reactivated on #LSDateFormat(WhenRun, '#datemask1#')#.</td>
						</tr>
					</cfoutput>
				</cfif>
			</cfloop>
		<cfsetting enablecfoutputonly="no">
	</cfif>
	<tr valign="top">
		<!--- Customer Management Buttons --->
<cfoutput>
		<td bgcolor="#tdclr#">
			<table border="0">
				<cfif GetOpts.MenuLev Is 1>
					<tr>
						<form method="post" action="payment.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" src="images/pmthist2.gif" border="0"></td>
						</form>
					</tr>
					<tr>
						<form method="post" action="adjustment.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" src="images/pmthist3.gif" border="0"></td>
						</form>
					</tr>
				</cfif>
				<cfif GetOpts.EditInfo Is "1">
					<tr>
						<FORM METHOD=POST ACTION="editcust.cfm">
							<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
							<td><input type="image" border="0" src="images/custinf1.gif"></td>
						</form>
					</tr>
				</cfif>
				<cfif (GetOpts.EditMisc Is "1") AND (MiscCheck.RecordCount GT 0)>
					<tr>
						<form method="post" action="editmisc.cfm">
							<input type="Hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="Image" border="0" src="images/custmisc.gif"></td>
						</form>
					</tr>
				</cfif>
				<cfif (GetOpts.EditPay Is "1") AND (OneP.CancelYN Is 0)>
					<tr>
						<FORM METHOD=POST ACTION="editcard.cfm">
							<input type="hidden" name="accountid" value="#OneP.AccountID#">
							<td><input type="image" border="0" src="images/custinf3.gif"></td>
						</form>
					</tr>
		   	</cfif>
				<cfif (GetOpts.ChPass Is "1") AND (OneP.CancelYN Is "0") AND (OneP.DeactivatedYN Is "0")>
					<tr>
						<FORM METHOD=POST ACTION="pass.cfm">
							<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
							<td><input type="image" border="0" src="images/custinf2.gif"></td>
						</form>
					</tr>
				</cfif>
				<cfif (GetAllScheds.Recordcount GT 0) AND (GetOpts.SchEvent Is 1)>
					<tr>
						<form method="post" action="scheduled2.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" border="0" name="Sched" src="images/schedevent.gif"></td>
						</form>
					</tr>	
				</cfif>
				<cfif GetOpts.PayHist is "1">
					<tr>
						<FORM METHOD=POST ACTION="pmthist.cfm">
							<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
							<td><input type="image" border="0" src="images/custinf4.gif"></td>
						</FORM>
					</tr>
				</cfif>
				<cfif GetOpts.SessHist Is "1">
					<!--- Add a check for AccountsAuth --->
					<cfif GetAllAuths.Recordcount GT 0>
						<tr>
							<FORM METHOD=POST ACTION="sesselect.cfm" onsubmit="MsgWindow()">
								<INPUT type="hidden" name="accountid" value="#OneP.AccountID#">
								<td><input type="image" border="0" src="images/custinf6.gif"></td>
							</FORM>
						</tr>
					</cfif>
				</cfif>
				<cfif GetOpts.SuppHist Is "1">
					<tr>
						<FORM METHOD=POST ACTION="support.cfm">
							<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
							<td><input type="image" border="0" src="images/custinf5.gif"></td>
						</FORM>
					</tr>
				</cfif>
				<cfif (GetOpts.BOBHist Is 1) AND (AdminCheck.RecordCount Is 0)>
					<tr>
						<form method="post" action="bobhist.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" src="images/bobhist.gif" border="0"></td>
						</form>
					</tr>
				<cfelseif (GetOpts.BOBAHist Is 1) AND (AdminCheck.RecordCount GT 0)>
					<tr>
						<form method="post" action="bobhist.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" src="images/bobhist.gif" border="0"></td>
						</form>
					</tr>
				</cfif>
				<cfif (GetOpts.ChPlan Is 1) AND (OneP.CancelYN Is 0)>
					<tr>
						<form method="post" action="accntmanage.cfm">
							<input type="hidden" name="AccountID" value="#OneP.AccountID#">
							<td><input type="image" src="images/acmanage.gif" border="0"></td>
						</form>
					</tr>
				</cfif>
				<cfif GetOpts.ViewOther Is "1" AND (OneP.CancelYN Is 0)>
					<tr>
						<FORM METHOD=POST ACTION="group.cfm">
							<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
							<td><input type="image" border="0" src="images/groups.gif"></td>
						</FORM>
					</tr>
				</cfif>
				<cfif GetOpts.DeactC Is "1" AND (OneP.CancelYN Is 0)>
					<cfif OneP.DeactivatedYN Is 0>
						<tr>
							<FORM METHOD=POST ACTION="deactivate.cfm">
								<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
								<td><input name="deactivate" type="image" border="0" src="images/custinf11.gif"></td>
							</FORM>
						</tr>
					</cfif>
				</cfif>
				<cfif GetOpts.ReactAcnt Is "1" AND (OneP.CancelYN Is 0)>
					<cfif OneP.DeactivatedYN Is 1>
						<tr>
							<form method="post" action="reactivate.cfm">
								<input type="Hidden" name="AccountID" value="#OneP.AccountID#">
								<td><input name="reactivate" type="image" border="0" src="images/custinf11b.gif"></td>
							</form>
						</tr>
					</cfif>
		      </cfif>
				<cfif (GetOpts.CancelC Is "1") AND (OneP.CancelYN Is 0)>
					<cfif (GroupCheck.BillTo Is 0) OR (GroupCheck.BillTo Is "")>
						<tr>
							<FORM METHOD=POST ACTION="custcan.cfm">
								<INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#>
								<td><input type="image" border="0" src="images/custinf12.gif"></td>
							</FORM>
						</tr>
					</cfif>
			   </cfif>
</cfoutput>
				<cfif (GetOpts.CancelA Is "1") AND (OneP.CancelYN Is "1")>
					<tr>
						<FORM METHOD=POST ACTION="cancel.cfm">
							<cfoutput><INPUT TYPE=HIDDEN NAME="AccountID" VALUE=#OneP.AccountID#></cfoutput>
							<td><input type="image" border="0" src="images/delete.gif"></td>
						</FORM>
					</tr>
				</cfif>
				<cfloop query="CustomLinks">
					<tr>
						<cfoutput>
							<form method="post" action="#CustLinkURL#">
								<input type="hidden" name="AccountID" value="#OneP.AccountID#">
								<input type="hidden" name="PlanID" value="#PlanID#">
								<td><input type="image" src="images/#CustLinkGraphic#" name="CustLink#PlanID#" border="0"></td>
							</form>
						</cfoutput>
					</tr>
				</cfloop>
			</table>		
		</td>
		<!--- Customer Info Section --->
		<cfoutput><td bgcolor="#tbclr#"></cfoutput>
			<cfoutput query="OneP">		
				<table bgcolor="#tbclr#" border="1">
					<tr>
						<td bgcolor="#thclr#" align=right valign=top>Address:</td>	
						<td>#address1#<br>
						<cfif Trim(Address2) Is Not "">#Address2#<br></cfif>
						<cfif Trim(Address3) Is Not "">#Address3#<br></cfif></td>
					</tr>
					<tr>
						<td bgcolor="#thclr#" align="right" valign="top">City</td>
						<td><cfif Trim(City) Is "">&nbsp;<cfelse>#City#</cfif></td>
					</tr>
					<tr>
						<cfif International Is 0>
							<td bgcolor="#thclr#" align=right valign="top">State Zip</td>
						<cfelse>
							<td bgcolor="#thclr#" align=right valign="top">Prov Post Code</td>
						</cfif>
						<td>#state#&nbsp;#zip#</td>
					</tr>
					<cfif International Is 1>
						<tr>
							<td bgcolor="#thclr#" align="right" valign="top">Country</td>
							<td>#Country#</td>
						</tr>
					</cfif>
					<tr>
						<td bgcolor="#thclr#" align=right>Home Phone</td>
						<td><cfif Trim(dayphone) Is "">&nbsp;<cfelse>#dayphone#</cfif></td>
					</tr>
				   <cfif Trim(evephone) Is Not "">
						<tr>
							<td bgcolor="#thclr#" align=right>Work Phone</td>
							<td>#evephone#</td>
						</tr>
					</cfif>
					<cfif Trim(fax) Is Not "">
						<tr>
							<td bgcolor="#thclr#" align=right>Fax</td>
							<td>#fax#</td>
						</tr>
					</cfif>
				   <cfif Trim(company) Is Not "">
						<tr>
							<td bgcolor="#thclr#" align=right>Company</td>
							<td>#company#</td>
						</tr>
					</cfif>
					<tr>
						<td bgcolor="#thclr#" align=right>Start Date</td>
						<td>#LSDateFormat(StartDate, '#datemask1#')#</td>
					</tr>
					<cfif OneP.DeactivatedYN Is 1>
						<tr>
							<td bgcolor="#thclr#" align="right">Deactivate Date</td>
							<td>#LSDateFormat(DeactDate, '#datemask1#')#</td>
						</tr>
					</cfif>
					<cfif OneP.CancelYN Is "1">
						<tr>
							<td bgcolor="#thclr#" align="right">Cancel Date</td>
							<td>#LSDateFormat(CancelDate, '#datemask1#')#</td>
						</tr>
					</cfif>
					<tr>
						<td bgcolor="#thclr#" align=right>Group Account</td>
						<td>#YesNoFormat(GroupCheck.Recordcount)#</td>
					</tr>
					<cfif OneP.CancelYN Is "0">
						<tr>
							<td bgcolor="#thclr#" align="right">gBill Login</td>
							<td>#Login#</td>
						</tr>
					</cfif>
	 			<!---	<cfif ((GetOpts.ViewCPasswd Is "1") OR (GetOpts.ViewAPasswd Is 1)) AND (OneP.CancelYN Is "0")>
						<tr>
							<td bgcolor="#thclr#" align="right">gBill Password</td>
							<td>#Password#</td>
						</tr>					
					</cfif> --->
					<tr>
						<td bgcolor="#thclr#" align=right>User ID</td>
						<td>#AccountID#</td>
					</tr>
			</cfoutput>
					<cfif CurrentPlans.RecordCount GT 0>
						<cfif OneP.CancelYN Is 0>
							<cfoutput>
								<tr>
									<th colspan="2" bgcolor="#thclr#">Current Plans</th>
								</tr>
							</cfoutput>
						</cfif>
						<cfsetting enablecfoutputonly="yes">
						<cfloop query="CurrentPlans">
							<cfif PlanID Is Not DelAccount>
								<cfoutput>
									<tr>
										<th bgcolor="#tdclr#" colspan="2">#PlanDesc#</td>
									</tr>
									<tr>
										<td align="right">POP</td>
										<td>#POPName#</td>
									</tr>
									<tr>
										<td align="right">Next Due Date</td>
										<td>#LSDateFormat(NextDueDate, '#DateMask1#')#</td>
									</tr>
									<tr>
										<td align=right>Payment</td>
										<td><cfif PayBy Is "cc">Credit Card
											<cfelseif PayBy Is "ck">Check
											<cfelseif PayBy Is "po">Purchase Order
											<cfelseif PayBy Is "cd">Check Debit
											<cfelseif PayBy Is "ca">Cash
										</cfif></td>
									</tr>
									<tr>
										<td align=right>Postal Reminder</td>
										<td>#YesNoFormat(PostalRem)#</td>
									</tr>
								</cfoutput>
							</cfif>
						</cfloop>
						<cfsetting enablecfoutputonly="no">
					</cfif>
				</table>
		</td>
	</tr>
	<cfif Trim(OneP.Notes) Is Not "">
		<tr>
			<cfoutput>
				<td colspan="2" bgcolor="#tbclr#">#OneP.Notes#</td>
			</cfoutput>
		</tr>
	</cfif>
	<cfif OneP.SalesPersonID Is Not "">
		<tr>
			<cfoutput>
				<td colspan="2" bgcolor="#tbclr#"><font size=-1>Salesperson #SalesPerson.FirstName# #SalesPerson.LastName#</td>
			</cfoutput>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
       