<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Group Account Maintenance --->
<!--- 4.0.0 10/23/99 --->
<!--- group5.cfm --->

<cfset securepage = "lookup1.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("TakeOver.x")>
	<cfquery name="TakeOver" datasource="#pds#">
		UPDATE MassActions SET 
		AdminID = #MyAdminID# 
		WHERE BillingID = #BillingID# 
	</cfquery>
</cfif>
<cfif IsDefined("FinalConfirm.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE MassActions SET 
		DeactivateYN = 0, 
		ReactivateYN = 0, 
		CancelYN = 0, 
		CancelSchedYN = 0 
		WHERE BillingID = #BillingID# 
	</cfquery>
	<cfif IsDefined("CancelSched")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			CancelSchedYN = 1 
			WHERE AccountID In (#CancelSched#) 
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("Deact")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			DeactivateYN = 1 
			WHERE AccountID In (#Deact#) 
			<cfif IsDefined("Cancel")>
				AND AccountID Not In (#Cancel#)
			</cfif>
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("React")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			ReactivateYN = 1 
			WHERE AccountID In (#React#) 
			<cfif IsDefined("Cancel")>
				AND AccountID Not In (#Cancel#)
			</cfif>
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("Cancel")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			CancelYN = 1 
			WHERE AccountID In (#Cancel#) 
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="group7.cfm">
	<cfabort>
</cfif>
<cfquery name="CheckSession" datasource="#pds#">
	SELECT AdminID 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	AND AdminID <> #MyAdminID# 
</cfquery>
<cfif CheckSession.Recordcount GT 0>
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="group6.cfm">
	<cfabort>
</cfif>
<cfif IsDefined("SetStatus.X")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE MassActions SET 
		DeactivateYN = 0, 
		ReactivateYN = 0, 
		CancelYN = 0, 
		CancelSchedYN = 0  
		WHERE BillingID = #BillingID# 
	</cfquery>
	<cfif IsDefined("CancelSched")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			CancelSchedYN = 1 
			WHERE AccountID In (#CancelSched#) 
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("Deact")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			DeactivateYN = 1 
			WHERE AccountID In (#Deact#) 
			<cfif IsDefined("Cancel")>
				AND AccountID Not In (#Cancel#)
			</cfif>
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("React")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			ReactivateYN = 1 
			WHERE AccountID In (#React#) 
			<cfif IsDefined("Cancel")>
				AND AccountID Not In (#Cancel#)
			</cfif>
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfif IsDefined("Cancel")>
		<cfquery name="UpdData" datasource="#pds#">	
			UPDATE MassActions SET 
			CancelYN = 1 
			WHERE AccountID In (#Cancel#) 
			AND BillingID = #BillingID# 
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MassSettings.x")) OR (IsDefined("StartOver.x"))>
	<cfif IsDefined("StartOver.x")>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM MassActions 
			WHERE BillingID = #BillingID# 
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT TBDID 
		FROM MassActions 
		WHERE BillingID = #BillingID# 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfquery name="GetGroup" datasource="#pds#">
			INSERT INTO MassActions 
			(AccountID, AdminID, BillingID, LastName, FirstName, DeactivateYN, CancelYN, ReactivateYN, 
			 Status, PrimaryAccnt, Company, Reason4, WhenRun, DoAction)
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			1, M.BillTo, A.Company, Null, Null, Null 
			FROM Accounts A, Multi M 
			WHERE A.AccountID = M.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 0 
			AND A.DeactivatedYN =  0 
			AND A.AccountID NOT IN 
				(SELECT AccountID 
				 FROM AutoRun 
				 WHERE AccountID IS NOT NULL)
			UNION 
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			2, M.BillTo, A.Company, Null, Null, Null 
			FROM Accounts A, Multi M 
			WHERE A.AccountID = M.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 0 
			AND A.DeactivatedYN = 1 
			AND A.AccountID NOT IN 
				(SELECT AccountID 
				 FROM AutoRun 
				 WHERE AccountID IS NOT NULL)
			UNION
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			3, M.BillTo, A.Company, Null, Null, Null 
			FROM Accounts A, Multi M 
			WHERE A.AccountID = M.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 1 
			AND A.DeactivatedYN = 0 
			AND A.AccountID NOT IN 
				(SELECT AccountID 
				 FROM AutoRun 
				 WHERE AccountID IS NOT NULL)
			UNION
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			1, M.BillTo, A.Company, Null, R.WhenRun, R.DoAction 
			FROM Accounts A, Multi M, AutoRun R 
			WHERE A.AccountID = M.AccountID 
			AND A.AccountID = R.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 0 
			AND A.DeactivatedYN =  0 
			AND R.DoAction IN ('Cancel','Reactivate','Deactivate')
			UNION 
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			2, M.BillTo, A.Company, Null, R.WhenRun, R.DoAction 
			FROM Accounts A, Multi M, AutoRun R 
			WHERE A.AccountID = M.AccountID 
			AND A.AccountID = R.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 0 
			AND A.DeactivatedYN = 1 
			AND R.DoAction IN ('Cancel','Reactivate','Deactivate')
			UNION
			SELECT A.AccountID, #MyAdminID#, #BillingID#, A.LastName, A.FirstName, 0, 0, 0, 
			3, M.BillTo, A.Company, Null, R.WhenRun, R.DoAction 
			FROM Accounts A, Multi M, AutoRun R 
			WHERE A.AccountID = M.AccountID 
			AND A.AccountID = R.AccountID 
			AND M.BillingID = #BillingID# 
			AND A.CancelYN = 1 
			AND A.DeactivatedYN = 0 
			AND R.DoAction IN ('Cancel','Reactivate','Deactivate')
		</cfquery>
	</cfif>
</cfif>
<cfquery name="GetGroups" datasource="#pds#">
	SELECT * 
	FROM MassActions 
	WHERE BillingID = #BillingID# 
	ORDER BY PrimaryAccnt desc, LastName, FirstName 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Mass Deactivate/ Cancel</title>
<script language="javascript">
<!--
function SelectAllD(tf)
	{
	 var len = document.SelectWho.Deact.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.SelectWho.Deact[i].checked=tf
		}
	}
function SelectAllR(tf)
	{
	 var len = document.SelectWho.React.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.SelectWho.React[i].checked=tf;
		}
	}
function SelectAllC(tf)
	{
	 var len = document.SelectWho.Cancel.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.SelectWho.Cancel[i].checked=tf;
		}
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="group2.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="12"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Mass Deactivate/ Cancel</font></th>
	</tr>
	<tr bgcolor="#thclr#" valign="top">
		<th colspan="2">Deactivate</th>
		<th colspan="2">Reactivate</th>
		<th colspan="2">Cancel</th>
		<th rowspan="2">Status</th>
		<th colspan="3">Scheduled</th>
		<th rowspan="2">Name</th>
		<th rowspan="2">Company</th>
	</tr>
	<tr bgcolor="#tdclr#">
		<td><font size="1"><a href="javascript:SelectAllD(true)">Select</a></font></td>
		<td><font size="1"><a href="javascript:SelectAllD(false)">Clear</a></font></td>
		<td><font size="1"><a href="javascript:SelectAllR(true)">Select</a></font></td>
		<td><font size="1"><a href="javascript:SelectAllR(false)">Clear</a></font></td>
		<td><font size="1"><a href="javascript:SelectAllC(true)">Select</a></font></td>
		<td><font size="1"><a href="javascript:SelectAllC(false)">Clear</a></font></td>		
		<th bgcolor="#thclr#">Cancel</th>
		<th bgcolor="#thclr#">Date</th>
		<th bgcolor="#thclr#">Action</th>
	</tr>
</cfoutput>
<form method="post" action="group5.cfm" name="SelectWho">
	<cfoutput  query="GetGroups">
		<tr bgcolor="#tbclr#">
			<cfif Status Is 3>
				<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
			<cfelseif Status Is 2>
				<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<th colspan="2" bgcolor="#tdclr#"><input type="checkbox" <cfif ReactivateYN Is 1>checked</cfif> name="React" value="#AccountID#"></th>
				<cfif PrimaryAccnt Is 1>
					<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<cfelse>
					<th colspan="2" bgcolor="#tdclr#"><input type="checkbox" <cfif CancelYN Is 1>checked</cfif> name="Cancel" value="#AccountID#"></th>
				</cfif>
			<cfelse>
				<th colspan="2" bgcolor="#tdclr#"><input type="checkbox" <cfif DeactivateYN Is 1>checked</cfif> name="Deact" value="#AccountID#"></th>
				<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<cfif PrimaryAccnt Is 1>
					<th colspan="2" bgcolor="#tdclr#">&nbsp;</th>
				<cfelse>
					<th colspan="2" bgcolor="#tdclr#"><input type="checkbox" <cfif CancelYN Is 1>checked</cfif> name="Cancel" value="#AccountID#"></th>	
				</cfif>
			</cfif>
			<cfif PrimaryAccnt Is 1>
				<th bgcolor="#tdclr#">Primary</th>
			<cfelseif Status Is 3>
				<th bgcolor="#tdclr#">Cancelled</th>
			<cfelseif Status Is 2>
				<th bgcolor="#tdclr#">Deactivated</th>
			<cfelse>
				<th bgcolor="#tdclr#">Active</th>
			</cfif>
			<cfif Trim(WhenRun) Is "">
				<th bgcolor="#tdclr#">&nbsp;</th>
			<cfelse>
				<th bgcolor="#tdclr#"><input type="checkbox" <cfif CancelSchedYN Is 1>checked</cfif> name="CancelSched" value="#AccountID#"></th>
			</cfif>
			<td>#LSDateFormat(WhenRun, '#DateMask1#')#<cfif Trim(WhenRun) Is "">&nbsp;</cfif></td>
			<td>#DoAction#<cfif Trim(DoAction) Is "">&nbsp;</cfif></td>
			<td><a href="custinf1.cfm?accountid=#AccountID#" <cfif getopts.OpenNew Is 1>target="_new"</cfif> >#LastName#, #FirstName#</a></td>
			<td>#Company#<cfif Trim(Company) Is "">&nbsp;</cfif></td>
		</tr>
	</cfoutput>
	<tr>
		<th colspan="12">
			<table border="0">
				<tr>
					<td><input type="image" src="images/update.gif" name="SetStatus" border="0"></td>
					<td><input type="image" src="images/reset.gif" name="StartOver" border="0"></td>
					<td><input type="Image" src="images/continue.gif" name="FinalConfirm" border="0"></td>
				</tr>
			</table>
		</th>
	</tr>
	<cfoutput>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<input type="hidden" name="BillingID" value="#BillingID#">
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 