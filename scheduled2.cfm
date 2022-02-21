<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is called from autorunselect0.cfm to show the scheduled events.
--->
<!--- 4.0.0 00/30/99 --->
<!--- scheduled2.cfm --->

<cfif (IsDefined("accountid")) AND (GetOpts.SchEvent Is 1)>
	<cfset SecurePage = "lookup1.cfm">
<cfelse>
	<cfset SecurePage = "scheduled.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfif IsDefined("UpdSchedule.x")>
	<cfset TheDate = ParseDateTime("#WhenRun#")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE AutoRun SET 
		<cfif IsDefined("Memo1")>Memo1='#form.memo#', </cfif>
		<cfif IsDefined("value1")>value1='#value1#', </cfif>
		<cfif IsDefined("value2")>value2='#value2#', </cfif>
		<cfif IsDefined("accountid")>accountid = #accountid#, </cfif>
		<cfif IsDefined("emailid")>emailid = #emailid#, </cfif>
		<cfif IsDefined("EMailFrom")>EMailFrom = '#EMailFrom#', </cfif>
		<cfif IsDefined("EMailSubject")>EMailSubject = '#EMailSubject#', </cfif>
		<cfif IsDefined("EMailTo")>EMailTo = '#EMailTo#', </cfif>
		<cfif IsDefined("FileAttach")>FileAttach = '#FileAttach#', </cfif>
		<cfif IsDefined("EMailCC")>EMailCC = '#EMailCC#', </cfif>
		<cfif IsDefined("AccntPlanID")>AccntPlanID = #AccntPlanID#, </cfif>
		<cfif IsDefined("PlanID")>PlanID = #PlanID#, </cfif>
		WhenRun = #TheDate#
		WHERE AutoRunID = #AutoRunID# 
	</cfquery>
</cfif>
<cfif IsDefined("DeleteSelected.x")>
	<cfquery name="GetData" datasource="#pds#">
		SELECT * 
		From Autorun 
		Where AutoRunID In (#DelThese#) 
	</cfquery>
	<cfloop query="GetData">
		<cfif (DoAction Is "Cancel") OR (DoAction Is "Deactivate")>
			<cfquery name="UpdPlans" datasource="#pds#">
				UPDATE AccntPlans SET 
				BillingStatus = 1 
				WHERE AccountID = #AccountID#
			</cfquery>
		</cfif>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM AutoRun 
			WHERE AutoRunID = #AutoRunID#
		</cfquery>
	</cfloop>
		
</cfif>
<cfparam name="page" default="1">
<cfparam name="ordby" default="Name">
<cfparam name="orddir" default="asc">
<cfparam name="FromYear" default="#Year(Now())#">
<cfparam name="FromMon" default="#Month(Now())#">
<cfparam name="FromDay" default="#Day(Now())#">
<cfset ToDate = DateAdd("yyyy",10,Now())>
<cfparam name="ToYear" default="#Year(ToDate)#">
<cfparam name="ToMon" default="#Month(ToDate)#">
<cfparam name="ToDay" default="#Day(ToDate)#">
<cfif IsDefined("AccountID")>
	<cfquery name="GetDate" datasource="#pds#">
		SELECT Min(WhenRun) as MnD, Max(WhenRun) as MxD 
		FROM AutoRun 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetAction" datasource="#pds#">
		SELECT DoAction 
		FROM AutoRun 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfparam name="DoAction" default="#GetAction.DoAction#">
	<cfif GetDate.MnD Is Not "">
		<cfset FromYear = Year(GetDate.MnD)>
		<cfset FromMon = Month(GetDate.MnD)>
		<cfset FromDay = Day(GetDate.MnD)>
		<cfset ToYear = Year(GetDate.MxD)>
		<cfset ToMon = Month(GetDate.MxD)>
		<cfset ToDay = Day(GetDate.MxD)>
	</cfif>
</cfif>
<cfparam name="DoAction" default="Rollback">
<cfset TheAction = DoAction>
<cfquery name="GetRoll" datasource="#pds#">
	<cfset Date1 = CreateDateTime(#FromYear#,#FromMon#,#FromDay#,00,00,00)>
	<cfset Date2 = CreateDateTime(#ToYear#,#ToMon#,#ToDay#,23,59,59)>
	<cfif (DoAction Is "Rollback") OR (DoAction Is "EMail") 
	   OR (DoAction Is "EMailDelay")>		
		SELECT R.*, P.PlanID, P.PlanDesc, A.FirstName, A.LastName, A.AccountID 
		FROM AutoRun R, Plans P, Accounts A 
		WHERE A.AccountID = R.AccountID 
		AND R.PlanID = P.PlanID 
	<cfelseif (DoAction Is "RunCustom") OR (DoAction Is "Reactivate") 
		OR (DoAction Is "Cancel") OR (DoAction Is "Deactivate")>
		SELECT R.*, A.FirstName, A.LastName, A.AccountID 
		FROM AutoRun R, Accounts A 
		WHERE A.AccountID = R.AccountID 
	<cfelse>
		SELECT R.* 
		FROM AutoRun R 
		WHERE R.DoAction = '#TheAction#' 
	</cfif>
	<cfif IsDefined("accountid")>
		AND R.AccountID = #accountid# 
	</cfif>	
	AND R.Whenrun <= #CreateODBCDateTime(Date2)# 		
	AND R.Whenrun >= #CreateODBCDateTime(Date1)#
	ORDER BY DoAction, WhenRun
</cfquery>
<cfif Page GT 0>
	<cfset MaxRows = mrow>
	<cfset Srow = (page * mrow) - (mrow - 1)>
<cfelse>
	<cfset Srow = 1>
	<cfset MaxRows = GetRoll.RecordCount>
</cfif>
<cfset PageNumber = Ceiling(GetRoll.RecordCount/mrow)>


<cfquery name="TheDoTypes" datasource="#pds#">
	SELECT DoAction 
	FROM AutoRun 
	<cfif IsDefined("AccountID")>
		WHERE AccountID = #AccountID# 
	</cfif>
	GROUP BY DoAction 
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
<html>
<head>
<title>Scheduled Events</TITLE>
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
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif IsDefined("accountid")>
	<cfoutput>
	<table border="0">
		<tr>
			<form method="post" action="custinf1.cfm">
				<input type="hidden" name="AccountID" value="#AccountID#">
				<td><input type="image" src="images/returncust.gif" border="0" alt="Return to Customer Data"></td>
			</form>
		</tr>
	</table>
	</cfoutput>
<cfelse>
	<cfoutput>
	<table border="0">
		<tr>
			<form method="post" action="scheduled.cfm">
				<td><input type="image" src="images/changecriteria.gif" border="0"></td>
			</form>
		</tr>
	</table>
	</cfoutput>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="9" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Scheduled Events</font></th>
	</tr>
</cfoutput>
	<cfif TheDoTypes.Recordcount GT 0>
		<tr>
			<form method="post" action="scheduled2.cfm">
				<cfoutput>
				<input type="Hidden" name="FromMon" value="#FromMon#">
				<input type="Hidden" name="ToMon" value="#ToMon#">
				<input type="Hidden" name="FromYear" value="#FromYear#">
				<input type="Hidden" name="FromDay" value="#FromDay#">
				<input type="Hidden" name="ToYear" value="#ToYear#">
				<input type="Hidden" name="ToDay" value="#ToDay#">
				<cfif IsDefined("accountid")>
					<input type="hidden" name="AccountID" value="#AccountID#">			
				</cfif>
				</cfoutput>
				<td colspan="9"><select name="DoAction" onchange="submit()">
					<cfoutput query="TheDoTypes"><option <cfif DoAction Is TheAction>selected</cfif> value="#DoAction#">#DoAction#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<cfif GetRoll.Recordcount GT MRow>
		<tr>
			<form method="post" action="scheduled2.cfm">
				<cfoutput>
				<input type="Hidden" name="FromMon" value="#FromMon#">
				<input type="Hidden" name="ToMon" value="#ToMon#">
				<input type="Hidden" name="FromYear" value="#FromYear#">
				<input type="Hidden" name="FromDay" value="#FromDay#">
				<input type="Hidden" name="ToYear" value="#ToYear#">
				<input type="Hidden" name="ToDay" value="#ToDay#">
				<cfif IsDefined("accountid")>
					<input type="hidden" name="AccountID" value="#AccountID#">			
				</cfif>
				</cfoutput>
				<td colspan="9"><select name="page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #DoAction# - #GetRoll.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
<cfif getroll.recordcount gt 0>
	<form action="scheduled3.cfm" method="POST" name="EditInfo">
		<cfoutput>
		<input type="Hidden" name="FromMon" value="#FromMon#">
		<input type="Hidden" name="ToMon" value="#ToMon#">
		<input type="Hidden" name="FromYear" value="#FromYear#">
		<input type="Hidden" name="FromDay" value="#FromDay#">
		<input type="Hidden" name="ToYear" value="#ToYear#">
		<input type="Hidden" name="ToDay" value="#ToDay#">
		<cfif IsDefined("accountid")>
			<input type="hidden" name="AccountID" value="#AccountID#">			
		</cfif>
		</cfoutput>
		<cfoutput>
		<tr valign="top" bgcolor="#thclr#" valign="top">
			<th>Edit</th>
			<th>Action</th>
			<th>When</th>
			<cfif (DoAction Is "Reactivate") OR (DoAction Is "Cancel") OR (DoAction Is "Deactivate")>
				<th colspan="5">Name</th>
   		<cfelseif DoAction Is "Rollback">
				<th>Name</th>
				<th colspan="2">Plan</th>
				<th colspan="2">Reason</th>
			<cfelseif DoAction Is "EMail">
				<th>Name</th>
				<th>Memo</th>
				<th colspan="2">subject</th>
				<th>From</th>
			<cfelseif DoAction Is "DeleteFile">
				<th colspan="5">File</th>
			<cfelseif DoAction Is "IPAD">
				<th colspan="5">Type</th>	
			<cfelseif DoAction Is "EMailDelay">
				<th>Name</th>
				<th>Memo</th>
				<th colspan="2">subject</th>
				<th>From</th>
			<cfelseif DoAction Is "RunCustom">
				<th>Name</th>
				<th colspan="4">CFM</th>
			<cfelse>
				<th colspan="5">&nbsp;</th>
			</cfif>
			<th>Delete</th>
		</tr>
		</cfoutput>
		<cfset counter1 = 0>
		<cfoutput query="getroll" startrow="#Srow#" maxrows="#MaxRows#">
			<cfset counter1 = counter1 + 1>
			<tr valign="top" bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="radio" name="AutoRunID" value="#AutoRunID#" onclick="submit()"></td>
				<td>#DoAction#</td>
				<td nowrap>#LSDateFormat(WhenRun, '#DateMask1#')# #TimeFormat(WhenRun, 'hh:mm tt')#</td>
				<cfif (DoAction Is "Reactivate") OR (DoAction Is "Cancel") OR (DoAction Is "Deactivate")>
					<th colspan="5"><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></th>
				<cfelseif doaction is "Rollback">
					<td><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></td>
					<td colspan="2">#plandesc#</td>
					<td colspan="2">#Value2# </td>
				<cfelseif DoAction Is "EMail">
					<td><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></td>
					<td>#Memo1# </td>
					<td colspan="2">#value1# </td>
					<td>#Value2# </td>
				<cfelseif DoAction Is "DeleteFile">
					<td colspan="5">#FileAttach#</td>
				<cfelseif DoAction Is "IPAD">
					<td colspan="5">#Value1#</td>
				<cfelseif DoAction Is "EMailDelay">
					<th><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></th>
					<th>#Memo1#&nbsp;</th>
					<th colspan="2">#value1# </th>
					<th>#Value2# </th>
				<cfelseif DoAction Is "RunCustom">
					<th><a href="custinf1.cfm?AccountID=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></th>
					<th colspan="4">#value2#&nbsp;</th>
				<cfelse>
					<td colspan="5">&nbsp;</td>
				</cfif>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#AutoRunID#" onClick="SetValues(#AutoRunID#,this)"></th>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#Counter1#">
		</cfoutput>
	</form>
	<form method="post" action="scheduled2.cfm" name="PickDelete">
		<cfoutput>
			<input type="Hidden" name="FromMon" value="#FromMon#">
			<input type="Hidden" name="ToMon" value="#ToMon#">
			<input type="Hidden" name="FromYear" value="#FromYear#">
			<input type="Hidden" name="FromDay" value="#FromDay#">
			<input type="Hidden" name="ToYear" value="#ToYear#">
			<input type="Hidden" name="ToDay" value="#ToDay#">
			<cfif IsDefined("accountid")>
				<input type="hidden" name="AccountID" value="#AccountID#">			
			</cfif>
		</cfoutput>
		<input type="hidden" name="DelThese" value="0">
		<tr>
			<th colspan="9"><input type="image" name="DeleteSelected" src="images/delete.gif" border="0"></th>
		</tr>
	</form>
	<cfif GetRoll.Recordcount GT MRow>
		<tr>
			<form method="post" action="scheduled2.cfm">
				<cfoutput>
				<input type="Hidden" name="FromMon" value="#FromMon#">
				<input type="Hidden" name="ToMon" value="#ToMon#">
				<input type="Hidden" name="FromYear" value="#FromYear#">
				<input type="Hidden" name="FromDay" value="#FromDay#">
				<input type="Hidden" name="ToYear" value="#ToYear#">
				<input type="Hidden" name="ToDay" value="#ToDay#">
				<cfif IsDefined("accountid")>
					<input type="hidden" name="AccountID" value="#AccountID#">			
				</cfif>
				</cfoutput>
				<td colspan="9"><select name="page" onChange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All #DoAction# - #GetRoll.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<tr>
		<form method="post" action="scheduled2.cfm">
			<cfoutput>
			<input type="Hidden" name="FromMon" value="#FromMon#">
			<input type="Hidden" name="ToMon" value="#ToMon#">
			<input type="Hidden" name="FromYear" value="#FromYear#">
			<input type="Hidden" name="FromDay" value="#FromDay#">
			<input type="Hidden" name="ToYear" value="#ToYear#">
			<input type="Hidden" name="ToDay" value="#ToDay#">
			<cfif IsDefined("accountid")>
				<input type="hidden" name="AccountID" value="#AccountID#">			
			</cfif>
			</cfoutput>
			<td colspan="9"><select name="DoAction" onchange="submit()">
				<cfoutput query="TheDoTypes"><option <cfif DoAction Is TheAction>selected</cfif> value="#DoAction#">#DoAction#</cfoutput>
			</select></td>
		</form>
	</tr>
<cfelse>
	<tr>
		<cfoutput>
			<td colspan="9" bgcolor="#tbclr#">No Scheduled Events in the selected criteria.</td><br>
		</cfoutput>
	</tr>
</cfif>
</table>
</center>
<cfinclude template ="footer.cfm">
</BODY>
</HTML>
    