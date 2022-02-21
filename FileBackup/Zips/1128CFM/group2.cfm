<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/22/99 --->
<!--- group2.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("CommitSel.x")>
	<cfif IsDefined("CancelSched")>
		<cfloop index="B5" list="#CancelSched#">
			<cftransaction>
				<cfquery name="RemoveEvent" datasource="#pds#">
					DELETE FROM AutoRun 
					WHERE AccountID = #B5# 
					AND DoAction IN ('Deactivate','Reactivate','Cancel')
				</cfquery>
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="GetWho" datasource="#pds#">
						SELECT FirstName, LastName 
						FROM Accounts 
						WHERE AccountID = #B5# 
					</cfquery>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,#B5#,#MyAdminID#, #Now()#,'Scheduled Event Deleted','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted a scheduled event for #GetWho.FirstName# #GetWho.LastName#.')
					</cfquery>
				</cfif>
				<cfquery name="CleanUp" datasource="#pds#">
					DELETE FROM MassActions 
					WHERE BillingID = #BillingID# 
					AND AccountID = #B5# 
				</cfquery>
			</cftransaction>
		</cfloop>
	</cfif>
	<cfif IsDefined("Cancel")>
		<cfloop index="B5" list="#Cancel#">
			<cfset MemoReason = Evaluate("Reason#B5#")>
			<cfset WhenRun = Evaluate("RunWhen#B5#")>
			<cfif IsDate(WhenRun)>
				<cfset WhenRun = LSParseDateTime(WhenRun)>
				<cftransaction>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM AutoRun 
						WHERE AccountID = #B5# 
						AND DoAction In ('Deactivate','Reactivate','Cancel')
					</cfquery>
					<cfif CheckFirst.Recordcount GT 0>
						<cfquery name="DelData" datasource="#pds#">
							DELETE FROM AutoRun 
							WHERE AccountID = #B5# 
							AND DoAction In ('Deactivate','Reactivate','Cancel')
						</cfquery>
					</cfif>
					<cfquery name="ScheduleTheEvents" datasource="#pds#">
						INSERT INTO AutoRun 
						(Memo1, WhenRun, DoAction, AccountID, AccntPlanID, PlanID, ScheduledBy)
						VALUES 
						(<cfif Trim(MemoReason) Is "">Null<cfelse>'#MemoReason#'</cfif>, 
						 #WhenRun#, 'Cancel', #B5#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#')
					</cfquery>	
					<cfif Not IsDefined("NoBOBHist")>
						<cfquery name="GetWho" datasource="#pds#">
							SELECT FirstName, LastName 
							FROM Accounts 
							WHERE AccountID = #B5# 
						</cfquery>
						<cfquery name="BOBHist" datasource="#pds#">
							INSERT INTO BOBHist
							(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
							VALUES 
							(Null,#B5#,#MyAdminID#, #Now()#,'Cancel Scheduled','#StaffMemberName.FirstName# #StaffMemberName.LastName# scheduled #GetWho.FirstName# #GetWho.LastName# to be cancelled on #LSDateFormat(WhenRun, '#DateMask1#')#. #MemoReason#')
						</cfquery>
					</cfif>
					<cfquery name="CleanUp" datasource="#pds#">
						DELETE FROM MassActions 
						WHERE BillingID = #BillingID# 
						AND AccountID = #B5#
					</cfquery>
				</cftransaction>
			</cfif>
		</cfloop>
	</cfif>
	<cfif IsDefined("Deact")>
		<cfloop index="B5" list="#Deact#">
			<cfset MemoReason = Evaluate("Reason#B5#")>
			<cfset WhenRun = Evaluate("RunWhen#B5#")>
			<cfif IsDate(WhenRun)>
				<cfset WhenRun = LSParseDateTime(WhenRun)>
				<cftransaction>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM AutoRun 
						WHERE AccountID = #B5# 
						AND DoAction In ('Deactivate','Reactivate','Cancel')
					</cfquery>
					<cfif CheckFirst.Recordcount GT 0>
						<cfquery name="DelData" datasource="#pds#">
							DELETE FROM AutoRun 
							WHERE AccountID = #B5# 
							AND DoAction In ('Deactivate','Reactivate','Cancel')
						</cfquery>
					</cfif>
					<cfquery name="ScheduleTheEvents" datasource="#pds#">
						INSERT INTO AutoRun 
						(Memo1, WhenRun, DoAction, AccountID, AccntPlanID, PlanID, ScheduledBy)
						VALUES 
						(<cfif Trim(MemoReason) Is "">Null<cfelse>'#MemoReason#'</cfif>, 
						 #WhenRun#, 'Deactivate',#B5#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#')
					</cfquery>	
					<cfif Not IsDefined("NoBOBHist")>
						<cfquery name="GetWho" datasource="#pds#">
							SELECT FirstName, LastName 
							FROM Accounts 
							WHERE AccountID = #B5# 
						</cfquery>
						<cfquery name="BOBHist" datasource="#pds#">
							INSERT INTO BOBHist
							(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
							VALUES 
							(Null,#B5#,#MyAdminID#, #Now()#,'Deactivate Scheduled','#StaffMemberName.FirstName# #StaffMemberName.LastName# scheduled #GetWho.FirstName# #GetWho.LastName# to be deactivated on #LSDateFormat(WhenRun, '#DateMask1#')#. #MemoReason#')
						</cfquery>
					</cfif>
					<cfquery name="CleanUp" datasource="#pds#">
						DELETE FROM MassActions 
						WHERE BillingID = #BillingID# 
						AND AccountID = #B5#
					</cfquery>
				</cftransaction>
			</cfif>
		</cfloop>
	</cfif>
	<cfif IsDefined("React")>
		<cfloop index="B5" list="#React#">
			<cfset MemoReason = Evaluate("Reason#B5#")>
			<cfset WhenRun = Evaluate("RunWhen#B5#")>
			<cfif IsDate(WhenRun)>
				<cfset WhenRun = LSParseDateTime(WhenRun)>
				<cftransaction>
					<cfquery name="CheckFirst" datasource="#pds#">
						SELECT AccountID 
						FROM AutoRun 
						WHERE AccountID = #B5# 
						AND DoAction In ('Deactivate','Reactivate','Cancel')
					</cfquery>
					<cfif CheckFirst.Recordcount GT 0>
						<cfquery name="DelData" datasource="#pds#">
							DELETE FROM AutoRun 
							WHERE AccountID = #B5# 
							AND DoAction In ('Deactivate','Reactivate','Cancel')
						</cfquery>
					</cfif>
					<cfquery name="ScheduleTheEvents" datasource="#pds#">
						INSERT INTO AutoRun 
						(Memo1, WhenRun, DoAction, AccountID, AccntPlanID, PlanID, ScheduledBy)
						VALUES 
						(<cfif Trim(MemoReason) Is "">Null<cfelse>'#MemoReason#'</cfif>, 
						 #WhenRun#,  'Reactivate', #B5#, 0, 0, '#StaffMemberName.FirstName# #StaffMemberName.LastName#')
					</cfquery>	
					<cfif Not IsDefined("NoBOBHist")>
						<cfquery name="GetWho" datasource="#pds#">
							SELECT FirstName, LastName 
							FROM Accounts 
							WHERE AccountID = #B5# 
						</cfquery>
						<cfquery name="BOBHist" datasource="#pds#">
							INSERT INTO BOBHist
							(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
							VALUES 
							(Null,#B5#,#MyAdminID#, #Now()#,'Reactivate Scheduled','#StaffMemberName.FirstName# #StaffMemberName.LastName# scheduled #GetWho.FirstName# #GetWho.LastName# to be reactivated on #LSDateFormat(WhenRun, '#DateMask1#')#. #MemoReason#')
						</cfquery>
					</cfif>
					<cfquery name="CleanUp" datasource="#pds#">
						DELETE FROM MassActions 
						WHERE BillingID = #BillingID# 
						AND AccountID = #B5#
					</cfquery>
				</cftransaction>
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM MassActions 
		WHERE BillingID = #BillingID# 
	</cfquery>
</cfif>
<cfif IsDefined("CancelSel.x")>
	<cfquery name="ResetSelections" datasource="#pds#">
		DELETE FROM MassActions 
		WHERE BillingID = #BillingID# 
	</cfquery>
</cfif>
<cfif IsDefined("AddOne")>
	<cfquery name="GetBillingID" datasource="#pds#">
		SELECT BillingID 
		FROM Multi 
		WHERE AccountID = #PrimaryID# 
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT MultiID 
		FROM Multi 
		WHERE AccountID = #SelectID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO Multi 
			(AccountID, BillingID, BillTo, PrimaryID, ViewPrivYN, AddAccntYN) 
			VALUES 
			(#SelectID#, #GetBillingID.BillingID#, 0, #PrimaryID#, 0, 0)			
		</cfquery>
		<cfquery name="UpdTrans" datasource="#pds#">
			UPDATE Transactions SET 
			AccountID = #PrimaryID# 
			WHERE AccountID = #SelectID# 
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("NewGroup")>
	<cfquery name="NewBillID" datasource="#pds#">
		SELECT Max(BillingID) As MaxBID 
		FROM Multi
	</cfquery>
	<cfif NewBillID.MaxBID Is "">
		<cfset BillingID = 1>
	<cfelse>
		<cfset BillingID = NewBillID.MaxBID + 1>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT MultiID 
		FROM Multi 
		WHERE AccountID = #PrimaryID#
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO Multi 
			(AccountID, BillingID, BillTo, PrimaryID, ViewPrivYN, AddAccntYN) 
			VALUES 
			(#PrimaryID#, #BillingID#, 1, #PrimaryID#, 1, 1)
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT MultiID 
		FROM Multi 
		WHERE AccountID = #SelectID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO Multi 
			(AccountID, BillingID, BillTo, PrimaryID, ViewPrivYN, AddAccntYN) 
			VALUES 
			(#SelectID#, #BillingID#, 0, #PrimaryID#, 0, 0)
		</cfquery>
		<cfquery name="UpdTrans" datasource="#pds#">
			UPDATE Transactions SET 
			AccountID = #PrimaryID# 
			WHERE AccountID = #SelectID# 
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("RemoveSelected.x")) AND(IsDefined("DelThese"))>
	<cfquery name="GetBillingID" datasource="#pds#">
		SELECT BillingID 
		FROM Multi 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM Multi 
		WHERE AccountID In (#DelThese#)
	</cfquery>
	<cfquery name="CheckForLast" datasource="#pds#">
		SELECT MultiID 
		FROM Multi 
		WHERE BillingID = #GetBillingID.BillingID# 
	</cfquery>
	<cfif CheckForLast.RecordCount Is 1>
		<cfquery name="CleanUp" datasource="#pds#">
			DELETE FROM Multi 
			WHERE BillingID = #GetBillingID.BillingID#
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT MultiID
		FROM Multi 
		WHERE BillingID In 
			(SELECT BillingID 
			 FROM Multi 
			 WHERE AccountID = #AccountID#) 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfsetting enablecfoutputonly="No">
		<cfinclude template="custinf1.cfm">
		<cfabort>
	</cfif>
</cfif>
<cfif IsDefined("UpdGroupSettings.x")>
	<cfset ThePrimaryID = PrimaryID>
	<cfloop index="B5" from="1" to="#Counter1#">
		<cfset Var2 = Evaluate("ViewPrivYN#B5#")>
		<cfset Var3 = Evaluate("AddAccntYN#B5#")>
		<cfset Var1 = Evaluate("AccountID#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Multi SET 
			ViewPrivYN = #Var2#, 
			AddAccntYN = #Var3# 
			WHERE AccountID = #Var1# 
		</cfquery>
	</cfloop>
	<cfquery name="GetBillingID" datasource="#pds#">
		SELECT BillingID 
		FROM Multi 
		WHERE AccountID = #ThePrimaryID#
	</cfquery>
	<cfquery name="SetPrimary" datasource="#pds#">
		UPDATE Multi SET 
		PrimaryID = #ThePrimaryID#, 
		BillTo = 0 
		WHERE BillingID = #GetBillingID.BillingID# 
	</cfquery>
	<cfquery name="SetPrimID" datasource="#pds#">
		UPDATE Multi SET
		BillTo = 1 
		WHERE AccountID = #ThePrimaryID# 
	</cfquery>
	<cfquery name="UpdTrans" datasource="#pds#">
		UPDATE Transactions SET 
		AccountID = #ThePrimaryID# 
		WHERE AccountID IN 
			(SELECT AccountID 
			 FROM Multi 
			 WHERE PrimaryID = #ThePrimaryID#)
	</cfquery>
</cfif>
<cfif IsDefined("AddTo")>
	<cfquery name="GetGroupInfo" datasource="#pds#">
		SELECT * 
		FROM Multi 
		WHERE BillingID = #BillingID# 
		AND BillTo = 1 
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT MultiID 
		FROM Multi 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO Multi 
			(AccountID, BillingID, BillTo, PrimaryID, ViewPrivYN, AddAccntYN) 
			VALUES 
			(#AccountID#, #BillingID#, 0, #GetGroupInfo.PrimaryID#, 0, 0)
		</cfquery>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Transactions SET 
			AccountID = #GetGroupInfo.PrimaryID# 
			WHERE AccountID In 
				(SELECT AccountID 
				 FROM Multi 
				 WHERE BillingID = #BillingID#)
		</cfquery>
	</cfif>
</cfif>
<cfparam name="page" default="1">
<cfquery name="GroupList" datasource="#pds#">
	SELECT A.FirstName, A.LastName, A.AccountID, M.BillingID, M.BillTo, M.ViewPrivYN, 
	M.AddAccntYN, A.DeactivatedYN, A.CancelYN, Null AS WhenRun, Null AS DoAction 
	FROM Accounts A, Multi M 
	WHERE A.AccountID = M.AccountID 
	AND BillingID = 
		(SELECT BillingID 
		 FROM Multi 
		 WHERE AccountID = #AccountID#) 
	AND A.AccountID Not In 
		(SELECT AccountID 
		 FROM AutoRun 
		 WHERE AccountID IS NOT NULL)
	UNION
	SELECT A.FirstName, A.LastName, A.AccountID, M.BillingID, M.BillTo, M.ViewPrivYN, 
	M.AddAccntYN, A.DeactivatedYN, A.CancelYN, R.WhenRun, R.DoAction 
	FROM Accounts A, Multi M, AutoRun R 
	WHERE A.AccountID = M.AccountID 
	AND A.AccountID = R.AccountID 
	AND BillingID = 
		(SELECT BillingID 
		 FROM Multi 
		 WHERE AccountID = #AccountID#) 
	AND R.DoAction IN ('Deactivate','Reactivate','Cancel')
	ORDER BY M.BillTo desc, A.LastName, A.FirstName 
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = GroupList.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(GroupList.Recordcount/Mrow)>
<cfset ReturnID = AccountID>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Group Account</title>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!-- 
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
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
		<input type="Hidden" name="AccountID" value="#AccountID#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">	
	<tr>
		<th bgcolor="#ttclr#" colspan="8"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Group Account</font></th>
	</tr>
	<tr>
		<form method="post" action="group4.cfm">
			<td align="right" colspan="8"><input type="image" src="images/multisel3.gif" name="AddOne" border="0"></td>
			<input type="hidden" name="AccountID" value="#AccountID#">
		</form>
	</tr>
</cfoutput>
	<cfif GroupList.Recordcount GT Mrow>
		<tr>
			<form method="post" action="group2.cfm">
				<td colspan="8"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
						<cfset DispStr = GroupList.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GroupList.Recordcount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="hidden" name="LoopCount" value="#LoopCount#">
					<input type="hidden" name="Counter1" value="#Counter1#">
					<input type="hidden" name="AccountID" value="#ReturnID#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Primary</th>
		<th>Name</th>
		<th>View Same Domains</th>
		<th>Add Accounts</th>
		<th>Status</th>
		<th colspan="2">Scheduled</th>
		<th>Remove</th>
	</tr>
</cfoutput>
<form method="post" action="group2.cfm" name="EditInfo">
	<cfset LoopCount = 0>
	<cfset Counter1 = 0>
	<cfoutput query="GroupList" startrow="#Srow#" maxrows="#Maxrows#">
		<cfset Counter1 = Counter1 + 1>
		<tr bgcolor="#tdclr#">
			<th><input type="radio" name="PrimaryID" <cfif BillTo Is 1>checked</cfif> value="#AccountID#"></th>
			<td bgcolor="#tbclr#"><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></td>
			<td><input type="radio" <cfif ViewPrivYN Is 1>checked</cfif> name="ViewPrivYN#Counter1#" value="1"> Yes <input type="radio" <cfif ViewPrivYN Is 0>checked</cfif> name="ViewPrivYN#Counter1#" value="0"> No</td>
			<td><input type="radio" <cfif AddAccntYN Is 1>checked</cfif> name="AddAccntYN#Counter1#" value="1"> Yes <input type="radio" <cfif AddAccntYN Is 0>checked</cfif> name="AddAccntYN#Counter1#" value="0"> No</td>
			<cfif CancelYN Is 1>
				<td>Cancelled</td>
			<cfelseif DeactivatedYN Is 1>
				<td>Deactivated</td>
			<cfelse>
				<td>Active</td>
			</cfif>
			<td>#LSDateFormat(WhenRun, '#DateMask1#')#<cfif trim(WhenRun) Is "">&nbsp;</cfif></td>
			<td>#DoAction#<cfif Trim(DoAction) Is "">&nbsp;</cfif></td>
			<cfif BillTo Is 1>
				<th>&nbsp;</th>
			<cfelse>
				<cfset LoopCount = LoopCount + 1>
				<th><input type="checkbox" name="DelSelected" value="#AccountID#" onClick="SetValues(#AccountID#,this)"></th>
			</cfif>
			<input type="hidden" name="AccountID#Counter1#" value="#AccountID#">
		</tr>
	</cfoutput>
	<tr>
		<th colspan="8">
			<table border="0">
				<tr>
					<td><input type="image" src="images/update.gif" name="UpdGroupSettings" border="0"></td>
					<cfoutput>
						<input type="hidden" name="LoopCount" value="#LoopCount#">
						<input type="hidden" name="Counter1" value="#Counter1#">
						<input type="hidden" name="AccountID" value="#ReturnID#">
					</cfoutput>
</form>
<form method="post" action="group5.cfm" name="MassActions">
					<td><input type="Image" name="MassSettings" src="images/mass.gif" border="0"></td>
					<cfoutput>
						<input type="hidden" name="AccountID" value="#ReturnID#">					
						<input type="Hidden" name="BillingID" value="#GroupList.BillingID#">
					</cfoutput>
</form>
<form method="post" action="group2.cfm" name="PickDelete" onSubmit="return confirm('Click Ok to confirm removing the selected customers.')">
					<td><input type="image" src="images/remove.gif" name="RemoveSelected" border="0"></td>
					<input type="hidden" name="DelThese" value="0">
					<cfoutput>
						<input type="hidden" name="AccountID" value="#ReturnID#">					
					</cfoutput>
				</tr>
			</table>
		</th>
	</tr>
</form>
	<cfif GroupList.Recordcount GT Mrow>
		<tr>
			<form method="post" action="group2.cfm">
				<td colspan="8"><select name="page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5 * Mrow) - (Mrow - 1)>
						<cfset DispStr = GroupList.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #GroupList.Recordcount#</cfoutput>
				</select></td>
				<cfoutput>
					<input type="hidden" name="LoopCount" value="#LoopCount#">
					<input type="hidden" name="Counter1" value="#Counter1#">
					<input type="hidden" name="AccountID" value="#ReturnID#">
				</cfoutput>
			</form>
		</tr>
	</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 