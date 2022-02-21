<cfsetting enablecfoutputonly="yes">
<!-- Version 3.5.0 -->
<!--- This page is a list of all the admins.
--->
<!--- 3.5.0 06/30/99
		3.2.0 09/08/98 --->
<!-- adminedt.cfm -->
<cfset securepage="adminedt.cfm">
<cfinclude template="security.cfm">
<cfif (IsDefined("DupPermissions.x")) AND (IsDefined("CopyFrom")) AND (IsDefined("CopyTo"))>
	<cfset ToFromCheck = ListFind(CopyTo,CopyFrom)>
	<cfif ToFromCheck GT 0>
		<cfset CopyTo = ListDeleteAt(CopyTo,ToFromCheck)>
	</cfif>
	<cfif CopyTo Is Not "">
		<cfquery name="GetFrom" datasource="#pds#">
			SELECT * 
			FROM Admin 
			WHERE AdminID = #CopyFrom#
		</cfquery>
		<cfquery name="GetSort" datasource="#pds#">
			SELECT * 
			FROM AdmSort 
			WHERE AdminID = #CopyFrom# 
			ORDER BY SortOrder 
		</cfquery>
		<cfloop query="GetFrom">
			<cfset aeditinfo = editinfo>
			<cfset achpass = chpass> 
			<cfset aeditpay = editpay> 
			<cfset amenulev = menulev> 
			<cfset apayhist = payhist> 
			<cfset asupphist = supphist> 
			<cfset asesshist = sesshist> 
			<cfset aviewother = viewother> 
			<cfset axemail = xemail> 
			<cfset achplan = chplan> 
			<cfset awaivea = waivea> 
			<cfset adeactc = deactc> 
			<cfset acancelc = cancelc> 
			<cfset acancela = cancela> 
			<cfset adeltrans = deltrans> 
			<cfset awhatview = whatview> 
			<cfset aschevent = schevent> 
			<cfset aReactAcnt = ReactAcnt> 
			<cfset aViewCPasswd = ViewCPasswd> 
			<cfset aViewAPasswd = ViewAPasswd> 
			<cfset aEditName = EditName> 
			<cfset aBOBHist = BOBHist> 
			<cfset aBOBAHist = BOBAHist> 
			<cfset aKeepDays = KeepDays> 
			<cfset aSessOut = SessOut> 
			<cfset aSUserYN = SUserYN> 
			<cfset aSalesPersonYN = SalesPersonYN>  
			<cfset aOnlineSignup = OnlineSignup>
			<cfset aSendEMail = SendEMail>
			<cfset aCCViewAll = CCViewAll>
			<cfset aOverRide = OverRide>
			<cfset aPrivRep = PrivRep>
		</cfloop>
		<cfquery name="UpdTo" datasource="#pds#">
			UPDATE Admin SET 
			editinfo = #aeditinfo#, chpass = #achpass#, editpay = #aeditpay#, menulev = #amenulev#, payhist = #apayhist#, 
			supphist = #asupphist#, sesshist = #asesshist#, viewother = #aviewother#, 
			xemail = #axemail#, chplan = #achplan#, waivea = #awaivea#, deactc = #adeactc#, cancelc = #acancelc#, 
			cancela = #acancela#, deltrans = #adeltrans#, whatview = #awhatview#, schevent = #aschevent#, 
			ReactAcnt = #aReactAcnt#, ViewCPasswd = #aViewCPasswd#, ViewAPasswd = #aViewAPasswd#, 
			EditName = #aEditName#, BOBHist = #aBOBHist#, BOBAHist = #aBOBAHist#, KeepDays = #aKeepDays#, 
			SessOut = #aSessOut#, SUserYN = #aSUserYN#, SalesPersonYN = #aSalesPersonYN#, OnlineSignup = #aOnlineSignup#, 
			SendEMail = #aSendEMail#, CCViewAll = #aCCViewAll#, OverRide = #aOverRide#, 
			PrivRep =#aPrivRep# 
			WHERE AdminID In (#CopyTo#)		
		</cfquery>
		<cfquery name="resetPOPS" datasource="#pds#">
			DELETE FROM POPAdm 
			WHERE AdminID In (#CopyTo#)
		</cfquery>
		<cfquery name="resetPlans" datasource="#pds#">
			DELETE FROM PlanAdm 
			WHERE AdminID In (#CopyTo#)
		</cfquery>
		<cfquery name="resetMenus" datasource="#pds#">
			DELETE FROM Connect 
			WHERE AdminID In (#CopyTo#)
		</cfquery>
		<cfquery name="resetDoms" datasource="#pds#">
			DELETE FROM DomAdm 
			WHERE AdminID In (#CopyTo#)
		</cfquery>
		<cfquery name="resetLetters" datasource="#pds#">
			DELETE FROM LetterAdm 
			WHERE AdminID In (#CopyTo#) 
		</cfquery>
		<cfloop index="B5" list="#CopyTO#">
			<cfquery name="AddPOPs" datasource="#pds#">
				INSERT INTO POPAdm 
				(AdminID,POPID) 
				SELECT #B5#,POPID 
				FROM POPAdm 
				WHERE AdminID = #CopyFrom# 
			</cfquery>
			<cfquery name="AddPlans" datasource="#pds#">
				INSERT INTO PlanAdm 
				(AdminID,PlanID) 
				SELECT #B5#,PlanID 
				FROM PlanAdm 
				WHERE AdminID = #CopyFrom# 
			</cfquery>
			<cfquery name="AddMenus" datasource="#pds#">
				INSERT INTO Connect 
				(AdminID,MenuID) 
				SELECT #B5#,MenuID 
				FROM Connect 
				WHERE AdminID = #CopyFrom# 
			</cfquery>
			<cfquery name="AddPOPs" datasource="#pds#">
				INSERT INTO DomAdm 
				(AdminID,DomainID) 
				SELECT #B5#,DomainID 
				FROM DomAdm 
				WHERE AdminID = #CopyFrom# 
			</cfquery>
			<cfquery name="AddLetters" datasource="#pds#">
				INSERT INTO LetterAdm 
				(AdminID, IntID) 
				SELECT #B5#, IntID 
				FROM LetterAdm 
				WHERE AdminID = #CopyFrom# 
			</cfquery>
			<cfquery name="MaxSort" datasource="#pds#">
				SELECT Max(SortOrder) as TopSort 
				FROM AdmSort 
				WHERE AdminID = #B5# 
			</cfquery>
			<cfif MaxSort.TopSort Is "">
				<cfset TopSort = 1>
			<cfelse>
				<cfset TopSort = MaxSort.TopSort + 1>
			</cfif>
			<cfloop query="GetSort">
				<cfquery name="CheckFirst" datasource="#pds#">
					SELECT * 
					FROM AdmSort 
					WHERE LevelID = #LevelID# 
					AND AdminID = #B5# 
				</cfquery>
				<cfif CheckFirst.RecordCount Is 0>
					<cfquery name="AddNewLevel" datasource="#pds#">
						INSERT INTO AdmSort 
						(AdminID, LevelID, SortOrder) 
						VALUES 
						(#B5#, #LevelID#, #TopSort#)
					</cfquery>
					<cfset TopSort = TopSort + 1>
				</cfif>
			</cfloop>
			<cfquery name="CleanUpSort" datasource="#pds#">
				DELETE FROM AdmSort 
				WHERE AdminID = #B5# 
				AND LevelID Not IN 
					(SELECT AdmSort.LevelID 
					 FROM AdmSort A 
					 WHERE A.AdminID = #B5# 
					 AND AdmSort.LevelID In 
					 	(SELECT Menu 
						 FROM MenuItems M, Connect C 
						 WHERE M.MenuID = C.MenuID AND C.AdminID = #B5#)
					)
			</cfquery>
			<cfquery name="ResetSort" datasource="#pds#">
				SELECT * 
				FROM AdmSort 
				WHERE AdminID = #B5# 
				ORDER BY SortOrder
			</cfquery>
			<cfloop query="ResetSort">
				<cfquery name="ResetEm" datasource="#pds#">
					UPDATE AdmSort SET 
					SortOrder = #CurrentRow# 
					WHERE AdminID = #B5# 
					AND LevelID = #LevelID# 
				</cfquery>
			</cfloop>
		</cfloop>
	</cfif>
</cfif>
<cfif IsDefined("RemoveStaff.x")>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM Admin
			</cfquery>
			<cfif CheckFirst.RecordCount GT 1>
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="GetWhoIs" datasource="#pds#">
						SELECT AccountID, FirstName, LastName 
						FROM Accounts 
						WHERE AccountID = (SELECT AccountID 
												 FROM Admin 
												 WHERE AdminID = #B5#)
					</cfquery>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,#GetWhoIs.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed #GetWhoIs.FirstName# #GetWhoIs.LastName# from the staff list.')
					</cfquery>
				</cfif>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM Connect 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM DomAdm 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM PlanAdm 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM POPAdm 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM FilterSalesP 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM LetterAdm 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#pds#">
					DELETE FROM EMailOutgoing 
					WHERE AdminID = #B5#
				</cfquery>
				<cfquery name="CleanUp" datasource="#pds#">
					DELETE FROM GrpLists 
					WHERE AdminID = #B5# 
				</cfquery>
				<cfquery name="CleanUp" datasource="#PDS#">
					DELETE FROM Admin 
					WHERE AdminID = #B5#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="ordby" default="name">
<cfparam name="orddir" default="asc">
<cfquery name="AllAdmin" datasource="#PDS#">
	SELECT U.FirstName, U.LastName, U.AccountID, 
	U.Login, A.AdminID, A.SUserYN, A.SalesPersonYN, A.LastSess 
	FROM Accounts U, Admin A
	WHERE U.AccountID = A.AccountID 
	ORDER BY 
	<cfif ordby Is "Name">
		LastName #orddir#, FirstName #orddir# 
	<cfelse>
		#ordby# #orddir# 
	</cfif>
</cfquery>
<cfset HowWide = 8>
<cfif GetOpts.SUserYN Is "1">
	<cfset HowWide = 9>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>gBill Staff</TITLE>
<cfinclude template="coolsheet.cfm">
<cfif AllAdmin.RecordCount GT 1>
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelAdmin.checked
		 var var3 = document.EditInfo.DelAdmin.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelAdmin[count].checked
		 var var3 = document.EditInfo.DelAdmin[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
</cfif>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>

<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">gBill Staff</font></th>
	</tr>
	<tr>
		<form method=post action="admined2.cfm">
			<td align="right" colspan="#HowWide#"><input type="image" src="images/addnew.gif" border="0" name="LookUp"></td>
		</form>
	</tr>
	<tr bgcolor="#thclr#" valign="top">
		<th rowspan="2">Edit</th>
		<th colspan="2">Permissions</th>
		<th rowspan="2">Super</th>
		<th rowspan="2">Sales</th>
		<form method="post" action="adminedt.cfm">
			<th rowspan="2"><input type="radio" <cfif ordby Is "Name">checked</cfif> name="ordby" value="Name" onclick="submit()" id="col1"><label for="col1">Name</label></th>
			<cfif (ordby Is "Name") AND (orddir Is "asc")>
				<input type="hidden" name="orddir" value="desc">
			</cfif>
		</form>
		<form method="post" action="adminedt.cfm">
			<th rowspan="2"><input type="radio" <cfif ordby Is "Login">checked</cfif> name="ordby" value="Login" onclick="submit()" id="col2"><label for="col2">Login</label></th>
			<cfif (ordby Is "Login") AND (orddir Is "asc")>
				<input type="hidden" name="orddir" value="desc">
			</cfif>
		</form>
		<cfif GetOpts.SUserYN Is "1">
			<form method="post" action="adminedt.cfm">
				<th rowspan="2"><input type="radio" <cfif ordby Is "LastSess">checked</cfif> name="ordby" value="LastSess" onclick="submit()" id="col3"><label for="col3">Last Visit</label></th>
				<cfif (ordby Is "LastSess") AND (orddir Is "asc")>
					<input type="hidden" name="orddir" value="desc">
				</cfif>
			</form>
		</cfif>
		<th rowspan="2">Remove</th>
	</tr>
	<tr bgcolor="#thclr#">
		<th><font size="1">Copy From</font></th>
		<th><font size="1">Copy To</font></th>
	</tr>
</cfoutput>
<form method=post action="adminedt.cfm?RequestTimeout=500" name="EditInfo">	
	<cfoutput query="alladmin">
		<tr valign="top">
			<th bgcolor="#tdclr#"><input type="radio" name="AdminID" value="#AdminID#" onClick="document.EditInfo.action = 'admined3.cfm';document.EditInfo.submit()"></th>
			<th bgcolor="#tdclr#"><input type="radio" name="CopyFrom" value="#AdminID#"></th>
			<th bgcolor="#tdclr#"><input type="checkbox" name="CopyTo" value="#AdminID#"></th>
			<td bgcolor="#tbclr#">#YesNoFormat(SUserYN)#</td>
			<td bgcolor="#tbclr#">#YesNoFormat(SalesPersonYN)#</td>
			<td bgcolor="#tbclr#"><a href="custinf1.cfm?accountid=#accountid#" <cfif getopts.OpenNew Is 1>target="_New"</cfif> >#lastname#, #firstname#</a></td>
			<td bgcolor="#tbclr#">#login#</td>
			<cfif GetOpts.SUserYN Is "1">
				<td bgcolor="#tbclr#">#DateFormat(lastsess, '#DateMask1#')# #TimeFormat(lastsess, 'hh:mm tt')#</td>
			</cfif>
			<th bgcolor="#tdclr#"><cfif AllAdmin.RecordCount GT 1><Input type="checkbox" value="#adminid#" name="DelAdmin" onClick="SetValues(#AdminID#,this)"><cfelse>&nbsp;</cfif></td>
		</tr>
	</cfoutput>
	<cfoutput>
		<input type="hidden" name="LoopCount" value="#AllAdmin.RecordCount#">
	<tr>
		<th colspan="#HowWide#">
	</cfoutput>
			<table border="0">
				<tr>
					<td><input type="image" src="images/duplicate.gif" name="DupPermissions" border="0"></td>
</form>
<form method="post" name="PickDelete" action="adminedt.cfm" onSubmit="return confirm ('Press OK to confirm removing the selected staff from the staff list')">
					<input type="hidden" name="DelThese" value="0">
					<td><input type="image" src="images/delete.gif" name="RemoveStaff" border="0"></td>
				</tr>
			</table>
		</th>
	</tr>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>





